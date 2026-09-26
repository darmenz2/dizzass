#!/usr/bin/env python3
"""Compare 0x730d8 with its C projection; callees/syscalls remain explicit.

No firmware process, device, physical power or original terminal routine runs.
"""
import ctypes as C,hashlib,json,random,sys,argparse
from pathlib import Path
from backend_cold_135_oracle import run,E
ROLE={'device':0,'model':1,'backend':2,'chains':3,'records':4,'chips':5,'items':6,'limits':7}
DEFAULT=[2,3,2,4,2,0,1,1,0,0,0xffffffff,0,0,0,0,0]
MASK=0xffffffff

def original(v):
 fields={'0x88':v[3],'0x38':v[4],'0x48':v[1],'0x34':v[5],
         '0xac':v[7],'0xb0':v[8],'0xb4':v[9],'0xb8':v[14]}
 returns={hex(v[11]):v[12]} if v[11] else {}
 if v[11]!=0xfdfac:returns['0xfdfac']=v[13]
 r=run({'chains':v[0],'items':v[2],'byte2c':v[6],
        'profile':fields,'returns':returns,'fail_alloc':v[10]})
 out=[]
 for key,args in r['events']:
  if key=='alloc':key=0x593bb4;args=[ROLE[args[0]],*args[1:]]
  elif key=='load':key=0xa7a48
  elif key=='log':key=0xfa0c4
  elif key=='fatal':key=0x72bf4
  else:key=int(key,16)
  out.extend([key,len(args),*args])
 m=r['machine'];alloc=r['allocation'];byrole={key:ptr for key,ptr,n,size in alloc}
 D=byrole.get('device',0);B=byrole.get('backend',0)
 out.extend([MASK,int(r['outcome']=='fatal'),D])
 if D:out.extend(m.read(D+x) for x in [4,0x14,0x20,0x98])
 out.append(B)
 if B:
  out.extend(m.read(B+x,1 if x==0x211 else 4) for x in [0x18,0x74,0x1c,0x78,0x100,0x230,0x7c,0x20,0x211])
  out.extend(m.read(B+x) for x in range(0x1f0,0x20c,4))
  CH=m.read(B+0x230)
  if CH:
   for i in range(v[0]):
    a=CH+800*i
    out.extend(m.read(a+x) for x in [0x18,0x1c,0x88,0x290])
    chip=m.read(a+0x88)
    if chip:
     for j in range(v[1]):out.extend([m.read(chip+j*96),m.read(chip+j*96+4)])
 return [x&MASK for x in out],r['visited']

def cases():
 yield 'baseline',DEFAULT[:]
 for chains in range(5):
  for chips in [0,1,3,8]:
   for items in [0,1,4]:
    for selector in [0,4,7,8,0xffffffff]:
     v=DEFAULT[:];v[:4]=[chains,chips,items,selector];yield 'sizes_selector',v
 for route in [0,1,2,0x80000000,0xffffffff]:
  for opt in [0,1,2,0x80000000,0xffffffff]:
   v=DEFAULT[:];v[5]=opt;v[13]=route;yield 'callback_table',v
 for j in [7,8,9,14]:
  for cap in [0,1,2,0xffffffff]:
   v=DEFAULT[:];v[7]=0;v[j]=cap;yield 'capabilities',v
 for fail in range(1,14):
  if fail==2:continue
  v=DEFAULT[:];v[10]=fail;yield 'allocation_failure',v
 for step in [0xa7a48,0xfb994,0x82048,0xb2a88,0x49b38,0xb86fc,0x81f68,0xd21dc,
              0xfdfdc,0xfe038,0xfe000,0x5a6880,0x5a6890,0x5a60dc,0x5a6878,
              0x5a6c48,0x5c4dc,0x35830]:
  for ret in [1,2,0x80000000,0xffffffff]:
   v=DEFAULT[:];v[11:13]=[step,ret];yield 'callee_result',v
 for stride in [0,1,2,0x40000000,0x80000000,0xffffffff]:
  v=DEFAULT[:];v[4]=stride;yield 'chip_word4_wrap',v
 for byte in [0,1,2,255,256,0xffffffff]:
  v=DEFAULT[:];v[6]=byte;yield 'byte_width',v
 rng=random.Random(0x730d8)
 for _ in range(100):
  v=DEFAULT[:];v[0]=rng.randrange(5);v[1]=rng.randrange(9);v[2]=rng.randrange(5)
  v[3]=rng.getrandbits(32);v[4]=rng.getrandbits(32);v[5]=rng.randrange(3);v[6]=rng.getrandbits(32)
  v[13]=rng.getrandbits(32);yield 'mixed',v

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');a=ap.parse_args()
 lib=C.CDLL(str(Path(a.library).resolve()));lib.vn135_cold_fixture.argtypes=[C.POINTER(C.c_uint32),C.POINTER(C.c_uint32)]
 counts={};total=0;visited=set();words=0
 for label,v in cases():
  expected,nvisit=original(v);buf=(C.c_uint32*4096)();n=lib.vn135_cold_fixture((C.c_uint32*16)(*v),buf);actual=list(buf[:n])
  if expected!=actual:
   i=next((i for i,(x,y) in enumerate(zip(expected,actual)) if x!=y),min(len(expected),len(actual)))
   raise AssertionError((label,v,i,expected[max(0,i-8):i+10],actual[max(0,i-8):i+10],len(expected),len(actual)))
  counts[label]=counts.get(label,0)+1;total+=1;words+=len(expected);visited.add(nvisit)
 # Independently execute numeric selector leaf for the entire byte domain.
 lib.vn135_cold_chip_identifier_135.argtypes=[C.c_uint32];lib.vn135_cold_chip_identifier_135.restype=C.c_uint32
 from backend_cold_135_oracle import A
 m=A(E)
 for x in [*range(256),0x80000000,0xffffffff]:
  m.reset((x,));m.visited=set();expected=m.run(0xa72b4)
  assert expected==lib.vn135_cold_chip_identifier_135(x)
 result={'cases':counts,'constructor_cases':total,'selector_leaf_cases':258,'serialized_words_compared':words,
         'reference_sha256':hashlib.sha256(E.data).hexdigest(),'original_terminal_handler':'stop at entry',
         'physical_io':False,'new_arm_opcodes':0,'unresolved_callees':'scripted callbacks',
         'runtime_prepare_7409c_translated':False}
 print('COLD135_ORIGINAL_PASS '+json.dumps(result,sort_keys=True))
 if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
