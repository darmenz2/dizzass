#!/usr/bin/env python3
"""Compare the whole original 79778 worker with the typed C port, no I/O.
Original words are interpreted unchanged. Missing callees are explicit scripts.
Each callback compares field state, ordering and scalar arguments, not just exit.
"""
import argparse, collections, ctypes as C, hashlib, itertools, json, math, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
from test_thermal_routes_135 import Chain, Sensor, template, put_sensor
U=C.c_uint32;I=C.c_int32;B=C.c_uint8;H=C.c_int16;D=C.c_double;P=C.c_void_p
class GChain(C.Structure):_fields_=[('thermal',Chain),('fault_3c',U),('detected_8c',U)]
class Fan(C.Structure):_fields_=[('mutex',B*24),('index',U),('lost',B),('pad',B*3),('value',I)]
class Model(C.Structure):_fields_=[('kind_34',U),('fan_count_bc',I),('expected_chips_48',I),('sensor_count',I),('query_fault_87',B)]
HISTORY=['chain_check','power_sample','rate_check','fan_adjust','psu_sample']
class History(C.Structure):_fields_=[(n,D) for n in HISTORY]+[('previous_temperature',I)]
SCALAR_U=['state','mode'];SCALAR_I=['target_temperature','required_fans','available_fans','psu_temperature_limit','minimum_rate_percent','tune_percent'];SCALAR_B=['running','active','suppress_chain_check','suppress_thermal','boot_flag','tuning','psu_monitoring','psu_valid']
class State(C.Structure):
 _fields_=[('model',C.POINTER(Model)),('chains',C.POINTER(GChain)),('fans',C.POINTER(Fan)),('history',C.POINTER(History)),('global_rate',C.POINTER(D))]+[(n,U) for n in SCALAR_U]+[(n,I) for n in SCALAR_I]+[('sampled_power',U),('started_at',D)]+[(n,B) for n in SCALAR_B]+[('psu_temperatures',H*3)]
CALL=C.CFUNCTYPE(I,P,U,U,U);NOW=C.CFUNCTYPE(D,P);NUMBER=C.CFUNCTYPE(D,P,U,U);COLLECT=C.CFUNCTYPE(I,P,C.POINTER(I));POWER=C.CFUNCTYPE(I,P,C.POINTER(U));PSU=C.CFUNCTYPE(I,P,C.POINTER(B),C.POINTER(H));FAULT=C.CFUNCTYPE(I,P,U,C.POINTER(U));STOP=C.CFUNCTYPE(I,P,C.POINTER(Chain),C.c_char_p);CREATE=C.CFUNCTYPE(I,P,U,U,C.POINTER(U));LOG=C.CFUNCTYPE(None,P,U,U,U,U,D,C.c_char_p)
class Ops(C.Structure):_fields_=[('call',CALL),('now',NOW),('number',NUMBER),('collect',COLLECT),('power',POWER),('psu',PSU),('fault',FAULT),('stop',STOP),('create',CREATE),('log',LOG)]
class Scratch(C.Structure):_fields_=[('handles',U*3)]
OP=dict(cancel=0x5a6b2c,name=0x593af8,delay=0x10ef3c,exit=0x5a52d0,fans=0x60730,count=0xfe668,platform=0xfdfbc,lock=0x5a6108,unlock=0x5a66c4,event=0x49c98,stop=0x5e92c,prestop=0x5e53c,sensor_test=0x772d8,chip_sensor_test=0x78eb8,thermal=0x591c8,fullfan=0xf8c70,afterstop=0x60a2c,powerstop=0x6b778,chain_check=0x5a3e8,update=0x60d58,chain_power=0xb5290,pool_flag=0x8291c,fan_target=0xf91f4,set_target=0xf911c,psu_available=0x104a20,maintain=0x4bc00,tune_maintain=0xb9420,state_maintain=0x61ae0,pool_mode=0x82af0,pool_update=0x9bc80,rate_action=0x19660)
NAMES={v:k for k,v in OP.items()}
BASE=0x840000;MODEL=0x842000;LIMITS=0x842200;GROUP=0x842400;CHAINS=0x843000;FANS=0x845000;SENSORS=0x846000;GLOBAL=0x6106d0
HO=dict(chain_check=0x610990,power_sample=0x610998,rate_check=0x6109a0,fan_adjust=0x6109a8,previous_temperature=0x6109b0,psu_sample=0x6109b8)
OFF=dict(state=(0x20,4),mode=(0x50,4),target_temperature=(0x58,4),required_fans=(0x68,4),available_fans=(0x23c,4),psu_temperature_limit=(0xd8,4),minimum_rate_percent=(0xe0,4),tune_percent=(0xe8,4),sampled_power=(0x1070,4),started_at=(0x28,8),running=(0x1020,1),active=(0x24,1),suppress_chain_check=(0x83,1),suppress_thermal=(0xf6,1),boot_flag=(0xec,1),tuning=(0x1049,1),psu_valid=(0x10ac,1))
MO=dict(kind_34=(MODEL+0x34,4),fan_count_bc=(MODEL+0xbc,4),expected_chips_48=(MODEL+0x48,4),sensor_count=(GROUP+0x18,4),query_fault_87=(MODEL+0x87,1))
REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
RANGES=((0x79778,0x7bb44),(0x56fcc,0x57028),(0xa71dc,0xa71e8),(0xa720c,0xa7218))

