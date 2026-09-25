"""Bounded original ring and nonce FIFO instructions. No original ELF process.
All eight ring primitives and seven queue wrappers execute from the supplied ELF.
Only malloc/free/memcpy and successful mutex functions are injected. A separate
1 MiB mapped test heap accommodates the real 4096 * 72 allocation. No CPU opcode
is added. Failed native allocation/lock guards are NOT claimed original behavior.
"""
from pathlib import Path
import hashlib,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
RING={'init':0xd19b0,'push':0xd19f0,'full':0xd1bb0,'empty':0xd1de0,
      'pop':0xd1df0,'count':0xd20ac,'reset':0xd212c,'destroy':0xd2144}
QUEUE={'init':0xfa5a4,'push':0xfa5e0,'pop':0xfa6e0,'empty':0xfa7b4,
       'full':0xfa87c,'reset':0xfa944,'destroy':0xfa97c}
class FifoOracle:
    def __init__(self,m=None,queue=False):
        e=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(e.data).hexdigest()==SHA
        self.m=m if m is not None else ARM32(e)
        self.heap=0x900000;self.heap_end=0xa00000
        if len(self.m.mem)<self.heap_end:self.m.mem.extend(bytes(self.heap_end-len(self.m.mem)))
        self.m.regions.append((self.heap,self.heap_end))
        self.queue=queue;self.q=0x654ae8 if queue else self.m.DATA_BASE
        self.mutex=0x654ad0;self.counter=0x654b04
        self.input=self.m.DATA_BASE+0x1000;self.output=self.m.DATA_BASE+0x6000
        self.active=False;self.events=[];self.m.mem[self.q:self.q+28]=bytes(28)
        if queue:self.m.write(self.counter,0)
        self.last_base=self.heap;self.allocation_size=0
    def hooks(self):
        def malloc(m):
            n=m.r[0];assert 0<n<self.heap_end-self.heap and not self.active
            self.active=True;self.allocation_size=n
            m.mem[self.heap:self.heap+n]=b'\xcd'*n;self.events.append(('allocate',n));m.r[0]=self.heap
        def free(m):
            assert m.r[0]==self.heap and self.active
            self.events.append(('release',self.allocation_size));self.active=False;m.r[0]=0
        def copy(m):
            dst,src,n=m.r[:3];m.check(dst,n);m.check(src,n)
            self.events.append(('copy',n));m.mem[dst:dst+n]=bytes(m.mem[src:src+n]);m.r[0]=dst
        def mutex(kind):
            def call(m):
                assert m.r[0]==self.mutex,(kind,hex(m.r[0]));self.events.append((kind,));m.r[0]=0
            return call
        return {0x5940ec:malloc,0x593c8c:free,0x5a2ee8:copy,
                0x5a60dc:mutex('initialize'),0x5a6108:mutex('lock'),
                0x5a66c4:mutex('unlock'),0x5a60b8:mutex('destroy')}
    def call(self,op,data=None,discard=False,cap=None,stride=None):
        m=self.m;self.events=[]
        if op=='init':args=[] if self.queue else [self.q,cap,stride]
        elif op=='push':
            assert data is not None and len(data)==m.read(self.q+24)
            assert len(data)<0x4000
            m.mem[self.input:self.input+len(data)]=data
            args=[self.input] if self.queue else [self.q,self.input]
        elif op=='pop':
            size=m.read(self.q+24);assert size<0x4000
            m.mem[self.output:self.output+size]=b'\xa5'*size
            args=[0 if discard else self.output] if self.queue else [self.q,0 if discard else self.output]
        else:args=[] if self.queue else [self.q]
        m.reset(args);r=m.run((QUEUE if self.queue else RING)[op],hooks=self.hooks(),max_steps=20000)
        return {'return':r,'events':self.events[:], 'state':self.state(),
                'output':bytes(m.mem[self.output:self.output+m.read(self.q+24)]) if op=='pop' and not discard else None}
    def state(self):
        m=self.m;base,end,w,r,cap,count,stride=[m.read(self.q+4*i) for i in range(7)]
        assert stride and end-self.last_base==cap*stride
        assert (w-self.last_base)%stride==0 and (r-self.last_base)%stride==0
        result={'active':bool(base),'capacity':cap,'stride':stride,'count':count,
                'write_index':(w-self.last_base)//stride,'read_index':(r-self.last_base)//stride,
                'storage':bytes(m.mem[self.heap:self.heap+cap*stride]) if base else None}
        if self.queue:result['push_word']=m.read(self.counter)
        return result
    def seed(self,cap,stride,read,count,storage=None,push_word=0):
        """Valid initialized snapshot, to exercise rollover/full without 4096 pushes.
        Seeding is explicit test setup, not a recovered initializer branch.
        """
        assert self.active and 0<=count<=cap and 0<=read<cap
        m=self.m;w=(read+count)%cap
        for i,v in enumerate((self.heap,self.heap+cap*stride,self.heap+w*stride,self.heap+read*stride,cap,count,stride)):m.write(self.q+i*4,v)
        if storage is not None:assert len(storage)==cap*stride;m.mem[self.heap:self.heap+len(storage)]=storage
        if self.queue:m.write(self.counter,push_word)
