#!/usr/bin/env python3
"""Compare the complete bounded resume caller with compiled C and actual power helper."""
import argparse,ctypes as C,itertools,json,random,struct
from pathlib import Path
from backend_resume_135_oracle import (ResumeOracle,Script,FIELDS,DEFAULT_FIELDS,
 MAX_CHAINS,MAX_ITEMS,STEP_IDS,NEW,MASK)
u8=C.c_uint8;u32=C.c_uint32;i32=C.c_int32;up=C.c_size_t
class PowerState(C.Structure):_fields_=[('byte_ff1',u8),('word_20c',u32)]
class Item(C.Structure):_fields_=[('word_3c',u32),('word_44',u32)]
class Chain(C.Structure):_fields_=[('word_20',u32),('byte_24',u8),('items',C.POINTER(Item))]
class Description(C.Structure):
 _fields_=[('word_10',u32),('board_word_10',u32),('table_count',i32),
           ('table_types',C.POINTER(u32)),('chip_selector',u32),('chip_word_2c',u32)]
class State(C.Structure):
 _fields_=[('power',PowerState),('description',C.POINTER(Description)),('chains',C.POINTER(Chain)),
  ('word_20',u32),('word_dc',u32),('limit_34',u32),('word_d4',i32),
  ('byte_24',u8),('byte_85',u8),('byte_ec',u8),('byte_1054',u8),('platform_byte',C.POINTER(u8)),
  ('double_28',C.c_double),('text_90',C.c_void_p),('text_fc8',C.c_void_p),
  ('thread_1050',up),('thread_1044',up),('thread_101c',up),('thread_1014',up)]
STEP=C.CFUNCTYPE(i32,C.c_void_p,C.c_int,u32,u32,u32)
CREATE=C.CFUNCTYPE(i32,C.c_void_p,u32,u32,C.POINTER(up))
JOIN=C.CFUNCTYPE(i32,C.c_void_p,up,C.POINTER(up))
DUP=C.CFUNCTYPE(C.c_void_p,C.c_void_p,C.c_void_p)
FREE=C.CFUNCTYPE(None,C.c_void_p,C.c_void_p)
TIME=C.CFUNCTYPE(C.c_double,C.c_void_p)
LOG=C.CFUNCTYPE(None,C.c_void_p,u32,u32,u32,u32)
class Ops(C.Structure):
 _fields_=[('step',STEP),('thread_create',CREATE),('thread_join',JOIN),('duplicate',DUP),
           ('release',FREE),('timestamp',TIME),('log',LOG)]
P0=C.CFUNCTYPE(i32,C.c_void_p);P16=C.CFUNCTYPE(i32,C.c_void_p,C.c_uint16)
P32=C.CFUNCTYPE(i32,C.c_void_p,u32);PLOG=C.CFUNCTYPE(None,C.c_void_p,C.c_int,u32,u32)
class PowerOps(C.Structure):
 _fields_=[('psu_on',P0),('psu_off',P0),('set_voltage',P16),('chain_count',P0),
           ('reset_chain',P32),('log',PLOG)]

