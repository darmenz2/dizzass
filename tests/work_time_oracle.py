"""Stage12 original clone + original hex helpers + original alphabet initializer.
No helper result or decoded alphabet is injected. Only documented allocation,
libc copy/strlen/memset, mutex and diagnostics are hooks. No Linux/ASIC execution.
"""
from work_storage_oracle import StorageOracle
class TimeOracle(StorageOracle):
    def __init__(self):
        super().__init__();m=self.m
        before=bytes(m.mem[0x5e00bb:0x5e00cd])
        m.reset();m.run(0x1ff00,stop=0x1ff2c,max_steps=200)
        assert bytes(m.mem[0x5e00bc:0x5e00cc])==b'0123456789abcdef'
        assert m.mem[0x5e00bb]==before[0] and m.mem[0x5e00cc]==before[-1]
        self.alphabet_steps=m.steps
    def hooks(self):
        hooks=super().hooks();original=hooks[0x593bb4]
        def calloc(m):
            if m.r[:2]==[1,632]:return original(m)
            assert m.r[:2]==[12,1],m.r[:2]
            m.r[0]=12;hooks[0x5940ec](m)
            if not m.r[0]:
                raise ValueError('Original bin2hex NULL write is outside compared domain')
            m.mem[m.r[0]:m.r[0]+12]=bytes(12)
        hooks[0x593bb4]=calloc
        return hooks
    def clone_time(self,image,texts,fresh_id,delta,fail=0):
        self.prepare(image,texts,fail);m=self.m
        g=(0x2cec4+8+m.read(0x2d110))&0xffffffff
        m.write(g,fresh_id);m.reset((self.work,delta))
        m.run(0x2ce84,hooks=self.hooks(),max_steps=50000)
        assert m.r[0]==self.new and m.read(g)==(fresh_id+1)&0xffffffff
        assert bytes(m.mem[self.work:self.work+632])==self.source_before
        assert len(self.locks)==2 and self.locks[0][1]==self.locks[1][1]
        result=self.result(self.new)
        if delta and texts[1] is not None:
            result['time_allocation']=bytes(m.mem[m.read(self.new+0x19c):m.read(self.new+0x19c)+12])
        return result
    def decode(self,text):
        assert len(text)==8 and b'\0' not in text
        self.prepare(bytes(632),[None]*4);m=self.m;src=m.DATA_BASE+0x2000;dst=m.DATA_BASE+0x3000
        m.mem[src:src+9]=text+b'\0';m.mem[dst-1:dst+5]=b'\xa5'*6
        m.reset((dst,src,4));m.run(0x107b0,hooks=self.hooks(),max_steps=5000)
        assert m.mem[dst-1]==0xa5 and m.mem[dst+4]==0xa5
        return m.r[0],bytes(m.mem[dst:dst+4])
    def encode(self,value):
        self.prepare(bytes(632),[None]*4);m=self.m;src=m.DATA_BASE+0x2000
        m.mem[src:src+4]=value.to_bytes(4,'big');m.reset((src,4))
        m.run(0x1068c,hooks=self.hooks(),max_steps=5000)
        return bytes(m.mem[m.r[0]:m.r[0]+12])
