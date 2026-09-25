#!/usr/bin/env python3
"""Reproduce the new source-path length directly through original XOR loop.
No program/Linux/hardware execution; finite A32 instructions in test memory.
"""
from pathlib import Path
import hashlib,json
from elf32 import ELF32
from arm32_subset import ARM32
ROOT=Path(__file__).resolve().parents[1]
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
assert hashlib.sha256(elf.data).hexdigest()=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
rows=json.loads((ROOT/'evidence/stage5/source-string-corrections.json').read_text())
for row in rows:
    base=int(row['base'],16);length=row['length'];start=int(row['constructor_slice_start'],16);end=int(row['constructor_slice_end_exclusive'],16)
    raw=elf.read(base,length)
    assert hashlib.sha256(raw).hexdigest()==row['original_bytes_sha256']
    assert hashlib.sha256(elf.read(start,end-start)).hexdigest()==row['constructor_slice_sha256']
    assert (int.from_bytes(elf.read(0x10ed14,4),'little')+0x10eadc+8)&0xffffffff==base
    m=ARM32(elf);m.r[2]=0;m.r[12]=m.DATA_BASE;m.r[14]=m.DATA_BASE+4
    m.write(m.DATA_BASE,0);m.write(m.DATA_BASE+4,0)
    before=bytes(m.mem[base-1:base+length+1]);m.run(start,stop=end,max_steps=10000)
    decoded=bytes(m.mem[base:base+length]);assert decoded==row['text'].encode()+b'\0'
    assert decoded==bytes(x^row['xor'] for x in raw)
    assert m.mem[base-1]==before[0] and m.mem[base+length]==before[-1]
# AML target is the UART helper (not directly libc write): decode actual BL.
pc=0x1180e0;word=int.from_bytes(elf.read(pc,4),'little');assert word>>24==0xeb
imm=word&0xffffff
if imm&0x800000:imm-=1<<24
assert (pc+8+4*imm)&0xffffffff==0x10e6c0
print('Stage 5 evidence: constructor length/path and AML -> UART call: PASS')
