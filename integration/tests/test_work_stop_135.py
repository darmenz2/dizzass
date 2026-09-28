#!/usr/bin/env python3
"""Original c3e18 instructions versus C. No firmware process or OS thread."""
import argparse,collections,ctypes as C,hashlib,itertools,json,random,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
U,I,B,P=C.c_uint32,C.c_int32,C.c_uint8,C.c_void_p
BACK=0x840100;SIZE=0x1348;BANKS=[0x844100,0x848100];N=8;STRIDE=800
HANDLES=[0x1068,0x1060,0x1058];FLAGS=[x+4 for x in HANDLES]
OBJECTS=[0x633bc0,0x633ba8,0x633b08,0x633af0];METHODS=[0xc39a8,0xbfb94,0xc1970]
class Thread(C.Structure):_fields_=[('handle',U),('running',B)]
class Chain(C.Structure):_fields_=[('enabled',C.POINTER(B)),('object',P)]
class View(C.Structure):_fields_=[('producer',C.POINTER(Thread)),('receiver',C.POINTER(Thread)),('sender',C.POINTER(Thread)),('chains',C.POINTER(Chain)),('method',U)]
COUNT=C.CFUNCTYPE(I,P);CANCEL=C.CFUNCTYPE(I,P,U);JOIN=C.CFUNCTYPE(I,P,U,C.POINTER(U))
DESTROY=C.CFUNCTYPE(I,P,U,U);CHAIN=C.CFUNCTYPE(I,P,U,P)
class Ops(C.Structure):_fields_=[('count',COUNT),('cancel',CANCEL),('join',JOIN),('destroy',DESTROY),('chain',CHAIN)]
class Machine(ARM32Verify):
    def extra_instruction(self,w,pc):
        assert 0xc3e18<=pc<0xc4038,('unexpected PC',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
def digest(x):return hashlib.sha256(x).hexdigest()
def signed(x):return x-0x100000000 if x&0x80000000 else x

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.calls=collections.Counter();self.errors=[];self.keep=[]
        self.count=p.get('count',3)&0xffffffff;self.objects=[0xdddd0000+i for i in range(4)]
        self.buffers=[C.create_string_buffer(size+32) for size in [SIZE,N*STRIDE,N*STRIDE]]
        self.pointers=[C.addressof(b)+16 for b in self.buffers]
        for j,(b,n) in enumerate(zip(self.buffers,[SIZE,N*STRIDE,N*STRIDE])):
            C.memset(b,0xa5,n+32);C.memmove(self.pointers[j],bytes((i*11+i//13+j*53+p.get('seed',0))&255 for i in range(n)),n)
        self.threads=[Thread.from_buffer(self.buffers[0],16+off) for off in HANDLES]
        for i,t in enumerate(self.threads):t.handle=p.get('handles',[11,22,33])[i];t.running=p.get('flags',[1,1,1])[i]
        self.bank_views=[]
        for bank in range(2):
            views=(Chain*N)()
            for i in range(N):
                at=self.pointers[bank+1]+i*STRIDE+0x318
                B.from_address(at).value=p.get('enabled',[[1]*N,[255]*N])[bank][i]
                views[i]=Chain(C.cast(at,C.POINTER(B)),BANKS[bank]+i*STRIDE)
            self.bank_views.append(views)
        self.base=p.get('base',0);self.view=View(*[C.pointer(t) for t in self.threads],self.bank_views[self.base],p.get('method',METHODS[0]))
        U.from_address(self.pointers[0]+0x230).value=BANKS[self.base];U.from_address(self.pointers[0]+0x200).value=self.view.method
        self.saved_thread_pointers=[C.addressof(t) for t in self.threads]
        if m:
            m.reset([BACK]);m.visited=set()
            for addr,b,n in zip([BACK]+BANKS,self.buffers,[SIZE,N*STRIDE,N*STRIDE]):m.mem[addr-16:addr+n+16]=C.string_at(b,n+32)
            for addr,value in zip(OBJECTS,self.objects):m.write(addr,value)
            for slot in (0x5de7ec,0x5dfb90):m.write(m.read(slot),p.get('opaque',0xffffffff))
    def memory(self):
        return [bytes(self.m.mem[a:a+n]) for a,n in zip([BACK]+BANKS,[SIZE,N*STRIDE,N*STRIDE])] if self.m else [C.string_at(a,n) for a,n in zip(self.pointers,[SIZE,N*STRIDE,N*STRIDE])]
    def snapshot(self):
        return [self.count,[digest(x) for x in self.memory()],[self.m.read(a) for a in OBJECTS] if self.m else list(self.objects)]
    def mutate(self,key,value):
        if key=='count':self.count=value&0xffffffff
        elif key=='base':
            assert value in (0,1)
            if self.m:self.m.write(BACK+0x230,BANKS[value])
            else:self.base=value;self.view.chains=self.bank_views[value];U.from_address(self.pointers[0]+0x230).value=BANKS[value]
        elif key=='method':
            assert value in METHODS
            if self.m:self.m.write(BACK+0x200,value)
            else:self.view.method=value;U.from_address(self.pointers[0]+0x200).value=value
        elif key.startswith('handle') or key.startswith('flag'):
            i=int(key[-1]);field='handle' if key.startswith('handle') else 'running';off=HANDLES[i] if field=='handle' else FLAGS[i]
            if self.m:self.m.write(BACK+off,value,4 if field=='handle' else 1)
            else:setattr(self.threads[i],field,value)
        elif key.startswith('enabled'):
            bank,i=map(int,key[7:].split('_'));assert 0<=i<N
            if self.m:self.m.write(BANKS[bank]+i*STRIDE+0x318,value,1)
            else:B.from_address(self.pointers[bank+1]+i*STRIDE+0x318).value=value
        elif key=='byte':
            if self.m:self.m.write(BACK+0x1080,value,1)
            else:B.from_address(self.pointers[0]+0x1080).value=value
        else:raise AssertionError(key)
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1;assert len(self.events)<50,'callback budget'
        self.events.append([name,list(args),self.snapshot()])
        for at,index,key,value in self.p.get('mutations',[]):
            if (at,index)==(name,n):self.mutate(key,value)
        return self.p.get('rc',-17)
    def get_count(self):self.event('count');return signed(self.count)
    def cancel(self,handle):return self.event('cancel',handle)
    def join(self,handle,result):assert not result;return self.event('join',handle,0)
    def destroy(self,entry,identity):
        rc=self.event('destroy',entry,identity);i=OBJECTS.index(identity)
        value=(0xee000000+self.calls['destroy'])&0xffffffff
        if self.m:self.m.write(identity,value)
        else:self.objects[i]=value
        return rc
    def chain(self,method,obj):
        assert method in METHODS and any(a<=obj<a+N*STRIDE and (obj-a)%STRIDE==0 for a in BANKS)
        return self.event('chain',method,obj)
    def result(self,rc):
        for addr,buf,n in zip([BACK]+BANKS,self.buffers,[SIZE,N*STRIDE,N*STRIDE]):
            if self.m:before=bytes(self.m.mem[addr-16:addr]);after=bytes(self.m.mem[addr+n:addr+n+16])
            else:before=C.string_at(buf,16);after=C.string_at(C.addressof(buf)+16+n,16)
            assert before==after==b'\xa5'*16
        if not self.m:assert [C.addressof(t.contents) for t in (self.view.producer,self.view.receiver,self.view.sender)]==self.saved_thread_pointers
        return {'rc':rc&0xffffffff,'events':self.events,'final':self.snapshot(),'memory':[x.hex() for x in self.memory()]}

def original(p,m):
    w=World(p,m)
    def count(_):m.r[0]=w.get_count()&0xffffffff
    def cancel(_):m.r[0]=w.cancel(m.r[0])&0xffffffff
    def join(_):m.r[0]=w.join(m.r[0],m.r[1])&0xffffffff
    def destroy(_):m.r[0]=w.destroy(m.r[15],m.r[0])&0xffffffff
    def chain(_):m.r[0]=w.chain(m.r[15],m.r[0])&0xffffffff
    rc=m.run(0xc3e18,hooks={0xfe668:count,0x5a4754:cancel,0x5a5d2c:join,0x5a4954:destroy,0x5a60b8:destroy,**{a:chain for a in METHODS}},max_steps=3000)
    return w.result(rc)

def cases():
    yield {}
    for flags in itertools.product((0,1,2,128,255),repeat=3):
        yield {'flags':flags,'handles':[0,0xffffffff,0x80000000]}
    for count,rc in itertools.product((-2147483648,-1,0,1,2,3,8),(0,1,-1,-2147483648,2147483647)):
        yield {'count':count,'rc':rc,'enabled':[[0,2,0,128,1,255,0,1],[1]*N]}
    for base,method,pattern in itertools.product((0,1),METHODS,([0]*N,[1]*N,[255]*N,[0,2,0,128,1,255,0,1])):
        yield {'base':base,'method':method,'count':8,'enabled':[pattern,pattern]}
    # Each boundary can change later live reads; the count is cached once.
    boundaries=[('count',0)]+[(name,i) for name,n in [('cancel',3),('join',3),('destroy',4),('chain',3)] for i in range(n)]
    changes=[('count',0),('count',8),('base',1),('method',METHODS[1]),('byte',0),
             *[(f'handle{i}',0xdead0000+i) for i in range(3)],
             *[(f'flag{i}',v) for i in range(3) for v in (0,255)],
             *[(f'enabled{bank}_{i}',0) for bank in range(2) for i in range(3)]]
    for (name,at),(key,value) in itertools.product(boundaries,changes):
        yield {'mutations':[(name,at,key,value)]}
    yield {'count':8,'mutations':[("chain",0,"base",1),("chain",1,"base",0),
        ("chain",0,"method",METHODS[2]),("chain",3,"method",METHODS[1])]}
    rng=random.Random(0xc3e18)
    for _ in range(200):
        name,at=rng.choice(boundaries);key,value=rng.choice(changes)
        yield {'count':rng.choice([-1,0,1,3,8]),'seed':rng.getrandbits(32),'opaque':rng.getrandbits(32),
            'flags':[rng.choice([0,1,2,255]) for _ in range(3)],'handles':[rng.getrandbits(32) for _ in range(3)],
            'base':rng.randrange(2),'method':rng.choice(METHODS),'rc':rng.choice([0,-1,17,-2147483648]),
            'enabled':[[rng.choice([0,1,128,255]) for _ in range(N)] for _ in range(2)],
            'mutations':[(name,at,key,value)]}

def fixtures():
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert digest(elf.data)=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    m=Machine(elf);items=[];steps=events=0;visited=set()
    for p in cases():
        result=original(p,m);items.append([p,result]);steps+=m.steps;events+=len(result['events']);visited.update(m.visited)
    return items,{'cases':len(items),'events':events,'steps':steps,'pcs':len(visited)}
def compare(items,lib):
    for i,(p,expected) in enumerate(items):
        actual=native(p,lib)
        if 'memory' not in expected:actual.pop('memory') # compact negative fixtures retain every memory hash
        assert actual==expected,('MISMATCH',i,p,str(actual)[:600],str(expected)[:600])
def native(p,lib):
    w=World(p)
    def cb(typ,fn):
        def wrap(*args):
            try:return fn(*args)
            except BaseException as e:w.errors.append(repr(e));return -1
        value=typ(wrap);w.keep.append(value);return value
    ops=Ops(cb(COUNT,lambda _:w.get_count()),cb(CANCEL,lambda _,h:w.cancel(h)),cb(JOIN,lambda _,h,r:w.join(h,r)),
        cb(DESTROY,lambda _,e,i:w.destroy(e,i)),cb(CHAIN,lambda _,e,o:w.chain(e,o)))
    f=lib.vn135_work_stop_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=I
    rc=f(C.byref(w.view),C.byref(ops),None);assert not w.errors,('MISMATCH callback arguments',w.errors)
    return w.result(rc)

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--fixtures');ap.add_argument('--save-fixtures');a=ap.parse_args()
    if a.fixtures:
        items=json.loads(Path(a.fixtures).read_text())
        try:compare(items,C.CDLL(str(Path(a.library).resolve())))
        except AssertionError as error:
            print('SEMANTIC_MISMATCH',str(error)[:600]);raise SystemExit(3)
        print(f'BASELINE_FIXTURES_PASS cases={len(items)}')
    else:
        items,counts=fixtures();compare(items,C.CDLL(str(Path(a.library).resolve())))
        if a.save_fixtures:
            for _,result in items:result.pop('memory')
            Path(a.save_fixtures).write_text(json.dumps(items))
        print('WORK_STOP_ORIGINAL_PASS '+' '.join(f'{k}={v}' for k,v in counts.items()))
