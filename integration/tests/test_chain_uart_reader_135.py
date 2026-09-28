#!/usr/bin/env python3
"""Bounded original worker/capacity wait vs C, with existing FIFO/UART reuse."""
import argparse,collections,ctypes as C,hashlib,itertools,json,random,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
U,I,B,P=C.c_uint32,C.c_int32,C.c_uint8,C.c_void_p
CHAIN=0x840100;HEAP=0x845000;METHOD_SLOT=0x654c28;METHODS=(0x116fa8,0x10e938)
BUFFER=0x81eed0;NAME=0x81ee90;OLD=0x81ee88
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class View(C.Structure):_fields_=[('model',C.POINTER(U)),('controller',C.POINTER(U)),('force',C.POINTER(B)),('index',C.POINTER(I)),('running',C.POINTER(B)),('method',C.POINTER(U)),('begin',C.POINTER(U)),('end',C.POINTER(U)),('stride',C.POINTER(U)),('count',C.POINTER(U)),('mutex',P),('queue',P),('uart',P),('condition_mutex',P),('condition',P)]
class Scratch(C.Structure):_fields_=[('data',B*256),('name',B*64),('old',U*2)]
MUTEX=C.CFUNCTYPE(I,P,U,P);DELAY=C.CFUNCTYPE(I,P,U);MODE=C.CFUNCTYPE(I,P,U,C.POINTER(U))
FORMAT=C.CFUNCTYPE(I,P,P,U,U,I);NAME_OP=C.CFUNCTYPE(I,P,U,P,U,U,U)
READ=C.CFUNCTYPE(I,P,U,P,P,U);PUSH=C.CFUNCTYPE(U,P,P,P,U);SIGNAL=C.CFUNCTYPE(I,P,P);EXIT=C.CFUNCTYPE(None,P,U)
class Ops(C.Structure):_fields_=[('mutex',MUTEX),('delay',DELAY),('mode',MODE),('format',FORMAT),('name',NAME_OP),('read',READ),('push',PUSH),('signal',SIGNAL),('exit',EXIT)]
class Fifo(C.Structure):_fields_=[('storage',P),('capacity',U),('stride',U),('count',U),('write',U),('read',U)]
class Uart(C.Structure):_fields_=[('path',P),('fd',I),('baud',U),('ready',C.c_bool)]
IOCTL=C.CFUNCTYPE(I,P,I,U,P);LOWREAD=C.CFUNCTYPE(I,P,I,P,U)
class UartOps(C.Structure):_fields_=[('context',P),('open',P),('duplicate',P),('release',P),('ioctl',IOCTL),('read',LOWREAD),('write',P),('errno',P),('close',P),('flush',P),('init',P),('lock',P),('unlock',P),('destroy',P),('sleep',P)]
RANGES=((0xc36e8,0xc3984),(0x5b150,0x5b1d4),(0xd20b4,0xd2124),(0xd20ac,0xd20b4),(0x590e28,0x590ec4),(0xfdfac,0xfdfb8),(0xfdfbc,0xfdfc8),(0xfe0b0,0xfe108),(0xfef1c,0xfef28),(0xd1bc8,0xd1ce8),(0x10e938,0x10e994))
PARITY=((0xc3984,0xc3704),(0xc3988,0xc3720),(0xc398c,0xc376c),(0xc3994,0xc38a8),(0xc3998,0xc38c4),(0xc399c,0xc391c),(0x5b1d4,0x5b1a8),(0x5b1d8,0x5b1b0),(0xd2124,0xd20c8),(0xd2128,0xd20f8),(0xfe108,0xfe0bc),(0xfe110,0xfe0f4),(0xd1ce8,0xd1bfc),(0xd1cec,0xd1c04))
class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES),('unexpected PC',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
class Finished(Exception):pass
def digest(x):return hashlib.sha256(x).hexdigest()
def signed(x):return I(x).value

class World:
    def __init__(self,p,m=None):
        self.p,self.m=p,m;self.events=[];self.calls=collections.Counter();self.errors=[];self.keep=[];self.iteration=0;self.mode_value=2
        self.buf=C.create_string_buffer(832);C.memset(self.buf,0xa5,832);self.ptr=C.addressof(self.buf)+16
        C.memmove(self.ptr,bytes((i*11+p.get('seed',0))&255 for i in range(800)),800)
        self.s=Scratch();C.memset(C.byref(self.s),0xcd,C.sizeof(self.s));self.sp=C.addressof(self.s)
        self.heap=C.create_string_buffer(2080);C.memset(self.heap,0xab,2080);self.hp=C.addressof(self.heap)+16
        self.model=U(p.get('model',7));self.controller=U(p.get('controller',4));self.force=B(p.get('force',0));self.method=U(p.get('method',METHODS[1]))
        self.index=I.from_address(self.ptr+0x18);self.index.value=p.get('index',0)
        self.running=B.from_address(self.ptr+0x318);self.running.value=p.get('flag',0)
        self.begin=U.from_address(self.ptr+0x2f8);self.end=U.from_address(self.ptr+0x2fc)
        self.count=U.from_address(self.ptr+0x30c);self.stride=U.from_address(self.ptr+0x310)
        self.begin.value=p.get('begin',HEAP);self.stride.value=p.get('stride',1)
        self.end.value=p.get('end',self.begin.value+p.get('capacity',2048)*self.stride.value)
        self.count.value=p.get('count',10)
        self.fifo=None
        if p.get('fifo'):
            cap=p.get('capacity',64);count=p.get('count',0);read=p.get('read_index',0)
            self.fifo=Fifo(self.hp,cap,1,count,(read+count)%cap,read);self.sync()
        self.uart=Uart(None,7,115200,True);U.from_address(self.ptr+0x2d8).value=7
        self.view=View(C.pointer(self.model),C.pointer(self.controller),C.pointer(self.force),C.pointer(self.index),C.pointer(self.running),C.pointer(self.method),C.pointer(self.begin),C.pointer(self.end),C.pointer(self.stride),C.pointer(self.count),CHAIN+0x2e0,CHAIN+0x2f8,CHAIN+0x2b8,0x653410,0x653428)
        if m:
            m.reset([CHAIN]);m.visited=set();m.mem[CHAIN-16:CHAIN+816]=C.string_at(self.buf,832)
            m.mem[HEAP-16:HEAP+2064]=C.string_at(self.heap,2080)
            m.mem[BUFFER:BUFFER+256]=bytes(self.s.data);m.mem[NAME:NAME+64]=bytes(self.s.name);m.mem[OLD:OLD+8]=bytes(self.s.old)
            for a,v in ((0x654b0c,self.model.value),(0x654b08,self.controller.value),(METHOD_SLOT,self.method.value)):m.write(a,v)
            m.write(0x654b24,self.force.value,1)
            for lit,pc8 in PARITY:m.write(m.read((m.read(lit)+pc8)&0xffffffff),p.get('opaque',0xffffffff))
    def sync(self):
        if self.fifo:
            q=self.fifo
            for n,val in enumerate((HEAP,HEAP+q.capacity,HEAP+q.write,HEAP+q.read,q.capacity,q.count,1)):
                U.from_address(self.ptr+0x2f8+4*n).value=val
    def scratch(self):
        if self.m:return bytes(self.m.mem[BUFFER:BUFFER+256])+bytes(self.m.mem[NAME:NAME+64])+bytes(self.m.mem[OLD:OLD+8])
        return bytes(self.s)
    def memory(self):
        if self.m:return bytes(self.m.mem[CHAIN:CHAIN+800]),bytes(self.m.mem[HEAP:HEAP+2048])
        self.sync();return C.string_at(self.ptr,800),C.string_at(self.hp,2048)
    def snapshot(self):
        state=[self.m.read(a) if self.m else v.value for a,v in ((0x654b0c,self.model),(0x654b08,self.controller),(METHOD_SLOT,self.method))]
        return [*state,self.m.read(0x654b24,1) if self.m else self.force.value,self.mode_value,*map(digest,self.memory()),digest(self.scratch())]
    def mutate(self,key,value):
        if key=='mode_value':self.mode_value=value;return
        a={'model':0x654b0c,'controller':0x654b08,'force':0x654b24,'method':METHOD_SLOT}.get(key)
        off={'index':0x18,'running':0x318,'begin':0x2f8,'end':0x2fc,'stride':0x310,'count':0x30c,'byte':0x31f,'fd':0x2d8}.get(key)
        if self.m:self.m.write(a if a is not None else CHAIN+off,value,1 if key in ('running','force','byte') else 4);return
        if key=='byte':B.from_address(self.ptr+off).value=value
        elif key=='fd':U.from_address(self.ptr+off).value=value;self.uart.fd=signed(value)
        else:getattr(self,key).value=value
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1;assert len(self.events)<350
        self.events.append([name,list(args),self.snapshot()])
        for at,occ,key,value in self.p.get('mutations',[]):
            if (at,occ)==(name,n):self.mutate(key,value)
        return self.p.get('rc',-17)
    def mutex(self,entry,obj):return self.event('lock' if entry==0x5a6108 else 'unlock',obj)
    def delay(self,ms):
        rc=self.event('delay',ms)
        if self.p.get('waits') and self.calls['delay']==self.p['waits']:
            self.mutate('stride',self.p.get('new_stride',1));self.mutate('end',self.p.get('new_end',HEAP+2048))
        return rc
    def mode(self,value,ptr):
        rc=self.event('mode',value,bool(ptr))
        if ptr:
            old=self.p.get('old_mode',self.mode_value)
            if self.m:assert ptr==OLD;self.m.write(ptr,old)
            else:assert C.addressof(ptr.contents)==self.sp+320;ptr[0]=old
        self.mode_value=value;return rc
    def format(self,out,size,fmt,index):
        rc=self.event('format',size,fmt,index&0xffffffff);assert size==64 and fmt==0x5e973e
        data=('i'+str(signed(index))).encode()+b'\0';data=data.ljust(64,b'\x78')
        if self.m:assert out==NAME;self.m.mem[out:out+64]=data
        else:assert out==self.sp+256;C.memmove(out,data,64)
        return rc
    def name(self,op,ptr,a,b,c):
        if self.m:assert ptr==NAME;data=bytes(self.m.mem[ptr:ptr+64])
        else:assert ptr==self.sp+256;data=C.string_at(ptr,64)
        return self.event('name',op,data.hex(),a,b,c)
    def read_result(self,out,n):
        results=self.p.get('reads',[9]);i=self.iteration;assert i<10
        # A later callback may re-enable running after the scripted final read.
        # Subsequent injected reads return no data and clear it again.
        rc=results[i] if i<len(results) else 0;self.iteration+=1
        if rc>0:
            assert rc<=256;data=bytes((j*13+i*23)&255 for j in range(rc))
            if self.m:self.m.mem[out:out+rc]=data
            else:C.memmove(out,data,rc)
        if self.iteration>=len(results):self.mutate('running',0)
        return rc
    def read(self,method,obj,out,n,lib=None):
        assert obj==CHAIN+0x2b8 and out==(BUFFER if self.m else self.sp)
        if not self.p.get('uart'):
            self.event('read',method,obj,n);return self.read_result(out,n)
        assert method==METHODS[1]
        ops=UartOps();ops.ioctl=self.callback(IOCTL,lambda _,fd,cmd,ptr:self.ioctl(fd,cmd,ptr))
        ops.read=self.callback(LOWREAD,lambda _,fd,ptr,n:self.low_read(fd,ptr,n))
        f=lib.vn135_uart_read;f.argtypes=[C.POINTER(Uart),C.POINTER(UartOps),P,C.c_size_t];f.restype=I
        return f(C.byref(self.uart),C.byref(ops),out,n)
    def ioctl(self,fd,cmd,ptr):
        rc=self.p.get('ioctl_rc',0);available=self.p.get('available',1)
        self.event('ioctl',fd&0xffffffff,cmd);assert cmd==0x541b
        if self.m:self.m.write(ptr,available)
        else:C.cast(ptr,C.POINTER(I))[0]=signed(available)
        if rc or not available:self.iteration+=1;self.mutate('running',0)
        return rc
    def low_read(self,fd,ptr,n):self.event('low_read',fd&0xffffffff,n);return self.read_result(ptr,n)
    def push(self,obj,ptr,n,lib):
        assert obj==CHAIN+0x2f8 and ptr==self.sp and n<=256
        if not self.p.get('fifo'):return self.event('push',obj,C.string_at(ptr,n).hex(),n)&0xffffffff
        f=lib.vn135_fifo_push;f.argtypes=[C.POINTER(Fifo),P];f.restype=I
        accepted=0
        for i in range(n):
            rc=f(C.byref(self.fifo),ptr+i);assert rc in (0,1)
            if not rc:break
            accepted+=1
        self.sync();return accepted
    def exit(self,value):self.event('exit',value)
    def callback(self,typ,fn):
        def cb(*args):
            try:return fn(*args)
            except BaseException as e:
                self.errors.append(repr(e));self.mutate('running',0)
                return None if typ==EXIT else 1 if typ==PUSH else -1
        obj=typ(cb);self.keep.append(obj);return obj
    def result(self,returned=None):
        for a,ptr,n in ((CHAIN,self.ptr,800),(HEAP,self.hp,2048)):
            raw=bytes(self.m.mem[a-16:a])+bytes(self.m.mem[a+n:a+n+16]) if self.m else C.string_at(ptr-16,16)+C.string_at(ptr+n,16)
            assert raw==bytes([0xa5 if a==CHAIN else 0xab])*32
        return {'return':returned,'events':self.events,'final':self.snapshot(),'memory':[x.hex() for x in self.memory()],'scratch':self.scratch().hex()}

def original(p,m):
    w=World(p,m)
    def call(fn,*args):m.r[0]=(fn(*args) or 0)&0xffffffff
    def push(_):call(w.event,'push',m.r[0],bytes(m.mem[m.r[1]:m.r[1]+m.r[2]]).hex(),m.r[2])
    def copy(_):m.mem[m.r[0]:m.r[0]+m.r[2]]=m.mem[m.r[1]:m.r[1]+m.r[2]]
    def done(_):w.exit(m.r[0]);raise Finished()
    hooks={0x5a6108:lambda _:call(w.mutex,0x5a6108,m.r[0]),0x5a66c4:lambda _:call(w.mutex,0x5a66c4,m.r[0]),
      0x10ef3c:lambda _:call(w.delay,m.r[0]),0x5a6b2c:lambda _:call(w.mode,m.r[0],m.r[1]),
      0x59f558:lambda _:call(w.format,*m.r[:4]),0x593af8:lambda _:call(w.name,*m.r[:4],m.read(m.r[13])),
      0x5a4a48:lambda _:call(w.event,'signal',m.r[0]),0x5a52d0:done}
    if p.get('fifo'):hooks[0x5a2ee8]=copy
    else:hooks[0xd1bc8]=push
    if p.get('uart'):hooks.update({0x597550:lambda _:call(w.ioctl,*m.r[:3]),0x5a8498:lambda _:call(w.low_read,*m.r[:3])})
    else:hooks.update({a:lambda _:call(w.read,m.r[15],*m.r[:3]) for a in METHODS})
    try:m.run(0x5b150 if p.get('wait_only') else 0xc36e8,hooks=hooks,max_steps=30000)
    except Finished:assert not p.get('wait_only');return w.result()
    assert p.get('wait_only');return w.result(m.r[0])
def native(p,lib):
    w=World(p)
    ops=Ops(w.callback(MUTEX,lambda _,e,o:w.mutex(e,o)),w.callback(DELAY,lambda _,ms:w.delay(ms)),
      w.callback(MODE,lambda _,v,p:w.mode(v,p)),w.callback(FORMAT,lambda _,*a:w.format(*a)),w.callback(NAME_OP,lambda _,*a:w.name(*a)),
      w.callback(READ,lambda _,*a:w.read(*a,lib)),w.callback(PUSH,lambda _,*a:w.push(*a,lib)),
      w.callback(SIGNAL,lambda _,p:w.event('signal',p)),w.callback(EXIT,lambda _,v:w.exit(v)))
    returned=None
    if p.get('wait_only'):
        f=lib.vn135_chain_uart_wait_capacity_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];f.restype=U
        returned=f(C.byref(w.view),C.byref(ops),None)
    else:
        f=lib.vn135_chain_uart_reader_135;f.argtypes=[C.POINTER(View),C.POINTER(Ops),P,C.POINTER(Scratch)];f.restype=None
        f(C.byref(w.view),C.byref(ops),None,C.byref(w.s))
    assert not w.errors,('MISMATCH callback',w.errors)
    return w.result(returned)

