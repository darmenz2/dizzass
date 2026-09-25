#!/usr/bin/env python3
"""Read-only source/ELF correspondence checks, no ELF process execution."""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
m=json.loads((ROOT/'evidence/stage8/recovery-manifest.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
def h(b):return hashlib.sha256(b).hexdigest()
def w(a):return int.from_bytes(elf.read(a,4),'little')
assert h(elf.data)==m['reference_sha256'] and len(elf.data)==m['reference_bytes']
for row in m['slices']:
    a=int(row['start'],16);b=int(row['end_exclusive'],16)
    assert b-a==row['size'] and h(elf.read(a,b-a))==row['original_bytes_sha256']
    assert h((ROOT/row['disassembly']).read_bytes())==row['disassembly_sha256']
for edge in m['branch_edges']:
    pc=int(edge['pc'],16);word=w(pc);delta=word&0xffffff
    if delta&0x800000:delta-=1<<24
    assert word>>24==0xeb and f'{word:08x}'==edge['instruction_hex']
    assert pc+8+delta*4==int(edge['target'],16)
assert w(0x33030)==0xe12fff31 # Actual original BLX r1 dispatch remains indirect.
assert w(0x33028)==0xe5901208 # Hash callback field is config+0x208.
assert w(0x33024)==0xe584604c # Nonce written at work+76 before callback.
assert w(0x33044)==0xe594013c # High digest word, work+316.
assert w(0x2dac0)==0xe2842e12 # Digest pointer work+288.
assert w(0x74e4c)==0xe1045081 # Three records use original stride0x478.
source=json.loads((ROOT/'evidence/source-tree.json').read_text())
assert source['partial_modules']==7 and source['pending_modules']==39
front=next(x for x in source['modules'] if x['path']=='src/frontend/cgminer.c')
assert front['status']=='partial-verified-slices'
refs=json.loads((ROOT/'evidence/stage1/cgminer_string_xrefs.json').read_text())
assert any(str(x.get('insn','')).lower()=='0x32fdc' and '/tmp/build/src/frontend/cgminer.c' in x['text']
           for x in refs['0x32f60'])
# Re-evaluate the actual PC-relative address, not just historic association text.
assert (0x32fdc+8+w(0x33584))&0xffffffff==0x5e2194
am=(ROOT/'reconstruction/cgminer-overlay.am').read_text()
assert 'src/frontend/cgminer.c' in am
for helper in m['new_helpers']:assert helper in am
print('Stage8 evidence: 10 bounded/context ranges, 8 call edges, source-path reference, field offsets and explicit indirect hash boundary PASS')
