#!/usr/bin/env python3
"""Compose original backend -> AML -> GPIO -> original PSU setter/exchange.
The bus electrical implementation is not executed. Trace all packet bytes.
"""
import argparse, ctypes as C, hashlib, itertools, json
from pathlib import Path
from gpio_power_135_oracle import Oracle as GPIOOracle, B, signed
from test_gpio_power_135 import Native as GPIONative, Script
from psu_protocol_135_oracle import Oracle as PSUOracle
from psu_setup_135_oracle import SetupArm
from test_psu_protocol_135 import Voltage, Protocol, Ops, LOCK, BLOCK, WRITE, READ, DELAY, LOG, U8, U32, I32, P8, checksum
import struct

class Calibration(C.Structure):
    # Current psu_setup_135.h projection, not the archival setup-state layout.
    _fields_=[('lower',I32),('upper',I32),('enabled',U8),('count',U32),
              ('x',C.c_double*15),('y',C.c_double*15)]
def initial():
    s=Calibration();s.lower=10000;s.upper=14000;s.count=5
    return s
def cal_tuple(s):
    return s.lower,s.upper,s.enabled,s.count,bytes(s.x),bytes(s.y)
def load_cal(psu,s):
    m=psu.m;S=psu.STATE
    for off,v,n in [(20,s.lower,4),(24,s.upper,4),(16,s.enabled,1),(48,s.count,4)]:
        m.write(S+off,v&((1<<(8*n))-1),n)
    m.mem[S+56:S+176]=bytes(s.x);m.mem[S+176:S+296]=bytes(s.y)
def save_cal(psu):
    m=psu.m;S=psu.STATE
    return signed(m.read(S+20)),signed(m.read(S+24)),m.read(S+16,1),m.read(S+48),bytes(m.mem[S+56:S+176]),bytes(m.mem[S+176:S+296])

class Wire:
    """Only the observed 0x83 command replies; no electrical bus simulation."""
    def __init__(self,bad_attempts=0):
        self.bad_attempts=bad_attempts;self.write_rc=0;self.read_rc=0;self.reset()
    def reset(self):
        self.events=[];self.pending=bytearray();self.tx=b'';self.response=None
        self.ri=0;self.attempt=0
    def write_block(self,a,m,r,data):
        self.events.append(('write_block',a,m,r,data));self.pending=bytearray(data)
    def write_byte(self,a,m,r,v):
        self.events.append(('write_byte',a,m,r,v));self.pending.append(v&255)
    def delay(self,v):
        self.events.append(('delay',v))
        if v==400:
            self.tx=bytes(self.pending);self.pending.clear();self.ri=0
            self.response=None;self.attempt+=1
            assert len(self.tx) in (8,10) and self.tx[3]==0x83
    def make_response(self,n,mode):
        assert n==len(self.tx)
        r=bytearray(n);r[:2]=self.tx[:2];r[2]=n-2;r[3]=self.tx[3]
        r[-2:]=struct.pack('<H',checksum(mode,r))
        if self.attempt<=self.bad_attempts:r[0]^=0xff
        return bytes(r)
    def read_block(self,a,m,r,n,mode):
        self.events.append(('read_block',a,m,r,n));return self.make_response(n,mode)
    def read_byte(self,a,m,r,mode):
        self.events.append(('read_byte',a,m,r))
        if self.response is None:self.response=self.make_response(len(self.tx),mode)
        v=self.response[self.ri];self.ri+=1;return v

