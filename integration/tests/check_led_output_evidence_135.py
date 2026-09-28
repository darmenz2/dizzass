#!/usr/bin/env python3
"""Verify saved source bytes and exact immutable dependencies before tests."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    manifest=json.loads((ROOT/'integration/evidence/led_output_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    digest=lambda b:hashlib.sha256(b).hexdigest()
    assert digest(elf.data)==manifest['reference_sha256']
    for span in manifest['ranges']:
        a,b=int(span['start'],16),int(span['end_exclusive'],16)
        assert digest(elf.read(a,b-a))==span['sha256'],span
    for path,expected in manifest['unchanged'].items():
        assert digest((ROOT/path).read_bytes())==expected,path
    s=manifest['source_path'];raw=elf.read(int(s['address'],16),len(s['text'])+1)
    assert bytes(x^s['xor'] for x in raw)==s['text'].encode()+b'\0'
    # Check actual PC-relative global addresses independently of the JSON labels.
    word=lambda a:int.from_bytes(elf.read(a,4),'little')
    assert 0xf98e8+8+word(0xf99f8)==0x654ab0
    assert 0xf984c+8+word(0xf98a8)==0x654ab0
    assert 0xf9930+8+word(0xf9a00)==0x654aa8
    assert 0xf9960+8+word(0xf9a04)==0x654aac
    assert 0xf9998+8+word(0xf9a08)==0x654aa8
    assert 0xf99a8+8+word(0xf9a0c)==0x654aac
    print('LED_OUTPUT135_EVIDENCE_PASS')
if __name__=='__main__':main()
