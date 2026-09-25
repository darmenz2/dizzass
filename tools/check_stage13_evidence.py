#!/usr/bin/env python3
"""Validate exact original slices, call edges and queue geometry. Not a hardware test."""
from pathlib import Path
import hashlib,json,sys
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from nonce_fifo_oracle import FifoOracle
elf=ELF32(ROOT/'reference/cgminer.vendor.elf');m=json.loads((ROOT/'evidence/stage13/recovery-manifest.json').read_text())
sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha(elf.data)==m['reference_sha256'] and len(elf.data)==m['reference_bytes']
for s in m['slices']:
 a,b=int(s['start'],16),int(s['end_exclusive'],16)
 assert b-a==s['bytes'] and sha(elf.read(a,b-a))==s['sha256']
 assert sha((ROOT/s['disassembly']).read_bytes())==s['disassembly_sha256']
for e in m['branch_edges']:
 pc=int(e['pc'],16);w=int.from_bytes(elf.read(pc,4),'little');d=w&0xffffff
 if d&0x800000:d-=1<<24
 assert w&0x0e000000==0x0a000000 and f'{w:08x}'==e['instruction_hex']
 assert pc+8+4*d==int(e['target'],16) and bool(w&(1<<24))==e['link']
# Execute the original init's actual immediates and allocation hook.
o=FifoOracle(queue=True);r=o.call('init')
assert r['state']['capacity']==m['capacity']==4096 and r['state']['stride']==m['element_bytes']==72
assert r['events']==[('initialize',),('allocate',m['storage_bytes'])]
for pc,lit,key in ((0xfa5b4,0xfa5d8,'mutex'),(0xfa5c8,0xfa5dc,'ring'),(0xfa69c,0xfa6d4,'push_word'),(0xfa6a4,0xfa6dc,'push_word')):
 assert pc+8+int.from_bytes(elf.read(lit,4),'little')==int(m['nonce_queue_globals'][key],16)
assert sum(m['comparison_counts'].values())==11725
for k in ('source_file_names_proven','opaque_tail_semantics_recovered','original_heap_and_pthread_bodies_recovered','full_consumer_recovered','external_reference_lifetime_recovered','interpreter_opcodes_modified','physical_hardware_tested'):assert m[k] is False,k
for p in m['new_api_headers']+m['new_support_modules']:
 assert (ROOT/p).is_file() and p in (ROOT/'reconstruction/cgminer-overlay.am').read_text()
header=(ROOT/m['new_api_headers'][0]).read_text()
for text in ('NOT vendor binary ABI','FOUR CALLER-SUPPLIED OPAQUE BYTES','AFTER mutation','discard OLDEST'):assert text in header,text
print(f"Stage13 evidence PASS: {len(m['slices'])} ranges including one context-only, {len(m['branch_edges'])} checked call edges, original queue allocation and globals")
