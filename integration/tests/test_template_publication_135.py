#!/usr/bin/env python3
"""Original c3148 vs C. Clone/OS effects are explicit scripted boundaries.

Nested cases execute original fa944/d212c versus unchanged nonce FIFO reset.
No ELF process, hardware, inferred allocator or new ARM opcode implementation.
"""
import argparse, collections, ctypes as C, hashlib, json, random, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
U,B,P=C.c_uint32,C.c_uint8,C.c_void_p
GLOBAL=0x633ae0; DEST=0x633b40; SOURCE=0x840100; READY=0x633b38
MUTEX=0x633af0; COND=0x633b08; QUEUE=0x654ae8; QMUTEX=0x654ad0
HEAP=0x900000; SIZE=4096*72
PARITY=((0xc3398,0xc3180),(0xc339c,0xc3194),(0xc33a0,0xc3200),
        (0xc33a4,0xc3214),(0xc33b0,0xc32b8),(0xc33b4,0xc32cc),
        (0xc33b8,0xc3314),(0xc33bc,0xc3328))
RANGES=((0xc3148,0xc3390),(0xfa944,0xfa974),(0xd212c,0xd2144))
SLOTS={'branches':0x50,'coinbase':0x48,'text':4}
class View(C.Structure):
    _fields_=[('branches',C.POINTER(P)),('coinbase',C.POINTER(P)),('text',C.POINTER(P)),
              ('ready',C.POINTER(B)),('source_reset',C.POINTER(B)),('destination',P),
              ('source',P),('mutex',P),('condition',P)]
LOCK=C.CFUNCTYPE(C.c_int,P,P);FREE=C.CFUNCTYPE(None,P,P)
CLONE=C.CFUNCTYPE(None,P,P,P);RESET=C.CFUNCTYPE(None,P)
class Ops(C.Structure):
    _fields_=[('lock',LOCK),('release',FREE),('clone',CLONE),('reset',RESET),('broadcast',LOCK),('unlock',LOCK)]
class Fifo(C.Structure):
    _fields_=[('storage',P),('capacity',U),('stride',U),('count',U),('write',U),('read',U)]
class Queue(C.Structure):_fields_=[('ring',Fifo),('push_word',U),('ready',U)]
SYNC=C.CFUNCTYPE(C.c_int,P)
class Sync(C.Structure):_fields_=[('context',P),('init',P),('lock',SYNC),('unlock',SYNC),('destroy',P)]
class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES),('unexpected PC',hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w,pc)
def sha(b):return hashlib.sha256(b).hexdigest()