def bits(x):return struct.pack('<d',float(x))
def seq(p,k,i,default):
 v=p.get(k,default)
 return v[min(i,len(v)-1)] if isinstance(v,list) else v

class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in RANGES):raise AssertionError('unapproved general code %x'%pc)
  self.visited.add(pc)
  # Only the three original signed-halfword loads, immediate/pre/no-writeback.
  # Fixtures separately check all 65536 halfword patterns before comparisons.
  if w&0x0fff00f0==0x01d400f0:
   rt=(w>>12)&15;off=((w>>4)&0xf0)|(w&15)
   if pc not in (0x7a9c4,0x7aa1c,0x7aa4c) or rt==15:raise AssertionError('LDRSH scope')
   v=self.read(self.r[4]+off,2);self.r[rt]=(v-65536 if v&32768 else v)&0xffffffff;return True
  return super().extra_instruction(w,pc)

def setup(p):
 model=Model(p.get('kind_34',0),p.get('fan_count_bc',2),p.get('expected_chips_48',88),p.get('sensor_count',2),p.get('query_fault_87',0))
 hist=History(*[p.get(n,100.0) for n in HISTORY],p.get('previous_temperature',60));cs=(GChain*3)();ss=[];fans=(Fan*4)();global_rate=D(p.get('global_rate',0))
 for i in range(3):
  c=cs[i];c.thermal.index=seq(p,'indices',i,i+10);c.thermal.state=seq(p,'chain_states',i,2);c.thermal.present=seq(p,'present',i,1);c.fault_3c=seq(p,'faults',i,0xaabb);c.detected_8c=seq(p,'detected',i,88);c.thermal.statistics[:8]=bits(seq(p,'rates',i,100))
  ar=(Sensor*4)()
  for j in range(4):ar[j]=template(index=j,access_kind=seq(p,'sensor_kinds',j,4),role=seq(p,'sensor_roles',j,2),state=seq(p,'sensor_states',j,2))
  c.thermal.sensors=ar;ss.append(ar)
 for i,f in enumerate(fans):f.index=i+20;f.lost=seq(p,'lost',i,0)
 s=State();s.model=C.pointer(model);s.chains=cs;s.fans=fans;s.history=C.pointer(hist);s.global_rate=C.pointer(global_rate)
 defaults=dict(state=2,mode=0,target_temperature=70,required_fans=2,available_fans=2,psu_temperature_limit=100,minimum_rate_percent=0,tune_percent=100,sampled_power=987,started_at=0,running=0,active=1,suppress_chain_check=0,suppress_thermal=0,boot_flag=0,tuning=0,psu_monitoring=0,psu_valid=0)
 for k,v in defaults.items():setattr(s,k,p.get(k,v))
 s.psu_temperatures[:]=p.get('psu_temperatures',[30,40,50]);scratch=Scratch();scratch.handles[:]=p.get('handles',[17,29,41])
 return s,model,hist,cs,ss,fans,global_rate,scratch

