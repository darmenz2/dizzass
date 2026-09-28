#!/usr/bin/env python3
"""Pin producer instructions/prologue/literals and retained Ghidra evidence."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
def main():
    record=json.loads((ROOT/'integration/evidence/work_producer_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==record['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    slices={'worker':(0xc2498,0xc2ec8),'worker_literals':(0xc2ec8,0xc2f6c),'sha':(0x108b7c,0x109740),
            'reverse':(0x10f64c,0x10f6b8),'count_context':(0x5ccf4,0x5cd70),
            'copy_context':(0x5cd70,0x5ce44),'compare_context':(0x5ce44,0x5cea8),'cleanup_context':(0xc2f6c,0xc3148)}
    assert set(record['slices'])==set(slices)
    for name,(lo,hi) in slices.items():
        item=record['slices'][name];assert (int(item['start'],16),int(item['end_exclusive'],16))==(lo,hi)
        assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==item['sha256'],name
    def word(at):return int.from_bytes(elf.read(at,4),'little')
    assert word(0xc2498)==0xe92d4ff0 and word(0xc249c)==0xe28db01c and word(0xc24a0)==0xe24ddf5f
    assert word(0xc2b80)==0xe0821190 # Single added interpreter opcode, UMULL.
    assert (0xc2ad8+8+word(0xc2f44))&0xffffffff==0x633bf0
    assert (0xc290c+8+word(0xc2f14))&0xffffffff==0x633bf0
    assert record['slice_entry']=='0xc2970' and record['slice_endpoint']=='0xc2e80'
    artifacts=record['ghidra']['artifacts'];assert len(artifacts)==16
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    assert record['ghidra']['version']=='12.1.4'
    assert '[[000c2498, 000c2ec7]]' in artifacts['headless-final.log']['text']
    assert 'FUN_0010f64c' in artifacts['10f64c.ghidra.c']['text']
    print(f'WORK_PRODUCER_EVIDENCE_PASS slices={len(slices)} literal_targets=2 ghidra_artifacts={len(artifacts)}')
if __name__=='__main__':main()
