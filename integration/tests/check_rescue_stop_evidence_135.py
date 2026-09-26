#!/usr/bin/env python3
"""Pin the original function, its global association and reused code boundary."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(b):return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def main():
    e=json.loads((ROOT/'integration/evidence/rescue_stop_135.json').read_text())
    elf=ELF32(ROOT/e['reference'])
    assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
    def u32(a):return int.from_bytes(elf.read(a,4),'little')
    for r in e['ranges']:
        a,z=int(r['start'],16),int(r['end_exclusive'],16)
        assert hashlib.sha256(elf.read(a,z-a)).hexdigest()==r['sha256'],r['name']
    for g in e['got']:
        lit,pc,got,target=(int(g[k],16) for k in ('literal','pc_relative_load','got','target'))
        assert pc+8+u32(lit)==got and u32(got)==target,g
    for l in e['literals']:
        raw=elf.read(int(l['address'],16),l['length'])
        assert hashlib.sha256(raw).hexdigest()==l['sha256']
        assert bytes(v^l['xor_key'] for v in raw)==l['decoded'].encode()+b'\0'
    old=e['base_source'];b=(ROOT/old['path']).read_bytes()
    assert blob(b[:old['length']])==old['git_blob']
    assert b[old['length']:].startswith(b'\n/* Shared thread-stop adapter for original rescue-service stop 287a4. */')
    for p,s in e['unchanged_files'].items():assert blob((ROOT/p).read_bytes())==s,p
    for pc in (0x5f900,0x5f92c):
        w=u32(pc);off=w&0xffffff;off=off-(1<<24) if off&(1<<23) else off
        assert w&0xff000000==0xeb000000 and pc+8+4*off==0x287a4
    assert u32(0x287c4)==0xe5c01000 # clear flag before self
    assert u32(0x287e8)==0xe5950000 # reload handle after cancel
    assert u32(0x287ec)==0xe3a01000 # NULL join result
    print('RESCUE_STOP135_EVIDENCE_PASS original global association reused helper and production boundary')
if __name__=='__main__':main()