def cases():
    yield {}
    yield {'rc':0}
    for key,value in (('model',6),('controller',0),('force',255)):
        yield {'count':9,'mutations':[('format',0,key,value)]}
    for model,controller,force,count in itertools.product((0,6,7,0xffffffff),(0,1,4,0xffffffff),(0,1,255),(8,9,10,11,0xffffffff)):
        yield {'model':model,'controller':controller,'force':force,'count':count}
    for capacity,stride,received in itertools.product((1,7,255,256,257,2048,0xffffffff),(1,3),(0,-1,-2147483648,1,9,256)):
        yield {'capacity':capacity,'stride':stride,'reads':[received]}
    for begin,end,stride in ((0xffffffff,0x100,3),(0x80000000,0,1),(0,0xffffffff,7),(HEAP,HEAP,1),(HEAP,HEAP+9,0)):
        yield {'wait_only':True,'begin':begin,'end':end,'stride':stride,'waits':2,'new_end':(begin+60)&0xffffffff,'new_stride':3}
    for waits in (1,3):yield {'stride':0,'waits':waits,'reads':[0,10,-1,1]}
    boundaries=[('mode',0),('format',0),('name',0),('lock',0),('unlock',0),('mode',1),('read',0),('mode',2),('lock',1),('push',0),('lock',2),('signal',0),('unlock',1),('delay',0)]
    changes=[('model',6),('controller',0),('force',255),('index',0xffffffff),('running',0),('running',255),('method',METHODS[0]),('count',0),('count',0xffffffff),('end',HEAP+7),('byte',0),('mode_value',2),('fd',9)]
    for (name,occ),(key,value) in itertools.product(boundaries,changes):
        # A later read clears running even when an earlier callback sets it.
        yield {'reads':[9,0,11,-1],'count':11,'mutations':[(name,occ,key,value)]}
    for old in (0,1,2,0xffffffff):yield {'old_mode':old,'reads':[10,0,-1,11]}
    rng=random.Random(0xc36e8)
    for _ in range(70):
        name,occ=rng.choice(boundaries);key,value=rng.choice(changes)
        yield {'model':rng.choice([0,6,7]),'controller':rng.choice([0,4]),'count':rng.randrange(8,12),'opaque':rng.getrandbits(32),'seed':rng.getrandbits(32),'reads':[rng.choice([0,-1,1,9,256]),0],'mutations':[(name,occ,key,value)]}
    for cap,count,read in ((1,0,0),(1,1,0),(7,6,6),(11,11,3),(64,3,60),(256,250,254),(512,0,400),(2048,2047,2000)):
        for reads in ([1],[9],[256],[0,9,256]):
            yield {'fifo':True,'uart':True,'capacity':cap,'count':count,'read_index':read,'reads':reads}
    for available,rc in itertools.product((0,1,-1,2147483647),(0,-1,1)):
        yield {'fifo':True,'uart':True,'capacity':64,'count':64,'available':available,'ioctl_rc':rc,'reads':[9]}
    yield {'uart':True,'reads':[0,-1,256],'mutations':[('ioctl',0,'fd',12)]}

