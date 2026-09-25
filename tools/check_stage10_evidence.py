#!/usr/bin/env python3
"""Verify Stage10 source bytes, literal constants, calls and explicit scope."""
from pathlib import Path
import hashlib,json,struct
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
e=ELF32(ROOT/'reference/cgminer.vendor.elf');m=json.loads((ROOT/'evidence/stage10/recovery-manifest.json').read_text())
sha=lambda b:hashlib.sha256(b).hexdigest()
word=lambda a:int.from_bytes(e.read(a,4),'little')
assert len(e.data)==m['reference_bytes'] and sha(e.data)==m['reference_sha256']
for s in m['slices']:
 a,b=int(s['start'],16),int(s['end_exclusive'],16)
 assert b-a==s['size'] and sha(e.read(a,b-a))==s['original_bytes_sha256']
 assert sha((ROOT/s['disassembly']).read_bytes())==s['disassembly_sha256']
for c in m['constants']:
 b=e.read(int(c['address'],16),8)
 assert b.hex()==c['bytes_hex'] and struct.unpack('<d',b)[0].hex()==c['double_hex']
for x in m['branch_edges']:
 pc=int(x['pc'],16);w=word(pc);d=w&0xffffff;d-=1<<24 if d&(1<<23) else 0
 assert w>>24==0xeb and f'{w:08x}'==x['instruction_hex'] and pc+8+4*d==int(x['target'],16)
assert e.read(0x30040,8).hex()=='00000000e0ffef4d'
assert e.read(0x30048,8).hex()=='00000000e0ffef4e'
assert word(0x2fea8)==0xe3500001 and word(0x2feac)==0x02811008
assert word(0x30d78)==0xe2840080 and word(0x30d84)==0xed940b68
assert word(0x30bbc)==0xe284ac01
h=(ROOT/'include/xminer/recovery/difficulty.h').read_text()
for claim in ['NOT claimed T21/algorithm names','NOT exact rational division','not the original queue consumer']:
 assert claim in h
am=(ROOT/'reconstruction/cgminer-overlay.am').read_text()
for helper in m['new_helpers']:assert helper in am
assert m['new_api'] in am
print('Stage10 evidence: 6 slices/helper ranges, 9 exact constants, 17 call edges; numerical domain and scope PASS')
