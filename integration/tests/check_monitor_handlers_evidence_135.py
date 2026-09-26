#!/usr/bin/env python3
"""Check immutable reference ranges, literals, the published prefix and core."""
import hashlib,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def blob(b):return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def main():
 e=json.loads((ROOT/'integration/evidence/monitor_handlers_135.json').read_text())
 elf=ELF32(ROOT/e['reference']);assert hashlib.sha256(elf.data).hexdigest()==e['reference_sha256']
 for item in e['ranges']:
  a,b=int(item['start'],16),int(item['end_exclusive'],16)
  assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==item['sha256'],item['name']
 for item in e['literals']:
  b=elf.read(int(item['address'],16),item['length'])
  assert hashlib.sha256(b).hexdigest()==item['sha256']
  assert bytes(x^item['xor_key'] for x in b)==item['decoded'].encode()+b'\0'
 for item in e['constants'].values():
  b=bytes.fromhex(item['bytes']);assert elf.read(int(item['address'],16),len(b))==b
 assert struct.unpack('<d',bytes.fromhex(e['constants']['warmup_deadline']['bytes']))[0]==900.0
 assert int.from_bytes(bytes.fromhex(e['constants']['cleanup_routine_got']['bytes']),'little')==0x5cf34
 for name,wanted in e['unchanged_files'].items():assert blob((ROOT/name).read_bytes())==wanted,name
 item=e['base_source'];b=(ROOT/item['path']).read_bytes()
 assert blob(b[:item['length']])==item['git_blob']
 assert b[item['length']:].startswith(b'\n/* Original internal monitor handlers 60730/60a2c/60d58/5e53c. */')
 print('MONITOR_HANDLERS135_EVIDENCE_PASS original bodies literals constants unchanged published prefix and core')
if __name__=='__main__':main()
