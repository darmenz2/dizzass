#!/usr/bin/env python3
"""Fail if the reference, source literals or reused dependencies change."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from current_dependency_pins_135 import check_current_dependency, require
def main():
    evidence=json.loads((ROOT/'integration/evidence/chain_reset_cleanup_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    require(hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256'],"original evidence predicate failed: hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256']")
    for item in evidence['ranges']:
        lo,hi=int(item['start'],16),int(item['end'],16)
        require(hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==item['sha256'],item['name'])
    for item in evidence['strings']:
        expected=item['text'].encode()
        require(bytes(x^item['xor'] for x in elf.read(int(item['address'],16),len(expected)))==expected,"original evidence predicate failed: bytes(x^item['xor'] for x in elf.read(int(item['address'],16),len(expected)))==expected")
    for path,expected in evidence['unchanged_files'].items():
        check_current_dependency(ROOT,path,expected)
    print('CHAIN_RESET_CLEANUP135_EVIDENCE_PASS')
if __name__=='__main__':main()
