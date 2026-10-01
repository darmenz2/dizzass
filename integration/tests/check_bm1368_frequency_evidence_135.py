#!/usr/bin/env python3
"""Check original bytes, literals, descriptor and unchanged reused modules."""
import hashlib,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from current_dependency_pins_135 import check_current_dependency, require

def main():
    spec=json.loads((ROOT/'integration/evidence/bm1368_frequency_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    require(hashlib.sha256(elf.data).hexdigest()==spec['reference_sha256'], 'reference SHA-256 changed')
    for r in spec['ranges']:
        a,b=int(r['start'],16),int(r['end'],16)
        require(hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'], r['start'])
    for path,expected in spec['immutable'].items():
        check_current_dependency(ROOT, path, expected)
    for r in spec['literals']:
        raw=elf.read(int(r['address'],16),len(r['text'].encode())+1)
        require(bytes(v^r['xor'] for v in raw)==r['text'].encode()+b'\0', r['address'])
    require(0xe24c0+8+int.from_bytes(elf.read(0xe27c0,4),'little')==0x5eb6c0, 'descriptor pointer changed')
    require(struct.unpack('<4d4id',elf.read(0x5eb6c0,56))==(25.,3200.,2400.,2000.,2,250,7,0,2.5), 'descriptor parameters changed')
    # Equal parameter records do NOT make the distinct chip packing equivalent.
    require(elf.read(0x5eb6c0,56)==elf.read(0x5ebea8,56), 'equal parameter record changed')
    print('BM1368_FREQUENCY135_EVIDENCE_PASS')
if __name__=='__main__':main()
