#!/usr/bin/env python3
"""Whole original c4b18 against C; original CRC, predicate and time helper run.

OS/transport/count/interval/memcpy and signed-division ABI are explicit hooks.
No firmware process, pool connection, UART or real concurrent thread is run.
"""
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
from arm32_subset import signed, MASK
from test_thermal_routes_135 import Chain

REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
BACK=0x840000
CHAINS=(0x842000,0x844000)
MUTEX,COND,RING,SLOTS=0x633ba8,0x633bc0,0x633bf0,0x653458
ROW0=RING+32
SLOT0=SLOTS+8
I,U,B,P,Q=C.c_int32,C.c_uint32,C.c_uint8,C.c_void_p,C.c_uint64
class Time(C.Structure): _fields_=[('sec',Q),('ns',U),('pad',U)]
class TxChain(C.Structure): _fields_=[('state',C.POINTER(Chain)),('uart',P)]
class Backend(C.Structure): _fields_=[('chains',C.POINTER(TxChain)),('running',B)]
class Ring(C.Structure): _fields_=[('head',U),('tail',U),('rows',P)]
class Slots(C.Structure): _fields_=[('next',U),('rows',P)]
class View(C.Structure): _fields_=[('backend',C.POINTER(Backend)),('ring',C.POINTER(Ring)),('slots',C.POINTER(Slots))]
CALL=C.CFUNCTYPE(I,P,U,U,U)
CLOCK=C.CFUNCTYPE(I,P,U,C.POINTER(Time))
WAIT=C.CFUNCTYPE(I,P,U,U,C.POINTER(Time))
WRITE=C.CFUNCTYPE(I,P,P,P,U)
class Ops(C.Structure): _fields_=[('call',CALL),('clock',CLOCK),('wait',WAIT),('write',WRITE)]

def digest(data): return hashlib.sha256(data).hexdigest()
def time_tuple(t): return (t.sec,t.ns,t.pad)
def s64(bits): return bits-(1<<64) if bits>>63 else bits
def division(m):
    # __aeabi_ldivmod at 5913ac: signed quotient truncates toward zero;
    # r0:r1 quotient, r2:r3 remainder. No worker/time logic in this hook.
    a=s64(m.r[0]|m.r[1]<<32); b=s64(m.r[2]|m.r[3]<<32)
    assert b in (1000,1000000000)
    q=abs(a)//b*(-1 if a<0 else 1); r=a-q*b
    m.r[:4]=[q&MASK,(q>>32)&MASK,r&MASK,(r>>32)&MASK]

class Machine(ARM32Rebuild):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in [(0xc4b18,0xc503c),(0x10f544,0x10f644),
                                       (0x56fcc,0x57028),(0xf7df4,0xf7eec)]), ('unexpected',hex(pc))
        self.visited.add(pc)
        # Only new instruction: exact UMULL r6,r3,r6,r12 in 10f544.
        if pc==0x10f584:
            assert w==0xe0836c96
            product=self.r[6]*self.r[12]
            self.r[6],self.r[3]=product&MASK,product>>32
            return True
        return super().extra_instruction(w,pc)

