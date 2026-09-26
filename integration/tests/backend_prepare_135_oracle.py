"""Bounded execution of pinned ARM words. OS/peripheral effects are RAM scripts.
No opcode changes, vendor process, host device operation or worker execution.
"""
from pathlib import Path
import sys, json, hashlib
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
MASK=0xffffffff
B=0x840100; D=0x842000; T=0x842200; P=0x843000; L=0x843800
F=0x844000; TEXT=0x846000; OLD=0x846100; NEW=0x846200; FILE=0x846400
PLATFORM=0x654b24; SERIAL=ARM32Difficulty.STACK_TOP-304
MAX_FANS=8
FIELDS={
 'word_28':(B+0x28,4),'word_2c':(B+0x2c,4),'word_1070':(B+0x1070,4),
 'byte_24':(B+0x24,1),'byte_fe5':(B+0xfe5,1),'byte_104a':(B+0x104a,1),
 'byte_85':(B+0x85,1),'byte_f4':(B+0xf4,1),'byte_210':(B+0x210,1),
 'mode_50':(B+0x50,4),'word_68':(B+0x68,4),'word_10c':(B+0x10c,4),
 'word_23c':(B+0x23c,4),'text_90':(B+0x90,4),'text_fc8':(B+0xfc8,4),
 'thread_ff4':(B+0xff4,4),'platform':(PLATFORM,1),
 'lower_30':(L+0x30,4),'upper_34':(L+0x34,4),'word_3c':(L+0x3c,4),
 'word_14':(L+0x14,4),'word_1c':(P+0x1c,4),'fan_count':(P+0xbc,4),
 'fan_word_0c':(P+0xc8,4)}
DEFAULT={
 'word_28':0x11111111,'word_2c':0x22222222,'word_1070':0x33333333,
 'byte_24':0x55,'byte_fe5':0x66,'byte_104a':0x77,'byte_85':0,'byte_f4':0,
 'byte_210':0x88,'mode_50':0,'word_68':2,'word_10c':0,'word_23c':0,
 'text_90':TEXT,'text_fc8':OLD,'thread_ff4':0x11223344,'platform':0xa5,
 'lower_30':10000,'upper_34':15000,'word_3c':9000,'word_14':1,
 'word_1c':3000,'fan_count':2,'fan_word_0c':1000}
SOURCES=[0x4f2d0,0xb86d0,0xb9148,0x82d60,0xf96a0,0xb4c58,0xf8b60,
 0xf8a30,0x10ef3c,0xa1fe0,0x49c98,0x5e92c,0x5a6108,0x5a66c4,0xfe2f0,0xfe300]
DEFAULT_RET={hex(0xfe300):1200,hex(0xfe2f0):30,'stat':-1,'duplicate':1,
 'serial_open':1,'serial_read':1,'thread':0}
RANGES=[(0x7409c,0x74acc),(0x7755c,0x776d0),(0xa71dc,0xa71e8),(0xfe114,0xfe190)]
class Script:
 def __init__(self,case):self.case=case;self.events=[];self.calls={}
 def invoke(self,key,args,state,mutate):
  n=self.calls.get(key,0);self.calls[key]=n+1
  self.events.append((key,tuple(args),state()))
  for change in self.case.get('mutate',[]):
   if change['at']==key and change.get('nth',0)==n:mutate(change['fields'])
  result=self.case.get('returns',{}).get(key,DEFAULT_RET.get(key,0))
  if isinstance(result,list):result=result[min(n,len(result)-1)]
  return int(result)
class Arm(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in RANGES):raise ValueError('Unexpected PC '+hex(pc))
  self.visited.add(pc)
  return super().extra_instruction(w,pc)
