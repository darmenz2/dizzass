#!/usr/bin/env python3
"""Original PSU byte exchange AND actual recovered GPIO helpers in one trace.
External GPIO/OS calls are scripted RAM, not a live or timed bus simulation.
"""
import argparse
import ctypes as C
import hashlib
import json
from pathlib import Path
from i2c_soft_135_oracle import Oracle, ENTRIES, signed
from test_i2c_soft_135 import Native, Script
from test_psu_protocol_135 import (Protocol, Ops, Voltage, LOCK, BLOCK,
                                  WRITE, READ, DELAY, LOG, P8, U32, storage, guard, checksum)

ROOT=Path(__file__).resolve().parents[2]
INITIAL=(1,10,11,12,'/fixture/sda/value')
TX=bytes.fromhex('55aa04030700')
class Wire(Script):
    def __init__(self,responses,fault=None,outer_return=0,ack=48):
        super().__init__(fault)
        self.responses=responses;self.outer_return=outer_return;self.ack=ack
        self.attempt=0;self.byte_index=-1;self.bit_index=0;self.last_flags=1;self.data_mode={}
    def open(self,path,flags):
        prior=self.last_flags
        rc=super().open(path,flags)
        self.last_flags=flags
        self.data_mode[rc]=flags
        if flags==0 and prior!=0:
            self.byte_index+=1;self.bit_index=0
        return rc
    def read(self,fd,n):
        assert n==1
        if self.data_mode.get(fd,2)==0:
            data=self.responses[min(self.attempt-1,len(self.responses)-1)]
            assert self.attempt>=1 and 0<=self.byte_index<len(data) and self.bit_index<8
            bit=(data[self.byte_index]>>(7-self.bit_index))&1
            self.bit_index+=1;b=49 if bit else 48
        else:b=self.ack
        rc=self.result('read',1);data=bytes([b]);self.record('read',fd,n,rc,data);return rc,data
    def delay(self,ms):
        if ms==1:return super().delay(ms)
        assert ms in (100,400)
        if ms==400:self.attempt+=1;self.byte_index=-1;self.bit_index=0
        self.record('psu_delay',ms,self.outer_return);return self.outer_return
    def mutex(self,kind):self.record(kind,self.outer_return);return self.outer_return
    def psu_log(self,line,a,b,data):self.record('psu_log',line,a,b,data)

def response(mode,valid=True):
    r=bytearray.fromhex('55aa060334120000')
    r[-2:]=checksum(mode,r).to_bytes(2,'little')
    if not valid:r[-1]^=1
    return bytes(r)

def original(oracle,wire,mode,address):
    m=oracle.m;DEVICE=0x842000;TXADDR=0x844000;RXADDR=0x845000
    evidence=json.loads((ROOT/'integration/evidence/psu_protocol_135.json').read_text())
    # Reuse and verify the saved PSU slices, not copies of their behavior.
    ranges=[r for r in evidence['ranges'] if r['name'] in ('exchange_bytes','response_validator')]
    assert len(ranges)==2
    for r in ranges:
        a,b=int(r['start'],16),int(r['end_exclusive'],16)
        assert hashlib.sha256(oracle.elf.read(a,b-a)).hexdigest()==r['sha256']
    oracle.begin(('write_byte',0,0,0,0),INITIAL)
    m.reset((DEVICE,TXADDR,len(TX),RXADDR,8))
    m.allowed += [(int(r['start'],16),int(r['end_exclusive'],16)) for r in ranges]
    m.write(0x654c30+12,mode);m.write(DEVICE+24,oracle.BUS);m.write(DEVICE+28,address,1)
    m.write(oracle.BUS+24,1)
    m.mem[TXADDR:TXADDR+len(TX)]=TX;m.mem[RXADDR:RXADDR+8]=b'\xa6'*8
    wire.state=oracle.snapshot
    hooks=oracle.hooks(wire);softlog=hooks[0xfa0c4];dumps={}
    def lock(x):
        assert x.r[0]==DEVICE;x.r[0]=wire.mutex('psu_lock')&0xffffffff
    def unlock(x):
        assert x.r[0]==DEVICE;x.r[0]=wire.mutex('psu_unlock')&0xffffffff
    def fmt(x):
        dest,cap,ptr,n=x.r[:4];assert cap==1024 and n<=257
        x.check(ptr,n);dumps[dest]=bytes(x.mem[ptr:ptr+n]);x.r[0]=0
    def log(x):
        line=x.r[3]
        if line<400:return softlog(x)
        if line in (937,939):wire.psu_log(line,0,0,dumps[x.read(x.r[13]+8)])
        elif line==951:wire.psu_log(line,0,0,b'')
        elif line==957:wire.psu_log(line,x.read(x.r[13]+8),x.read(x.r[13]+12),b'')
        else:raise ValueError('Unknown PSU log '+str(line))
        x.r[0]=0
    hooks.update({0x5a6108:lock,0x5a66c4:unlock,0x10f170:fmt,0xfa0c4:log})
    # Crucially, no hooks replace byte read/write, START/STOP, ACK or validator.
    rc=m.run(0x105938,hooks=hooks,max_steps=2000000)
    assert {0x105938,0x102bd0,ENTRIES['write_byte'],ENTRIES['read_byte'],ENTRIES['start'],ENTRIES['send'],ENTRIES['stop']}<=m.visited
    return signed(rc),bytes(m.mem[RXADDR:RXADDR+8]),oracle.snapshot(),wire.events

