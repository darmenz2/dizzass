#!/usr/bin/env python3
"""e34cc and nested register/CRC/cache/AML/UART versus compiled C.
Original instruction bytes and prior interpreter/tests remain unchanged.
Only system effects and omitted internal legacy diagnostics are hooked.
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
import test_transport_dispatch_135 as T
import test_bm1368_register_write_135 as R
I,U,P=C.c_int32,C.c_uint32,C.c_void_p
START,END=0xe34cc,0xe35a0
WRITE=C.CFUNCTYPE(I,P,C.POINTER(R.Device),U,C.POINTER(R.Chip),U,U)
class Ops(C.Structure):_fields_=[('write',WRITE),('log',R.LOG)]
class Binding(C.Structure):_fields_=[('ops',C.POINTER(R.Ops)),('context',P)]
class Machine(T.Machine):
    def extra_instruction(self,w,pc):
        if START<=pc<END:
            self.visited.add(pc)
            return ARM32Difficulty.extra_instruction(self,w,pc)
        return super().extra_instruction(w,pc)

def configure(lib):
    T.configure(lib)
    lib.vn135_bm1368_set_pulse_width_135.argtypes=[C.POINTER(R.Device),U,U,U,C.POINTER(Ops),P]
    lib.vn135_bm1368_set_pulse_width_135.restype=I
    lib.vn135_bm1368_pulse_register_135.argtypes=[P,C.POINTER(R.Device),U,C.POINTER(R.Chip),U,U]
    lib.vn135_bm1368_pulse_register_135.restype=I

def inputs(p):return [p.get('width',1)&MASK,p.get('delay',2)&MASK,p.get('fourth',1)&MASK]
def validate_log(m):
    assert m.r[:3]==[0x5eb3e0,0x5eb3e7,0x5eb411]
    assert m.r[3] in (387,569) and m.read(m.r[13])==1
    assert m.read(m.r[13]+4)=={387:0x5eb8b0,569:0x5eb4ba}[m.r[3]]

class Direct:
    def __init__(self,elf,lib):self.m=Machine(elf);self.lib=lib;self.steps=0;self.visited=set()
    def run(self,p,native):
        m=self.m;device=R.Device(p.get('index',2)&MASK);events=[];counts=collections.Counter();errors=[]
        if not native:
            m.mem[R.DEVICE:R.DEVICE+64]=b'\xa5'*64;m.write(R.DEVICE+24,device.index)
        def index():return device.index if native else m.read(R.DEVICE+24)
        def event(name,*args):
            n=counts[name];counts[name]+=1;events.append((name,*args,index()))
            for at,num,val in p.get('mutations',[]):
                if (at,num)==(name,n):
                    if native:device.index=val&MASK
                    else:m.write(R.DEVICE+24,val)
        if native:
            @WRITE
            def write(_,dev,mode,chip,reg,value):
                try:
                    assert C.addressof(dev.contents)==C.addressof(device) and not chip
                    event('register',mode,False,reg,value)
                    return p.get('result',0)
                except BaseException as e:errors.append(e);return -999
            @R.LOG
            def log(_,line,i):event('log',line,i)
            o=Ops(write,R.LOG() if p.get('nolog') else log)
            ret=[self.lib.vn135_bm1368_set_pulse_width_135(C.byref(device),*inputs(p),C.byref(o),None)
                 for _ in range(p.get('repeat',1))]
            assert not errors,errors
        else:
            def write(mm):
                assert mm.r[0]==R.DEVICE and mm.r[2]==0
                event('register',mm.r[1],False,mm.r[3],mm.read(mm.r[13]))
                mm.r[0]=p.get('result',0)&MASK
            def log(mm):
                validate_log(mm)
                if not p.get('nolog'):event('log',mm.r[3],mm.read(mm.r[13]+8))
                mm.r[0]=0xabcdef
            ret=[]
            for _ in range(p.get('repeat',1)):
                m.reset((R.DEVICE,*inputs(p)))
                ret.append(signed(m.run(START,hooks={0xe4a74:write,0xfa0c4:log},max_steps=1000)))
                assert m.r[13]==m.STACK_TOP
                self.steps+=m.steps;self.visited|=m.visited
            guard=bytearray(m.mem[R.DEVICE:R.DEVICE+64]);guard[24:28]=b'\xa5'*4
            assert guard==b'\xa5'*64,'unexpected original device write'
        return ret,index(),events

def direct_cases(quick=False):
    yield {'width':1,'delay':2,'fourth':0xffffffff}
    yield {'width':4,'delay':8}
    yield {'width':0xffffffff,'delay':0xffffffff}
    yield {'width':1,'delay':2,'result':11,'mutations':[('register',0,17),('log',0,0xffffffff)]}
    yield {'result':-1,'nolog':True}
    yield {'result':-2147483648,'repeat':2,'mutations':[('log',0,15),('register',1,23)]}
    if quick:return
    for width,delay,rc,extra in itertools.product(range(4),range(8),[0,1,-1,11,-2,-2147483648,2147483647],[0,1,0xffffffff]):
        yield {'width':width,'delay':delay,'result':rc,'fourth':extra}
    for n,rc in itertools.product(range(256),[0,1,-1]):
        yield {'width':n,'delay':2,'result':rc};yield {'width':1,'delay':n,'result':rc}
    for bit in range(32):
        yield {'width':1<<bit,'delay':MASK^(1<<bit),'fourth':1<<bit}
    rng=random.Random(0xe34cc)
    for _ in range(256):
        yield {'width':rng.getrandbits(32),'delay':rng.getrandbits(32),'fourth':rng.getrandbits(32),
               'result':signed(rng.getrandbits(32)),'index':rng.getrandbits(32),'repeat':2,
               'mutations':[('register',0,rng.getrandbits(32)),('log',0,rng.getrandbits(32))]}

class Trace(T.Trace):
    def __init__(self,p,mutate,snapshot):super().__init__(p,mutate);self.snapshot=snapshot
    def event(self,name,*args):super().event(name,*args,self.snapshot())

def brief(v,fd):
    fields=v.snapshot(True)
    return fields[:-1]+(hashlib.sha256(fields[-1]).hexdigest(),fd)

class PipelineOriginal:
    def __init__(self,elf):self.elf=elf;self.m=Machine(elf);self.steps=0;self.excluded=collections.Counter();self.visited=set()
    def run(self,p):
        m=self.m;m.reset();v=R.ArmView(m,self.elf,p)
        T.opaque(m,p.get('opaque',MASK));m.write(T.TABLE+24,0x117f7c)
        m.write(R.DEVICE+28,0);m.write(R.DEVICE+32,p.get('fd',17));m.write(T.ERRPTR,p.get('errno',11))
        outer=0x1180c8+8+m.read(0x11817c);live=False;wi=0
        def mutate(k,x):
            if k=='fd':m.write(R.DEVICE+32,x)
            elif k=='errno':m.write(T.ERRPTR,x)
            else:v.mutate(k,x)
        t=Trace(p,mutate,lambda:brief(v,signed(m.read(R.DEVICE+32))))
        def alloc(mm):
            nonlocal live
            assert mm.r[0]==11;t.event('allocate',11);live=not p.get('no_memory',False);mm.r[0]=T.HEAP if live else 0
        def copy(mm):
            dst,src,n=mm.r[:3];assert live and dst==T.HEAP+2 and n==9
            m.mem[dst:dst+n]=m.mem[src:src+n];mm.r[0]=dst
        def lock(mm):
            assert mm.r[0] in (R.DEVICE,outer);t.event('inner_lock' if mm.r[0]==R.DEVICE else 'outer_lock');mm.r[0]=MASK
        def unlock(mm):
            assert mm.r[0] in (R.DEVICE,outer);t.event('inner_unlock' if mm.r[0]==R.DEVICE else 'outer_unlock');mm.r[0]=MASK
        def write(mm):
            nonlocal wi
            fd,buf,n=mm.r[:3];assert live and buf==T.HEAP and n==11
            t.event('write',signed(fd),bytes(m.mem[buf:buf+n]).hex())
            seq=T.outcomes(p.get('io','exact'),n);rc,err=seq[min(wi,len(seq)-1)];wi+=1
            if err is not None:m.write(T.ERRPTR,err)
            mm.r[0]=rc&MASK
        def error(mm):t.event('errno_pointer');mm.r[0]=T.ERRPTR
        def sleep(mm):t.event('sleep',mm.r[0]);mm.r[0]=0
        def release(mm):
            nonlocal live
            assert live and mm.r[0]==T.HEAP;t.event('release');live=False;mm.r[0]=0
        def log(mm):
            line=mm.r[3]
            if line in (387,569):validate_log(mm);t.event('pulse_log',line,mm.read(mm.r[13]+8))
            elif line==350:t.event('register_log',line,mm.read(mm.r[13]+8))
            else:self.excluded[line]+=1
            mm.r[0]=0
        def observe(pc):
            if pc==0x107648:t.event('cache_chain',signed(m.r[0]),m.r[1],m.r[2])
            elif pc==0x107ed0:raise AssertionError('unexpected per-chip cache path')
        m.observer=observe;m.r[:4]=[R.DEVICE,*inputs(p)]
        hooks={0x5940ec:alloc,0x5a2ee8:copy,0x5a6108:lock,0x5a66c4:unlock,
               0x5a8684:write,0x5931e4:error,0x10ef3c:sleep,0x593c8c:release,0xfa0c4:log}
        rc=signed(m.run(START,hooks=hooks,max_steps=150000))
        assert not live and m.r[13]==m.STACK_TOP and {START,0xe4a74,0xd26ac,0x117f7c}<=m.visited
        # Explicit UART fd/path, errno word and eleven-byte frame allocation.
        # All other bytes retain the earlier register fixture's guard policy.
        before=bytearray(v.before)
        for address,size in [(R.DEVICE+28,8),(T.ERRPTR,4),(T.HEAP,11)]:
            offset=address-R.DEVICE;before[offset:offset+size]=m.mem[address:address+size]
        v.before=bytes(before);v.check_extra_writes()
        self.steps+=m.steps;self.visited|=m.visited
        return rc,t.events,v.snapshot(True),signed(m.read(R.DEVICE+32))

class PipelineNative:
    def __init__(self,lib,elf):self.lib=lib;self.elf=elf
    def run(self,p):
        lib=self.lib;v=R.NativeView(self.elf,p);u=T.Uart(None,p.get('fd',17),115200,True)
        error=I(p.get('errno',11));storage=C.create_string_buffer(13);live=False;wi=0;keep=[];errors=[]
        def mutate(k,x):
            if k=='fd':u.fd=x
            elif k=='errno':error.value=x
            else:v.mutate(k,x)
        t=Trace(p,mutate,lambda:brief(v,u.fd))
        def cb(ty,fn):
            def call(*args):
                try:return fn(*args)
                except BaseException as e:errors.append(e);return None if ty in (T.ALLOC,T.FREE,T.VOID,R.LOG) else -999
            c=ty(call);keep.append(c);return c
        def alloc(_,n):
            nonlocal live
            assert n==11;t.event('allocate',n);live=not p.get('no_memory',False)
            C.memset(C.addressof(storage),0xa5,13);return C.addressof(storage)+1 if live else None
        def release(_,ptr):
            nonlocal live
            assert live and ptr==C.addressof(storage)+1
            assert storage.raw[0]==storage.raw[12]==0xa5;t.event('release');live=False
        def write(_,fd,buf,n):
            nonlocal wi
            assert live and buf==C.addressof(storage)+1 and n==11;t.event('write',fd,C.string_at(buf,n).hex())
            seq=T.outcomes(p.get('io','exact'),n);rc,err=seq[min(wi,len(seq)-1)];wi+=1
            if err is not None:error.value=err
            return rc
        def err(_):t.event('errno_pointer');return C.addressof(error)
        f=T.Frame();o=T.UartOps()
        for field,ty,fn in [('allocate',T.ALLOC,alloc),('release',T.FREE,release),
            ('lock',T.VOID,lambda _:t.event('outer_lock')),('unlock',T.VOID,lambda _:t.event('outer_unlock'))]:
            setattr(f,field,C.cast(cb(ty,fn),P))
        for field,ty,fn in [('write',T.WRITE,write),('error_number',T.ERR,err),
            ('lock',T.VOID,lambda _:t.event('inner_lock')),('unlock',T.VOID,lambda _:t.event('inner_unlock')),
            ('sleep_ms',T.SLEEP,lambda _,n:t.event('sleep',n))]:setattr(o,field,C.cast(cb(ty,fn),P))
        identity=C.addressof(v.device);b=T.Binding(identity,C.pointer(u),C.pointer(f),C.pointer(o))
        table=T.Dispatch(C.cast(lib.vn135_aml_uart_send_135,T.SEND),C.cast(C.pointer(b),P))
        def send(_,device,buf,n):
            assert C.addressof(device.contents)==identity and n==9
            return lib.vn135_transport_send_135(C.byref(table),identity,buf,n)
        def chain(_,i,reg,value):
            t.event('cache_chain',i,reg,value)
            return lib.vn135_bm1368_register_cache_chain_135(C.byref(v.cache),i,reg,value)
        ro=R.Ops(cb(R.SEND,send),cb(R.CHAIN,chain),R.ONE(),cb(R.LOG,lambda _,line,i:t.event('register_log',line,i)))
        binding=Binding(C.pointer(ro),None)
        po=Ops(C.cast(lib.vn135_bm1368_pulse_register_135,WRITE),cb(R.LOG,lambda _,line,i:t.event('pulse_log',line,i)))
        rc=lib.vn135_bm1368_set_pulse_width_135(C.byref(v.device),*inputs(p),C.byref(po),C.byref(binding))
        if errors:raise errors[0]
        assert not live
        return rc,t.events,v.snapshot(True),u.fd

def pipeline_cases():
    ios=['exact','eagain','last_success','exhausted','short_stale','zero','short','hard','eintr','overreport','change_errno']
    for w,d,io in itertools.product([0,1,3,4,MASK],[0,7,8,MASK],ios):yield {'width':w,'delay':d,'io':io}
    for key,value in [('no_memory',True),('ready',0),('device',MASK),('chip_count',0),('chain_count',0)]:
        yield {'io':'exact',key:value}
    mutations=[('inner_lock',0,'fd',29),('write',0,'fd',-4),('write',0,'device',0),
        ('outer_unlock',0,'ready',0),('release',0,'device',MASK),('register_log',0,'device',4),
        ('pulse_log',0,'device',MASK),('pulse_log',1,'device',17)]
    for mutation,io in itertools.product(mutations,['exact','eagain','hard']):yield {'io':io,'mutations':[mutation]}
    yield {'io':'hard','mutations':[('register_log',0,'device',4),('pulse_log',0,'device',MASK)]}
    yield {'io':'exact','ready':0,'mutations':[('pulse_log',0,'device',MASK)]}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary',type=Path);ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==T.SHA
    lib=C.CDLL(str(Path(a.library).resolve()));configure(lib);d=Direct(elf,lib);nc=ne=0
    for p in direct_cases(a.quick):
        old,new=d.run(p,False),d.run(p,True)
        assert old==new,('SEMANTIC_MISMATCH',p,old,new)
        nc+=1;ne+=len(old[2])
    summary={'direct_cases':nc,'direct_events':ne,'direct_steps':d.steps}
    if not a.quick:
        old,new=PipelineOriginal(elf),PipelineNative(lib,elf);nc=ne=0
        for p in pipeline_cases():
            left,right=old.run(p),new.run(p)
            assert left==right,('SEMANTIC_MISMATCH','nested',p,left[:2],right[:2],left[2:]==right[2:])
            nc+=1;ne+=len(left[1])
        summary.update(nested_cases=nc,nested_events=ne,nested_steps=old.steps,
            excluded_internal_diagnostics=dict(old.excluded),visited_instructions=len(d.visited|old.visited))
    summary.update(passed=True,reference_sha256=T.SHA,hardware_io=False,live_threads=False)
    if a.summary:a.summary.write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
