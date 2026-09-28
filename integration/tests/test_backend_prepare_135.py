#!/usr/bin/env python3
"""C vs original ARM preparation and fan poll. Only external effects scripted."""
import argparse,ctypes as C,json,random,sys,collections
from backend_prepare_135_oracle import *
U=C.c_uint32;I=C.c_int32;B8=C.c_uint8;V=C.c_void_p
class Limits(C.Structure):_fields_=[('word_14',U),('lower_30',I),('upper_34',I),('word_3c',I)]
class Profile(C.Structure):_fields_=[('word_1c',I),('fan_count',I),('fan_word_0c',I)]
class Fan(C.Structure):_fields_=[('byte_1c',B8),('word_20',I)]
class State(C.Structure):
 _fields_=[('limits',C.POINTER(Limits)),('profile',C.POINTER(Profile)),('fans',C.POINTER(Fan)),
 ('word_28',U),('word_2c',U),('word_1070',U),('byte_24',B8),('byte_fe5',B8),
 ('byte_104a',B8),('byte_85',B8),('byte_f4',B8),('byte_210',B8),('mode_50',U),
 ('word_68',I),('word_10c',I),('word_23c',I),('text_90',V),('text_fc8',V),
 ('platform_byte',C.POINTER(B8)),('thread_ff4',U)]
STEP=C.CFUNCTYPE(I,V,U,U,U,U);STAT=C.CFUNCTYPE(I,V,C.c_char_p)
DUP=C.CFUNCTYPE(V,V,V);PSU=C.CFUNCTYPE(I,V,I,I,U)
OPEN=C.CFUNCTYPE(V,V,C.c_char_p,C.c_char_p);READ=C.CFUNCTYPE(I,V,V,C.c_char_p,V)
CLOSE=C.CFUNCTYPE(I,V,V);THREAD=C.CFUNCTYPE(I,V,U,U,C.POINTER(U))
LOG=C.CFUNCTYPE(None,V,U,U,U,U,C.c_char_p)
class Ops(C.Structure):
 _fields_=[('step',STEP),('stat_path',STAT),('duplicate',DUP),('initialize_psu',PSU),
 ('serial_open',OPEN),('serial_read',READ),('serial_close',CLOSE),('thread_create',THREAD),('log',LOG)]
