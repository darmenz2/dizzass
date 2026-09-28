#!/usr/bin/env python3
"""Execute the four unchanged A32 entries against the C handlers, no hardware.
The decision body and its two predicates/getters run as original instructions.
OS calls and not-yet-ported reset/stop/config effects are explicit scripts.
"""
import argparse, collections, ctypes as C, hashlib, itertools, json, math, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
import test_general_monitor_135 as G
I=C.c_int32;U=C.c_uint32;B=C.c_uint8;P=C.c_void_p;D=C.c_double;S=C.c_char_p
class Power(C.Structure):_fields_=[('byte_ff1',B),('word_20c',U)]
class Profile(C.Structure):_fields_=[('key',S),('label',S)]
class Profiles(C.Structure):_fields_=[('entries',C.POINTER(Profile)),('count',I)]
HF={'minimum_chains_f8':(0xf8,I,4),'partial_chains_105':(0x105,B,1),'warmup_e4':(0xe4,B,1),'warmup_done_22c':(0x22c,B,1),'lower_preset_95':(0x95,B,1),'minimum_enabled_b0':(0xb0,B,1)}
class State(C.Structure):
 _fields_=[('general',C.POINTER(G.State)),('power',C.POINTER(Power)),('profiles',C.POINTER(Profiles)),('current_preset_fc8',S),('minimum_preset_b8',S)]+[(k,t) for k,(_,t,_) in HF.items()]
CALL=C.CFUNCTYPE(I,P,U,U,U);NOW=C.CFUNCTYPE(D,P);COLLECT=C.CFUNCTYPE(I,P,C.POINTER(I));RESET=C.CFUNCTYPE(I,P,U,U,U);SET=C.CFUNCTYPE(I,P,S,S);LOG=C.CFUNCTYPE(None,P,U,U,U,U,S)
class Ops(C.Structure):_fields_=[('call',CALL),('now',NOW),('collect',COLLECT),('reset',RESET),('set',SET),('log',LOG)]
BASE=G.BASE;MODEL=G.MODEL;CHAINS=G.CHAINS;TABLE=0x847000;TEXT=0x848000
GF=['state','mode','target_temperature','running','active','started_at']
SF={'current_preset_fc8':0xfc8,'minimum_preset_b8':0xb8}
ENTRIES={'check':0x60730,'decision':0x60a2c,'warmup':0x60d58,'preset':0x5e53c}
FUNCTIONS={'check':'vn135_monitor_check_chains_135','decision':'vn135_monitor_chain_decision_135','warmup':'vn135_monitor_finish_warmup_135','preset':'vn135_monitor_lower_preset_135'}
NAMES={0xfe668:'count',0x49c98:'event',0x5e92c:'stop',0xfdfbc:'platform',0x5a6684:'trylock',0x5a66c4:'unlock',0x10ef3c:'delay',0x5a48a0:'push',0x5a48a8:'pop'}
RANGES=((0x60730,0x609dc),(0x60a2c,0x60d20),(0x60d58,0x60fd4),(0x5e53c,0x5e8d8),(0x56fcc,0x57028),(0x57030,0x57084),(0xa720c,0xa7218),(0xa71e8,0xa71f4),(0x5a24d4,0x5a2544))
LOGS={2167:0x5e5296,2173:0x5e52b0,445:0x5e6030,451:0x5e607a,2737:0x5e52c2,2740:0x5e52c2,2084:0x5e51e7,2065:0x5e5fe9,2067:0x5e6010}
DEFAULTS=dict(minimum_chains_f8=2,partial_chains_105=0,warmup_e4=1,warmup_done_22c=0,lower_preset_95=1,minimum_enabled_b0=0)
def choose(p,key,n,default):
 v=p.get(key,default);return v[min(n,len(v)-1)] if isinstance(v,list) else v
def enc(v):return None if v is None else v.encode()
def text(v):return v.decode() if v is not None else None
class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  assert any(a<=pc<b for a,b in RANGES),('unapproved code',hex(pc))
  self.visited.add(pc);return super().extra_instruction(w,pc)
