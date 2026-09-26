#!/usr/bin/env python3
"""Read-only source-boundary checks on the pinned ELF; no execution of startup."""
import argparse,json,struct
from pathlib import Path
from backend_cold_135_oracle import E,validate_evidence

def branch(pc):
 w=int.from_bytes(E.read(pc,4),'little')
 if w & 0x0f000000 != 0x0b000000: raise AssertionError(('not BL',hex(pc),hex(w)))
 delta=w&0xffffff
 if delta&0x800000:delta-=0x1000000
 return (pc+8+(delta<<2))&0xffffffff

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--summary');a=ap.parse_args()
 validate_evidence(E)
 assert E.read(0x730d8,4).hex()=='f04f2de9'
 assert E.read(0x7409c,4).hex()=='f04f2de9'
 assert E.read(0x73f10,4).hex()=='f08fbde8'
 expected={0x732c4:0xfb994,0x73f04:0x35830,0x7426c:0x100fc4,
           0xb5a8c:0x730d8,0xb5ab8:0x730d8}
 for pc,target in expected.items():assert branch(pc)==target,(hex(pc),hex(branch(pc)))
 assert int.from_bytes(E.read(0x5e9108,4),'little')==0x7409c
 targets=[]
 for pc in range(0x730d8,0x73f14,4):
  w=int.from_bytes(E.read(pc,4),'little')
  if w & 0x0f000000==0x0b000000:targets.append(branch(pc))
 assert 0x100fc4 not in targets and 0x7409c not in targets
 result={'constructor':'0x730d8','last_instruction':'0x73f10','literal_pool_end':'0x7409c',
  'separate_runtime_entry':'0x7409c','psu_call_pc':'0x7426c','psu_call_target':'0x100fc4',
  'runtime_pointer_at':'0x5e9108','constructor_direct_calls_runtime_or_psu':False,
  'checked_call_sites':{hex(k):hex(v) for k,v in expected.items()},
  'driver_table_field_name':'not established by this audit','physical_io':False}
 print('COLD135_BOUNDARIES_PASS '+json.dumps(result,sort_keys=True))
 if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