class Scratch(C.Structure):_fields_=[('serial',C.c_char*256)]
class Native:
 def __init__(self,path):
  self.lib=C.CDLL(str(path))
  self.lib.vn135_backend_prepare_135.argtypes=[C.POINTER(State),C.POINTER(Ops),V,C.POINTER(Scratch)]
  self.lib.vn135_backend_prepare_135.restype=I
  self.lib.vn135_backend_poll_fans_135.argtypes=[C.POINTER(State),C.POINTER(Ops),V]
  self.lib.vn135_backend_poll_fans_135.restype=None
 def run(self,case,poll=False,psu_initializer=None):
  s=State();l=Limits();profile=Profile();fans=(Fan*MAX_FANS)();platform=B8()
  s.limits=C.pointer(l);s.profile=C.pointer(profile);s.fans=fans;s.platform_byte=C.pointer(platform)
  scratch=Scratch();C.memset(C.addressof(scratch),0xa5,256)
  payload=case.get('scratch',b'old-serial\0');C.memmove(C.addressof(scratch),payload,len(payload))
  sc=Script(case);errors=[]
  lf={k for k,_ in Limits._fields_};pf={k for k,_ in Profile._fields_}
  def mutate(values):
   for k,v in values.items():
    if k.startswith('fan.'):
     _,i,field=k.split('.');setattr(fans[int(i)],'byte_1c' if field=='flag' else 'word_20',v)
    elif k=='platform':platform.value=v
    else:setattr(l if k in lf else profile if k in pf else s,k,v)
  mutate(dict(DEFAULT,**case.get('fields',{})))
  fdata=case.get('fans',[(1,0x11111111)]*MAX_FANS)
  for i in range(MAX_FANS):fans[i].byte_1c,fans[i].word_20=fdata[i] if i<len(fdata) else (1,0x11111111)
  def state():
   values=[]
   for k,(a,n) in FIELDS.items():
    v=platform.value if k=='platform' else getattr(l if k in lf else profile if k in pf else s,k)
    values.append(int(v or 0)&((1<<(8*n))-1))
   return tuple(values)+tuple(v for f in fans for v in (f.byte_1c,f.word_20&MASK))
  def invoke(k,args=()):return sc.invoke(k,args,state,mutate)
  def safe(fn):
   def wrap(*a):
    try:return fn(*a)
    except Exception as e:errors.append(e);return 0
   return wrap
  @safe
  def step(p,k,a,b,c):return invoke(hex(k),(a,b,c))
  @safe
  def stat(p,path):return invoke('stat',(path.decode(),))
  @safe
  def dup(p,ptr):return NEW if invoke('duplicate',(ptr or 0,)) else None
  @safe
  def psu(p,lo,hi,mode):
   rc=invoke('psu',(lo&MASK,hi&MASK,mode))
   return psu_initializer(lo,hi,mode) if psu_initializer else rc
  @safe
  def op(p,path,mode):return FILE if invoke('serial_open',(path.decode(),mode.decode())) else None
  @safe
  def rd(p,f,fmt,out):
   assert f==FILE;rc=invoke('serial_read',(fmt.decode(),))
   if case.get('serial_write',True):
    payload=case.get('serial',b'EXAMPLE-135\0');assert len(payload)<=256;C.memmove(out,payload,len(payload))
   return rc
  @safe
  def close(p,f):assert f==FILE;return invoke('serial_close')
  @safe
  def thread(p,field,entry,handle):
   rc=invoke('thread',(field,entry))
   if case.get('thread_write',True):handle[0]=case.get('handle',0x76543210)
   return rc
  @safe
  def log(p,line,level,a,b,text):invoke('log',(line,level,a,b,text.decode() if text is not None else None))
  refs=[STEP(step),STAT(stat),DUP(dup),PSU(psu),OPEN(op),READ(rd),CLOSE(close),THREAD(thread),LOG(log)]
  ops=Ops(*refs)
  if poll:self.lib.vn135_backend_poll_fans_135(C.byref(s),C.byref(ops),None);rc=None
  else:rc=self.lib.vn135_backend_prepare_135(C.byref(s),C.byref(ops),None,C.byref(scratch))
  if errors:raise errors[0]
  return {'rc':rc,'state':state(),'events':sc.events,'calls':sc.calls}
