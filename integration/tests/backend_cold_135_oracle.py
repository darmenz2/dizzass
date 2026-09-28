"""Pinned, bounded original instruction execution; external effects are RAM.

No vendor process, hardware or new ARM instruction semantics are introduced.
"""
from pathlib import Path
import sys,struct,json,hashlib
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
def validate_evidence(elf):
 evidence=json.loads((ROOT/'integration/evidence/backend_cold_135.json').read_text())
 if hashlib.sha256(elf.data).hexdigest()!=evidence['reference_sha256']:
  raise ValueError('Wrong reference ELF')
 for item in evidence['ranges']:
  a,b=int(item['start'],16),int(item['end_exclusive'],16)
  if hashlib.sha256(elf.read(a,b-a)).hexdigest()!=item['sha256']:
   raise ValueError('Changed instruction range '+item['name'])
 for item in evidence['data']:
  if hashlib.sha256(elf.read(int(item['address'],16),item['size'])).hexdigest()!=item['sha256']:
   raise ValueError('Changed evidence data '+item['name'])
 return evidence
E=ELF32(ROOT/'reference/cgminer.vendor.elf')
EVIDENCE=validate_evidence(E)
class Halt(Exception):pass
class A(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in [(0x730d8,0x73f14),(0xa71dc,0xa7228),(0xa72b4,0xa7364),(0x53d98,0x53da0)]):
   raise ValueError('unhooked '+hex(pc))
  self.visited.add(pc)
  return super().extra_instruction(w,pc)
def run(case=None):
 c=case or {};m=A(E);m.reset((0x848400,));m.visited=set();ev=[];alloc=[]
 P=0x840400;B=0x840800;D=0x840000;CH=0x842000;SN=0x843000;L=0x848000
 def event(k,args=()):ev.append([k,list(args)])
 def ret(key,default=0):return c.get('returns',{}).get(hex(key),default)
 def calloc(mm):
  caller=mm.r[14]-4
  role={0x730f4:'device',0x73104:'model',0x733a4:'backend',0x73448:'chains',0x7352c:'records',0x73604:'chips',0x73674:'items',0x73b00:'limits'}[caller]
  n,size=mm.r[:2];ordinal=len(alloc);idx=sum(x[0]==role for x in alloc)
  address={'device':D,'model':P,'backend':B,'chains':CH,'records':SN,'chips':0x843800+idx*0x800,'items':0x846000+idx*0x400,'limits':L}[role]
  if c.get('fail_alloc')==ordinal:address=0
  alloc.append((role,address,n,size));event('alloc',(role,n,size,address))
  if address: mm.mem[address:address+n*size]=b'\0'*(n*size)
  mm.r[0]=address
 def loader(mm):
  assert mm.r[0]==P;event('load',(P,))
  values={0x88:4,0xac:1,0xb0:0,0xb4:0,0xb8:0,0x38:2,0x48:3,0x58:0x848600,0x34:0}
  values.update({int(k,16):v for k,v in c.get('profile',{}).items()})
  for off,v in values.items():mm.write(P+off,v)
  mm.write(P+0x2c,c.get('byte2c',1),1);mm.write(0x848600+0x18,c.get('items',2))
  mm.r[0]=ret(0xa7a48)
 def log(mm):event('log',(mm.r[3],mm.read(mm.r[13])));mm.r[0]=0
 def fatal(mm):event('fatal',(mm.r[0],));raise Halt()
 def step(mm,key):
  n={0xfdfdc:1,0xfe038:1,0xfe000:1,0xfb994:5,0xfe668:0,0x5a6880:1,0x5a6890:2,0x5a60dc:2,0x5a6878:1,0x5a6c48:3,0x82048:3,0x49c98:2,0x593c8c:1,0x5c4dc:2,0xfdfac:0,0xb2a88:1,0x49b38:1,0xb86fc:1,0x81f68:1,0xd21dc:4,0x35830:1}[key]
  args=mm.r[:min(n,4)]+([mm.read(mm.r[13])] if n==5 else [])
  event(hex(key),args)
  mm.r[0]=ret(key,c.get('chains',2) if key==0xfe668 else 0)&0xffffffff
 hooks={0x593bb4:calloc,0xa7a48:loader,0xfa0c4:log,0x72bf4:fatal}
 for k in [0xfdfdc,0xfe038,0xfe000,0xfb994,0xfe668,0x5a6880,0x5a6890,0x5a60dc,0x5a6878,0x5a6c48,0x82048,0x49c98,0x593c8c,0x5c4dc,0xfdfac,0xb2a88,0x49b38,0xb86fc,0x81f68,0xd21dc,0x35830]:hooks[k]=lambda mm,k=k:step(mm,k)
 try:m.run(0x730d8,hooks=hooks,max_steps=20000);outcome='return'
 except Halt:outcome='fatal'
 return {'machine':m,'outcome':outcome,'events':ev,'allocation':alloc,'callbacks':[hex(m.read(B+off)) for off in range(0x1f0,0x20c,4)],'backend':{hex(x):hex(m.read(B+x,1 if x==0x211 else 4)) for x in [0x18,0x74,0x1c,0x78,0x7c,0x230,0x100,0x20,0x211]},'device':{hex(x):hex(m.read(D+x)) for x in [4,0x14,0x20,0x98]},'steps':m.steps,'visited':len(m.visited)}
