"""Execute the original RX nonce preparation including real original SHA-256.
Injected: chip/core attribution (downstream helpers), memcpy. Queue boundary
0xc46fc is NOT executed. Selected job rows are immutable test data in the original
32 x 168-byte table. This does not validate a share or job freshness.
"""
from pathlib import Path
import hashlib,struct,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

class NonceOracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ARM32Nonce(self.elf)
    @staticmethod
    def copy(m):
        dst,src,n=m.r[:3];m.check(dst,n);m.check(src,n)
        m.mem[dst:dst+n]=bytes(m.mem[src:src+n]);m.r[0]=dst
    @staticmethod
    def fill(m):
        dst,value,n=m.r[:3];m.check(dst,n)
        m.mem[dst:dst+n]=bytes([value&255])*n;m.r[0]=dst
    def prepare(self,variant,chip_selector,chain,payload,record,chip_result,core_result):
        assert variant in (0,1,2) and len(payload)==7+variant and len(record)==168
        m=self.m;m.reset();sp=m.STACK_TOP-0x1000;fp=sp+504
        m.r[13]=sp;m.r[11]=fp;m.r[8]=fp-104;m.r[2]=variant
        m.r[10]=m.DATA_BASE;m.write(m.DATA_BASE,0)
        m.r[9]=m.DATA_BASE+0x4000;m.write(m.r[9]-768,chain)
        m.mem[fp-104:fp-104+len(payload)]=payload
        tail=bytes.fromhex('a1b2c3d4');m.mem[fp-180:fp-176]=tail
        # Run original slot bits and table calculation BEFORE inserting a row.
        for off,value in ((0x10,chip_selector|1),(0x4c,variant),(0x30,fp-103),
                          (4,fp-224),(8,fp-212),(12,sp+224)):
            m.write(sp+off,value)
        m.run(0xc4480,stop=0xc4518,max_steps=1000)
        slot=m.r[1];row=m.r[10]+8
        assert row==0x653460+slot*168
        m.check(row,len(record));m.mem[row:row+168]=record
        calls=[]
        def chip_id(m):calls.append(('chip',m.r[0]));m.r[0]=chip_result&0xffffffff
        def core_id(m):calls.append(('core',m.r[0]));m.r[0]=core_result&0xffffffff
        m.run(0xc4518,stop=0xc46fc,hooks={0xd2760:chip_id,0xd280c:core_id,
              0x5a2ee8:self.copy},max_steps=30000)
        assert m.r[0]==fp-248
        assert bytes(m.mem[fp-180:fp-176])==tail, 'Undocumented tail write'
        return {'slot':slot,'candidate':bytes(m.mem[fp-248:fp-180]),
                'prefix':bytes(m.mem[fp-172:fp-108]),'calls':calls,'steps':m.steps}
    def sha_midstate(self,block,initial=None):
        assert len(block)==64
        m=self.m;a=m.DATA_BASE;p=a+0x1000
        m.reset((a,));m.run(0x109120,max_steps=500)
        if initial is not None:m.mem[a+136:a+168]=struct.pack('<8I',*initial)
        m.mem[p:p+64]=block;m.reset((a,p,1))
        m.run(0x108b7c,max_steps=20000)
        return tuple(struct.unpack('<8I',m.mem[a+136:a+168]))
    def digest64(self,block):
        assert len(block)==64
        m=self.m;a=m.DATA_BASE;p=a+0x1000;out=p+256
        m.reset((a,));m.run(0x109120,max_steps=500)
        m.mem[p:p+64]=block;m.reset((a,p,64))
        m.run(0x109170,hooks={0x5a2ee8:self.copy},max_steps=30000)
        m.reset((a,out));m.run(0x10939c,hooks={0x5a348c:self.fill},max_steps=30000)
        return bytes(m.mem[out:out+32])

if __name__=='__main__':
    o=NonceOracle()
    for v in range(3):
        x=o.prepare(v,2,3,bytes(range(7+v)),bytes(range(168)),7,9)
        print(v,x['slot'],struct.unpack('<17I',x['candidate']),x['prefix'].hex(),x['calls'])