def cases():
 yield 'baseline',{},False
 # All Boolean/negative/noncanonical outcomes at each early-return boundary.
 for key in ['0x4f2d0','0xb86d0','0xb9148','0x82d60','psu','stat','duplicate',
             'serial_open','serial_read','serial_close','0xf96a0','0xb4c58',
             '0xf8b60','0xf8a30','0x10ef3c','0xa1fe0','thread','0x49c98','0x5e92c']:
  for value in [-2147483648,-9,-1,0,1,2,255,256,2147483647]:
   yield 'external_returns',{'returns':{key:value},'fields':{'byte_85':1}},False
 for flag in [0,1,2,255]:
  for f4 in [0,1,2,255]:
   for mode in [0,1,2,3,0x80000000,0xffffffff]:
    yield 'flags_modes',{'fields':{'byte_85':flag,'byte_f4':f4,'mode_50':mode},'returns':{'0xb86d0':1}},False
 for requested in [0,1,1499,1500,1501,8999,9000,9001,2147483647,0x80000000,0xffffffff]:
  for cap in [0,1,1499,1500,1501,9000,2147483647,0x80000000,0xffffffff]:
   yield 'limit_order',{'fields':{'word_10c':requested,'word_3c':cap,'word_1c':0xffffffff}},False
 for count in [-2,-1,0,1,2,8]:
  for required in [-1,0,1,2,8]:
   for rpm in [-1,0,999,1000,1001,4000]:
    yield 'fan_paths',{'fields':{'fan_count':count,'word_68':required},'returns':{'0xfe300':rpm}},False
 for scale in [-1,0,9,10,11,2147483647]:
  for first in [-2147483648,-1,0,1,999,1000,1001]:
   for second in [-2147483648,-1,0,1,2999,3000,3001,2147483647]:
    for flag in [0,1,255]:
     yield 'poll_reads',{'fields':{'fan_count':1,'word_23c':0x7fffffff},'fans':[(flag,0)],'returns':{'0xfe2f0':scale,'0xfe300':[first,second]}},True
 for threshold in [-2147483648,-1,0,1,715827882,715827883,2147483647]:
  for first in [-1,0,1,2147483647]:
   yield 'poll_wrap',{'fields':{'fan_count':1,'fan_word_0c':threshold,'word_23c':0x80000000},'fans':[(0,0)],'returns':{'0xfe300':[first,0]}},True
 for delay in [0,1,13,14]:
  yield 'arrival_on_poll',{'fields':{'fan_count':1,'word_68':1},'returns':{'0xfe300':[0]*(2*delay)+[1200]}},False
 for write in [False,True]:
  for rc in [-1,0,1,2]:
   yield 'serial_scratch',{'serial_write':write,'returns':{'serial_read':rc}},False
   yield 'thread_scratch',{'thread_write':write,'returns':{'thread':rc}},False
 yield 'max_serial',{'serial':b'a'*255+b'\0'},False
 # Values may change at explicit, synchronous callback boundaries.
 for at,nth,fields in [
   ('0x4f2d0',0,{'byte_f4':1,'word_28':17}),
   ('0xb9148',0,{'byte_f4':2,'word_10c':1200}),
   ('psu',0,{'word_10c':1600,'word_3c':1000}),
   ('0x5a6108',0,{'fan.0.flag':0}),
   ('0x5a66c4',0,{'word_23c':0}),
   ('0x10ef3c',0,{'word_23c':2}),
   ('0xfe300',0,{'fan_word_0c':900}),
   ('0xfe2f0',0,{'fan_word_0c':100}),
   ('0x5a66c4',2,{'fan.0.flag':1}),
   ('log',2,{'word_68':3}),
 ]:
  yield 'mutations',{'fields':{'byte_85':1},'returns':{'0xb86d0':1},'mutate':[{'at':at,'nth':nth,'fields':fields}]},False
 rng=random.Random(0x7409c)
 for _ in range(128):
  count=rng.randrange(5)
  yield 'mixed',{'fields':{'fan_count':count,'word_68':rng.randrange(5),'word_23c':rng.randrange(5),'word_10c':rng.getrandbits(32),'mode_50':rng.randrange(4)},'fans':[(rng.choice([0,1,2,255]),rng.getrandbits(32)) for i in range(MAX_FANS)],'returns':{'0xfe300':[rng.choice([-1,0,1,999,1000,3001]) for i in range(10)],'0xfe2f0':rng.randrange(15),'stat':rng.choice([-1,0]),'psu':rng.choice([0,0,0,-1])}},False
def main():
 parser=argparse.ArgumentParser();parser.add_argument('library');parser.add_argument('--summary');args=parser.parse_args()
 oracle=Oracle();native=Native(Path(args.library).resolve());counts=collections.Counter();events=0;visited=0
 for n,(group,case,poll) in enumerate(cases()):
  a=oracle.run(case,poll);b=native.run(case,poll)
  try:
   for k in ('rc','state','events','calls'):assert a[k]==b[k],k
  except AssertionError as e:
   print('FAIL',n,group,json.dumps(case),'poll',poll,'key',str(e))
   if a['state']!=b['state']:print('state',a['state'],b['state'])
   for i,(x,y) in enumerate(zip(a['events'],b['events'])):
    if x!=y:print('event',i,'ARM',x,'C',y);break
   print('events',len(a['events']),len(b['events']));raise
  counts[group]+=1;events+=len(a['events']);visited=max(visited,a['visited'])
 out={'total':sum(counts.values()),'counts':dict(counts),'compared_events':events,'max_visited_instruction_addresses':visited,'new_arm_opcodes':0,'fan_poll_body_executed':True,'psu_body':'explicit boundary in this suite','hardware_io':False,'real_threads':False}
 if args.summary:Path(args.summary).write_text(json.dumps(out,indent=2)+'\n')
 print('BACKEND_PREPARE135_ORIGINAL_PASS',json.dumps(out,sort_keys=True))
if __name__=='__main__':main()
