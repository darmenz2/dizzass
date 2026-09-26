#!/usr/bin/env python3
"""Whole original temperature polling worker and failure dispatcher, offline.
Lower reader/aggregate/overheat and OS effects are explicit scenario callbacks.
"""
import argparse, collections, ctypes as C, hashlib, itertools, json, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
from test_thermal_routes_135 import Chain, CP, Sensor, template, put_sensor, get_sensor, snapshot
U=C.c_uint32;I=C.c_int32;B=C.c_uint8;D=C.c_double;P=C.c_void_p
class State(C.Structure):_fields_=[('state',U),('mode',U),('running',B),('suppress',B),('count',I),('chains',CP),('last',D)]
CB=C.CFUNCTYPE(I,P);SCALAR=C.CFUNCTYPE(I,P,U);NAME=C.CFUNCTYPE(I,P,C.c_char_p);NOW=C.CFUNCTYPE(D,P)
READ=C.CFUNCTYPE(I,P,CP,C.POINTER(Sensor));VOIDCHAIN=C.CFUNCTYPE(None,P,CP);ICHAIN=C.CFUNCTYPE(I,P,CP)
STOP=C.CFUNCTYPE(I,P,CP,C.c_char_p);VOID=C.CFUNCTYPE(None,P);CREATE=C.CFUNCTYPE(I,P,U,C.POINTER(U));EXIT=C.CFUNCTYPE(None,P,U)
LOG=C.CFUNCTYPE(None,P,U,U,U,I)
class Ops(C.Structure):_fields_=[('chain_count',CB),('cancel_type',SCALAR),('name',NAME),('now',NOW),('delay',SCALAR),('read',READ),('aggregate',VOIDCHAIN),('overheat',ICHAIN),('stop',STOP),('after_stop',CB),('refresh',ICHAIN),('action',VOID),('event',SCALAR),('create',CREATE),('power_stop',CB),('exit',EXIT),('log',LOG)]
BASE=0x840000;MODEL=0x842000;DESC=MODEL+0x38;GROUP=0x842800;CHAINS=0x843000;SENSORS=0x846000;LAST=0x610968
HASH='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
RANGES=((0x668a8,0x66ee4),(0x66f80,0x67074),(0x56fcc,0x57028),(0xa720c,0xa7218))
class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in RANGES):raise AssertionError('unapproved monitor code %x'%pc)
  return super().extra_instruction(w,pc)
def nth(p,k,n,default):
 v=p.get(k,[default]);return v[min(n,len(v)-1)]
def setup(p):
 cs=(Chain*3)();sensors=[]
 for ci in range(3):
  ss=(Sensor*4)()
  for j in range(4):ss[j]=template(index=j+5,access_kind=nth(p,'kinds',j,1),state=nth(p,'sensor_states',j,2),role=p.get('role',0),failures=0)
  cs[ci].index=ci+10;cs[ci].state=nth(p,'chain_states',ci,2);cs[ci].present=nth(p,'present',ci,1);cs[ci].sensors=ss;sensors.append(ss)
 return State(p.get('state',2),p.get('mode',0),p.get('running',0),p.get('suppress',0),p.get('sensors',2),cs,p.get('last',100.0)),cs,sensors
class Script:
 def __init__(self,p,mutate,snap):self.p=p;self.events=[];self.count=collections.Counter();self.mutate=mutate;self.snap=snap
 def call(self,name,*a):
  n=self.count[name];self.count[name]+=1;self.events.append((name,*a,self.snap()))
  if name=='count':return self.p.get('chains',2)
  if name=='now':return self.p.get('now',105.0)+n*self.p.get('tick',0.125)
  if name=='delay' and a[0]==1000:
   self.count['laps']+=1
   if self.count['laps']>=self.p.get('laps',1):self.mutate('running',0)
   if 'state_after_lap' in self.p:self.mutate('state',self.p['state_after_lap'])
  if name=='read':
   state=nth(self.p,'post_read_state',n,2);self.mutate('sensor',(a[0],a[1],state))
   if 'state_after_read' in self.p:self.mutate('state',self.p['state_after_read'])
   if self.p.get('stop_during_read'):self.mutate('running',0)
  if name=='stop':self.mutate('chain',a[0])
  vals=self.p.get('returns',{}).get(name,0)
  return vals[min(n,len(vals)-1)] if isinstance(vals,list) else vals

