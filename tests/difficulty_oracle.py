"""Original target routine, including original uint64<->double helpers.
Model lookup, memcpy and zero-difficulty logging are injected. No running ELF,
threads, live job or physical hardware. Inputs finite, arithmetic default RN.
"""
from pathlib import Path
import hashlib, struct, sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from nonce_oracle import NonceOracle,SHA
class DifficultyOracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ARM32Difficulty(self.elf)
    def prepare(self,selector):
        m=self.m;a=m.DATA_BASE
        m.mem[a:a+0x10000]=bytes(0x10000)
        m.write(a+0x14,a+0x100);m.write(a+0x118,a+0x200)
        m.write(a+0x234,selector)
        self.events=[]
        def lookup(mm):
            assert mm.r[0]==0;self.events.append('lookup');mm.r[0]=a
        def log(mm):self.events.append('zero-difficulty-log');mm.r[0]=0
        return {0x29238:lookup,0x11d7c:NonceOracle.copy,0xfa0c4:log}
    def target(self,difficulty,selector):
        hooks=self.prepare(selector);m=self.m;out=m.DATA_BASE+0x800
        m.mem[out-8:out+40]=b'\xa7'*48
        m.reset((out,));m.set_d(0,difficulty)
        m.run(0x2fe60,hooks=hooks,max_steps=20000)
        assert m.mem[out-8:out]==b'\xa7'*8 and m.mem[out+32:out+40]==b'\xa7'*8
        return bytes(m.mem[out:out+32])
    def inverse(self,target,selector):
        assert len(target)==32
        hooks=self.prepare(selector);m=self.m;a=m.DATA_BASE;out=a+0x800
        m.mem[out:out+32]=target;m.reset();m.r[10]=out;m.r[5]=a+0x200
        m.run(0x31070,stop=0x31100,hooks=hooks,max_steps=20000)
        assert m.mem[out:out+32]==target
        return m.d(8)
    def u64_to_double(self,x):
        m=self.m;m.reset((x&0xffffffff,x>>32))
        m.run(0x591338,max_steps=20000)
        return struct.unpack('<d',struct.pack('<II',m.r[0],m.r[1]))[0]
    def double_to_u64(self,x):
        m=self.m;lo,hi=struct.unpack('<II',struct.pack('<d',x));m.reset((lo,hi))
        m.run(0x591508,max_steps=20000)
        return m.r[0]|m.r[1]<<32
    def work_math(self,words,difficulty,selector):
        assert len(words)==112
        hooks=self.prepare(selector);m=self.m;a=m.DATA_BASE;work=a+0x1000
        image=bytearray(b'\xa7'*632);image[:112]=words
        struct.pack_into('<d',image,0x1a0,difficulty)
        m.mem[work:work+632]=image
        m.reset();m.r[4]=work;m.r[10]=work+0x100
        m.r[13]=m.STACK_TOP-0x800;m.r[11]=m.r[13]+0x300
        m.run(0x30c9c,stop=0x30d90,hooks=hooks,max_steps=100000)
        mid=bytes(m.mem[work+0x80:work+0xa0]);target=bytes(m.mem[work+0x100:work+0x120])
        image[0x80:0xa0]=mid;image[0x100:0x120]=target
        assert m.mem[work:work+632]==image
        return mid,target
if __name__=='__main__':
    o=DifficultyOracle()
    for selector in [0,1,2]:
        for d in [0.0,1.0,2.0,3.0,65536.0,1e12,1e40]:
            t=o.target(d,selector)
            print(selector,d,t[::-1].hex(),o.inverse(t,selector),o.events)
