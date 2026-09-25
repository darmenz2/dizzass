"""Bounded original software-I2C instruction execution; no OS or GPIO access."""
from pathlib import Path
import hashlib
import json
import sys
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
from arm32_subset import signed

ENTRIES = {'input': 0x126e0c, 'output': 0x1287c4, 'start': 0x127030,
           'stop': 0x127e28, 'send': 0x12728c,
           'write_byte': 0x126fcc, 'read_byte': 0x128188}

class Tracked(ARM32Verify):
    def reset(self, args=()):
        super().reset(args)
        self.visited = set()
        self.allowed = [(0x126e0c, 0x1289c4), (0x129088, 0x1290b4)]
    def extra_instruction(self, word, pc):
        if not any(a <= pc < b for a, b in self.allowed):
            raise ValueError('Unexpected executable PC: ' + hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(word, pc)

class Oracle:
    BUS = 0x840000
    SOFT = BUS + 0x24
    def __init__(self):
        self.evidence = json.loads((ROOT / 'integration/evidence/i2c_soft_135.json').read_text())
        self.elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest() == self.evidence['reference_sha256']
        for item in self.evidence['ranges']:
            a, b = int(item['start'], 16), int(item['end_exclusive'], 16)
            assert hashlib.sha256(self.elf.read(a, b-a)).hexdigest() == item['sha256']
        for item in self.evidence['literal_words']:
            assert self.elf.read(int(item['address'], 16), 4).hex() == item['hex']
        item = self.evidence['source_path']
        raw = self.elf.read(int(item['address'], 16), len(item['text'])+1)
        assert bytes(x ^ item['xor'] for x in raw) == item['text'].encode() + b'\0'
        self.m = Tracked(self.elf)
    def begin(self, spec, initial):
        m = self.m
        # Execute the original three-byte constructor slice, not guessed output.
        # Restore only the encrypted literal before executing its original loop.
        m.mem[0x5ef56f:0x5ef56f+3] = self.elf.read(0x5ef56f, 3)
        m.reset()
        m.run(0x129088, stop=0x1290b4, max_steps=100)
        assert m.mem[0x5ef56f:0x5ef56f+3] == b'out'
        direction, fd, direction_fd, scl_fd, path = initial
        name, address, mode, reg, value = spec
        args = (self.BUS, address, mode, reg, value) if name.endswith('_byte') else (self.SOFT, value)
        m.reset(args)
        m.write(self.SOFT, direction, 1)
        m.write(self.SOFT+0x20c, fd)
        m.write(self.SOFT+0x210, direction_fd)
        m.write(self.SOFT+0x41c, scl_fd)
        data = path.encode()+b'\0'
        assert len(data) <= 512
        m.mem[self.SOFT+8:self.SOFT+8+len(data)] = data
    def snapshot(self):
        m = self.m
        return (m.read(self.SOFT, 1), signed(m.read(self.SOFT+0x20c)))
    def hooks(self, script):
        def write(m):
            script.state = self.snapshot
            n = m.r[2]; m.check(m.r[1], n)
            m.r[0] = script.write(signed(m.r[0]), bytes(m.mem[m.r[1]:m.r[1]+n])) & 0xffffffff
        def read(m):
            script.state = self.snapshot
            n = m.r[2]; m.check(m.r[1], n)
            result, data = script.read(signed(m.r[0]), n)
            if data is not None:
                assert len(data) <= n
                m.mem[m.r[1]:m.r[1]+len(data)] = data
            m.r[0] = result & 0xffffffff
        def open_(m):
            script.state = self.snapshot
            p=m.r[0]; m.check(p, 1)
            raw=bytes(m.mem[p:p+512]); assert b'\0' in raw
            m.r[0] = script.open(raw.split(b'\0')[0].decode(), m.r[1]) & 0xffffffff
        def close(m):
            script.state = self.snapshot
            m.r[0] = script.close(signed(m.r[0])) & 0xffffffff
        def delay(m):
            script.state = self.snapshot
            m.r[0] = script.delay(m.r[0]) & 0xffffffff
        def log(m):
            script.state = self.snapshot
            line=m.r[3]; severity=m.read(m.r[13])
            arg=m.read(m.r[13]+8) if line==309 else 0
            script.log(line, severity, arg)
            m.r[0]=0
        return {0x5a8684:write, 0x5a8498:read, 0x5936dc:open_, 0x5a811c:close,
                0x10ed2c:delay, 0xfa0c4:log}
    def run(self, spec, script, initial):
        self.begin(spec, initial)
        rc = self.m.run(ENTRIES[spec[0]], hooks=self.hooks(script), max_steps=60000)
        return (signed(rc) if spec[0].endswith('_byte') else None,
                self.snapshot(), script.events)