class PSUNative:
    def __init__(self,path):
        self.lib=C.CDLL(str(Path(path).resolve()))
        self.fn=self.lib.vn135_psu_set_voltage
        self.fn.argtypes=[C.POINTER(Protocol),C.POINTER(Calibration),U32,P8]
        self.fn.restype=C.c_int
    def procedure(self,mode,cal,wire,model,kind,mv):
        wire.reset();s=Calibration.from_buffer_copy(cal);errors=[]
        def safe(fn):
            def call(*a):
                try:return fn(*a)
                except BaseException as e:errors.append(e);return -999
            return call
        def lock(_):wire.events.append(('lock',));return 0
        def unlock(_):wire.events.append(('unlock',));return 0
        def wb(_,a,m,r,q,n):wire.write_block(a,m,r,C.string_at(q,n));return 0
        def rb(_,a,m,r,q,n):
            data=wire.read_block(a,m,r,n,p.checksum_mode);C.memmove(q,data,len(data));return 0
        def wy(_,a,m,r,v):wire.write_byte(a,m,r,v);return 0
        def ry(_,a,m,r):return wire.read_byte(a,m,r,p.checksum_mode)
        def delay(_,v):wire.delay(v);return 0
        def log(_,line,a,b,q,n):wire.events.append(('log',line,a,b,C.string_at(q,n) if n else b''))
        ops=Ops(LOCK(safe(lock)),LOCK(safe(unlock)),BLOCK(safe(wb)),BLOCK(safe(rb)),
                WRITE(safe(wy)),READ(safe(ry)),DELAY(safe(delay)),LOG(safe(log)))
        p=Protocol(mode,kind,16,Voltage(model,4,0,0,0),C.pointer(ops),None)
        scratch=(U8*10)(*([0x48]*10))
        rc=self.fn(C.byref(p),C.byref(s),mv,scratch)
        if errors:raise errors[0]
        return rc,cal_tuple(s),p.checksum_mode

class CombinedArm(SetupArm):
    def extra_instruction(self,w,pc):
        if pc==0x104134:self.observe_set(self.r[0],self.r[1])
        return super().extra_instruction(w,pc)
def original(gpio,psu,script,wire,setup,mode,kind,model,requested):
    psu.DEVICE=B+0x108c;psu.BUS=0x848000
    wire.reset()
    def augment(m,hooks):
        del hooks[0x104134]  # The real setter executes, no return substitution.
        m.observe_set=lambda dev,v: (script.call('set_voltage',(v,)),
            (_ for _ in ()).throw(AssertionError('device binding')) if dev!=psu.DEVICE else None)
        m.write(psu.STATE+12,mode)
        for off,val,n in [(4,model,2),(8,4,4),(28,0,1),(304,0,1),(306,0,2)]:m.write(psu.STATE+off,val,n)
        m.write(psu.DEVICE+24,psu.BUS);m.write(psu.DEVICE+28,16,1);m.write(psu.BUS+24,kind)
        load_cal(psu,setup);psu.dumps={}
        old_lock=hooks[0x5a6108];old_unlock=hooks[0x5a66c4];old_log=hooks[0xfa0c4]
        def lock(x):
            if x.r[0]!=psu.DEVICE:return old_lock(x)
            wire.events.append(('lock',));x.r[0]=0
        def unlock(x):
            if x.r[0]!=psu.DEVICE:return old_unlock(x)
            wire.events.append(('unlock',));x.r[0]=0
        def delay(x):wire.delay(x.r[0]);x.r[0]=0
        def wb(x):
            assert x.r[0]==psu.BUS
            ptr,n=x.read(x.r[13]),x.read(x.r[13]+4)
            wire.write_block(*x.r[1:4],bytes(x.mem[ptr:ptr+n]));x.r[0]=wire.write_rc&0xffffffff
        def rb(x):
            assert x.r[0]==psu.BUS
            ptr,n=x.read(x.r[13]),x.read(x.r[13]+4)
            data=wire.read_block(*x.r[1:4],n,mode=x.read(psu.STATE+12))
            if data is not None:x.mem[ptr:ptr+len(data)]=data
            x.r[0]=wire.read_rc&0xffffffff
        def wy(x):
            assert x.r[0]==psu.BUS
            wire.write_byte(*x.r[1:4],x.read(x.r[13]));x.r[0]=wire.write_rc&0xffffffff
        def ry(x):
            assert x.r[0]==psu.BUS
            x.r[0]=wire.read_byte(*x.r[1:4],mode=x.read(psu.STATE+12))&0xffffffff
        def log(x):
            if not (0x100000<=x.r[14]<0x106000):return old_log(x)
            line=x.r[3];a=b=0;data=b''
            if line in (515,519,540,868,1037,1069):a=x.read(x.r[13]+8)
            elif line in (957,1016):a=x.read(x.r[13]+8);b=x.read(x.r[13]+12)
            elif line in (937,939):data=psu.dumps[x.read(x.r[13]+8)]
            wire.events.append(('log',line,a,b,data));x.r[0]=0
        hooks.update({0x5a6108:lock,0x5a66c4:unlock,0x10ed2c:delay,
         0xfe538:wb,0xfe528:rb,0x126fcc:wy,0x128188:ry,0xfa0c4:log,0x10f170:psu.fmt})
    return gpio.run('start',script,arg=requested,ready=1,augment=augment)
