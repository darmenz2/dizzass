#!/usr/bin/env python3
"""Read-only pin checks for original bytes and unchanged dependencies."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32

def require(ok,message):
    if not ok:raise ValueError(message)
def blob(data):return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
def check():
    e=json.loads((ROOT/'integration/evidence/chip_sensor_check_135.json').read_text())
    elf=ELF32(ROOT/e['reference'])
    require(hashlib.sha256(elf.data).hexdigest()==e['reference_sha256'],'reference changed')
    for row in e['ranges']:
        a,b=int(row['start'],16),int(row['end_exclusive'],16)
        require(b>a and a%4==b%4==0,'invalid original range')
        require(hashlib.sha256(elf.read(a,b-a)).hexdigest()==row['sha256'],row['name'])
    for path,want in e['unchanged_files'].items():
        require(blob((ROOT/path).read_bytes())==want,'old dependency changed: '+path)
    print('CHIP_SENSOR_CHECK135_EVIDENCE_PASS ranges=%d unchanged_files=%d' %
          (len(e['ranges']),len(e['unchanged_files'])))
if __name__=='__main__':check()
