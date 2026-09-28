"""Bounded ORIGINAL packet slice, not a vendor process or a hardware test.
Only memcpy is injected. Original reversal and CRC16 (with its ELF table) run.
The 104-byte job view and final Merkle digest are precomputed input boundaries;
this does not reimplement or claim to run the original coinbase/job producer.
"""
from pathlib import Path
import hashlib
import struct
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce
from arm32_subset import MASK, ror
ELF_SHA = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
class TX86ARM(ARM32Nonce):
    def extra_instruction(self, w, pc):
        if w & 0x0fff03f0 == 0x06af0070:  # SXTB, rotated byte
            d, n = (w >> 12) & 15, w & 15
            if 15 in (d,n): raise ValueError('SXTB PC unsupported')
            x = ror(self.get(n,pc), ((w >> 10) & 3)*8) & 255
            self.r[d] = (x-256 if x & 128 else x) & MASK
            return True
        if w & 0x0fff0ff0 == 0x06bf0fb0:  # REV16, byte swap in each halfword
            d,n = (w >> 12) & 15,w & 15
            if 15 in (d,n): raise ValueError('REV16 PC unsupported')
            x = self.get(n,pc)
            self.r[d] = ((x & 0x00ff00ff) << 8) | ((x & 0xff00ff00) >> 8)
            return True
        return super().extra_instruction(w,pc)
class TX86Oracle:
    def __init__(self):
        elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        assert hashlib.sha256(elf.data).hexdigest() == ELF_SHA
        self.elf = elf
        self.m = TX86ARM(elf)
    def crc(self, data, seed):
        m=self.m; p=m.DATA_BASE
        if len(data)>0x8000: raise ValueError('CRC fixture too large')
        m.mem[p:p+len(data)] = data
        m.reset((p,len(data),seed)); m.run(0xf7df4,max_steps=2000000)
        return m.r[0]
    def encode(self, words, selector, raw_id):
        assert len(words)==80 and 0<=raw_id<=255
        m=self.m;m.reset()
        sp=m.STACK_TOP-0x2000;fp=sp+520;packet=fp-240;view=fp-152
        digest=m.DATA_BASE;model=digest+0x100
        m.r[13]=sp;m.r[11]=fp;m.r[7]=digest
        # Merkle digest byte order is an explicit boundary; the slice swaps its
        # words before insertion. Remaining inputs are native work word bytes.
        m.mem[digest:digest+32]=bytes(words[36+(i&~3)+(3-(i&3))] for i in range(32))
        m.write(model,selector)
        m.mem[view+8:view+12]=words[:4]
        m.mem[view+12:view+44]=words[4:36]
        m.mem[view+44:view+48]=words[72:76]
        m.mem[view+48:view+52]=words[68:72]
        for off,val in [(0x40,raw_id),(0x28,model),(0x20,packet+8),
                        (0x14,view+12),(0x24,packet+40),(0x1c,packet+4),(0x18,packet+2)]:
            m.write(sp+off,val)
        # The preceding 32 bytes are the ORIGINAL temporary Merkle buffer.
        # Place the leading canary before that buffer, not inside it.
        m.mem[packet-40:packet+88]=b'\xa5'*128
        # Last two bytes after the 86-byte packet are canaries.
        before=bytes(m.mem[view:view+104]); original_digest=bytes(m.mem[digest:digest+32])
        def copy(mm):
            dst,src,n=mm.r[:3]
            assert n==32 and dst in (packet+8,packet+12,packet+40,packet+44)
            mm.check(dst,n);mm.check(src,n)
            mm.mem[dst:dst+n]=bytes(mm.mem[src:src+n]);mm.r[0]=dst
        m.run(0xc069c,stop=0xc07e4,hooks={0x5a2ee8:copy},max_steps=50000)
        assert bytes(m.mem[packet-40:packet-32])==b'\xa5'*8
        assert bytes(m.mem[packet+86:packet+88])==b'\xa5'*2
        assert bytes(m.mem[view:view+104])==before
        assert bytes(m.mem[digest:digest+32])==original_digest
        return bytes(m.mem[packet:packet+86])