class Assigned(Exception):pass
class Probe(ARM32):
    def extra_instruction(self,w,pc):
        assert 0xfb994<=pc<0xfddfc;return super().extra_instruction(w,pc)
    def write(self,a,v,n=4):
        super().write(a,v,n)
        if a==METHOD_SLOT:raise Assigned((self.r[15]-4,v))
def provenance(elf):
    records=[]
    for c,m,s in itertools.product(range(5),(0,4,7),(0,1,0xffffffff)):
        a=Probe(elf);a.reset([c,m,s,0])
        try:a.run(0xfb994,max_steps=1000)
        except Assigned as found:
            pc,target=found.args[0];assert pc==0xfbc50 and target==METHODS[c!=0]
            records.append([c,m,s,pc,target,a.steps])
        else:raise AssertionError('store not reached')
    return records
def fixtures():
    e=ELF32(ROOT/'reference/cgminer.vendor.elf');assert digest(e.data)==SHA
    m=Machine(e);items=[];steps=events=0;pcs=set()
    for p in cases():
        r=original(p,m);items.append([p,r]);steps+=m.steps;events+=len(r['events']);pcs.update(m.visited)
    return items,dict(cases=len(items),events=events,steps=steps,pcs=len(pcs),nested=sum(bool(p.get('fifo')) for p,_ in items),provenance=len(provenance(e)))
def compare(items,lib):
    for i,(p,expected) in enumerate(items):
        actual=native(p,lib)
        for k in ('memory','scratch'):
            if k not in expected:actual.pop(k)
        if actual!=expected:
            for j,(a,b) in enumerate(zip(actual['events'],expected['events'])):
                if a!=b:raise AssertionError(('MISMATCH event',i,j,p,a,b))
            raise AssertionError(('MISMATCH final',i,p,str(actual)[-1000:],str(expected)[-1000:]))
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--fixtures');a=ap.parse_args()
    if a.fixtures:
        items=json.loads(Path(a.fixtures).read_text())
        try:compare(items,C.CDLL(str(Path(a.library).resolve())))
        except AssertionError as e:print('SEMANTIC_MISMATCH',str(e)[:800]);raise SystemExit(3)
        print(f'BASELINE_FIXTURES_PASS cases={len(items)}')
    else:
        items,counts=fixtures();compare(items,C.CDLL(str(Path(a.library).resolve())))
        print('CHAIN_UART_READER_ORIGINAL_PASS '+' '.join(f'{k}={v}' for k,v in counts.items()))
