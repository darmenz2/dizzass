#!/usr/bin/env python3
"""Whole c4054 against composed C; original SHA executes, OS/FIFO are hooks."""
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
from arm32_nonce_subset import ARM32Nonce
from test_thermal_routes_135 import Chain

REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
BASE=0x840000;BANKS=(0x842000,0x844000);TABLE=0x653460
WAIT_MUTEX,CONDITION=0x653410,0x653428
U,I,B,P=C.c_uint32,C.c_int32,C.c_uint8,C.c_void_p
class RxChain(C.Structure):_fields_=[('chain',C.POINTER(Chain)),('enabled',B),('mutex',P),('fifo',P)]
class Backend(C.Structure):_fields_=[('chains',C.POINTER(RxChain)),('running',B)]
class Scratch(C.Structure):_fields_=[('cancel',U),('header',B)]
class View(C.Structure):_fields_=[('backend',C.POINTER(Backend)),('slots',P),('scratch',Scratch)]
class Message(C.Structure):_fields_=[(k,U) for k in ('kind','consumed','size','chain','value','chip','reg','crc','slot')]+[('payload',B*9)]
class Candidate(C.Structure):_fields_=[('words',U*17)]
SCALAR=C.CFUNCTYPE(U,P,U);CANCEL=C.CFUNCTYPE(I,P,U,C.POINTER(U));NAME=C.CFUNCTYPE(I,P,U,U)
SYNC=C.CFUNCTYPE(I,P,U,P);WAIT=C.CFUNCTYPE(I,P,U,U);AVAIL=C.CFUNCTYPE(U,P,P)
BYTE=C.CFUNCTYPE(I,P,P,C.POINTER(B));PAYLOAD=C.CFUNCTYPE(I,P,P,C.POINTER(B),U)
ATTR=C.CFUNCTYPE(U,P,U);REPLY=C.CFUNCTYPE(I,P,C.POINTER(Message));NONCE=C.CFUNCTYPE(I,P,C.POINTER(Candidate))
class Ops(C.Structure):_fields_=[('scalar',SCALAR),('cancel',CANCEL),('name',NAME),('sync',SYNC),('wait',WAIT),('available',AVAIL),('byte',BYTE),('payload',PAYLOAD),('chip',ATTR),('core',ATTR),('reply',REPLY),('nonce',NONCE)]
def digest(x):return hashlib.sha256(x).hexdigest()
def pick(p,k,n,default):
    value=p.get(k,default)
    return value[min(n,len(value)-1)] if isinstance(value,list) else value
def packet(variant=2,nonce=True,reg=0x41,seed=17):
    b=bytearray((seed+i*19)&255 for i in range(7+variant))
    b[6 if variant==1 else 5]=reg
    b[-1]=(b[-1]&0x7f)|(0x80 if nonce else 0)
    return bytes([0xaa,0x55])+b

