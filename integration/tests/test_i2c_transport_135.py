#!/usr/bin/env python3
"""Compare selected original A32 I2C procedures with the C translation.
Only libc/syscall/log boundaries are scripted. No firmware or device process.
"""
from __future__ import annotations
import ctypes as C
import hashlib
import json
from pathlib import Path
import random
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
from arm32_subset import signed
MASK=0xffffffff
G=0x68c180; P=0x841000; BUF=0x842001; NAME=0x843000; HEAP=0x844000; ERR=0x845000
ENTRY={'close':0x125c64,'open':0x125cf4,'read':0x11a6b0,'write':0x11ab24,'exchange':0x10560c}
RANGES=[(0x125c64,0x125e74),(0x11a6b0,0x11af60),
        (0xfe528,0xfe548),(0x102bd0,0x102ec0),(0x10560c,0x105938)]
class CheckedARM(ARM32Verify):
    def extra_instruction(self,w,pc):
        if not any(a<=pc<b for a,b in RANGES):
            raise AssertionError(f'unexpected instruction {pc:x}')
        return super().extra_instruction(w,pc)
class IFace(C.Structure):
    _fields_=[('fd',C.c_int32)]
I=C.c_int32; U=C.c_uint32; V=C.c_void_p; B=C.POINTER(C.c_uint8)
LOCK=C.CFUNCTYPE(I,V,C.POINTER(IFace)); OPEN=C.CFUNCTYPE(I,V,C.c_char_p,U)
CLOSE=C.CFUNCTYPE(I,V,I); IOCTL=C.CFUNCTYPE(I,V,I,U,U)
IO=C.CFUNCTYPE(I,V,I,B,U); SLEEP=C.CFUNCTYPE(I,V,U)
ERRNO=C.CFUNCTYPE(I,V); TEXT=C.CFUNCTYPE(V,V,I)
ALLOC=C.CFUNCTYPE(V,V,U,U); FREE=C.CFUNCTYPE(None,V,V)
LOG=C.CFUNCTYPE(None,V,I,U,U,U,U,C.c_char_p)
class Ops(C.Structure):
    _fields_=[('lock',LOCK),('unlock',LOCK),('open',OPEN),('close',CLOSE),
              ('ioctl',IOCTL),('write',IO),('read',IO),('sleep',SLEEP),
              ('errno',ERRNO),('text',TEXT),('calloc',ALLOC),('free',FREE),('log',LOG)]
class Context(C.Structure):
    _fields_=[('global_',C.POINTER(IFace)),('ops',C.POINTER(Ops)),('opaque',V)]
# Exact typed header shared with previous five recovered PSU procedures.
class Voltage(C.Structure):
    _fields_=[('model',C.c_uint16),('word_08',U),('byte_1c',C.c_uint8),
              ('byte_130',C.c_uint8),('word_132',C.c_uint16)]
PL=C.CFUNCTYPE(I,V); BLOCK=C.CFUNCTYPE(I,V,C.c_uint8,U,C.c_uint8,B,U)
WB=C.CFUNCTYPE(I,V,C.c_uint8,U,C.c_uint8,U); RB=C.CFUNCTYPE(I,V,C.c_uint8,U,C.c_uint8)
PLOG=C.CFUNCTYPE(None,V,U,U,U,B,U)
class PsuOps(C.Structure):
    _fields_=[('lock',PL),('unlock',PL),('write_block',BLOCK),('read_block',BLOCK),
              ('write_byte',WB),('read_byte',RB),('delay',SLEEP),('log',PLOG)]
class Psu(C.Structure):
    _fields_=[('mode',U),('kind',U),('address',C.c_uint8),('voltage',Voltage),
              ('ops',C.POINTER(PsuOps)),('opaque',V)]
libc=C.CDLL(None)
libc.calloc.argtypes=[C.c_size_t,C.c_size_t];libc.calloc.restype=V
libc.free.argtypes=[V];libc.free.restype=None

