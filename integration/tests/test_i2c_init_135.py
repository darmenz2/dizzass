#!/usr/bin/env python3
"""Differential tests: original instructions vs C, scripted errors and state."""
import argparse
from collections import Counter
import ctypes as C
import json
from pathlib import Path
import random
from i2c_init_135_oracle import Oracle
from test_i2c_soft_135 import Ops as SoftOps, State as SoftState, WRITE,READ,OPEN,CLOSE,DELAY,LOG
I32=C.c_int32;U32=C.c_uint32;P=C.c_void_p
class Registration(C.Structure):_fields_=[('kind',U32),('index',U32),('name',P)]
class GPIO(C.Structure):
    _fields_=[('soft',SoftState),('sda_mode',U32),('scl_mode',U32),('sda_pin',I32),('scl_pin',I32),
              ('sda_value',C.c_char*256),('sda_direction',C.c_char*256),('scl_value',C.c_char*256),('scl_direction',C.c_char*256)]
class PSU(C.Structure):_fields_=[('registration',Registration),('gpio',GPIO),('ready',C.c_uint8)]
class Iface(C.Structure):_fields_=[('fd',I32)]
class HW(C.Structure):_fields_=[('registration',Registration),('hardware',Iface)]
PIN=C.CFUNCTYPE(I32,P,I32);DIR=C.CFUNCTYPE(I32,P,I32,U32);DUP=C.CFUNCTYPE(P,P,C.c_char_p)
MUTEX=C.CFUNCTYPE(I32,P,C.c_int,C.POINTER(Registration),U32)
INITLOG=C.CFUNCTYPE(None,P,C.c_int,U32)
class InitOps(C.Structure):_fields_=[('io',SoftOps),('check',PIN),('unexport',PIN),('direction',DIR),('duplicate',DUP),('mutex',MUTEX),('log',INITLOG)]
TLOG=C.CFUNCTYPE(None,P,C.c_int,U32,U32,U32,U32,C.c_char_p)
class TransportOps(C.Structure):
    _fields_=[('lock',P),('unlock',P),('open',OPEN),('close',CLOSE),('ioctl',P),('write',P),('read',P),('sleep',P),('errno',P),('text',P),('calloc',P),('free',P),('log',TLOG)]
class Transport(C.Structure):_fields_=[('global_',C.POINTER(Iface)),('ops',C.POINTER(TransportOps)),('opaque',P)]

INITIAL=dict(kind=9,index=7,direction=0,sda_mode=99,scl_mode=88,sda=13,scl=14,
             fd=20,dirfd=21,sclfd=22,ready=0,hwfd=31)
class Script:
    def __init__(self,fault=None,exported=0):
        self.fault=fault;self.exported=exported;self.events=[];self.counts=Counter();self.state=lambda:()
    def result(self,k,v):
        self.counts[k]+=1
        if self.fault and self.fault[0]==k and self.fault[1] in (0,self.counts[k]):return self.fault[2]
        return v
    def event(self,*a):self.events.append((*a,self.state()))
    def open(self,path,flags):
        rc=self.result('open',100+self.counts['open']);self.event('open',path,flags,rc);return rc
    def close(self,fd):
        rc=self.result('close',0);self.event('close',fd,rc);return rc
    def write(self,fd,data):
        rc=self.result('write',len(data));self.event('write',fd,data,rc);return rc
    def check(self,pin):
        rc=self.result('check',self.exported);self.event('check',pin,rc);return rc
    def unexport(self,pin):
        rc=self.result('unexport',0);self.event('unexport',pin,rc);return rc
    def direction(self,pin,mode):
        rc=self.result('direction',0);self.event('direction',pin,mode,rc);return rc
    def duplicate(self,text):
        ok=self.result('duplicate',1)!=0;self.event('duplicate',text,ok);return ok
    def mutex(self,step,typ):
        rc=self.result('mutex',0);self.event('mutex',step,typ,rc);return rc
    def log(self,source,line):self.event('log',source,line)

