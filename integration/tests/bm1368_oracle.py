"""Bounded original model/nonce slices. Vendor ELF is data, never a process.
Attribution and RX slices execute actual dispatch, getters and helpers without
external hooks. Only strcmp is injected in the separate model-name slice. Model
JSON loading, hwscan and physical chip detection are NOT executed.
"""
from pathlib import Path
import hashlib
import struct
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce

ELF_SHA256 = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
SOURCE_PATH = b'/tmp/build/libbitmain/src/chip/chip1368.c\0'
MODEL_NAMES = ('BM1360', 'BM1362', 'BM1398', 'BM1366',
               'BM1368', 'BM1370', 'BM1489', 'BM1491')

class TracedARM(ARM32Nonce):
    def reset(self, args=()):
        super().reset(args)
        self.executed = set()

    def extra_instruction(self, word, pc):
        self.executed.add(pc)
        return super().extra_instruction(word, pc)

class BM1368Oracle:
    def __init__(self):
        self.elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        if hashlib.sha256(self.elf.data).hexdigest() != ELF_SHA256:
            raise ValueError('Unexpected original ELF')
        self.m = TracedARM(self.elf)
        # Execute the original constructor slice, including its PIC address
        # calculations and all 42 XOR operations, on interpreter memory only.
        self.m.run(0xe5408, stop=0xe54cc, max_steps=2000)
        if self.m.r[3] != 0x5eb3e7 or bytes(self.m.mem[0x5eb3e7:0x5eb3e7+42]) != SOURCE_PATH:
            raise ValueError('Original source-path decoder mismatch')
        self.source_decode_steps = self.m.steps
        log_literal = int.from_bytes(self.elf.read(0xe467c, 4), 'little')
        if (0xe4648 + log_literal) & 0xffffffff != 0x5eb3e7:
            raise ValueError('Chip helper source-path reference mismatch')
        # The whole global constructor is not run. Materialize these eight
        # encrypted 7-byte literals explicitly for the bounded strcmp slice.
        self.string_records = []
        for i in range(8):
            address = 0x5e8838 + i * 7
            raw = self.elf.read(address, 7)
            key = raw[0] ^ ord('B')
            decoded = bytes(x ^ key for x in raw)
            if decoded[:-1].decode('ascii') not in MODEL_NAMES or decoded[-1] != 0:
                raise ValueError('Unexpected chip-name literal')
            self.m.mem[address:address+7] = decoded
            self.string_records.append((address, key, decoded))

    def selector(self, name):
        if not isinstance(name, bytes) or b'\0' in name or len(name) > 128:
            raise ValueError('Expected bounded chip-name bytes without NUL')
        m = self.m
        m.reset()
        m.r[4] = m.DATA_BASE
        m.r[1] = 0x5e8838       # live-in first string pointer
        m.r[5] = 0             # original default before first equality
        m.mem[m.DATA_BASE:m.DATA_BASE+len(name)+1] = name + b'\0'
        def cstring(address):
            data = bytearray()
            for i in range(130):
                value = m.read(address+i, 1)
                if not value:
                    return bytes(data)
                data.append(value)
            raise ValueError('Unterminated model-name test input')
        def strcmp(machine):
            a, b = cstring(machine.r[0]), cstring(machine.r[1])
            machine.r[0] = 0 if a == b else 1 if a > b else 0xffffffff
        m.run(0xaa714, stop=0xab2f0, hooks={0x5a3608: strcmp}, max_steps=1000)
        return m.r[5]

    def chip_number(self, selector):
        self.m.reset((selector,))
        return self.m.run(0xa72b4, max_steps=500)

    def _set_config(self, count):
        if not 1 <= count <= 256:
            raise ValueError('Outside the verified attribution domain')
        self.m.write(0x654b0c, 4)
        self.m.write(0x654b14, count)

    def locate(self, nonce, count):
        self._set_config(count)
        m = self.m
        m.reset((nonce,))
        chip = m.run(0xd2760, max_steps=1000)
        if not {0xfdfbc, 0xe4600, 0xfe014}.issubset(m.executed):
            raise ValueError('Original BM1368 chip dispatch not executed')
        if 0xe4628 in m.executed:
            raise ValueError('Unexpected original invalid-index fallback')
        m.reset((nonce,))
        core = m.run(0xd280c, max_steps=1000)
        if not {0xfdfbc, 0xe4688}.issubset(m.executed):
            raise ValueError('Original BM1368 core dispatch not executed')
        return chip, core

    def rx_attribution(self, variant, payload, count):
        if variant not in (0, 1, 2) or len(payload) != 7 + variant:
            raise ValueError('Wrong test payload format')
        self._set_config(count)
        m = self.m
        m.reset()
        fp = m.STACK_TOP - 0x1000
        m.r[11] = fp
        m.r[13] = fp - 0x200
        m.r[10] = m.DATA_BASE + 0x1000
        m.r[6] = variant
        m.r[0] = m.DATA_BASE + 0x2000
        m.r[1] = fp - 103
        m.r[8] = fp - 104
        m.mem[fp-104:fp-104+len(payload)] = payload
        # Original producer chooses the payload offset, reverses the loaded
        # word, and invokes both complete original attribution dispatchers.
        m.run(0xc4588, stop=0xc45c4, max_steps=2000)
        if not {0xe4600, 0xe4688, 0xd2760, 0xd280c}.issubset(m.executed):
            raise ValueError('RX attribution composition was bypassed')
        return m.read(fp-216), m.read(fp-244), m.read(fp-240)
