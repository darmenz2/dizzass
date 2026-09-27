#!/usr/bin/env python3
"""Pin original bytes and retained Ghidra provenance; no firmware execution."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    record=json.loads((ROOT/'integration/evidence/work_tx_worker_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==record['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    expected={'worker':(0xc4b18,0xc503c),'worker_literals':(0xc503c,0xc5094),
              'time_helper':(0x10f544,0x10f64c),'chain_predicate':(0x56fcc,0x57030),
              'crc':(0xf7df4,0xf7eec),'division_boundary':(0x5913ac,0x5914bc)}
    assert set(record['slices'])==set(expected)
    for name,(lo,hi) in expected.items():
        item=record['slices'][name]
        assert (int(item['start'],16),int(item['end_exclusive'],16))==(lo,hi)
        assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==item['sha256'],name
    def word(at):return int.from_bytes(elf.read(at,4),'little')
    for pc,lit,address in [(0xc4b64,0xc503c,0x5e977d),(0xc4bac,0xc5040,0x633ba8),
                           (0xc4bb0,0xc5044,0x633bc0),(0xc4bb4,0xc5048,0x633bf0),
                           (0xc4da0,0xc5064,0x653458),(0xc4da8,0xc5068,0x653458),
                           (0xc4dc0,0xc506c,0x653458),(0xc4bd4,0xc5080,0x633ba8),
                           (0xc4bd8,0xc5084,0x633bc0)]:
        assert (pc+8+word(lit))&0xffffffff==address
    assert word(0x10f584)==0xe0836c96
    for name,item in record['ghidra']['artifacts'].items():
        assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    assert record['ghidra']['version']=='12.1.4'
    assert 'setNoReturn(true)' in record['ghidra']['artifacts']['InspectWorkTx.java']['text']
    assert 'FUN_005a52d0(0)' in record['ghidra']['artifacts']['c4b18.ghidra.c']['text']
    print(f'WORK_TX_WORKER_EVIDENCE_PASS slices={len(expected)} literal_targets=9 ghidra_artifacts={len(record["ghidra"]["artifacts"])}')

if __name__=='__main__':main()
