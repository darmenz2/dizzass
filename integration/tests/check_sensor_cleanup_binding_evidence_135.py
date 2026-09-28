#!/usr/bin/env python3
"""Pin the existing implementations, reference words and shared test tools."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    evidence=json.loads((ROOT/'integration/evidence/sensor_cleanup_binding_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256']
    for item in evidence['ranges']:
        start=int(item['start'],16);end=int(item['end'],16)
        assert hashlib.sha256(elf.read(start,end-start)).hexdigest()==item['sha256'],item['name']
    for path,digest in evidence['unchanged_dependencies'].items():
        assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==digest,path
    print('SENSOR_CLEANUP_BINDING135_EVIDENCE_PASS')
if __name__=='__main__':main()
