"""Original ARM metadata/copy/clear/delete, with explicit allocator/libc hooks.
The original strdup wrapper executes; strlen/malloc/memcpy/free/calloc/locks are
injected. No full ELF process, live objects, threads, network or hardware.
"""
from pathlib import Path
import hashlib,struct,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from nonce_oracle import NonceOracle,SHA
OFFSETS=(0x18c,0x19c,0x1a8,0x1b0)

def normalize(image):
    b=bytearray(image)
    for off in OFFSETS:b[off:off+4]=bytes(4)
    return bytes(b)

class StorageOracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ARM32Difficulty(self.elf)
    def prepare(self,image,texts,fail=0):
        assert len(image)==632 and len(texts)==4
        m=self.m;a=m.DATA_BASE;m.mem[a:a+0x10000]=bytes(0x10000)
        self.work=a+0x1000;self.new=a+0x4000;self.heap=a+0x6000
        self.ptrslot=a+0x1400;self.events=[];self.locks=[];self.allocations={}
        self.attempt=0;self.fail=fail
        b=bytearray(normalize(image))
        for i,s in enumerate(texts):
            p=a+0x2000+i*0x500 if s is not None else 0
            assert s is None or (len(s)<0x4ff and b'\0' not in s)
            if p:m.mem[p:p+len(s)+1]=s+b'\0';self.allocations[p]=('input',i)
            struct.pack_into('<I',b,OFFSETS[i],p)
        m.mem[self.work:self.work+632]=b;self.source_before=bytes(b)
        return b
    def text(self,p):
        if not p:return None
        out=bytearray()
        for _ in range(0x1000):
            n=self.m.read(p,1);p+=1
            if not n:return bytes(out)
            out.append(n)
        raise AssertionError('Unterminated oracle string')
    def hooks(self):
        def length(m):m.r[0]=len(self.text(m.r[0]))
        def allocate(m):
            n=m.r[0];assert 1<=n<=0x500
            ok=not(self.fail&(1<<self.attempt));self.attempt+=1
            self.events.append(('alloc',n,ok))
            if not ok:m.r[0]=0;return
            p=self.heap;self.heap+=(n+15)&~15;assert self.heap<self.m.DATA_BASE+0xf000
            self.allocations[p]=('new',self.attempt-1);m.mem[p:p+n]=b'\xcd'*n;m.r[0]=p
        def calloc(m):
            assert m.r[:2]==[1,632];self.events.append(('object',632,True))
            m.mem[self.new:self.new+632]=bytes(632);m.r[0]=self.new
            self.allocations[self.new]=('object',)
        def free(m):
            p=m.r[0];assert p in self.allocations,('unexpected/double free',hex(p))
            what=self.allocations.pop(p)
            if p in (self.work,self.new):self.events.append(('free-object',))
            else:self.events.append(('free',self.text(p)))
            m.r[0]=0
        def lock(m):self.locks.append(('lock',m.r[0]));m.r[0]=0
        def unlock(m):self.locks.append(('unlock',m.r[0]));m.r[0]=0
        def log(m):self.events.append(('null-work-log',));m.r[0]=0
        return {0x5a3a48:length,0x5940ec:allocate,0x593bb4:calloc,0x593c8c:free,
                0x5a2ee8:NonceOracle.copy,0x11d7c:NonceOracle.copy,0x5a348c:NonceOracle.fill,
                0x5a6108:lock,0x5a66c4:unlock,0xfa0c4:log}
    def result(self,p):
        image=bytes(self.m.mem[p:p+632]);texts=[self.text(self.m.read(p+o)) for o in OFFSETS]
        return {'image':normalize(image),'texts':texts,'events':self.events[:],'locks':self.locks[:],
                'steps':self.m.steps}
    def metadata(self,image,strings,bits,fail=0):
        assert len(strings)==3
        self.prepare(image,[None]*4,fail);m=self.m;t=m.DATA_BASE
        ptrs=[m.DATA_BASE+0x2000+i*0x500 for i in range(3)]
        for p,s in zip(ptrs,strings):m.mem[p:p+len(s)+1]=s+b'\0'
        m.write(t+0x3d0,ptrs[0]);m.write(t+0x3ec,ptrs[1])
        m.mem[t+0x396:t+0x396+len(strings[2])+1]=strings[2]+b'\0'
        # +0x396 text must not overlap +0x3a8 double: real ntime is eight chars.
        assert len(strings[2])<18
        m.write(t+0x3a8,bits,8);m.reset();m.r[4]=self.work;m.r[9]=t
        m.run(0x30a6c,stop=0x30a9c,hooks=self.hooks(),max_steps=20000)
        return self.result(self.work)
    def clone(self,image,texts,fresh_id,fail=0):
        self.prepare(image,texts,fail);m=self.m
        g=(0x2cec4+8+m.read(0x2d110))&0xffffffff
        assert g==(0x2cec0+8+m.read(0x2d10c))&0xffffffff
        m.write(g,fresh_id);m.reset((self.work,0))
        m.run(0x2ce84,hooks=self.hooks(),max_steps=50000)
        assert m.r[0]==self.new and m.read(g)==(fresh_id+1)&0xffffffff
        assert bytes(m.mem[self.work:self.work+632])==self.source_before
        assert len(self.locks)==2 and self.locks[0][1]==self.locks[1][1]
        return self.result(self.new)
    def clear(self,image,texts):
        self.prepare(image,texts);m=self.m;m.reset((self.work,))
        m.run(0x2a1bc,hooks=self.hooks(),max_steps=20000)
        return self.result(self.work)
    def delete(self,image,texts,present=True):
        self.prepare(image,texts);m=self.m
        self.allocations[self.work]=('object',)
        m.write(self.ptrslot,self.work if present else 0);m.reset((self.ptrslot,1,2,3))
        m.run(0x2a330,hooks=self.hooks(),max_steps=20000)
        assert m.read(self.ptrslot)==0
        return {'events':self.events[:],'steps':m.steps}
    def builder(self,image,template,global_cookie):
        self.prepare(image,[None]*4);m=self.m
        g=(0x30da8+8+m.read(0x312ac))&0xffffffff;m.write(g,global_cookie)
        m.reset();m.r[4]=self.work;m.r[9]=template
        m.run(0x30d90,stop=0x30db8,max_steps=1000)
        return bytes(m.mem[self.work:self.work+632])
    def wrapper(self,image,word168,global_cookie,counter,word160,word254):
        self.prepare(image,[None]*4);m=self.m;a=m.DATA_BASE
        reference=a+0x400;thread=a+0x900
        m.write(reference+0x98,counter);m.write(thread,word254);m.write(self.ptrslot,self.work)
        g=(0x30400+8+m.read(0x30534))&0xffffffff;m.write(g,global_cookie)
        m.reset();m.r[6]=self.ptrslot;m.r[5]=reference;m.r[8]=word168;m.r[4]=word160;m.r[7]=thread
        m.run(0x303e8,stop=0x3043c,max_steps=1000)
        return {'image':bytes(m.mem[self.work:self.work+632]),'counter':m.read(reference+0x98),'reference':reference}
