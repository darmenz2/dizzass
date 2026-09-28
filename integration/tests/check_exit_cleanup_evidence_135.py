#!/usr/bin/env python3
"""Verify unchanged reference, bounded entry words, reused source and literals."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(data):
    return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()

def main():
    e=json.loads((ROOT/'integration/evidence/exit_cleanup_135.json').read_text())
    elf=ELF32(ROOT/e['reference'])
    assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
    for r in e['ranges']:
        a,b=int(r['start'],16),int(r['end_exclusive'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'],r['name']
    for r in e['literals']:
        raw=elf.read(int(r['address'],16),r['length'])
        assert hashlib.sha256(raw).hexdigest()==r['sha256']
        assert bytes(x^r['xor_key'] for x in raw)==r['decoded'].encode()+b'\0'
    base=e['base_source'];data=(ROOT/base['path']).read_bytes()
    assert blob(data[:base['length']])==base['git_blob']
    assert data[base['length']:].startswith(b'\n/* Original pre-exit teardown 5f0fc, distinct from common shutdown 5fc54. */')
    for path,sha in e['unchanged_files'].items():
        assert blob((ROOT/path).read_bytes())==sha,path
    assert int.from_bytes(elf.read(0x5f204,4),'little')==0xe3a00004  # state 4 before teardown
    assert int.from_bytes(elf.read(0x5fc04,4),'little')==0xe3a00002  # final f98b8 argument
    print('EXIT_CLEANUP135_EVIDENCE_PASS original bodies literals reused prefix and production boundary')
if __name__=='__main__':main()
