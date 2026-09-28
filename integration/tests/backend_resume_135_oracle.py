"""Bounded original resume instructions; no firmware process or hardware calls.

Existing ARM32Difficulty is reused without extending its instruction set.
Unrecovered callees and C-library effects are scripted explicitly. The original
power caller, PSU-on wrapper and pure descriptor/chain getters execute in ARM.
"""
from pathlib import Path
import sys, struct, hashlib, json
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
MASK=0xffffffff
B=0x840100; PROFILE=0x842000; LIMITS=0x843000; TABLE=0x843200
ENTRIES=0x843300; CHAINS=0x844000; ITEMS=0x847000
TEXT=0x849000; OLD=0x849100; NEW=0x849200; PLATFORM=0x654b24
MAX_CHAINS=4; MAX_ITEMS=5
# Source fields, not a recreated ABI for use by cgminer.
FIELDS={
 'word_20':(B+0x20,4),'word_dc':(B+0xdc,4),'limit_34':(LIMITS+0x34,4),
 'word_d4':(B+0xd4,4),'byte_24':(B+0x24,1),'byte_85':(B+0x85,1),
 'byte_ec':(B+0xec,1),'byte_1054':(B+0x1054,1),'platform':(PLATFORM,1),
 'power_on':(B+0xff1,1),'power_word':(B+0x20c,4),
 'thread_1050':(B+0x1050,4),'thread_1044':(B+0x1044,4),
 'thread_101c':(B+0x101c,4),'thread_1014':(B+0x1014,4),
 'text_90':(B+0x90,4),'text_fc8':(B+0xfc8,4),
 'model_word10':(PROFILE+0x10,4),'board_word10':(PROFILE+0x48,4),
 'table_count':(TABLE+0x18,4),'selector':(PROFILE+0x88,4),
 'chip_word2c':(PROFILE+0xb4,4)
}
DEFAULT_FIELDS={
 'word_20':5,'word_dc':12000,'limit_34':15000,'word_d4':0,
 'byte_24':0,'byte_85':0,'byte_ec':0,'byte_1054':0,'platform':0xa5,
 'power_on':0x55,'power_word':0x11223344,'thread_1050':0x10101010,
 'thread_1044':0x20202020,'thread_101c':0x30303030,'thread_1014':0x40404040,
 'text_90':TEXT,'text_fc8':OLD,'model_word10':3,'board_word10':108,
 'table_count':3,'selector':4,'chip_word2c':0x44332211
}
STEP_IDS=[0xfe668,0x82d60,0xb86d0,0x4f0a0,0xb9148,0x34920,0x5a6684,
 0x5a66c4,0x59c09c,0x10ef3c,0xfe190,0x106e58,0x66504,0x6c61c,0x6c89c,
 0x6e31c,0x6e734,0x6ec4c,0xfdfbc,0x6f1cc,0x6f550,0x6f6f4,0x6709c,
 0x66244,0x6f8ac,0x6fae8,0xf8c70,0x644a8,0x6bb70,0x49c98,0x5e92c,
 0x55400,0xa20a0,0x5de64,0x60a2c,0x8291c,0x829e8]
BACKEND_ARG={0xb86d0,0xb9148,0x5a6684,0x5a66c4,0x66504,0x6c61c,0x6c89c,
 0x6e31c,0x6e734,0x6ec4c,0x6f1cc,0x6f550,0x6f6f4,0x6709c,0x66244,
 0x6f8ac,0x6fae8,0x644a8,0x6bb70,0x5e92c,0xa20a0,0x5de64,0x60a2c}
DEFAULT_RET={0xfe668:3,0x34920:1,0x59c09c:12345}
RANGES=[(0x70e30,0x727e0),(0xa71f4,0xa7218),(0x56fc4,0x57030),
 (0xfe114,0xfe190),(0x6c224,0x6c61c),(0x102a94,0x102b04)]

