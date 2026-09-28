#!/usr/bin/env python3
"""Fail if the reference, source literals or reused dependencies change."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
def main():
    evidence=json.loads((ROOT/'integration/evidence/chain_cleanup_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256']
    for item in evidence['ranges']:
        lo,hi=int(item['start'],16),int(item['end'],16)
        assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==item['sha256'],item['name']
    for item in evidence['strings']:
        expected=item['text'].encode()
        assert bytes(x^item['xor'] for x in elf.read(int(item['address'],16),len(expected)))==expected
    for path,expected in evidence['unchanged_files'].items():
        data=(ROOT/path).read_bytes()
        assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==expected,path
    print('CHAIN_CLEANUP135_EVIDENCE_PASS')
if __name__=='__main__':main()