class Native:
 def __init__(self,lib):
  self.lib=C.CDLL(str(Path(lib).resolve()));self.f=self.lib.vn135_backend_resume_135
  self.f.argtypes=[C.POINTER(State),C.POINTER(Ops),C.POINTER(PowerOps),C.c_void_p,C.POINTER(up)]
  self.f.restype=i32
 def run(self,case):
  self.case=case;self.script=Script(case);self.errors=[]
  self.types=(u32*MAX_ITEMS)(*case.get('types',[0,4,0,4,7]))
  self.d=Description(0,0,0,self.types,0,0)
  self.items=[(Item*MAX_ITEMS)(*(Item(1000+i*10+j,0x87650000+i*10+j)
                                for j in range(MAX_ITEMS))) for i in range(MAX_CHAINS)]
  flags=case.get('chains',[(1,1)]*MAX_CHAINS)
  self.chains=(Chain*MAX_CHAINS)(*(Chain(a,b,self.items[i]) for i,(a,b) in enumerate(flags)))
  self.platform=u8(0xa5);self.s=State()
  self.s.description=C.pointer(self.d);self.s.chains=self.chains
  self.s.platform_byte=C.pointer(self.platform);self.s.double_28=case.get('old_time',-99.25)
  self.mutate(DEFAULT_FIELDS);self.mutate(case.get('fields',{}))
  def invoke(key,*args):return self.script.invoke(key,args,self.snapshot,self.mutate)
  def guarded(fn,fallback=0):
   def wrap(*args):
    try:return fn(*args)
    except Exception as e:self.errors.append(e);return fallback
   return wrap
  def step(p,key,a,b,c):return invoke(key,a,b,c)
  def create(p,offset,entry,out):
   rc=invoke('create',offset,entry)
   if case.get('create_write',True) and (rc==0 or case.get('create_error_write',False)):
    out[0]=0x60000000+offset
   return rc
  def join(p,handle,out):
   rc=invoke('join',handle)
   if case.get('join_write',True):out[0]=case.get('join_value',0)
   return rc
  def duplicate(p,text):invoke('duplicate',text or 0);return case.get('duplicate_value',NEW)
  def free(p,text):invoke('release',text or 0)
  def timestamp(p):invoke('time');return case.get('new_time',12345.125)
  def log(p,line,level,a,b):invoke('log',line,level,a,b)
  def on(p):return invoke('on')
  def off(p):raise AssertionError('OFF must not be invented by resume')
  def voltage(p,v):return invoke('setter',v)
  def power_count(p):raise AssertionError('Unexpected power chain count')
  def reset(p,i):raise AssertionError('Unexpected power reset')
  def plog(p,source,line,arg):invoke('power_log',source,line,arg)
  self.ops=Ops(STEP(guarded(step)),CREATE(guarded(create)),JOIN(guarded(join)),
   DUP(guarded(duplicate)),FREE(guarded(free)),TIME(guarded(timestamp,0.0)),LOG(guarded(log)))
  self.powerops=PowerOps(P0(guarded(on)),P0(guarded(off)),P16(guarded(voltage)),
                         P0(guarded(power_count)),P32(guarded(reset)),PLOG(guarded(plog)))
  scratch=up(case.get('join_seed',0))
  rc=self.f(C.byref(self.s),C.byref(self.ops),C.byref(self.powerops),None,C.byref(scratch))
  if self.errors:raise self.errors[0]
  return rc,self.snapshot(),scratch.value,self.script.events
 def mutate(self,fields):
  for key,val in fields.items():
   if key=='platform':self.platform.value=val
   elif key=='power_on':self.s.power.byte_ff1=val
   elif key=='power_word':self.s.power.word_20c=val
   elif key in ('model_word10','board_word10','table_count','selector','chip_word2c'):
    setattr(self.d,{'model_word10':'word_10','board_word10':'board_word_10','table_count':'table_count',
                   'selector':'chip_selector','chip_word2c':'chip_word_2c'}[key],val)
   else:setattr(self.s,key,val)
 def snapshot(self):
  vals=[]
  for key,(_,n) in FIELDS.items():
   if key=='platform':v=self.platform.value
   elif key=='power_on':v=self.s.power.byte_ff1
   elif key=='power_word':v=self.s.power.word_20c
   elif key in ('model_word10','board_word10','table_count','selector','chip_word2c'):
    v=getattr(self.d,{'model_word10':'word_10','board_word10':'board_word_10','table_count':'table_count',
                    'selector':'chip_selector','chip_word2c':'chip_word_2c'}[key])
   else:v=getattr(self.s,key)
   vals.append((v or 0)&((1<<(8*n))-1))
  return (tuple(vals),int.from_bytes(struct.pack('<d',self.s.double_28),'little'),
          tuple((self.chains[i].word_20,self.chains[i].byte_24,
                 tuple((v.word_3c,v.word_44) for v in self.items[i])) for i in range(MAX_CHAINS)))

