#!/usr/bin/env python3
"""Check original bytes, literals, descriptor and unchanged reused modules."""
import hashlib,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    spec=json.loads((ROOT/'integration/evidence/bm1368_frequency_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==spec['reference_sha256']
    for r in spec['ranges']:
        a,b=int(r['start'],16),int(r['end'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'],r['start']
    for path,expected in spec['immutable'].items():
        data=(ROOT/path).read_bytes()
        assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==expected,path
    for r in spec['literals']:
        raw=elf.read(int(r['address'],16),len(r['text'].encode())+1)
        assert bytes(v^r['xor'] for v in raw)==r['text'].encode()+b'\0'
    assert 0xe24c0+8+int.from_bytes(elf.read(0xe27c0,4),'little')==0x5eb6c0
    assert struct.unpack('<4d4id',elf.read(0x5eb6c0,56))==(25.,3200.,2400.,2000.,2,250,7,0,2.5)
    # Equal parameter records do NOT make the distinct chip packing equivalent.
    assert elf.read(0x5eb6c0,56)==elf.read(0x5ebea8,56)
    print('BM1368_FREQUENCY135_EVIDENCE_PASS')
if __name__=='__main__':main()
