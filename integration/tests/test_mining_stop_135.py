#!/usr/bin/env python3
"""Unchanged 663cc ARM instructions versus the typed C caller. No real I/O.
Compare every external event and projected byte, preserving lower boundaries.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import random
import struct
from pathlib import Path
import test_monitor_handlers_135 as H
import test_backend_shutdown_135 as S
import test_rescue_stop_135 as R
from arm32_subset import ARM32, MASK
ROOT, HASH, BASE = R.ROOT, R.HASH, S.BASE
START, END = 0x663cc, 0x664ec
OPAQUE_X, OPAQUE_Y = 0x68b964, 0x68bad0
FIELDS = {'started_bits':(0x28,8),'active':(0x24,1),'byte_fd0':(0xfd0,1),
          'byte_fe5':(0xfe5,1),'warmup_done':(0x22c,1),'tuning':(0x1049,1),
          'byte_104a':(0x104a,1),'handle':(0x104c,4),'power':(0x1070,4)}
DEFAULTS = dict(started_bits=0x405edd2f1a9fbe77,active=1,byte_fd0=1,
                byte_fe5=1,warmup_done=1,tuning=1,byte_104a=1,handle=700,power=987)
class State(C.Structure):
    _fields_=[('handlers',C.POINTER(H.State)),('handle_104c',S.U),
              ('byte_104a',S.B),('byte_fd0',S.B),('byte_fe5',S.B)]

class View:
    def __init__(self,p):
        self.g=H.G.State();self.h=H.State();self.s=State()
        for obj in (self.g,self.h,self.s):C.memset(C.addressof(obj),0xa5,C.sizeof(obj))
        self.h.general=C.pointer(self.g);self.s.handlers=C.pointer(self.h)
        self.locations={'started_bits':(self.g,'started_at'),'active':(self.g,'active'),
            'byte_fd0':(self.s,'byte_fd0'),'byte_fe5':(self.s,'byte_fe5'),
            'warmup_done':(self.h,'warmup_done_22c'),'tuning':(self.g,'tuning'),
            'byte_104a':(self.s,'byte_104a'),'handle':(self.s,'handle_104c'),
            'power':(self.g,'sampled_power')}
        for k,v in DEFAULTS.items():self.put(k,p.get(k,v))
        self.before=[C.string_at(C.addressof(obj),C.sizeof(obj)) for obj in (self.g,self.h,self.s)]
    def address(self,k):
        obj,field=self.locations[k];return C.addressof(obj)+getattr(type(obj),field).offset
    def put(self,k,v):
        n=FIELDS[k][1];data=(v&((1<<(n*8))-1)).to_bytes(n,'little');C.memmove(self.address(k),data,n)
    def snap(self):return tuple(int.from_bytes(C.string_at(self.address(k),n),'little') for k,(_,n) in FIELDS.items())
    def guard(self):
        allowed=set()
        for k,(_,n) in FIELDS.items():allowed.update(range(self.address(k),self.address(k)+n))
        for obj,before in zip((self.g,self.h,self.s),self.before):
            start=C.addressof(obj);after=C.string_at(start,len(before))
            assert all(x==y or start+i in allowed for i,(x,y) in enumerate(zip(before,after))), 'unexpected C write'

class Script(R.Script):
    pass

def bind_native(view,ops_parameters,extra_snap=lambda:(),extra_mutate=None):
    events=[];errors=[];callbacks=[]
    def mutate(k,v):
        if k in FIELDS:view.put(k,v)
        else:
            assert extra_mutate is not None,k
            extra_mutate(k,v)
    sc=Script(ops_parameters,lambda:(view.snap(),extra_snap()),mutate)
    def cb(ty,fn):
        def f(*args):
            try:return fn(*args)
            except BaseException as e:errors.append(e);return 0
        call=ty(f);callbacks.append(call);return call
    o=S.Ops()
    def step(_,ep,arg):
        assert ep in (0xfe218,0xb8e54,0x65b3c) and arg==0
        return sc.call(hex(ep),0)&MASK
    def join(_,handle,out):
        assert not out
        return sc.call('join',handle,False)
    o.step=cb(S.STEP,step)
    o.delay_ms=cb(S.DELAY,lambda _,ms:sc.call('delay',ms))
    o.cancel=cb(S.HANDLE,lambda _,handle:sc.call('cancel',handle))
    o.join=cb(S.JOIN,join)
    if not ops_parameters.get('nolog'):o.log=cb(S.LOG,lambda _,line:sc.call('log',line))
    # All unused function pointers remain NULL; accidental self/lock is not a stub.
    return o,sc,errors,callbacks

class Native:
    def __init__(self,lib):
        self.f=lib.vn135_backend_stop_mining_135
        self.f.argtypes=[C.POINTER(State),C.POINTER(S.Ops),S.P];self.f.restype=None
    def run(self,p):
        view=View(p);ops,sc,errors,keep=bind_native(view,p)
        for i in range(p.get('repeat',1)):
            self.f(C.byref(view.s),C.byref(ops),None)
            sc.events.append(('returned',i,view.snap()))
        if errors:raise errors[0]
        view.guard()
        return view.snap(),sc.events

class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert START<=pc<END,('unapproved instruction',hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w,pc)

def seed(m,p):
    for k,(off,n) in FIELDS.items():m.write(BASE+off,p.get(k,DEFAULTS[k]),n)
    m.write(OPAQUE_X,p.get('opaque',0));m.write(OPAQUE_Y,p.get('opaque_y',10))
def snapshot(m):return tuple(m.read(BASE+off,n) for off,n in FIELDS.values())
def bind_original(m,p,extra_snap=lambda:(),extra_mutate=None):
    def mutate(k,v):
        if k in FIELDS:
            off,n=FIELDS[k];m.write(BASE+off,v,n)
        else:
            assert extra_mutate is not None,k
            extra_mutate(k,v)
    sc=Script(p,lambda:(snapshot(m),extra_snap()),mutate)
    def hook(name,argc,backend=False):
        def h(_):
            if backend:assert m.r[0]==BASE
            args=(0,) if backend or name=='0xfe218' else tuple(m.r[:argc])
            if name=='join':assert args[1]==0;args=(args[0],False)
            if name=='log':
                assert tuple(m.r[:4])==(0x5e51e0,0x5e50be,0x5e50e3,4825)
                assert m.read(m.r[13])==3 and m.read(m.r[13]+4)==0x5e5537
                args=(4825,)
                if p.get('nolog'):return
            m.r[0]=sc.call(name,*args)&MASK
            # Test varied opaque words without rewriting any original instruction.
            m.write(OPAQUE_X,(p.get('opaque',0)+sc.calls[name]*0x80000001)&MASK)
            m.write(OPAQUE_Y,p.get('opaque_y',10)^MASK)
        return h
    return sc,{0xfe218:hook('0xfe218',0),0xb8e54:hook('0xb8e54',0,True),
               0x10ed2c:hook('delay',1),0x5a4754:hook('cancel',1),
               0x5a5d2c:hook('join',2),0x65b3c:hook('0x65b3c',0,True),0xfa0c4:hook('log',0)}

class Original:
    def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,p):
        m=self.m;m.visited=set();m.mem[BASE:BASE+0x1100]=b'\xa5'*0x1100;seed(m,p)
        before=bytes(m.mem[BASE:BASE+0x1100]);sc,hooks=bind_original(m,p)
        for i in range(p.get('repeat',1)):
            m.reset((BASE,));m.run(START,hooks=hooks,max_steps=150)
            assert m.r[13]==m.STACK_TOP
            self.steps+=m.steps;sc.events.append(('returned',i,snapshot(m)))
        self.visited|=m.visited
        after=bytearray(m.mem[BASE:BASE+0x1100])
        for off,n in FIELDS.values():after[off:off+n]=before[off:off+n]
        assert after==before,'unexpected ARM backend write'
        return snapshot(m),sc.events

def cases(quick=False):
    yield 'active',{}
    yield 'inactive_but_still_cleanup',{'tuning':0,'byte_104a':255}
    yield 'no_early_flag_clear',{'mutations':[('cancel',0,'handle',0x80000000)]}
    yield 'cancel_failure_still_joins',{'returns':{'cancel':-3}}
    yield 'delay_can_finish_worker',{'mutations':[('delay',0,'tuning',0)]}
    yield 'cleanup_after_join_can_restore_flag',{'mutations':[('0x65b3c',0,'tuning',17)]}
    yield 'join_clears_two_bytes',{'mutations':[('join',0,'byte_104a',255)]}
    yield 'final_log_after_reset',{'started_bits':0x7ff0000000000001,'repeat':2}
    if quick:return
    for flag,joinable in itertools.product(range(256),(0,1,255)):
        yield 'flag_bytes',{'tuning':flag,'byte_104a':joinable,'repeat':2}
    for name,field,value in itertools.product(('0xfe218','0xb8e54','delay','cancel','join','0x65b3c','log'),
                                             FIELDS,(0,1,255,0xffffffff)):
        yield 'mutation_order',{'mutations':[(name,0,field,value)],'repeat':2}
    for op,rc in itertools.product(('0xfe218','0xb8e54','delay','cancel','join','0x65b3c'),(-2147483648,-3,0,3,2147483647)):
        yield 'ignored_errors',{'returns':{op:rc}}
    for bits in (0,0x8000000000000000,1,0x7ff0000000000000,0xfff0000000000000,0x7ff0000000000001,0x7ff8000000001234,0xffffffffffffffff):
        yield 'raw_timestamp_bits',{'started_bits':bits,'nolog':True}
    for x,y in itertools.product((0,1,2,0x7fffffff,0x80000000,0xffffffff),(0,9,10,0x7fffffff,0x80000000,0xffffffff)):
        yield 'opaque_words',{'opaque':x,'opaque_y':y}
    rng=random.Random(66333)
    for _ in range(250):
        p={k:rng.getrandbits(n*8) for k,(_,n) in FIELDS.items()}
        p.update(repeat=3,opaque=rng.getrandbits(32),opaque_y=rng.getrandbits(32),
                 mutations=[('delay',0,'tuning',rng.randrange(2)),('cancel',0,'handle',rng.getrandbits(32))])
        yield 'seeded',p

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=R.ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
    native=Native(C.CDLL(str(Path(a.library).resolve())));original=Original(elf);counts=collections.Counter();events=0
    for name,p in cases(a.quick):
        want=original.run(p);got=native.run(p)
        if want!=got:raise AssertionError(('ORIGINAL_MISMATCH',name,p,want,got))
        counts[name]+=1;events+=sum(e[0]!='returned' for e in want[1])
    summary=dict(cases=sum(counts.values()),categories=dict(counts),events=events,arm_steps=original.steps,
        visited_instruction_addresses=len(original.visited),reference_sha256=HASH,new_arm_opcodes=0,
        real_threads=False,hardware_io=False,lower_bodies='fe218 b8e54 65b3c explicit callbacks')
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('MINING_STOP135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
