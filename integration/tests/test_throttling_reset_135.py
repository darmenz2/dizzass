#!/usr/bin/env python3
"""A-01: original b8e54, optionally nested in original 663cc, versus C.
All lower effects are scripted. Original instructions are data, never a process.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_subset import ARM32, MASK, signed
import test_general_monitor_135 as G
import test_mining_stop_135 as M

START, END = 0xb8e54, 0xb9094
BASE, GLOBAL, MUTEX = M.BASE, 0x68be68, 0x612aa0
MODELS = (0x842000, 0x842400)
OPAQUE_X, OPAQUE_Y = 0x68be50, 0x68be7c
CAP, SIZE = 4, 64
U, I, P = C.c_uint32, C.c_int32, C.c_void_p
BYTE = C.c_uint8
class Model(C.Structure):
    _fields_ = [('general', C.POINTER(G.Model)), ('count_50', U), ('count_60', U)]
class Tables(C.Structure):
    _fields_ = [('groups', C.POINTER(P) * 4)]
class View(C.Structure):
    _fields_ = [('model', C.POINTER(Model)), ('tables', C.POINTER(Tables)), ('mutex', P)]
SCALAR = C.CFUNCTYPE(I, P)
LOCK = C.CFUNCTYPE(I, P, P)
ZERO = C.CFUNCTYPE(None, P, P, U)
class Ops(C.Structure):
    _fields_ = [('count', SCALAR), ('platform', SCALAR), ('lock', LOCK),
                ('unlock', LOCK), ('zero', ZERO)]

def address(pointer):
    return C.cast(pointer, P).value or 0

def array_address(g, b):
    return 0x844000 + g * 0x100 + b * 0x40

def row_address(n):
    return 0x845000 + n * 0x80 + 8

class Machine(ARM32):
    def extra_instruction(self, word, pc):
        assert START <= pc < END or M.START <= pc < M.END or 0xb86fc <= pc < 0xb8984, hex(pc)
        self.visited.add(pc)
        return super().extra_instruction(word, pc)

class World:
    """Identical field/byte model exposed through real C objects or ARM memory."""
    def __init__(self, parameters, machine=None):
        self.p, self.m = parameters, machine
        self.count = parameters.get('count', 3)
        self.events, self.calls, self.keep, self.errors = [], collections.Counter(), [], []
        self.parent = None
        if machine is None:
            self.parent = M.View(parameters.get('parent', {}))
            self.generals = (G.Model * 2)()
            self.models = (Model * 2)()
            self.arrays = [[(P * CAP)() for _ in range(2)] for _ in range(4)]
            self.buffers = [(BYTE * (SIZE + 16))() for _ in range(32)]
            self.table = Tables()
            self.mutex = U(0x12345678)
            self.view = View(C.pointer(self.models[0]), C.pointer(self.table),
                             C.addressof(self.mutex))
            for n in range(2):
                C.memset(C.addressof(self.generals[n]), 0xa5, C.sizeof(G.Model))
                self.models[n].general = C.pointer(self.generals[n])
            self.general_before = [bytes(x) for x in self.generals]
        else:
            machine.mem[BASE:BASE + 0x10000] = b'\xa5' * 0x10000
            M.seed(machine, parameters.get('parent', {}))
            machine.write(OPAQUE_X, parameters.get('opaque', 0xffffffff))
            machine.write(OPAQUE_Y, parameters.get('opaque_y', 10))
            machine.write(GLOBAL + 16, 0x844f00)
        self.set_model(0)
        for bank, sizes in enumerate(parameters.get('sizes', [(3, 2, 4), (1, 5, 2)])):
            for field, value in zip((0x48, 0x50, 0x60), sizes):
                self.set_size(bank, field, value)
        for n in range(32):
            data = bytes([0x37 + n]) * (SIZE + 16)
            if machine is None:
                C.memmove(C.addressof(self.buffers[n]), data, len(data))
            else:
                at = row_address(n) - 8
                machine.mem[at:at + len(data)] = data
        for g in range(4):
            for b in range(2):
                for i in range(CAP):
                    self.set_row(g, b, i, g * 8 + b * 4 + i)
            self.set_group(g, None if g in parameters.get('null_groups', []) else 0)
        for g, b, i in parameters.get('null_rows', []):
            self.set_row(g, b, i, None)
        for mutation in parameters.get('initial', []):
            self.mutate(*mutation)
        if machine:
            self.backend_before = bytes(machine.mem[BASE:BASE + 0x1100])
            self.model_before = [bytes(machine.mem[a:a + 0x100]) for a in MODELS]

    def set_model(self, n):
        if self.m:
            self.m.write(BASE + 0x18, MODELS[n])
        else:
            self.view.model = C.pointer(self.models[n])

    def set_size(self, n, field, value):
        if self.m:
            self.m.write(MODELS[n] + field, value)
        elif field == 0x48:
            self.generals[n].expected_chips_48 = signed(value & MASK)
        else:
            setattr(self.models[n], 'count_%x' % field, value & MASK)

    def set_group(self, g, b):
        if self.m:
            self.m.write(GLOBAL + g * 4, 0 if b is None else array_address(g, b))
        else:
            self.table.groups[g] = C.POINTER(P)() if b is None else self.arrays[g][b]

    def set_row(self, g, b, i, n):
        if self.m:
            self.m.write(array_address(g, b) + i * 4, 0 if n is None else row_address(n))
        else:
            self.arrays[g][b][i] = None if n is None else C.addressof(self.buffers[n]) + 8

    def row_id(self, at):
        if not at:
            return None
        if self.m:
            n = (at - row_address(0)) // 0x80
            assert 0 <= n < 32 and at == row_address(n), hex(at)
            return n
        for n, buf in enumerate(self.buffers):
            if at == C.addressof(buf) + 8:
                return n
        raise AssertionError(('unknown C row', at))

    def snapshot(self):
        if self.m:
            m = self.m
            model = MODELS.index(m.read(BASE + 0x18))
            sizes = tuple(tuple(m.read(a + o) for o in (0x48, 0x50, 0x60)) for a in MODELS)
            groups = tuple(None if not m.read(GLOBAL + 4*g) else
                           (m.read(GLOBAL + 4*g) - array_address(g, 0)) // 0x40 for g in range(4))
            rows = tuple(self.row_id(m.read(array_address(g, b) + i*4))
                         for g in range(4) for b in range(2) for i in range(CAP))
            buffers = tuple(bytes(m.mem[row_address(n)-8:row_address(n)+SIZE+8]) for n in range(32))
            parent = M.snapshot(m)
        else:
            model = next(n for n in range(2) if address(self.view.model) == C.addressof(self.models[n]))
            sizes = tuple((x.expected_chips_48 & MASK, y.count_50, y.count_60)
                          for x, y in zip(self.generals, self.models))
            groups = tuple(None if not address(self.table.groups[g]) else
                           next(b for b in range(2) if address(self.table.groups[g]) ==
                                C.addressof(self.arrays[g][b])) for g in range(4))
            rows = tuple(self.row_id(self.arrays[g][b][i])
                         for g in range(4) for b in range(2) for i in range(CAP))
            buffers = tuple(bytes(buf) for buf in self.buffers)
            parent = self.parent.snap()
        # Full buffers (including both canaries), not just a summary or count.
        return model, sizes, groups, rows, buffers, self.count, parent

    def mutate(self, key, value):
        if key == 'model':
            self.set_model(value)
        elif key == 'size':
            self.set_size(*value)
        elif key == 'group':
            self.set_group(*value)
        elif key == 'row':
            self.set_row(*value)
        elif key == 'count':
            self.count = value
        elif key == 'fill':
            n, byte = value
            at = row_address(n) if self.m else C.addressof(self.buffers[n]) + 8
            if self.m:
                self.m.mem[at:at + SIZE] = bytes([byte]) * SIZE
            else:
                C.memset(at, byte, SIZE)
        elif key.startswith('parent_'):
            field = key[7:]
            if self.m:
                offset, length = M.FIELDS[field]
                self.m.write(BASE + offset, value, length)
            else:
                self.parent.put(field, value)
        else:
            raise AssertionError(key)

    def event(self, name, *args, effect=None):
        n = self.calls[name]
        self.calls[name] += 1
        self.events.append((name, args, self.snapshot()))
        if effect:
            effect()
        for op, nth, key, value in self.p.get('mutations', []):
            if name == op and nth == n:
                self.mutate(key, value)
        default = self.count if name == 'count' else self.p.get('platform', 4) if name == 'platform' else 0
        result = self.p.get('returns', {}).get(name, default)
        return result[min(n, len(result)-1)] if isinstance(result, list) else result

    def zero(self, at, length):
        n = self.row_id(at)
        assert n is not None and length <= SIZE, ('fixture length', length)
        def effect():
            if self.m:
                self.m.mem[at:at + length] = bytes(length)
            else:
                C.memset(at, 0, length)
        self.event('zero', n, length, effect=effect)

    def guard(self, nested):
        if self.m:
            after = bytearray(self.m.mem[BASE:BASE + 0x1100])
            allowed = [(0x18, 4)] + list(M.FIELDS.values())
            for off, n in allowed:
                after[off:off+n] = self.backend_before[off:off+n]
            assert after == self.backend_before, 'unexpected ARM backend write'
            for a, before in zip(MODELS, self.model_before):
                after = bytearray(self.m.mem[a:a+0x100])
                for o in (0x48, 0x50, 0x60):
                    after[o:o+4] = before[o:o+4]
                assert after == before, 'unexpected ARM model write'
            assert self.m.read(GLOBAL+16) == 0x844f00, 'fifth table was changed'
            assert bytes(self.m.mem[0x844f00:0x844f20]) == b'\xa5'*32
        else:
            self.parent.guard()
            for g, before in zip(self.generals, self.general_before):
                after = bytearray(bytes(g));off = G.Model.expected_chips_48.offset
                after[off:off+4] = before[off:off+4]
                assert after == before, 'unexpected C model write'
            assert self.mutex.value == 0x12345678
            assert address(self.view.tables) == C.addressof(self.table)
        for buf in self.snapshot()[4]:
            assert buf[:8] == buf[-8:], 'row canary changed'

class Original:
    def __init__(self, elf):
        self.m = Machine(elf)
        self.steps = 0
        self.visited = set()

    def run(self, p, nested=False):
        m = self.m;w = World(p, m);m.visited = set()
        def scalar(name):
            return lambda _: m.r.__setitem__(0, w.event(name) & MASK)
        def lock(name):
            def hook(_):
                assert m.r[0] == MUTEX
                m.r[0] = w.event(name) & MASK
            return hook
        def zero(_):
            assert m.r[1] == 0
            at, length = m.r[0], m.r[2]
            w.zero(at, length)
            m.r[0] = at
        def parent(name):
            def hook(_):
                if name == 'log':
                    assert m.r[3] == 4825
                    args = (4825,)
                elif name == 'join':
                    assert m.r[1] == 0
                    args = (m.r[0], 0)
                elif name in ('delay', 'cancel'):
                    args = (m.r[0],)
                else:
                    if name == 'fall':
                        assert m.r[0] == BASE
                    args = ()
                m.r[0] = w.event('parent:'+name, *args) & MASK
            return hook
        hooks = {0xfe668:scalar('count'), 0xfdfbc:scalar('platform'),
                 0x5a6108:lock('lock'), 0x5a66c4:lock('unlock'), 0x5a348c:zero}
        if nested:
            hooks.update({0xfe218:parent('platform_stop'), 0x10ed2c:parent('delay'),
                          0x5a4754:parent('cancel'), 0x5a5d2c:parent('join'),
                          0x65b3c:parent('fall'), 0xfa0c4:parent('log')})
        for _ in range(p.get('repeat', 1)):
            m.reset((BASE,))
            saved = [0xd00d0000+i for i in range(8)]
            m.r[4:12] = saved
            m.run(M.START if nested else START, hooks=hooks, max_steps=2000)
            assert m.r[13] == m.STACK_TOP and m.r[4:12] == saved
            self.steps += m.steps
        self.visited |= m.visited
        w.guard(nested)
        return w.snapshot(), w.events

class Native:
    def __init__(self, lib):
        self.reset = lib.vn135_throttling_reset_135
        self.reset.argtypes = [C.POINTER(View), C.POINTER(Ops), P]
        self.reset.restype = None
        self.parent = lib.vn135_backend_stop_mining_135
        self.parent.argtypes = [C.POINTER(M.State), C.POINTER(M.S.Ops), P]
        self.parent.restype = None

    def run(self, p, nested=False):
        w = World(p)
        def cb(kind, fn):
            def wrapper(*args):
                try:
                    return fn(*args)
                except BaseException as error:
                    w.errors.append(error)
                    return None if kind == ZERO else 0
            value = kind(wrapper);w.keep.append(value)
            return value
        def lock(name, token):
            assert token == C.addressof(w.mutex)
            return w.event(name)
        ops = Ops(cb(SCALAR, lambda _: w.event('count')),
                  cb(SCALAR, lambda _: w.event('platform')),
                  cb(LOCK, lambda _, token: lock('lock', token)),
                  cb(LOCK, lambda _, token: lock('unlock', token)),
                  cb(ZERO, lambda _, at, n: w.zero(at, n)))
        def run_reset():
            self.reset(C.byref(w.view), C.byref(ops), None)
        if nested:
            def step(_, ep, arg):
                assert arg == 0
                if ep == START:
                    run_reset();return 0
                assert ep in (0xfe218, 0x65b3c)
                return w.event('parent:'+('fall' if ep == 0x65b3c else 'platform_stop')) & MASK
            po = M.S.Ops()
            po.step = cb(M.S.STEP, step)
            po.delay_ms = cb(M.S.DELAY, lambda _, n: w.event('parent:delay', n))
            po.cancel = cb(M.S.HANDLE, lambda _, handle: w.event('parent:cancel', handle))
            po.join = cb(M.S.JOIN, lambda _, handle, out: w.event('parent:join', handle, int(bool(out))))
            po.log = cb(M.S.LOG, lambda _, line: w.event('parent:log', line))
        for _ in range(p.get('repeat', 1)):
            if nested:
                self.parent(C.byref(w.parent.s), C.byref(po), None)
            else:
                run_reset()
        if w.errors:
            raise w.errors[0]
        w.guard(nested)
        return w.snapshot(), w.events

def cases(quick=False):
    yield 'baseline', {}
    yield 'skip_platform', {'platform':2}
    yield 'supported_7', {'platform':7}
    yield 'zero_count_locks', {'count':0}
    yield 'negative_count_locks', {'count':-1}
    yield 'zero_lengths_still_calls', {'sizes':[(0,0,0),(1,1,1)]}
    yield 'group_after_zero', {'mutations':[('zero',0,'group',[1,1])]}
    yield 'length_after_zero', {'mutations':[('zero',0,'size',[0,0x48,7])]}
    yield 'model_after_count', {'mutations':[('count',0,'model',1)]}
    yield 'model_before_platform', {'mutations':[('platform',0,'model',1)]}
    yield 'model_before_lock', {'mutations':[('lock',0,'model',1)]}
    yield 'count_only_once', {'mutations':[('lock',0,'count',1)]}
    yield 'null_rows', {'null_rows':[(g,0,0) for g in range(4)]}
    yield 'lock_error_ignored', {'returns':{'lock':-1,'unlock':-3}}
    yield 'repeat', {'repeat':2}
    yield 'refill_not_recleared', {'mutations':[('zero',0,'fill',[0,0xe1])]}
    yield 'overflow_lengths', {'sizes':[(0x20000001,0x40000001,0x80000001),(1,1,1)],'null_groups':[3]}
    if quick:
        return
    for platform, count, mask in itertools.product((0,1,2,3,4,7,8,-1), (0,1,3,4,-1), range(16)):
        yield f'gates-{platform}-{count}-{mask}', {'platform':platform,'count':count,
                                                'null_groups':[g for g in range(4) if mask>>g&1]}
    for g, bank, i, dest in itertools.product(range(4), range(2), range(3), (None,0,31)):
        yield f'row-{g}-{bank}-{i}-{dest}', {'initial':[('row',[g,bank,i,dest]),('group',[g,bank])]}
    for op, n in [('count',0),('platform',0),('lock',0),('unlock',0)]+[('zero',i) for i in range(12)]:
        for key, value in [('model',1),('count',0),('group',[0,1]),('group',[2,None]),
                           ('row',[3,0,2,None]),('size',[0,0x48,1]),('size',[0,0x50,6]),('size',[0,0x60,2])]:
            yield f'mutation-{op}-{n}-{key}-{value}', {'mutations':[(op,n,key,value)]}
    rng = random.Random(0xb8e54)
    for i in range(160):
        yield f'random-{i}', {'platform':rng.choice([4,7,2]),'count':rng.randrange(5),
                            'sizes':[[rng.randrange(9) for _ in range(3)] for _ in range(2)],
                            'null_groups':[g for g in range(4) if rng.randrange(4)==0],
                            'null_rows':[(g,0,n) for g in range(4) for n in range(4) if rng.randrange(3)==0],
                            'opaque':rng.getrandbits(32),'opaque_y':rng.getrandbits(32)}

def nested_cases():
    for platform, count, tuning, mask in itertools.product((2,4,7),(0,1,3),(0,1),(0,5,15)):
        yield f'parent-{platform}-{count}-{tuning}-{mask}', {
            'platform':platform,'count':count,'parent':{'tuning':tuning},
            'null_groups':[g for g in range(4) if mask>>g&1]}
    for op in ('zero','unlock'):
        for field, value in [('tuning',0),('handle',0x80000000),('byte_104a',255),('active',0)]:
            yield f'parent-mutation-{op}-{field}', {'mutations':[(op,0,'parent_'+field,value)]}
    yield 'parent-cancel-error', {'returns':{'parent:cancel':-1}}
    yield 'parent-repeat', {'repeat':2}

def allocation_provenance(elf):
    """Execute only successful allocation paths: verify same table and sizes.
    This is provenance, not a reconstruction of the allocator or its error paths.
    """
    total = 0
    for platform_value, count in itertools.product((2,4,7), (0,1,3)):
        machine = Machine(elf)
        world = World({'platform':platform_value, 'count':count}, machine)
        allocations, locks = [], []
        def allocate(m):
            n, stride = m.r[:2]
            j = len(allocations)
            allocations.append((n,stride))
            if j < 4:
                at = array_address(j,0)
            elif j == 4:
                at = 0x844f00
            else:
                chain, group = divmod(j-5,4)
                at = row_address(group*8+chain)
            assert n*stride <= 64
            m.mem[at:at+n*stride] = bytes(n*stride)
            m.r[0] = at
        def lock(m):
            assert m.r[0] == MUTEX
            locks.append('lock');m.r[0] = 0
        def unlock(m):
            assert m.r[0] == MUTEX
            locks.append('unlock');m.r[0] = 0
        machine.visited = set();machine.reset((BASE,))
        hooks = {0xfe668:lambda m:m.r.__setitem__(0,count),
                 0xfdfbc:lambda m:m.r.__setitem__(0,platform_value),
                 0x593bb4:allocate,0x5a6108:lock,0x5a66c4:unlock}
        rc = machine.run(0xb86fc,hooks=hooks,max_steps=2000)
        assert rc == 0 and machine.r[13] == machine.STACK_TOP
        if platform_value == 2:
            assert allocations == [] and locks == []
        else:
            assert locks == ['lock','unlock']
            assert allocations == [(count,4)]*4+[(count,8)]+[(4,8),(3,8),(2,8),(3,1)]*count
            for g in range(4):
                assert machine.read(GLOBAL+g*4) == array_address(g,0)
                for i in range(count):
                    assert machine.read(array_address(g,0)+i*4) == row_address(g*8+i)
            assert machine.read(GLOBAL+16) == 0x844f00
        total += 1
    return total

def compare(lib, quick=False):
    original, native = Original(ELF32(ROOT/'reference/cgminer.vendor.elf')), Native(lib)
    counts = {}
    for name, nested, sequence in [('direct',False,cases(quick)),
                                   ('nested',True,[] if quick else nested_cases())]:
        total = events = 0
        for label, p in sequence:
            expected, actual = original.run(p,nested), native.run(p,nested)
            if expected != actual:
                raise AssertionError(('MISMATCH',name,label,p))
            total += 1;events += len(expected[1])
        counts[name] = {'cases':total,'events':events}
    counts.update(original_steps=original.steps,visited_instructions=len(original.visited))
    if not quick:
        counts['allocation_provenance_cases'] = allocation_provenance(ELF32(ROOT/'reference/cgminer.vendor.elf'))
    return counts

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('library');parser.add_argument('--summary');parser.add_argument('--quick',action='store_true')
    args = parser.parse_args()
    assert hashlib.sha256((ROOT/'reference/cgminer.vendor.elf').read_bytes()).hexdigest() == M.HASH
    result = compare(C.CDLL(str(Path(args.library).resolve())),args.quick)
    print(json.dumps(result,sort_keys=True))
    if args.summary:
        Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
