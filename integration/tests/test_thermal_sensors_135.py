#!/usr/bin/env python3
"""Offline differential tests against pinned 1.3.5 instruction ranges.
No firmware process, OS effects, real hardware, or physical shutdown claim.
"""
import argparse, ctypes as C, hashlib, json, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed, ror
ELF_HASH='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
U=C.c_uint32; I=C.c_int32; B=C.c_uint8; D=C.c_double; P=C.c_void_p
class Sensor(C.Structure):
 _fields_=[(n,U) for n in ['index','address','state','access_kind','role']]+[(n,B) for n in ['device_id','remote_enabled','skip_initial_read','extended','has_previous']]+[(n,I) for n in ['sample','corrected','local_offset','remote_offset','failures','previous_sample','previous_corrected']]+[('sampled_at',D),('started_at',D)]
SP=C.POINTER(Sensor)
MUT=C.CFUNCTYPE(I,P,SP);NOW=C.CFUNCTYPE(D,P);RD=C.CFUNCTYPE(I,P,SP,U,C.POINTER(B));WR=C.CFUNCTYPE(I,P,SP,U,B);DELAY=C.CFUNCTYPE(I,P,U);LOG=C.CFUNCTYPE(None,P,U,U,U,U)
class Ops(C.Structure):
 _fields_=[('mutex_init',MUT),('lock',MUT),('unlock',MUT),('now',NOW),('configure_reading',MUT),('read_register',RD),('write_register',WR),('finish_configuration',MUT),('delay_ms',DELAY),('log',LOG)]
class Group(C.Structure):_fields_=[('sensors',SP),('description_types',C.POINTER(U)),('count',I),('board_timeout',D),('sensor_timeout',D)]
class Chip(C.Structure):_fields_=[('index',U),('value',D)]
class Chain(C.Structure):_fields_=[('index',U),('board_temperature',I),('chip_temperature',I),('chip_count',I),('chips',C.POINTER(Chip))]
class Limits(C.Structure):_fields_=[('board',I),('chip',I)]
TL=C.CFUNCTYPE(I,P);SEL=C.CFUNCTYPE(U,P);TLOG=C.CFUNCTYPE(None,P,U,U,I,U);STOP=C.CFUNCTYPE(I,P,C.c_int);EV=C.CFUNCTYPE(I,P,U,I)
class TripOps(C.Structure):_fields_=[('lock',TL),('unlock',TL),('chip_selector',SEL),('log',TLOG),('stop_chain',STOP),('full_airflow',TL),('event',EV)]
OFF={'index':(0x18,4),'address':(0x24,4),'device_id':(0x28,1),'state':(0x2c,4),'access_kind':(0x30,4),'role':(0x34,4),'sample':(0x3c,4),'corrected':(0x40,4),'local_offset':(0x48,4),'remote_offset':(0x4c,4),'remote_enabled':(0x50,1),'skip_initial_read':(0x51,1),'sampled_at':(0x58,8),'failures':(0x60,4),'started_at':(0x68,8),'extended':(0x70,1),'has_previous':(0x71,1),'previous_sample':(0x74,4),'previous_corrected':(0x78,4)}
A=0x840000;S=A+0x800;BK=A+0x2000;MODEL=A+0x4000;CFG=A+0x5000;TYPES=A+0x5800;CHIPS=A+0x6000;LIMITS=A+0x7000;BUS=A+0x7100
# Indirect callee identities live in test RAM, never host code addresses.
CALLS={0x850000:'configure',0x850010:'read',0x850020:'write',0x850030:'finish'}
ALLOWED_CODE=((0xb5f40,0xb71a8),(0xb71a8,0xb73f4),(0xb7400,0xb76c0),
              (0xb76d8,0xb7790),(0xb7798,0xb7fd4),(0xb80a8,0xb8688),
              (0xa720c,0xa7218),(0x58e68,0x5917c),(0x591c8,0x594b0),
              (0x6687c,0x668a8))