class Stimulus:
    def __init__(self,case):
        self.c=case; self.trace=[]; self.count={};self.error=case.get('errno',5)
        self.live=set();self.snapshot=lambda:None
    def result(self,key,default):
        i=self.count.get(key,0);self.count[key]=i+1
        entries=self.c.get(key,[])
        return entries[i] if i<len(entries) else default
    def event(self,*args):self.trace.append((args,self.snapshot()))
    def lock(self,identity,unlock=False):
        key='unlock' if unlock else 'lock';self.event(key,identity)
        return self.result(key,0)
    def open(self,name,flags):
        self.event('open',name,flags);return self.result('open_rc',29)
    def close(self,fd):self.event('close',fd);return self.result('close_rc',0)
    def ioctl(self,fd,req,arg):
        self.event('ioctl',fd,req,arg);return self.result('ioctl_rc',0)
    def write(self,fd,data):
        self.event('write',fd,data.hex());return self.result('write_rc',len(data))
    def read(self,fd,old):
        entry=self.result('read_result',None)
        if entry is None:rc=len(old);prefix=bytes((i*29+7)&255 for i in range(len(old)))
        else:rc,prefix=entry
        assert len(prefix)<=len(old)
        new=prefix+old[len(prefix):]
        self.event('read',fd,len(old),old.hex(),new.hex(),rc)
        return rc,new
    def sleep(self,n):self.event('sleep_us',n);return self.result('sleep_rc',0)
    def errno(self):self.event('errno');return self.error
    def text(self,error):self.event('strerror',error);return b'scripted-error'
    def alloc(self,n,size):
        self.event('calloc',n,size)
        return not self.result('alloc_fail',False)
    def free(self):self.event('free')
    def log(self,source,line,a=0,b=0,c=0,text=None):
        self.event('log',source,line,a&MASK,b&MASK,c&MASK,text)

