#!/usr/bin/env python3
"""Compare C to seven original entries through identical scripted I/O."""
import argparse
import ctypes as C
from collections import Counter
import json
from pathlib import Path
import random
from i2c_soft_135_oracle import Oracle, ENTRIES
I32=C.c_int32; U32=C.c_uint32; U8=C.c_uint8; P8=C.POINTER(U8)
WRITE=C.CFUNCTYPE(I32,C.c_void_p,I32,P8,U32)
READ=C.CFUNCTYPE(I32,C.c_void_p,I32,P8,U32)
OPEN=C.CFUNCTYPE(I32,C.c_void_p,C.c_char_p,U32)
CLOSE=C.CFUNCTYPE(I32,C.c_void_p,I32)
DELAY=C.CFUNCTYPE(I32,C.c_void_p,U32)
LOG=C.CFUNCTYPE(None,C.c_void_p,U32,U32,U32)
class Ops(C.Structure):
    _fields_=[('write',WRITE),('read',READ),('open',OPEN),('close',CLOSE),('delay_ms',DELAY),('log',LOG)]
class State(C.Structure):
    _fields_=[('sda_output',U8),('sda_value_fd',I32),('sda_direction_fd',I32),
              ('scl_value_fd',I32),('sda_value_path',C.c_char_p),('ops',C.POINTER(Ops)),('opaque',C.c_void_p)]
class Script:
    def __init__(self, fault=None, samples=None, default=48):
        self.fault=fault; self.samples=list(samples or []);self.default=default
        self.counts=Counter();self.events=[];self.state=lambda:(0,0)
    def result(self,kind,normal):
        self.counts[kind]+=1
        f=self.fault
        if f and kind==f[0] and (f[1]==0 or self.counts[kind]==f[1]):return f[2]
        return normal
    def record(self,*event):self.events.append((*event,self.state()))
    def write(self,fd,data):
        n=self.result('write',len(data));self.record('write',fd,data,n);return n
    def read(self,fd,n):
        rc=self.result('read',1);i=self.counts['read']-1
        b=self.samples[i] if i<len(self.samples) else self.default
        # Explicit data model: even non-success can modify one byte; caller may not use it.
        data=bytes([b]);assert n==1
        self.record('read',fd,n,rc,data);return rc,data
    def open(self,path,flags):
        rc=self.result('open',20+self.counts['open']+1)
        self.record('open',path,flags,rc);return rc
    def close(self,fd):
        rc=self.result('close',0);self.record('close',fd,rc);return rc
    def delay(self,ms):
        assert ms==1
        rc=self.result('delay',0);self.record('delay',ms,rc);return rc
    def log(self,line,severity,arg):self.record('log',line,severity,arg)
