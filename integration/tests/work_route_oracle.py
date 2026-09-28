"""Bounded original selection; no vendor process, threads, devices or syscalls.

Inputs are already-parsed snapshots. Only strcmp is substituted in algorithm
parsing. Thread creation and pthread initialization are intercepted in a separate
initializer trace. The original callback selector and global getter execute.
"""
from pathlib import Path
import hashlib
import json
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce
SHA = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

class TraceARM(ARM32Nonce):
    def reset(self, args=()):
        super().reset(args)
        self.executed = set()
    def extra_instruction(self, word, pc):
        self.executed.add(pc)
        return super().extra_instruction(word, pc)

class WorkRouteOracle:
    def __init__(self):
        self.elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        if hashlib.sha256(self.elf.data).hexdigest() != SHA:
            raise ValueError('Unexpected original ELF')
        evidence = json.loads((ROOT / 'integration/evidence/work_route.json').read_text())
        for item in evidence['ranges']:
            start, end = int(item['start'],16), int(item['end_exclusive'],16)
            digest = hashlib.sha256(self.elf.read(start,end-start)).hexdigest()
            if digest != item['sha256']:
                raise ValueError('Original slice checksum mismatch: '+item['name'])
        self.m = TraceARM(self.elf)

    def algorithm(self, name):
        if not isinstance(name, bytes) or b'\0' in name or len(name) > 128:
            raise ValueError('Invalid bounded algorithm name')
        m = self.m
        m.reset()
        sp, base = m.STACK_TOP - 0x1000, m.DATA_BASE
        fp = sp + 0x400
        m.r[11], m.r[13], m.r[9], m.r[5] = fp, sp, base, 0
        m.write(fp - 0x30, base + 0x800)
        m.write(base + 0x800, base + 0x900)
        m.mem[base + 0x900:base + 0x901 + len(name)] = name + b'\0'
        for address, key, expected in ((0x5e8153, 131, b'sha256d\0'),
                                       (0x5e815b, 39, b'scrypt\0')):
            decoded = bytes(x ^ key for x in self.elf.read(address, len(expected)))
            if decoded != expected:
                raise ValueError('Algorithm literal mismatch')
            m.mem[address:address + len(expected)] = decoded
        def cstring(address):
            result = bytearray()
            for i in range(129):
                value = m.read(address+i, 1)
                if value == 0:
                    return bytes(result)
                result.append(value)
            raise ValueError('Unterminated test string')
        def compare(cpu):
            a, b = cstring(cpu.r[0]), cstring(cpu.r[1])
            cpu.r[0] = 0 if a == b else 1 if a > b else 0xffffffff
        m.run(0xa898c, stop=0xa89d4, hooks={0x5a3608: compare}, max_steps=2000)
        return m.read(base + 0x34)

    def caller_platform(self, chip=4, chip_count=108, bypass=0):
        # This executes the reference base.c caller's constant, not hwscan.
        if chip not in range(8) or not 1 <= chip_count <= 256 or bypass not in (0, 1):
            raise ValueError('Outside bounded initialization snapshot')
        m = self.m
        m.reset()
        base = m.DATA_BASE
        m.r[4], m.r[7], m.r[8] = base, base+0x100, base+0x200
        m.write(base+0x10, chip_count)
        m.write(base+0x100, chip)
        m.write(base+0x22c, bypass, 1)
        # Stop immediately after config stores; no peripheral initialization.
        m.run(0x732ac, stop=0xfbbbc, max_steps=3000)
        if not {0x732c0, 0xfb994, 0xfbb98, 0xfbba0, 0xfbbac}.issubset(m.executed):
            raise ValueError('Caller/config stores bypassed')
        return m.read(0x654b08), m.read(0x654b0c), m.read(0x654b14)

    def select(self, platform, algorithm):
        if not 0 <= platform <= 0xffffffff or not 0 <= algorithm <= 0xffffffff:
            raise ValueError('Expected u32 selectors')
        m = self.m
        m.reset()
        base, model = m.DATA_BASE, m.DATA_BASE+0x2000
        m.mem[base:base+0x220] = b'\xa5'*0x220
        m.write(0x654b08, platform)
        m.r[4], m.r[9], m.r[10] = base, base+0x1800, base+0x1804
        m.write(base+0x1800, 0)
        m.write(base+0x1804, 0)
        m.write(base+0x18, model)
        m.write(model+0x34, algorithm)
        m.write(m.STACK_TOP+0x24, base)
        m.run(0x738a4, stop=0x73af8, max_steps=2000)
        if 0xfdfac not in m.executed:
            raise ValueError('Original global getter not executed')
        return tuple(m.read(base+i) for i in range(0x1f0, 0x20c, 4))

    def worker_entries(self, initializer):
        if initializer not in (0xc1c0c, 0xc3b54):
            raise ValueError('Unexamined initializer')
        m = self.m
        m.reset((m.DATA_BASE,))
        entries = []
        def no_op(cpu):
            cpu.r[0] = 0
        def create(cpu):
            entries.append(cpu.r[2])
            if cpu.r[3] != m.DATA_BASE:
                raise ValueError('Unexpected worker context')
            cpu.r[0] = 0
        hooks = {address: no_op for address in
                 (0x5a50e8, 0x5a50f8, 0x5a60dc, 0x5a4a08, 0x5a50e0)}
        hooks[0x5a55cc] = create
        rc = m.run(initializer, hooks=hooks, max_steps=3000)
        if rc != 0:
            raise ValueError('Initializer trace failed')
        return tuple(entries)

    def shared_slot_table(self):
        # Resolve BOTH original PC-relative table addresses independently.
        def word(a):
            return int.from_bytes(self.elf.read(a, 4), 'little')
        tx_table = (0xc4da8 + 8 + word(0xc5068)) & 0xffffffff
        rx_table = (0xc4508 + 8 + word(0xc4ad4)) & 0xffffffff
        tx_slot_address = (0xc4da0 + 8 + word(0xc5064)) & 0xffffffff
        if tx_table != rx_table or tx_slot_address != tx_table:
            raise ValueError('TX/RX do not reference the same slot table')
        return tx_table
