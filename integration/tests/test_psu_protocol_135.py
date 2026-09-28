#!/usr/bin/env python3
"""Differential tests: original ARM instructions versus the C reconstruction.
No production hardware, process-level firmware execution or live I2C.
"""
import argparse
import ctypes as C
from collections import Counter
import json
from pathlib import Path
import random
import struct
from psu_protocol_135_oracle import Oracle, signed

U8=C.c_uint8;U32=C.c_uint32;I32=C.c_int32;P8=C.POINTER(U8)
class Voltage(C.Structure):
    _fields_=[('model',C.c_uint16),('word_08',U32),('byte_1c',U8),('byte_130',U8),('word_132',C.c_uint16)]
LOCK=C.CFUNCTYPE(C.c_int,C.c_void_p)
BLOCK=C.CFUNCTYPE(C.c_int,C.c_void_p,U8,U32,U8,P8,U32)
WRITE=C.CFUNCTYPE(C.c_int,C.c_void_p,U8,U32,U8,U32)
READ=C.CFUNCTYPE(C.c_int,C.c_void_p,U8,U32,U8)
DELAY=C.CFUNCTYPE(C.c_int,C.c_void_p,U32)
LOG=C.CFUNCTYPE(None,C.c_void_p,C.c_uint,U32,U32,P8,U32)
class Ops(C.Structure):
    _fields_=[('lock',LOCK),('unlock',LOCK),('write_block',BLOCK),('read_block',BLOCK),('write_byte',WRITE),('read_byte',READ),('delay_ms',DELAY),('log',LOG)]
class Protocol(C.Structure):
    _fields_=[('checksum_mode',U32),('bus_kind',U32),('address',U8),('voltage',Voltage),('ops',C.POINTER(Ops)),('opaque',C.c_void_p)]

def storage(data):
    # Intentionally unaligned data with canaries on both sides.
    b=(U8*(len(data)+17))(*([0xa6]*(len(data)+17)))
    C.memmove(C.addressof(b)+3,data,len(data))
    p=C.cast(C.addressof(b)+3,P8)
    return b,p

def guard(b,n):
    assert bytes(b[:3])==b'\xa6'*3 and bytes(b[3+n:])==b'\xa6'*14

def checksum(mode,data):
    if mode:return sum(data[i]+256*data[i+1] for i in range(2,len(data)-2,2))&65535
    return sum(data[2:-2])&65535

def reply(tx,n,mode,rng,raw=None):
    assert 6<=n<=257
    r=bytearray(rng.randbytes(n));r[:2]=tx[:2];r[2]=n-2;r[3]=tx[3];r[-2:]=b'\0\0'
    if raw is not None:
        assert n==8
        r[4:6]=struct.pack('<H',raw)
    v=checksum(mode,r)
    if mode and n&1:v=(v+256*(v&255))&65535
    r[-2:]=struct.pack('<H',v)
    assert checksum(mode,r)==v
    return bytes(r)

