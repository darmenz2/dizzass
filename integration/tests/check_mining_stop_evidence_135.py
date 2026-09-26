#!/usr/bin/env python3
"""Pin 663cc source, original instructions/literals, and unchanged old logic."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
def blob(b):return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def main():
    e=json.loads((ROOT/'integration/evidence/mining_stop_135.json').read_text());elf=ELF32(ROOT/e['reference'])
    assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
    def word(a):return int.from_bytes(elf.read(a,4),'little')
    for r in e['ranges']:
        a,b=int(r['start'],16),int(r['end_exclusive'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'],r['name']
    for x in e['literals']:
        b=elf.read(int(x['address'],16),x['length'])
        assert hashlib.sha256(b).hexdigest()==x['sha256']
        assert bytes(v^x['xor_key'] for v in b)==x['decoded'].encode()+b'\0'
    for g in e['got']:
        l,pc,got,target=(int(g[k],16) for k in ('literal','pc_relative_load','got','target'))
        assert pc+8+word(l)==got and word(got)==target
    prefix=e['base_source'];b=(ROOT/prefix['path']).read_bytes()
    assert len(b)>=prefix['length'] and blob(b[:prefix['length']])==prefix['git_blob']
    for p,sha in e['unchanged_files'].items():assert blob((ROOT/p).read_bytes())==sha,p
    assert 0x4cc68+8+word(0x4cd78)==0x4cda0
    assert 0x4cdbc+8+word(0x4ce80)==0x5e38ad
    assert 0x4d334+8+word(0x4d46c)==0x5e38ad
    assert word(0x4d348)==0xe3520014
    assert word(0x663f8)==0xe3011049 and word(0x66484)==0xe1c560b0
    assert word(0x66474)==0xe5950003 and word(0x66478)==0xe3a01000
    print('MINING_STOP135_EVIDENCE_PASS source prefix literals shared views and original words')
if __name__=='__main__':main()
