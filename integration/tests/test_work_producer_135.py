#!/usr/bin/env python3
"""Bounded original c2498 batch against C, original SHA and swap instructions run."""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import random
import struct
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_rebuild_subset import ARM32Rebuild

REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
RING=0x633bf0;ROW0=RING+32;ROWS=768*168
BACK=0x840000;COIN=0x842000;BRANCH=0x844000;HEAP=0x846000
U,B,Q,P=C.c_uint32,C.c_uint8,C.c_uint64,C.c_void_p
class Template(C.Structure):
    _fields_=[('key',U),('header',B*44),('coinbase',P),('size',U),('offset',U),('width',U),('branches',P),('count',U)]
class Ring(C.Structure):_fields_=[('head',U),('tail',U),('rows',P)]
class View(C.Structure):_fields_=[('job',C.POINTER(Template)),('ring',C.POINTER(Ring)),('counter',C.POINTER(Q)),('backend',P)]
COUNT=C.CFUNCTYPE(U,P,P);SYNC=C.CFUNCTYPE(C.c_int32,P,U,U);ALLOC=C.CFUNCTYPE(P,P,U);FREE=C.CFUNCTYPE(None,P,P)
class Ops(C.Structure):_fields_=[('count',COUNT),('sync',SYNC),('allocate',ALLOC),('release',FREE)]
def digest(x):return hashlib.sha256(x).hexdigest()
def dsha(x):return hashlib.sha256(hashlib.sha256(x).digest()).digest()

class Machine(ARM32Rebuild):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in [(0xc2970,0xc2e80),(0x108b7c,0x109740),(0x10f64c,0x10f6b0)]),('unexpected',hex(pc))
        self.visited.add(pc)
        if pc==0xc2b80:
            # Only new opcode: UMULL r1,r2,r0,r1; no flags or input clobber first.
            assert w==0xe0821190
            product=self.r[0]*self.r[1];self.r[1],self.r[2]=product&0xffffffff,product>>32
            return True
        if pc==0x108f38:
            self.sha_inputs.append(bytes(self.mem[self.r[0]:self.r[0]+self.r[1]]))
        return super().extra_instruction(w,pc)

