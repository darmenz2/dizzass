#!/usr/bin/env python3
"""Validate all stored original-code slice and source-path hashes offline."""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
manifest=json.loads((ROOT/'evidence/verified-slices.json').read_text())
assert hashlib.sha256(elf.data).hexdigest()==manifest['binary_sha256']
for item in manifest['slices']+manifest.get('data_records',[]):
    raw=elf.read(int(item['start'],16),item['size'])
    assert hashlib.sha256(raw).hexdigest()==item['original_bytes_sha256'],item['name']
paths=json.loads((ROOT/'evidence/source-tree.json').read_text())
for module in paths['modules']:
    assert (ROOT/module['path']).is_file(),module['path']
    for e in module['evidence']:
        raw=bytes(v^e['xor'] for v in elf.read(int(e['address'],16),e['decoded_length']))
        assert module['observed_as'].encode() in raw,module['path']
print(f"evidence: PASS; {len(manifest['slices'])} code slices, {len(manifest.get('data_records',[]))} data records, {len(paths['modules'])} observed paths")
