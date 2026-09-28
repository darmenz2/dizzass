#!/usr/bin/env python3
"""Unchanged a6080 words versus existing helper through the new voltage adapter.
Reuse only generic thread fixtures, not the rescue ARM entry/global mapping.
No OS threads, voltage writes, I/O or execution of vendor ELF as a process.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import test_rescue_stop_135 as R
from arm32_subset import ARM32, MASK
from arm32_difficulty_subset import ARM32Difficulty

ROOT, HASH, S = R.ROOT, R.HASH, R.S
START, END = 0xa6080, 0xa6188
BASE = S.BASE
HANDLE, FLAG = BASE + 0x1024, BASE + 0x1028
OPAQUE_X, OPAQUE_Y = 0x68b090, 0x68b0ac

class Machine(ARM32):
    def extra_instruction(self, w, pc):
        assert START <= pc < END, ('unapproved instruction', hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(w, pc)

class Native(R.Native):
    def __init__(self, library):
        self.f = library.vn135_voltage_controller_stop_135
        self.f.argtypes = [C.POINTER(R.Worker), C.POINTER(S.Ops), S.P]
        self.f.restype = None

class Original:
    def __init__(self, elf):
        self.m = Machine(elf)
        self.steps = 0
        self.visited = set()
    def run(self, p):
        m = self.m
        m.visited = set()
        # Guard every other byte of the backend, not only adjacent words.
        m.mem[BASE:BASE+0x1100] = b'\xa5' * 0x1100
        m.write(FLAG, p.get('flag', 1), 1)
        m.write(HANDLE, p.get('handle', 100))
        m.write(OPAQUE_X, p.get('opaque', 0))
        m.write(OPAQUE_Y, p.get('opaque_y', 10))
        before = bytes(m.mem[BASE:BASE+0x1100])
        def snap(): return m.read(FLAG, 1), m.read(HANDLE)
        def mutate(k, v):
            if k == 'flag': m.write(FLAG, v, 1)
            elif k == 'handle': m.write(HANDLE, v)
            else: raise AssertionError(k)
        sc = R.Script(p, snap, mutate)
        def hook(name, argc):
            def h(_):
                args = tuple(m.r[:argc])
                if name == 'join':
                    assert m.r[1] == 0
                    args = (args[0], False)
                m.r[0] = sc.call(name, *args) & MASK
                m.write(OPAQUE_X, (p.get('opaque', 0) + sc.calls[name]*0x80000001) & MASK)
                m.write(OPAQUE_Y, (p.get('opaque_y', 10) ^ MASK) & MASK)
            return h
        hooks = {0x5a6b20: hook('self', 0), 0x5a5bb0: hook('detach', 1),
                 0x5a4754: hook('cancel', 1), 0x5a5d2c: hook('join', 2)}
        for i in range(p.get('repeat', 1)):
            m.reset((BASE,))
            m.run(START, hooks=hooks, max_steps=240)
            assert m.r[13] == m.STACK_TOP
            self.steps += m.steps
            sc.events.append(('returned', i, snap()))
        self.visited |= m.visited
        after = bytearray(m.mem[BASE:BASE+0x1100])
        for a in range(HANDLE, HANDLE+4): after[a-BASE] = before[a-BASE]
        after[FLAG-BASE] = before[FLAG-BASE]
        assert after == before, 'unexpected backend write'
        return snap(), sc.events

def cases(quick=False):
    # The reusable cases contain all 256 flags, signed-error bit patterns,
    # self/cancel mutations and repeated invocations, identical on both sides.
    yield from R.cases(quick)
    if quick: return
    for x,y in itertools.product((0,1,2,0x7fffffff,0x80000000,0xffffffff),
                                 (0,9,10,0x7fffffff,0x80000000,0xffffffff)):
        yield 'opaque_cross_product', {'opaque':x,'opaque_y':y,'repeat':2}
    for op in ('self','detach','cancel','join'):
        yield 'source_handle_not_cleared', {'handle':0xffffffff, 'self':0xffffffff if op=='detach' else 7,
            'mutations':[(op,0,'handle',0x80000000)], 'repeat':2}

def provenance(elf):
    # Bounded observations of creator and worker prologue. Their full runtime
    # behavior is NOT reconstructed or claimed by these association fixtures.
    class ProvenanceMachine(ARM32Difficulty):
        def extra_instruction(self,w,pc):
            assert 0xa20a0 <= pc < 0xa2204 or 0xa2218 <= pc < 0xa2288, hex(pc)
            return super().extra_instruction(w,pc)
    m = ProvenanceMachine(elf)
    creations = []
    for flag,rc in ((0,0),(0,5),(1,0),(255,-3)):
        m.mem[BASE:BASE+0x1100] = bytes(0x1100)
        m.write(FLAG,flag,1); m.write(HANDLE,123)
        m.write(OPAQUE_X,0xffffffff); m.write(OPAQUE_Y,10)
        calls=[]
        def create(_):
            calls.append(tuple(m.r[:4])+(m.read(FLAG,1),))
            m.r[0] = rc & MASK
        def mutex(_): m.r[0]=0
        m.reset((BASE,))
        m.run(0xa20a0,hooks={0x5a6108:mutex,0x5a66c4:mutex,0x5a55cc:create},max_steps=200)
        assert calls == ([] if flag else [(HANDLE,0,0xa2218,BASE,1)]), calls
        creations.append(len(calls))
    m.write(BASE+0x18,S.MODEL)
    names=[]
    def zero(_): m.r[0]=0
    def prctl(_):
        assert m.r[0] == 15 and m.r[2:4] == [0,0] and m.read(m.r[13]) == 0
        assert m.r[1] == 0x5e7cf7
        names.append(bytes(x^23 for x in elf.read(m.r[1],14)))
        m.r[0]=0
    m.reset((BASE,))
    m.run(0xa2218,stop=0xa2288,hooks={0x61e80:zero,0x5a6b2c:zero,0x593af8:prctl},max_steps=80)
    assert names == [b'volt_ctrl@btm\0']
    return {'creator_cases':len(creations),'worker_name_cases':len(names)}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('library'); ap.add_argument('--summary'); ap.add_argument('--quick',action='store_true')
    a=ap.parse_args()
    elf=R.ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==HASH
    native=Native(C.CDLL(str(Path(a.library).resolve()))); original=Original(elf)
    counts=collections.Counter();events=0
    for name,p in cases(a.quick):
        want=original.run(p);got=native.run(p)
        if want!=got: raise AssertionError(('ORIGINAL_MISMATCH',name,p,want,got))
        counts[name]+=1;events+=sum(e[0]!='returned' for e in want[1])
    assoc=provenance(elf)
    summary={'cases':sum(counts.values()),'categories':dict(counts),'events':events,
             'arm_steps':original.steps,'visited_instruction_addresses':len(original.visited),
             'provenance':assoc,'reference_sha256':HASH,'existing_helper_reused':True,
             'new_arm_opcodes':0,'real_threads':False,'voltage_operations':False}
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('VOLTAGE_STOP135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
