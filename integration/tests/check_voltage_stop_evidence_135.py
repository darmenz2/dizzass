#!/usr/bin/env python3
"""Pin original voltage-stop words, full source association and reused helper."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(b):
    return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def main():
    e=json.loads((ROOT/'integration/evidence/voltage_stop_135.json').read_text())
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
    for p,s in e['unchanged_files'].items():
        assert blob((ROOT/p).read_bytes())==s,p
    # Creator's real arguments and name pointer; no neighboring-name guess.
    assert 0xa2154+8+u32(0xa2210)==0xa2218
    assert 0xa2278+8+u32(0xa3244)==0x5e7cf7
    assert 0xa6bb0+8+u32(0xa7180)==0x5e7cd4
    assert u32(0xa6bb8)==0xe3520023  # Full 35-byte filename decoder limit.
    assert u32(0xa6c48)==0xe350000e  # Full 14-byte thread-name decoder limit.
    assert u32(0xa6088)==0xe3011028
    assert u32(0xa6098)==0xe3011024
    assert u32(0xa60a4)==0xe5c69004  # Clear flag before self.
    assert u32(0xa6140)==0xe5960000  # Reload handle after cancel.
    assert u32(0xa6144)==0xe3a01000  # NULL join result.
    for pc in (0x5f47c,0x5fe94):
        w=u32(pc);off=w&0xffffff
        if off&0x800000:off-=0x1000000
        assert w&0xff000000==0xeb000000 and pc+8+4*off==0xa6080
    print('VOLTAGE_STOP135_EVIDENCE_PASS original creator worker fields and unchanged helper')
if __name__=='__main__':main()
