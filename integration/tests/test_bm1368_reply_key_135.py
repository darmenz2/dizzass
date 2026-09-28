#!/usr/bin/env python3
"""Execute unchanged ARM instructions for getter/selection/lifecycle edges.
The original registry and callback bodies are NOT implemented by this test.
Existing parent fixtures are reused, replacing only their getter boundary.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import sys
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
import test_exit_cleanup_135 as E

GETTER = 0xe3bbc
REGISTRY = 0x108b40
HANDLER = 0x78aa4
BASE = E.BASE
EXTRA = ((GETTER, GETTER+8), (0xd21dc, 0xd24ec), (0xe1450, 0xe16b8),
         (0x73dd4, 0x73dec), (0x6ef84, 0x6efa4), (0x6efc4, 0x6efe4),
         (0x108938, 0x108974))

class Machine(ARM32Difficulty):
    def __init__(self, elf):
        super().__init__(elf)
        self.visited = set()
        self.on_leaf = None
        self.leaves = 0
    def extra_instruction(self, word, pc):
        assert any(a <= pc < b for a, b in E.RANGES + EXTRA), hex(pc)
        self.visited.add(pc)
        if pc == GETTER:
            self.leaves += 1
            if self.on_leaf:
                # Old hook is used ONLY to observe the boundary/state. It may
                # neither mutate fields nor determine the original result.
                regs = self.r[:]
                self.on_leaf(self)
                self.r[:] = regs
        return super().extra_instruction(word, pc)

class ParentMachine(Machine):
    def run(self, start, stop=None, hooks=None, max_steps=250000):
        assert start in (0x5f0fc, 0x5fc54, 0x5e92c)
        hooks = dict(hooks or {})
        self.on_leaf = hooks.pop(E.INDIRECT)
        self.write(BASE+0x19c, GETTER)
        assert GETTER not in hooks
        return super().run(start, stop=stop, hooks=hooks, max_steps=max_steps)

class ParentOriginal(E.Original):
    def __init__(self, elf):
        super().__init__(elf)
        self.m = ParentMachine(elf)

class ParentNative(E.Native):
    def __init__(self, lib):
        super().__init__(lib)
        self.key = lib.vn135_bm1368_reply_key_135
        self.key.argtypes = []
        self.key.restype = C.c_uint32
    def run(self, entry, p):
        key = self.key
        class Script(E.Script):
            def call(self, name, *args):
                status = super().call(name, *args)
                return key() if name == 'indirect' else status
        with patch.object(E, 'Script', Script):
            return super().run(entry, p)

def selected_table(elf, controller=2, subtype=0):
    m = Machine(elf)
    at = BASE+0x110
    m.mem[at-16:at+0x100] = b'\xa5'*0x110
    m.reset((controller, 4, subtype, at))
    assert m.run(0xd21dc, max_steps=10000) == 0
    assert m.read(at+0x8c) == GETTER
    assert m.mem[at-16:at] == b'\xa5'*16
    assert m.mem[at+0xe0:at+0x100] == b'\xa5'*32
    return m

def provenance(elf):
    result = collections.Counter()
    for controller, subtype in itertools.product(range(5), (0, 1, 0xffffffff)):
        selected_table(elf, controller, subtype)
        result['table_selection'] += 1
    # Execute the actual reached cold-call window and the actual table builder.
    # This deliberately starts at a known reached block, not the full startup.
    for subtype in (0, 1, 2, 255):
        m = Machine(elf); m.reset()
        m.r[8], m.r[6] = BASE+0x800, BASE+0x900
        m.write(m.r[13]+0x24, BASE)
        m.write(m.r[8]+0x2c, subtype, 1); m.write(m.r[6], 4)
        m.mem[BASE+0x100:BASE+0x220] = b'\xa5'*0x120
        assert m.run(0x73dd4, stop=0x73dec, max_steps=10000) == 0
        assert m.read(BASE+0x19c) == GETTER
        assert m.mem[BASE+0x100:BASE+0x110] == b'\xa5'*16
        assert m.mem[BASE+0x1f0:BASE+0x220] == b'\xa5'*48
        result['cold_call_window'] += 1
    for start in (0x6ef84, 0x6efc4):
        for seed in (0, 1, 0xffffffff):
            m = selected_table(elf); m.reset((seed, seed, seed, seed)); m.r[9] = BASE
            sp = m.r[13]
            m.run(start, stop=REGISTRY, max_steps=32)
            assert tuple(m.r[:4]) == (sp+12, 0x44, BASE, HANDLER), tuple(map(hex,m.r[:4]))
            assert m.leaves == 1 and {GETTER,GETTER+4}.issubset(m.visited)
            result['registration_window'] += 1
    # Verify the existing reader's index/context/callback association. Stop at
    # the selected callback or fallback entrance; neither body is executed.
    registry = (0x10894c + 8 + int.from_bytes(elf.read(0x1089c8,4),'little')) & 0xffffffff
    assert registry == 0x654dc8
    for identity, installed in itertools.product((0, 0x43, 0x44, 0x45, 255), (0, 1)):
        m=Machine(elf); m.mem[registry:registry+2048]=bytes(2048)
        event=BASE+0x400; m.mem[event:event+32]=b'\xa5'*32; m.write(event+5,identity,1)
        if installed:
            m.write(registry+0x44*8,BASE); m.write(registry+0x44*8+4,HANDLER)
        before=bytes(m.mem[registry:registry+2048]); event_before=bytes(m.mem[event:event+32])
        m.reset((event,))
        target = HANDLER if identity==0x44 and installed else 0x108974
        m.run(0x108938,stop=target,max_steps=32)
        if target==HANDLER: assert m.r[0]==BASE and m.r[1]==event
        assert bytes(m.mem[registry:registry+2048])==before
        assert bytes(m.mem[event:event+32])==event_before
        result['reader_window']+=1
    return dict(result)

def parent_cases():
    for entry, state, ready, mode in itertools.product(('before','common'),
            (0,1,2,3,4,5,6,7,0x80000000,0xffffffff),(0,1),(0,2)):
        yield entry, 'gates', dict(state=state, mode=mode, chip=4, returns={'ready':ready})
    for entry in ('before','common'):
        for flags in ([0]*10,[1]*10,[255]*10,[1,0]*5):
            yield entry,'thread_paths',dict(chip=4, flags=flags, returns={'self':102})
        for n in (-1,0,1,3):
            for rc in (-7,0,1):
                yield entry,'cleanup_result',dict(chip=4, returns={'count':n,'cleanup':rc})
        for op,field,value in [('step_58d08','state',6),('cancel','boardflag',0),
                ('step_663cc','mode',2),('ready','state',2),('cleanup','fans',1)]:
            yield entry,'other_edge_mutations',dict(chip=4,mutations=[(op,0,field,value)])
    for limit, attempts, ready in itertools.product((-1,0,1,2),(0,3),(0,1)):
        yield 'policy','policy_paths',dict(chip=4, limit=limit, attempts=attempts,returns={'ready':ready})

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true')
    args=ap.parse_args();elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==E.S.HASH
    lib=C.CDLL(str(Path(args.library).resolve()))
    key=lib.vn135_bm1368_reply_key_135;key.argtypes=[];key.restype=C.c_uint32
    direct=0
    for seed in (0,1,0x43,0x44,0x45,255,0x80000000,0xffffffff):
        m=Machine(elf);m.reset((seed,seed^0xffffffff,seed,seed))
        before=bytes(m.mem);regs=m.r[:]
        expected=m.run(GETTER,max_steps=4);actual=key()
        if actual != expected:
            raise AssertionError(('MISMATCH','getter',expected,actual))
        assert expected==0x44 and m.steps==2
        assert bytes(m.mem)==before and m.r[1:15]==regs[1:15]
        direct+=1
    proofs=provenance(elf)
    native=ParentNative(lib);original=ParentOriginal(elf)
    groups=collections.Counter();events=leaves=0
    for entry,group,p in parent_cases():
        assert not any(item[0]=='indirect' for item in p.get('mutations',[]))
        n=original.m.leaves;a=original.run(entry,p);c=native.run(entry,p)
        if a!=c:
            for left,right in itertools.zip_longest(a[2],c[2]):
                if left!=right:print('first difference',left,right);break
            raise AssertionError(('MISMATCH','parent',entry,group,p))
        observed=[e for e in a[2] if e[0]=='cleanup']
        assert all(e[1]==0x44 for e in observed)
        assert original.m.leaves-n==len(observed)
        groups[group]+=1;events+=len(a[2]);leaves+=len(observed)
        if args.quick and sum(groups.values())>=12:break
    summary={'direct_getter_cases':direct,'provenance':proofs,'parent_cases':sum(groups.values()),
             'parent_groups':dict(groups),'parent_events':events,'reached_original_getters':leaves,
             'parent_arm_steps':original.steps,'parent_visited_addresses':len(original.visited),
             'source_reference_sha256':E.S.HASH,'original_registry_executed':False,
             'original_consumer_executed':False,'live_hardware':False,'new_arm_opcodes':0}
    if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('BM1368_REPLY_KEY135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
