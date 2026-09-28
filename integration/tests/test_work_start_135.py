#!/usr/bin/env python3
"""Full original c3b54 versus C; OS effects remain deterministic boundaries."""
import argparse,ctypes as C,hashlib,itertools,json,random,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
U,I,P=C.c_uint32,C.c_int32,C.c_void_p
BACK=0x840100;SIZE=0x1348;FIELDS=[0x1060,0x1068,0x1058]
OBJECTS=[0x633af0,0x633b08,0x633ba8,0x633bc0];SLOT=0x5df978
ATTR=C.CFUNCTYPE(I,P,U,C.POINTER(U),U)
INIT=C.CFUNCTYPE(I,P,U,U,C.POINTER(U))
CREATE=C.CFUNCTYPE(I,P,U,C.POINTER(U),U,U,P)
LOG=C.CFUNCTYPE(None,P,U,U,U,U,U,U)
class View(C.Structure):
    _fields_=[('backend',P),('rx',C.POINTER(U)),('producer',C.POINTER(U)),('tx',C.POINTER(U)),('entry',C.POINTER(U)),('seed',U)]
class Ops(C.Structure):_fields_=[('attribute',ATTR),('initialize',INIT),('create',CREATE),('log',LOG)]
class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert 0xc3b54<=pc<0xc3db4,('unexpected PC',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
def digest(data):return hashlib.sha256(data).hexdigest()

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.keep=[];self.errors=[];self.attr_ptr=None
        self.attr=p.get('seed',0xa1b2c3d4);self.entry=U(p.get('entry',0xc2498));self.objects=[0x98980000+i for i in range(4)]
        self.buf=C.create_string_buffer(SIZE+32);C.memset(self.buf,0xa5,SIZE+32)
        self.data=C.addressof(self.buf)+16;self.initial=bytes((i*13+i//7)&255 for i in range(SIZE));C.memmove(self.data,self.initial,SIZE)
        for i,off in enumerate(FIELDS):U.from_address(self.data+off).value=0x87654320+i
        self.view=View(BACK,*[C.cast(self.data+off,C.POINTER(U)) for off in FIELDS],C.pointer(self.entry),self.attr)
        self.saved_view=bytes(self.view)
        if m:
            m.reset([BACK]);m.visited=set();self.attr_address=m.STACK_TOP-36
            m.write(self.attr_address,self.attr);m.mem[BACK-16:BACK+SIZE+16]=C.string_at(self.buf,SIZE+32)
            m.write(SLOT,self.entry.value)
            for a,v in zip(OBJECTS,self.objects):m.write(a,v)
            for slot in (0x5df468,0x5deec0):m.write(m.read(slot),p.get('opaque',0xffffffff))
    def snapshot(self):
        if self.m:
            return [digest(bytes(self.m.mem[BACK:BACK+SIZE])),self.m.read(SLOT),self.m.read(self.attr_address),[self.m.read(a) for a in OBJECTS]]
        return [digest(C.string_at(self.data,SIZE)),self.entry.value,self.attr,list(self.objects)]
    def mutate(self,key,value):
        if key=='attr':
            self.attr=value
            if self.m:self.m.write(self.attr_address,value)
            else:
                assert self.attr_ptr is not None;self.attr_ptr[0]=value
        elif key=='entry':
            if self.m:self.m.write(SLOT,value)
            else:self.entry.value=value
        elif key in ('rx','producer','tx'):
            off=FIELDS[['rx','producer','tx'].index(key)]
            if self.m:self.m.write(BACK+off,value)
            else:U.from_address(self.data+off).value=value
        elif key.startswith('object'):
            i=int(key[-1])
            if self.m:self.m.write(OBJECTS[i],value)
            else:self.objects[i]=value
        elif key=='byte':
            if self.m:self.m.write(BACK+0x1080,value,1)
            else:C.c_uint8.from_address(self.data+0x1080).value=value
        else:raise AssertionError(key)
    def event(self,kind,args):
        n=len(self.events);assert n<20,'callback budget'
        self.events.append([kind,list(args),self.snapshot()])
        for at,key,value in self.p.get('mutations',[]):
            if at==n:self.mutate(key,value)
        return n
    def attribute(self,entry,ptr,value):
        if self.m:assert ptr==self.attr_address
        else:
            if self.attr_ptr is None:self.attr_ptr=ptr
            assert C.addressof(ptr.contents)==C.addressof(self.attr_ptr.contents)
            self.attr=ptr[0]
        n=self.event('attribute',[entry,value]);return self.p.get('init_rc',[0]*7)[n]
    def initialize(self,entry,identity,ptr):
        present=bool(ptr)
        if present:
            if self.m:assert ptr==self.attr_address
            else:assert C.addressof(ptr.contents)==C.addressof(self.attr_ptr.contents)
        n=self.event('initialize',[entry,identity,int(present)])
        index=OBJECTS.index(identity);write=self.p.get('init_write',[None]*4)[index]
        if write is not None:self.mutate('object'+str(index),write)
        return self.p.get('init_rc',[0]*7)[n]
    def create(self,field,ptr,attribute,entry,backend):
        assert backend==BACK
        i=FIELDS.index(field)
        if self.m:assert ptr==BACK+field
        else:assert C.addressof(ptr.contents)==self.data+field
        self.event('create',[field,attribute,entry,backend])
        write=self.p.get('create_write',[0x10101010,0x20202020,0x30303030])[i]
        if write is not None:self.mutate(['rx','producer','tx'][i],write)
        return self.p.get('create_rc',[0]*3)[i]
    def log(self,*args):self.event('log',args)
    def result(self,rc):
        if self.m:
            assert bytes(self.m.mem[BACK-16:BACK])==b'\xa5'*16 and bytes(self.m.mem[BACK+SIZE:BACK+SIZE+16])==b'\xa5'*16
            data=bytes(self.m.mem[BACK:BACK+SIZE])
        else:
            assert C.string_at(self.buf,16)==b'\xa5'*16 and C.string_at(self.data+SIZE,16)==b'\xa5'*16
            assert bytes(self.view)==self.saved_view
            data=C.string_at(self.data,SIZE)
        return {'rc':rc&0xffffffff,'events':self.events,'final':self.snapshot(),'backend':data.hex()}

def original(p,m):
    w=World(p,m)
    def attribute(_):
        at=m.r[15];m.r[0]=w.attribute(at,m.r[0],m.r[1] if at==0x5a50f8 else 0)&0xffffffff
    def initialize(_):m.r[0]=w.initialize(m.r[15],m.r[0],m.r[1])&0xffffffff
    def create(_):m.r[0]=w.create(m.r[0]-BACK,m.r[0],m.r[1],m.r[2],m.r[3])&0xffffffff
    def log(_):w.log(*m.r[:4],m.read(m.r[13]),m.read(m.r[13]+4));m.r[0]=p.get('log_rc',0xffffffff)
    rc=m.run(0xc3b54,hooks={0x5a50e8:attribute,0x5a50f8:attribute,0x5a50e0:attribute,
        0x5a60dc:initialize,0x5a4a08:initialize,0x5a55cc:create,0xfa0c4:log},max_steps=1000)
    return w.result(rc)
def native(p,lib):
    w=World(p)
    def cb(typ,fn):
        def wrap(*args):
            try:return fn(*args)
            except BaseException as e:w.errors.append(repr(e));return -1
        out=typ(wrap);w.keep.append(out);return out
    ops=Ops(cb(ATTR,lambda _,*a:w.attribute(*a)),cb(INIT,lambda _,*a:w.initialize(*a)),
        cb(CREATE,lambda _,*a:w.create(*a)),cb(LOG,lambda _,*a:w.log(*a)))
    f=lib.vn135_work_start_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=I
    rc=f(C.byref(w.view),C.byref(ops),None)
    assert not w.errors,('MISMATCH callback arguments',w.errors)
    return w.result(rc)

def cases():
    yield {}
    errors=[0,1,-1,-2147483648,2147483647,85]
    for i,rc in itertools.product(range(7),errors):
        returns=[0]*7;returns[i]=rc;yield {'init_rc':returns,'seed':0xdeadbeef}
    for rc in itertools.product(errors,repeat=3):yield {'create_rc':rc}
    for stage,rc,write in itertools.product(range(3),errors[1:],(None,0,0xffffffff)):
        returns=[0]*3;returns[stage]=rc;writes=[None]*3;writes[stage]=write
        yield {'create_rc':returns,'create_write':writes}
    for seed,entry in itertools.product((0,1,0x80000000,0xffffffff),(0,1,0xc2498,0xffffffff)):
        yield {'seed':seed,'entry':entry,'create_write':[None]*3}
    paths=[([0,0,0],10),([-1,0,0],9),([0,-1,0],11),([0,0,-1],12)]
    for (returns,n),key in itertools.product(paths,('attr','entry','rx','producer','tx','object0','object3','byte')):
        for at in range(n):yield {'create_rc':returns,'mutations':[(at,key,0xbabeface)],'create_write':[None]*3}
    for at in range(7):yield {'mutations':[(at,'attr',0)],'init_rc':[-1]*7,'init_write':[1,2,3,4]}
    rng=random.Random(0xc3b54)
    for _ in range(200):
        rc=[rng.choice(errors) for _ in range(3)]
        yield {'seed':rng.getrandbits(32),'entry':rng.getrandbits(32),'opaque':rng.getrandbits(32),
            'init_rc':[rng.choice(errors) for _ in range(7)],'create_rc':rc,'log_rc':rng.getrandbits(32),
            'init_write':[rng.choice([None,rng.getrandbits(32)]) for _ in range(4)],
            'create_write':[rng.choice([None,rng.getrandbits(32)]) for _ in range(3)],
            'mutations':[(rng.randrange(9),rng.choice(['attr','entry','tx']),rng.getrandbits(32))]}

def fixtures():
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert digest(elf.data)=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    m=Machine(elf);items=[];steps=events=0;visited=set()
    for p in cases():
        result=original(p,m);items.append([p,result]);steps+=m.steps;events+=len(result['events']);visited.update(m.visited)
    return items,{'cases':len(items),'events':events,'steps':steps,'pcs':len(visited)}
def compare(items,lib):
    for i,(p,expected) in enumerate(items):
        actual=native(p,lib);assert actual==expected,('MISMATCH',i,p,actual,expected)
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--fixtures');ap.add_argument('--save-fixtures');a=ap.parse_args()
    if a.fixtures:
        items=json.loads(Path(a.fixtures).read_text())
        try:compare(items,C.CDLL(str(Path(a.library).resolve())))
        except AssertionError as error:
            print('SEMANTIC_MISMATCH',str(error)[:400]);raise SystemExit(3)
        print(f'BASELINE_FIXTURES_PASS cases={len(items)}')
    else:
        items,counts=fixtures();compare(items,C.CDLL(str(Path(a.library).resolve())))
        if a.save_fixtures:Path(a.save_fixtures).write_text(json.dumps(items))
        print('WORK_START_ORIGINAL_PASS '+' '.join(f'{k}={v}' for k,v in counts.items()))
