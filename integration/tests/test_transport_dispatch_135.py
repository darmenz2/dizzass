#!/usr/bin/env python3
"""Original d26ac -> AML -> UART, optionally inside BM1368 register/cache.
Only allocation, memcpy, mutexes, errno, OS write, delay and diagnostics are
hooked. No real I/O. Prior source/oracles/interpreter are not modified.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import random
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import MASK,signed
import test_bm1368_register_write_135 as R

I,U,P,Z=C.c_int32,C.c_uint32,C.c_void_p,C.c_size_t
SEND=C.CFUNCTYPE(I,P,P,P,U)
ALLOC=C.CFUNCTYPE(P,P,Z)
FREE=C.CFUNCTYPE(None,P,P)
VOID=C.CFUNCTYPE(None,P)
WRITE=C.CFUNCTYPE(I,P,I,P,U)
ERR=C.CFUNCTYPE(P,P)
SLEEP=C.CFUNCTYPE(None,P,U)
class Dispatch(C.Structure):_fields_=[('send',SEND),('context',P)]
class Uart(C.Structure):_fields_=[('path',P),('fd',I),('baud',U),('ready',C.c_bool)]
class UartOps(C.Structure):
    _fields_=[(name,P) for name in ('context','open','duplicate','release','ioctl',
        'read','write','error_number','close','flush','mutex_init','lock','unlock',
        'mutex_destroy','sleep_ms')]
class Frame(C.Structure):
    _fields_=[(name,P) for name in ('context','allocate','release','lock','unlock','write')]
class Binding(C.Structure):
    _fields_=[('identity',P),('uart',C.POINTER(Uart)),('frame',C.POINTER(Frame)),
              ('ops',C.POINTER(UartOps))]
TABLE=0x68bf68
BUF,HEAP,ERRPTR=0x84f000,0x84e000,0x84d000
RANGES=R.RANGES+((0xd26ac,0xd2750),(0x117f7c,0x118148),
                 (0x10e6c0,0x10e938),(0xd21dc,0xd22dc))
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class Machine(ARM32Difficulty):
    def reset(self,args=()):
        super().reset(args);self.visited=set();self.observer=None
    def extra_instruction(self,word,pc):
        assert any(a<=pc<b for a,b in RANGES),('unreviewed instruction',hex(pc))
        self.visited.add(pc)
        if self.observer:self.observer(pc)
        return super().extra_instruction(word,pc)

def opaque(m,value):
    for lit,pc in ((0xd2750,0xd26c4),(0xd2754,0xd26d8),
                   (0x118148,0x117f9c),(0x11814c,0x117fb0)):
        m.write(m.read((pc+8+m.read(lit))&MASK),value)

def configure(lib):
    f=lib.vn135_transport_send_135
    f.argtypes=[C.POINTER(Dispatch),P,P,U];f.restype=I
    a=lib.vn135_aml_uart_send_135
    a.argtypes=[P,P,P,U];a.restype=I
    reg=lib.vn135_bm1368_write_register_135
    reg.argtypes=[C.POINTER(R.Device),U,C.POINTER(R.Chip),U,U,C.POINTER(R.Ops),P]
    reg.restype=I
    for name,args in [('chain',[P,I,U,U]),('chip',[P,I,I,U,U])]:
        fn=getattr(lib,'vn135_bm1368_register_cache_'+name+'_135')
        fn.argtypes=args;fn.restype=I

def direct(elf,lib):
    """No wrapper normalization, dereference, copy, retry or implicit AML."""
    rng=random.Random(0xd26ac);total=events=0
    values=[0,1,-1,-2,11,-2147483648,2147483647]+[signed(rng.getrandbits(32)) for _ in range(32)]
    m=Machine(elf)
    for result,length,nulls,reenter in itertools.product(values,[0,9,0xffffffff],range(4),[False,True]):
        dev=0 if nulls&1 else R.DEVICE;buf=0 if nulls&2 else BUF
        old=[];new=[];seed=rng.getrandbits(32)
        opaque(m,seed);m.write(TABLE+24,0x850f00)
        def hook_b(mm):
            old.append((1,mm.r[0],mm.r[1],mm.r[2]));mm.r[0]=0x87654321
        def hook_a(mm):
            old.append((0,mm.r[0],mm.r[1],mm.r[2]));m.write(TABLE+24,0x850f04)
            opaque(m,~seed&MASK)
            if reenter:
                saved=m.r[:];flags=(m.n,m.z,m.c,m.v);m.r[13]-=0x100;m.r[14]=m.RETURN
                assert signed(m.run(0xd26ac,hooks={0x850f04:hook_b},max_steps=2000))==signed(0x87654321)
                m.r=saved;m.n,m.z,m.c,m.v=flags
            mm.r[0]=result&MASK
        m.reset((dev,buf,length))
        rc=signed(m.run(0xd26ac,hooks={0x850f00:hook_a,0x850f04:hook_b},max_steps=3000))
        assert rc==result and m.r[13]==m.STACK_TOP, 'invalid original dispatch return'
        m.reset((dev,buf,length));rc2=signed(m.run(0xd26ac,hooks={0x850f04:hook_b},max_steps=1000))
        table=Dispatch();failures=[]
        @SEND
        def b(ctx,d,p,n):
            new.append((1,d or 0,p or 0,n));return signed(0x87654321)
        @SEND
        def a(ctx,d,p,n):
            new.append((0,d or 0,p or 0,n));table.send=b
            if reenter:
                got=lib.vn135_transport_send_135(C.byref(table),d,p,n)
                if got!=signed(0x87654321):failures.append(got)
            return result
        table.send=a;table.context=None
        got=lib.vn135_transport_send_135(C.byref(table),dev,buf,length)
        got2=lib.vn135_transport_send_135(C.byref(table),dev,buf,length)
        assert not failures and (got,got2,new)==(rc,rc2,old),('SEMANTIC_MISMATCH',result,length,nulls,reenter)
        total+=1;events+=len(old)
    return {'cases':total,'events':events}

def provenance(elf):
    expected={0:(0x10fa38,0x10f938),1:(0x11d0cc,)*2,2:(0x117f7c,)*2,
              3:(0xf8048,)*2,4:(0x109740,)*2}
    m=Machine(elf);cases=0
    for platform,subtype in itertools.product(range(5),[0,1,0xffffffff]):
        m.write(TABLE+24,0xa5a5a5a5);m.reset((platform,4,subtype,BUF))
        m.run(0xd21dc,stop=0xd22dc,max_steps=300)
        assert m.read(TABLE+24)==expected[platform][bool(subtype)]
        cases+=1
    # Only the platform-method installation slice is accepted, not init/I/O.
    return {'cases':cases,'aml_platform':2,'aml_entry':'0x117f7c',
            'table':'0x68bf68','method_offset':'0x18','stop':'0xd22dc'}

def outcomes(name,n):
    return {'exact':[(n,None)],'eagain':[(-1,11),(n,None)],
        'last_success':[(-1,11)]*4+[(n,None)],'exhausted':[(-1,11)]*5,
        'short_stale':[(1,None),(n,None)],'zero':[(0,11)]*5,
        'short':[(1,5)],'hard':[(-1,5)],'eintr':[(-1,4)],
        'overreport':[(n+1,0)],'change_errno':[(-1,11),(-1,9)]}[name]

class Trace:
    def __init__(self,p,mutate):self.p=p;self.mutate=mutate;self.events=[];self.counts=collections.Counter()
    def event(self,name,*args):
        at=self.counts[name];self.counts[name]+=1;self.events.append((name,*args))
        for event,occurrence,key,value in self.p.get('mutations',[]):
            if (event,occurrence)==(name,at):self.mutate(key,value)

class Original:
    def __init__(self,elf):self.elf=elf;self.m=Machine(elf);self.steps=0;self.excluded=collections.Counter()
    def run(self,p,payload,register):
        m=self.m;m.reset();v=R.ArmView(m,self.elf,p)
        opaque(m,p.get('opaque',MASK));m.write(TABLE+24,0x117f7c)
        m.write(R.DEVICE+28,0);m.write(R.DEVICE+32,p.get('fd',17));m.write(ERRPTR,p.get('errno',11))
        m.mem[BUF:BUF+len(payload)]=payload
        outer=0x1180c8+8+m.read(0x11817c);assert outer!=R.DEVICE
        live=False;write_index=0
        def mutate(k,x):
            if k=='fd':m.write(R.DEVICE+32,x)
            elif k=='errno':m.write(ERRPTR,x)
            else:v.mutate(k,x)
        t=Trace(p,mutate)
        def alloc(mm):
            nonlocal live
            n=mm.r[0];t.event('allocate',n);assert 2<=n<=1026
            live=not p.get('no_memory',False);mm.r[0]=HEAP if live else 0
        def copy(mm):
            dst,src,n=mm.r[:3];assert live and dst==HEAP+2
            m.mem[dst:dst+n]=m.mem[src:src+n];mm.r[0]=dst
        def lock(mm):
            assert mm.r[0] in (R.DEVICE,outer);t.event('inner_lock' if mm.r[0]==R.DEVICE else 'outer_lock');mm.r[0]=MASK
        def unlock(mm):
            assert mm.r[0] in (R.DEVICE,outer);t.event('inner_unlock' if mm.r[0]==R.DEVICE else 'outer_unlock');mm.r[0]=MASK
        def write(mm):
            nonlocal write_index
            fd,buf,n=mm.r[:3];assert live and buf==HEAP
            t.event('write',signed(fd),bytes(m.mem[buf:buf+n]).hex())
            seq=outcomes(p['io'],n);rc,err=seq[min(write_index,len(seq)-1)];write_index+=1
            if err is not None:m.write(ERRPTR,err)
            mm.r[0]=rc&MASK
        def error(mm):t.event('errno_pointer');mm.r[0]=ERRPTR
        def sleep(mm):t.event('sleep',mm.r[0]);mm.r[0]=0
        def release(mm):
            nonlocal live
            assert live and mm.r[0]==HEAP;t.event('release');live=False;mm.r[0]=0
        def log(mm):
            if register and mm.r[3]==350:t.event('register_log',350,mm.read(mm.r[13]+8))
            else:self.excluded[mm.r[3]]+=1
            mm.r[0]=0
        def observe(pc):
            if pc==0x107648:t.event('cache_chain',signed(m.r[0]),m.r[1],m.r[2])
            elif pc==0x107ed0:t.event('cache_chip',signed(m.r[0]),signed(m.r[1]),m.r[2],m.r[3])
        m.observer=observe
        hooks={0x5940ec:alloc,0x5a2ee8:copy,0x5a6108:lock,0x5a66c4:unlock,
               0x5a8684:write,0x5931e4:error,0x10ef3c:sleep,0x593c8c:release,0xfa0c4:log}
        if register:
            m.r[:4]=[R.DEVICE,p.get('mode',1),0 if p.get('null_chip') else R.CHIP,p.get('reg',8)]
            m.write(m.STACK_TOP,p.get('value',0x12345678));entry=0xe4a74
        else:
            m.r[:3]=[0 if p.get('no_device') else R.DEVICE,BUF,len(payload)];entry=0xd26ac
        rc=signed(m.run(entry,hooks=hooks,max_steps=150000))
        assert not live and m.r[13]==m.STACK_TOP
        assert 0xd26ac in m.visited and 0x117f7c in m.visited
        if t.counts['write']:assert 0x10e6c0 in m.visited
        self.steps+=m.steps
        return rc,t.events,v.snapshot(register),signed(m.read(R.DEVICE+32))

class Native:
    def __init__(self,lib,elf):self.lib=lib;self.elf=elf
    def run(self,p,payload,register):
        lib=self.lib;v=R.NativeView(self.elf,p);u=Uart(None,p.get('fd',17),115200,True)
        error=I(p.get('errno',11));storage=C.create_string_buffer(1026);source=C.create_string_buffer(payload)
        live=False;write_index=0;keep=[];errors=[]
        def mutate(k,x):
            if k=='fd':u.fd=x
            elif k=='errno':error.value=x
            else:v.mutate(k,x)
        t=Trace(p,mutate)
        def cb(ty,fn):
            def call(*args):
                try:return fn(*args)
                except BaseException as e:
                    errors.append(e);return None if ty in (ALLOC,FREE,VOID,R.LOG) else -999
            c=ty(call);keep.append(c);return c
        def alloc(_,n):
            nonlocal live
            t.event('allocate',n);assert 2<=n<=1026
            live=not p.get('no_memory',False);return C.addressof(storage) if live else None
        def release(_,ptr):
            nonlocal live
            assert live and ptr==C.addressof(storage);t.event('release');live=False
        def write(_,fd,buf,n):
            nonlocal write_index
            assert live and buf==C.addressof(storage)
            t.event('write',fd,C.string_at(buf,n).hex())
            seq=outcomes(p['io'],n);rc,err=seq[min(write_index,len(seq)-1)];write_index+=1
            if err is not None:error.value=err
            return rc
        def err(_):t.event('errno_pointer');return C.addressof(error)
        f=Frame();o=UartOps()
        for field,ty,fn in [('allocate',ALLOC,alloc),('release',FREE,release),
            ('lock',VOID,lambda _:t.event('outer_lock')),('unlock',VOID,lambda _:t.event('outer_unlock'))]:
            setattr(f,field,C.cast(cb(ty,fn),P))
        for field,ty,fn in [('write',WRITE,write),('error_number',ERR,err),
            ('lock',VOID,lambda _:t.event('inner_lock')),('unlock',VOID,lambda _:t.event('inner_unlock')),
            ('sleep_ms',SLEEP,lambda _,n:t.event('sleep',n))]:
            setattr(o,field,C.cast(cb(ty,fn),P))
        identity=C.addressof(v.device);b=Binding(identity,C.pointer(u),C.pointer(f),C.pointer(o))
        table=Dispatch(C.cast(lib.vn135_aml_uart_send_135,SEND),C.cast(C.pointer(b),P))
        def send(_,device,buf,n):
            assert C.addressof(device.contents)==identity and n==9
            return lib.vn135_transport_send_135(C.byref(table),identity,buf,n)
        def chain(_,i,reg,value):
            t.event('cache_chain',i,reg,value)
            return lib.vn135_bm1368_register_cache_chain_135(C.byref(v.cache),i,reg,value)
        def chip(_,i,j,reg,value):
            t.event('cache_chip',i,j,reg,value)
            return lib.vn135_bm1368_register_cache_chip_135(C.byref(v.cache),i,j,reg,value)
        ro=R.Ops(cb(R.SEND,send),cb(R.CHAIN,chain),cb(R.ONE,chip),
                 cb(R.LOG,lambda _,line,index:t.event('register_log',line,index)))
        if register:
            rc=lib.vn135_bm1368_write_register_135(C.byref(v.device),p.get('mode',1),
                None if p.get('null_chip') else C.byref(v.chip),p.get('reg',8),p.get('value',0x12345678),C.byref(ro),None)
        else:
            rc=lib.vn135_transport_send_135(C.byref(table),None if p.get('no_device') else identity,source,len(payload))
        if errors:raise errors[0]
        assert not live
        return rc,t.events,v.snapshot(register),u.fd

def pipeline_cases():
    rng=random.Random(0x117f7c)
    names=['exact','eagain','last_success','exhausted','short_stale','zero','short','hard','eintr','overreport','change_errno']
    for io,n in itertools.product(names,[0,1,7,9,64,256,1024]):
        yield False,{'io':io},rng.randbytes(n)
    for field in ['no_device','no_memory']:
        yield False,{'io':'exact',field:True},b'abcdefghi'
    for mode,reg,io,null in itertools.product([0,1,2,MASK],[8,0x108],names,[False,True]):
        yield True,{'io':io,'mode':mode,'reg':reg,'null_chip':null},b''
    mutations=[('inner_lock',0,'fd',29),('write',0,'fd',-4),('sleep',0,'errno',4),
               ('write',0,'device',0),('write',0,'index',0),('outer_unlock',0,'ready',0),
               ('release',0,'device',MASK),('write',0,'address',0xfed)]
    for mutation,mode in itertools.product(mutations,[0,1,2]):
        yield True,{'io':'eagain','mode':mode,'mutations':[mutation]},b''
    yield True,{'io':'exact','no_memory':True},b''

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary',type=Path)
    a=ap.parse_args();elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==SHA
    lib=C.CDLL(str(Path(a.library).resolve()));configure(lib)
    result={'dispatch':direct(elf,lib),'provenance':provenance(elf)}
    old,new=Original(elf),Native(lib,elf);counts=collections.Counter();events=collections.Counter()
    for index,(nested,p,payload) in enumerate(pipeline_cases()):
        left=old.run(p,payload,nested);right=new.run(p,payload,nested)
        assert left==right,('SEMANTIC_MISMATCH',index,nested,p,left[:2],right[:2],left[2:]==right[2:])
        name='register_transport_cache' if nested else 'dispatch_aml_uart'
        counts[name]+=1;events[name]+=len(left[1])
    result.update(passed=True,composition_cases=dict(counts),composition_events=dict(events),
                  original_steps=old.steps,excluded_internal_diagnostics=dict(old.excluded),
                  original_reference_sha256=SHA,hardware_io=False,live_threads=False,
                  scope='Finite original-instruction comparisons with scripted OS boundaries; lower diagnostic hooks excluded.')
    if a.summary:a.summary.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
if __name__=='__main__':main()