def original(elf,case):
    s=Stimulus(case);m=CheckedARM(elf);p=G if case['alias'] else P
    m.write(0x5dfbe8,G)
    # Decode only verified literal bytes; no constructor/process execution.
    for addr,key,text in [(0x5ee422,65,b'/dev/i2c-1'),(0x5ef3b9,38,b'/dev/')]:
        raw=elf.read(addr,len(text)+1)
        assert bytes(x^key for x in raw)==text+b'\0'
        m.mem[addr:addr+len(raw)]=text+b'\0'
    for x in (G,P):m.mem[x:x+64]=bytes([0x53])*64
    m.write(G+36,case['gfd']);m.write(P+36,case['pfd'])
    s.snapshot=lambda:(signed(m.read(G+36)),signed(m.read(p+36)))
    ident=lambda x:'psu' if x==0x840000 else 'global' if x==G else 'other' if x==P else (_ for _ in ()).throw(AssertionError(hex(x)))
    def string(x):
        assert x;end=m.mem.index(0,x,x+4096);return bytes(m.mem[x:end])
    def ret(f):
        def hook(cpu):cpu.r[0]=f(cpu)&MASK
        return hook
    def reading(cpu):
        fd,ptr,n=cpu.r[:3];old=bytes(cpu.mem[ptr:ptr+n]);rc,new=s.read(signed(fd),old)
        cpu.check(ptr,n);cpu.mem[ptr:ptr+n]=new;return rc
    def alloc(cpu):
        n,size=cpu.r[:2]
        if not s.alloc(n,size):return 0
        assert n*size<4096 and HEAP not in s.live
        s.live.add(HEAP);cpu.mem[HEAP:HEAP+n*size]=bytes(n*size);return HEAP
    def free(cpu):
        assert cpu.r[0] in s.live;s.live.remove(cpu.r[0]);s.free();return 0
    def memcpy(cpu):
        d,src,n=cpu.r[:3];cpu.check(d,n);cpu.check(src,n)
        cpu.mem[d:d+n]=bytes(cpu.mem[src:src+n]);return d
    dumps={}
    def fmt(cpu):
        dest,cap,ptr,n=cpu.r[:4]
        assert cap==1024 and n<=257
        dumps[dest]=bytes(cpu.mem[ptr:ptr+n]);return 0
    def delay_ms(cpu):
        assert cpu.r[0] in (100,400)
        s.event('delay_ms',cpu.r[0]);return -1
    def log(cpu):
        line=cpu.r[3];sp=cpu.r[13]
        get=lambda off:cpu.read(sp+off)
        if line==67:s.log(0,line,text=string(get(8)))
        elif line in (49,207,262,271,295):s.log(1,line)
        elif line in (215,242,301):s.log(1,line,get(8),get(12))
        elif line in (224,284):s.log(1,line,get(8),get(12),get(20),string(get(16)))
        elif line==232:s.log(1,line,get(8))
        elif line in (937,939):s.event('psu_log',line,0,0,dumps[get(8)].hex())
        elif line==951:s.event('psu_log',line,0,0,'')
        elif line==957:s.event('psu_log',line,get(8),get(12),'')
        else:raise AssertionError(f'unknown log {line}')
        return 0
    def errno(cpu):cpu.write(ERR,s.errno());return ERR
    def error_text(cpu):
        text=s.text(signed(cpu.r[0]));cpu.mem[ERR+16:ERR+16+len(text)+1]=text+b'\0';return ERR+16
    hooks={0x5a6108:ret(lambda q:s.lock(ident(q.r[0]))),
           0x5a66c4:ret(lambda q:s.lock(ident(q.r[0]),True)),
           0x5936dc:ret(lambda q:s.open(string(q.r[0]),q.r[1])),
           0x5a811c:ret(lambda q:s.close(signed(q.r[0]))),
           0x597550:ret(lambda q:s.ioctl(signed(q.r[0]),q.r[1],q.r[2])),
           0x5a8684:ret(lambda q:s.write(signed(q.r[0]),bytes(q.mem[q.r[1]:q.r[1]+q.r[2]]))),
           0x5a8498:ret(reading),0x5a85e4:ret(lambda q:s.sleep(q.r[0])),
           0x5931e4:ret(errno),0x593224:ret(error_text),0x593bb4:ret(alloc),
           0x593c8c:ret(free),0x5a2ee8:ret(memcpy),0xfa0c4:ret(log),
           0x5a40bc:ret(lambda q:0 if string(q.r[0])==string(q.r[1]) else 1)}
    data=case['data'];m.mem[BUF-1:BUF+len(data)+1]=b'\x9d'+data+b'\x63'
    name=case.get('path',b'/dev/i2c-1');m.mem[NAME:NAME+len(name)+1]=name+b'\0'
    op=case['op']
    args=(p+36,NAME) if op=='open' else (p+36,) if op=='close' else (p,case['addr'],case['mode'],case['reg'],BUF,len(data))
    if op=='exchange':
        m.write(0x654ba0,ENTRY['write']);m.write(0x654b9c,ENTRY['read'])
        m.write(0x654c30+12,case['mode']);m.write(0x840000+24,p)
        tx=case['tx'];m.mem[0x846000:0x846000+len(tx)]=tx
        args=(0x840000,0x846000,len(tx),BUF,len(data))
        hooks.update({0x10ed2c:ret(delay_ms),0x10f170:ret(fmt)})
    m.reset(args);rc=signed(m.run(ENTRY[op],hooks=hooks,max_steps=16000))
    assert not s.live
    assert m.mem[BUF-1]==0x9d and m.mem[BUF+len(data)]==0x63
    return rc,s.snapshot(),bytes(m.mem[BUF:BUF+len(data)]),s.trace

