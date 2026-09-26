#!/usr/bin/env python3
"""Original 0x6c61c -> 0x5db54 -> 0x56fcc; only external effects hooked."""
from pathlib import Path
import argparse,ctypes as C,hashlib,json,random,sys
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from backend_cold_135_oracle import validate_evidence
from arm32_difficulty_subset import ARM32Difficulty
M=0xffffffff;B=0x840800;P=0x840400;T=0x848600;E0=0x848800;CH=0x842000;OUT=0x848c00
DEFAULT=[3,0,2,70,35,111,222,0xdeadbeef,0,0,4,0,0,0,0,0,1,1,40,1,1,1,50,1,1,1,45,1,1,1,60,1,0,0,0,0]
class Arm(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in [(0x6c61c,0x6c884),(0x5db54,0x5dda0),(0x56fcc,0x57030),(0xa71dc,0xa7228)]):raise ValueError('unhooked '+hex(pc))
  self.visited.add(pc);return super().extra_instruction(w,pc)
def original(v,elf):
 m=Arm(elf);m.reset((B,OUT));m.visited=set();out=[]
 for off,val in [(0x18,P),(0x230,CH),(0x50,v[1]),(0x6c,v[5]),(0x70,v[6])]:m.write(B+off,val)
 m.write(P+0x38+0x20,T);m.write(T,E0);m.write(T+0x18,v[2]);m.write(P+0xbc+8,v[4]);m.write(P+0xf0,v[3]);m.write(OUT,v[7])
 for i in range(4):
  m.write(E0+28*i,v[8+i*2]);m.write(E0+28*i+25,v[9+i*2],1)
  c=CH+i*800;m.write(c+0x20,v[16+i*4]);m.write(c+0x24,v[17+i*4],1)
  m.write(c+0x2ac,v[18+i*4]);m.write(c+0x2b0,v[19+i*4],1)
 def call(mm,key):
  args=[];ret=0
  if key==0xfe668:ret=v[0]
  elif key in [0x5a6108,0x5a66c4]:
   assert (mm.r[0]-CH)%800==0;args=[(mm.r[0]-CH)//800];ret=v[32 if key==0x5a6108 else 33]
  elif key==0xf8a30:args=[mm.r[0]];ret=v[34]
  elif key==0xf86a8:args=mm.r[:4];ret=v[34]
  elif key==0xfa0c4:args=[mm.r[3]]
  out.extend([key,len(args),*args]);mm.r[0]=ret&M
 hooks={k:(lambda mm,k=k:call(mm,k)) for k in [0xfe668,0x5a6108,0x5a66c4,0xf8a30,0xf86a8,0xfa0c4]}
 rc=m.run(0x5db54 if v[35] else 0x6c61c,hooks=hooks,max_steps=10000)
 out.extend([M,rc,m.read(OUT)])
 return out,len(m.visited)
def cases():
 yield 'baseline',DEFAULT[:]
 for direct in [0,1]:
  for n in [M,0,1,2,4]:
   for state in [0,1,2,3,4,5,6,M]:
    for valid in [0,1,2,255]:
     v=DEFAULT[:];v[35]=direct;v[0]=n
     for i in range(4):v[16+i*4]=state;v[19+i*4]=valid
     yield 'aggregate_predicate',v
 for ty in [0,1,2,3,4,5,M]:
  for flag in [0,1,2,3,255]:
   for count in [0,1,2,4]:
    v=DEFAULT[:];v[2]=count
    for i in range(4):v[8+i*2]=ty;v[9+i*2]=flag
    yield 'table_choice',v
 for reading in [0x80000000,M,0,44,45,46,0x7fffffff]:
  for i in range(4):
   v=DEFAULT[:];v[18+i*4]=reading;yield 'signed_max',v
 for mode in [0,1,2,3,256,M]:
  for ret in [0,1,2,M]:
   v=DEFAULT[:];v[1]=mode;v[32]=ret;v[33]=ret;v[34]=ret;yield 'ignored_failures',v
 rng=random.Random(0x6c61c)
 for _ in range(80):
  v=DEFAULT[:];v[0]=4
  for i in range(4):v[16+i*4:20+i*4]=[rng.randrange(8),rng.randrange(4),rng.getrandbits(32),rng.randrange(3)]
  yield 'mixed',v

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');a=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');validate_evidence(elf);lib=C.CDLL(str(Path(a.library).resolve()))
 lib.vn135_peripheral_fixture.argtypes=[C.POINTER(C.c_uint32),C.POINTER(C.c_uint32)]
 counts={};words=0
 for label,v in cases():
  expected,_=original(v,elf);buf=(C.c_uint32*128)();n=lib.vn135_peripheral_fixture((C.c_uint32*36)(*v),buf)
  assert expected==list(buf[:n]),(label,v,expected,list(buf[:n]))
  counts[label]=counts.get(label,0)+1;words+=n
 result={'cases':counts,'total':sum(counts.values()),'words_compared':words,'physical_io':False,'cached_data_only':True,
         'original_caller_aggregate_predicate_executed':True,'new_arm_opcodes':0,'reference_sha256':hashlib.sha256(elf.data).hexdigest()}
 print('PERIPHERAL135_ORIGINAL_PASS '+json.dumps(result,sort_keys=True))
 if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
