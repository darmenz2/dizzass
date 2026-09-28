#!/usr/bin/env python3
"""Pin source instructions, source-path literals and immutable dependencies."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from test_thermal_request_route_135 import AuditArm,TABLE

def main():
    spec=json.loads((ROOT/'integration/evidence/chain_frequency_135.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==spec['reference_sha256']
    for r in spec['ranges']:
        b=elf.read(int(r['start'],16),int(r['end'],16)-int(r['start'],16))
        assert hashlib.sha256(b).hexdigest()==r['sha256'],r['start']
    for path,expected in spec['immutable'].items():
        b=(ROOT/path).read_bytes();actual=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
        assert actual==expected,path
    for r in spec['literals']:
        b=elf.read(int(r['address'],16),len(r['text'].encode())+1)
        assert bytes(v^r['xor'] for v in b)==r['text'].encode()+b'\0',r['address']
    # Reuse the previous bounded table-selection interpreter, no driver calls.
    selections=0
    for platform in range(5):
        for subtype in (0,1,0xffffffff):
            m=AuditArm(elf);m.reset((platform,4,subtype,TABLE));assert m.run(0xd21dc,max_steps=10000)==0
            assert m.read(TABLE+0x30)==0xe249c and m.read(TABLE+0x78)==0xe34cc
            selections+=1
    print('CHAIN_FREQUENCY135_EVIDENCE_PASS',json.dumps({'selector':4,'selection_cases':selections,'set_slot':'0xe249c','pulse_slot':'0xe34cc','physical_model_confirmed':False}))
if __name__=='__main__':main()
