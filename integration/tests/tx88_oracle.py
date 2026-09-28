"""Bounded original ARM slices; the reference ELF is data, never a process.

Prefix slice c29b4..c2a6c receives an already built header's version, prevhash,
Merkle words and final two scalar fields. It does NOT run pool/coinbase code.
Formatter c4dfc..c4ea8 calls the actual original CRC16 twice. Only its two memcpy
calls are hooked. UART call at the stop PC is NOT executed. Not T21 dispatch proof.
"""
from pathlib import Path
import hashlib
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce

REFERENCE_SHA256 = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

class Tx88Oracle:
    def __init__(self):
        self.elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        if hashlib.sha256(self.elf.data).hexdigest() != REFERENCE_SHA256:
            raise ValueError('Original reference ELF checksum mismatch')
        self.m = ARM32Nonce(self.elf)

    def crc(self, data, initial):
        if len(data) > 4096 or not 0 <= initial <= 65535:
            raise ValueError('Unsupported oracle CRC input')
        m = self.m
        m.reset((m.DATA_BASE, len(data), initial))
        m.mem[m.DATA_BASE:m.DATA_BASE + len(data)] = data
        result = m.run(0xf7df4, max_steps=100000)
        return result

    def prefix(self, header):
        if len(header) != 80:
            raise ValueError('80 native header bytes required')
        m = self.m
        m.reset()
        sp, row = m.STACK_TOP - 0x1000, m.DATA_BASE + 0x2000
        fp = sp + 408
        m.r[13], m.r[11] = sp, fp
        # Inputs at this slice boundary, not a reconstructed complete swork.
        m.mem[fp-184:fp-152] = b''.join(header[i:i+4][::-1] for i in range(36, 68, 4))
        m.mem[fp-144:fp-140] = header[:4]
        m.mem[fp-140:fp-108] = header[4:36]
        m.mem[fp-104:fp-100] = header[68:72]
        m.mem[fp-108:fp-104] = header[72:76]
        m.write(sp+0x1c, row)
        m.write(sp+0x20, row-32)
        m.write(sp+0x24, fp-140)
        m.mem[row:row+168] = b'\xa5' * 168
        # Original full-byte reverse helper 10f64c is executed, not replaced.
        m.run(0xc29b4, stop=0xc2a6c, max_steps=5000)
        return bytes(m.mem[row:row+76])

    def frame_row(self, row_bytes, slot):
        if len(row_bytes) != 76 or not 0 <= slot < 32:
            raise ValueError('Unsupported original formatter input')
        m = self.m
        m.reset()
        sp, row = m.STACK_TOP - 0x400, m.DATA_BASE + 0x4000
        m.r[13], m.r[4], m.r[6] = sp, slot, row
        m.mem[row:row+76] = row_bytes
        m.write(sp+0x10, sp+34)
        m.write(sp+0x14, sp+32+26)
        m.write(sp+0x18, sp+32+58)
        m.write(sp+0x1c, 0x12345678)  # opaque UART handle, never dereferenced
        copies = []
        def copy(cpu):
            dst, src, size = cpu.r[:3]
            cpu.check(dst, size)
            cpu.check(src, size)
            copies.append((src-row, size))
            cpu.mem[dst:dst+size] = bytes(cpu.mem[src:src+size])
            cpu.r[0] = dst
        m.run(0xc4dfc, stop=0xc4ea8, hooks={0x5a2ee8: copy}, max_steps=10000)
        assert copies == [(4, 32), (36, 28)]
        assert m.r[0:3] == [0x12345678, sp+32, 88]
        assert bytes(m.mem[row:row+76]) == row_bytes
        return bytes(m.mem[sp+32:sp+120])

    def frame(self, header, slot):
        return self.frame_row(self.prefix(header), slot)
