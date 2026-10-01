#!/usr/bin/env python3
"""Read-only pin checks for original bytes and unchanged dependencies."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from current_dependency_pins_135 import check_current_dependency, require

def check():
    e=json.loads((ROOT/'integration/evidence/chip_sensor_check_135.json').read_text())
    elf=ELF32(ROOT/e['reference'])
    require(hashlib.sha256(elf.data).hexdigest()==e['reference_sha256'],'reference changed')
    for row in e['ranges']:
        a,b=int(row['start'],16),int(row['end_exclusive'],16)
        require(b>a and a%4==b%4==0,'invalid original range')
        require(hashlib.sha256(elf.read(a,b-a)).hexdigest()==row['sha256'],row['name'])
    for path,want in e['unchanged_files'].items():
        check_current_dependency(ROOT,path,want)
    print('CHIP_SENSOR_CHECK135_EVIDENCE_PASS ranges=%d unchanged_files=%d' %
          (len(e['ranges']),len(e['unchanged_files'])))
if __name__=='__main__':check()