def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');a=ap.parse_args()
    gn=GPIONative(a.library);pn=PSUNative(a.library);go=GPIOOracle();po=PSUOracle()
    mixed=CombinedArm(go.elf)
    mixed.mem[:]=go.m.mem;po.m=mixed;go.m=mixed
    # Restore verified bounds after reset, including previously reviewed VFP.
    manifest=json.loads((Path(__file__).parents[1]/'evidence/gpio_power_135.json').read_text())
    gpio_ranges=[(int(s['start'],16),int(s['end_exclusive'],16)) for s in manifest['ranges']]
    po.begin(0);mixed.allowed+=gpio_ranges+[(0xffff8,0x100878),(0x103058,0x104218),(0x596778,0x596818)]
    mixed.observe_set=lambda *_:None
    # Validate the saved setup spans as well as the base GPIO and PSU spans.
    evidence=json.loads((Path(__file__).parents[1]/'evidence/psu_setup_135.json').read_text())
    for span in evidence['ranges']:
        start,end=int(span['start'],16),int(span['end_exclusive'],16)
        assert hashlib.sha256(go.elf.read(start,end-start)).hexdigest()==span['sha256']
    count=events=0
    for mode,kind,model,requested,bad,cal in itertools.product([0,1],[0,1],[193,196],
          [10000,12000,14000,0x12342ee0],[0,1,3],[False,True]):
        setup=initial();setup.enabled=cal
        # Valid, monotonically increasing voltage intervals; code-valued x.
        if mode:
            setup.x[:]=[10.0+i for i in range(15)];setup.y[:]=[9.9+i for i in range(15)]
        else:
            setup.x[:]=[float(230-i*20) for i in range(15)];setup.y[:]=[10.0+i for i in range(15)]
        setup.count=5
        so=Script();wo=Wire(bad)
        expected=original(go,po,so,wo,setup,mode,kind,model,requested)
        assert 0x104134 in mixed.visited
        assert (0x103ae8 if mode else 0x103058) in mixed.visited
        assert (0x105938 if kind else 0x10560c) in mixed.visited
        assert 0x102bd0 in mixed.visited
        sn=Script();wn=Wire(bad)
        saved=[]
        def setter(v):
            result=pn.procedure(mode,setup,wn,model,kind,v)
            saved.append(result)
            return result[0]
        sn.setter=setter
        actual=gn.run('start',sn,arg=requested,ready=1)
        assert expected==actual,(mode,kind,model,requested,bad,cal,expected,actual)
        assert len(saved)==1 and save_cal(po)==saved[0][1]
        assert mixed.read(po.STATE+12)==saved[0][2]
        assert wo.events==wn.events,(mode,kind,model,requested,bad,cal,wo.events,wn.events)
        count+=1;events+=len(wo.events)+len(expected[2])
    result={'composed_cases':count,'external_events':events,'original_setter_exchange_validator':True,
      'original_gpio_and_dispatch':True,'native_setup_interface':'vn135_psu_calibration','electrical_bus':'scripted block/byte responses','physical_psu':False}
    print('GPIO_POWER_PSU135_PASS',json.dumps(result,sort_keys=True))
    if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