class Script:
 def __init__(self,p,mutate,snapshot):self.p=p;self.mutate=mutate;self.snapshot=snapshot;self.events=[];self.calls=collections.Counter();self.current=p.get('current_target',70)
 def call(self,name,*args):
  n=self.calls[name];self.calls[name]+=1
  self.events.append((name,*args,self.snapshot()))
  for change in self.p.get('mutations',[]):
   if change[0]==name and change[1]==n:self.mutate(change[2],change[3])
  if name=='delay':
   assert args==(1000,0)
   if self.calls[name]>=self.p.get('laps',1):self.mutate('running',0)
  if name=='stop_chain' and self.p.get('stop_changes_state'):self.mutate('chain_state',[args[0],3])
  if name=='set_target':self.current=signed(args[0])
  default={'count':self.p.get('chain_count',2),'platform':self.p.get('platform',0),'now':self.p.get('now',105)+n*self.p.get('tick',0.125),'fan_target':self.current,'chain_power':1200,'denominator':100.0,'integral':0.0}.get(name,0)
  v=self.p.get('returns',{}).get(name,default)
  return v[min(n,len(v)-1)] if isinstance(v,list) else v

SNAMES=SCALAR_U+SCALAR_I+['sampled_power','started_at']+SCALAR_B
class Native:
 def __init__(self,lib):
  self.fn=lib.vn135_general_monitor_135;self.fn.argtypes=[C.POINTER(State),C.POINTER(Ops),P,C.POINTER(Scratch)];self.fn.restype=None
 def run(self,p):
  s,model,hist,cs,ss,fans,glob,scratch=setup(p);errors=[];keep=[]
  def snap():
   return tuple(bits(getattr(s,k)) if k=='started_at' else getattr(s,k) for k in SNAMES),tuple(s.psu_temperatures),tuple(bits(getattr(hist,k)) for k in HISTORY)+(hist.previous_temperature,),tuple(getattr(model,k) for k in MO),tuple((c.thermal.index,c.thermal.state,c.thermal.present,c.fault_3c,c.detected_8c,bytes(c.thermal.statistics[:8])) for c in cs),tuple((f.index,f.lost) for f in fans),tuple(tuple((x.state,x.access_kind,x.role) for x in ar) for ar in ss),bits(glob.value),tuple(scratch.handles)
  def mutate(k,v):
   if k in SNAMES:setattr(s,k,v)
   elif k in HISTORY or k=='previous_temperature':setattr(hist,k,v)
   elif k in MO:setattr(model,k,v)
   elif k=='global_rate':glob.value=v
   elif k=='chain_state':cs[v[0]].thermal.state=v[1]
   elif k=='chain_present':cs[v[0]].thermal.present=v[1]
   elif k=='detected':cs[v[0]].detected_8c=v[1]
   elif k=='psu_temperatures':s.psu_temperatures[:]=v
   elif k=='sensor_state':ss[v[0]][v[1]].state=v[2]
   elif k=='lost':fans[v[0]].lost=v[1]
   elif k=='rate':cs[v[0]].thermal.statistics[:8]=bits(v[1])
   else:raise ValueError(k)
  sc=Script(p,mutate,snap)
  def cb(t,fn):
   def f(*args):
    try:return fn(*args)
    except BaseException as e:errors.append(e);s.running=0;return 0.0 if t in (NOW,NUMBER) else 0
   v=t(f);keep.append(v);return v
  def call(_,op,a,b):return sc.call(NAMES[op],a,b)
  def number(_,op,idx):return sc.call('denominator' if op==0x59810 else 'integral',idx)
  def collect(_,out):
   n=sc.calls['collect'];rc=sc.call('collect',out[0]);v=seq(p,'collected',n,60)
   if v is not None:out[0]=v
   return rc
  def power(_,out):
   n=sc.calls['power'];rc=sc.call('power',out[0]);v=seq(p,'power_values',n,3456)
   if v is not None:out[0]=v
   return rc
  def psu(_,valid,temps):
   n=sc.calls['psu'];rc=sc.call('psu',valid[0],tuple(temps[:3]));v=seq(p,'psu_read',n,(7,31,41,51))
   if v is not None:valid[0]=v[0];temps[0],temps[1],temps[2]=v[1:]
   return rc
  def fault(_,ci,out):
   n=sc.calls['fault'];rc=sc.call('fault',ci,out[0]);v=seq(p,'fault_read',n,0x1234)
   if v is not None:out[0]=v
   return rc
  def create(_,slot,entry,out):
   n=sc.calls['create'];rc=sc.call('create',slot,entry,out[0]);v=seq(p,'handle_values',n,0xabc)
   if v is not None:out[0]=v
   return rc
  def stop(_,ptr,reason):
   ci=(C.addressof(ptr.contents)-C.addressof(cs))//C.sizeof(GChain);assert 0<=ci<3
   return sc.call('stop_chain',ci,reason.decode())
  ops=Ops(cb(CALL,call),cb(NOW,lambda _:sc.call('now')),cb(NUMBER,number),cb(COLLECT,collect),cb(POWER,power),cb(PSU,psu),cb(FAULT,fault),cb(STOP,stop),cb(CREATE,create),cb(LOG,lambda _,line,level,a,b,d,detail:sc.call('log',line,level,a,b,bits(d),detail.decode() if detail else '')))
  self.fn(C.byref(s),C.byref(ops),None,C.byref(scratch))
  if errors:raise errors[0]
  return snap(),sc.events