def native(lib,case):
    s=Stimulus(case);g=IFace(case['gfd']);other=IFace(case['pfd'])
    p=g if case['alias'] else other
    s.snapshot=lambda:(g.fd,p.fd)
    ident=lambda ptr:'global' if C.addressof(ptr.contents)==C.addressof(g) else 'other'
    text=C.create_string_buffer(b'scripted-error')
    def reading(_,fd,ptr,n):
        rc,new=s.read(fd,C.string_at(ptr,n));C.memmove(ptr,new,n);return rc
    def alloc(_,n,size):
        if not s.alloc(n,size):return None
        a=libc.calloc(n,size);assert a;s.live.add(a);return a
    def free(_,ptr):
        assert ptr in s.live;s.live.remove(ptr);s.free();libc.free(ptr)
    def error_text(_,e):s.text(e);return C.addressof(text)
    callbacks=[LOCK(lambda _,p:s.lock(ident(p))),LOCK(lambda _,p:s.lock(ident(p),True)),
        OPEN(lambda _,n,f:s.open(n,f)),CLOSE(lambda _,fd:s.close(fd)),
        IOCTL(lambda _,fd,req,arg:s.ioctl(fd,req,arg)),
        IO(lambda _,fd,p,n:s.write(fd,C.string_at(p,n))),IO(reading),
        SLEEP(lambda _,n:s.sleep(n)),ERRNO(lambda _:s.errno()),TEXT(error_text),
        ALLOC(alloc),FREE(free),LOG(lambda _,src,line,a,b,c,t:s.log(src,line,a,b,c,t))]
    ops=Ops(*callbacks);ctx=Context(C.pointer(g),C.pointer(ops),None)
    data=case['data'];buf=(C.c_uint8*(len(data)+2)).from_buffer_copy(b'\x9d'+data+b'\x63')
    ptr=C.cast(C.byref(buf,1),B)
    op=case['op']
    if op=='exchange':
        pcb=[PL(lambda _:s.lock('psu')),PL(lambda _:s.lock('psu',True)),
             BLOCK(lambda _,a,m,r,b,n:lib.vn135_aml_i2c_write_block(C.byref(ctx),C.byref(p),a,m,r,b,n)),
             BLOCK(lambda _,a,m,r,b,n:lib.vn135_aml_i2c_read_block(C.byref(ctx),C.byref(p),a,m,r,b,n)),
             WB(lambda *a:-1),RB(lambda *a:-1),
             SLEEP(lambda _,n:(s.event('delay_ms',n),-1)[1]),
             PLOG(lambda _,line,a,b,d,n:s.event('psu_log',line,a,b,C.string_at(d,n).hex() if n else ''))]
        pops=PsuOps(*pcb);psu=Psu(case['mode'],0,16,Voltage(),C.pointer(pops),None)
        tx=(C.c_uint8*len(case['tx'])).from_buffer_copy(case['tx'])
        fn=lib.vn135_psu_exchange_block
        fn.argtypes=[C.POINTER(Psu),B,U,B,U];fn.restype=I
        rc=fn(C.byref(psu),tx,len(tx),ptr,len(data))
        assert not s.live and buf[0]==0x9d and buf[-1]==0x63
        return rc,s.snapshot(),bytes(buf)[1:-1],s.trace
    prefix='vn135_i2c_hw_' if op in ('open','close') else 'vn135_aml_i2c_'
    fn=getattr(lib,prefix+op+('_block' if op in ('read','write') else ''))
    if op=='open':rc=fn(C.byref(ctx),C.byref(p),case.get('path',b'/dev/i2c-1'))
    elif op=='close':rc=fn(C.byref(ctx),C.byref(p))
    else:rc=fn(C.byref(ctx),C.byref(p),case['addr'],case['mode'],case['reg'],ptr,len(data))
    assert not s.live and buf[0]==0x9d and buf[-1]==0x63
    return rc,s.snapshot(),bytes(buf)[1:-1],s.trace

def cases():
    rng=random.Random(135119)
    base=dict(alias=True,gfd=17,pfd=41,data=b'\x81\x92\xa3\xb4',addr=16,mode=1,reg=0x11)
    for op in ('open','close'):
        for alias in (False,True):
            for fd in (-2147483648,-2,-1,0,17,2147483647):
                for path in (b'/dev/',b'/dev/i2c-1',b'',b'/dev/i2c-0'):
                    yield dict(base,op=op,alias=alias,gfd=fd,pfd=fd,path=path,
                        open_rc=[fd],close_rc=[-1])
    for op in ('read','write'):
        for alias in (False,True):
            for mode in (0,1,2,MASK):
                for n in (0,1,2,6,8,33,255,257):
                    common=dict(base,op=op,alias=alias,mode=mode,
                        data=bytes(rng.randrange(256) for _ in range(n)),reg=rng.getrandbits(32),addr=rng.getrandbits(32))
                    yield common
                    for failure in range(5):
                        yield dict(common,ioctl_rc=[-1]*failure+[0])
                        yield dict(common,write_rc=[-1]*failure)
                        if op=='read':yield dict(common,read_result=[(-1,b'')]*failure)
                    yield dict(common,ioctl_rc=[-1]*5)
                    yield dict(common,ioctl_rc=[-2]*5,lock=[-1,-2],unlock=[-3,-4],sleep_rc=[-1]*5)
                    yield dict(common,write_rc=[-1]*5)
                    yield dict(common,open_rc=[-1]);yield dict(common,open_rc=[-2])
                    if op=='write' and mode:yield dict(common,alloc_fail=[True])
                    if op=='read' and n:
                        yield dict(common,read_result=[(1,b'Z')]+[(-1,b'')]*4)
                        yield dict(common,read_result=[(n+1,b'')]*5)
                    if op=='write' and n:yield dict(common,write_rc=[max(0,n-1)]*5)
    # Mixed failures with explicit read side effects, equal and distinct ifaces.
    for _ in range(200):
        n=rng.randrange(1,128)
        yield dict(base,op=rng.choice(('read','write')),alias=bool(rng.getrandbits(1)),
            mode=rng.choice((0,1,2,MASK)),reg=rng.getrandbits(32),addr=rng.getrandbits(32),
            data=bytes(rng.randrange(256) for _ in range(n)),
            ioctl_rc=[rng.choice((-1,-2,0,1)) for _ in range(5)],
            write_rc=[rng.choice((-1,0,1,n,n+1)) for _ in range(5)],
            read_result=[(rng.choice((-1,0,n)),bytes([i])*rng.randrange(n+1)) for i in range(5)])

