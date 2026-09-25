#!/usr/bin/env python3
"""Check pinned original ranges/literals and explicit limits, offline."""
from pathlib import Path
import hashlib,json,struct
from elf32 import ELF32
R=Path(__file__).resolve().parents[1];e=ELF32(R/'reference/cgminer.vendor.elf')
m=json.loads((R/'evidence/stage14/recovery-manifest.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha(e.data)==m['reference_sha256'] and len(e.data)==m['reference_bytes']
for s in m['slices']:
 a,b=int(s['start'],16),int(s['end_exclusive'],16)
 assert b-a==s['bytes'] and sha(e.read(a,b-a))==s['sha256']
 assert sha((R/s['disassembly']).read_bytes())==s['disassembly_sha256']
for s in m['data']:
 b=e.read(int(s['address'],16),s['size']);assert b.hex()==s['hex'] and struct.unpack('<d',b)[0]==s['value_f64']
for edge in m['branch_edges']:
 pc=int(edge['pc'],16);w=int.from_bytes(e.read(pc,4),'little');d=w&0xffffff
 if d&0x800000:d-=1<<24
 assert w&0x0f000000==0x0b000000 and f'{w:08x}'==edge['instruction_hex'] and pc+8+4*d==int(edge['target'],16)
assert 0x32060+8+int.from_bytes(e.read(0x324c8,4),'little')==int(m['global_work_block_address'],16)
assert sum(m['comparisons'].values())==m['new_main_comparisons']==8366
for k in ('original_locks_implemented','full_reference_lifetime_recovered','full_consumer_recovered','exact_vendor_ancestor_proven','remote_fork_created','physical_hardware_tested'):assert m[k] is False
for p in m['new_support_modules']+m['new_api_headers']:assert p in (R/'reconstruction/cgminer-overlay.am').read_text() and (R/p).is_file()
print('Stage14 exact reference bytes, literals, call edges and explicit limits: PASS')