def cases():
 yield 'baseline',{}
 for state in (0,1,2,3,4,5,6,255,0x80000000,MASK):yield 'state',{'fields':{'word_20':state}}
 for rc in (0,1,2,-1,-2147483648):
  for flag in (0,1,255):
   for apply in (0,-1,2):
    yield 'precheck',{'fields':{'byte_85':flag},'returns':{0xb86d0:rc,0x4f0a0:apply,0x8291c:1}}
 for pool in (0,1,2,-1):
  for lock in (0,1,16,-1):yield 'gate',{'returns':{0x34920:pool,0x5a6684:lock}}
 for sel in (0,1,2,3,4,5,6,7,8,255,0x80000006,MASK):
  for mode in (0,1,2,255,256,MASK):
   for platform in (0,1,2,3,-1):
    yield 'route',{'fields':{'selector':sel},'returns':{0x82d60:mode,0xfdfbc:platform}}
 for op in STEP_IDS+['on','setter']:
  for rc in (-1,1,2,7,-2147483648):
   if op in (0xfe668,0x59c09c):continue
   yield 'failures',{'returns':{op:rc,0x8291c:1},'fields':{'byte_85':1}}
 for fail in (0,1,2):
  for rc in (-1,1,11):
   for write in (False,True):
    yield 'thread_create',{'returns':{'create':[0]*fail+[rc]},'create_error_write':write}
 for flag,seed,write,value,rc in itertools.product((0,1,255),(0,0x1234),(False,True),(0,123),(-1,0,11)):
  yield 'thread_join',{'fields':{'byte_1054':flag},'join_seed':seed,'join_write':write,
                      'join_value':value,'returns':{'join':rc}}
 for d4 in (-2147483648,-1,0,1,2,7,2147483647):
  for rv in (0,1,2147483647,-1,-2147483648):
   yield 'delay',{'fields':{'word_d4':d4},'returns':{0x59c09c:rv}}
 for base,limit in itertools.product((0,1,65535,65536,0x7fffffff,0x80000000,MASK),(0,15000,65535,0x7fffffff,MASK)):
  for selector,flag in ((4,0),(5,0),(5,1)):
   yield 'power_value',{'fields':{'word_dc':base,'limit_34':limit,'selector':selector,'byte_ec':flag}}
 for count,table in itertools.product((-2,0,1,2,3,4),(-1,0,1,3,5)):
  for state in (0,1,2,3,4,5,6,7,MASK):
   yield 'chain_state',{'fields':{'table_count':table},'chains':[(state,255),(state,0),(state,1),(state,2)],
                       'returns':{0xfe668:count}}
 for tt in ([4,4,4,4,4],[0,0,0,0,0],[0,0,0,0,4],[3,4,5,4,7]):yield 'table_order',{'types':tt,'fields':{'table_count':5}}
 for ptr in (0,0x849100):
  for dup in (0,NEW):yield 'string_lifetime',{'fields':{'text_fc8':ptr},'duplicate_value':dup}
 # Callbacks expose load order and cached versus reread fields, synchronously.
 for at,fields in [(0x59c09c,{'word_d4':13}),(0xb9148,{'word_20':4}),
  (0x106e58,{'word_dc':0x10001,'selector':5}),('on',{'word_dc':1}),
  (0x6f550,{'text_fc8':0}),('release',{'text_90':0x849100}),
  (0x6f6f4,{'selector':7}),(0x66504,{'byte_ec':255}),
  (0xfe668,{'table_count':5})]:
  yield 'boundary_mutation',{'fields':{'word_d4':7,'byte_85':1},'returns':{0xb86d0:1},
                            'mutate':[{'at':at,'fields':fields}]}
 # Cached table_count before the second count callback, not its new value.
 yield 'cached_count',{'returns':{0xfe668:[1,4,2,0]},
                       'mutate':[{'at':0xfe668,'nth':1,'fields':{'table_count':1}}]}
 rng=random.Random(0x13570e30)
 for _ in range(200):
  op=rng.choice(STEP_IDS[8:]);returns={0x82d60:rng.choice([0,1,256]),0xfe668:rng.randrange(5)}
  if op not in (0xfe668,0x59c09c):returns[op]=rng.choice([-1,0,1,2])
  yield 'mixed',{'fields':{'selector':rng.randrange(9),'table_count':rng.randrange(6),
                        'byte_ec':rng.randrange(256)},'returns':returns,
                'chains':[(rng.choice([0,1,3,4,5,6,MASK]),rng.choice([0,1,255])) for _ in range(MAX_CHAINS)]}

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--limit',type=int)
 a=ap.parse_args();native=Native(a.library);oracle=ResumeOracle();counts={};events=0;visited=set()
 for number,(category,case) in enumerate(cases()):
  if a.limit is not None and number>=a.limit:break
  expected=oracle.run(case);actual=native.run(case)
  if expected[:4]!=actual:
   out=Path(a.summary or 'resume_failure.json').with_suffix('.failure.json')
   out.parent.mkdir(parents=True,exist_ok=True)
   out.write_text(json.dumps({'number':number,'category':category,'case':case,'expected':expected[:4],'actual':actual},indent=2))
   if expected[3]!=actual[3]:
    for i,(x,y) in enumerate(itertools.zip_longest(expected[3],actual[3])):
     if x!=y:print('FIRST_EVENT',i,str(x)[:800],str(y)[:800]);break
   raise AssertionError(f'resume mismatch #{number} {category}; {out}')
  counts[category]=counts.get(category,0)+1;events+=len(actual[3]);visited|=expected[4]
 result={'cases':counts,'total':sum(counts.values()),'compared_events':events,
  'visited_instruction_addresses':len(visited),'reference_sha256':oracle.hash,
  'original_power_entry_executed':True,'cold_initialization_recovered':False,
  'unresolved_callees':'explicit scripted callbacks','hardware_io':False,'new_arm_opcodes':0}
 print('BACKEND_RESUME135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
 if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