class Native:
    def __init__(self,path):
        self.lib=C.CDLL(str(path.resolve()))
        for name in ('response_check','exchange_block','exchange_bytes'):
            f=getattr(self.lib,'vn135_psu_'+name)
            f.argtypes=[C.POINTER(Protocol),P8,U32,P8,U32];f.restype=C.c_int
        self.lib.vn135_psu_decode_voltage.argtypes=[C.POINTER(Voltage),I32]
        self.lib.vn135_psu_decode_voltage.restype=C.c_double
        self.lib.vn135_psu_read_voltage.argtypes=[C.POINTER(Protocol),P8,C.POINTER(I32)]
        self.lib.vn135_psu_read_voltage.restype=C.c_int
    def begin(self,mode,state=(34,0,0,0,0),kind=0,address=16,responses=(b'',),returns=None,mutate_mode=None):
        self.events=[];self.errors=[];self.attempt=0;self.read_index=0
        self.responses=responses;self.returns=returns or {};self.mutate_mode=mutate_mode
        def safe(fn):
            def wrapped(*args):
                try:return fn(*args)
                except BaseException as e:self.errors.append(e);return -999
            return wrapped
        def lock(_):self.events.append(('lock',));return self.returns.get('lock',0)
        def unlock(_):self.events.append(('unlock',));return self.returns.get('unlock',0)
        def wb(_,a,m,r,p,n):
            self.events.append(('write_block',a,m,r,C.string_at(p,n)));return self.returns.get('write',0)
        def rb(_,a,m,r,p,n):
            self.events.append(('read_block',a,m,r,n))
            x=self.responses[min(self.attempt-1,len(self.responses)-1)]
            if x is not None:
                assert len(x)<=n;C.memmove(p,bytes(x),len(x))
            return self.returns.get('read',0)
        def wy(_,a,m,r,v):
            self.events.append(('write_byte',a,m,r,v));return self.returns.get('write',0)
        def ry(_,a,m,r):
            self.events.append(('read_byte',a,m,r))
            x=self.responses[min(self.attempt-1,len(self.responses)-1)]
            v=self.returns.get('read',-1) if x is None else x[self.read_index]
            self.read_index+=1;return v
        def delay(_,v):
            self.events.append(('delay',v))
            if v==400:self.attempt+=1;self.read_index=0
            if v==100 and self.mutate_mode is not None:self.p.checksum_mode=self.mutate_mode
            return self.returns.get('delay',0)
        def log(_,line,a,b,p,n):self.events.append(('log',line,a,b,C.string_at(p,n) if n else b''))
        self.ops=Ops(LOCK(safe(lock)),LOCK(safe(unlock)),BLOCK(safe(wb)),BLOCK(safe(rb)),WRITE(safe(wy)),READ(safe(ry)),DELAY(safe(delay)),LOG(safe(log)))
        self.p=Protocol(mode,kind,address,Voltage(*state),C.pointer(self.ops),None)
    def validate(self,mode,tx,rx,request_size=None):
        self.begin(mode)
        tb,tp=storage(tx);rb,rp=storage(rx)
        rc=self.lib.vn135_psu_response_check(C.byref(self.p),tp,len(tx) if request_size is None else request_size,rp,len(rx))
        assert not self.errors,self.errors
        guard(tb,len(tx));guard(rb,len(rx));assert C.string_at(tp,len(tx))==tx and C.string_at(rp,len(rx))==rx
        return rc,self.events
    def voltage(self,state,raw):
        s=Voltage(*state);before=bytes(s)
        v=self.lib.vn135_psu_decode_voltage(C.byref(s),signed(raw&0xffffffff))
        assert bytes(s)==before
        return struct.unpack('<Q',struct.pack('<d',v))[0]
    def exchange(self,kind,mode,tx,responses,initial,address=16,returns=None,mutate_mode=None,read_command=False,state=(34,0,0,0,0)):
        self.begin(mode,state,kind,address,responses,returns,mutate_mode)
        tb,tp=storage(tx);rb,rp=storage(initial);out=I32(0x11223344)
        if read_command:rc=self.lib.vn135_psu_read_voltage(C.byref(self.p),rp,C.byref(out))
        else:
            f=self.lib.vn135_psu_exchange_block if kind==0 else self.lib.vn135_psu_exchange_bytes
            rc=f(C.byref(self.p),tp,len(tx),rp,len(initial))
        assert not self.errors,self.errors
        guard(tb,len(tx));guard(rb,len(initial));assert C.string_at(tp,len(tx))==tx
        return rc,C.string_at(rp,len(initial)),self.events,out.value

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library',type=Path);ap.add_argument('--summary',type=Path)
    args=ap.parse_args();o=Oracle();c=Native(args.library);rng=random.Random(13510560);counts=Counter()
    def compare(group,method,*a,**kw):
        original=getattr(o,method)(*a,**kw);native=getattr(c,method)(*a,**kw)
        assert native==original,(group,a,kw,original,native)
        counts[group]+=1
    tx=bytes.fromhex('55aa04030700')
    # All supported length values, malformed headers/commands, and odd word sums.
    for mode in (0,1,2,0xffffffff):
        for n in range(4,258):
            good=reply(tx,n,mode,rng) if n>=6 else rng.randbytes(n)
            compare('validator','validate',mode,tx,good)
            for pos in (0,3,n-1):
                bad=bytearray(good);bad[pos]^=1
                compare('validator','validate',mode,tx,bytes(bad))
        for tn in (0,1,2,3,6,257,0xffffffff):
            compare('validator','validate',mode,tx,reply(tx,8,mode,rng),request_size=tn)
        alt=bytes.fromhex('123400ff')
        compare('validator','validate',mode,alt,reply(alt,8,mode,rng))
    # Every numeric model in/around the switch and boundary raw words.
    raws=(0,1,255,1000,1275,65535,-1,-2147483648,2147483647)
    for model in list(range(257))+[65535]:
        for raw in raws:compare('voltage_bits','voltage',(model,0,0,0,0),raw)
    models=(34,65,66,67,97,101,102,106,113,114,115,116,117,118,119,120,193,194,196,0xffff)
    for model in models:
        for w08 in (0,3,4,0xffffffff):
            for b1c in (0,1,255):
                compare('voltage_bits','voltage',(model,w08,b1c,0,0),rng.randint(-2147483648,2147483647))
    for b130 in (1,255):
        for w132 in (0,1,2,3,65535):
            for raw in raws:compare('voltage_bits','voltage',(65535,0xffffffff,255,b130,w132),raw)
    # Compare full traces and final bytes, including failed low-level returns.
    for kind in (0,1):
        for mode in (0,1,2,0xffffffff):
            for n in (6,7,8,9,12,31,256,257):
                good=reply(tx,n,mode,rng);bad=bytearray(good);bad[-1]^=1;bad=bytes(bad)
                initial=rng.randbytes(n)
                for responses in ([good],[bad,good],[bad,bad,good],[bad]):
                    for ret in ({},{'lock':-1,'write':-5,'read':-9,'delay':-4,'unlock':-7}):
                        compare('exchange','exchange',kind,mode,tx,responses,initial,address=0x37,returns=ret)
            # Validator consults current mode, transfer flag stays captured.
            for new_mode in (0,1,2,0xffffffff):
                good=reply(tx,8,new_mode,rng)
                compare('exchange','exchange',kind,mode,tx,[good],b'\x33'*8,mutate_mode=new_mode)
    for kind in (0,1):
        for mode in (0,1,2,0xffffffff):
            for tn in (4,5,7,16,255,256,257):
                req=rng.randbytes(tn);good=reply(req,8,mode,rng)
                compare('exchange','exchange',kind,mode,req,[good],b'\0'*8,address=0xe7)
    for kind in (0,1):
        for mode in (0,1):
            good=reply(tx,8,mode,rng)
            if kind==0:
                for n in range(9):
                    compare('exchange','exchange',kind,mode,tx,[good[:n]],good,returns={'read':-5})
                compare('exchange','exchange',kind,mode,tx,[None],good,returns={'read':-5,'write':-5})
            else:
                for error in (-1,-128,-256,0x1ff):
                    compare('exchange','exchange',kind,mode,tx,[None],good,returns={'read':error})
                compare('exchange','exchange',kind,mode,tx,[[v-256 for v in good]],b'\0'*8)
    # Composed command -> exchange -> original check -> original decoder.
    for kind in (0,1):
        for mode in (0,1,2):
            for model in models:
                state=(model,4,1,0,0)
                for raw in (0,1275,65535):
                    good=reply(tx,8,mode,rng,raw)
                    compare('read_voltage','exchange',kind,mode,tx,[good],b'\x22'*8,read_command=True,state=state)
                bad=bytes.fromhex('55aa060300000000')
                compare('read_voltage','exchange',kind,mode,tx,[bad],b'\x22'*8,read_command=True,state=state)
    for kind in (2,0xffffffff):
        compare('read_voltage','exchange',kind,0,tx,[b'\0'*8],b'\x22'*8,read_command=True)
    for mode in (0,1):
        good=reply(tx,8,mode,rng,100)
        compare('read_voltage','exchange',0,mode,tx,[None],good,returns={'write':-1,'read':-1},read_command=True)
    # Delay argument units and exact integer construction in the original.
    for v in (0,1,100,400,999,1000,1001,123456,0x7fffffff,0xffffffff):
        o.delay(v);counts['delay_conversion']+=1
    # Isolated fixture checks of only the three local interpreter extensions.
    m=o.m
    for i in range(100):
        m.reset();m.allowed=[(0x1000,0x1004)];m.n,m.z,m.c,m.v=(bool((i>>j)&1) for j in range(4));flags=(m.n,m.z,m.c,m.v)
        reg=[rng.getrandbits(32) for _ in range(16)];m.r=reg.copy()
        lo,hi,rs,rm=0,1,(i%5),(i//5)%5
        z=reg[rs]*reg[rm];w=0xe0800090|(hi<<16)|(lo<<12)|(rs<<8)|rm
        assert m.extra_instruction(w,0x1000) and m.r[lo]==z&0xffffffff and m.r[hi]==z>>32
        assert (m.n,m.z,m.c,m.v)==flags;counts['interpreter_fixtures']+=1
        m.r=reg.copy();rd,ra,rs,rm=0,(i%5),(i//5)%5,(i//25)%4
        w=0xe0600090|(rd<<16)|(ra<<12)|(rs<<8)|rm
        assert m.extra_instruction(w,0x1000) and m.r[rd]==(reg[ra]-reg[rs]*reg[rm])&0xffffffff
        assert (m.n,m.z,m.c,m.v)==flags;counts['interpreter_fixtures']+=1
        m.r[4]=0x84f003;m.s[0]=rng.getrandbits(32);before=m.s[0]
        m.mem[0x84f002:0x84f008]=b'\xa5'*6
        assert m.extra_instruction(0xed840a00,0x1000)
        assert m.read(0x84f003,4)==before and m.read(0x84f002,1)==m.read(0x84f007,1)==0xa5
        assert (m.n,m.z,m.c,m.v)==flags;counts['interpreter_fixtures']+=1
    result={'counts':dict(counts),'original_comparisons':sum(v for k,v in counts.items() if k!='interpreter_fixtures'),
        'firmware_process_executed':False,'hardware_io':False,'reference_sha256':o.evidence['reference_sha256']}
    print('PSU135_ORIGINAL_PASS '+json.dumps(result,sort_keys=True))
    if args.summary:args.summary.write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
