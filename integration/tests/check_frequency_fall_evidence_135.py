#!/usr/bin/env python3
"""Pin original bytes/literals and immutable predecessor, not whole-file success."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(b):return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def main():
    e=json.loads((ROOT/'integration/evidence/frequency_fall_135.json').read_text());elf=ELF32(ROOT/e['reference'])
    assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
    def word(a):return int.from_bytes(elf.read(a,4),'little')
    for r in e['ranges']:
        a,b=int(r['start'],16),int(r['end_exclusive'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'],r['name']
    for x in e['literals']:
        raw=elf.read(int(x['address'],16),x['length'])
        assert hashlib.sha256(raw).hexdigest()==x['sha256']
        assert bytes(v^x['xor_key'] for v in raw)==x['decoded'].encode()+b'\0'
    for g in e['got']:
        lit,pc,got,target=(int(g[k],16) for k in ('literal','pc_relative_load','got','target'))
        assert (pc+8+word(lit))&0xffffffff==got and word(got)==target
    old=e['base_source'];b=(ROOT/old['path']).read_bytes()
    assert len(b)>=old['length'] and blob(b[:old['length']])==old['git_blob']
    for p,h in e['unchanged_files'].items():assert blob((ROOT/p).read_bytes())==h,p
    assert 0x65d2c+8+word(0x65fb8)==0x65fcc  # passed thread entry, not a neighboring guess
    assert word(0x65b8c)==0xe3a01008 and word(0x65be0)==0xe3a01004
    assert word(0x65c88)==0xe590000c and word(0x65c80)==0xe5993018
    assert word(0x65d28)==0xe3a01000 and word(0x65e58)==0xe3a01000
    # Error creation branch reaches release, not the join loop.
    w=word(0x65e3c);imm=w&0xffffff
    if imm&0x800000:imm-=1<<24
    assert w&0xff000000==0xea000000 and 0x65e3c+8+4*imm==0x65ec0
    w=word(0x6648c);imm=w&0xffffff
    if imm&0x800000:imm-=1<<24
    assert w&0xff000000==0xeb000000 and 0x6648c+8+4*imm==0x65b3c
    assert e['partial_create_failure']['joins_prior_threads'] is False
    print('FREQUENCY_FALL135_EVIDENCE_PASS original body literals argument layout and immutable prefix')
if __name__=='__main__':main()
