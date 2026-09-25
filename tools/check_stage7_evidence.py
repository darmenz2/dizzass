#!/usr/bin/env python3
"""Read-only byte/branch validation for nonce preparation. No device access."""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
m=json.loads((ROOT/'evidence/stage7/recovery-manifest.json').read_text())
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
def digest(data):return hashlib.sha256(data).hexdigest()
def word(addr):return int.from_bytes(elf.read(addr,4),'little')
assert digest(elf.data)==m['reference_sha256'] and len(elf.data)==m['reference_bytes']
for s in m['slices']:
    a=int(s['start'],16);b=int(s['end_exclusive'],16)
    assert b-a==s['size'] and digest(elf.read(a,b-a))==s['original_bytes_sha256']
    assert digest((ROOT/s['disassembly']).read_bytes())==s['disassembly_sha256']
for edge in m['branch_edges']:
    pc=int(edge['pc'],16);w=word(pc)
    assert w>>24==0xeb and f'{w:08x}'==edge['instruction_hex']
    d=w&0xffffff
    if d&0x800000:d-=1<<24
    assert (pc+8+4*d)&0xffffffff==int(edge['target'],16)
for row in m['literals']:
    b=elf.read(int(row['address'],16),4)
    assert b.hex()==row['bytes_hex'] and int.from_bytes(b,'little')==row['value_le']
# Producer and writer use the same adjusted table base, then +8 to first row.
assert (0xc4508+8+word(0xc4ad4))&0xffffffff==0x653458
assert (0xc4da8+8+word(0xc5068))&0xffffffff==0x653458
assert word(0xc450c)==0xe10a0281  # smlabb r10,r1,r2,r0
assert word(0xc4d94)==0xe3a000a8 and word(0xc4d9c)==0xe3a020a8
assert word(0xc4dc8)==0xe350001f  # cmp r0,#31
# Queue size is NOT equal to the explicit output prefix length of 68.
assert word(0xfa5c0)==0xe3a01a01 and word(0xfa5c4)==0xe3a02048
assert (0xfa5c8+8+word(0xfa5dc))&0xffffffff==0x654ae8
hdr=(ROOT/'include/xminer/recovery/work_nonce.h').read_text()
assert '#define VN135_NONCE_CANDIDATE_DEFINED_SIZE 68u' in hdr
assert '#define VN135_ORIGINAL_NONCE_QUEUE_ELEMENT_SIZE 72u' in hdr
assert 'MUST NOT be copied as a 72-byte vendor queue element' in hdr
# Ensure no new helper is falsely described as an original source path.
status=json.loads((ROOT/'evidence/source-tree.json').read_text())
am=(ROOT/'reconstruction/cgminer-overlay.am').read_text()
for path in m['new_helpers']:assert path in am
print('Stage7 evidence: 10 bounded slices (4 context-only), 10 call edges, table stride/base and 72-vs-68 boundary PASS')
