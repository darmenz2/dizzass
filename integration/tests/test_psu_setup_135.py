#!/usr/bin/env python3
"""Original ARM setup versus C; explicit RAM transport; no hardware access."""
import argparse
import ctypes as C
from collections import Counter
import json
import math
from pathlib import Path
import random
import struct
from psu_setup_135_oracle import SetupOracle,BusScript,SetupArm
from test_psu_protocol_135 import (Native,Voltage,Protocol,Ops,LOCK,BLOCK,WRITE,READ,DELAY,LOG,U8,U32,I32,P8,storage,guard)

class Calibration(C.Structure):
    _fields_=[('lower',I32),('upper',I32),('enabled',U8),('count',U32),('x',C.c_double*15),('y',C.c_double*15)]

class Identity(C.Structure):
    _fields_=[('initial_word',U32),('date_word',U32),('serial',C.c_char*18)]
SELECT=C.CFUNCTYPE(U32,C.c_void_p,U32)
class InitOps(C.Structure):
    _fields_=[('select_bus_kind',SELECT),('mutex_init',LOCK)]
class InitScratch(C.Structure):
    _fields_=[('response',U8*40),('auxiliary',U8*14)]
SERIAL_SEED=b'old-serial-1234567'
assert len(SERIAL_SEED)==18