class Original:
 def __init__(self,elf):self.elf=elf;self.m=Machine(elf);self.visited=set();self.steps=0
 def run(self,p):
  s,model,hist,cs,ss,fans,glob,scratch=setup(p);m=self.m;m.reset((BASE,));m.visited=set();m.mem[BASE:BASE+0x10000]=bytes(0x10000)
  for k,(off,n) in OFF.items():m.write(BASE+off,int.from_bytes(bits(getattr(s,k)),'little') if n==8 else getattr(s,k),n)
  m.write(BASE+0x18,MODEL);m.write(BASE+0x1c,LIMITS);m.write(BASE+0x230,CHAINS);m.write(BASE+0x238,FANS);m.write(MODEL+0x58,GROUP)
  for k,(a,n) in MO.items():m.write(a,getattr(model,k),n)
  m.write(LIMITS+0x38,s.psu_monitoring,1)
  for i,v in enumerate(s.psu_temperatures):m.write(BASE+0x10ae+i*2,v,2)
  for k,a in HO.items():m.write(a,getattr(hist,k) if k=='previous_temperature' else int.from_bytes(bits(getattr(hist,k)),'little'),4 if k=='previous_temperature' else 8)
  m.write(GLOBAL,int.from_bytes(bits(glob.value),'little'),8)
  slots=[m.STACK_TOP-464,m.STACK_TOP-456,m.STACK_TOP-192]
  for a,v in zip(slots,scratch.handles):m.write(a,v)
  for i,c in enumerate(cs):
   a=CHAINS+i*800;m.write(a+0x18,c.thermal.index);m.write(a+0x1c,BASE);m.write(a+0x20,c.thermal.state);m.write(a+0x24,c.thermal.present,1);m.write(a+0x3c,c.fault_3c);m.write(a+0x8c,c.detected_8c);m.mem[a+0x40:a+0x48]=bytes(c.thermal.statistics[:8]);m.write(a+0x290,SENSORS+i*0x400)
   for j,x in enumerate(ss[i]):put_sensor(m,x,SENSORS+i*0x400+j*128)
  for i,f in enumerate(fans):m.write(FANS+i*36+24,f.index);m.write(FANS+i*36+28,f.lost,1)
  def scalar(k):
   if k=='psu_monitoring':return m.read(LIMITS+0x38,1)
   off,n=OFF[k];v=m.read(BASE+off,n)
   return v.to_bytes(8,'little') if n==8 else signed(v) if k in SCALAR_I else v
  def snap():
   return tuple(scalar(k) for k in SNAMES),tuple(C.c_int16(m.read(BASE+0x10ae+i*2,2)).value for i in range(3)),tuple(bytes(m.mem[HO[k]:HO[k]+8]) for k in HISTORY)+(signed(m.read(HO['previous_temperature'])),),tuple(signed(m.read(a,n)) if k in ('fan_count_bc','expected_chips_48','sensor_count') else m.read(a,n) for k,(a,n) in MO.items()),tuple((m.read(CHAINS+i*800+0x18),m.read(CHAINS+i*800+0x20),m.read(CHAINS+i*800+0x24,1),m.read(CHAINS+i*800+0x3c),m.read(CHAINS+i*800+0x8c),bytes(m.mem[CHAINS+i*800+0x40:CHAINS+i*800+0x48])) for i in range(3)),tuple((m.read(FANS+i*36+24),m.read(FANS+i*36+28,1)) for i in range(4)),tuple(tuple((m.read(SENSORS+i*0x400+j*128+0x2c),m.read(SENSORS+i*0x400+j*128+0x30),m.read(SENSORS+i*0x400+j*128+0x34)) for j in range(4)) for i in range(3)),bytes(m.mem[GLOBAL:GLOBAL+8]),tuple(m.read(a) for a in slots)
  def mutate(k,v):
   if k=='psu_monitoring':m.write(LIMITS+0x38,v,1)
   elif k in OFF:
    off,n=OFF[k];m.write(BASE+off,int.from_bytes(bits(v),'little') if n==8 else v,n)
   elif k in HO:m.write(HO[k],v if k=='previous_temperature' else int.from_bytes(bits(v),'little'),4 if k=='previous_temperature' else 8)
   elif k in MO:a,n=MO[k];m.write(a,v,n)
   elif k=='global_rate':m.write(GLOBAL,int.from_bytes(bits(v),'little'),8)
   elif k in ('chain_state','chain_present','detected'):m.write(CHAINS+v[0]*800+{'chain_state':0x20,'chain_present':0x24,'detected':0x8c}[k],v[1],1 if k=='chain_present' else 4)
   elif k=='psu_temperatures':
    for i,val in enumerate(v):m.write(BASE+0x10ae+i*2,val,2)
   elif k=='sensor_state':m.write(SENSORS+v[0]*0x400+v[1]*128+0x2c,v[2])
   elif k=='lost':m.write(FANS+v[0]*36+28,v[1],1)
   elif k=='rate':m.write(CHAINS+v[0]*800+0x40,int.from_bytes(bits(v[1]),'little'),8)
   else:raise ValueError(k)
  sc=Script(p,mutate,snap)
  def ret(v=0):m.r[0]=int(v)&0xffffffff
  def ci(a):
   i=(a-CHAINS)//800;assert 0<=i<3 and a==CHAINS+i*800,hex(a)
   return i
  def text(a):
   if a==0x5e55da:return 'Lost temp sensors'
   if a==0x5e6a21:return 'Chain break detected'
   assert m.STACK_BASE<=a<m.STACK_TOP,hex(a)
   return bytes(m.mem[a:a+256]).split(b'\0')[0].decode()
  def simple(name):
   def f(_):
    a=b=0
    if name in ('cancel','delay','set_target'):a=m.r[0]
    elif name=='name':assert m.r[0]==15 and m.r[1]==0x5e696a and m.r[2]==m.r[3]==m.read(m.r[13])==0
    elif name in ('thermal','chain_check','chain_power'):a=ci(m.r[0]);b=m.r[1] if name=='thermal' else 0
    elif name=='event':
     assert m.r[0]==BASE+0x10b4;a=m.r[1];b=m.r[2] if a in (2004,3005) else 0
    elif name in ('lock','unlock'):
     ptr=m.r[0]
     if ptr==BASE+0x214:a=0
     elif FANS<=ptr<FANS+4*36:a=1;b=(ptr-FANS)//36;assert ptr==FANS+b*36
     else:a=2;b=ci(ptr)
    elif name=='exit':assert m.r[0]==0;m.r[14]=m.RETURN
    ret(sc.call(name,a,b))
   return f
  hooks={op:simple(name) for name,op in OP.items()}
  def now(_):m.set_d(0,sc.call('now'))
  def number(name):return lambda _:m.set_d(0,sc.call(name,ci(m.r[0]) if name=='denominator' else 0))
  def collect(_):
   assert m.r[0]==BASE;out=m.r[1];n=sc.calls['collect'];rc=sc.call('collect',signed(m.read(out)));v=seq(p,'collected',n,60)
   if v is not None:m.write(out,v)
   ret(rc)
  def power(_):
   assert m.r[0]==BASE+0x108c;out=m.r[1];n=sc.calls['power'];rc=sc.call('power',m.read(out));v=seq(p,'power_values',n,3456)
   if v is not None:m.write(out,v)
   ret(rc)
  def psu(_):
   assert m.r[0]==BASE+0x108c and m.r[1]==BASE+0x10ac,(list(map(hex,m.r[:4])))
   n=sc.calls['psu'];rc=sc.call('psu',m.read(BASE+0x10ac,1),tuple(C.c_int16(m.read(BASE+0x10ae+i*2,2)).value for i in range(3)));v=seq(p,'psu_read',n,(7,31,41,51))
   if v is not None:
    m.write(BASE+0x10ac,v[0],1)
    for i,val in enumerate(v[1:]):m.write(BASE+0x10ae+i*2,val,2)
   ret(rc)
  def fault(_):
   i=ci(m.r[0]);out=m.r[1];assert out==CHAINS+i*800+0x3c
   n=sc.calls['fault'];rc=sc.call('fault',i,m.read(out));v=seq(p,'fault_read',n,0x1234)
   if v is not None:m.write(out,v)
   ret(rc)
  def stop(_):ret(sc.call('stop_chain',ci(m.r[0]),text(m.r[1])))
  def create(_):
   out,attrs,entry,backend=m.r[:4];assert out in slots and attrs==0 and entry==0x72ba4 and backend==BASE
   n=sc.calls['create'];rc=sc.call('create',slots.index(out),entry,m.read(out));v=seq(p,'handle_values',n,0xabc)
   if v is not None:m.write(out,v)
   ret(rc)
  def snprintf(_):
   out,size,fmt,detected=m.r[:4];assert size==256 and fmt==0x5e69ab
   msg=('Chain break detected (%d of %d chips replied)'%(signed(detected),signed(m.read(m.r[13])))).encode();m.mem[out:out+len(msg)+1]=msg+b'\0';ret(len(msg))
  def log(_):
   line=m.r[3];sp=m.r[13];level=m.read(sp);a=b=0;v=0.0
   if line in (2207,2565,2569,2604,2608,2894):a=m.read(sp+8)
   if line in (2569,2608):b=m.read(sp+12)
   if line in (2461,2462):level=2;v=struct.unpack('<d',m.mem[sp+8:sp+16])[0];a=m.read(sp+16)
   assert line in (2207,2364,2565,2569,2604,2608,2894,2895,2461,2462,2654,6483),line
   sc.call('log',line,level,a,b,bits(v),text(m.read(sp+12)) if line==2565 else '');ret()
  hooks.update({0x1ed58:now,0x59810:number('denominator'),0xf8df0:number('integral'),0x5db54:collect,0x104fe4:power,0x104aa0:psu,0xb4e28:fault,0x56d18:stop,0x5a55cc:create,0x59f558:snprintf,0xfa0c4:log})
  m.run(0x79778,hooks=hooks,max_steps=100000);self.visited|=m.visited;self.steps+=m.steps
  return snap(),sc.events