class Script:
 def __init__(self,p,mutate,snapshot):self.p=p;self.mutate=mutate;self.snapshot=snapshot;self.events=[];self.counts=collections.Counter()
 def call(self,name,*args):
  n=self.counts[name];self.counts[name]+=1
  self.events.append((name,*args,self.snapshot()))
  for op,which,k,v in self.p.get('mutations',[]):
   if name==op and which==n:self.mutate(k,v)
  defaults={'count':self.p.get('count',3),'platform':4,'now':100.0,'trylock':0}
  v=choose(self.p.get('returns',{}),name,n,defaults.get(name,0))
  if name=='trylock' and n>32:raise AssertionError('non-completing scripted lock')
  return v

def setup(p):
 q=dict(p);q['running']=p.get('running',1)
 gs,model,hist,chains,sensors,fans,rate,scratch=G.setup(q)
 power=Power(p.get('power_on',1),p.get('voltage',13500))
 profile_values=p.get('profiles',(('100','Low'),('200','Medium'),('300','High'),('400','Top')))
 records=(Profile*len(profile_values))(*[Profile(enc(k),enc(v)) for k,v in profile_values]);profiles=Profiles(records,len(records))
 state=State(C.pointer(gs),C.pointer(power),C.pointer(profiles),enc(p.get('current_preset_fc8','300')),enc(p.get('minimum_preset_b8','100')))
 for k,v in DEFAULTS.items():setattr(state,k,p.get(k,v))
 keep=(gs,model,hist,chains,sensors,fans,rate,scratch,power,records,profiles)
 return state,keep

class Native:
 def __init__(self,lib):
  self.functions={}
  for k,n in FUNCTIONS.items():
   f=getattr(lib,n);f.argtypes=[C.POINTER(State),C.POINTER(Ops),P];f.restype=I if k=='decision' else None;self.functions[k]=f
 def run(self,entry,p):
  s,keep=setup(p);g,model,hist,chains,_,_,_,_,power,records,profiles=keep;errors=[];callbacks=[];strings=[]
  def snap():return tuple(G.bits(getattr(g,k)) if k=='started_at' else getattr(g,k) for k in GF),tuple(getattr(s,k) for k in HF),power.byte_ff1,power.word_20c,model.query_fault_87,tuple((c.thermal.state,c.thermal.present) for c in chains),tuple(text(getattr(s,k)) for k in SF),tuple((text(x.key),text(x.label)) for x in records)
  def mutate(k,v):
   if k in GF:setattr(g,k,v)
   elif k in HF:setattr(s,k,v)
   elif k=='voltage':power.word_20c=v
   elif k=='power_on':power.byte_ff1=v
   elif k=='query_fault_87':model.query_fault_87=v
   elif k=='chain_state':chains[v[0]].thermal.state=v[1]
   elif k=='chain_present':chains[v[0]].thermal.present=v[1]
   elif k in SF:strings.append(enc(v));setattr(s,k,strings[-1])
   elif k in ('profile_key','profile_label'):
    strings.append(enc(v[1]));setattr(records[v[0]],k[8:],strings[-1])
   else:raise ValueError(k)
  sc=Script(p,mutate,snap)
  def cb(t,f):
   def fn(*args):
    try:return f(*args)
    except BaseException as e:errors.append(e);return 0.0 if t==NOW else 0
   callback=t(fn);callbacks.append(callback);return callback
  def collect(_,out):
   n=sc.counts['collect'];rc=sc.call('collect');value=choose(p,'collected',n,70)
   assert value is not None or rc!=0,'success requires initialized temperature'
   if value is not None:out[0]=value
   return rc
  ops=Ops(cb(CALL,lambda _,e,a,b:sc.call(NAMES[e],a,b)),cb(NOW,lambda _:sc.call('now')),cb(COLLECT,collect),cb(RESET,lambda _,e,m,v:sc.call('reset',e,m,v)),cb(SET,lambda _,k,v:sc.call('set',text(k),text(v))),cb(LOG,lambda _,l,lev,a,b,d:sc.call('log',l,lev,a,b,text(d))))
  results=[]
  for _ in range(p.get('laps',1)):results.append(self.functions[entry](C.byref(s),C.byref(ops),None))
  if errors:raise errors[0]
  return results,snap(),sc.events

