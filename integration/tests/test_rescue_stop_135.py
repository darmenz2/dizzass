#!/usr/bin/env python3
"""Unchanged ARM stop entry versus reused C helper; no real thread operations."""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import random
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_subset import ARM32, MASK
import test_backend_shutdown_135 as S

START, END = 0x287a4, 0x28890
FLAG, HANDLE, OPAQUE_X, OPAQUE_Y = 0x68b108, 0x68b118, 0x68b114, 0x68b11c
HASH = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class Worker(C.Structure):
    _fields_ = [('handle', C.c_uint32), ('running', C.c_uint8)]
class Machine(ARM32):
    def extra_instruction(self, w, pc):
        assert START <= pc < END, ('unapproved instruction', hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w, pc)

def select(p, name, n, default=0):
    v = p.get('returns', {}).get(name, default)
    return v[min(n,len(v)-1)] if isinstance(v,list) else v

class Script:
    def __init__(self, p, snap, mutate):
        self.p,self.snap,self.mutate = p,snap,mutate
        self.events,self.calls = [],collections.Counter()
    def call(self, name, *args):
        n=self.calls[name];self.calls[name]+=1
        self.events.append((name,*args,self.snap()))
        for op,nth,field,value in self.p.get('mutations',[]):
            if name==op and n==nth:self.mutate(field,value)
        return select(self.p,name,n,self.p.get('self',999) if name=='self' else 0)

class Native:
    def __init__(self, library):
        self.f=library.vn135_rescue_service_stop_135
        self.f.argtypes=[C.POINTER(Worker),C.POINTER(S.Ops),S.P];self.f.restype=None
    def run(self,p):
        class Guarded(C.Structure):
            _fields_=[('left',C.c_uint64),('worker',Worker),('right',C.c_uint64)]
        g=Guarded(0xdeadbeef01234567,Worker(p.get('handle',100),p.get('flag',1)),0x123456789abcdef0)
        def snap():return (g.worker.running,g.worker.handle)
        def mutate(k,v):
            if k=='flag':g.worker.running=v
            elif k=='handle':g.worker.handle=v
            else:raise AssertionError(k)
        sc=Script(p,snap,mutate);callbacks=[];errors=[]
        def cb(ty,name):
            def call(_, *args):
                try:
                    if name=='join':args=(args[0],bool(args[1]))
                    return sc.call(name,*args)
                except BaseException as e:errors.append(e);return 0
            f=ty(call);callbacks.append(f);return f
        ops=S.Ops();ops.self=cb(S.SELF,'self');ops.detach=cb(S.HANDLE,'detach')
        ops.cancel=cb(S.HANDLE,'cancel');ops.join=cb(S.JOIN,'join')
        for i in range(p.get('repeat',1)):
            self.f(C.byref(g.worker),C.byref(ops),None)
            sc.events.append(('returned',i,snap()))
        if errors:raise errors[0]
        assert g.left==0xdeadbeef01234567 and g.right==0x123456789abcdef0
        return snap(),sc.events