def compare(original,native,p,index):
 a=original.run(p);b=native.run(p)
 if a!=b:
  print('FAIL',index,p)
  for i,(x,y) in enumerate(itertools.zip_longest(a[1],b[1])):
   if x!=y:
    print('EVENT',i,'ORIGINAL',x,'NATIVE',y);break
  if a[0]!=b[0]:print('FINAL',a[0],b[0])
  raise AssertionError('general worker mismatch')
 return len(a[1])

def cases():
 yield 'baseline',{}
 for state,mode,active in itertools.product((0,1,2,3,4,5,6,0xffffffff),(0,1,2,3),(0,1)):
  yield 'gates',dict(state=state,mode=mode,active=active)
 for flag,vals,limit in itertools.product((0,1,2,3,4,5,6,7,8,255),((-32768,-1,0),(0,1,2),(99,100,101),(32767,-32768,50)),(-1,0,50,100,32767)):
  yield 'psu_trip',dict(psu_monitoring=1,psu_valid=flag,psu_temperatures=vals,psu_temperature_limit=limit,returns={'psu_available':1})
 for required,available,lost,nfans in itertools.product((-1,0,2),(0,1,2,3),(0,1),(0,2,4)):
  yield 'fans',dict(required_fans=required,available_fans=available,lost=[lost],fan_count_bc=nfans)
 for platform,query,detected in itertools.product(range(9),(0,1),(87,88,89,0xffffffff)):
  yield 'chain_check',dict(platform=platform,query_fault_87=query,detected=[detected],now=111,returns={'chain_check':1})
 for cstate,pr in itertools.product((0,1,2,3,4,5,6,0xffffffff),(0,1,255)):
  yield 'chain_state',dict(chain_states=[cstate],present=[pr],detected=[87],query_fault_87=1,returns={'thermal':1,'afterstop':1,'create':-1})
 for suppress,st,role,kind in itertools.product((0,1),(0,2,3),(0,2),(1,4)):
  yield 'sensors',dict(suppress_thermal=suppress,sensor_states=[st],sensor_roles=[role],sensor_kinds=[kind],returns={'thermal':1,'afterstop':1})
 for value in (-1,0,1,2,3):
  yield 'counts',dict(chain_count=value,sensor_count=0,suppress_thermal=1)
 for boot,start,rate,minimum in itertools.product((0,1),(299.999,300,599.999,600),(0,0.0009,0.001,50,99,100),(-1,0,80,100)):
  yield 'rates',dict(boot_flag=boot,now=start,tick=0,rate_check=0,rates=[rate],minimum_rate_percent=minimum)
 for target,current,previous,collected,gap,elapsed in itertools.product((50,70),(40,60,80),(40,60,80),(40,60,80),(0.9,1),(29.999,30)):
  yield 'fan_control',dict(target_temperature=target,current_target=current,previous_temperature=previous,collected=collected,fan_adjust=100,now=100+elapsed,tick=0,returns={'integral':gap})
 for k in ('thermal','afterstop','create','stop_chain','powerstop','collect','power','psu','fault','chain_check','pool_flag','pool_mode','psu_available'):
  for rc in (-1,0,1):
   returns={'thermal':1,'afterstop':1,'create':-1,'chain_check':1,'psu_available':1};returns[k]=rc
   yield 'failures',dict(now=700,psu_monitoring=1,psu_valid=7,psu_temperatures=[100,101,102],detected=[87],query_fault_87=1,current_target=50,minimum_rate_percent=80,rates=[20],returns=returns)
 for laps in (1,2,3):
  yield 'multi_lap',dict(laps=laps,now=601,tick=10,psu_monitoring=1,current_target=50,returns={'psu_available':1},psu_read=[(7,10,20,30),(7,100,150,200)],handle_values=[12,None],returns_unused={})
 for kind,rate in itertools.product((0,1,2),(999999999,1e9,3e9,3000000001)):
  yield 'rate_action',dict(kind_34=kind,global_rate=rate)

 for key,edge in (("now",5),("now",10),("now",30),("now",90),("now",300),("now",600)):
  for v in (math.nextafter(float(edge),-math.inf),float(edge),math.nextafter(float(edge),math.inf)):
   yield 'time_boundaries',dict(now=v,tick=0,chain_check=0,power_sample=0,rate_check=0,fan_adjust=0,psu_sample=0,minimum_rate_percent=80,rates=[50],current_target=50,psu_monitoring=1,returns={'psu_available':1,'integral':1})
 for current,target in ((2147483640,2147483647),(-2147483640,-2147483648)):
  yield 'integer_wrap',dict(current_target=current,target_temperature=target,previous_temperature=current,collected=current,now=150,returns={'integral':0.5})
 yield 'integer_wrap',dict(returns={'chain_power':-1},chain_count=3)
 for k in ('collected','power_values','psu_read','fault_read','handle_values'):
  yield 'unchanged_outputs',dict(**{k:None},psu_monitoring=1,psu_valid=7,psu_temperatures=[120,130,140],query_fault_87=1,detected=[87],current_target=50,returns={'psu_available':1,'thermal':1,'afterstop':1})
 full=dict(now=700,tick=0,laps=2,psu_monitoring=1,psu_valid=7,psu_temperatures=[100,110,120],query_fault_87=1,detected=[87],current_target=50,previous_temperature=60,collected=60,fan_adjust=100,required_fans=4,available_fans=1,lost=[1],minimum_rate_percent=80,rates=[50],returns={'psu_available':1,'thermal':1,'afterstop':1,'create':-1,'integral':1})
 changes=dict(state=[0,2,3,6],mode=[0,2],running=[0],active=[0],suppress_thermal=[1],suppress_chain_check=[1],tuning=[1],psu_monitoring=[0],psu_valid=[0],target_temperature=[30,90],minimum_rate_percent=[0,99],tune_percent=[0],required_fans=[0],available_fans=[4],started_at=[700.0],boot_flag=[1],fan_count_bc=[0,4],expected_chips_48=[87],sensor_count=[0,4],query_fault_87=[0],kind_34=[2],chain_state=[[0,3]],chain_present=[[0,0]],detected=[[1,88]],sensor_state=[[0,0,3]],lost=[[1,0]],rate=[[0,0.0]],global_rate=[4e9],previous_temperature=[30],chain_check=[1000.0],power_sample=[1000.0],rate_check=[1000.0],fan_adjust=[1000.0],psu_sample=[1000.0])
 for op in ('fans','now','lock','unlock','count','thermal','stop_chain','event','stop','create','powerstop','platform','fault','prestop','update','power','pool_flag','denominator','fan_target','collect','integral','set_target','psu_available','psu','maintain','log','delay'):
  for k,values in changes.items():
   # Avoid generating thousands of identical non-reached choices: the first
   # callback boundary still compares its complete incoming state.
   v=values[-1]
   q=dict(full);q['mutations']=[(op,0,k,v)]
   yield 'boundary_mutation',q
 for op in ('count','lock','thermal','now','fault','log','create','denominator'):
  for n in range(1,5):
   q=dict(full);q['mutations']=[(op,n,'running',0),(op,n,'state',3)];yield 'late_mutation',q
 for flags in ((1,1),(1,0),(0,1)):
  yield 'count_mutation',dict(full,returns=dict(full['returns'],count=[3,1,2,3,1,2],sensor_test=flags[0],chip_sensor_test=flags[1]))
 rng=random.Random(79778135)
 for i in range(350):
  yield 'mixed',dict(state=rng.choice([0,2,3,6]),mode=rng.randrange(4),active=rng.randrange(2),chain_count=rng.randrange(-1,4),fan_count_bc=rng.randrange(5),sensor_count=rng.randrange(5),kind_34=rng.randrange(4),platform=rng.randrange(9),query_fault_87=rng.randrange(2),chain_states=[rng.randrange(8) for _ in range(3)],present=[rng.randrange(2) for _ in range(3)],detected=[rng.choice([87,88,89]) for _ in range(3)],sensor_states=[rng.randrange(4) for _ in range(4)],sensor_roles=[rng.randrange(3) for _ in range(4)],sensor_kinds=[rng.randrange(6) for _ in range(4)],suppress_thermal=rng.randrange(2),suppress_chain_check=rng.randrange(2),tuning=rng.randrange(2),psu_monitoring=rng.randrange(2),psu_valid=rng.randrange(256),psu_temperatures=[rng.randrange(-32768,32768) for _ in range(3)],psu_temperature_limit=rng.randrange(-100,300),required_fans=rng.randrange(-1,5),available_fans=rng.randrange(5),lost=[rng.randrange(2) for _ in range(4)],minimum_rate_percent=rng.choice([0,80,90]),boot_flag=rng.randrange(2),tune_percent=rng.choice([0,100]),current_target=rng.choice([30,70,90]),target_temperature=rng.choice([30,70,90]),collected=rng.choice([20,60,90]),previous_temperature=rng.choice([20,60,90]),rates=[rng.choice([0,0.001,50,100]) for _ in range(3)],now=rng.choice([5,100,300,700]),tick=rng.choice([0,0.125,30]),laps=rng.randrange(1,4),returns={k:rng.choice([-1,0,1]) for k in ['thermal','afterstop','create','chain_check','psu_available','pool_flag','pool_mode']})