class Oracle:
 def __init__(self):
  self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
  evidence=json.loads((ROOT/'integration/evidence/backend_prepare_135.json').read_text())
  assert hashlib.sha256(self.elf.data).hexdigest()==evidence['reference_sha256']
  for r in evidence['ranges']:
   a,b=int(r['start'],16),int(r['end_exclusive'],16)
   assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==r['sha256']
  for r in evidence['data']:
   assert hashlib.sha256(self.elf.read(int(r['address'],16),r['size'])).hexdigest()==r['sha256']
  for r in evidence.get('decoded_literals',[]):
   data=self.elf.read(int(r['address'],16),len(r['text'])+1)
   assert hashlib.sha256(data).hexdigest()==r['sha256']
   assert bytes(x^r['xor'] for x in data)==r['text'].encode()+b'\0'
  for r in evidence.get('direct_calls',[]):
   pc=int(r['pc'],16);w=int.from_bytes(self.elf.read(pc,4),'little')
   assert w&0xff000000==0xeb000000
   target=pc+8+((w&0xffffff)-(0x1000000 if w&0x800000 else 0))*4
   assert target==int(r['target'],16)
  assert self.elf.read(0x74c0c,4)==bytes.fromhex('f04f2de9')
  assert self.elf.read(0x7409c,4)==bytes.fromhex('f04f2de9')
  assert (0x74908+8+int.from_bytes(self.elf.read(0x74bf8,4),'little'))&MASK==0x7bfc0
  self.m=Arm(self.elf)
 def run(self,case,poll=False,augment=None):
  m=self.m;m.reset((B if poll else T,));m.visited=set();sc=Script(case)
  m.mem[B:B+0x1348]=b'\xa7'*0x1348
  for a in (D,T,P,L,F):m.mem[a:a+0x200]=b'\0'*0x200
  m.write(T+0x24,D);m.write(D+0x14,B);m.write(B+0x18,P)
  m.write(B+0x1c,L);m.write(B+0x238,F)
  for k,v in dict(DEFAULT,**case.get('fields',{})).items():m.write(*self._args(k,v))
  fans=case.get('fans',[(1,0x11111111)]*MAX_FANS)
  for i in range(MAX_FANS):
   flag,value=fans[i] if i<len(fans) else (1,0x11111111)
   m.write(F+36*i+0x1c,flag,1);m.write(F+36*i+0x20,value)
  serial=case.get('scratch',b'old-serial\0');m.mem[SERIAL:SERIAL+256]=b'\xa5'*256
  m.mem[SERIAL:SERIAL+len(serial)]=serial
  initial_backend=bytes(m.mem[B:B+0x1348]);initial_fans=bytes(m.mem[F:F+36*MAX_FANS])
  def state():return tuple(m.read(a,n) for a,n in FIELDS.values())+tuple(v for i in range(MAX_FANS) for v in (m.read(F+36*i+0x1c,1),m.read(F+36*i+0x20)))
  def mutate(values):
   for k,v in values.items():
    if k.startswith('fan.'):
     _,i,field=k.split('.');m.write(F+int(i)*36+(0x1c if field=='flag' else 0x20),v,1 if field=='flag' else 4)
    else:m.write(*self._args(k,v))
  def invoke(k,args=()):return sc.invoke(k,args,state,mutate)
  def step(mm,key):
   if key in (0x4f2d0,0x82d60):assert mm.r[0]==B+0x50;args=(0x50,0,0)
   elif key in (0x10ef3c,0xf8a30,0xfe300):args=(mm.r[0],0,0)
   elif key in (0x5a6108,0x5a66c4):
    assert F<=mm.r[0]<F+36*MAX_FANS and (mm.r[0]-F)%36==0
    args=((mm.r[0]-F)//36,0,0)
   elif key==0x49c98:
    assert mm.r[0]==B+0x10b4
    args=(mm.r[1],mm.r[2] if mm.r[1]==2004 else 0,mm.r[3] if mm.r[1]==2004 else 0)
   else:args=(0,0,0)
   mm.r[0]=invoke(hex(key),args)&MASK
  def stat(mm):
   assert mm.r[0] in (0x5e5089,0x5e5099)
   mm.r[0]=invoke('stat',('/config/stopped' if mm.r[0]==0x5e5089 else '/tmp/stopped',))&MASK
  def duplicate(mm):
   value=invoke('duplicate',(mm.r[0],));mm.r[0]=NEW if value else 0
  def psu(mm):
   assert mm.r[0]==B+0x108c
   mm.r[0]=invoke('psu',tuple(mm.r[1:4]))&MASK
  def serial_open(mm):
   assert mm.r[0]==0x5e6cf5 and mm.r[1]==0x5e6d04
   mm.r[0]=FILE if invoke('serial_open',('/config/serial','r')) else 0
  def serial_read(mm):
   assert mm.r[0]==FILE and mm.r[1]==0x5e6d06 and mm.r[2]==SERIAL
   rc=invoke('serial_read',('%255s',))
   if case.get('serial_write',True):
    payload=case.get('serial',b'EXAMPLE-135\0');assert len(payload)<=256
    m.mem[SERIAL:SERIAL+len(payload)]=payload
   mm.r[0]=rc&MASK
  def serial_close(mm):assert mm.r[0]==FILE;mm.r[0]=invoke('serial_close')&MASK
  def create(mm):
   assert tuple(mm.r[:4])==(B+0xff4,0,0x7bfc0,B)
   rc=invoke('thread',(0xff4,0x7bfc0))
   if case.get('thread_write',True):mm.write(B+0xff4,case.get('handle',0x76543210))
   mm.r[0]=rc&MASK
  def log(mm):
   line=mm.r[3];level=mm.read(mm.r[13]);a=b=0;text=None
   if line==201:
    a0=mm.read(mm.r[13]+8);assert a0==SERIAL
    text=bytes(m.mem[a0:a0+256]).split(b'\0',1)[0].decode('ascii')
   elif line==271:
    a=mm.read(mm.r[13]+8);a0=mm.read(mm.r[13]+12)
    assert a0 in (0x5e6d2b,0x5e6d30);text='lost' if a0==0x5e6d2b else 'ok'
   elif line==275:a,b=mm.read(mm.r[13]+8),mm.read(mm.r[13]+12)
   else:assert line in (253,7480,7495,7506,7513,7520,7526,7533),line
   invoke('log',(line,level,a,b,text));mm.r[0]=0
  hooks={k:(lambda mm,k=k:step(mm,k)) for k in SOURCES}
  hooks.update({0x59d97c:stat,0x5a38a0:duplicate,0x100fc4:psu,0x59e5b0:serial_open,
   0x59e958:serial_read,0x59e084:serial_close,0x5a55cc:create,0xfa0c4:log})
  extra_mutable=set()
  if augment:extra_mutable=augment(m,hooks,invoke) or set()
  rc=m.run(0x7755c if poll else 0x7409c,hooks=hooks,max_steps=200000)
  # No unreported backend/fan bytes may change. Callback mutations are fields.
  mutable=set(extra_mutable)
  for a,n in FIELDS.values():mutable.update(range(a,a+n))
  for i in range(MAX_FANS):mutable.update([F+36*i+0x1c]);mutable.update(range(F+36*i+0x20,F+36*i+0x24))
  for base,before in ((B,initial_backend),(F,initial_fans)):
   after=m.mem[base:base+len(before)]
   for i,(old,new) in enumerate(zip(before,after)):
    assert old==new or base+i in mutable,hex(base+i)
  return {'rc':None if poll else signed(rc),'state':state(),'events':sc.events,'steps':m.steps,'calls':sc.calls,'visited':len(m.visited)}
 @staticmethod
 def _args(k,v):
  a,n=FIELDS[k];return a,int(v)&((1<<(n*8))-1),n