class Original:
 def __init__(self,elf):self.machine=Machine(elf);self.steps=0;self.visited=set()
 def run(self,entry,p):
  s,keep=setup(p);g,model,_,chains,_,_,_,_,power,records,profiles=keep;m=self.machine
  m.mem[BASE:BASE+0x10000]=bytes(0x10000);m.reset((BASE,));m.visited=set();pool=[TEXT]
  def puttext(v):
   if v is None:return 0
   data=v.encode()+b'\0';a=pool[0];pool[0]+=len(data)+8;assert pool[0]<BASE+0x10000
   m.mem[a:a+len(data)]=data;return a
  def string(a):
   if a==0:return None
   end=m.mem.find(0,a,a+512);assert end>=a,(hex(a),'unterminated')
   m.check(a,end-a+1);return m.mem[a:end].decode()
  m.write(BASE+0x18,MODEL);m.write(BASE+0x230,CHAINS);m.write(MODEL+0xdc,TABLE);m.write(MODEL+0xe0,profiles.count)
  for k in GF:
   off,n=G.OFF[k];v=getattr(g,k);m.write(BASE+off,int.from_bytes(G.bits(v),'little') if n==8 else v,n)
  for k,(off,_,n) in HF.items():m.write(BASE+off,getattr(s,k),n)
  m.write(BASE+0xff1,power.byte_ff1,1);m.write(BASE+0x20c,power.word_20c);m.write(MODEL+0x87,model.query_fault_87,1)
  for i,c in enumerate(chains):m.write(CHAINS+i*800+0x20,c.thermal.state);m.write(CHAINS+i*800+0x24,c.thermal.present,1)
  for k,off in SF.items():m.write(BASE+off,puttext(text(getattr(s,k))))
  for i,rec in enumerate(records):m.write(TABLE+i*24,puttext(text(rec.key)));m.write(TABLE+i*24+4,puttext(text(rec.label)))
  def gv(k):
   off,n=G.OFF[k];v=m.read(BASE+off,n)
   return v.to_bytes(8,'little') if n==8 else signed(v) if k=='target_temperature' else v
  def snap():return tuple(gv(k) for k in GF),tuple(signed(m.read(BASE+off,n)) if t==I else m.read(BASE+off,n) for _,(off,t,n) in HF.items()),m.read(BASE+0xff1,1),m.read(BASE+0x20c),m.read(MODEL+0x87,1),tuple((m.read(CHAINS+i*800+0x20),m.read(CHAINS+i*800+0x24,1)) for i in range(3)),tuple(string(m.read(BASE+off)) for off in SF.values()),tuple((string(m.read(TABLE+i*24)),string(m.read(TABLE+i*24+4))) for i in range(len(records)))
  def mutate(k,v):
   if k in GF:
    off,n=G.OFF[k];m.write(BASE+off,int.from_bytes(G.bits(v),'little') if n==8 else v,n)
   elif k in HF:off,_,n=HF[k];m.write(BASE+off,v,n)
   elif k=='voltage':m.write(BASE+0x20c,v)
   elif k=='power_on':m.write(BASE+0xff1,v,1)
   elif k=='query_fault_87':m.write(MODEL+0x87,v,1)
   elif k=='chain_state':m.write(CHAINS+v[0]*800+0x20,v[1])
   elif k=='chain_present':m.write(CHAINS+v[0]*800+0x24,v[1],1)
   elif k in SF:m.write(BASE+SF[k],puttext(v))
   elif k in ('profile_key','profile_label'):m.write(TABLE+v[0]*24+(4 if k=='profile_label' else 0),puttext(v[1]))
   else:raise ValueError(k)
  sc=Script(p,mutate,snap);pushes=[]
  def ret(v=0):m.r[0]=int(v)&0xffffffff
  def simple(name):
   def f(_):
    a=b=0
    if name in ('trylock','unlock'):assert m.r[0]==BASE+0x1074;a=0x1074
    elif name=='delay':a=m.r[0]
    elif name=='event':assert m.r[0]==BASE+0x10b4;a=m.r[1]
    elif name=='stop':assert m.r[0]==BASE
    elif name=='push':
     assert m.r[1]==0x5cf34 and m.r[2]==BASE;pushes.append(m.r[0]);a=m.r[1]
    elif name=='pop':assert pushes.pop()==m.r[0] and m.r[1]==0
    ret(sc.call(name,a,b))
   return f
  hooks={addr:simple(name) for addr,name in NAMES.items()}
  def now(_):m.set_d(0,float(sc.call('now')))
  def collect(_):
   assert m.r[0]==BASE;out=m.r[1];n=sc.counts['collect'];rc=sc.call('collect');value=choose(p,'collected',n,70)
   assert value is not None or rc!=0
   if value is not None:m.write(out,value)
   ret(rc)
  def reset(addr):
   def f(_):assert m.r[0]==BASE and m.r[1]==0;ret(sc.call('reset',addr,m.r[1],m.r[2]))
   return f
  def log(_):
   line=m.r[3];sp=m.r[13];assert m.r[2] in (0x5e50be,0x5e50e3),(hex(m.r[2]),line);assert m.read(sp+4)==LOGS[line],(line,hex(m.read(sp+4)))
   a=m.read(sp+8) if line==451 else 0;b=m.read(sp+12) if line==451 else 0;detail=string(m.read(sp+8)) if line in (2084,2065,2067) else None
   ret(sc.call('log',line,m.read(sp),a,b,detail))
  def compare(_):
   a,b=string(m.r[0]),string(m.r[1]);assert a is not None and b is not None;ret((a>b)-(a<b))
  def setprofile(_):assert m.r[0]==0x5e5fff;ret(sc.call('set','autotune-profile',string(m.r[1])))
  hooks.update({0x1ed58:now,0x5db54:collect,0x6100c:reset(0x6100c),0x61170:reset(0x61170),0xfa0c4:log,0x5a375c:compare,0x509b4:setprofile})
  results=[]
  for _ in range(p.get('laps',1)):
   m.reset((BASE,));m.run(ENTRIES[entry],hooks=hooks,max_steps=30000);self.steps+=m.steps
   results.append(signed(m.r[0]) if entry=='decision' else None)
  assert not pushes;self.visited|=m.visited
  return results,snap(),sc.events