def c_run(lib,p):
 s,cs,ss=setup(p);errors=[];scratch=U(0xabcdef)
 def snap():return s.state,s.mode,s.running,s.suppress,struct.pack('<d',s.last),tuple((c.state,c.present) for c in cs),tuple(tuple((x.state,x.failures) for x in ar) for ar in ss)
 def mutate(k,v):
  if k=='running':s.running=v
  if k=='state':s.state=v
  if k=='chain':cs[v].state=3
  if k=='sensor':ci,j,st=v;ss[ci][j].state=st;ss[ci][j].failures+=1
 sc=Script(p,mutate,snap)
 def ci(ptr):return (C.addressof(ptr.contents)-C.addressof(cs))//C.sizeof(Chain)
 def sj(c,ptr):return (C.addressof(ptr.contents)-C.addressof(ss[c]))//C.sizeof(Sensor)
 def safe(fn,default=0):
  def f(*a):
   try:return fn(*a)
   except BaseException as e:errors.append(e);return default
  return f
 def create(_,ep,out):
  rc=sc.call('create',ep)
  if p.get('write_handle',True):out[0]=456
  return rc
 def log(_,line,c,se,fail):sc.call('log',line,c,se,fail)
 cbs=[CB(safe(lambda _:sc.call('count'))),SCALAR(safe(lambda _,v:sc.call('cancel_type',v))),NAME(safe(lambda _,v:sc.call('name',v.decode()))),NOW(safe(lambda _:sc.call('now'),0.0)),SCALAR(safe(lambda _,v:sc.call('delay',v))),READ(safe(lambda _,c,se:sc.call('read',ci(c),sj(ci(c),se)))),VOIDCHAIN(safe(lambda _,c:sc.call('aggregate',ci(c)))),ICHAIN(safe(lambda _,c:sc.call('overheat',ci(c)))),STOP(safe(lambda _,c,t:sc.call('stop',ci(c),t.decode()))),CB(safe(lambda _:sc.call('after_stop'))),ICHAIN(safe(lambda _,c:sc.call('refresh',ci(c)))),VOID(safe(lambda _:sc.call('action'))),SCALAR(safe(lambda _,v:sc.call('event',v))),CREATE(safe(create)),CB(safe(lambda _:sc.call('power_stop'))),EXIT(safe(lambda _,v:sc.call('exit',v))),LOG(safe(log))]
 o=Ops(*cbs)
 if p.get('abort_only'):lib.vn135_temperature_monitor_abort_135(C.byref(o),None,C.byref(scratch))
 else:lib.vn135_temperature_monitor_135(C.byref(s),C.byref(o),None,C.byref(scratch))
 if errors:raise errors[0]
 return snap(),sc.events

def original(m,p,elf):
 s,cs,ss=setup(p);m.reset((BASE,))
 m.mem[BASE:BASE+0x1200]=bytes([0x69])*0x1200;m.mem[MODEL:MODEL+0x900]=bytes(0x900)
 m.write(BASE+0x18,MODEL);m.write(DESC+0x20,GROUP);m.write(GROUP+0x18,s.count);m.write(BASE+0x230,CHAINS)
 m.write(BASE+0x20,s.state);m.write(BASE+0x50,s.mode);m.write(BASE+0x1030,s.running,1);m.write(BASE+0xf6,s.suppress,1);m.write(LAST,struct.unpack('<Q',struct.pack('<d',s.last))[0],8)
 for ci,c in enumerate(cs):
  cp=CHAINS+ci*800;m.mem[cp:cp+800]=bytes([0x36])*800
  m.write(cp+0x18,c.index);m.write(cp+0x1c,BASE);m.write(cp+0x20,c.state);m.write(cp+0x24,c.present,1);m.write(cp+0x290,SENSORS+ci*0x400)
  for j,x in enumerate(ss[ci]):put_sensor(m,x,SENSORS+ci*0x400+j*128)
 def snap():
  return m.read(BASE+0x20),m.read(BASE+0x50),m.read(BASE+0x1030,1),m.read(BASE+0xf6,1),bytes(m.mem[LAST:LAST+8]),tuple((m.read(CHAINS+ci*800+0x20),m.read(CHAINS+ci*800+0x24,1)) for ci in range(3)),tuple(tuple((m.read(SENSORS+ci*0x400+j*128+0x2c),signed(m.read(SENSORS+ci*0x400+j*128+0x60))) for j in range(4)) for ci in range(3))
 def mutate(k,v):
  if k=='running':m.write(BASE+0x1030,v,1)
  if k=='state':m.write(BASE+0x20,v)
  if k=='chain':m.write(CHAINS+v*800+0x20,3)
  if k=='sensor':ci,j,st=v;off=SENSORS+ci*0x400+j*128;m.write(off+0x2c,st);m.write(off+0x60,m.read(off+0x60)+1)
 sc=Script(p,mutate,snap)
 def ret(v=0):m.r[0]=int(v)&0xffffffff
 def call(name,args=lambda:()):
  return lambda _:ret(sc.call(name,*args()))
 def chain():
  ci=(m.r[0]-CHAINS)//800;assert 0<=ci<3 and m.r[0]==CHAINS+ci*800;return ci
 def read(_):
  ci=chain();j=(m.r[1]-SENSORS-ci*0x400)//128;assert 0<=j<4;ret(sc.call('read',ci,j))
 def now(_):m.set_d(0,sc.call('now'))
 def text(addr,key):
  raw=elf.read(addr,len(key)+1)
  vals=[x for x in range(256) if bytes(v^x for v in raw)==key.encode()+b'\0']
  assert len(vals)==1,(hex(addr),key);return key
 def name(_):
  assert m.r[0]==15 and m.r[2]==m.r[3]==m.read(m.r[13])==0
  ret(sc.call('name',text(m.r[1],'temp_read@btm')))
 def stop(_):ret(sc.call('stop',chain(),text(m.r[1],'Lost temp sensors')))
 def create(_):
  out,attrs,ep,backend=m.r[:4];assert attrs==0 and backend==BASE
  rc=sc.call('create',ep)
  if p.get('write_handle',True):m.write(out,456)
  ret(rc)
 def log(_):
  line=m.r[3];sp=m.r[13];ci=sj=fail=0
  if line==4907:ci=m.read(sp+8);sj=m.read(sp+12);fail=signed(m.read(sp+16))
  elif line==4912:ci=m.read(sp+8);sj=m.read(sp+12)
  else:assert line in (4929,4943,6483),line
  sc.call('log',line,ci,sj,fail);ret()
 def leave(_):sc.call('exit',m.r[0]);m.r[14]=m.RETURN
 hooks={0xfe668:call('count'),0x5a6b2c:call('cancel_type',lambda:(m.r[0],)),0x593af8:name,0x1ed58:now,0x10ef3c:call('delay',lambda:(m.r[0],)),0xb5f40:read,0x58700:call('aggregate',lambda:(chain(),)),0x58e68:call('overheat',lambda:(chain(),)),0x56d18:stop,0x60a2c:call('after_stop'),0x59e48:call('refresh',lambda:(chain(),)),0x5e53c:call('action'),0x49c98:call('event',lambda:(m.r[1],)),0x5a55cc:create,0x6b778:call('power_stop'),0x5a52d0:leave,0xfa0c4:log}
 m.run(0x66f80 if p.get('abort_only') else 0x668a8,hooks=hooks,max_steps=100000)
 return snap(),sc.events

