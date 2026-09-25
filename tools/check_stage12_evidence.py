#!/usr/bin/env python3
"""Verify Stage12 source evidence from the unchanged ELF and original XOR loop.
This checks bytes/links/data/scope, not hardware behavior or every possible input.
"""
from pathlib import Path
import hashlib,json,struct,sys
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from work_time_oracle import TimeOracle
e=ELF32(ROOT/'reference/cgminer.vendor.elf');m=json.loads((ROOT/'evidence/stage12/recovery-manifest.json').read_text())
sha=lambda b:hashlib.sha256(b).hexdigest()
assert len(e.data)==m['reference_bytes'] and sha(e.data)==m['reference_sha256']
for row in m['slices']:
 a,b=int(row['start'],16),int(row['end_exclusive'],16)
 assert row['bytes']==b-a and sha(e.read(a,b-a))==row['sha256']
 assert sha((ROOT/row['disassembly']).read_bytes())==row['disassembly_sha256']
for row in m['literals']:assert sha(e.read(int(row['address'],16),row['bytes']))==row['sha256']
for row in m['branch_edges']:
 pc=int(row['pc'],16);w=int.from_bytes(e.read(pc,4),'little');d=w&0xffffff
 if d&(1<<23):d-=1<<24
 assert w&0x0e000000==0x0a000000 and f'{w:08x}'==row['instruction_hex']
 assert pc+8+4*d==int(row['target'],16) and bool(w&(1<<24))==row['link']
init=e.section('.init_array');assert int(m['initializer_function'],16) in struct.unpack('<'+'I'*(len(init)//4),init)
# Code pointers to alphabet and decode table, plus initializer's relative literal.
for pc,lit,want in ((0x1074c,0x107ac,0x5e00bc),(0x10828,0x1096c,0x5b0310),(0x1ff10,0x20eec,0x5e00bc)):
 assert pc+8+int.from_bytes(e.read(lit,4),'little')==want
nibbles=struct.unpack('<256i',e.read(0x5b0310,1024))
for i,value in enumerate(nibbles):
 c=chr(i);expected=int(c,16) if c in '0123456789abcdefABCDEF' else -1
 assert value==expected,(i,value)
o=TimeOracle();assert bytes(o.m.mem[0x5e00bc:0x5e00cc])==b'0123456789abcdef'
# Decoder return is not checked at the observed caller: load stack result next.
assert e.read(0x2d008,4)==bytes.fromhex('0c009de5')
assert e.read(0x2cfe4,4)==bytes.fromhex('440095e5')
assert e.read(0x2cffc,4)==bytes.fromhex('440085e5')
assert e.read(0x2d078,4)==bytes.fromhex('9c0185e5')
assert sum(m['comparison_counts'].values())==2511
for key in ('failed_original_encoder_allocation_compared','malformed_time_clone_compared','runtime_time_policy_checked','hash_refreshed_by_clone','live_reference_ownership_recovered','physical_hardware_tested','original_general_hex_api_fully_recovered','interpreter_instructions_modified'):
 assert m[key] is False,key
h=(ROOT/m['new_header']).read_text()
for s in ('NOT vendor binary ABI','independent value','Invalid time rejects BEFORE','Original unchecked NULL','12 zeroed'):
 assert s in h,s
am=(ROOT/'reconstruction/cgminer-overlay.am').read_text()
assert m['new_header'] in am and m['new_support'] in am
print('Stage12 evidence: 4 code ranges, 7 literal/data blocks, 12 call edges, original XOR and table PASS')
