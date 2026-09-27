#!/usr/bin/env python3
"""e4a74 + original CRC/cache, optionally e249c/ff288, against compiled C.
No live transport, firmware process, threads, syscalls or emulator patching.
The historical cache API omits diagnostics: those are counted, not equated.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import random
import struct
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_vfp_subset import ARM32VFP
from arm32_subset import MASK, signed
import test_bm1368_frequency_135 as PLL

START, END = 0xe4a74, 0xe4bec
DEVICE, CHIP, CACHE_BASE, CHIP_BASE = 0x840000, 0x840100, 0x841000, 0x844000
GLOBAL_PTR, GLOBAL_COUNT, GLOBAL_READY = 0x654d68, 0x654d6c, 0x654d70
RANGES = ((START, END), (0xf7f10, 0xf8040), (0x107648, 0x10797c),
          (0x107ed0, 0x108244), (0xe249c, 0xe27c0), (0xff288, 0xff630))
I, U, P, S = C.c_int32, C.c_uint32, C.c_void_p, C.c_size_t
Device = PLL.Device
class Chip(C.Structure):
    _fields_ = [('index', I), ('address', U)]
SEND = C.CFUNCTYPE(I, P, C.POINTER(Device), C.POINTER(C.c_uint8), S)
CHAIN = C.CFUNCTYPE(I, P, I, U, U)
ONE = C.CFUNCTYPE(I, P, I, I, U, U)
LOG = C.CFUNCTYPE(None, P, U, U)
class Ops(C.Structure):
    _fields_ = [('send', SEND), ('chain', CHAIN), ('chip', ONE), ('log', LOG)]
class Entry(C.Structure):
    _fields_ = [('address', U), ('value', U)]
class Table(C.Structure):
    _fields_ = [('entries', Entry * 64)]
class CacheChain(C.Structure):
    _fields_ = [('common', Table), ('chips', C.POINTER(Table)), ('count', I)]
class Allocator(C.Structure):
    _fields_ = [('opaque', P), ('allocate', P), ('release', P)]
class Cache(C.Structure):
    _fields_ = [('chains', C.POINTER(CacheChain)), ('count', I),
                ('ready', C.c_uint8), ('allocator', Allocator)]

TABLES = json.loads((ROOT / 'evidence/stage4/cache-defaults.json').read_text())['tables']

def pick(p, key, n, default=0):
    value = p.get(key, default)
    return value[min(n, len(value)-1)] if isinstance(value, list) else value

def initial_tables(elf, p):
    raw = elf.read(int(TABLES[p.get('selector', 4)]['address'], 16), 512)
    tables = []
    for chain in range(2):
        records = [bytearray(raw) for _ in range(4)]
        for j, record in enumerate(records):
            for slot in range(64):
                struct.pack_into('<I', record, slot*8+4, (chain*0x100000+j*0x10000+slot) & MASK)
        if p.get('shape') == 'different_slots':
            # set_chain propagates the common table's SLOT, not a per-chip search.
            for record in records[1:]:
                record[8:16], record[16:24] = record[16:24], record[8:16]
        elif p.get('shape') == 'duplicate':
            for record in records:
                struct.pack_into('<I', record, 8, 8)
                struct.pack_into('<I', record, 16, 8)
        tables.append(tuple(map(bytes, records)))
    return tables

class NativeView:
    def __init__(self, elf, p):
        self.device = Device(p.get('device', 1) & MASK)
        self.chip = Chip(signed(p.get('index', 2) & MASK), p.get('address', 0x123) & MASK)
        self.chains = (CacheChain * 2)()
        self.arrays = [(Table * 3)() for _ in range(2)]
        self.cache = Cache(self.chains, p.get('chain_count', 2), p.get('ready', 1), Allocator())
        for i, records in enumerate(initial_tables(elf, p)):
            self.chains[i].chips = self.arrays[i]
            self.chains[i].count = p.get('chip_count', 3)
            C.memmove(C.byref(self.chains[i].common), records[0], 512)
            for j in range(3):
                C.memmove(C.byref(self.arrays[i][j]), records[j+1], 512)
    def snapshot(self, cache=False):
        fields = (self.device.index, self.chip.index, self.chip.address)
        if not cache:
            return fields
        raw = b''.join(bytes(ch.common)+b''.join(bytes(x) for x in arr)
                       for ch, arr in zip(self.chains, self.arrays))
        return fields + (self.cache.ready, self.cache.count,
                         tuple(x.count for x in self.chains), raw)
    def mutate(self, key, value):
        if key == 'device': self.device.index = value & MASK
        elif key == 'index': self.chip.index = signed(value & MASK)
        elif key == 'address': self.chip.address = value & MASK
        elif key == 'ready': self.cache.ready = value
        elif key == 'chain_count': self.cache.count = value
        elif key == 'chip_count':
            for x in self.chains: x.count = value
        else: raise AssertionError(key)

class ArmView:
    def __init__(self, m, elf, p):
        self.m = m
        m.mem[DEVICE:DEVICE+0x10000] = b'\xa5' * 0x10000
        for key, default in [('device', 1), ('index', 2), ('address', 0x123),
                             ('ready', 1), ('chain_count', 2), ('chip_count', 3)]:
            self.mutate(key, p.get(key, default))
        m.write(GLOBAL_PTR, CACHE_BASE)
        for i, records in enumerate(initial_tables(elf, p)):
            base = CACHE_BASE + i*520
            m.mem[base:base+512] = records[0]
            address = CHIP_BASE+i*0x1000
            m.write(base+512, address)
            for j in range(3):
                m.mem[address+j*512:address+(j+1)*512] = records[j+1]
        for lit, pc in ((0xe4bfc, 0xe4b80), (0xe4c00, 0xe4bb0),
                        (0xf8040, 0xf7ffc), (0xf8044, 0xf8004)):
            target = m.read((pc+8+m.read(lit)) & MASK)
            m.write(target, p.get('opaque', MASK))
        self.before = bytes(m.mem[DEVICE:DEVICE+0x10000])
    def snapshot(self, cache=False):
        m = self.m
        fields = (m.read(DEVICE+24), signed(m.read(CHIP)), m.read(CHIP+4))
        if not cache: return fields
        raw = b''.join(bytes(m.mem[CACHE_BASE+i*520:CACHE_BASE+i*520+512])+
                       bytes(m.mem[CHIP_BASE+i*0x1000:CHIP_BASE+i*0x1000+3*512])
                       for i in range(2))
        return fields + (m.read(GLOBAL_READY, 1), signed(m.read(GLOBAL_COUNT)),
                         tuple(signed(m.read(CACHE_BASE+i*520+516)) for i in range(2)), raw)
    def mutate(self, key, value):
        m = self.m
        if key == 'device': m.write(DEVICE+24, value)
        elif key == 'index': m.write(CHIP, value)
        elif key == 'address': m.write(CHIP+4, value)
        elif key == 'ready': m.write(GLOBAL_READY, value, 1)
        elif key == 'chain_count': m.write(GLOBAL_COUNT, value)
        elif key == 'chip_count':
            for i in range(2): m.write(CACHE_BASE+i*520+516, value)
        else: raise AssertionError(key)
    def check_extra_writes(self):
        m = self.m
        got = bytearray(m.mem[DEVICE:DEVICE+0x10000])
        allowed = [(24, 4), (CHIP-DEVICE, 8)]
        for i in range(2):
            allowed += [(CACHE_BASE-DEVICE+i*520, 512), (CACHE_BASE-DEVICE+i*520+516, 4),
                        (CHIP_BASE-DEVICE+i*0x1000, 3*512)]
        for off, size in allowed: got[off:off+size] = self.before[off:off+size]
        assert got == self.before, 'unexpected original fixture write'

class Script:
    def __init__(self, p, view):
        self.p, self.view = p, view
        self.events, self.counts = [], collections.Counter()
    def call(self, name, *args):
        n = self.counts[name]
        self.counts[name] += 1
        self.events.append((name, *args, self.view.snapshot(self.p.get('nested', False))))
        for at, occurrence, key, value in self.p.get('mutations', []):
            if (at, occurrence) == (name, n): self.view.mutate(key, value)
        return pick(self.p, name, n)

class Machine(ARM32VFP):
    def extra_instruction(self, word, pc):
        assert any(a <= pc < b for a, b in RANGES), ('unreviewed instruction', hex(pc))
        self.visited.add(pc)
        if self.observer and pc in (0x107648, 0x107ed0):
            self.observer(pc)
        return super().extra_instruction(word, pc)

class Original:
    def __init__(self, elf):
        self.elf, self.m = elf, Machine(elf)
        self.steps, self.visited, self.excluded = 0, set(), collections.Counter()
    def run(self, p):
        m = self.m
        m.visited = set()
        view, results = ArmView(m, self.elf, p), []
        sc = Script(p, view)
        def cache_event(pc):
            if pc == 0x107648:
                return sc.call('cache_chain', signed(m.r[0]), m.r[1], m.r[2])
            return sc.call('cache_chip', signed(m.r[0]), signed(m.r[1]), m.r[2], m.r[3])
        def send(mm):
            assert mm.r[0] == DEVICE and mm.r[2] == 9
            mm.r[0] = sc.call('send', bytes(mm.mem[mm.r[1]:mm.r[1]+9]).hex()) & MASK
        def log(mm):
            line, sp = mm.r[3], mm.r[13]
            if line == 350:
                assert mm.r[:3] == [0x5eb3e0, 0x5eb3e7, 0x5eb411]
                assert mm.read(sp) == 1 and mm.read(sp+4) == 0x5eb883
                if not p.get('nolog'): sc.call('log', line, mm.read(sp+8))
            elif p.get('pll') and line in (966, 972):
                sc.call('pll_log', line, mm.read(sp+8), bytes(mm.mem[sp+16:sp+24]).hex())
            else:
                # Previously recovered computational cache/PLL API omits these.
                self.excluded[line] += 1
            mm.r[0] = 0xabcdef
        hooks = {0xd26ac: send, 0xfa0c4: log}
        if p.get('nested'):
            m.observer = cache_event  # Observe entry, then execute ORIGINAL body.
        else:
            m.observer = None
            hooks[0x107648] = lambda mm: setattr(mm, 'r', [cache_event(0x107648)&MASK]+mm.r[1:])
            hooks[0x107ed0] = lambda mm: setattr(mm, 'r', [cache_event(0x107ed0)&MASK]+mm.r[1:])
        for _ in range(p.get('repeat', 1)):
            if p.get('pll'):
                m.reset((DEVICE,))
                m.set_d(0, p.get('frequency', 600.75))
                start = 0xe249c
            else:
                m.reset((DEVICE, p.get('mode', 1), 0 if p.get('null') else CHIP,
                         p.get('reg', 8), p.get('value', 0x12345678)))
                start = START
            results.append(signed(m.run(start, hooks=hooks, max_steps=100000)))
            assert m.r[13] == m.STACK_TOP
            self.steps += m.steps
            self.visited |= m.visited
        view.check_extra_writes()
        return results, view.snapshot(p.get('nested', False)), sc.events

class Native:
    def __init__(self, lib, elf):
        self.lib, self.elf = lib, elf
        self.f = lib.vn135_bm1368_write_register_135
        self.f.argtypes = [C.POINTER(Device), U, C.POINTER(Chip), U, U, C.POINTER(Ops), P]
        self.f.restype = I
        self.chain = lib.vn135_bm1368_register_cache_chain_135
        self.chain.argtypes, self.chain.restype = [P, I, U, U], I
        self.chip = lib.vn135_bm1368_register_cache_chip_135
        self.chip.argtypes, self.chip.restype = [P, I, I, U, U], I
        self.pll = PLL.Native(lib)
    def run(self, p):
        view = NativeView(self.elf, p)
        sc, errors, keep = Script(p, view), [], []
        def cb(ty, fn):
            def call(*args):
                try: return fn(*args)
                except BaseException as e:
                    errors.append(e)
                    return None if ty in (LOG, PLL.LOG) else -999
            obj = ty(call)
            keep.append(obj)
            return obj
        def send(_, device, payload, size):
            assert C.addressof(device.contents) == C.addressof(view.device) and size == 9
            return sc.call('send', C.string_at(payload, size).hex())
        def chain(_, i, reg, value):
            rc = sc.call('cache_chain', i, reg, value)
            return self.chain(C.byref(view.cache), i, reg, value) if p.get('nested') else rc
        def chip(_, i, j, reg, value):
            rc = sc.call('cache_chip', i, j, reg, value)
            return self.chip(C.byref(view.cache), i, j, reg, value) if p.get('nested') else rc
        ops = Ops(cb(SEND, send), cb(CHAIN, chain), cb(ONE, chip),
                  LOG() if p.get('nolog') else cb(LOG, lambda _, l, i: sc.call('log', l, i)))
        def pll_write(_, device, mode, arg, reg, value):
            assert not arg
            return self.f(device, mode, None, reg, value, C.byref(ops), None)
        pop = PLL.Ops(cb(PLL.SOLVE, self.pll.solve), cb(PLL.WRITE, pll_write),
                      cb(PLL.LOG, lambda _, l, i, f: sc.call('pll_log', l, i, PLL.bits(f))))
        results = []
        for _ in range(p.get('repeat', 1)):
            if p.get('pll'):
                results.append(self.pll.f(C.byref(view.device), p.get('frequency', 600.75), C.byref(pop), None))
            else:
                results.append(self.f(C.byref(view.device), p.get('mode', 1),
                    None if p.get('null') else C.byref(view.chip), p.get('reg', 8),
                    p.get('value', 0x12345678), C.byref(ops), None))
        if errors: raise errors[0]
        return results, view.snapshot(p.get('nested', False)), sc.events

def direct_cases(quick=False):
    for mode, null, status in itertools.product((0, 1, 2, MASK), (False, True), (0, -1, 7)):
        yield dict(mode=mode, null=null, send=status)
    for mode, status in itertools.product((0, 1, 2), (-1, 7, -2147483648)):
        yield dict(mode=mode, cache_chain=status, cache_chip=status)
    for mode, reg in itertools.product((0, 1, 2), (8, 255, 256, 0x108, MASK)):
        yield dict(mode=mode, reg=reg, address=0x123)
    for key, value in [('device', MASK), ('index', 7), ('address', 0x456)]:
        for mode in (0, 1, 2):
            yield dict(mode=mode, mutations=[('send', 0, key, value)], repeat=2)
    yield dict(mode=0, send=-1, mutations=[('send', 0, 'device', MASK)], repeat=2)
    if quick: return
    for mode in range(256): yield dict(mode=mode)
    for field in ('address', 'reg'):
        for value in range(256): yield {field: value, 'mode': 0}
    for step in ('send', 'cache_chain', 'cache_chip', 'log'):
        for key in ('device', 'index', 'address'):
            for mode in (0, 1, 2):
                for status in (0, -17):
                    yield dict(mode=mode, send=status, mutations=[(step, 0, key, MASK)], repeat=2)
    rng = random.Random(0xe4a74)
    for _ in range(256):
        yield dict(mode=rng.choice((0, 1, 2, MASK)), reg=rng.getrandbits(32),
                   address=rng.getrandbits(32), index=rng.getrandbits(32), device=rng.getrandbits(32),
                   value=rng.getrandbits(32), send=rng.choice((0, 0, -1, 9)),
                   cache_chain=rng.choice((0, 0, -2, 17)), cache_chip=rng.choice((0, 0, -7, 17)),
                   null=bool(rng.getrandbits(1)), opaque=rng.getrandbits(32), nolog=bool(rng.getrandbits(1)))

def cache_cases(quick=False):
    for mode, reg, ready in itertools.product((0, 1, 2, MASK), (8, 0x25, 0x108, MASK), (0, 1)):
        yield dict(nested=True, mode=mode, reg=reg, ready=ready)
    for field in ('device', 'index'):
        for mode, value in itertools.product((0, 1, 2), (-1, 0, 1, 2, 3, 0x80000000)):
            yield dict(nested=True, mode=mode, mutations=[('send', 0, field, value)])
    for mode in (0, 1, 2):
        for shape in ('normal', 'different_slots', 'duplicate'):
            yield dict(nested=True, mode=mode, shape=shape)
    if quick: return
    for selector, mode, reg, null in itertools.product(range(8), (0, 1, 2, MASK), (0, 8, 0x18, 0xfc, 0xff), (False, True)):
        yield dict(nested=True, selector=selector, mode=mode, reg=reg, null=null, repeat=2)
    for mode, field, value in itertools.product((0, 1, 2), ('ready', 'chain_count', 'chip_count'), (0, 1, 2)):
        yield dict(nested=True, mode=mode, mutations=[('send', 0, field, value)], repeat=2)
    for mode, status in itertools.product((0, 1, 2), (-1, 7)):
        yield dict(nested=True, mode=mode, send=status)

def pll_cases(quick=False):
    for f, a, b in itertools.product((400., 600.75, 800.) if quick else (0., 50., 400., 449.9, 450., 600.75, 625., 800., 3201., 1e9), (0, -1), (0, -7)):
        yield dict(nested=True, pll=True, frequency=f, send=[a, b])
    for field, value in [('ready', 0), ('device', -1), ('device', 0), ('chip_count', 0)]:
        for occurrence in (0, 1):
            yield dict(nested=True, pll=True, mutations=[('send', occurrence, field, value)])

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('library')
    ap.add_argument('--summary')
    ap.add_argument('--quick', action='store_true')
    args = ap.parse_args()
    elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest() == PLL.HASH
    lib = C.CDLL(str(Path(args.library).resolve()))
    old, new, totals = Original(elf), Native(lib, elf), collections.Counter()
    for name, cases in [('direct', direct_cases), ('nested_cache', cache_cases), ('nested_pll', pll_cases)]:
        for number, params in enumerate(cases(args.quick)):
            want, got = old.run(params), new.run(params)
            assert want == got, ('SEMANTIC_MISMATCH', name, number, params,
                                 'return', want[0], got[0], 'trace', want[2], got[2])
            totals[name+'_cases'] += 1
            totals[name+'_events'] += len(want[2])
    totals['original_steps'], totals['visited_instructions'] = old.steps, len(old.visited)
    output = dict(totals)
    output['excluded_internal_diagnostics'] = dict(old.excluded)
    print('BM1368_REGISTER135_ORIGINAL_PASS', json.dumps(output, sort_keys=True))
    if args.summary: Path(args.summary).write_text(json.dumps(output, indent=2)+'\n')
if __name__ == '__main__': main()