def cases():
 for state,mode,k in itertools.product((0,1,2,3,4,5,6,0xffffffff),(0,2,3),(0,1,2,3,4,5)):
  yield dict(state=state,mode=mode,kinds=[k])
 for elapsed,st in itertools.product((-1,0,4.999,5,5.001,10),(2,3,4,6)):
  yield dict(last=100,now=100+elapsed,state=st)
 for cs,pr in itertools.product((0,1,2,3,4,5,6,0xffffffff),(0,1,255)):
  yield dict(chain_states=[cs],present=[pr],now=106)
 for n,chains,laps in itertools.product((0,1,3),(-1,0,1,3),(1,2,3)):
  yield dict(sensors=n,chains=chains,laps=laps,now=106)
 for mode,role,sup,post,after in itertools.product((0,2),(0,2),(0,1),(2,3),(0,-1)):
  yield dict(mode=mode,role=role,suppress=sup,post_read_state=[post],returns={'read':-1,'after_stop':after})
 for key in ('read','overheat','refresh','create','power_stop','delay','cancel_type','name','event'):
  for rc in (-1,1,0):yield dict(now=106,returns={key:rc,'overheat':rc if key=='overheat' else -1 if key in ('create','power_stop','event') else 0})
 for n in range(6):yield dict(now=106,returns={'overheat':[0]*n+[-1],'create':-1})
 for st in (2,3,4,6):yield dict(state_after_read=st,now=106,laps=2)
 yield dict(stop_during_read=True,laps=3)
 yield dict(state_after_lap=4,laps=3)
 for ret in (0,1,-1):yield dict(abort_only=True,returns={'create':ret,'power_stop':-1})
 rng=random.Random(668135)
 for _ in range(90):
  yield dict(state=rng.choice([2,3,4]),mode=rng.randrange(4),suppress=rng.randrange(2),role=rng.choice([0,2]),kinds=[rng.randrange(6) for _ in range(3)],sensor_states=[rng.randrange(4) for _ in range(3)],post_read_state=[rng.choice([2,3]) for _ in range(4)],present=[rng.randrange(2) for _ in range(3)],chain_states=[rng.randrange(7) for _ in range(3)],sensors=3,chains=3,now=100+rng.random()*10,laps=2,returns={'after_stop':rng.choice([0,-1]),'overheat':[0,0,rng.choice([0,-1])],'create':rng.choice([0,-1])})
def main():
 a=argparse.ArgumentParser();a.add_argument('library');a.add_argument('--summary');args=a.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
 m=Machine(elf);lib=C.CDLL(str(Path(args.library).resolve()))
 lib.vn135_temperature_monitor_135.argtypes=[C.POINTER(State),C.POINTER(Ops),P,C.POINTER(U)];lib.vn135_temperature_monitor_135.restype=None
 lib.vn135_temperature_monitor_abort_135.argtypes=[C.POINTER(Ops),P,C.POINTER(U)];lib.vn135_temperature_monitor_abort_135.restype=None
 n=ev=0
 for p in cases():
  try:
   x=original(m,p,elf);y=c_run(lib,p);assert x==y,(p,x,y)
  except BaseException:print('MONITOR_FAILED',p,file=sys.stderr);raise
  n+=1;ev+=len(x[1])
 result=dict(comparisons=n,events=ev,original_worker_and_abort=True,original_chain_predicate=True,new_arm_instructions=0,lower_reader_and_chip_request='explicit callbacks',physical_io=False,real_threads=False)
 if args.summary:Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
 print('SENSOR_MONITOR135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