class Machine(ARM32Nonce):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in ((0xc4054,0xc4aa8),(0x108b7c,0x10939c))),('unexpected code',hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w,pc)

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.calls=collections.Counter();self.keep=[];self.errors=[]
        self.states=[(Chain*3)() for _ in range(2)];self.chains=[(RxChain*3)() for _ in range(2)]
        for bank in range(2):
            for i,c in enumerate(self.states[bank]):
                C.memset(C.addressof(c),0xa5,C.sizeof(c));c.index=100+bank*10+i
                at=BANKS[bank]+i*800
                self.chains[bank][i]=RxChain(C.pointer(c),p.get('enabled',[1,1,1])[i],at+0x2e0,at+0x2f8)
        self.backend=Backend(self.chains[0],73)
        data=bytes((i*17+i//168+p.get('seed',0))&255 for i in range(32*168))
        self.jobs=C.create_string_buffer(data,len(data));self.initial_jobs=data
        self.view=View(C.pointer(self.backend),C.addressof(self.jobs),Scratch(p.get('cancel_seed',0x13579bdf),p.get('header_seed',0xed)))
        streams=p.get('streams',[packet().hex(),'',''])
        self.streams=[bytearray.fromhex(x) for x in streams]+[bytearray.fromhex(x) for x in p.get('other_streams',streams)]
        if m:
            m.reset((BASE,));m.visited=set()
            m.mem[BASE:0x846000]=b'\xa5'*0x6000
            m.mem[TABLE:TABLE+len(data)]=data
            m.write(BASE+0x230,BANKS[0]);m.write(BASE+0x1064,73,1)
            m.write(m.STACK_TOP-44,self.view.scratch.cancel)
            m.write(m.STACK_TOP-113,self.view.scratch.header,1)
            m.write(0x68bd94,p.get('opaque',0xffffffff));m.write(0x68bd40,0x7fffffff)
            for bank in range(2):
                for i,c in enumerate(self.states[bank]):
                    m.write(BANKS[bank]+i*800+0x18,c.index)
                    m.write(BANKS[bank]+i*800+0x318,self.chains[bank][i].enabled,1)
        for k,v in p.get('initial',[]):self.mutate(k,v)
        self.before=bytes(m.mem[BASE:0x846000]) if m else [bytes(c) for bank in self.states for c in bank]

    def identity(self,pointer,offset):
        for bank,base in enumerate(BANKS):
            for i in range(3):
                if pointer==base+i*800+offset:return bank*3+i
        raise AssertionError(('bad identity',hex(pointer),offset))
    def running(self):return self.m.read(BASE+0x1064,1) if self.m else self.backend.running
    def snapshot(self):
        if self.m:
            bank=BANKS.index(self.m.read(BASE+0x230))
            fields=tuple((self.m.read(base+i*800+0x18),self.m.read(base+i*800+0x318,1)) for base in BANKS for i in range(3))
        else:
            bank=int(C.addressof(self.backend.chains.contents)==C.addressof(self.chains[1]))
            fields=tuple((self.states[b][i].index,self.chains[b][i].enabled) for b in range(2) for i in range(3))
        return (self.running(),bank,fields,tuple(bytes(s).hex() for s in self.streams))
    def mutate(self,k,v):
        m=self.m
        if k=='running':
            if m:m.write(BASE+0x1064,v,1)
            else:self.backend.running=v
        elif k=='bank':
            if m:m.write(BASE+0x230,BANKS[v])
            else:self.backend.chains=self.chains[v]
        elif k in ('index','enabled'):
            bank,i,value=v
            if m:m.write(BANKS[bank]+i*800+(0x18 if k=='index' else 0x318),value,4 if k=='index' else 1)
            else:setattr(self.states[bank][i] if k=='index' else self.chains[bank][i],k,value)
        elif k=='append':self.streams[v[0]].extend(bytes.fromhex(v[1]))
        elif k=='clear':self.streams[v].clear()
        elif k=='job_byte':
            at,value=v
            if m:m.write(TABLE+at,value,1)
            else:C.c_uint8.from_address(C.addressof(self.jobs)+at).value=value
        else:raise AssertionError(k)
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1
        assert sum(self.calls.values())<3000,'callback budget exceeded'
        self.events.append((name,*args,self.snapshot()))
        if name=='wait' and n+1>=self.p.get('waits',1):self.mutate('running',0)
        for at,index,k,v in self.p.get('mutations',[]):
            if (at,index)==(name,n):self.mutate(k,v)
        return pick(self.p.get('returns',{}),name,n,-7)
    def scalar(self,entry):
        names={0xfe668:'count',0xfdfbc:'selector',0xfdfac:'board',0xfe0b0:'mode',0xd2a84:'filter'}
        name=names[entry];n=self.calls[name];self.event(name)
        return pick(self.p,name,n,{'count':3,'selector':2,'board':1,'mode':0,'filter':0x40}[name])&0xffffffff
    def cancel(self,mode,old):
        n=self.calls['cancel_save'];name='cancel_save' if old is not None else 'cancel_plain'
        rc=self.event(name,mode,old)
        return rc,pick(self.p,'cancel_values',n,1) if old is not None else None
    def available(self,which):
        n=self.calls['available'];self.event('available',which)
        return pick(self.p,'reported',n,len(self.streams[which]))&0xffffffff
    def byte(self,which,old):
        n=self.calls['byte'];rc=self.event('byte',which,old)
        data=self.streams[which]
        default=data.pop(0) if data else None
        return rc,pick(self.p,'byte_writes',n,default)
    def payload(self,which,old):
        n=self.calls['payload'];rc=self.event('payload',which,bytes(old).hex())
        amount=min(len(old),len(self.streams[which]),pick(self.p,'payload_limit',n,len(old)))
        data=self.streams[which][:amount];del self.streams[which][:amount]
        return rc,data
    def verify(self):
        if self.m:
            after=bytearray(self.m.mem[BASE:0x846000]);before=self.before
            allowed=[(0x230,4),(0x1064,1)]+[(base-BASE+i*800+off,size) for base in BANKS for i in range(3) for off,size in [(0x18,4),(0x318,1)]]
            for off,size in allowed:after[off:off+size]=before[off:off+size]
            assert bytes(after)==before,'original unrelated state changed'
        else:
            for i,c in enumerate(c for bank in self.states for c in bank):
                after=bytearray(bytes(c));off=Chain.index.offset;after[off:off+4]=self.before[i][off:off+4]
                assert bytes(after)==self.before[i],'C unrelated state changed'
        return digest(bytes(self.m.mem[TABLE:TABLE+32*168]) if self.m else self.jobs.raw)

def original(p,m):
    w=World(p,m)
    def ret(x):m.r[0]=x&0xffffffff
    def scalar(_):ret(w.scalar(m.r[15]))
    def cancel(_):
        at=m.r[1];rc,value=w.cancel(m.r[0],m.read(at) if at else None)
        if at and value is not None:m.write(at,value)
        ret(rc)
    def name(_):assert m.r[:4]==[15,0x5e9749,0,0] and m.read(m.r[13])==0;ret(w.event('name',15,0x5e9749))
    def sync(_):
        which=-1 if m.r[0]==WAIT_MUTEX else w.identity(m.r[0],0x2e0)
        ret(w.event('lock' if m.r[15]==0x5a6108 else 'unlock',which))
    def wait(_):assert m.r[:2]==[CONDITION,WAIT_MUTEX];ret(w.event('wait'))
    def available(_):ret(w.available(w.identity(m.r[0],0x2f8)))
    def byte(_):
        at=m.r[1];rc,value=w.byte(w.identity(m.r[0],0x2f8),m.read(at,1))
        if value is not None:m.write(at,value,1)
        ret(rc)
    def payload(_):
        at,size=m.r[1:3];assert 7<=size<=9
        rc,value=w.payload(w.identity(m.r[0],0x2f8),m.mem[at:at+size]);m.mem[at:at+len(value)]=value;ret(rc)
    def attribution(name):
        def f(_):n=w.calls[name];w.event(name,m.r[0]);ret(pick(p,name,n,0x1234 if name=='chip' else 0x5678))
        return f
    def reply(_):
        at=m.r[0]
        ret(w.event('reply',m.read(at),m.read(at+4,1),m.read(at+5,1),m.read(at+8),m.read(at+12,2)))
    def nonce(_):ret(w.event('nonce',bytes(m.mem[m.r[0]:m.r[0]+68]).hex()))
    def copy(_):
        dst,src,n=m.r[:3];m.check(dst,n);m.check(src,n);m.mem[dst:dst+n]=bytes(m.mem[src:src+n]);ret(dst)
    def fill(_):
        dst,value,n=m.r[:3];assert value==0 and n==64;m.check(dst,n);m.mem[dst:dst+n]=bytes(n);ret(dst)
    hooks={a:scalar for a in (0xfe668,0xfdfbc,0xfdfac,0xfe0b0,0xd2a84)}
    hooks.update({0x5a6b2c:cancel,0x593af8:name,0x5a6108:sync,0x5a66c4:sync,0x5a50d8:wait,
                  0xd20ac:available,0xd1df0:byte,0xd1f20:payload,0xd2760:attribution('chip'),0xd280c:attribution('core'),
                  0x108938:reply,0xfa5e0:nonce,0x5a2ee8:copy,0x5a348c:fill})
    assert m.run(0xc4054,hooks=hooks,max_steps=2000000)==0
    w.verify();return w

def native(p,lib):
    w=World(p)
    def cb(typ,fn):
        def f(*args):
            try:return fn(*args)
            except BaseException as e:w.errors.append(e);w.backend.running=0;return 0
        out=typ(f);w.keep.append(out);return out
    def cancel(_,mode,old):
        rc,value=w.cancel(mode,old[0] if old else None)
        if old and value is not None:old[0]=value
        return rc
    def name(_,a,b):assert(a,b)==(15,0x5e9749);return w.event('name',a,b)
    def sync(_,entry,mutex):
        assert entry in (0x5a6108,0x5a66c4)
        return w.event('lock' if entry==0x5a6108 else 'unlock',-1 if mutex==WAIT_MUTEX else w.identity(mutex,0x2e0))
    def wait(_,cond,mutex):assert(cond,mutex)==(CONDITION,WAIT_MUTEX);return w.event('wait')
    def byte(_,fifo,out):
        rc,value=w.byte(w.identity(fifo,0x2f8),out[0])
        if value is not None:out[0]=value
        return rc
    def payload(_,fifo,out,size):
        assert 7<=size<=9;rc,value=w.payload(w.identity(fifo,0x2f8),C.string_at(out,size));C.memmove(out,bytes(value),len(value));return rc
    def attr(name):
        def f(_,nonce):n=w.calls[name];w.event(name,nonce);return pick(p,name,n,0x1234 if name=='chip' else 0x5678)
        return f
    def reply(_,msg):
        x=msg.contents;assert x.kind==2
        return w.event('reply',x.chain,x.chip,x.reg,x.value,x.crc)
    ops=Ops(cb(SCALAR,lambda _,entry:w.scalar(entry)),cb(CANCEL,cancel),cb(NAME,name),cb(SYNC,sync),cb(WAIT,wait),
            cb(AVAIL,lambda _,fifo:w.available(w.identity(fifo,0x2f8))),cb(BYTE,byte),cb(PAYLOAD,payload),
            cb(ATTR,attr('chip')),cb(ATTR,attr('core')),cb(REPLY,reply),cb(NONCE,lambda _,x:w.event('nonce',C.string_at(x,68).hex())))
    f=lib.vn135_work_rx_worker_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=I
    assert f(C.byref(w.view),C.byref(ops),None)==0
    if w.errors:raise w.errors[0]
    w.verify();return w

def cases():
    yield {}
    for count in (0,0xffffffff,0x80000000,1,2,3):yield {'count':count,'waits':2}
    for selector,board,mode in itertools.product([0,2,4,5,6,7,0xffffffff],[0,1,4],[0,1]):
        variant=0 if board==0 or (selector==6 and board==4) else 1 if selector==7 else 2
        for nonce in (False,True):
            frame=packet(0 if mode else variant,nonce)
            yield {'selector':selector,'board':board,'mode':mode,'streams':[frame.hex(),frame.hex(),'']}
    for first,second in itertools.product([2,4,7],[0,2,4,7,0xffffffff]):
        variant=1 if first==7 else 2
        yield {'selector':[first,second],'streams':[packet(variant,True).hex(),'','']}
    for variant,mode in itertools.product([0,1,2],[[0,1],[1,0],[0,0,1,0],[1,1,0,1]]):
        first=7 if variant==1 else 2;board=0 if variant==0 else 1
        stream=(packet(variant,True)+packet(0,False)).hex()
        yield {'selector':first,'board':board,'mode':mode,'streams':[stream,stream,stream]}
    for value in range(256):
        yield {'streams':[(bytes([value])+packet()+bytes(11)).hex(),'',''],'count':1}
    for size in range(12):yield {'streams':[packet().hex()[:size*2],'','']}
    for last in (0,1,31,32,63,127,128,255):
        for variant in range(3):
            frame=bytearray(packet(variant,False));frame[-1]=last
            yield {'selector':7 if variant==1 else 2,'board':0 if variant==0 else 1,'streams':[frame.hex(),'','']}
    for filtered in (0,0x40,0x41,255,256,0xffffffff):yield {'filter':filtered,'streams':[packet(2,False).hex(),'','']}
    for enabled in (0,1,2,255):yield {'enabled':[enabled]*3,'streams':[packet().hex()]*3}
    for rc in (-2147483648,-1,0,1,2147483647):
        yield {'returns':{k:rc for k in ('cancel_plain','cancel_save','name','lock','unlock','wait','byte','payload','reply','nonce')},'streams':[(packet()+packet(2,False)).hex(),'','']}
    for k in range(10):yield {'payload_limit':k,'streams':[packet().hex(),'','']}
    yield {'header_seed':0xaa,'byte_writes':[None,None]}
    yield {'header_seed':0x55,'byte_writes':[0xaa,None]}
    yield {'cancel_values':None,'cancel_seed':0xfedcba98,'waits':3,'streams':['','','']}
    yield {'cancel_values':[0,2,0xffffffff],'waits':3,'streams':['','','']}
    for at,n in [('name',0),('mode',1),('lock',0),('available',0),('byte',0),('byte',1),('payload',0),('nonce',0),('unlock',0),('wait',0)]:
        for key,value in [('running',0),('bank',1),('index',[0,0,0xffffffff]),('enabled',[0,1,0]),('append',[1,packet().hex()])]:
            yield {'streams':[packet().hex()]*3,'mutations':[(at,n,key,value)]}
    yield {'streams':['','',''],'mutations':[('lock',0,'running',0)]}
    yield {'streams':['','',''],'mutations':[('wait',0,'append',[0,packet().hex()]),('wait',0,'running',1)]}
    for i in range(32):
        frame=bytearray(packet());frame[7]=i<<3
        yield {'streams':[frame.hex(),'',''],'seed':i,'chip':i,'core':0xffffffff-i}
    rng=random.Random(0xc4054)
    for _ in range(80):
        variant=rng.randrange(3);selector=7 if variant==1 else rng.choice([0,2,4,5,6]);board=0 if variant==0 else 1
        frame=bytearray(packet(variant,bool(rng.getrandbits(1)),rng.randrange(256),rng.randrange(256)))
        yield {'selector':selector,'board':board,'streams':[(bytes([rng.randrange(256)])+frame+bytes(12)).hex(),frame.hex(),frame.hex()],
               'enabled':[rng.choice([0,1,255]) for _ in range(3)],'opaque':rng.getrandbits(32),'seed':rng.randrange(256)}

def run(lib,quick=False):
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert digest(elf.data)==REF
    m=Machine(elf);events=steps=nonces=replies=0;visited=set();params=list(cases())
    if quick:params=params[:35]+params[-12:]+[p for p in params if 'mutations' in p]
    for i,p in enumerate(params,1):
        a=original(p,m);b=native(p,lib)
        assert a.events==b.events,('MISMATCH events',i,p,next(((x,y) for x,y in itertools.zip_longest(a.events,b.events) if x!=y),None))
        assert a.snapshot()==b.snapshot() and a.verify()==b.verify(),('MISMATCH final',i,p)
        events+=len(a.events);steps+=m.steps;nonces+=a.calls['nonce'];replies+=a.calls['reply'];visited.update(m.visited)
    print(f'WORK_RX_WORKER_ORIGINAL_PASS cases={len(params)} nonces={nonces} replies={replies} events={events} steps={steps} pcs={len(visited)}')

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    run(C.CDLL(str(Path(a.library).resolve())),a.quick)
