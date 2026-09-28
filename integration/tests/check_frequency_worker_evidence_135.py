#!/usr/bin/env python3
"""Pin original instructions/literals and the unchanged reused dependencies."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
p=json.loads((ROOT/'integration/evidence/frequency_worker_135.json').read_text())
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
assert hashlib.sha256(elf.data).hexdigest()==p['reference_sha256']
assert hashlib.sha256(elf.read(0x65fcc,0x66210-0x65fcc)).hexdigest()==p['body_sha256']
assert hashlib.sha256(elf.read(0x66210,0x34)).hexdigest()==p['literal_pool_sha256']
for name,expected in p['read_only_dependencies'].items():
 b=(ROOT/name).read_bytes();assert hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()==expected,name
for address,s in p['decoded_literals'].items():
 assert bytes(b^s['key'] for b in elf.read(int(address,16),s['length'])).decode()==s['text']
assert elf.read(0x6603c,4)==bytes.fromhex('14f050e7')
print('FREQUENCY_WORKER135_EVIDENCE_PASS')
