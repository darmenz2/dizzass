#!/usr/bin/env python3
"""Pin original bytes and unchanged source prefix before running the oracle."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(data):return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
def check():
 e=json.loads((ROOT/'integration/evidence/general_monitor_135.json').read_text())
 elf=ELF32(ROOT/e['reference']);assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
 for item in e['ranges']:
  a,b=int(item['start'],16),int(item['end_exclusive'],16)
  assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==item['sha256'],item['name']
 for item in e['literals']:
  data=elf.read(int(item['address'],16),item['length'])
  assert hashlib.sha256(data).hexdigest()==item['sha256']
  assert bytes(x^item['xor_key'] for x in data)==item['decoded'].encode()+b'\0'
 for name,sha in e['unchanged_files'].items():assert blob((ROOT/name).read_bytes())==sha,name
 item=e['base_source'];data=(ROOT/item['path']).read_bytes()
 assert blob(data[:item['length']])==item['git_blob'],item['path']
 assert data[item['length']:].startswith(b'\n/* Original general control worker')
 print('GENERAL_MONITOR135_EVIDENCE_PASS original ranges literals prefix and production boundary')
if __name__=='__main__':check()