class World:
    def __init__(self,p,m=None,lib=None):
        self.p,self.m,self.lib=p,m,lib;self.events=[];self.calls=collections.Counter();self.errors=[]
        seed=p.get('seed',0)
        self.g=(B*256).from_buffer_copy(bytes((i*13+seed)&255 for i in range(256)))
        self.s=(B*136).from_buffer_copy(bytes((i*7+seed)&255 for i in range(136)))
        self.slots={k:P((0x850000+i*256) if p.get('mask',7)&(1<<i) else 0) for i,k in enumerate(SLOTS)}
        self.ready=B.from_buffer(self.g,READY-GLOBAL);self.ready.value=p.get('ready',0xa5)
        self.flag=B.from_buffer(self.s,16+0x60);self.flag.value=p.get('flag',1)
        self.storage=(B*SIZE).from_buffer_copy(bytes([seed&255])*SIZE)
        read=p.get('read',7);count=p.get('count',33)
        self.q=Queue(Fifo(C.addressof(self.storage),4096,72,count,(read+count)%4096,read),p.get('push',0xffffffff),1)
        self.view=View(*[C.pointer(self.slots[k]) for k in SLOTS],C.pointer(self.ready),C.pointer(self.flag),DEST,SOURCE,MUTEX,COND)
        if m:
            m.reset([SOURCE]);m.visited=set()
            m.mem[GLOBAL:GLOBAL+256]=bytes(self.g);m.mem[SOURCE-16:SOURCE+120]=bytes(self.s)
            for k,v in self.slots.items():m.write(DEST+SLOTS[k],v.value or 0)
            if len(m.mem)<HEAP+SIZE+16:m.mem.extend(bytes(HEAP+SIZE+16-len(m.mem)))
            m.regions.append((HEAP-16,HEAP+SIZE+16))
            m.mem[HEAP-16:HEAP+SIZE+16]=b'\xa7'*16+bytes(self.storage)+b'\xb8'*16
            self.seed_queue(m)
            for lit,pc in PARITY:m.write(m.read((m.read(lit)+pc)&0xffffffff),p.get('opaque',0xffffffff))
        self.sync=Sync(None,None,SYNC(lambda _:self.event('queue_lock',QMUTEX)),SYNC(lambda _:self.event('queue_unlock',QMUTEX)),None)
    def seed_queue(self,m):
        q=self.q.ring
        for i,n in enumerate((HEAP,HEAP+SIZE,HEAP+q.write*72,HEAP+q.read*72,4096,q.count,72,self.q.push_word)):
            m.write(QUEUE+i*4,n)
    def images(self):
        if self.m:return bytes(self.m.mem[GLOBAL:GLOBAL+256]),bytes(self.m.mem[SOURCE-16:SOURCE+120])
        g=bytearray(self.g)
        for k,v in self.slots.items():g[DEST-GLOBAL+SLOTS[k]:DEST-GLOBAL+SLOTS[k]+4]=(v.value or 0).to_bytes(4,'little')
        return bytes(g),bytes(self.s)
    def qstate(self):
        if self.m:return [self.m.read(QUEUE+i*4) for i in range(8)]
        q=self.q.ring
        return [HEAP,HEAP+SIZE,HEAP+q.write*72,HEAP+q.read*72,4096,q.count,72,self.q.push_word]
    def snapshot(self):return [*[sha(x) for x in self.images()],self.qstate()]
    def set(self,key,value):
        if key in SLOTS:
            if self.m:self.m.write(DEST+SLOTS[key],value)
            else:self.slots[key].value=value
        else:
            addr={'ready':READY,'source_reset':SOURCE+0x60,'source_byte':SOURCE+0x61,
                  'dest_reset':DEST+0x60,'dest_byte':DEST+0x61}[key]
            if self.m:self.m.write(addr,value,1)
            elif addr>=SOURCE:self.s[addr-SOURCE+16]=value
            else:self.g[addr-GLOBAL]=value
    def event(self,name,*args):
        nth=self.calls[name];self.calls[name]+=1
        assert len(self.events)<32
        self.events.append([name,list(args),self.snapshot()])
        for event,n,key,value in self.p.get('mutations',[]):
            if (event,n)==(name,nth):self.set(key,value)
        if name.startswith('queue_'):return 0
        return self.p.get('rc',-17)
    def clone(self,d,s):
        assert (d,s)==(DEST,SOURCE)
        self.event('clone',d,s)
        # Scripted boundary writes, NOT an implementation of 5cd70.
        # The original and C coordinator must preserve these exact effects.
        self.set('dest_byte',0xed)
    def reset(self):
        self.event('reset')
        if self.p.get('nested'):
            rc=self.lib.vn135_nonce_fifo_reset(C.byref(self.q),C.byref(self.sync))
            assert rc==0,rc
    def hooks(self):
        def one(name):
            def f(m):m.r[0]=self.event(name,m.r[0])&0xffffffff
            return f
        def lock(m):
            assert m.r[0] in (MUTEX,QMUTEX)
            m.r[0]=self.event('lock' if m.r[0]==MUTEX else 'queue_lock',m.r[0])&0xffffffff
        def unlock(m):
            assert m.r[0] in (MUTEX,QMUTEX)
            m.r[0]=self.event('unlock' if m.r[0]==MUTEX else 'queue_unlock',m.r[0])&0xffffffff
        def clone(m):self.clone(*m.r[:2]);m.r[0]=0xdeadbeef
        h={0x5a6108:lock,0x593c8c:one('free'),0x5cd70:clone,0x5a48d0:one('broadcast'),0x5a66c4:unlock}
        if not self.p.get('nested'):
            def reset(m):self.event('reset');m.r[0]=0xbadc0de
            h[0xfa944]=reset
        return h
    def finish(self):
        g,s=self.images()
        if self.m:
            assert self.m.mem[HEAP-16:HEAP]==b'\xa7'*16
            assert self.m.mem[HEAP+SIZE:HEAP+SIZE+16]==b'\xb8'*16
            storage=bytes(self.m.mem[HEAP:HEAP+SIZE])
        else:storage=bytes(self.storage)
        assert storage==bytes([self.p.get('seed',0)&255])*SIZE
        return {'events':self.events,'global':g.hex(),'source':s.hex(),'queue':self.qstate(),'storage':sha(storage)}
    def native(self):
        def safe(fn):
            def f(*args):
                try:return fn(*args)
                except BaseException as e:self.errors.append(e);return 0
            return f
        self.ops=Ops(LOCK(safe(lambda _,x:self.event('lock',x))),FREE(safe(lambda _,x:self.event('free',x))),
            CLONE(safe(lambda _,d,s:self.clone(d,s))),RESET(safe(lambda _:self.reset())),
            LOCK(safe(lambda _,x:self.event('broadcast',x))),LOCK(safe(lambda _,x:self.event('unlock',x))))
        self.lib.vn135_template_publish_135(C.byref(self.view),C.byref(self.ops),None)
        if self.errors:
            assert all(isinstance(e,AssertionError) for e in self.errors),('unexpected callback error',self.errors)
            raise AssertionError(('SEMANTIC_MISMATCH callback contract',[repr(e) for e in self.errors]))
        return self.finish()

