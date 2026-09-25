"""Original RX instruction slices with actual original ring-pop/filter callees.
No Linux or vendor ELF process runs. Injected: selector getter, memcpy, unlock,
and final register enqueue. Nonce path stops BEFORE job lookup/hash checking.
"""
from pathlib import Path
import hashlib, struct, sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_rx_subset import ARM32RX
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class ReachedBoundary(Exception): pass

class RxOracle:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==SHA
        self.m=ARM32RX(self.elf)
    def policy(self, board, chip, special):
        m=self.m;m.reset();m.r[13]=m.STACK_TOP-0x1000;m.r[6]=chip
        m.run(0xc4074,stop=0xc40dc,hooks={
          0xfdfac:lambda m:setattr0(m,board),0xfe0b0:lambda m:setattr0(m,special)},max_steps=300)
        return m.read(m.r[13]+0x4c), m.read(m.r[13]+0x54)
    def filtered_register(self, chip):
        m=self.m;m.reset()
        return m.run(0xd2a84,hooks={0xfdfbc:lambda m:setattr0(m,chip)},max_steps=600)
    def job_slot(self, chip, variant, payload):
        m=self.m;m.reset();sp=m.STACK_TOP-0x1000;m.r[13]=sp;m.r[11]=sp+504
        buf=m.r[11]-104;m.mem[buf:buf+len(payload)]=payload
        m.r[8]=buf;m.r[2]=variant;m.r[10]=m.DATA_BASE
        m.write(m.DATA_BASE,0);m.write(sp+0x10,chip|1)
        m.run(0xc4480,stop=0xc44dc,max_steps=300)
        return m.r[1]
    def frame(self, board, chip, special, chain, data, head=0):
        variant,minimum=self.policy(board,chip,special)
        m=self.m;m.reset();sp=m.STACK_TOP-0x1000;fp=sp+504
        m.r[13]=sp;m.r[11]=fp
        ch=m.DATA_BASE+0x1000;ring=ch+760;mem=m.DATA_BASE+0x4000;capacity=64
        assert len(data)<=capacity and 0<=head<capacity
        m.mem[m.DATA_BASE:m.DATA_BASE+0x6000]=b'\0'*0x6000
        for i,b in enumerate(data):m.write(mem+(head+i)%capacity,b,1)
        for off,val in enumerate((mem,mem+capacity,mem+(head+len(data))%capacity,mem+head,capacity,len(data),1)):
            m.write(ring+off*4,val)
        m.r[9]=ch+792;m.write(m.r[9]-768,chain)
        m.r[6]=ch+736;m.r[10]=ring;m.r[0]=ring
        m.r[5]=m.DATA_BASE+0x2000;m.r[8]=special
        buf=fp-104
        for off,val in ((0x54,minimum),(0x4c,variant),(0x40,7+variant),(0x48,buf+6),
                        (0x3c,buf+7),(0x34,buf+8),(0x30,buf+1),(0x10,chip|1)):
            m.write(sp+off,val)
        enqueued=[];boundary=[];copies=[];unlocks=[]
        def end(m):
            boundary.append(m.r[15]);raise ReachedBoundary
        def copy(m):
            dst,src,n=m.r[:3];m.check(dst,n);m.check(src,n)
            copies.append(n);m.mem[dst:dst+n]=bytes(m.mem[src:src+n]);m.r[0]=dst
        def enqueue(m):
            assert m.r[0]==sp+88
            enqueued.append(bytes(m.mem[sp+88:sp+102]));m.r[0]=0
        def unlock(m):unlocks.append(m.r[0]);m.r[0]=0
        hooks={0x5a2ee8:copy,0x5a66c4:unlock,0x108938:enqueue,
               0xfdfbc:lambda m:setattr0(m,chip),
               0xc4300:end,0xc4480:end,0xc4844:end}
        try:m.run(0xc42b0,hooks=hooks,max_steps=10000)
        except ReachedBoundary:pass
        else:raise AssertionError('Original RX did not stop at a documented boundary')
        consumed=len(data)-m.read(ring+20)
        assert m.read(ring+12)==mem+(head+consumed)%capacity
        tail=bytes(m.mem[mem+(head+i)%capacity] for i in range(consumed,len(data)))
        assert tail==data[consumed:]
        endpc=boundary[0]
        if endpc==0xc4300:
            assert not enqueued
            return dict(kind=0 if consumed==0 else 1,consumed=consumed,payload=b'',chain=chain)
        payloadsize=7 if special else 7+variant
        payload=bytes(m.mem[buf:buf+payloadsize])
        assert consumed==payloadsize+2
        if endpc==0xc4480:
            assert not enqueued
            m.run(0xc4480,stop=0xc44dc,max_steps=m.steps+200)
            return dict(kind=3,consumed=consumed,payload=payload,chain=chain,job_slot=m.r[1])
        # All normal/special register paths reach 0xc4844. No enqueue is a filter.
        assert len(enqueued)<=1
        result=dict(kind=2 if enqueued else 4,consumed=consumed,payload=payload,
            chain=m.read(sp+88),chip_address=m.read(sp+92,1),
            register_address=m.read(sp+93,1),register_value=m.read(sp+96),
            crc5_field=m.read(sp+100,2))
        return result

def setattr0(m,value):m.r[0]=value&0xffffffff

if __name__=='__main__':
    o=RxOracle()
    for b,c,s in ((0,0,0),(1,7,0),(1,2,0),(1,7,1),(4,6,0)):
        print('policy',b,c,s,o.policy(b,c,s),'filter',hex(o.filtered_register(c)))
        n=o.policy(b,c,s)[1]
        for data in (b'\0'*n,b'\xaa\xaa'+b'\0'*n,b'\xaa\x55'+bytes(range(n-2)),b'\xaa\x55'+b'\x80'*(n-2)):
            print(o.frame(b,c,s,2,data,head=61))