def cases():
 for entry in ENTRIES:yield entry,'baseline',{}
 for entry in ('check','decision'):
  for count,states,present,flag,partial,minimum in itertools.product((-1,0,1,2,3),((2,2,2),(2,3,2),(2,5,2),(3,3,3),(5,5,5),(0,1,6),(0xffffffff,4,2)),(0,1,255),(0,1),(0,1),(-1,0,2,3,4)):
   yield entry,'chain_policy',dict(count=count,chain_states=list(states),present=[present],query_fault_87=flag,partial_chains_105=partial,minimum_chains_f8=minimum)
 for state,running in itertools.product((0,1,2,3,4,5,6,0xffffffff),(0,1,255)):
  yield 'check','outer_gate',dict(state=state,running=running,present=[0])
 for first,second,third in itertools.product((-1,0,1,4,5,6),(0,4,5),(0,4,5)):
  yield 'warmup','platform_reread',dict(returns={'platform':[first,second,third]})
 for state,mode,active,e4,done in itertools.product((0,1,2,3,4,5,0xffffffff),(0,1,2),(0,1,255),(0,1),(0,1,255)):
  yield 'warmup','warmup_gates',dict(state=state,mode=mode,active=active,warmup_e4=e4,warmup_done_22c=done)
 for clock in (-100.0,0.0,math.nextafter(900.0,-math.inf),900.0,math.nextafter(900.0,math.inf),901.0):
  for start in (0.0,1.0,900.0):yield 'warmup','time_boundary',dict(started_at=start,returns={'now':clock})
 for target,value,rc in itertools.product((-2147483648,-1,0,70,2147483647),(-2147483648,-1,0,69,70,71,2147483647),(-1,0,1)):
  yield 'warmup','temperature_boundary',dict(target_temperature=target,collected=value,returns={'collect':rc})
 for tries,rc,platform,voltage in itertools.product((0,1,2,4),(-1,0,1),(0,1,5),(0,1,65535,0xffffffff)):
  yield 'warmup','lock_failure',dict(voltage=voltage,returns={'trylock':[16]*tries+[0],'reset':rc,'platform':[4,platform]})
 yield 'warmup','untouched_error_output',dict(collected=None,returns={'collect':-1})
 for table,current,minimum,enabled,lower in itertools.product(((),(('0','Only'),),(('9','Nine'),('10','Ten'),('11','Eleven')),(('300','First'),('200','Second'),('300','Last'))),('0','9','10','11','200','300','missing',None),(None,'0','9','10','100','-1'),(0,1),(0,1)):
  yield 'preset','preset_selection',dict(profiles=table,current_preset_fc8=current,minimum_preset_b8=minimum,minimum_enabled_b0=enabled,lower_preset_95=lower)
 for previous,minimum in itertools.product(('2147483647','-2147483648',' +009tail',' \t-10.0','abc','0','99'),('2147483647','-2147483648','+9','-10','abc','0','100')):
  yield 'preset','atoi_boundary',dict(profiles=((previous,'Previous'),('current','Current')),current_preset_fc8='current',minimum_preset_b8=minimum,minimum_enabled_b0=1)
 for entry in ENTRIES:
  for laps in (2,3):yield entry,'repeat_entry',dict(laps=laps,present=[0] if entry=='check' else [1])
 changes=dict(state=0,mode=1,running=0,active=0,target_temperature=80,started_at=1000.0,query_fault_87=1,minimum_chains_f8=0,partial_chains_105=1,warmup_e4=0,warmup_done_22c=1,voltage=54321,power_on=0,lower_preset_95=0,minimum_enabled_b0=1,current_preset_fc8='400',minimum_preset_b8='300',chain_state=[0,5],chain_present=[1,0],profile_label=[1,'Changed label'],profile_key=[1,'250'])
 for entry,ops in [('check',('count','log','event','stop')),('decision',('count','log')),('warmup',('platform','now','collect','trylock','delay','push','reset','log','pop','unlock')),('preset',('log','set'))]:
  for op,k in itertools.product(ops,changes):
   p=dict(mutations=[(op,0,k,changes[k])])
   if entry=='check':p.update(present=[0])
   if entry=='warmup':p.update(returns={'trylock':[16,0],'reset':-1})
   yield entry,'callback_mutation',p
 for op in ('count','log','event','stop'):
  for n in range(5):
   yield 'check','late_mutation',dict(present=[0],mutations=[(op,n,'chain_present',[0,1]),(op,n,'state',0),(op,n,'running',0)])
 for counts in ([0,3,1,2],[3,1,0,2],[2,3,2,0],[3,0,3,1]):
  for entry in ('check','decision'):yield entry,'independent_counts',dict(chain_states=[2,3,5],returns={'count':counts})
 rng=random.Random(6073060)
 for _ in range(400):
  entry=rng.choice(tuple(ENTRIES));yield entry,'mixed',dict(state=rng.choice([0,2,3]),running=rng.randrange(2),mode=rng.randrange(3),active=rng.randrange(2),chain_states=[rng.randrange(7) for _ in range(3)],present=[rng.randrange(2) for _ in range(3)],count=rng.randrange(4),minimum_chains_f8=rng.randrange(-1,5),query_fault_87=rng.randrange(2),partial_chains_105=rng.randrange(2),warmup_e4=rng.randrange(2),warmup_done_22c=rng.randrange(2),current_preset_fc8=rng.choice(['100','200','300','400',None]),minimum_preset_b8=rng.choice(['100','200','300',None]),minimum_enabled_b0=rng.randrange(2),lower_preset_95=rng.randrange(2),returns={'platform':rng.randrange(7),'now':rng.choice([0,899,900,901]),'reset':rng.choice([-1,0,1]),'set':rng.choice([-1,0,1])})

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--limit',type=int);ap.add_argument('--entry',choices=ENTRIES);ns=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==G.REF
 original=Original(elf);native=Native(C.CDLL(str(Path(ns.library).resolve())));counts=collections.Counter();events=0
 for index,(entry,category,p) in enumerate(cases()):
  if ns.entry and entry!=ns.entry:continue
  if ns.limit is not None and sum(counts.values())>=ns.limit:break
  a=original.run(entry,p);b=native.run(entry,p)
  if a!=b:
   print('FAIL',index,entry,category,p)
   for i,(x,y) in enumerate(itertools.zip_longest(a[2],b[2])):
    if x!=y:print('EVENT',i,'ORIGINAL',x,'NATIVE',y);break
   if a[:2]!=b[:2]:print('FINAL',a[:2],b[:2])
   raise AssertionError('monitor handler mismatch')
  counts[entry+'/'+category]+=1;events+=len(a[2])
 report=dict(cases=dict(counts),total=sum(counts.values()),compared_events=events,original_steps=original.steps,visited_instruction_addresses=len(original.visited),original_entries=[hex(x) for x in ENTRIES.values()],nested_original_60a2c=True,original_predicates_and_atoi=True,new_arm_instructions=0,hardware_io=False,real_threads=False,reference_sha256=G.REF)
 if ns.summary:Path(ns.summary).write_text(json.dumps(report,indent=2)+'\n')
 print('MONITOR_HANDLERS135_ORIGINAL_PASS',json.dumps(report,sort_keys=True))
if __name__=='__main__':main()
