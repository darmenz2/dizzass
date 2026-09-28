#!/usr/bin/env python3
"""Pin original ranges, global method binding and unchanged reused sources."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    s=json.loads((ROOT/'integration/evidence/transport_dispatch_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==s['reference_sha256']
    for r in s['ranges']:
        a,b=int(r['start'],16),int(r['end'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'],r['start']
    for p,want in s['immutable'].items():
        b=(ROOT/p).read_bytes()
        assert hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()==want,p
    u=lambda a:int.from_bytes(elf.read(a,4),'little')
    assert 0xd26fc+8+u(0xd2758)==0x5df454
    assert u(0x5df454)==0x68bf68
    assert 0xd2290+8+u(0xd2508)==0x5dfa68 and u(0x5dfa68)==0x117f7c
    assert u(0xd2700)==0xe5903018 and u(0xd2708)==0xe12fff33
    assert u(0xd22d8)==0xe5823018
    outer=0x1180c8+8+u(0x11817c)
    assert outer!=0x68bf68 # Framing serialization is a separate global object.
    print('TRANSPORT_DISPATCH135_EVIDENCE_PASS')
if __name__=='__main__':main()
