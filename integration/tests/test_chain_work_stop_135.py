#!/usr/bin/env python3
"""Original c39a8/d2144/feeec versus C; optional existing UART composition."""
import argparse,collections,ctypes as C,hashlib,itertools,json,random,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
U,I,B,P=C.c_uint32,C.c_int32,C.c_uint8,C.c_void_p
CHAIN=0x840100;QUEUE=0x633bf0;SLOT=0x654c1c;METHODS=(0x116f00,0x10e9a0)
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class Thread(C.Structure):_fields_=[('handle',U),('running',B)]
class View(C.Structure):_fields_=[('index',C.POINTER(I)),('worker',C.POINTER(Thread)),('head',C.POINTER(U)),('tail',C.POINTER(U)),('allocation',C.POINTER(P)),('method',C.POINTER(U)),('queue',P),('mutex',P),('uart',P)]
COUNT=C.CFUNCTYPE(I,P);MUTEX=C.CFUNCTYPE(I,P,U,P);CANCEL=C.CFUNCTYPE(I,P,U);JOIN=C.CFUNCTYPE(I,P,U,C.POINTER(U))
FREE=C.CFUNCTYPE(None,P,P);UART=C.CFUNCTYPE(None,P,U,P);LOG=C.CFUNCTYPE(None,P,U,U,U,U,U,U,U)
class Ops(C.Structure):_fields_=[('count',COUNT),('mutex',MUTEX),('cancel',CANCEL),('join',JOIN),('release',FREE),('uart',UART),('log',LOG)]
class Uart(C.Structure):_fields_=[('path',P),('fd',I),('baud',U),('ready',C.c_bool)]
CLOSE=C.CFUNCTYPE(I,P,I);VOID=C.CFUNCTYPE(None,P)
# Unused callback slots are NULL. They are not successful hardware substitutes.
class UartOps(C.Structure):_fields_=[('context',P),('open',P),('duplicate',P),('release',FREE),('ioctl',P),('read',P),('write',P),('errno',P),('close',CLOSE),('flush',P),('init',P),('lock',P),('unlock',P),('destroy',VOID),('sleep',P)]
RANGES=((0xc39a8,0xc3b38),(0xd2144,0xd21d4),(0xfeeec,0xfeef8),(0x10e9a0,0x10ea54))
class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES),('unexpected PC',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
def digest(x):return hashlib.sha256(x).hexdigest()
def signed(x):return C.c_int32(x).value

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.calls=collections.Counter();self.errors=[];self.keep=[]
        self.buffers=[C.create_string_buffer(n+32) for n in (800,40)]
        self.ptrs=[C.addressof(b)+16 for b in self.buffers]
        for j,(buf,n) in enumerate(zip(self.buffers,(800,40))):
            C.memset(buf,0xa5,n+32);C.memmove(self.ptrs[j],bytes((i*11+j*19+p.get('seed',0))&255 for i in range(n)),n)
        self.index=I.from_address(self.ptrs[0]+0x18);self.index.value=p.get('index',0)
        self.worker=Thread.from_address(self.ptrs[0]+0x314);self.worker.handle=p.get('handle',11);self.worker.running=p.get('flag',1)
        self.head=U.from_address(self.ptrs[1]+0x18);self.tail=U.from_address(self.ptrs[1]+0x1c)
        self.head.value=p.get('head',27);self.tail.value=p.get('tail',19)
        self.allocation=P(p.get('allocation',0x860100));self.method=U(p.get('method',METHODS[1]));self.count=p.get('count',3)
        self.uart=Uart(p.get('path',0x860200),p.get('fd',5),p.get('baud',115200),True)
        self.view=View(C.pointer(self.index),C.pointer(self.worker),C.pointer(self.head),C.pointer(self.tail),C.pointer(self.allocation),C.pointer(self.method),QUEUE,CHAIN+0x2e0,CHAIN+0x2b8)
        self.sync()
        if m:
            m.reset([CHAIN]);m.visited=set()
            for a,buf,n in zip((CHAIN,QUEUE),self.buffers,(800,40)):m.mem[a-16:a+n+16]=C.string_at(buf,n+32)
            m.write(SLOT,self.method.value)
            for lit,pc8 in ((0xc3b48,0xc39e8),(0xc3b4c,0xc39fc),(0xd21d4,0xd2168),(0xd21d8,0xd217c),(0x10ea54,0x10e9e8),(0x10ea58,0x10e9fc)):
                m.write(m.read((m.read(lit)+pc8)&0xffffffff),p.get('opaque',0xffffffff))
    def sync(self):
        for off,val in ((0x2f8,self.allocation.value or 0),(0x2d4,self.uart.path or 0),(0x2d8,self.uart.fd),(0x2dc,self.uart.baud)):
            U.from_address(self.ptrs[0]+off).value=val
    def memory(self):
        if self.m:return [bytes(self.m.mem[a:a+n]) for a,n in ((CHAIN,800),(QUEUE,40))]
        self.sync();return [C.string_at(a,n) for a,n in zip(self.ptrs,(800,40))]
    def snapshot(self):return [self.count&0xffffffff,self.m.read(SLOT) if self.m else self.method.value,*map(digest,self.memory())]
    def mutate(self,key,value):
        if key=='count':self.count=signed(value);return
        offsets={'index':0x18,'handle':0x314,'flag':0x318,'allocation':0x2f8,'path':0x2d4,'fd':0x2d8,'baud':0x2dc,'byte':0x31f}
        if self.m:
            addr=SLOT if key=='method' else QUEUE+(0x18 if key=='head' else 0x1c) if key in ('head','tail') else CHAIN+offsets[key]
            self.m.write(addr,value,1 if key in ('flag','byte') else 4);return
        if key in ('index','head','tail','method','allocation'):getattr(self,key).value=value
        elif key in ('handle','flag'):setattr(self.worker,'handle' if key=='handle' else 'running',value)
        elif key in ('path','fd','baud'):setattr(self.uart,key,value)
        elif key=='byte':B.from_address(self.ptrs[0]+0x31f).value=value
        else:raise AssertionError(key)
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1;assert len(self.events)<25
        self.events.append([name,list(args),self.snapshot()])
        for at,occ,key,value in self.p.get('mutations',[]):
            if (at,occ)==(name,n):self.mutate(key,value)
        return self.p.get('rc',-17)
    def get_count(self):self.event('count');return self.count
    def mutex(self,entry,obj):return self.event('mutex',entry,obj)
    def cancel(self,h):return self.event('cancel',h)
    def join(self,h,r):assert not r;return self.event('join',h,0)
    def release(self,p):self.event('release',p)
    def log(self,*args):self.event('log',*args)
    def destroy(self,method,obj,lib=None):
        assert method in METHODS and obj==CHAIN+0x2b8
        if not self.p.get('nested'):self.event('uart',method,obj);return
        assert method==0x10e9a0
        ops=UartOps();ops.release=self.callback(FREE,lambda _,p:self.event('uart_release',p))
        ops.close=self.callback(CLOSE,lambda _,fd:self.event('close',fd&0xffffffff))
        ops.destroy=self.callback(VOID,lambda _:self.event('uart_mutex_destroy',CHAIN+0x2b8))
        f=lib.vn135_uart_destroy;f.argtypes=[C.POINTER(Uart),C.POINTER(UartOps)];f.restype=I
        assert f(C.byref(self.uart),C.byref(ops))==0 and not self.uart.ready
    def callback(self,typ,fn):
        def cb(*args):
            try:return fn(*args)
            except BaseException as e:self.errors.append(repr(e));return None if typ in (FREE,VOID,UART,LOG) else -1
        out=typ(cb);self.keep.append(out);return out
    def result(self):
        for a,buf,n in zip((CHAIN,QUEUE),self.buffers,(800,40)):
            if self.m:before=bytes(self.m.mem[a-16:a]);after=bytes(self.m.mem[a+n:a+n+16])
            else:before=C.string_at(buf,16);after=C.string_at(C.addressof(buf)+16+n,16)
            assert before==after==b'\xa5'*16
        return {'events':self.events,'final':self.snapshot(),'memory':[x.hex() for x in self.memory()]}

def original(p,m):
    w=World(p,m)
    def call(fn,*args):m.r[0]=(fn(*args) or 0)&0xffffffff
    def release(_):
        if m.r[14]==0xd2194:call(w.release,m.r[0])
        else:assert p.get('nested') and m.r[14]==0x10e9bc;call(w.event,'uart_release',m.r[0])
    hooks={0xfe668:lambda _:call(w.get_count),0x5a6108:lambda _:call(w.mutex,0x5a6108,m.r[0]),
           0x5a66c4:lambda _:call(w.mutex,0x5a66c4,m.r[0]),0x5a4754:lambda _:call(w.cancel,m.r[0]),
           0x5a5d2c:lambda _:call(w.join,m.r[0],m.r[1]),0x593c8c:release,
           0xfa0c4:lambda _:call(w.log,*m.r[:4],m.read(m.r[13]),m.read(m.r[13]+4),m.read(m.r[13]+8))}
    if p.get('nested'):
        hooks.update({0x5a811c:lambda _:call(w.event,'close',m.r[0]),0x5a60b8:lambda _:call(w.event,'uart_mutex_destroy',m.r[0])})
    else:hooks.update({a:lambda _:call(w.destroy,m.r[15],m.r[0]) for a in METHODS})
    m.run(0xc39a8,hooks=hooks,max_steps=1500);return w.result()
def native(p,lib):
    w=World(p)
    ops=Ops(w.callback(COUNT,lambda _:w.get_count()),w.callback(MUTEX,lambda _,e,o:w.mutex(e,o)),
        w.callback(CANCEL,lambda _,h:w.cancel(h)),w.callback(JOIN,lambda _,h,r:w.join(h,r)),
        w.callback(FREE,lambda _,p:w.release(p)),w.callback(UART,lambda _,e,o:w.destroy(e,o,lib)),w.callback(LOG,lambda _,*a:w.log(*a)))
    f=lib.vn135_chain_work_stop_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=None
    f(C.byref(w.view),C.byref(ops),None);assert not w.errors,('MISMATCH callback',w.errors)
    return w.result()

def cases():
    yield {}
    for index,count,flag in itertools.product((-2147483648,-1,0,1,3,2147483647),(-2147483648,-1,0,1,3,2147483647),(0,1,2,128,255)):
        yield {'index':index,'count':count,'flag':flag,'handle':0}
    for ptr,handle,method,rc in itertools.product((0,0x860100,0xffffffff),(0,0xffffffff,0x80000000),METHODS,(0,-1,2147483647,-2147483648)):
        yield {'allocation':ptr,'handle':handle,'method':method,'rc':rc}
    boundaries=[('count',0),('mutex',0),('mutex',1),('cancel',0),('join',0),('mutex',2),('release',0),('mutex',3),('uart',0)]
    changes=[('count',0),('index',0xffffffff),('flag',0),('flag',255),('handle',0),('handle',0xdeadbeef),('allocation',0),('allocation',0x860300),('head',99),('tail',77),('method',METHODS[0]),('byte',0)]
    for (name,occ),(key,value) in itertools.product(boundaries,changes):yield {'mutations':[(name,occ,key,value)]}
    for index,count,new_index in itertools.product((0,1,2147483647),(-1,0,1),(0,5,0x80000000,0xffffffff)):
        yield {'index':index,'count':count,'mutations':[('count',0,'index',new_index)]}
    rng=random.Random(0xc39a8)
    for _ in range(160):
        name,occ=rng.choice(boundaries);key,value=rng.choice(changes)
        yield {'index':rng.choice([-1,0,1]),'count':rng.choice([-1,0,1,3]),'flag':rng.choice([0,1,255]),'seed':rng.getrandbits(32),
            'opaque':rng.getrandbits(32),'allocation':rng.choice([0,0x860100]),'handle':rng.getrandbits(32),'mutations':[(name,occ,key,value)]}
    # Existing uart_destroy: first initialized destruction, fd >= -1, stable UART fields.
    for path,fd,flag,rc in itertools.product((0,0x860200),(-1,0,7,2147483647),(0,1,255),(0,-17)):
        yield {'nested':True,'path':path,'fd':fd,'flag':flag,'rc':rc}
    for name,occ in boundaries[:-1]:
        yield {'nested':True,'mutations':[(name,occ,'handle',0xabcdef01),(name,occ,'allocation',0)]}

class Assigned(Exception):pass
class Probe(ARM32):
    def extra_instruction(self,w,pc):
        assert 0xfb994<=pc<0xfddfc,('unreviewed initialization PC',hex(pc))
        return super().extra_instruction(w,pc)
    def write(self,a,v,n=4):
        super().write(a,v,n)
        if a==SLOT:raise Assigned((self.r[15]-4,v))
def provenance(elf):
    records=[]
    for controller,model,subtype in itertools.product(range(5),(0,4,7),(0,1,0xffffffff)):
        m=Probe(elf);m.reset([controller,model,subtype,0])
        try:m.run(0xfb994,max_steps=1000)
        except Assigned as found:
            pc,target=found.args[0];assert pc==0xfbbfc and target==METHODS[controller!=0]
            assert m.read(0x654b08)==controller and m.read(0x654b0c)==model
            records.append([controller,model,subtype,pc,target,m.steps])
        else:raise AssertionError('assignment not reached')
    return records
def fixtures():
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert digest(elf.data)==SHA
    m=Machine(elf);items=[];steps=events=0;visited=set();nested=nested_calls=0
    for p in cases():
        expected=original(p,m);items.append([p,expected]);steps+=m.steps;events+=len(expected['events']);visited.update(m.visited);nested+=bool(p.get('nested'))
        nested_calls+=any(e[0]=='uart_mutex_destroy' for e in expected['events'])
    return items,dict(cases=len(items),nested=nested,nested_calls=nested_calls,events=events,steps=steps,pcs=len(visited),provenance=len(provenance(elf)))
def compare(items,lib):
    for i,(p,expected) in enumerate(items):
        actual=native(p,lib)
        if 'memory' not in expected:actual.pop('memory')
        assert actual==expected,('MISMATCH',i,p,str(actual)[:650],str(expected)[:650])
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--fixtures');a=ap.parse_args()
    if a.fixtures:
        items=json.loads(Path(a.fixtures).read_text())
        try:compare(items,C.CDLL(str(Path(a.library).resolve())))
        except AssertionError as e:print('SEMANTIC_MISMATCH',str(e)[:600]);raise SystemExit(3)
        print(f'BASELINE_FIXTURES_PASS cases={len(items)}')
    else:
        items,counts=fixtures();compare(items,C.CDLL(str(Path(a.library).resolve())))
        print('CHAIN_WORK_STOP_ORIGINAL_PASS '+' '.join(f'{k}={v}' for k,v in counts.items()))