class Original:
    def __init__(self,elf):
        self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,p):
        m=self.m;m.visited=set();m.mem[FLAG-8:HANDLE+16]=b'\xa5'*40
        m.write(FLAG,p.get('flag',1),1);m.write(HANDLE,p.get('handle',100))
        m.write(OPAQUE_X,p.get('opaque',0));m.write(OPAQUE_Y,p.get('opaque_y',10))
        untouched=bytes(m.mem[FLAG-8:HANDLE+16])
        def snap():return m.read(FLAG,1),m.read(HANDLE)
        def mutate(k,v):
            if k=='flag':m.write(FLAG,v,1)
            elif k=='handle':m.write(HANDLE,v)
            else:raise AssertionError(k)
        sc=Script(p,snap,mutate)
        def hook(name,argc):
            def h(_):
                args=tuple(m.r[:argc])
                if name=='join':args=(args[0],bool(args[1]));assert not m.r[1]
                m.r[0]=sc.call(name,*args)&MASK
                # Vary both source opaque words at every effect boundary.
                m.write(OPAQUE_X, (p.get('opaque',0)+sc.calls[name]*0x80000001)&MASK)
                m.write(OPAQUE_Y, (p.get('opaque_y',10)^0xffffffff)&MASK)
            return h
        hooks={0x5a6b20:hook('self',0),0x5a5bb0:hook('detach',1),
               0x5a4754:hook('cancel',1),0x5a5d2c:hook('join',2)}
        for i in range(p.get('repeat',1)):
            m.reset();m.run(START,hooks=hooks,max_steps=200)
            assert m.r[13]==m.STACK_TOP
            self.steps+=m.steps;sc.events.append(('returned',i,snap()))
        self.visited|=m.visited
        for i,v in enumerate(untouched):
            a=FLAG-8+i
            if a==FLAG or HANDLE<=a<HANDLE+4 or OPAQUE_X<=a<OPAQUE_X+4 or OPAQUE_Y<=a<OPAQUE_Y+4:continue
            assert m.read(a,1)==v,hex(a)
        return snap(),sc.events

def cases(quick=False):
    yield 'inactive',{'flag':0}
    yield 'cancel_join',{}
    yield 'self_detach',{'self':100}
    yield 'clear_before_self',{'self':100,'mutations':[('self',0,'handle',200)]}
    yield 'reread_after_self',{'self':999,'mutations':[('self',0,'handle',999)]}
    yield 'reread_after_cancel',{'mutations':[('cancel',0,'handle',321)]}
    yield 'ignore_cancel_failure',{'returns':{'cancel':-3}}
    if quick:return
    for flag in range(256):
        for handle in (0,100,0xffffffff):
            yield 'flag_byte',{'flag':flag,'handle':handle,'self':100,'repeat':2,'opaque':flag*0x1010101}
    for handle,self_,rc in itertools.product((0,1,0x80000000,0xffffffff),(0,1,0x80000000,0xffffffff),(0,-1,3,-2147483648)):
        yield 'handle_and_error',{'handle':handle,'self':self_,'returns':{'detach':rc,'cancel':rc,'join':rc}}
    for op,field,v in itertools.product(('self','cancel','detach','join'),('handle','flag'),(0,1,7,0xff)):
        yield 'callback_mutation',{'self':100 if op=='detach' else 999,'repeat':2,'mutations':[(op,0,field,v)]}
    for value in (0,1,2,9,10,0x7fffffff,0x80000000,0xfffffffe,0xffffffff):
        for self_ in (100,999):
            yield 'opaque_boundary',{'self':self_,'opaque':value,'opaque_y':value}
    rng=random.Random(28704)
    for _ in range(256):
        yield 'seeded',{'flag':rng.randrange(256),'handle':rng.getrandbits(32),'self':rng.getrandbits(32),
              'opaque':rng.getrandbits(32),'opaque_y':rng.getrandbits(32),
              'mutations':[('self',0,'handle',rng.getrandbits(32)),('cancel',0,'handle',rng.getrandbits(32)),
                           ('join',0,'flag',rng.randrange(256))], 'repeat':3}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
    native=Native(C.CDLL(str(Path(a.library).resolve())));original=Original(elf);counts=collections.Counter();events=0
    for name,p in cases(a.quick):
        want=original.run(p);got=native.run(p)
        if want!=got:raise AssertionError(('ORIGINAL_MISMATCH',name,p,want,got))
        counts[name]+=1;events+=sum(e[0]!='returned' for e in want[1])
    summary={'cases':sum(counts.values()),'categories':dict(counts),'events':events,'arm_steps':original.steps,
             'visited_instruction_addresses':len(original.visited),'reference_sha256':HASH,
             'native_reuses_existing_thread_helper':True,'new_arm_opcodes':0,'real_threads':False}
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('RESCUE_STOP135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
