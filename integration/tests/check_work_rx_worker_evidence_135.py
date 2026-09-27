#!/usr/bin/env python3
"""Check pinned ARM bytes, literal targets and retained Ghidra provenance."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    record=json.loads((ROOT/'integration/evidence/work_rx_worker_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==record['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    expected={'worker':(0xc4054,0xc4aa8),'worker_literals':(0xc4aa8,0xc4b18),'sha':(0x108b7c,0x10939c)}
    assert set(record['slices'])==set(expected)
    for name,(lo,hi) in expected.items():
        item=record['slices'][name]
        assert (int(item['start'],16),int(item['end_exclusive'],16))==(lo,hi)
        assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==item['sha256'],name
    def word(at):return int.from_bytes(elf.read(at,4),'little')
    for pc,lit,address in [(0xc4108,0xc4aa8,0x5e9749),(0xc41a8,0xc4b10,0x653410),
                           (0xc41c8,0xc4b14,0x653428),(0xc4508,0xc4ad4,0x653458),
                           (0xc4188,0xc4aac,0x5dfc30),(0xc4190,0xc4ab0,0x5de650)]:
        assert (pc+8+word(lit))&0xffffffff==address
    assert word(0x5dfc30)==0x68bd94 and word(0x5de650)==0x68bd40
    artifacts=record['ghidra']['artifacts']
    assert set(artifacts)=={'InspectWorkRx.java','c4054.ghidra.c','c4054.ghidra.asm','headless.log'}
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    assert record['ghidra']['version']=='12.1.4'
    assert 'FUN_000c4054' in artifacts['c4054.ghidra.c']['text']
    assert 'body=[[000c4054, 000c4aa7]]' in artifacts['headless.log']['text']
    assert '000c4aa4  ' in artifacts['c4054.ghidra.asm']['text']
    print(f'WORK_RX_WORKER_EVIDENCE_PASS slices={len(expected)} literal_targets=6 ghidra_artifacts={len(artifacts)}')

if __name__=='__main__':main()