def exchange_cases():
    def reply(mode,raw):
        r=bytearray.fromhex('55 aa 06 03 00 00 00 00');r[4:6]=raw.to_bytes(2,'little')
        total=sum(r[2:6]) if not mode else int.from_bytes(r[2:4],'little')+raw
        r[6:8]=(total&65535).to_bytes(2,'little');return bytes(r)
    for alias in (False,True):
      for mode in (0,1,2,MASK):
        good=reply(mode,81);bad=bytes(8)
        base=dict(op='exchange',alias=alias,gfd=17,pfd=41,addr=16,mode=mode,reg=17,
                  data=bad,tx=bytes.fromhex('55 aa 04 03 07 00'))
        # Real original and C PSU validators execute; success is never injected.
        yield dict(base,read_result=[(8,good)])
        for failed in range(16):
            yield dict(base,ioctl_rc=[-1]*failed,read_result=[(8,good)]*3)
            yield dict(base,write_rc=[-1]*failed,read_result=[(8,good)]*3)
            yield dict(base,read_result=[(-1,b'')]*failed+[(8,good)]*3)
        for delay in range(3):
            yield dict(base,read_result=[(8,bad)]*delay+[(8,good)])
        # Stale checksum-valid scratch can pass after failed new reads/reopens.
        yield dict(base,data=good,read_result=[(-1,b'')]*15)
        yield dict(base,data=good,open_rc=[-1]*6)
        yield dict(base,open_rc=[-1]*6)
        yield dict(base,alloc_fail=[True]*3,read_result=[(8,good)]*3)
        yield dict(base,read_result=[(1,good[:1])]+[(-1,b'')]*14)


def main():
    if len(sys.argv)!=2:raise SystemExit('usage: test_i2c_transport_135.py SHARED_LIBRARY')
    evidence=json.loads((ROOT/'integration/evidence/i2c_transport_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256']
    for r in evidence['ranges']:
        assert hashlib.sha256(elf.read(int(r['start'],16),int(r['end'],16)-int(r['start'],16))).hexdigest()==r['sha256']
    for r in evidence['strings']:
        assert bytes(x^r['xor'] for x in elf.read(int(r['address'],16),len(r['text'])+1))==r['text'].encode()+b'\0'
    lib=C.CDLL(str(Path(sys.argv[1]).resolve()))
    for op in ('open','close'):
        f=getattr(lib,'vn135_i2c_hw_'+op);f.restype=I
        f.argtypes=[C.POINTER(Context),C.POINTER(IFace)]+([C.c_char_p] if op=='open' else [])
    for op in ('read','write'):
        f=getattr(lib,'vn135_aml_i2c_'+op+'_block');f.restype=I
        f.argtypes=[C.POINTER(Context),C.POINTER(IFace),U,U,U,B,U]
    counts={}
    from itertools import chain
    for count,c in enumerate(chain(cases(),exchange_cases()),1):
        a=original(elf,c);b=native(lib,c)
        if a!=b:
            print('FAIL',count,c,'\nORIGINAL',a,'\nC',b);raise SystemExit(1)
        counts[c['op']]=counts.get(c['op'],0)+1
    print('I2C135_ORIGINAL_PASS',json.dumps(counts,sort_keys=True),'total='+str(count),'physical_i2c=no')
if __name__=='__main__':main()
