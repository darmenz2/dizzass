"""Bounded original AML gate, reset and shutdown paths. No hardware/process.

External GPIO or libc side effects are explicit hooks. Full dispatcher selection
executes up to, but not including, the first peripheral initializer.
"""
from pathlib import Path
import hashlib
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
SHA = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

def signed(value):
    return value if value < 0x80000000 else value - 0x100000000

def nop(cpu):
    cpu.r[0] = 0

class TracedPowerARM(ARM32Verify):
    def reset(self, args=()):
        super().reset(args)
        self.executed = set()
    def extra_instruction(self, word, pc):
        self.executed.add(pc)
        return super().extra_instruction(word, pc)

class PowerOracle:
    def __init__(self):
        self.elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        if hashlib.sha256(self.elf.data).hexdigest() != SHA:
            raise ValueError('Unexpected original ELF')
        self.m = TracedPowerARM(self.elf)
        self.flag = self.relative(0x11c98c, 0x11ca58)
        assert self.flag == self.relative(0x11ca88, 0x11cbb8)
        self.pins_addr = self.relative(0x11bca0, 0x11bd60)
        self.pins = tuple(self.m.read(self.pins_addr + 4*i) for i in range(3))
        self.select()

    def relative(self, pc, literal):
        return (pc + 8 + int.from_bytes(self.elf.read(literal, 4), 'little')) & 0xffffffff

    def select(self, chips=108):
        m = self.m
        m.reset()
        b = m.DATA_BASE
        m.r[4], m.r[7], m.r[8] = b, b+0x100, b+0x200
        m.write(b+0x10, chips)
        m.write(b+0x100, 4)
        m.write(b+0x22c, 0, 1)
        m.run(0x732ac, stop=0xfd790, max_steps=20000)
        return {hex(a): m.read(a) for a in (0x654b08, 0x654b0c, 0x654b14,
            0x654b28, 0x654b44, 0x654b5c, 0x654b74, 0x654b78, 0x654b7c)}

    def gate(self, initialized, enable, status):
        m = self.m
        m.reset()
        m.write(self.flag, initialized, 1)
        trace = []
        def gpio(c):
            trace.append((c.r[0], c.r[1]))
            c.r[0] = status & 0xffffffff
        rc = m.run(0xfe310 if enable else 0xfe398,
                   hooks={0x124ba4: gpio, 0xfa0c4: nop}, max_steps=20000)
        assert (0x11c978 if enable else 0x11ca74) in m.executed
        return signed(rc), trace

    def reset_chain(self, chain, asserted, status):
        m = self.m
        m.reset((chain & 0xffffffff, asserted))
        trace = []
        def gpio(c):
            trace.append((c.r[0], c.r[1]))
            c.r[0] = status & 0xffffffff
        rc = m.run(0xfde14, hooks={0x124ba4: gpio, 0xfa0c4: nop}, max_steps=20000)
        assert 0x11bc14 in m.executed
        return signed(rc), trace

    def shutdown(self, initialized, statuses=(0, 0, 0, 0)):
        if len(statuses) != 4:
            raise ValueError('Need four GPIO return codes')
        m = self.m
        b = m.DATA_BASE
        m.reset((b,))
        m.mem[b:b+0x4000] = bytes(0x4000)
        m.write(self.flag, initialized, 1)
        m.write(b+0x230, b+0x2000)
        m.write(b+0xff1, 1, 1)
        m.write(b+0x20c, 123)
        for i in range(3):
            m.write(b+0x2000+i*800+0x18, i)
        trace = []
        by_pin = dict(zip((437,) + self.pins, statuses))
        def gpio(c):
            trace.append((c.r[0], c.r[1]))
            if c.r[0] not in by_pin:
                raise AssertionError('Unexpected original GPIO')
            c.r[0] = by_pin[c.r[0]] & 0xffffffff
        rc = m.run(0x6b778, hooks={0x124ba4: gpio, 0xfa0c4: nop}, max_steps=30000)
        assert {0x102b04, 0xfe398, 0x11ca74, 0x11b6c8}.issubset(m.executed)
        if trace and trace[-1][0] == 456:
            assert {0x55370, 0xfde14, 0x11bc14}.issubset(m.executed)
        return signed(rc), trace, (m.read(b+0xff1, 1), m.read(b+0x20c))

    def gpio_stdio(self, opened=True, print_status=1, close_status=0, level=1):
        m = self.m
        m.reset((437, level))
        trace = []
        def fmt(c):
            text = ('/sys/class/gpio/gpio%u/value' % c.r[3]).encode() + b'\0'
            assert c.r[1] == 256
            m.mem[c.r[0]:c.r[0]+len(text)] = text
            trace.append(('format', c.r[3]))
            c.r[0] = len(text)-1
        def fopen(c):
            trace.append(('open',))
            c.r[0] = m.DATA_BASE+0x5000 if opened else 0
        def fprintf(c):
            trace.append(('write', c.r[2]))
            c.r[0] = print_status & 0xffffffff
        def fclose(c):
            trace.append(('close',))
            c.r[0] = close_status & 0xffffffff
        hooks = {0x5a6108: nop, 0x5a66c4: nop, 0x59f558: fmt, 0x59e5b0: fopen,
            0x59e658: fprintf, 0x59e084: fclose, 0xfa0c4: nop, 0x59ef60: nop}
        rc = m.run(0x124ba4, hooks=hooks, max_steps=20000)
        return signed(rc), trace

    def thermal(self, pcb, chip, pcb_limit, chip_limit):
        m = self.m
        b = m.DATA_BASE
        m.reset((b, b+0x3000))
        m.mem[b:b+0x4000] = bytes(0x4000)
        for at, value in ((b+0x29c, pcb), (b+0x2ac, chip),
                           (b+0x3010, pcb_limit), (b+0x300c, chip_limit)):
            m.write(at, value & 0xffffffff)
        trace = []
        def stop(c):
            assert c.r[0] == b
            trace.append(('stop_chain',)); c.r[0] = 0
        def secondary(c):
            trace.append(('secondary_action',)); c.r[0] = 0
        def error(c):
            trace.append(('event', c.r[1], signed(c.r[2]))); c.r[0] = 0
        rc = m.run(0x58e68, hooks={0x5a6108: nop, 0x5a66c4: nop, 0xfa0c4: nop,
                   0x56d18: stop, 0xf8c70: secondary, 0x49c98: error, 0x6687c: nop},
                   max_steps=30000)
        return signed(rc), trace

if __name__ == '__main__':
    o = PowerOracle()
    print('FLAG', hex(o.flag), 'RESET PINS', hex(o.pins_addr), o.pins)
    print('ROUTE', o.select())
    print('ON', o.gate(1, 1, 0), 'OFF UNINIT', o.gate(0, 0, 0))
    print('RESET', o.reset_chain(1, 1, -7))
    print('SHUTDOWN', o.shutdown(1), o.shutdown(1, (0, -1, -1, -1)))
    print('GPIO', o.gpio_stdio(True, -1, -1))
    print('THERMAL', o.thermal(80, 90, 80, 90), o.thermal(79,90,80,90), o.thermal(79,89,80,90))