def native(n,wire,mode,address):
    n.bind(wire,INITIAL)
    def safe(fn):
        def call(*a):
            try:return fn(*a)
            except Exception as e:n.errors.append(e);return -999
        return call
    def unreachable(*_):raise AssertionError('Block path executed')
    def wb(_,a,m,r,v):return n.functions['write_byte'](C.byref(n.state),a,m,r,v)
    def rb(_,a,m,r):return n.functions['read_byte'](C.byref(n.state),a,m,r)
    def log(_,line,a,b,p,size):wire.psu_log(line,a,b,C.string_at(p,size) if size else b'')
    ops=Ops(LOCK(safe(lambda _:wire.mutex('psu_lock'))),LOCK(safe(lambda _:wire.mutex('psu_unlock'))),
        BLOCK(safe(unreachable)),BLOCK(safe(unreachable)),WRITE(safe(wb)),READ(safe(rb)),
        DELAY(safe(lambda _,ms:wire.delay(ms))),LOG(safe(log)))
    p=Protocol(mode,1,address,Voltage(),C.pointer(ops),None)
    tb,tp=storage(TX);rb_,rp=storage(b'\xa6'*8)
    f=n.lib.vn135_psu_exchange_bytes;f.argtypes=[C.POINTER(Protocol),P8,U32,P8,U32];f.restype=C.c_int
    rc=f(C.byref(p),tp,len(TX),rp,8)
    if n.errors:raise n.errors[0]
    guard(tb,len(TX));guard(rb_,8);assert C.string_at(tp,len(TX))==TX
    return rc,C.string_at(rp,8),(n.state.sda_output,n.state.sda_value_fd),wire.events

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary',required=True)
    ap.add_argument('--part',type=int,default=0);ap.add_argument('--parts',type=int,default=1)
    args=ap.parse_args();assert 0<=args.part<args.parts
    n=Native(args.library);oracle=Oracle();cases=[]
    for mode in (0,1,2,0xffffffff):
        good,bad=response(mode),response(mode,False)
        for failures in range(4):
            responses=[bad]*failures+([good] if failures<3 else [])
            cases.append((mode,16+failures,responses,None,0,48))
        for fault in (('write',0,-1),('open',1,-1),('read',1,-1),('close',0,-1)):
            cases.append((mode,0xff,[good],fault,-1,48))
    counts=0;event_count=0;attempts=0
    for i,(mode,address,responses,fault,outer,ack) in enumerate(cases):
        if i%args.parts!=args.part:continue
        a=Wire(responses,fault,outer,ack);b=Wire(responses,fault,outer,ack)
        expected=original(oracle,a,mode,address);actual=native(n,b,mode,address)
        if expected!=actual:
            for j,(x,y) in enumerate(zip(expected[3],actual[3])):
                if x!=y:print('FIRST COMPOSED MISMATCH',j,x,y);break
            raise AssertionError((i,mode,fault,expected[:3],actual[:3],len(expected[3]),len(actual[3])))
        assert a.attempt==b.attempt
        counts+=1;attempts+=a.attempt;event_count+=len(a.events)
    out={'part':args.part,'parts':args.parts,'enumerated':len(cases),'total':counts,
         'psu_attempts':attempts,'compared_events':event_count,'original_exchange_and_gpio_helpers':True,
         'external_io':'scripted RAM callbacks','physical_gpio':False}
    Path(args.summary).write_text(json.dumps(out,indent=2)+'\n')
    print('I2C_SOFT_PSU_PASS',json.dumps(out,sort_keys=True))
if __name__=='__main__':main()
