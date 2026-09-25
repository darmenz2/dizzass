#!/usr/bin/env python3
"""Check preserved Stage11 machine bytes, call boundaries and explicit scope.
This verifies artifact integrity, not correctness for every possible input.
"""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
e=ELF32(ROOT/'reference/cgminer.vendor.elf')
m=json.loads((ROOT/'evidence/stage11/recovery-manifest.json').read_text())
sha=lambda b:hashlib.sha256(b).hexdigest()
assert len(e.data)==m['reference_bytes'] and sha(e.data)==m['reference_sha256']
for s in m['slices']:
 a,b=int(s['start'],16),int(s['end_exclusive'],16)
 assert b-a==s['bytes'] and sha(e.read(a,b-a))==s['sha256']
 assert sha((ROOT/s['disassembly']).read_bytes())==s['disassembly_sha256']
for s in m['literals']:
 raw=e.read(int(s['address'],16),s['bytes'])
 assert raw.hex()==s['bytes_hex'] and sha(raw)==s['sha256']
for b in m['branch_edges']:
 pc=int(b['pc'],16);w=int.from_bytes(e.read(pc,4),'little')
 assert (w&0x0e000000)==0x0a000000 and f'{w:08x}'==b['instruction_hex']
 d=w&0xffffff;d=d-(1<<24) if d&(1<<23) else d
 assert pc+8+4*d==int(b['target'],16) and bool(w&0x01000000)==b['link']
assert e.read(0x2ce9c,4).hex()=='9e1fa0e3'  # calloc extent 632
assert e.read(0x2cf10,4).hex()=='bc4185e5'  # copy ID at +0x1bc
assert e.read(0x2cfdc,4).hex()=='000058e3'  # time-roll branch boundary
assert e.read(0x30414,4).hex()=='011081e2'  # raw +0x98 word increment
assert m['copy_order']==['0x18c','0x1a8','0x19c','0x1b0']
assert m['release_order']==['0x18c','0x19c','0x1b0','0x1a8']
assert m['original_image_bytes']==632 and sum(m['comparison_counts'].values())==2086
for key in ('full_work_semantics_recovered','vendor_binary_abi_compatible','time_roll_branch_recovered','live_reference_ownership_recovered','physical_hardware_tested'):
 assert m[key] is False
h=(ROOT/m['new_api']).read_text()
for marker in ('NOT the native 632-byte vendor work ABI','time-roll argument == 0','rollback is NOT claimed','not proof of refcount semantics'):
 assert marker in h
am=(ROOT/'reconstruction/cgminer-overlay.am').read_text()
assert m['new_api'] in am and m['new_helper'] in am
print('Stage11 evidence: 7 code ranges, 5 literal blocks, 20 branch edges; normalized ABI/scope PASS')