def scenarios():
    out=[]
    for mask in range(8):
        for flag in (0,1,2,128,255):
            for rc in (0,-17,0x7fffffff):out.append(dict(mask=mask,flag=flag,rc=rc,ready=255))
    # Every callback may affect later source/slot loads and after-call stores.
    for event,n in [('lock',0),('free',0),('free',1),('free',2),('clone',0),('reset',0),('broadcast',0),('unlock',0)]:
        for key,values in [('branches',(0,0x860000)),('coinbase',(0,0x861000)),('text',(0,0x862000)),
                           ('source_reset',(0,2)),('ready',(0,0xa7)),('source_byte',(0x38,)),('dest_reset',(0,1))]:
            for value in values:out.append(dict(mutations=[(event,n,key,value)]))
    for old,new in ((0,1),(1,0),(255,2)):
        out.append(dict(flag=old,mutations=[('clone',0,'source_reset',new),('clone',0,'dest_reset',1-new if new<=1 else 0)]))
    for opaque in (0,1,2,9,10,0x7fffffff,0x80000000,0xfffffffe,0xffffffff):out.append(dict(opaque=opaque))
    for count in (0,1,4095,4096):
        for read in (0,1,4095):
            for flag in (0,1,255):out.append(dict(nested=True,count=count,read=read,flag=flag))
    rng=random.Random(1353148)
    for _ in range(80):
        out.append(dict(mask=rng.randrange(8),flag=rng.randrange(256),ready=rng.randrange(256),opaque=rng.getrandbits(32),seed=rng.randrange(256),nested=True,count=rng.randrange(4097),read=rng.randrange(4096)))
    return out

def run(library,fixture=None):
    lib=C.CDLL(str(Path(library).resolve()))
    lib.vn135_template_publish_135.argtypes=[C.POINTER(View),C.POINTER(Ops),P];lib.vn135_template_publish_135.restype=None
    lib.vn135_nonce_fifo_reset.argtypes=[C.POINTER(Queue),C.POINTER(Sync)];lib.vn135_nonce_fifo_reset.restype=C.c_int
    e=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert sha(e.data)=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    cached=json.loads(Path(fixture).read_text()) if fixture and Path(fixture).exists() else None
    m=None if cached else Machine(e);pcs=set();steps=events=nested=0;records=[]
    for i,p in enumerate(scenarios()):
        if cached:assert cached[i]['parameters']==json.loads(json.dumps(p));expected=cached[i]['expected']
        else:
            w=World(p,m)
            # Trace reset entry without replacing original fa944/d212c instructions.
            original_extra=m.extra_instruction
            def observe(word,pc):
                if pc==0xfa944:w.event('reset')
                return original_extra(word,pc)
            m.extra_instruction=observe
            m.run(0xc3148,hooks=w.hooks(),max_steps=1000)
            m.extra_instruction=original_extra
            expected=w.finish();steps+=m.steps;pcs.update(m.visited)
        actual=World(p,lib=lib).native()
        assert actual==expected,('SEMANTIC_MISMATCH',i,p,actual,expected)
        events+=len(actual['events']);nested+=bool(p.get('nested'));records.append({'parameters':p,'expected':expected})
    if fixture and not cached:Path(fixture).write_text(json.dumps(records),encoding='utf-8')
    print(f'TEMPLATE_PUBLICATION_ORIGINAL_PASS cases={len(records)} events={events} steps={steps} pcs={len(pcs)} nested={nested}')
    return len(records)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('library');p.add_argument('--fixtures');a=p.parse_args();run(a.library,a.fixtures)