class Native:
    def __init__(self,path):
        self.lib=C.CDLL(str(Path(path).resolve()))
        self.reg=self.lib.vn135_i2c_register_135;self.reg.argtypes=[C.POINTER(Registration),C.POINTER(InitOps),P,U32,U32,C.c_char_p];self.reg.restype=I32
        self.gpio=self.lib.vn135_i2c_gpio_initialize_135;self.gpio.argtypes=[C.POINTER(GPIO),C.POINTER(InitOps),P,I32,I32];self.gpio.restype=I32
        self.close=self.lib.vn135_i2c_gpio_close_135;self.close.argtypes=[C.POINTER(GPIO),C.POINTER(InitOps),P];self.close.restype=None
        self.psu=self.lib.vn135_aml_psu_bus_initialize_135;self.psu.argtypes=[C.POINTER(PSU),C.POINTER(InitOps),P];self.psu.restype=I32
        self.hw=self.lib.vn135_aml_hw_bus_initialize_135;self.hw.argtypes=[C.POINTER(HW),C.POINTER(InitOps),P,C.POINTER(Transport)];self.hw.restype=I32
        self.psu_get=self.lib.vn135_aml_psu_bus_get_135;self.psu_get.argtypes=[C.POINTER(PSU),U32];self.psu_get.restype=P
        self.hw_get=self.lib.vn135_aml_hw_bus_get_135;self.hw_get.argtypes=[C.POINTER(HW),U32];self.hw_get.restype=P
    def run(self,name,script,initial,args=()):
        self.errors=[];keep=[]
        def guard(fn,default=0):
            def f(*a):
                try:return fn(*a)
                except Exception as e:self.errors.append(e);return default
            return f
        def duplicate(_,text):
            if not script.duplicate(text.decode()):return None
            b=C.create_string_buffer(text);keep.append(b);return C.addressof(b)
        softops=SoftOps(WRITE(guard(lambda _,fd,b,n:script.write(fd,bytes(b[:n])))),READ(),
            OPEN(guard(lambda _,p,f:script.open(p.decode(),f))),CLOSE(guard(lambda _,fd:script.close(fd))),DELAY(),LOG())
        ops=InitOps(softops,PIN(guard(lambda _,p:script.check(p))),PIN(guard(lambda _,p:script.unexport(p))),
                    DIR(guard(lambda _,p,m:script.direction(p,m))),DUP(guard(duplicate,None)),
                    MUTEX(guard(lambda _,step,s,t:script.mutex(step,t))),INITLOG(guard(lambda _,s,l:script.log(s,l),None)))
        psu=PSU();hw=HW();s=psu.gpio;r=hw.registration if name.startswith('hw') else psu.registration
        old=C.create_string_buffer(b'old');r.kind=initial['kind'];r.index=initial['index'];r.name=C.addressof(old)
        for k in ('sda_value','sda_direction','scl_value','scl_direction'):C.memset(C.addressof(s)+getattr(GPIO,k).offset,0xa5,256)
        s.soft.sda_output=initial['direction'];s.soft.sda_value_fd=initial['fd'];s.soft.sda_direction_fd=initial['dirfd'];s.soft.scl_value_fd=initial['sclfd']
        s.sda_mode=initial['sda_mode'];s.scl_mode=initial['scl_mode'];s.sda_pin=initial['sda'];s.scl_pin=initial['scl']
        psu.ready=initial['ready'];hw.hardware.fd=initial['hwfd']
        tops=TransportOps();tops.open=softops.open;tops.close=softops.close
        tops.log=TLOG(guard(lambda _,src,line,a,b,c,txt:script.log(0,line),None))
        t=Transport(C.pointer(hw.hardware),C.pointer(tops),None)
        def snapshot():
            reg=(r.kind,r.index,C.string_at(r.name).decode() if r.name else None)
            if name=='register':return reg
            if name.startswith('hw'):return reg+(hw.hardware.fd,)
            return reg+(s.soft.sda_output,s.sda_mode,s.scl_mode,s.sda_pin,s.scl_pin,s.soft.sda_value_fd,s.soft.sda_direction_fd,s.soft.scl_value_fd,psu.ready)
        script.state=snapshot
        if name=='register':rc=self.reg(C.byref(r),C.byref(ops),None,args[0],args[1],args[2].encode())
        elif name=='gpio':rc=self.gpio(C.byref(s),C.byref(ops),None,*args)
        elif name=='close':rc=self.close(C.byref(s),C.byref(ops),None)
        elif name=='psu':rc=self.psu(C.byref(psu),C.byref(ops),None)
        elif name=='hw':rc=self.hw(C.byref(hw),C.byref(ops),None,C.byref(t))
        elif name=='psu_get':rc=self.psu_get(C.byref(psu),args[0])==C.addressof(psu.registration)
        elif name=='hw_get':rc=self.hw_get(C.byref(hw),args[0])==C.addressof(hw.registration)
        else:raise AssertionError(name)
        if self.errors:raise self.errors[0]
        final=snapshot()
        if name in ('gpio','close','psu'):
            final+=(tuple(C.string_at(C.addressof(s)+getattr(GPIO,k).offset,256) for k in ('sda_value','sda_direction','scl_value','scl_direction')),)
        return rc,final,script.events

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary',required=True);args=ap.parse_args()
    oracle=Oracle();native=Native(args.library);counts=Counter();visited=set()
    def check(name,args=(),fault=None,exported=0,**state):
        initial={**INITIAL,**state};a=Script(fault,exported);b=Script(fault,exported)
        expected=oracle.run(name,a,initial,args);actual=native.run(name,b,initial,args)
        if expected!=actual:
            print('MISMATCH',name,args,fault,initial,'results',expected[:1],actual[:1])
            for i,(x,y) in enumerate(zip(expected[2],actual[2])):
                if x!=y:print('EVENT',i,x,y);break
            for i,(x,y) in enumerate(zip(expected[1],actual[1])):
                if x!=y:print('FINAL',i,x,y)
            raise AssertionError((len(expected[2]),len(actual[2])))
        counts[name]+=1;visited.update(oracle.m.visited);return a
    for k in (0,1,2,0xffffffff):
        for i in (0,1,0xffffffff):
            for text in ('','bus','i2c:psu-bus','/dev/i2c-1','a'*255):
                check('register',(k,i,text));check('register',(k,i,text),('duplicate',1,0))
    for name,par in (('gpio',(477,476)),('psu',()),('hw',())):
        for exported in (0,1,-1):
            baseline=check(name,par,exported=exported)
            for kind,n in baseline.counts.items():
                values=(0,) if kind=='duplicate' else (-2147483648,-2,-1,0,1,2,3,2147483647)
                for j in range(1,n+1):
                    for rc in values:check(name,par,(kind,j,rc),exported,ready=1)
    for sda in (-2147483648,-1,0,1,255,476,477,2147483647):
        for scl in (-2147483648,-1,0,477,2147483647):
            check('gpio',(sda,scl),exported=1)
    for fd in (-2147483648,-2,-1,0,1,2147483647):
        for dirfd in (-1,0,1,23):
            for sclfd in (-1,0,1,24):
                check('close',fd=fd,dirfd=dirfd,sclfd=sclfd)
                check('gpio',(477,476),fd=fd,dirfd=dirfd,sclfd=sclfd)
    for name in ('psu_get','hw_get'):
        for index in (0,1,2,3,0x7fffffff,0xffffffff):
            for ready in (0,1,255):check(name,(index,),ready=ready)
    rng=random.Random(135126084)
    for _ in range(128):
        check('gpio',(C.c_int32(rng.getrandbits(32)).value,C.c_int32(rng.getrandbits(32)).value),exported=rng.choice((0,1)),
              direction=rng.randrange(256),sda_mode=rng.getrandbits(32),scl_mode=rng.getrandbits(32),ready=rng.randrange(256))
    result={'cases':dict(counts),'total':sum(counts.values()),'visited_instruction_addresses':len(visited),
            'physical_gpio':False,'external_io':'scripted RAM','new_arm_opcodes':0,'original_nested_initializers':True}
    Path(args.summary).parent.mkdir(parents=True,exist_ok=True);Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
    print('I2C_INIT_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
