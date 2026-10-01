#!/usr/bin/env python3
"""Check original bytes and immutable reused code, not current test counts."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from current_dependency_pins_135 import check_current_dependency, require

def main():
 data=json.loads((ROOT/'integration/evidence/bm1368_reply_key_135.json').read_text())
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
 require(hashlib.sha256(elf.data).hexdigest()==data['reference_sha256'],"original evidence predicate failed: hashlib.sha256(elf.data).hexdigest()==data['reference_sha256']")
 for row in data['ranges']:
  a,b=int(row['start'],16),int(row['end'],16)
  require(hashlib.sha256(elf.read(a,b-a)).hexdigest()==row['sha256'],row['name'])
 for path,want in data['immutable'].items():
  check_current_dependency(ROOT,path,want)
 require(elf.read(0xe3bbc,8)==bytes.fromhex('4400a0e31eff2fe1'),"original evidence predicate failed: elf.read(0xe3bbc,8)==bytes.fromhex('4400a0e31eff2fe1')")
 u=lambda a:int.from_bytes(elf.read(a,4),'little')
 require(0x110+0x8c==0x19c,'original evidence predicate failed: 0x110+0x8c==0x19c')
 require(u(0x73de0)==0xe2803e11,'original evidence predicate failed: u(0x73de0)==0xe2803e11') # ADD r3,r0,#0x110: actual caller placement.
 require(0x6ef9c+8+u(0x6f1b4)==0x78aa4,'original evidence predicate failed: 0x6ef9c+8+u(0x6f1b4)==0x78aa4')
 require(0x6efdc+8+u(0x6f1c8)==0x78aa4,'original evidence predicate failed: 0x6efdc+8+u(0x6f1c8)==0x78aa4')
 require(0x10894c+8+u(0x1089c8)==0x654dc8,'original evidence predicate failed: 0x10894c+8+u(0x1089c8)==0x654dc8')
 print('BM1368_REPLY_KEY135_EVIDENCE_PASS')
if __name__=='__main__':main()