class ThermalArm(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if pc and not any(lo<=pc<hi for lo,hi in ALLOWED_CODE):
   raise ValueError("Unapproved executed instruction at %x"%pc)
  if w&0x0fff03f0==0x06af0070: # SXTB with byte rotation
   d=(w>>12)&15;n=w&15
   if 15 in (d,n):raise ValueError('SXTB PC unsupported')
   x=ror(self.get(n,pc),((w>>10)&3)*8)&255;self.r[d]=(x-256 if x>=128 else x)&0xffffffff;return True
  return super().extra_instruction(w,pc)
class Scenario:
 def __init__(self,params=None):self.p=params or {};self.events=[];self.read_n=0;self.time_n=0
 def event(self,*e):self.events.append(tuple(e))
 def now(self):
  v=self.p.get('now',100.0)+self.time_n*self.p.get('time_step',0.125);self.time_n+=1;self.event('now',v);return v
 def read(self,index,reg):
  self.event('read',index,reg);n=self.read_n;self.read_n+=1
  return (self.p.get('read_rc',[-1]*self.p.get('read_failures',0)+[0]*8)[min(n,len(self.p.get('read_rc',[-1]*self.p.get('read_failures',0)+[0]*8))-1)], self.p.get('raw',89),self.p.get('write_read',True))
 def lock(self,name,index):self.event(name,index);return self.p.get('mutex_rc',0)
 def call(self,name,index):self.event(name,index);return self.p.get(name+'_rc',0)
 def write(self,index,reg,v):self.event('write',index,reg,v);return self.p.get('write_rc',{}).get(reg,0)
 def delay(self,v):self.event('delay',v);return self.p.get('delay_rc',0)
 def log(self,*v):self.event('log',*v)
def snapshot(s):
 return tuple(struct.pack('<d',getattr(s,n)) if typ is D else int(getattr(s,n)) for n,typ in s._fields_)
def template(**kw):
 d=dict(index=2,address=76,state=2,access_kind=1,role=0,device_id=26,remote_enabled=0,skip_initial_read=0,extended=0,has_previous=1,sample=50,corrected=54,local_offset=4,remote_offset=-3,failures=1,previous_sample=49,previous_corrected=53,sampled_at=80.0,started_at=50.0);d.update(kw);return Sensor(**d)
def csensor(data):return Sensor.from_buffer_copy(bytes(data))
def c_ops(sc,arr):
 base=C.addressof(arr);stride=C.sizeof(Sensor)
 def idx(ptr):return (C.addressof(ptr.contents)-base)//stride if ptr else -1
 def read(_,s,r,out):
  rc,val,put=sc.read(idx(s),r)
  if put:out[0]=val
  return rc
 cb=[MUT(lambda _,s:sc.lock('init_mutex',idx(s))),MUT(lambda _,s:sc.lock('lock',idx(s))),MUT(lambda _,s:sc.lock('unlock',idx(s))),NOW(lambda _:sc.now()),MUT(lambda _,s:sc.call('configure',idx(s))),RD(read),WR(lambda _,s,r,v:sc.write(idx(s),r,v)),MUT(lambda _,s:sc.call('finish',idx(s))),DELAY(lambda _,v:sc.delay(v)),LOG(lambda _,l,c,i,v:sc.log(l,c,i,v))]
 return Ops(*cb),cb
def put_sensor(a,s,addr):
 a.mem[addr:addr+128]=bytes([0xa5])*128
 for n,(off,size) in OFF.items():
  v=getattr(s,n);a.write(addr+off,int.from_bytes(struct.pack('<d',v),'little') if size==8 else v,size)
def get_sensor(a,addr):
 s=Sensor()
 for n,(off,size) in OFF.items():
  v=a.read(addr+off,size)
  if size==8:v=struct.unpack('<d',v.to_bytes(8,'little'))[0]
  elif dict(Sensor._fields_)[n] is I:v=signed(v)
  setattr(s,n,v)
 return s
def build_arm(elf,sc,sensors):
 a=ThermalArm(elf)
 for off,val in [(A+0x1c,BK),(A+0x18,3),(A+0x290,S),(A+0x2b4,BUS),(BK+0x18,MODEL),(MODEL+0x58,CFG),(CFG,TYPES),(CFG+0x18,len(sensors)),(BK+0x1d0,0x850000),(BK+0x1d4,0x850010),(BK+0x1d8,0x850020),(BK+0x1dc,0x850030)]:a.write(off,val)
 for i,s in enumerate(sensors):put_sensor(a,s,S+i*128)
 def idx(addr):return (addr-S)//128 if S<=addr<S+128*len(sensors) else -1
 def mutex(name):
  def h(a):a.r[0]=sc.lock(name,idx(a.r[0]))&0xffffffff
  return h
 def tm(a):a.set_d(0,sc.now())
 def config(a):a.r[0]=sc.call('configure',idx(a.r[1]-0x1c))&0xffffffff
 def read(a):
  rc,v,put=sc.read(idx(a.r[1]-0x1c),a.r[3]);out=a.read(a.r[13])
  if put:a.write(out,v,1)
  a.r[0]=rc&0xffffffff
 def wr(a):a.r[0]=sc.write(idx(a.r[1]-0x1c),a.r[3],a.read(a.r[13])&255)&0xffffffff
 def finish(a):a.r[0]=sc.call('finish',idx(a.r[1]-0x1c))&0xffffffff
 def delay(a):a.r[0]=sc.delay(a.r[0])&0xffffffff
 def log(a):
  line=a.r[3];sp=a.r[13];sc.log(line,a.read(sp+8),a.read(sp+12),a.read(sp+16) if line==83 else 0);a.r[0]=0
 hooks={0x5a60b8:mutex('init_mutex'),0x5a6108:mutex('lock'),0x5a66c4:mutex('unlock'),0x1ed58:tm,0x850000:config,0x850010:read,0x850020:wr,0x850030:finish,0x10ef3c:delay,0xfa0c4:log}
 return a,hooks
COUNTS={};EVENTS=0

def main():
 global EVENTS
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==ELF_HASH
 evidence=json.loads((ROOT/'integration/evidence/thermal_sensors_135.json').read_text())
 for item in evidence['ranges']:
  lo=int(item['start'],16);hi=int(item['end_exclusive'],16)
  assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==item['sha256'],item['name']
 lib=C.CDLL(str(Path(args.library).resolve()))
 for name in ['reset','accept','initialize','fresh','read_local_path']:
  f=getattr(lib,'vn135_temperature_'+name);f.restype=I;f.argtypes=[SP,C.POINTER(Ops),P]+({'accept':[I,I],'initialize':[U],'fresh':[D]}.get(name,[]))
 lib.vn135_temperature_group_fresh.argtypes=[C.POINTER(Group),C.POINTER(Ops),P];lib.vn135_temperature_group_fresh.restype=I
 lib.vn135_temperature_check_timeouts.argtypes=[C.POINTER(Group),C.POINTER(Ops),P,U,U];lib.vn135_temperature_check_timeouts.restype=I
 lib.vn135_thermal_check_overheat.argtypes=[C.POINTER(Chain),C.POINTER(Limits),C.POINTER(TripOps),P];lib.vn135_thermal_check_overheat.restype=I
 def case(name,s,params=None,extra=()):
  global EVENTS
  ac=Scenario(params);cc=Scenario(params);arr=(Sensor*1)(csensor(s));ops,keep=c_ops(cc,arr)
  a,h=build_arm(elf,ac,[s]);entry={'reset':0xb71a8,'accept':0xb71e4,'initialize':0xb7798,'fresh':0xb76d8,'read_local_path':0xb5f40}[name]
  armargs={'reset':[S],'accept':[A,S,*[int(v)&0xffffffff for v in extra]],'initialize':[A,S],'fresh':[A,S],'read_local_path':[A,S]}[name]
  if name=='initialize':a.write(A+0x18,extra[0])
  if name=='fresh':a.write(CFG+8,int.from_bytes(struct.pack('<d',extra[0]),'little'),8)
  a.reset(armargs);before=bytes(a.mem[S:S+128]);ar=signed(a.run(entry,hooks=h,max_steps=60000));cr=getattr(lib,'vn135_temperature_'+name)(arr,C.byref(ops),None,*extra)
  if name!='reset':assert ar==cr,(name,dict(params or {}),'return',ar,cr)
  sa=get_sensor(a,S);assert snapshot(sa)==snapshot(arr[0]),(name,'state',[(n,getattr(sa,n),getattr(arr[0],n)) for n,_ in Sensor._fields_ if getattr(sa,n)!=getattr(arr[0],n)])
  assert ac.events==cc.events,(name,params,'events',ac.events,cc.events)
  known={i for off,n in OFF.values() for i in range(off,off+n)}
  assert all(a.mem[S+i]==before[i] for i in range(128) if i not in known)
  COUNTS[name]=COUNTS.get(name,0)+1;EVENTS+=len(ac.events)
 rng=random.Random(135)
 for st in [0,1,2,3,4,0xffffffff]:
  case('reset',template(state=st,failures=77,extended=2,has_previous=255),{'mutex_rc':-1})
 for _ in range(300):
  s=template(state=rng.choice([0,1,2,3,4,0xffffffff]),access_kind=rng.choice([0,1,2,4,99]),remote_enabled=rng.choice([0,1,255]),has_previous=rng.choice([0,1,255]),local_offset=rng.choice([-2147483648,4,2147483647]),previous_sample=rng.choice([-2147483648,49,2147483647]))
  case('accept',s,{'mutex_rc':rng.choice([0,-1])},(rng.choice([-2147483648,0,19,20,49,79,80,2147483647]),rng.choice([-2147483648,0,65,2147483647])))
 for kind in [0,1,2,3,4,0xffffffff]:
  for device in [0,26,85,89,255]:
   for remote in [0,1,255]:
    for fail in [0,1,2,3]:case('initialize',template(access_kind=kind,remote_enabled=remote),{'raw':device,'read_failures':fail},(3,))
 for p in [{'configure_rc':-7},{'write_rc':{9:-1}},{'write_rc':{17:-1}},{'finish_rc':-9},{'read_failures':3,'write_read':False}]:
  for kind in [1,2]:case('initialize',template(access_kind=kind,remote_enabled=1),p,(0xffffffff,))
 for kind in [0,1,2,3,4]:
  for st in [0,1,2,3,0xffffffff]:
   for now in [-100.0,80.0,89.999,90.0,90.001,100.0]:case('fresh',template(state=st,access_kind=kind),{'now':now},(10.0,))
 for raw in range(256):case('read_local_path',template(remote_enabled=0),{'raw':raw})
 for st in [0,1,2,3,4,0xffffffff]:
  for errors in [-2147483648,-1,0,1,2,3,2147483647]:
   for fail in [0,3]:case('read_local_path',template(state=st,failures=errors),{'read_failures':fail,'raw':84})
 # Whole group freshness, including nested source getters and mutex operations.
 for _ in range(180):
  count=rng.randrange(0,6);sensors=[template(state=rng.choice([1,2,3]),role=rng.choice([0,1,2]),sampled_at=rng.choice([0.,70.,90.,110.])) for _ in range(count)]
  types=[rng.choice([0,1,2]) for _ in sensors];params={'now':100.0};ac=Scenario(params);cc=Scenario(params)
  arr=(Sensor*max(1,count))(*sensors);types_c=(U*max(1,count))(*types);ops,keep=c_ops(cc,arr);g=Group(arr,types_c,count,10.0)
  a,h=build_arm(elf,ac,sensors)
  for i,t in enumerate(types):a.write(TYPES+i*28,t)
  a.write(CFG+16,int.from_bytes(struct.pack('<d',10.),'little'),8);a.reset((A,));ar=a.run(0xb7400,hooks=h);cr=lib.vn135_temperature_group_fresh(C.byref(g),C.byref(ops),None)
  assert ar==cr,('group',types,[(s.state,s.role,s.sampled_at) for s in sensors],ar,cr)
  assert ac.events==cc.events,('group_events',ac.events,cc.events)
  COUNTS['group_fresh']=COUNTS.get('group_fresh',0)+1;EVENTS+=len(ac.events)
 # Composed original per-sensor and group timeout checks, no preset result.
 for _ in range(240):
  count=rng.randrange(0,5);sensors=[template(index=i,state=rng.choice([1,2,3]),access_kind=rng.choice([1,2,4]),role=rng.choice([0,1,2]),sampled_at=rng.choice([60.,90.,91.,110.])) for i in range(count)]
  types=[rng.choice([0,2]) for _ in sensors];mode=rng.choice([0,1,2,0xffffffff]);ac=Scenario({'time_step':0.});cc=Scenario({'time_step':0.})
  arr=(Sensor*max(1,count))(*sensors);types_c=(U*max(1,count))(*types);ops,keep=c_ops(cc,arr);g=Group(arr,types_c,count,10.,10.)
  a,h=build_arm(elf,ac,sensors)
  for i,t in enumerate(types):a.write(TYPES+i*28,t)
  for off in [8,16]:a.write(CFG+off,int.from_bytes(struct.pack('<d',10.),'little'),8)
  def timeout_log(a):
   sp=a.r[13];line=a.r[3];ac.log(line,a.read(sp+8),a.read(sp+12) if line==1338 else 0,0);a.r[0]=0
  h[0xfa0c4]=timeout_log;a.reset((A,mode));ar=signed(a.run(0x591c8,hooks=h));cr=lib.vn135_temperature_check_timeouts(C.byref(g),C.byref(ops),None,3,mode)
  assert ar==cr and ac.events==cc.events,('timeouts',mode,ar,cr,ac.events,cc.events)
  assert all(snapshot(get_sensor(a,S+i*128))==snapshot(arr[i]) for i in range(count))
  COUNTS['check_timeouts']=COUNTS.get('check_timeouts',0)+1;EVENTS+=len(ac.events)
 # Complete overheat decision with independent original selector helper/getter.
 for pcb in [-2147483648,69,70,71,2147483647]:
  for chip in [89,90,91]:
   for selector in [0,4,7,99]:
    for count in [0,1,4]:
     ac=Scenario();cc=Scenario();values=[(8,10.),(12,11.),(21,11.),(33,9.)][:count];chips=(Chip*max(1,count))(*(Chip(i,v) for i,v in values));chain=Chain(3,pcb,chip,count,chips);limits=Limits(70,90)
     callbacks=[TL(lambda _:cc.lock('chain_lock',0)),TL(lambda _:cc.lock('chain_unlock',0)),SEL(lambda _:(cc.event('selector',selector),selector)[1]),TLOG(lambda _,line,n,t,ix:cc.event('trip_log',line,n,t,ix)),STOP(lambda _,r:(cc.event('stop',r),-7)[1]),TL(lambda _:(cc.event('full'),-9)[1]),EV(lambda _,code,t:(cc.event('event',code,t),-11)[1])];op=TripOps(*callbacks)
     a,h=build_arm(elf,ac,[]);a.write(A+0x29c,pcb);a.write(A+0x2ac,chip);a.write(MODEL+0x48,count);a.write(A+0x88,CHIPS);a.write(LIMITS+0x10,70);a.write(LIMITS+0xc,90)
     for j,(ix,v) in enumerate(values):a.write(CHIPS+j*96,ix);a.write(CHIPS+j*96+88,int.from_bytes(struct.pack('<d',v),'little'),8)
     def tl(a):ac.lock('chain_lock',0);a.r[0]=0
     def tu(a):ac.lock('chain_unlock',0);a.r[0]=0
     def select(a):ac.event('selector',selector);a.r[0]=selector
     def log(a):line=a.r[3];sp=a.r[13];ac.event('trip_log',line,a.read(sp+8),signed(a.read(sp+12)),a.read(sp+16) if line==1307 else 0);a.r[0]=0
     def stop(a):ac.event('stop',0 if a.r[14]==0x58f30 else 1);a.r[0]=0xfffffff9
     def full(a):ac.event('full');a.r[0]=0xfffffff7
     def event(a):ac.event('event',a.r[1],signed(a.r[2]));a.r[0]=0xfffffff5
     h={0x5a6108:tl,0x5a66c4:tu,0xfdfbc:select,0xfa0c4:log,0x56d18:stop,0xf8c70:full,0x49c98:event}
     a.reset((A,LIMITS));ar=signed(a.run(0x58e68,hooks=h));cr=lib.vn135_thermal_check_overheat(C.byref(chain),C.byref(limits),C.byref(op),None)
     assert ar==cr and ac.events==cc.events,('trip',pcb,chip,selector,count,ar,cr,ac.events,cc.events)
     COUNTS['overheat']=COUNTS.get('overheat',0)+1;EVENTS+=len(ac.events)
 # Full source string constructor, no previously decoded text injected.
 a=ThermalArm(elf);a.run(0xb80a8);assert bytes(a.mem[0x5e9167:0x5e9167+len(b"/tmp/build/src/backend/temp.c\0")])==b'/tmp/build/src/backend/temp.c\0'
 # New SXTB extension: byte sign, four rotations, preserve flags and source alias.
 fixtures=0
 for rotation in range(4):
  for byte in range(256):
   a.reset();a.r[2]=ror(byte,32-8*rotation);a.n,a.z,a.c,a.v=True,False,True,False;flags=(a.n,a.z,a.c,a.v)
   assert a.extra_instruction(0xe6af2072|(rotation<<10),0)
   assert a.r[2]==(byte if byte<128 else byte-256)&0xffffffff and flags==(a.n,a.z,a.c,a.v);fixtures+=1
 summary={'counts':COUNTS,'total':sum(COUNTS.values()),'events':EVENTS,'sxtb_fixtures':fixtures,'reference_sha256':ELF_HASH,'executed_instruction_allowlist':True,'source_string_constructor_executed':True,'local_read_only_access_kind_1_remote_disabled':True,'all_sensor_read_routes_recovered':False,'physical_io':False,'physical_shutdown_verified':False,'unresolved_bus_and_stop_bodies':'explicit callbacks'}
 print('THERMAL135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
 if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