class SetupNative(Native):
    def __init__(self,path):
        super().__init__(path)
        lib=self.lib;PS=C.POINTER(Calibration);PP=C.POINTER(Protocol);PD=C.POINTER(C.c_double)
        for name,args in {'knots_voltage':[PS,PD,I32],'knots_raw':[PD,U32],
            'load_calibration_a':[PP,PS,P8],'load_calibration_b':[PS,P8],
            'model_family':[C.c_uint16],'identify_prefix':[PP,P8],
            'set_voltage_raw':[PP,PS,U32,P8],'set_voltage_float':[PP,PS,U32,P8],
            'set_voltage':[PP,PS,U32,P8],'read_extended':[PP,P8],
            'decode_serial':[C.POINTER(Identity),P8],
            'decode_date':[C.c_uint16],'calibration_crc':[P8,U32,C.c_uint16],
            'initialize':[PP,PS,C.POINTER(Identity),I32,I32,U32,C.POINTER(InitOps),C.POINTER(InitScratch)]}.items():
            f=getattr(lib,'vn135_psu_'+name);f.argtypes=args;f.restype=C.c_int
    def init_setup(self,state=(34,0,0,0,0),mode=0,kind=0,address=16,
                   lower=10000,upper=15000,enabled=0,count=0,x=None,y=None):
        self.begin(mode,state,kind,address)
        initial=[1234.+i for i in range(15)]
        self.cal=Calibration(lower,upper,enabled,count,
            (C.c_double*15)(*(x if x is not None else initial)),
            (C.c_double*15)(*(y if y is not None else initial)))
    def calibration(self,fmt,data,**kw):
        self.init_setup(**kw);s=self.cal
        buf,p=storage(bytes(data));before=bytes(s)
        if fmt=='A':rc=self.lib.vn135_psu_load_calibration_a(C.byref(self.p),C.byref(s),p)
        else:rc=self.lib.vn135_psu_load_calibration_b(C.byref(s),p)
        assert bytes(s)[:Calibration.count.offset]==before[:Calibration.count.offset]
        guard(buf,len(data));assert C.string_at(p,len(data))==data
        return rc,(s.count,bytes(s.x)+bytes(s.y))
    def knots(self,fmt,count,**kw):
        self.init_setup(**kw)
        out=(C.c_double*16)();C.memset(out,0xa5,C.sizeof(out))
        if fmt=='A':rc=self.lib.vn135_psu_knots_raw(out,count&0xffffffff)
        else:rc=self.lib.vn135_psu_knots_voltage(C.byref(self.cal),out,count)
        return rc,bytes(out)
    def family(self,model):return self.lib.vn135_psu_model_family(model)
    def serial(self,data):
        identity=Identity(0x55667788,0x11223344,SERIAL_SEED);b,p=storage(bytes(data))
        rc=self.lib.vn135_psu_decode_serial(C.byref(identity),p)
        guard(b,len(data));assert C.string_at(p,len(data))==data
        assert identity.initial_word==0x55667788 and identity.date_word==0x11223344
        return rc,C.string_at(C.addressof(identity)+Identity.serial.offset,18)
    def crc(self,data,init):
        b,p=storage(bytes(data));rc=self.lib.vn135_psu_calibration_crc(p,len(data),init)
        guard(b,len(data));assert C.string_at(p,len(data))==data;return rc
    def date(self,value):return self.lib.vn135_psu_decode_date(value)

    def operation(self,op,request=12000,scenario=None,initial=None,**kw):
        self.init_setup(**kw);sc=scenario or {};runtime=BusScript(sc);rets=sc.get('returns',{})
        self.events=[];self.errors=[]
        def safe(fn):
            def call(*args):
                try:return fn(*args)
                except BaseException as e:self.errors.append(e);return -999
            return call
        def lock(_):self.events.append(('lock',));return rets.get('lock',0)
        def unlock(_):self.events.append(('unlock',));return rets.get('unlock',0)
        def delay(_,v):
            self.events.append(('delay',v))
            if v==400:runtime.new_attempt(self.p.checksum_mode)
            return rets.get('delay',0)
        def wb(_,a,m,r,p,n):
            runtime.tx=bytearray(C.string_at(p,n));self.events.append(('write_block',a,m,r,bytes(runtime.tx)))
            return rets.get('write',0)
        def rb(_,a,m,r,p,n):
            self.events.append(('read_block',a,m,r,n));chunk=runtime.response(n)
            if chunk is not None:C.memmove(p,chunk,len(chunk))
            return rets.get('read',0)
        def wy(_,a,m,r,v):
            self.events.append(('write_byte',a,m,r,v));runtime.write_byte(v);return rets.get('write',0)
        size=40 if op=='initialize' else 14 if op=='extended' else 8 if op in ('identify','raw') or op=='dispatch' and not self.p.checksum_mode else 10
        if op in ('initialize','extended'):runtime.full=True
        def ry(_,a,m,r):self.events.append(('read_byte',a,m,r));return runtime.read_byte(size)
        def log(_,line,a,b,p,n):self.events.append(('log',line,a,b,C.string_at(p,n) if n else b''))
        self.ops=Ops(LOCK(safe(lock)),LOCK(safe(unlock)),BLOCK(safe(wb)),BLOCK(safe(rb)),WRITE(safe(wy)),READ(safe(ry)),DELAY(safe(delay)),LOG(safe(log)))
        self.p.ops=C.pointer(self.ops)
        initial=bytes([0xa7]*size) if initial is None else initial
        assert len(initial)==size
        b,p=storage(initial);before=bytes(self.p);calbefore=bytes(self.cal)
        if op=='initialize':
            identity=Identity(0x55667788,0x11223344,SERIAL_SEED)
            scratch=InitScratch((U8*40)(*initial),(U8*14)(*([0xa9]*14)))
            def select(_,index):
                self.events.append(('select_bus',index));assert index==0;return kw.get('kind',0)
            def init(_):self.events.append(('mutex_init',));return rets.get('mutex_init',0)
            initops=InitOps(SELECT(safe(select)),LOCK(safe(init)))
            rc=self.lib.vn135_psu_initialize(C.byref(self.p),C.byref(self.cal),C.byref(identity),
                kw.get('lower',10000),kw.get('upper',15000),kw.get('mode',0),C.byref(initops),C.byref(scratch))
            assert not self.errors,self.errors
            return (rc,bytes(scratch.response),bytes(scratch.auxiliary),self.events,
                self.p.checksum_mode,self.p.voltage.model,self.p.voltage.word_08,self.p.address,
                identity.initial_word,identity.date_word,C.string_at(C.addressof(identity)+Identity.serial.offset,18),
                self.cal.enabled,(self.cal.count,bytes(self.cal.x)+bytes(self.cal.y)))
        elif op=='extended':rc=self.lib.vn135_psu_read_extended(C.byref(self.p),p)
        elif op=='identify':rc=self.lib.vn135_psu_identify_prefix(C.byref(self.p),p)
        else:
            name={'raw':'set_voltage_raw','float':'set_voltage_float','dispatch':'set_voltage'}[op]
            rc=getattr(self.lib,'vn135_psu_'+name)(C.byref(self.p),C.byref(self.cal),request,p)
            assert bytes(self.p)==before
        assert bytes(self.cal)==calbefore
        assert not self.errors,self.errors
        guard(b,size)
        return rc,C.string_at(p,size),self.events,self.p.checksum_mode,self.p.voltage.model

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library',type=Path);ap.add_argument('--summary',type=Path)
    args=ap.parse_args();o=SetupOracle();c=SetupNative(args.library);rng=random.Random(135103058);counts=Counter()
    def compare(group,method,*a,**kw):
        original=getattr(o,method)(*a,**kw);native=getattr(c,method)(*a,**kw)
        assert original==native,(group,a,kw,original,native)
        counts[group]+=1
    for n in (-2147483648,-1,0,1,*range(2,16)):
        for fmt in 'AB':
            for lo,hi in ((10000,15000),(15000,10000),(0,0),(-1,15000),(10000,-1),(2147483647,0)):
                compare('knots','knots',fmt,n,lower=lo,upper=hi)
    for n in (16,17,255,2147483647,4294967295):compare('knots','knots','A',n)
    for model in (*range(258),65535):compare('family','family',model)
    for fmt in 'AB':
        at=19 if fmt=='A' else 20
        for sentinel in range(15):
            for offset in (0,1,32767,32768,65535):
                for lo,hi in ((10000,15000),(15000,10000),(-1,15000)):
                    d=bytearray(rng.randbytes(40));d[at:at+14]=bytes(rng.choice([0,1,127,129,255]) for _ in range(14))
                    d[at-2:at]=struct.pack('>H',offset)
                    if sentinel<14:d[at+sentinel]=128
                    compare('calibration_'+fmt,'calibration',fmt,d,lower=lo,upper=hi,
                            state=(rng.choice([34,193,194,196,113,65535]),rng.choice([3,4]),rng.randrange(2),0,0))
    for op in ('raw','float','dispatch'):
        for mode in (0,1,2,4294967295):
            for kind in (0,1,2):
                for request in (0,9999,10000,12000,15000,15001,2147483647,2147483648,4294967295):
                    compare('set_basic','operation',op,request,mode=mode,kind=kind)
    for model in (*range(258),65535):
        compare('set_models','operation','raw',rng.randrange(10000,15001),state=(model,0,0,0,0))
    for model in (113,114,115,116,117,118,119,120,193,194,196):
        for word in (0,3,4,4294967295):
            for flag in (0,1,255):
                compare('set_models','operation','raw',rng.randrange(10000,15001),state=(model,word,flag,0,0))
    for sub in (0,1,2,3,65535):
        for active in (1,255):
            for enable in (0,1):
                compare('override','operation','raw',12345,state=(193,4,1,active,sub),enabled=enable,count=0)
    for op in ('raw','float','dispatch'):
        for n in (0,1,2,3,15):
            for mode in (0,1):
                for descending in (False,True):
                    yy=[10.+i*5/(max(n,2)-1) for i in range(15)]
                    if descending:yy[:n]=yy[:n][::-1]
                    xx=([250.-i*250/(max(n,2)-1) for i in range(15)] if op=='raw' or op=='dispatch' and not mode
                        else [10.1+i*4.8/(max(n,2)-1) for i in range(15)])
                    for req in (9999,10000,11001,12345,14999,15000,15001):
                        compare('interpolation','operation',op,req,mode=mode,enabled=1,count=n,x=xx,y=yy)
    for op in ('raw','float','dispatch'):
        for kind in (0,1):
            for mode in (0,1,2):
                for bad in (0,1,2,3,4):
                    compare('retries','operation',op,mode=mode,kind=kind,scenario={'bad_attempts':bad,'returns':{'write':-7,'read':-8,'lock':-9,'unlock':-10,'delay':-11}})
    for model in (*range(258),65535):
        compare('identify','operation','identify',scenario={'model':model})
    for mode in (0,1,2,4294967295):
        for kind in (0,1,2):
            for bad in (0,1,2,3,4,5,6):
                for targetmode in (0,1):
                    compare('identify_retry','operation','identify',mode=mode,kind=kind,scenario={'model':193,'hardware_mode':targetmode,'bad_attempts':bad})
    for init in (0,1,255,256,65535):
        for length in (0,1,2,3,7,12,30,31,32,127,255):
            compare('record_crc','crc',rng.randbytes(length),init)
    for first in (0,1,36**11-1,36**11,2**57-1,2**64-1):
        for second in (0,1,36**6-1,36**6,2**32-1):
            compare('serial','serial',struct.pack('>QI',first,second))
    for _ in range(128):compare('serial','serial',rng.randbytes(12))
    for date in sorted(set([0,1,30,31,32,371,372,373,65535]+[rng.randrange(65536) for _ in range(160)])):
        compare('date','date',date)
    for mode in (0,1,2,4294967295):
        for kind in (0,1,2):
            for value in (0,1,0x7fffffff,0x80000000,0xfffffffe,0xffffffff):
                compare('extended','operation','extended',mode=mode,kind=kind,scenario={'extended':value})
    supported=(34,65,66,67,97,98,100,101,102,103,105,106,113,114,115,116,117,118,119,120,193,194,196,197)
    for mode in (0,1,2,4294967295):
        for kind in (0,1,2):
            for model in (*supported,0,35,195,65535):
                compare('initializer_models','operation','initialize',mode=mode,kind=kind,enabled=1,count=7,
                    state=(34,0x55aa,1,0,0),address=77,scenario={'model':model})
    cases=[{}, {'bad_commands':[1]}, {'bad_commands':[6]}, {'bad_commands':[10,14]},
           {'extended':0xffffffff}, {'extended':0x80000000}, {'bad_record_crc':True},
           {'a':{'bad_record_crc':True}}, {'b':{'bad_record_crc':True}},
           {'a':{'sentinel':0}}, {'b':{'sentinel':0}}, {'sentinel':0},
           {'serial_first':36**11}, {'serial_second':36**6},
           {'a':{'serial_first':36**11}}, {'b':{'serial_second':36**6}},
           {'a':{'offset':65535,'delta':255},'b':{'offset':32767,'delta':127}},
           {'no_read':True}, {'returns':{'read':-5,'write':-6,'delay':-7,'lock':-8,'unlock':-9,'mutex_init':-10}}]
    for mode in (0,1,2):
        for kind in (0,1):
            for scenario in cases:
                for lo,hi in ((10000,15000),(-10000,15000)):
                    compare('initializer_failures','operation','initialize',mode=mode,kind=kind,enabled=1,count=7,
                        lower=lo,upper=hi,state=(34,3,1,0,0),scenario=scenario)
    for mode in (0,1,2,4294967295):
        for kind in (0,1):
            for bad in (1,2,3,4,5,6):
                for targetmode in (0,1):
                    compare('initializer_fallback','operation','initialize',mode=mode,kind=kind,
                        scenario={'hardware_mode':targetmode,'bad_attempts':bad})
    # Feed actual transformed tables, not invented monotonic fixtures, into
    # the original setter. Both transformations and setters run as ARM code.
    for fmt in 'AB':
        at=19 if fmt=='A' else 20
        for n in (2,3,9,15):
            data=bytearray(40);data[at-2:at]=b'\x00\x0a'
            if n<15:data[at+n-1]=128
            for model in (34,113,193,194,196):
                opts={'state':(model,4,0,0,0)}
                aa=o.calibration(fmt,data,**opts);bb=c.calibration(fmt,data,**opts);assert aa==bb
                arrays=struct.unpack('<30d',aa[1][1]);opts.update(enabled=1,count=n,x=arrays[:15],y=arrays[15:])
                for req in (10000,12345,15000):
                    compare('loaded_table_to_setter','operation','raw' if fmt=='A' else 'float',req,**opts)
    print('PSU_SETUP_ORIGINAL_PASS',dict(counts),'total=',sum(counts.values()))
    if args.summary:args.summary.write_text(json.dumps({'comparisons':dict(counts),'total':sum(counts.values()),'physical_hardware':False,'full_initializer_control_flow':True,'external_io':'scripted RAM','compiler_udiv64':'explicit arithmetic hook','hardware_driver':False},indent=2)+'\n')
if __name__=='__main__':main()
