#!/usr/bin/env python3
"""Pinned original bytes, shared-table provenance and unchanged dependencies."""
import hashlib
import json
from pathlib import Path
import struct
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(data):
    return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()

def main():
    evidence=json.loads((ROOT/'integration/evidence/throttling_reset_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==evidence['reference_sha256']
    for item in evidence['ranges']:
        data=elf.read(int(item['start'],16),int(item['end'],16)-int(item['start'],16))
        assert hashlib.sha256(data).hexdigest()==item['sha256'],item['name']
    for item in evidence['pc_relative_links']:
        literal,pc,target=(int(item[k],16) for k in ('literal','pc','target'))
        actual=(pc+8+struct.unpack('<I',elf.read(literal,4))[0])&0xffffffff
        assert actual==target,item
        if 'value' in item:
            assert struct.unpack('<I',elf.read(target,4))[0]==int(item['value'],16)
    source=bytes(x^0x69 for x in elf.read(0x5e9376,36))
    assert source==b'/tmp/build/src/backend/throttling.c\0'
    for path,sha in evidence['unchanged_files'].items():
        assert blob((ROOT/path).read_bytes())==sha,path
    print('THROTTLING_RESET135_EVIDENCE_PASS')

if __name__=='__main__':main()