class Exit(Exception): pass
class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m
        self.calls=collections.Counter();self.events=[];self.errors=[];self.keep=[]
        self.chain_banks=[(Chain*3)() for _ in range(2)]
        self.bindings=[(TxChain*3)() for _ in range(2)]
        for bank in range(2):
            for i,c in enumerate(self.chain_banks[bank]):
                C.memset(C.addressof(c),0xa5,C.sizeof(c))
                c.present=p.get('present',[1,1,1])[i]
                c.state=p.get('states',[2,2,2])[i]
                self.bindings[bank][i]=TxChain(C.pointer(c),CHAINS[bank]+i*800+0x2b8)
        self.queue=C.create_string_buffer(768*168+32)
        self.table=C.create_string_buffer(32*168+32)
        queue=bytes((i*37+i//168+p.get('seed',0))&255 for i in range(768*168))
        self.initial_queue=b'\xa5'*16+queue+b'\xa5'*16
        self.initial_table=b'\xa5'*(32*168+32)
        C.memmove(self.queue,self.initial_queue,len(self.initial_queue))
        C.memmove(self.table,self.initial_table,len(self.initial_table))
        self.backend=Backend(self.bindings[0],p.get('running',99))
        self.ring=Ring(p.get('head',40),p.get('tail',0),C.addressof(self.queue)+16)
        self.slots=Slots(p.get('next',0),C.addressof(self.table)+16)
        self.view=View(C.pointer(self.backend),C.pointer(self.ring),C.pointer(self.slots))
        if m:
            m.reset((BACK,));m.visited=set()
            m.mem[BACK:0x846000]=b'\xa5'*0x6000
            m.mem[ROW0-16:ROW0+768*168+16]=self.initial_queue
            m.mem[SLOT0-16:SLOT0+32*168+16]=self.initial_table
            m.write(BACK+0x230,CHAINS[0]);m.write(BACK+0x105c,self.backend.running,1)
            m.write(RING+24,self.ring.head);m.write(RING+28,self.ring.tail)
            m.write(SLOTS,self.slots.next)
            for bank in range(2):
                for i,c in enumerate(self.chain_banks[bank]):
                    m.write(CHAINS[bank]+800*i+0x20,c.state)
                    m.write(CHAINS[bank]+800*i+0x24,c.present,1)
            # Valid parity globals, including wrap-valued inputs. Never patch code.
            for at,lit in [(0xc4be4,0xc504c),(0xc4c58,0xc5054),(0xc4d64,0xc505c),
                           (0xc4eb0,0xc5070),(0xc5004,0xc5078),(0x10f610,0x10f644),
                           (0x56ff4,0x57028)]:
                target=m.read((at+8+m.read(lit))&MASK)
                m.write(target,p.get('opaque',0xffffffff))
        for key,value in p.get('initial',[]):self.mutate(key,value)
        self.before=(bytes(m.mem[BACK:0x846000]) if m else [bytes(c) for bank in self.chain_banks for c in bank])

    def scalar(self,k):
        m=self.m
        if k=='running':return m.read(BACK+0x105c,1) if m else self.backend.running
        if k=='bank':return CHAINS.index(m.read(BACK+0x230)) if m else int(C.addressof(self.backend.chains.contents)==C.addressof(self.bindings[1]))
        off={'head':RING+24,'tail':RING+28,'next':SLOTS}[k]
        return m.read(off) if m else getattr(self.slots if k=='next' else self.ring,k)

    def data(self,kind):
        m=self.m;at,size=(ROW0,768*168) if kind=='queue' else (SLOT0,32*168)
        return bytes(m.mem[at:at+size]) if m else C.string_at(self.ring.rows if kind=='queue' else self.slots.rows,size)

    def snapshot(self):
        return tuple(self.scalar(k) for k in ('running','bank','head','tail','next'))+(digest(self.data('slots')),)

    def mutate(self,k,v):
        m=self.m
        if k in ('head','tail','next','running'):
            if m:m.write({'head':RING+24,'tail':RING+28,'next':SLOTS,'running':BACK+0x105c}[k],v,1 if k=='running' else 4)
            else:setattr(self.backend if k=='running' else self.slots if k=='next' else self.ring,k,v)
        elif k=='bank':
            if m:m.write(BACK+0x230,CHAINS[v])
            else:self.backend.chains=self.bindings[v]
        elif k in ('present','state'):
            bank,i,val=v
            if m:m.write(CHAINS[bank]+i*800+(0x24 if k=='present' else 0x20),val,1 if k=='present' else 4)
            else:setattr(self.chain_banks[bank][i],k,val)
        elif k in ('queue_byte','slot_byte'):
            offset,val=v
            if m:m.write((ROW0 if k=='queue_byte' else SLOT0)+offset,val,1)
            else:C.c_uint8.from_address((self.ring.rows if k=='queue_byte' else self.slots.rows)+offset).value=val
        else:raise AssertionError(k)

    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1
        assert sum(self.calls.values())<5000, 'callbacks failed to terminate'
        self.events.append((name,*args,self.snapshot()))
        if name=='wait' and n+1>=self.p.get('passes',1):self.mutate('running',0)
        for at,index,key,value in self.p.get('mutations',[]):
            if at==name and index==n:self.mutate(key,value)
        value=self.p.get('returns',{}).get(name,self.p.get('count',3) if name=='count' else self.p.get('interval',17) if name=='interval' else -7)
        return value[min(n,len(value)-1)] if isinstance(value,list) else value

    def clock(self,old):
        i=self.calls['clock'];rc=self.event('clock',old)
        writes=self.p.get('times',[(100,998000000,0x91827364)])
        return rc,writes[min(i,len(writes)-1)]

    def verify_unrelated(self):
        if self.m:
            after=bytearray(self.m.mem[BACK:0x846000]);before=self.before
            ranges=[(0x230,4),(0x105c,1)]
            for base in CHAINS:
                for i in range(3):ranges.extend([(base-BACK+i*800+0x20,4),(base-BACK+i*800+0x24,1)])
            for offset,size in ranges:after[offset:offset+size]=before[offset:offset+size]
            assert bytes(after)==before,'original unrelated backend/chain overwrite'
        else:
            for i,c in enumerate(c for bank in self.chain_banks for c in bank):
                after=bytearray(bytes(c));before=self.before[i]
                for k in ('state','present'):
                    off=getattr(Chain,k).offset;size=getattr(Chain,k).size
                    after[off:off+size]=before[off:off+size]
                assert bytes(after)==before,'C unrelated chain overwrite'
            assert self.queue.raw[:16]==self.queue.raw[-16:]==b'\xa5'*16
            assert self.table.raw[:16]==self.table.raw[-16:]==b'\xa5'*16

def original(p,m):
    w=World(p,m)
    def ret(value):m.r[0]=value&MASK
    def call(name,*args):ret(w.event(name,*args))
    def cancel(_):assert m.r[:2]==[1,0];call('cancel',1,0)
    def name(_):assert m.r[:4]==[15,0x5e977d,0,0] and m.read(m.r[13])==0;call('name',15,0x5e977d)
    def clock(_):
        assert m.r[0]==1
        at=m.r[1];rc,value=w.clock(struct.unpack('<QII',m.mem[at:at+16]))
        if value is not None:m.mem[at:at+16]=struct.pack('<QII',*value)
        ret(rc)
    def wait(_):
        assert m.r[:2]==[COND,MUTEX]
        call('wait',struct.unpack('<QII',m.mem[m.r[2]:m.r[2]+16]))
    def sync(kind):
        def f(_):
            assert m.r[0] in (MUTEX,RING)
            call(('queue_' if m.r[0]==RING else 'wait_')+kind)
        return f
    def copy(_):
        dst,src,size=m.r[:3];assert size in (168,32,28)
        m.check(src,size);m.check(dst,size);m.mem[dst:dst+size]=bytes(m.mem[src:src+size]);ret(dst)
    def write(_):
        uart,at,size=m.r[:3];assert size==88
        call('write',uart,bytes(m.mem[at:at+size]).hex())
    def leave(_):assert m.r[0]==0;w.event('exit',0,0);raise Exit()
    hooks={0xfe668:lambda _:call('count'),0xfedc4:lambda _:call('interval'),
           0x5a6b2c:cancel,0x593af8:name,0x5a7004:clock,0x5a4bd8:wait,
           0x5a6108:sync('lock'),0x5a66c4:sync('unlock'),0x5a2ee8:copy,
           0xfef0c:write,0x5a52d0:leave,0x5913ac:division}
    try:m.run(0xc4b18,hooks=hooks,max_steps=2000000)
    except Exit:pass
    else:raise AssertionError('original thread did not exit')
    w.verify_unrelated()
    return w

def native(p,lib):
    w=World(p)
    def cb(typ,fn):
        def wrapped(*args):
            try:return fn(*args)
            except BaseException as error:w.errors.append(error);w.backend.running=0;return 0
        f=typ(wrapped);w.keep.append(f);return f
    def call(_,e,a,b):
        if e in (0xfe668,0xfedc4):assert(a,b)==(0,0);return w.event('count' if e==0xfe668 else 'interval')
        if e in (0x5a6b2c,0x593af8,0x5a52d0):
            name,expected={0x5a6b2c:('cancel',(1,0)),0x593af8:('name',(15,0x5e977d)),0x5a52d0:('exit',(0,0))}[e]
            assert(a,b)==expected;return w.event(name,a,b)
        assert e in (0x5a6108,0x5a66c4) and a in (MUTEX,RING) and b==0
        return w.event(('queue_' if a==RING else 'wait_')+('lock' if e==0x5a6108 else 'unlock'))
    def clock(_,identity,t):
        assert identity==1;rc,value=w.clock(time_tuple(t.contents))
        if value is not None:t.contents.sec,t.contents.ns,t.contents.pad=value
        return rc
    def wait(_,cond,mutex,t):assert(cond,mutex)==(COND,MUTEX);return w.event('wait',time_tuple(t.contents))
    def write(_,uart,data,size):assert size==88;return w.event('write',uart,C.string_at(data,size).hex())
    ops=Ops(cb(CALL,call),cb(CLOCK,clock),cb(WAIT,wait),cb(WRITE,write))
    f=lib.vn135_work_tx_worker_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=I
    assert f(C.byref(w.view),C.byref(ops),None)==1
    if w.errors:raise w.errors[0]
    w.verify_unrelated()
    return w

def cases():
    yield {}
    for count in (-2147483648,-1,0,1,2,3):yield {'count':count,'passes':3}
    for state,present in itertools.product([0,1,2,3,4,5,6,0x80000000,0xffffffff],[0,1,2,255]):
        yield {'states':[state]*3,'present':[present]*3,'count':3}
    for slot,tail in itertools.product(range(32),[0,1,254,255,256,511,512,766,767]):
        yield {'next':slot,'tail':tail,'head':(tail+2)%768,'passes':2}
    for tail in (0,1,767,768,0x7fffffff,0x80000000,0xffffffff):
        yield {'head':tail,'tail':tail}
        yield {'head':tail^1,'tail':tail}
    for rc in (-2147483648,-1,0,1,7,87,88,89,2147483647):
        yield {'returns':{k:rc for k in ('cancel','name','clock','wait','wait_lock','wait_unlock','queue_lock','queue_unlock','write','exit')}}
    for interval in (-2147483648,-1001,-1000,-999,-1,0,1,999,1000,1001,2147483647):
        yield {'interval':interval,'passes':3,'times':[(0,0,0xaabbccdd),None,None]}
    for at,n in [('name',0),('clock',0),('wait',0),('wait_unlock',0),('queue_lock',0),
                 ('queue_unlock',0),('queue_lock',1),('queue_unlock',1),('queue_lock',2),
                 ('queue_unlock',2),('write',0)]:
        changes=[('running',0),('head',0),('tail',7),('tail',767),('next',31),('bank',1),
                 ('state',[0,1,4]),('present',[0,1,0]),('queue_byte',[7*168+64,0xee]),
                 ('slot_byte',[0,0xef]),('slot_byte',[64,0xed])]
        for k,v in changes:yield {'passes':2,'mutations':[(at,n,k,v)]}
    for at,n in [('queue_unlock',0),('queue_lock',1),('queue_unlock',1),('queue_lock',2)]:
        for tail in (768,0xffffffff):yield {'mutations':[(at,n,'tail',tail)]}
    rng=random.Random(0xc4b18)
    for _ in range(180):
        yield {'seed':rng.randrange(256),'next':rng.randrange(32),'tail':rng.randrange(768),
               'head':rng.randrange(768),'states':[rng.randrange(8) for _ in range(3)],
               'present':[rng.choice([0,1,255]) for _ in range(3)],'passes':rng.randrange(1,4),
               'interval':rng.randint(-2147483648,2147483647),'opaque':rng.getrandbits(32),
               'times':[(rng.getrandbits(64),rng.getrandbits(32),rng.getrandbits(32))]}

def time_cases():
    for sec,ns,interval in itertools.product([0,1,0xffffffff,0xffffffffffffffff,0x7fffffffffffffff],
            [0,1,999999999,1000000000,0x7fffffff,0x80000000,0xffffffff],
            [-2147483648,-1001,-1000,-999,-1,0,1,999,1000,1001,2147483647]):
        yield sec,ns,interval
    rng=random.Random(0x10f544)
    for _ in range(500):yield rng.getrandbits(64),rng.getrandbits(32),rng.randint(-2147483648,2147483647)

def run(lib,quick=False):
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert digest(elf.data)==REF
    m=Machine(elf);events=steps=total=0;visited=set()
    f=lib.vn135_tx_add_interval_135;f.argtypes=[C.POINTER(Time),I];f.restype=None
    times=list(time_cases())[:8] if quick else list(time_cases())
    for sec,ns,interval in times:
        t=Time(sec,ns,0xa5a55a5a);at=BACK
        m.reset((at,at,interval,0xffffffff if interval<0 else 0));m.visited=set()
        m.mem[at:at+16]=bytes(t)
        m.run(0x10f544,hooks={0x5913ac:division},max_steps=1000)
        f(C.byref(t),interval)
        assert bytes(t)==bytes(m.mem[at:at+16]),('MISMATCH time',sec,ns,interval)
        steps+=m.steps;visited.update(m.visited)
    params=list(cases())
    if quick:params=params[:60]+params[-30:]+[p for p in params if 'mutations' in p]
    for total,p in enumerate(params,1):
        a=original(p,m);b=native(p,lib)
        assert a.events==b.events,('MISMATCH events',total,p,next(((x,y) for x,y in itertools.zip_longest(a.events,b.events) if x!=y),None))
        assert a.snapshot()==b.snapshot() and a.data('queue')==b.data('queue') and a.data('slots')==b.data('slots'),('MISMATCH final',total,p)
        events+=len(a.events);steps+=m.steps;visited.update(m.visited)
    print(f'WORK_TX_WORKER_ORIGINAL_PASS cases={total} times={len(times)} events={events} steps={steps} pcs={len(visited)}')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('library');parser.add_argument('--quick',action='store_true');args=parser.parse_args()
    run(C.CDLL(str(Path(args.library).resolve())),args.quick)