class Native:
    def __init__(self,path):
        self.lib=C.CDLL(str(Path(path).resolve()))
        self.functions={}
        names={'input':'sda_input','output':'sda_output','send':'send_bits'}
        for name in ENTRIES:
            f=getattr(self.lib,'vn135_i2c_soft_'+names.get(name,name))
            args=[C.POINTER(State)]
            if name=='send':args+=[U32]
            if name=='write_byte':args+=[U32]*4
            if name=='read_byte':args+=[U32]*3
            f.argtypes=args;f.restype=I32 if name=='write_byte' else U8 if name=='read_byte' else None
            self.functions[name]=f
    def bind(self,script,initial):
        self.errors=[]
        def guard(fn,default=0):
            def callback(*args):
                try:return fn(*args)
                except Exception as error:self.errors.append(error);return default
            return callback
        def read(_,fd,p,n):
            rc,data=script.read(fd,n)
            if data is not None:C.memmove(p,data,len(data))
            return rc
        self.ops=Ops(WRITE(guard(lambda _,fd,p,n:script.write(fd,bytes(p[:n])))),
                     READ(guard(read)),OPEN(guard(lambda _,path,f:script.open(path.decode(),f))),
                     CLOSE(guard(lambda _,fd:script.close(fd))),
                     DELAY(guard(lambda _,ms:script.delay(ms))),
                     LOG(guard(lambda _,line,sev,arg:script.log(line,sev,arg),None)))
        direction,fd,dirfd,sclfd,path=initial
        self.path=path.encode()
        self.state=State(direction,fd,dirfd,sclfd,self.path,C.pointer(self.ops),None)
        script.state=lambda:(self.state.sda_output,self.state.sda_value_fd)
    def run(self,spec,script,initial):
        self.bind(script,initial)
        name,address,mode,reg,value=spec
        args=[C.byref(self.state)]
        if name=='send':args+=[value]
        if name=='write_byte':args+=[address,mode,reg,value]
        if name=='read_byte':args+=[address,mode,reg]
        rc=self.functions[name](*args)
        if self.errors:raise self.errors[0]
        return rc,(self.state.sda_output,self.state.sda_value_fd),script.events

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary',required=True)
    ap.add_argument('--part',type=int,default=0);ap.add_argument('--parts',type=int,default=1)
    args=ap.parse_args();assert 0<=args.part<args.parts
    native=Native(args.library);oracle=Oracle();counts=Counter();visited=set();case_id=0
    initial=(1,10,11,12,'/fixture/sda/value')
    def check(name,address=16,mode=1,reg=17,value=165,direction=1,fault=None,samples=None,default=48,fd=10):
        nonlocal case_id
        case_id+=1
        spec=(name,address,mode,reg,value);state=(direction,fd,11,12,initial[-1])
        a=Script(fault,samples,default);b=Script(fault,samples,default)
        actual=native.run(spec,b,state)
        if (case_id-1)%args.parts!=args.part:return b
        expected=oracle.run(spec,a,state)
        if expected!=actual:
            for i,(x,y) in enumerate(zip(expected[2],actual[2])):
                if x!=y:print('FIRST EVENT MISMATCH',i,x,y);break
            raise AssertionError((spec,state,fault,samples,default,expected[:2],actual[:2],len(expected[2]),len(actual[2])))
        counts[name]+=1;visited.update(oracle.m.visited)
        return a
    for name in ('input','output','start','stop'):
        for d in (0,1,2,255):
            check(name,direction=d)
            for k in ('write','open','close','delay'):
                for r in (-2147483648,-2,-1,0,1,2,3,2147483647):
                    check(name,direction=d,fault=(k,0,r))
    for value in range(256):
        check('send',value=value,direction=value&1)
        check('write_byte',address=value,reg=value^85,value=value,mode=value&1)
        samples=[48]*(1+(value&1))+[49 if value&(128>>i) else 48 for i in range(8)]
        check('read_byte',address=value,reg=value^85,mode=value&1,samples=samples)
    # Every ACK sample position, all four windows, and persistent non-'0' input.
    for pos in range(24):check('send',samples=[49]*pos+[48])
    for byte in (0,1,47,49,50,127,128,255):check('send',default=byte)
    for name in ('input','output','start','stop','send','write_byte','read_byte'):
        for d in (0,1):
            baseline=check(name,direction=d)
            for k,n in baseline.counts.items():
                for idx in range(1,n+1):
                    for r in (-1,0,2):check(name,direction=d,fault=(k,idx,r))
            for k in ('write','read','open','close','delay'):
                for r in (-2147483648,-2,2147483647):check(name,direction=d,fault=(k,0,r))
    rng=random.Random(135126)
    for _ in range(192):
        name=rng.choice(('send','write_byte','read_byte'))
        check(name,address=rng.getrandbits(32),mode=rng.choice((0,1,2,0xffffffff)),
              reg=rng.getrandbits(32),value=rng.getrandbits(32),direction=rng.choice((0,1,255)),
              samples=[rng.randrange(256) for _ in range(48)],default=rng.choice((0,48,49,255)))
    result={'part':args.part,'parts':args.parts,'enumerated':case_id,'cases':dict(counts),'total':sum(counts.values()),'visited_instruction_addresses':len(visited),
            'reference_sha256':oracle.evidence['reference_sha256'],
            'original_helpers_executed':True,'external_io':'scripted RAM callbacks',
            'new_arm_opcodes':0,'physical_gpio':False}
    Path(args.summary).parent.mkdir(parents=True,exist_ok=True)
    Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
    print('I2C_SOFT_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
