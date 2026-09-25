#!/usr/bin/env python3
"""Read-only validation of Stage6 original bytes and direct branch relationships."""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
m=json.loads((ROOT/'evidence/stage6/recovery-manifest.json').read_text())
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
assert hashlib.sha256(elf.data).hexdigest()==m['reference_sha256']
for s in m['slices']:
    assert hashlib.sha256(elf.read(int(s['start'],16),s['size'])).hexdigest()==s['original_bytes_sha256']
    assert (ROOT/s['disassembly']).is_file()
for edge in m['branch_edges']:
    pc=int(edge['pc'],16);w=int.from_bytes(elf.read(pc,4),'little')
    assert w>>24==0xeb
    d=w&0xffffff
    if d&0x800000:d-=1<<24
    assert (pc+8+4*d)&0xffffffff==int(edge['target'],16)
# Ensure the new partial file is actually compiled and the adapter is labeled new.
assert 'src/backend/work-gen/work-gen.c' in (ROOT/'reconstruction/cgminer-overlay.am').read_text()
assert 'NOT recovered original source' in (ROOT/'reconstruction/support/work_rx_stream.c').read_text()
print('Stage6 original slices and RX->ring/filter/enqueue call edges: PASS')
