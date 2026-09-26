#!/usr/bin/env python3
"""Pin the reference and code ranges. This is not execution-equivalence proof."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
    e=json.loads((ROOT/'integration/evidence/transport_monitor_135.json').read_text())
    elf=ELF32(ROOT/e['reference'])
    assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
    for f in e['functions']:
        a,b=int(f['start'],16),int(f['end_exclusive'],16)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==f['sha256'],f['purpose']
    for s in e['strings']:
        raw=elf.read(int(s['address'],16),s['length'])
        assert hashlib.sha256(raw).hexdigest()==s['sha256']
        assert bytes(x^s['xor_key'] for x in raw)==s['decoded'].encode()+b'\0'
    print('TRANSPORT_MONITOR135_EVIDENCE_PASS reference and bounded ranges verified')
if __name__=='__main__':main()
