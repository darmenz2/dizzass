#!/usr/bin/env python3
"""Pin old source, original function/data ranges and diagnostic literals."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
 e=json.loads((ROOT/'integration/evidence/temperature_setup_135.json').read_text())
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
 assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
 for row in e['ranges']:
  a,b=int(row['start'],16),int(row['end_exclusive'],16)
  assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==row['sha256'],row['start']
 for name,digest in e['dependencies'].items():assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest,name
 for row in e['literals']:
  text=row['text'].encode()+b'\0'
  assert bytes(x^row['xor_key'] for x in elf.read(int(row['address'],16),len(text)))==text,row
 print('TEMPERATURE_SETUP135_EVIDENCE_PASS',len(e['dependencies']),'immutable dependencies')
if __name__=='__main__':main()
