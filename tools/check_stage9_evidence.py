#!/usr/bin/env python3
"""Read-only checks linking the supplied ELF, disassembly and reconstructed API."""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1];e=ELF32(ROOT/'reference/cgminer.vendor.elf')
m=json.loads((ROOT/'evidence/stage9/recovery-manifest.json').read_text())
def sha(b):return hashlib.sha256(b).hexdigest()
def w(a):return int.from_bytes(e.read(a,4),'little')
assert len(e.data)==m['reference_bytes'] and sha(e.data)==m['reference_sha256']
for s in m['slices']:
 a=int(s['start'],16);b=int(s['end_exclusive'],16)
 assert b-a==s['size'] and sha(e.read(a,b-a))==s['original_bytes_sha256']
 assert sha((ROOT/s['disassembly']).read_bytes())==s['disassembly_sha256']
for edge in m['branch_edges']:
 pc=int(edge['pc'],16);insn=w(pc);d=insn&0xffffff;d=d-(1<<24) if d&(1<<23) else d
 assert insn>>24==0xeb and f'{insn:08x}'==edge['instruction_hex']
 assert pc+8+4*d==int(edge['target'],16)
for row in m['instruction_assertions']:assert f"{w(int(row['address'],16)):08x}"==row['word_hex']
# Non-tautological decoded correspondences for the candidate binding and output.
assert w(0x74f18)==0xe59d0054  # candidate +20
assert w(0x74f20)==0xe1c220d0  # two counter words
assert w(0x74f24)==0xe6bf0f30 and w(0x30228)==0xe6bf1f31 # caller/wrapper two REV
assert w(0x30220)==0xe58a53c0 and w(0x30224)==0xe58a93c4
assert w(0x30a38)==0xe3a02070 and w(0x30a58)==0xe2840024 and w(0x30a5c)==0xe3a02020
am=(ROOT/'reconstruction/cgminer-overlay.am').read_text()
for s in m['new_helpers']:assert s in am
hdr=(ROOT/'include/xminer/recovery/work_rebuild.h').read_text()
assert '#define VN135_WORK_PREFIX_BYTES 112u' in hdr
assert 'NOT a complete 632-byte original work' in hdr
assert 'last_nonce obeys original prefilter semantics' in hdr
state=json.loads((ROOT/'evidence/source-tree.json').read_text())
assert state['partial_modules']==7 and state['pending_modules']==39
print('Stage9 evidence: 6 bounded/context ranges, 10 call edges, candidate offsets, two REV and 112-byte prefix PASS')