def load_fixtures(elf):
 m=Machine(elf);m.visited=set();m.r[4]=BASE
 total=0
 for pc in (0x7a9c4,0x7aa1c,0x7aa4c):
  w=int.from_bytes(elf.read(pc,4),'little');off=((w>>4)&0xf0)|(w&15);rt=(w>>12)&15
  for v in range(65536):
   m.write(BASE+off,v,2);assert m.extra_instruction(w,pc)
   assert m.r[rt]==(v if v<32768 else v-65536)&0xffffffff
   total+=1
 return total


def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--limit',type=int);ns=ap.parse_args()
 path=ROOT/'reference/cgminer.vendor.elf';assert hashlib.sha256(path.read_bytes()).hexdigest()==REF
 elf=ELF32(path);fixtures=load_fixtures(elf);original=Original(elf);native=Native(C.CDLL(str(Path(ns.library).resolve())))
 counts=collections.Counter();events=0
 for i,(category,p) in enumerate(cases()):
  if ns.limit is not None and i>=ns.limit:break
  events+=compare(original,native,p,i);counts[category]+=1
 report=dict(cases=dict(counts),total=sum(counts.values()),compared_events=events,original_steps=original.steps,visited_instruction_addresses=len(original.visited),signed_halfword_fixtures=fixtures,original_whole_entry=True,hardware_io=False,real_threads=False,unresolved_callees='explicit scripted callbacks',reference_sha256=REF)
 if ns.summary:Path(ns.summary).write_text(json.dumps(report,indent=2)+'\n')
 print('GENERAL_MONITOR135_ORIGINAL_PASS',json.dumps(report,sort_keys=True))
if __name__=='__main__':main()