def check_umull(m):
    vectors=[(0,0,0,0),(1,0xffffffff,0xffffffff,0),(0xffffffff,0xffffffff,1,0xfffffffe),
             (0x80000000,2,0,1),(0x10000,0x10000,0,1),(768,0xaaaaaaab,256,512)]
    for a,b,lo,hi in vectors:
        m.reset();m.visited=set();m.r[0:3]=[a,b,0x12345678];m.n,m.z,m.c,m.v=True,False,True,False
        assert m.extra_instruction(0xe0821190,0xc2b80)
        assert m.r[:3]==[a,lo,hi] and (m.n,m.z,m.c,m.v)==(True,False,True,False)

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.calls=collections.Counter();self.keep=[];self.errors=[];self.allocations=[]
        self.seed=p.get('seed',0);self.header=bytes((17*i+self.seed)&255 for i in range(44))
        self.coin=bytes((29*i+self.seed)&255 for i in range(p.get('size',73)))
        self.branch_count=p.get('branches',2);self.branches=bytes((37*i+self.seed)&255 for i in range(max(self.branch_count,0)*32))
        self.cb=C.create_string_buffer(self.coin,max(1,len(self.coin)));self.br=C.create_string_buffer(self.branches,max(1,len(self.branches)))
        self.storage=C.create_string_buffer(ROWS+32);self.heap=C.create_string_buffer(len(self.coin)+32)
        self.template=Template(p.get('key',0x12345678),(B*44).from_buffer_copy(self.header),C.addressof(self.cb),len(self.coin),p.get('offset',13),p.get('width',8),C.addressof(self.br),self.branch_count&0xffffffff)
        self.counter=Q(p.get('counter',0xfffffffe));self.ring=Ring(p.get('head',40),p.get('tail',0),C.addressof(self.storage)+16)
        self.view=View(C.pointer(self.template),C.pointer(self.ring),C.pointer(self.counter),BACK)
        self.initial_rows=bytes((i*7+i//168+self.seed)&255 for i in range(ROWS))
        C.memmove(self.ring.rows,self.initial_rows,ROWS);C.memset(self.storage,0xa5,16);C.memset(self.ring.rows+ROWS,0x5a,16)
        self.saved_template=bytes(self.template)
        if m:
            m.reset();m.visited=set();m.sha_inputs=[]
            # Original prologue: push36, fp=old_sp-8, sub sp380.
            sp=m.STACK_TOP-416;fp=m.STACK_TOP-8;self.sp=sp;self.local=fp-152
            m.r[13]=sp;m.r[11]=fp;m.r[4]=RING;m.r[5]=sp+160;m.r[10]=sp+52
            for off,value in [(8,BACK),(36,self.local+12),(20,sp+192),(44,self.counter.value>>32),(48,self.counter.value&0xffffffff),
                              (120,self.counter.value&0xffffffff),(124,self.counter.value>>32)]:m.write(sp+off,value)
            m.write(self.local,self.template.key);m.mem[self.local+8:self.local+52]=self.header
            for off,value in [(64,self.template.offset),(68,self.template.width),(72,COIN),(76,len(self.coin)),(80,BRANCH),(84,self.template.count)]:m.write(self.local+off,value)
            m.mem[COIN:COIN+len(self.coin)]=self.coin;m.mem[BRANCH:BRANCH+len(self.branches)]=self.branches
            m.mem[RING:ROW0+ROWS+16]=b'\xa5'*(32+ROWS+16);m.mem[ROW0:ROW0+ROWS]=self.initial_rows
            m.write(RING+24,self.ring.head);m.write(RING+28,self.ring.tail)
            # Both opaque parity globals used by this worker. No branch is patched.
            for pc,lit in [(0xc2980,0xc2f20),(0xc2b50,0xc2f24),(0xc2b88,0xc2f28),(0xc2bb0,0xc2f2c),
                           (0xc2e7c,0xc2f30),(0xc2c04,0xc2f34),(0xc2c2c,0xc2f38),(0xc2c90,0xc2f3c),
                           (0xc2da0,0xc2f40),(0xc2b30,0xc2f48),(0xc2d0c,0xc2f68)]:
                target=m.read((pc+8+m.read(lit))&0xffffffff)
                m.write(target,p.get('opaque',0xffffffff))
        for k,v in p.get('initial',[]):self.mutate(k,v)
    def rows(self):return bytes(self.m.mem[ROW0:ROW0+ROWS]) if self.m else C.string_at(self.ring.rows,ROWS)
    def snapshot(self):
        if self.m:return (self.m.read(RING+24),self.m.read(RING+28),self.m.read(self.sp+48)|(self.m.read(self.sp+44)<<32),digest(self.rows()))
        return (self.ring.head,self.ring.tail,self.counter.value,digest(self.rows()))
    def mutate(self,k,v):
        if k in ('head','tail'):
            if self.m:self.m.write(RING+(24 if k=='head' else 28),v)
            else:setattr(self.ring,k,v)
        elif k=='row_byte':
            at,value=v
            if self.m:self.m.write(ROW0+at,value,1)
            else:C.c_uint8.from_address(self.ring.rows+at).value=value
        else:raise AssertionError(k)
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1
        assert sum(self.calls.values())<20000,'callback budget exceeded'
        self.events.append((name,*args,self.snapshot()))
        for at,index,k,v in self.p.get('mutations',[]):
            if (at,index)==(name,n):self.mutate(k,v)
        return self.p.get('rc',-17)
    def allocate(self,size):
        assert size==len(self.coin);self.event('allocate',size)
        at=HEAP if self.m else C.addressof(self.heap)+16
        if self.m:self.m.mem[at-16:at+size+16]=b'\xa5'*16+b'\xcc'*size+b'\x5a'*16
        else:C.memset(self.heap,0xa5,16);C.memset(at,0xcc,size);C.memset(at+size,0x5a,16)
        self.allocations.append(self.snapshot()[2]);return at
    def release(self,at):
        assert at==(HEAP if self.m else C.addressof(self.heap)+16)
        data=bytes(self.m.mem[at:at+len(self.coin)]) if self.m else C.string_at(at,len(self.coin))
        self.event('release',data.hex())
        before=bytes(self.m.mem[at-16:at]) if self.m else C.string_at(at-16,16)
        after=bytes(self.m.mem[at+len(self.coin):at+len(self.coin)+16]) if self.m else C.string_at(at+len(self.coin),16)
        assert before==b'\xa5'*16 and after==b'\x5a'*16,'heap guard changed'
    def verify(self):
        if self.m:
            assert bytes(self.m.mem[COIN:COIN+len(self.coin)])==self.coin
            assert bytes(self.m.mem[BRANCH:BRANCH+len(self.branches)])==self.branches
            assert self.m.mem[RING:RING+24]==b'\xa5'*24 and self.m.mem[ROW0+ROWS:ROW0+ROWS+16]==b'\xa5'*16
            expected=[]
            for counter in self.allocations:
                cb=bytearray(self.coin);cb[self.template.offset:self.template.offset+self.template.width]=counter.to_bytes(8,'little')[:self.template.width]
                expected += [bytes(cb),hashlib.sha256(cb).digest()];root=dsha(cb)
                for i in range(max(0,self.branch_count)):
                    pair=root+self.branches[i*32:i*32+32];expected += [pair,hashlib.sha256(pair).digest()];root=dsha(pair)
            assert self.m.sha_inputs==expected,'original SHA call input/order mismatch'
        else:
            assert bytes(self.template)==self.saved_template and bytes(self.cb)[:len(self.coin)]==self.coin and bytes(self.br)[:len(self.branches)]==self.branches
            assert C.string_at(self.storage,16)==b'\xa5'*16 and C.string_at(self.ring.rows+ROWS,16)==b'\x5a'*16

def original(p,m):
    w=World(p,m)
    def count(_):assert m.r[0]==BACK;w.event('count');m.r[0]=p.get('count',2)&0xffffffff
    def sync(_):assert m.r[0]==RING;m.r[0]=w.event('lock' if m.r[15]==0x5a6108 else 'unlock')&0xffffffff
    def allocate(_):m.r[0]=w.allocate(m.r[0])
    def release(_):w.release(m.r[0]);m.r[0]=0
    def copy(_):
        dst,src,n=m.r[:3];m.check(dst,n);m.check(src,n);m.mem[dst:dst+n]=bytes(m.mem[src:src+n]);m.r[0]=dst
    def fill(_):
        dst,value,n=m.r[:3];m.check(dst,n);m.mem[dst:dst+n]=bytes([value&255])*n;m.r[0]=dst
    m.run(0xc2970,stop=0xc2e80,hooks={0x5ccf4:count,0x5a6108:sync,0x5a66c4:sync,0x5940ec:allocate,0x593c8c:release,
                                      0x5a2ee8:copy,0x5a348c:fill},max_steps=12000000)
    w.verify();return w

def native(p,lib):
    w=World(p)
    def cb(typ,fn):
        def f(*args):
            try:return fn(*args)
            except BaseException as e:w.errors.append(e);w.ring.head=768;return 0
        out=typ(f);w.keep.append(out);return out
    def count(_,backend):assert backend==BACK;w.event('count');return p.get('count',2)&0xffffffff
    def sync(_,entry,identity):assert identity==RING and entry in (0x5a6108,0x5a66c4);return w.event('lock' if entry==0x5a6108 else 'unlock')
    ops=Ops(cb(COUNT,count),cb(SYNC,sync),cb(ALLOC,lambda _,n:w.allocate(n)),cb(FREE,lambda _,at:w.release(at)))
    f=lib.vn135_work_producer_batch_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=None
    f(C.byref(w.view),C.byref(ops),None)
    if w.errors:raise w.errors[0]
    w.verify();return w

def cases():
    yield {}
    for count in (0,1,2,3,8,0xffffffff,0x80000000,0x40000000,0x7fffffff):yield {'count':count}
    for head,tail in itertools.product((0,1,766,767,768,0xfffffffe,0xffffffff),(0,1,767,768,0xffffffff)):
        yield {'head':head,'tail':tail,'count':2}
    for size in (0,1,7,8,31,32,55,56,63,64,65,119,120,127,128,129,255):
        for width in (0,1,4,8):
            if width<=size:yield {'size':size,'width':width,'offset':size-width,'count':1}
    for counter in (0,1,0xffffffff,0x100000000,0xfffffffffffffffe,0xffffffffffffffff):
        for width in range(9):yield {'counter':counter,'width':width,'count':2}
    for branches in (-2147483648,-1,0,1,2,3,7):yield {'branches':branches,'count':1}
    for head in range(768):
        if head%17==0 or head>=764:yield {'head':head,'tail':(head+2)%768,'count':4,'branches':0}
    for at,n in [('count',0),('lock',0),('unlock',0),('lock',1),('unlock',1),('allocate',0),('release',0),('lock',2),('unlock',2)]:
        for key,value in [('head',0),('head',767),('head',768),('head',0xffffffff),('tail',41),('row_byte',[40*168+67,0xed])]:
            yield {'mutations':[(at,n,key,value)],'count':2}
    for rc in (-2147483648,-1,0,1,2147483647):yield {'rc':rc,'count':1}
    rng=random.Random(0xc2498)
    for _ in range(75):
        size=rng.randrange(8,170);width=rng.randrange(9)
        yield {'size':size,'width':width,'offset':rng.randrange(size-width+1),'branches':rng.randrange(4),'seed':rng.randrange(256),
               'counter':rng.getrandbits(64),'head':rng.randrange(768),'tail':rng.randrange(768),'count':rng.randrange(1,4),'opaque':rng.getrandbits(32)}

def run(lib,quick=False):
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert digest(elf.data)==REF
    m=Machine(elf);check_umull(m);events=rows=steps=0;visited=set();params=list(cases())
    if quick:params=params[:48]+params[-5:]+[p for p in params if 'mutations' in p]
    for i,p in enumerate(params,1):
        a=original(p,m);b=native(p,lib)
        assert a.events==b.events,('MISMATCH events',i,p,next(((x,y) for x,y in itertools.zip_longest(a.events,b.events) if x!=y),None))
        assert a.snapshot()==b.snapshot() and a.rows()==b.rows(),('MISMATCH final',i,p)
        events+=len(a.events);rows+=len(a.allocations);steps+=m.steps;visited.update(m.visited)
    print(f'WORK_PRODUCER_ORIGINAL_PASS cases={len(params)} rows={rows} events={events} steps={steps} pcs={len(visited)} umull_vectors=6')

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    run(C.CDLL(str(Path(a.library).resolve())),a.quick)
