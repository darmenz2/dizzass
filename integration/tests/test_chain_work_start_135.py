#!/usr/bin/env python3
"""Execute original c33d0/fef3c/fee4c, optionally d19b0, against typed C.

Selected path/open bodies are explicit trace boundaries. Their implementation
is not faked in production. Existing FIFO init is composed only for successful
allocation into an empty object; existing UART has its own old original oracle.
"""
import argparse,collections,ctypes as C,hashlib,itertools,json,random,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
U,I,B,P=C.c_uint32,C.c_int32,C.c_uint8,C.c_void_p
CHAIN=0x840100;PATH_SLOT=0x654b4c;OPEN_SLOT=0x654c18
PATHS=(0x115d10,0x11fe2c,0x11c080,0x1239a8,0x10cf84)
OPENS=(0x116dd8,0x10e0c8)
STORES=(0xfc92c,0xfbf00,0xfc15c,0xfc3cc,0xfd37c)
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class Thread(C.Structure):_fields_=[('handle',U),('running',B)]
class View(C.Structure):_fields_=[('index',C.POINTER(I)),('device_index',C.POINTER(I)),('worker',C.POINTER(Thread)),('path_method',C.POINTER(U)),('open_method',C.POINTER(U)),('chain',P),('mutex',P),('queue',P),('uart',P)]
COUNT=C.CFUNCTYPE(I,P);MUTEX=C.CFUNCTYPE(I,P,P,U);QUEUE=C.CFUNCTYPE(I,P,P,U,U)
PATH=C.CFUNCTYPE(P,P,U,I);OPEN=C.CFUNCTYPE(I,P,U,P,P)
CREATE=C.CFUNCTYPE(I,P,C.POINTER(U),U,U,P);LOG=C.CFUNCTYPE(None,P,U,U,U,U,U,U,C.c_size_t)
class Ops(C.Structure):_fields_=[('count',COUNT),('mutex',MUTEX),('queue',QUEUE),('path',PATH),('open',OPEN),('create',CREATE),('log',LOG)]
ALLOC=C.CFUNCTYPE(P,P,C.c_size_t);FREE=C.CFUNCTYPE(None,P,P)
class Memory(C.Structure):_fields_=[('context',P),('allocate',ALLOC),('release',FREE)]
class Fifo(C.Structure):_fields_=[('storage',P),('capacity',U),('stride',U),('count',U),('write_index',U),('read_index',U)]
RANGES=((0xc33d0,0xc369c),(0xfef3c,0xfef48),(0xfee4c,0xfeedc),(0xd19b0,0xd19f0))
class Machine(ARM32Verify):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES),('unexpected PC',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
def digest(x):return hashlib.sha256(x).hexdigest()
def signed(x):return I(x).value

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.calls=collections.Counter();self.errors=[];self.keep=[]
        self.buffer=C.create_string_buffer(832);C.memset(self.buffer,0xa5,832);self.ptr=C.addressof(self.buffer)+16
        C.memmove(self.ptr,bytes((i*11+p.get('seed',0))&255 for i in range(800)),800)
        self.index=I.from_address(self.ptr+0x18);self.index.value=p.get('index',0)
        self.device_index=I.from_address(self.ptr+0x2d0);self.device_index.value=p.get('device_index',77)
        self.worker=Thread.from_address(self.ptr+0x314);self.worker.handle=p.get('handle',11);self.worker.running=p.get('flag',0)
        self.path_method=U(p.get('path_method',PATHS[4]));self.open_method=U(p.get('open_method',OPENS[1]))
        self.count=p.get('count',3);self.path_value=p.get('path',0x845100);self.fifo=Fifo()
        self.view=View(C.pointer(self.index),C.pointer(self.device_index),C.pointer(self.worker),C.pointer(self.path_method),C.pointer(self.open_method),CHAIN,CHAIN+0x2e0,CHAIN+0x2f8,CHAIN+0x2b8)
        if p.get('nested'):C.memset(self.ptr+0x2f8,0,28)
        if m:
            m.reset([CHAIN]);m.visited=set();m.mem[CHAIN-16:CHAIN+816]=C.string_at(self.buffer,832)
            m.write(PATH_SLOT,self.path_method.value);m.write(OPEN_SLOT,self.open_method.value)
            for lit,pc8 in ((0xc369c,0xc33ec),(0xc36a0,0xc3400),(0xfeedc,0xfee68),(0xfeee0,0xfee7c)):
                m.write(m.read((m.read(lit)+pc8)&0xffffffff),p.get('opaque',0xffffffff))
    def sync(self):
        if self.p.get('nested') and self.fifo.storage:
            q=self.fifo;s=q.storage
            # Original +8 is write, +c is read. Both are zero after this init.
            for n,val in enumerate((s,s+q.capacity*q.stride,s+q.write_index*q.stride,s+q.read_index*q.stride,q.capacity,q.count,q.stride)):
                U.from_address(self.ptr+0x2f8+4*n).value=val
    def memory(self):
        if self.m:return bytes(self.m.mem[CHAIN:CHAIN+800])
        self.sync();return C.string_at(self.ptr,800)
    def snapshot(self):
        return [self.count&0xffffffff,self.path_value,self.m.read(PATH_SLOT) if self.m else self.path_method.value,self.m.read(OPEN_SLOT) if self.m else self.open_method.value,digest(self.memory())]
    def mutate(self,key,value):
        if key=='count':self.count=signed(value);return
        if key=='path_value':self.path_value=value;return
        offsets={'index':0x18,'device_index':0x2d0,'handle':0x314,'flag':0x318,'queue_word':0x300,'byte':0x31f}
        if self.m:
            addr={'path_method':PATH_SLOT,'open_method':OPEN_SLOT}.get(key,CHAIN+offsets.get(key,0))
            self.m.write(addr,value,1 if key in ('flag','byte') else 4);return
        if key in ('index','device_index','path_method','open_method'):getattr(self,key).value=value
        elif key in ('handle','flag'):setattr(self.worker,'handle' if key=='handle' else 'running',value)
        elif key=='byte':B.from_address(self.ptr+0x31f).value=value
        elif key=='queue_word':U.from_address(self.ptr+0x300).value=value
        else:raise AssertionError(key)
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1;assert len(self.events)<20
        self.events.append([name,list(args),self.snapshot()])
        for at,occ,key,value in self.p.get('mutations',[]):
            if (at,occ)==(name,n):self.mutate(key,value)
        return self.p.get(name+'_rc',0)
    def get_count(self):self.event('count');return self.count
    def mutex(self,obj,attr):return self.event('mutex',obj,attr)
    def allocate(self,size):self.event('allocate',size);return self.p.get('allocation',0x846000)
    def queue(self,obj,cap,stride,lib):
        if not self.p.get('nested'):return self.event('queue',obj,cap,stride)
        assert (obj,cap,stride)==(CHAIN+0x2f8,0x800,1)
        mem=Memory(None,self.callback(ALLOC,lambda _,n:self.allocate(n)),self.callback(FREE,lambda *_:self.errors.append('unexpected release')))
        f=lib.vn135_fifo_init;f.argtypes=[C.POINTER(Fifo),U,U,C.POINTER(Memory)];f.restype=I
        rc=f(C.byref(self.fifo),cap,stride,C.byref(mem));assert rc==0;self.sync();return rc
    def path(self,method,index):self.event('path',method,index&0xffffffff);return self.path_value
    def open(self,method,obj,path):return self.event('open',method,obj,path or 0)
    def create(self,handle,attr,entry,arg):
        assert handle==CHAIN+0x314
        rc=self.event('create',handle,attr,entry,arg)
        self.mutate('handle',self.p.get('created_handle',0xabcdef01));return rc
    def log(self,*args):self.event('log',*args)
    def callback(self,typ,fn):
        def cb(*args):
            try:return fn(*args)
            except BaseException as e:self.errors.append(repr(e));return None if typ in (LOG,FREE,ALLOC,PATH) else -1
        out=typ(cb);self.keep.append(out);return out
    def result(self,rc):
        if self.m:before=bytes(self.m.mem[CHAIN-16:CHAIN]);after=bytes(self.m.mem[CHAIN+800:CHAIN+816])
        else:before=C.string_at(self.buffer,16);after=C.string_at(self.ptr+800,16)
        assert before==after==b'\xa5'*16
        return {'return':signed(rc),'events':self.events,'final':self.snapshot(),'memory':self.memory().hex()}

def original(p,m):
    w=World(p,m)
    def call(fn,*args):m.r[0]=(fn(*args) or 0)&0xffffffff
    hooks={0xfe668:lambda _:call(w.get_count),0x5a60dc:lambda _:call(w.mutex,*m.r[:2]),
           0x5a55cc:lambda _:call(w.create,*m.r[:4]),
           0xfa0c4:lambda _:call(w.log,*m.r[:4],m.read(m.r[13]),m.read(m.r[13]+4),m.read(m.r[13]+8))}
    hooks.update({a:lambda _:call(w.path,m.r[15],m.r[0]) for a in PATHS})
    hooks.update({a:lambda _:call(w.open,m.r[15],m.r[0],m.r[1]) for a in OPENS})
    if p.get('nested'):hooks[0x5940ec]=lambda _:call(w.allocate,m.r[0])
    else:hooks[0xd19b0]=lambda _:call(w.event,'queue',*m.r[:3])
    m.run(0xc33d0,hooks=hooks,max_steps=1200);return w.result(m.r[0])
def native(p,lib):
    w=World(p)
    def create(_,ptr,a,e,obj):
        assert C.addressof(ptr.contents)==w.ptr+0x314
        return w.create(CHAIN+0x314,a,e,obj)
    ops=Ops(w.callback(COUNT,lambda _:w.get_count()),w.callback(MUTEX,lambda _,o,a:w.mutex(o,a)),
        w.callback(QUEUE,lambda _,o,c,s:w.queue(o,c,s,lib)),w.callback(PATH,lambda _,m,i:w.path(m,i)),
        w.callback(OPEN,lambda _,m,o,p:w.open(m,o,p)),w.callback(CREATE,create),w.callback(LOG,lambda _,*a:w.log(*a)))
    f=lib.vn135_chain_work_start_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=I
    rc=f(C.byref(w.view),C.byref(ops),None);assert not w.errors,('MISMATCH callback',w.errors)
    return w.result(rc)

def cases():
    yield {}
    for index,count,flag in itertools.product((-2147483648,-1,0,1,3,2147483647),(-2147483648,-1,0,1,3,2147483647),(0,1,2,128,255)):
        yield {'index':index,'count':count,'flag':flag,'handle':0}
    for opened,created,init,path in itertools.product((0,-1,1,-2147483648,2147483647),(0,-1,11,-2147483648,2147483647),(0,-19),(0,0x845100,0xffffffff)):
        yield {'open_rc':opened,'create_rc':created,'mutex_rc':init,'queue_rc':init,'path':path}
    for path,opened in itertools.product(PATHS,OPENS):yield {'path_method':path,'open_method':opened}
    boundaries=('count','mutex','queue','path','open','create','log')
    changes=[('count',0),('index',0xffffffff),('index',0x7fffffff),('index',2),('device_index',42),('flag',0),('flag',255),('handle',0),('handle',0xdeadbeef),('path_method',PATHS[0]),('open_method',OPENS[0]),('path_value',0),('path_value',0x845200),('queue_word',99),('byte',0)]
    for name,(key,value),rc in itertools.product(boundaries,changes,(0,-1)):
        yield {'create_rc':rc,'mutations':[(name,0,key,value)]}
        if name in ('open','log'):yield {'open_rc':-1,'mutations':[(name,0,key,value)]}
    for index,count,new_index in itertools.product((-1,0,2147483647),(-1,0,1,3),(0,1,0x80000000,0xffffffff)):
        yield {'index':index,'count':count,'mutations':[('count',0,'index',new_index)]}
    rng=random.Random(0xc33d0)
    for _ in range(220):
        mutations=[(rng.choice(boundaries),0,*rng.choice(changes)) for _ in range(3)]
        yield {'index':rng.choice([-1,0,1]),'count':rng.choice([-1,0,1,3]),'flag':rng.choice([0,0,255]),'seed':rng.getrandbits(32),'opaque':rng.getrandbits(32),'handle':rng.getrandbits(32),'open_rc':rng.choice([0,0,-1]),'create_rc':rng.choice([0,-5]),'mutations':mutations}
    # Existing FIFO initialization only: empty valid object, successful allocation.
    for opened,created,allocation in itertools.product((0,-1,1),(0,-1,1),(0x846000,0x846800)):
        yield {'nested':True,'open_rc':opened,'create_rc':created,'allocation':allocation}
    for name in ('count','mutex','allocate','path','open','create'):
        for key,value in changes:
            if key!='queue_word':yield {'nested':True,'mutations':[(name,0,key,value)]}

class Assigned(Exception):pass
class Probe(ARM32Verify):
    def extra_instruction(self,w,pc):
        assert 0xfb994<=pc<0xfddfc,('unreviewed initializer PC',hex(pc))
        return super().extra_instruction(w,pc)
    def write(self,a,v,n=4):
        super().write(a,v,n)
        if a in (PATH_SLOT,OPEN_SLOT):
            self.found[a]=[self.r[15]-4,v]
            if len(self.found)==2:raise Assigned()
def provenance(elf):
    records=[]
    for controller,model,subtype in itertools.product(range(5),(0,4,7),(0,1,0xffffffff)):
        m=Probe(elf);m.found={};m.reset([controller,model,subtype,0])
        try:m.run(0xfb994,max_steps=1000)
        except Assigned:
            assert m.found=={OPEN_SLOT:[0xfbbd8,OPENS[controller!=0]],PATH_SLOT:[STORES[controller],PATHS[controller]]}
            assert m.read(0x654b08)==controller and m.read(0x654b0c)==model
            records.append([controller,model,subtype,*m.found[OPEN_SLOT],*m.found[PATH_SLOT],m.steps])
        else:raise AssertionError('assignments not reached')
    return records
def fixtures():
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert digest(elf.data)==SHA
    m=Machine(elf);items=[];steps=events=nested_calls=0;visited=set()
    for p in cases():
        expected=original(p,m);items.append([p,expected]);steps+=m.steps;events+=len(expected['events']);visited.update(m.visited)
        nested_calls+=any(e[0]=='allocate' for e in expected['events'])
    return items,dict(cases=len(items),nested_calls=nested_calls,events=events,steps=steps,pcs=len(visited),provenance=len(provenance(elf)))
def compare(items,lib):
    for i,(p,expected) in enumerate(items):
        actual=native(p,lib)
        if 'memory' not in expected:actual.pop('memory')
        assert actual==expected,('MISMATCH',i,p,str(actual)[:1000],str(expected)[:1000])
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--fixtures');a=ap.parse_args()
    if a.fixtures:
        items=json.loads(Path(a.fixtures).read_text())
        try:compare(items,C.CDLL(str(Path(a.library).resolve())))
        except AssertionError as e:print('SEMANTIC_MISMATCH',str(e)[:600]);raise SystemExit(3)
        print(f'BASELINE_FIXTURES_PASS cases={len(items)}')
    else:
        items,counts=fixtures();compare(items,C.CDLL(str(Path(a.library).resolve())))
        print('CHAIN_WORK_START_ORIGINAL_PASS '+' '.join(f'{k}={v}' for k,v in counts.items()))
