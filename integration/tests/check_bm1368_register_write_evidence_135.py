#!/usr/bin/env python3
"""Pin original bodies, literals and all reused implementation modules."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from current_dependency_pins_135 import check_current_dependency, require

def main():
    spec=json.loads((ROOT/'integration/evidence/bm1368_register_write_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    require(hashlib.sha256(elf.data).hexdigest()==spec['reference_sha256'], 'reference SHA-256 changed')
    for r in spec['ranges']:
        a,b=int(r['start'],16),int(r['end'],16)
        require(hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'], r['start'])
    for path,want in spec['immutable'].items():
        check_current_dependency(ROOT, path, want)
    for r in spec['literals']:
        text=r['text'].encode()+b'\0'
        data=elf.read(int(r['address'],16),len(text))
        require(bytes(x^r['xor'] for x in data)==text, r['address'])
    # Both selection tests are pinned: EQ #1 for packet, NE #0 for cache.
    for at,want in [(0xe4a94,0xe3540001),(0xe4b5c,0xe3540000),
                    (0xe4b58,0xe5970018),(0xe4bd0,0xeb008cbe)]:
        require(int.from_bytes(elf.read(at,4),'little')==want, hex(at))
    print('BM1368_REGISTER135_EVIDENCE_PASS')
if __name__=='__main__':main()
