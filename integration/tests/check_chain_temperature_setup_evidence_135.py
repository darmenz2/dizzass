#!/usr/bin/env python3
"""Pin original instructions and immutable reused implementations/fixtures."""
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def main():
 e=json.loads((ROOT/'integration/evidence/chain_temperature_setup_135.json').read_text())
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
 assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
 for r in e['ranges']:
  lo,hi=int(r['start'],16),int(r['end'],16)
  assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==r['sha256'],r['name']
 for path,want in e['immutable'].items():
  data=(ROOT/path).read_bytes()
  assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==want,path
 for s in e['strings']:
  raw=elf.read(int(s['address'],16),len(s['text'])+1)
  assert bytes(v^s['xor_key'] for v in raw)==s['text'].encode()+b'\0',s['address']
 for addr,word in e['instruction_words'].items():
  assert int.from_bytes(elf.read(int(addr,16),4),'little')==int(word,16),addr
 for literal,pc,want in e['literal_edges']:
  assert pc+8+int.from_bytes(elf.read(literal,4),'little')==want
 print('CHAIN_TEMPERATURE_SETUP135_EVIDENCE_PASS',len(e['immutable']),'immutable files')
if __name__=='__main__':main()