class Script:
 def __init__(self,case):
  self.case=case; self.events=[]; self.calls={}
 def invoke(self,key,args,get_state,mutate):
  n=self.calls.get(key,0); self.calls[key]=n+1
  self.events.append((key,tuple(args),get_state()))
  for entry in self.case.get('mutate',[]):
   if entry['at']==key and entry.get('nth',0)==n:mutate(entry['fields'])
  values=self.case.get('returns',{}).get(key,DEFAULT_RET.get(key,0))
  if isinstance(values,(tuple,list)): values=values[min(n,len(values)-1)]
  return int(values)

class ResumeArm(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in RANGES):raise ValueError('Unexpected resume PC '+hex(pc))
  self.visited.add(pc)
  return super().extra_instruction(w,pc)

class ResumeOracle:
 def __init__(self):
  self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
  self.hash=hashlib.sha256(self.elf.data).hexdigest()
  assert self.hash=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
  evpath=ROOT/'integration/evidence/backend_resume_135.json'
  if evpath.exists():
   evidence=json.loads(evpath.read_text())
   for r in evidence['ranges']:
    a,b=int(r['start'],16),int(r['end_exclusive'],16)
    assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==r['sha256']
  self.m=ResumeArm(self.elf)
 def snapshot(self):
  m=self.m
  return (tuple(m.read(a,n) for a,n in FIELDS.values()),m.read(B+0x28,8),
   tuple((m.read(CHAINS+i*800+0x20),m.read(CHAINS+i*800+0x24,1),
          tuple((m.read(ITEMS+i*0x400+j*128+0x3c),m.read(ITEMS+i*0x400+j*128+0x44))
                for j in range(MAX_ITEMS))) for i in range(MAX_CHAINS)))
 def mutate(self,fields):
  for k,v in fields.items():
   a,n=FIELDS[k];self.m.write(a,int(v),n)
 def run(self,case):
  m=self.m;m.reset((B,));m.visited=set();self.script=Script(case)
  m.mem[B:B+0x1100]=b'\xa5'*0x1100
  m.mem[PROFILE:PROFILE+0x300]=b'\xa5'*0x300
  self.mutate(DEFAULT_FIELDS);self.mutate(case.get('fields',{}))
  m.write(B+0x18,PROFILE);m.write(B+0x1c,LIMITS);m.write(B+0x230,CHAINS)
  m.write(PROFILE+0x38+0x20,TABLE);m.write(TABLE,ENTRIES)
  m.mem[B+0x28:B+0x30]=struct.pack('<d',case.get('old_time',-99.25))
  types=case.get('types',[0,4,0,4,7])
  for j in range(MAX_ITEMS):m.write(ENTRIES+28*j,types[j])
  chains=case.get('chains',[(1,1),(1,1),(1,1),(1,1)])
  for i,(state,flag) in enumerate(chains):
   m.mem[CHAINS+i*800:CHAINS+(i+1)*800]=b'\xa5'*800
   m.write(CHAINS+i*800+0x20,state);m.write(CHAINS+i*800+0x24,flag,1)
   m.write(CHAINS+i*800+0x290,ITEMS+i*0x400)
   for j in range(MAX_ITEMS):
    m.mem[ITEMS+i*0x400+j*128:ITEMS+i*0x400+(j+1)*128]=b'\xa5'*128
    m.write(ITEMS+i*0x400+j*128+0x3c,1000+i*10+j)
    m.write(ITEMS+i*0x400+j*128+0x44,0x87650000+i*10+j)
  m.mem[TEXT:TEXT+9]=b'new-text\0';m.mem[OLD:OLD+9]=b'old-text\0';m.mem[NEW:NEW+9]=b'new-text\0'
  # prologue: 36 pushed + 12 local + 8 scratch = 56 bytes.
  join_ptr=m.STACK_TOP-56;m.write(join_ptr,case.get('join_seed',0))
  before=bytes(m.mem[B:B+0x1100]); hooks={}
  def call(key,*args):return self.script.invoke(key,args,self.snapshot,self.mutate)
  def step(mm,key):
   if key in BACKEND_ARG:assert mm.r[0]==B,(hex(key),hex(mm.r[0]))
   if key in (0x82d60,0x4f0a0):assert mm.r[0]==B+0x50
   args=(0,0,0)
   if key==0x106e58:args=tuple(mm.r[:3])
   elif key in (0x10ef3c,0x829e8):args=(mm.r[0],0,0)
   elif key in (0x6e734,0x6709c,0x66244,0x644a8):args=(mm.r[1],0,0)
   elif key==0x49c98:
    assert mm.r[0]==B+0x10b4;args=(mm.r[1],0,0)
   elif key==0x55400:
    assert (mm.r[0]-CHAINS)%800==0;args=((mm.r[0]-CHAINS)//800,0,0)
   mm.r[0]=call(key,*args)&MASK
  for key in STEP_IDS:hooks[key]=lambda mm,key=key:step(mm,key)
  def log(mm):
   line=mm.r[3];level=mm.read(mm.r[13]);a=b=0
   if line in (1973,1976):
    a=mm.read(mm.r[13]+8);call('power_log',2,line,a)
   elif line in (4997,5000,5005):call('power_log',2,line,0)
   else:
    if line==6124:a=mm.read(mm.r[13]+8)
    elif line==6157:a=mm.read(mm.r[13]+8);b=mm.read(mm.r[13]+12)
    call('log',line,level,a,b)
   mm.r[0]=0
  hooks[0xfa0c4]=log
  def on(mm):mm.r[0]=call('on')&MASK
  hooks[0xfe310]=on
  def setter(mm):
   assert mm.r[0]==B+0x108c
   mm.r[0]=call('setter',mm.r[1])&MASK
  hooks[0x104134]=setter
  def create(mm):
   offset=mm.r[0]-B;assert offset in (0x1044,0x101c,0x1014)
   assert mm.r[1]==0 and mm.r[3]==B
   ptr=mm.r[0];rc=call('create',offset,mm.r[2])
   if case.get('create_write',True) and (rc==0 or case.get('create_error_write',False)):
    mm.write(ptr,0x60000000+offset)
   mm.r[0]=rc&MASK
  hooks[0x5a55cc]=create
  def join(mm):
   assert mm.r[1]==join_ptr
   rc=call('join',mm.r[0])
   if case.get('join_write',True):mm.write(join_ptr,case.get('join_value',0))
   mm.r[0]=rc&MASK
  hooks[0x5a5d2c]=join
  def duplicate(mm):call('duplicate',mm.r[0]);mm.r[0]=case.get('duplicate_value',NEW)
  hooks[0x5a38a0]=duplicate
  def release(mm):call('release',mm.r[0]);mm.r[0]=0
  hooks[0x593c8c]=release
  def time(mm):call('time');mm.set_d(0,case.get('new_time',12345.125))
  hooks[0x1ed58]=time
  def divmod_(mm):
   a,b=signed(mm.r[0]),signed(mm.r[1]);assert b>0
   q=abs(a)//b;q=-q if a<0 else q
   mm.r[0]=q&MASK;mm.r[1]=(a-q*b)&MASK
  hooks[0x590fcc]=divmod_
  rc=signed(m.run(0x70e30,hooks=hooks,max_steps=30000))
  after=bytes(m.mem[B:B+0x1100])
  mutable={}
  for a,n in FIELDS.values():
   if B<=a<a+n<=B+0x1100:
    for off in range(a-B,a-B+n):mutable[off]=1
  mutable.update({i:1 for i in range(0x28,0x30)})
  for off,(x,y) in enumerate(zip(before,after)):
   assert x==y or off in mutable,('unexpected backend write',hex(off))
  return rc,self.snapshot(),m.read(join_ptr),self.script.events,set(m.visited)
