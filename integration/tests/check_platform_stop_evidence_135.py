#!/usr/bin/env python3
"""Read-only checks of source evidence; never executes the reference program."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    evidence=json.loads((ROOT/'integration/evidence/platform_stop_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256']
    for r in evidence['ranges']:
        a,b=int(r['start'],16),int(r['end'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==r['sha256'],r
    for path,want in evidence['immutable'].items():
        data=(ROOT/path).read_bytes()
        assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==want,path
    u=lambda address:int.from_bytes(elf.read(address,4),'little')
    assert [u(p) for p in (0xfe218,0xfe21c,0xfe220)]==[0xe59f0004,0xe79f0000,0xe12fff10]
    assert 0xfe21c+8+u(0xfe224)==int(evidence['dispatch_slot'],16)
    assert 0xfe028+8+u(0xfe034)==int(evidence['skip_byte'],16)
    assert all(u(p)==0xe12fff1e for p in (0x11bfbc,0x1238cc,0x10cf34))
    assert u(0x115dfc)==0xe3c01501 and u(0x115e0c)==0xe3c00040
    print('PLATFORM_STOP135_EVIDENCE_PASS',len(evidence['immutable']),'prior files unchanged')
if __name__=='__main__':main()
