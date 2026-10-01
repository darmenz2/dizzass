#!/usr/bin/env python3
"""Pin original instruction/data ranges and unchanged reused modules."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from current_dependency_pins_135 import check_current_dependency, require

def main():
 e=json.loads((ROOT/'integration/evidence/bm1368_pulse_width_135.json').read_text())
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
 require(hashlib.sha256(elf.data).hexdigest()==e['reference_sha256'],"original evidence predicate failed: hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']")
 for r in e['ranges']:
  start,end=int(r['start'],16),int(r['end'],16)
  require(hashlib.sha256(elf.read(start,end-start)).hexdigest()==r['sha256'],r['start'])
 for p,want in e['immutable'].items():
  check_current_dependency(ROOT,p,want)
 for r in e['strings']:
  got=bytes(v^r['xor_key'] for v in elf.read(int(r['address'],16),r['length']))
  require(got==r['text'].encode()+b'\0',r['address'])
 u=lambda at:int.from_bytes(elf.read(at,4),'little')
 require(u(0xe34f0)==0xe7c70311,'original evidence predicate failed: u(0xe34f0)==0xe7c70311') # BFI r0,r1,#6,#2.
 require(u(0xe34e0)==0xe0000182,'original evidence predicate failed: u(0xe34e0)==0xe0000182') # mask the shifted r2 with 0x38.
 require(u(0xe34e8)==0xe3a0303c,'original evidence predicate failed: u(0xe34e8)==0xe3a0303c') # r3 overwritten, not consulted as a mode.
 require(u(0xe352c)==u(0xe3560)==0xe5940018,'original evidence predicate failed: u(0xe352c)==u(0xe3560)==0xe5940018') # two fresh index reads.
 for lit,pc,expected in [(0xe35a4,0xe3530,0x5eb3e7),(0xe35ac,0xe3544,0x5eb8b0),(0xe35b0,0xe3578,0x5eb4ba)]:
  require(pc+8+u(lit)==expected,'original evidence predicate failed: pc+8+u(lit)==expected')
 print('BM1368_PULSE135_EVIDENCE_PASS')
if __name__=='__main__':main()
