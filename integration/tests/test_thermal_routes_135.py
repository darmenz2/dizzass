#!/usr/bin/env python3
"""Bounded original instruction comparisons. No process/device/thread execution."""
import argparse, collections, ctypes as C, hashlib, json, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed, ror
from test_thermal_sensors_135 import Sensor,Ops,MUT,NOW,RD,WR,DELAY,LOG,template,put_sensor,get_sensor,snapshot,OFF
U=C.c_uint32;I=C.c_int32;B=C.c_uint8;P=C.c_void_p
class Chip(C.Structure):
 _fields_=[('index',U),('word_08',U),('valid',B),('statistics',B*44),('temperature',C.c_double)]
class Chain(C.Structure):
 _fields_=[('index',U),('state',U)]+[(n,B) for n in ['present','auxiliary_enabled','extra_stop_enabled','suppress_chip_samples']]+[('cleared_words',U*4),('statistics',B*44),('local',I*3),('remote',I*3),('local_valid',B),('remote_valid',B),('local_tail',B*3),('remote_tail',B*3),('sensor_count',I),('chip_count',I),('sensors',C.POINTER(Sensor)),('sensor_chip_addresses',C.POINTER(U)),('chips',C.POINTER(Chip)),('reason',C.c_char*512)]
CP=C.POINTER(Chain);CB0=C.CFUNCTYPE(I,P);CBCHAIN=C.CFUNCTYPE(I,P,CP)
RLOG=C.CFUNCTYPE(None,P,I,U,C.POINTER(U),C.c_size_t)
CREATE=C.CFUNCTYPE(I,P,U,C.POINTER(U))
class Rops(C.Structure):
 _fields_=[('temperature',C.POINTER(Ops)),('count',CB0),('supported',CB0),('lock',CBCHAIN),('unlock',CBCHAIN),('overheat',CBCHAIN),('action',CBCHAIN),('create',CREATE),('off',CB0),('log',RLOG)]
class Reply(C.Structure):_fields_=[('chain_index',I),('chip_address',B),('payload',U)]
class Profile(C.Structure):_fields_=[('count',I),('types',C.POINTER(U))]
RESET=C.CFUNCTYPE(I,P,U,U);WAIT=C.CFUNCTYPE(I,P,U,U)
EXCHANGE=C.CFUNCTYPE(I,P,U,U,C.POINTER(B),U,C.POINTER(B),U);IND=C.CFUNCTYPE(I,P,U)
class Stops(C.Structure):_fields_=[('reset',RESET),('delay',WAIT),('exchange',EXCHANGE),('indicator',IND),('lock',CBCHAIN),('unlock',CBCHAIN),('log',RLOG)]
class ResetOps(C.Structure):_fields_=[('gpio',RESET),('log',RLOG)]
DIRECT=C.CFUNCTYPE(I,P,U,U,U,U,C.POINTER(B),U)
PLAT=C.CFUNCTYPE(U,P)
class DirectOps(C.Structure):_fields_=[('temperature',C.POINTER(Ops)),('platform',PLAT),('read',DIRECT),('log',RLOG)]
REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
BK=0x840000;A=0x842000;MODEL=0x843000;DESC=MODEL+0x38;GROUP=0x843400;TYPES=0x843500;RX=0x843800;WHY=0x844000;S=0x845000;CH=0x848000
RANGES=[(0x53da4,0x53eb4),(0x545a0,0x54924),(0x56d18,0x56f94),(0x58700,0x58b38),(0x58df0,0x58e68),(0x5e524,0x5e53c),(0x6687c,0x668a8),(0x78aa4,0x78e64),(0xa720c,0xa7218),(0xb5f40,0xb71a8),(0xb71e4,0xb73f4),(0xfde14,0xfdea4),(0x11bc14,0x11bd3c),(0x590ef0,0x590fbc)]
ENTRIES={'lookup':0x53da4,'accept':0x58df0,'aggregate':0x58700,'reply':0x78aa4,'aux':0x545a0,'stop':0x56d18,'reset':0x11bc14,'direct':0xb5f40}
class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(a<=pc<b for a,b in RANGES):raise ValueError('Unexpected instruction '+hex(pc))
  self.visited.add(pc)
  if pc==0x545a0:
   self.scratch_address=self.r[13]-48
   for i,v in enumerate(self.scratch):self.write(self.scratch_address+i,v,1)
  # Reuse the previously tested finite A32 SXTB model for direct readers.
  if w&0x0fff03f0==0x06af0070:
   d=(w>>12)&15;n=w&15
   if 15 in (d,n):raise ValueError('SXTB PC unsupported')
   x=ror(self.get(n,pc),((w>>10)&3)*8)&255;self.r[d]=(x-256 if x>=128 else x)&0xffffffff;return True
  return super().extra_instruction(w,pc)
class Script:
 def __init__(self,p):self.p=p;self.events=[];self.calls=collections.Counter();self.time_n=0
 def call(self,name,*a):
  i=self.calls[name];self.calls[name]+=1;self.events.append((name,*a))
  r=self.p.get('returns',{}).get(name,0)
  return r[min(i,len(r)-1)] if isinstance(r,list) else r
 def now(self):
  v=100.0+self.time_n/8;self.time_n+=1;self.events.append(('now',v));return v
 def exchange(self,ci,addr,tx,old):
  i=self.calls['exchange'];ret=self.call('exchange',ci,addr,tx,tuple(old))
  pairs=self.p.get('responses',[(21,1)]);v=pairs[min(i,len(pairs)-1)]
  return ret,tuple(old) if v is None else tuple(v)
 def log(self,src,line,args):self.events.append(('log',src,line,tuple(args)))
 def read_direct(self,entry,a,b,reg,old):
  rc=self.call('read_direct',entry,a,b,reg,tuple(old))
  raw=self.p.get('raw',[89,90,91]);n=self.p.get('read_write_length',len(old))
  v=list(old)
  for i in range(min(n,len(old))):v[i]=raw[i%len(raw)]
  return rc,v
def defaults(p):
 n=p.get('sensors',3);k=p.get('chips',3);nc=3
 arrays=[];chains=(Chain*nc)();sensors=[];chiparrays=[];addresses=[]
 for ci in range(nc):
  ss=(Sensor*max(n,1))();cs=(Chip*max(k,1))();ad=(U*max(n,1))()
  for i in range(max(n,0)):
   ss[i]=template(index=i,access_kind=2,state=2,remote_enabled=1,local_offset=4,remote_offset=-3)
   for key,val in p.get('sensor_fields',{}).items():setattr(ss[i],key,val[i%len(val)] if isinstance(val,list) else val)
   ad[i]=p.get('addresses',[16,32,48])[i%len(p.get('addresses',[16,32,48]))]
  for i in range(max(k,0)):
   cs[i].index=i+10;cs[i].word_08=0xb123;cs[i].valid=p.get('chip_valid',[1])[i%len(p.get('chip_valid',[1]))]
   cs[i].temperature=p.get('chip_temperatures',[50.75,60.125,52.5])[i%len(p.get('chip_temperatures',[50.75,60.125,52.5]))]
   cs[i].statistics[:]=[0x56]*44
  c=chains[ci];c.index=p.get('index',ci);c.state=p.get('state',2);c.present=p.get('present',1)
  c.auxiliary_enabled=p.get('aux',1);c.extra_stop_enabled=p.get('extra',1);c.suppress_chip_samples=p.get('suppress',0)
  c.cleared_words[:]=[11,22,33,44];c.statistics[:]=[0x67]*44;c.local[:]=[40,50,60];c.remote[:]=[50,60,70]
  c.local_valid=9;c.remote_valid=8;c.local_tail[:]=[1,2,3];c.remote_tail[:]=[4,5,6]
  c.sensor_count=n;c.chip_count=k;c.sensors=ss;c.chips=cs;c.sensor_chip_addresses=ad
  C.memset(C.addressof(c)+Chain.reason.offset,0x72,512)
  sensors.append(ss);chiparrays.append(cs);addresses.append(ad)
 types=(U*max(n,1))(*([p.get('types',[2])[i%len(p.get('types',[2]))] for i in range(max(n,1))]))
 return chains,sensors,chiparrays,addresses,types
def snapshot_all(chains,sensors,chiparrays):
 result=[]
 for ci,c in enumerate(chains):
  chip=tuple((x.index,x.word_08,x.valid,bytes(x.statistics),struct.pack('<d',x.temperature)) for x in chiparrays[ci][:max(c.chip_count,0)])
  fields=(c.index,c.state,c.present,c.auxiliary_enabled,tuple(c.cleared_words),bytes(c.statistics),tuple(c.local),tuple(c.remote),c.local_valid,c.remote_valid,bytes(c.local_tail),bytes(c.remote_tail),C.string_at(C.addressof(c)+Chain.reason.offset,512))
  result.append((fields,tuple(snapshot(x) for x in sensors[ci][:max(c.sensor_count,0)]),chip))
 return tuple(result)
def bind(lib):
 funcs={
 'vn135_temperature_lookup_chip_135':([CP,U],I),
 'vn135_temperature_accept_chip_135':([CP,I,I,I,C.POINTER(Rops),P],None),
 'vn135_temperature_aggregate_135':([CP,C.POINTER(Rops),P],None),
 'vn135_temperature_reply_135':([C.POINTER(Profile),CP,C.POINTER(Reply),C.POINTER(Rops),P,C.POINTER(U)],I),
 'vn135_chain_auxiliary_stop_135':([CP,C.POINTER(Stops),P,C.POINTER(B)],I),
 'vn135_chain_stop_135':([CP,C.c_char_p,C.POINTER(Stops),P,C.POINTER(B)],I),
 'vn135_chain_reset_aml_135':([U,U,C.POINTER(ResetOps),P],I),
 'vn135_temperature_read_direct_135':([C.POINTER(Sensor),U,C.POINTER(DirectOps),P],I)}
 for name,(a,r) in funcs.items():f=getattr(lib,name);f.argtypes=a;f.restype=r
class Native:
 def __init__(self,lib):self.lib=lib;bind(lib)
 def run(self,entry,p):
  chains,ss,cs,ad,ty=defaults(p);sc=Script(p);errors=[];keep=[]
  def cb(t,fn):
   def f(*args):
    try:return fn(*args)
    except BaseException as e:errors.append(e);return 0
   v=t(f);keep.append(v);return v
  def si(ptr):
   if not ptr:return (-1,-1)
   addr=C.addressof(ptr.contents)
   for ci,ar in enumerate(ss):
    off=addr-C.addressof(ar)
    if 0<=off<C.sizeof(ar) and off%C.sizeof(Sensor)==0:return (ci,off//C.sizeof(Sensor))
   raise ValueError('unexpected sensor')
  def ci(ptr):return (C.addressof(ptr.contents)-C.addressof(chains))//C.sizeof(Chain)
  to=Ops(cb(MUT,lambda *_:sc.call('mutex_init')),cb(MUT,lambda _,s:sc.call('sensor_lock',*si(s))),cb(MUT,lambda _,s:sc.call('sensor_unlock',*si(s))),cb(NOW,lambda _:sc.now()),MUT(),RD(),WR(),MUT(),DELAY(),LOG())
  lg=cb(RLOG,lambda _,src,l,a,n:sc.log(src,l,[a[i] for i in range(n)]))
  def create(_,e,h):
   rc=sc.call('create',e,h[0])
   if p.get('write_handle',True):h[0]=0x1234
   return rc
  ro=Rops(C.pointer(to),cb(CB0,lambda _:sc.call('count') or p.get('chain_count',3)),cb(CB0,lambda _:sc.call('supported') or int(p.get('selector',2) in (4,7))),cb(CBCHAIN,lambda _,c:sc.call('chain_lock',ci(c))),cb(CBCHAIN,lambda _,c:sc.call('chain_unlock',ci(c))),cb(CBCHAIN,lambda _,c:sc.call('overheat',ci(c))),cb(CBCHAIN,lambda _,c:sc.call('action',ci(c))),cb(CREATE,create),cb(CB0,lambda _:sc.call('power_stop')),lg)
  def ex(_,idx,addr,tx,tn,rx,rn):
   assert rn==2
   rc,out=sc.exchange(idx,addr,bytes(tx[:tn]),rx[:2]);rx[0],rx[1]=out;return rc
  reset=ResetOps(cb(RESET,lambda _,pin,v:sc.call('gpio',pin,v)),lg)
  stop=Stops(cb(RESET,lambda _,idx,v:self.lib.vn135_chain_reset_aml_135(idx,v,C.byref(reset),None)),cb(WAIT,lambda _,e,t:sc.call('delay',e,t)),cb(EXCHANGE,ex),cb(IND,lambda _,v:sc.call('indicator',v)),ro.lock,ro.unlock,lg)
  def direct_read(_,entry,a,b,reg,out,n):
   rc,v=sc.read_direct(entry,a,b,reg,out[:n])
   for i,value in enumerate(v):out[i]=value
   return rc
  direct=DirectOps(C.pointer(to),cb(PLAT,lambda _:sc.call('platform') or p.get('platform',0)),cb(DIRECT,direct_read),lg)
  scratch=(B*2)(*p.get('scratch',[0x12,0x34]));handle=U(p.get('thread_seed',0x42));c=C.byref(chains[0])
  r=Reply(p.get('chain_index',0),p.get('address',32),p.get('payload',0x003c0146));profile=Profile(chains[0].sensor_count,ty)
  if entry=='lookup':rc=self.lib.vn135_temperature_lookup_chip_135(c,p.get('address',32))
  elif entry=='accept':rc=self.lib.vn135_temperature_accept_chip_135(c,p.get('sensor_index',1),p.get('sample',65),p.get('second',75),C.byref(ro),None)
  elif entry=='aggregate':rc=self.lib.vn135_temperature_aggregate_135(c,C.byref(ro),None)
  elif entry in ('reply','late'):
   if entry=='late':self.lib.vn135_chain_stop_135(c,p.get('reason',b'thermal stop'),C.byref(stop),None,scratch)
   rc=self.lib.vn135_temperature_reply_135(C.byref(profile),chains,C.byref(r),C.byref(ro),None,C.byref(handle))
  elif entry=='aux':rc=self.lib.vn135_chain_auxiliary_stop_135(c,C.byref(stop),None,scratch)
  elif entry=='stop':rc=self.lib.vn135_chain_stop_135(c,p.get('reason',b'thermal stop'),C.byref(stop),None,scratch)
  elif entry=='direct':rc=self.lib.vn135_temperature_read_direct_135(C.byref(ss[0][0]),chains[0].index,C.byref(direct),None)
  elif entry=='reset':rc=self.lib.vn135_chain_reset_aml_135(p.get('index',0),p.get('asserted',1),C.byref(reset),None)
  else:raise ValueError(entry)
  if errors:raise errors[0]
  return rc,snapshot_all(chains,ss,cs),tuple(sc.events)
class Original:
 def __init__(self,elf):self.elf=elf
 def run(self,entry,p):
  chains,ss,cs,ad,ty=defaults(p);sc=Script(p);m=Machine(self.elf);m.visited=set();m.scratch=p.get('scratch',[0x12,0x34])
  m.write(BK+0x18,MODEL);m.write(MODEL+0x58,DESC);m.write(DESC+0x20,GROUP);m.write(GROUP,TYPES);m.write(GROUP+0x18,chains[0].sensor_count);m.write(DESC+0x10,chains[0].chip_count)
  m.write(DESC+0x4f,chains[0].extra_stop_enabled,1);m.write(BK+0xf7,chains[0].suppress_chip_samples,1);m.write(BK+0x230,A)
  m.write(0x654b5c,0x11bc14)
  watched=[]
  for i in range(max(chains[0].sensor_count,0)):m.write(TYPES+i*28,ty[i])
  for ci,c in enumerate(chains):
   a=A+ci*800;sbase=S+ci*0x800;cp=CH+ci*0x400
   m.mem[a:a+800]=b'\xa5'*800;m.write(a+0x1c,BK);m.write(a+0x18,c.index);m.write(a+0x20,c.state);m.write(a+0x24,c.present,1);m.write(a+0x25,c.auxiliary_enabled,1)
   m.write(a+0x290,sbase);m.write(a+0x88,cp);m.write(a+0x2b4,0x849f00)
   for j,off in enumerate((0x28,0x30,0x34,0x38)):m.write(a+off,c.cleared_words[j])
   m.mem[a+0x40:a+0x6c]=bytes(c.statistics);m.mem[a+0x90:a+0x290]=b'r'*512
   for j in range(3):m.write(a+0x294+4*j,c.local[j]);m.write(a+0x2a4+4*j,c.remote[j])
   for off,v in [(0x2a0,c.local_valid),(0x2b0,c.remote_valid)]:m.write(a+off,v,1)
   m.mem[a+0x2a1:a+0x2a4]=bytes(c.local_tail);m.mem[a+0x2b1:a+0x2b4]=bytes(c.remote_tail)
   watched.append((a,800,bytes(m.mem[a:a+800]),set(range(0x20,0x24))|{0x25}|set(range(0x28,0x2c))|set(range(0x30,0x3c))|set(range(0x40,0x6c))|set(range(0x90,0x290))|set(range(0x294,0x2b4))))
   for j,s in enumerate(ss[ci][:max(c.sensor_count,0)]):
    at=sbase+j*128;put_sensor(m,s,at);m.write(at+0x20,ad[ci][j])
    mutable=set().union(*(set(range(off,off+n)) for key,(off,n) in OFF.items() if key not in ['index','address','device_id','access_kind','role','local_offset','remote_offset','remote_enabled','skip_initial_read','extended']))
    watched.append((at,128,bytes(m.mem[at:at+128]),mutable))
   for j,x in enumerate(cs[ci][:max(c.chip_count,0)]):
    at=cp+j*96;m.mem[at:at+96]=b'\xa7'*96;m.write(at,x.index);m.write(at+8,x.word_08);m.write(at+0x50,x.valid,1);m.mem[at+0x18:at+0x44]=bytes(x.statistics);m.mem[at+0x58:at+0x60]=struct.pack('<d',x.temperature)
    watched.append((at,96,bytes(m.mem[at:at+96]),set(range(8,12))|set(range(0x18,0x44))|{0x50}|set(range(0x58,0x60))))
  def ci(addr):
   assert A<=addr<A+2400 and (addr-A)%800==0
   return (addr-A)//800
  def si(addr):
   for j in range(3):
    off=addr-(S+j*0x800)
    if 0<=off<max(chains[j].sensor_count,0)*128 and off%128==0:return j,off//128
   return None
  def ret(v):m.r[0]=int(v)&0xffffffff
  def mutex(name):
   def f(_):
    pair=(-1,-1) if m.r[0]==0x849f00 else si(m.r[0])
    ret(sc.call('sensor_'+name,*pair) if pair else sc.call('chain_'+name,ci(m.r[0])))
   return f
  def clock(_):m.set_d(0,sc.now())
  def selector(_):sc.call('supported');ret(p.get('selector',2))
  def log(_):
   line=m.r[3];sp=m.r[13]
   source=4 if line in (401,425) else 0 if line in (1577,1595,1603,6483) else 1 if line in (1840,1843) else 2 if line==395 else 3
   if source!=4:
    assert m.r[1]=={0:0x5e50be,1:0x5e4267,2:0x5e4267,3:0x5ee737}[source], ('source path',line,hex(m.r[1]))
   n={1577:1,1595:6,1603:0,6483:0,1840:1,1843:1,395:4,130:1,401:0,425:1}[line]
   sc.log(source,line,[m.read(sp+8+i*4) for i in range(n)]);ret(0)
  def exchange(_):
   assert m.r[0]==0x849f00 and m.r[3]==7 and m.read(m.r[13]+4)==2
   out=m.read(m.r[13]);idx=chains[0].index
   rc,pair=sc.exchange(idx,m.r[1],bytes(m.mem[m.r[2]:m.r[2]+7]),m.mem[out:out+2]);m.write(out,pair[0],1);m.write(out+1,pair[1],1);ret(rc)
  def memset(_):
   dest,v,n=m.r[:3];m.check(dest,n);m.mem[dest:dest+n]=bytes([v&255])*n;ret(dest)
  def copy_reason(_):
   assert m.r[1]==WHY and m.r[2]==512
   n=min(len(p.get('reason',b'thermal stop')),511);m.mem[m.r[0]:m.r[0]+n+1]=p.get('reason',b'thermal stop')[:n]+b'\0';ret(m.r[0])
  def create(_):
   assert m.r[1]==0 and m.r[3]==BK
   rc=sc.call('create',m.r[2],m.read(m.r[0]));
   if p.get('write_handle',True):m.write(m.r[0],0x1234)
   ret(rc)
  def direct_read(ep):
   def h(_):
    assert m.r[0]==0x849f00
    if ep==0xfe440:out=m.r[3];n=m.read(m.r[13]);second=0;reg=m.r[2]
    else:out=m.read(m.r[13]);n=m.read(m.r[13]+4);second=m.r[2];reg=m.r[3]
    rc,values=sc.read_direct(ep,m.r[1],second,reg,m.mem[out:out+n]);m.mem[out:out+n]=bytes(values);ret(rc)
   return h
  hooks={0xfe668:lambda _:ret(sc.call('count') or p.get('chain_count',3)),0x5a6108:mutex('lock'),0x5a66c4:mutex('unlock'),0x1ed58:clock,0xfdfbc:selector,0xfa0c4:log,
         0x58e68:lambda _:ret(sc.call('overheat',ci(m.r[0]))),0x5e53c:lambda _:ret(sc.call('action',p.get('chain_index',0))),0x5a55cc:create,0x6b778:lambda _:ret(sc.call('power_stop')),
         0x124ba4:lambda _:ret(sc.call('gpio',m.r[0],m.r[1])),0xfada0:exchange,0x10ed2c:lambda _:ret(sc.call('delay',0x10ed2c,m.r[0])),0x10ef3c:lambda _:ret(sc.call('delay',0x10ef3c,m.r[0])),0xf9840:lambda _:ret(sc.call('indicator',m.r[0])),0x5a348c:memset,0x10f128:copy_reason}
  hooks.update({ep:direct_read(ep) for ep in [0xfaeec,0xfe440,0xfe528]});hooks[0xfdfac]=lambda _:ret(sc.call('platform') or p.get('platform',0))
  why=p.get('reason',b'thermal stop');m.mem[WHY:WHY+len(why)+1]=why+b'\0'
  def execute(which):
   args={'lookup':(A,p.get('address',32)),'accept':(A,p.get('sensor_index',1),p.get('sample',65),p.get('second',75)),'aggregate':(A,),'reply':(BK,RX),'aux':(A,),'stop':(A,WHY),'reset':(p.get('index',0),p.get('asserted',1)),'direct':(A,S)}[which]
   m.reset(args)
   if which=='reply':m.write(m.STACK_TOP-40,p.get('thread_seed',0x42))
   return m.run(ENTRIES[which],hooks=hooks,max_steps=50000)
  m.write(RX,p.get('chain_index',0));m.write(RX+4,p.get('address',32),1);m.write(RX+8,p.get('payload',0x003c0146))
  if entry=='late':execute('stop');rv=execute('reply')
  else:rv=execute(entry)
  if entry in ('aggregate','accept'):rv=None
  elif entry=='lookup':rv=(rv-S)//128 if rv else -1
  else:rv=signed(rv)
  for ci_,c in enumerate(chains):
   a=A+ci_*800;sp=S+ci_*0x800;cp=CH+ci_*0x400
   c.state=m.read(a+0x20);c.auxiliary_enabled=m.read(a+0x25,1)
   c.cleared_words[:]=[m.read(a+x) for x in (0x28,0x30,0x34,0x38)];c.statistics[:]=m.mem[a+0x40:a+0x6c]
   c.local[:]=[signed(m.read(a+0x294+4*j)) for j in range(3)];c.remote[:]=[signed(m.read(a+0x2a4+4*j)) for j in range(3)]
   c.local_valid=m.read(a+0x2a0,1);c.remote_valid=m.read(a+0x2b0,1);c.local_tail[:]=m.mem[a+0x2a1:a+0x2a4];c.remote_tail[:]=m.mem[a+0x2b1:a+0x2b4]
   C.memmove(C.addressof(c)+Chain.reason.offset,bytes(m.mem[a+0x90:a+0x290]),512)
   for j in range(max(c.sensor_count,0)):ss[ci_][j]=get_sensor(m,sp+j*128)
   for j in range(max(c.chip_count,0)):
    x=cs[ci_][j];at=cp+j*96;x.word_08=m.read(at+8);x.valid=m.read(at+0x50,1);x.statistics[:]=m.mem[at+0x18:at+0x44];x.temperature=struct.unpack('<d',m.mem[at+0x58:at+0x60])[0]
  for at,n,old,mutable in watched:
   for j in range(n):
    if j not in mutable and m.mem[at+j]!=old[j]:raise AssertionError(('unmodeled mutation',hex(at+j)))
  return rv,snapshot_all(chains,ss,cs),tuple(sc.events)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==REF
 evidence=json.loads((ROOT/'integration/evidence/thermal_routes_135.json').read_text())
 assert evidence['reference_sha256']==REF
 for r in evidence['ranges']:
  lo=int(r['start'],16);hi=int(r['end_exclusive'],16)
  assert hashlib.sha256(elf.read(lo,hi-lo)).hexdigest()==r['sha256']
 for d in evidence['data']+evidence['source_paths']:
  raw=elf.read(int(d['address'],16),d['size'])
  assert hashlib.sha256(raw).hexdigest()==d['sha256']
  if 'xor_key' in d:assert bytes(x^d['xor_key'] for x in raw).decode('ascii')==d['path']
 assert struct.unpack('<3I',elf.read(0x5b29d8,12))==(454,455,456)
 from test_aml_fans_135 import FanArm,RANGES as PLATFORM_RANGES
 machine=FanArm(elf);machine.allowed=PLATFORM_RANGES;machine.visited=set()
 machine.reset((2,));machine.run(0xfb994,stop=0xfd784,max_steps=30000)
 assert machine.read(0x654b5c)==0x11bc14
 del machine
 original=Original(elf);native=Native(C.CDLL(str(Path(args.library).resolve())));counts=collections.Counter();events=0
 def test(entry,**p):
  nonlocal events
  x=original.run(entry,p);y=native.run(entry,p)
  if x!=y:
   print('MISMATCH',entry,p,'returns',x[0],y[0]);print('events',x[2],y[2]);print('state difference',[(i,a,b) for i,(a,b) in enumerate(zip(x[1],y[1])) if a!=b]);raise AssertionError(entry)
  counts[entry]+=1;events+=len(x[2])
 for e in ENTRIES:
  if e!='direct':test(e)
 for idx in [0,1,2,3,7,0xffffffff]:
  for value in [0,1,2,3,255,0xffffffff]:
   for rc in [0,-1,5]:test('reset',index=idx,asserted=value,returns={'gpio':rc})
 for kind in range(6):
  for state in [0,1,2,3,4,5,0xffffffff]:
   for addr in [16,32,48,255,256]:test('lookup',address=addr,sensor_fields={'access_kind':kind,'state':state})
 for state in [0,1,2,3,4,5,6,0xffffffff]:
  for present in [0,1,255]:
   for idx in [-1,0,1,2,3,0x7fffffff]:test('accept',state=state,present=present,sensor_index=idx)
 for remote in [0,1,255]:
  for error in [0,1,128,255]:
   for status in [0,1,2,255]:
    for local in [0,64,128,255]:test('reply',payload=(error<<24)|(local<<16)|(status<<8)|241,sensor_fields={'remote_enabled':remote})
 for rc in [0,1,-1]:
  for cr in [0,1,-1]:
   for state in [0,1,2,3,4,5,6]:test('reply',state=state,returns={'overheat':rc,'create':cr,'action':-2,'power_stop':-3})
 for idx in [-1,0,1,2,3,0x7fffffff]:
  for n in [0,1,3]:test('reply',chain_index=idx,sensors=n)
 for states in [[3,3,3],[1,2,3],[2,2,2]]:
  for sel in [2,4,7]:
   for sup in [0,1]:
    for values in [[-2.75,3.75,4.25],[2147483647.5,-2147483648.5,0.5]]:
     test('aggregate',sensor_fields={'state':states,'sample':[2147483647,2147483647,-1],'corrected':[-2147483648,-2147483648,0]},selector=sel,suppress=sup,chip_temperatures=values)
 for n in [-1,0,1,3]:
  for k in [0,1,3]:test('aggregate',sensors=n,chips=k,selector=4)
 for slot in [0,1,2,3,0xffffffff]:test('reply',sensor_fields={'index':slot})
 for types in [[0],[1],[2],[4],[0,2,4]]:test('reply',types=types)
 for responses in [[(21,1)],[(0,0),(21,1)],[(0,0),(0,0),(21,1)],[(21,0)],[(0,1)],[None]]:
  for seed in [(0,0),(21,1),(255,255)]:
   for rc in [0,-1,7]:
    for e in ['aux','stop']:test(e,responses=responses,scratch=seed,returns={'exchange':rc,'chain_unlock':-9,'gpio':-1})
 for reason in [b'',b'x',b'x'*511,b'x'*512,b'x'*777]:
  for n in [0,1,3]:
   for extra in [0,1]:test('stop',reason=reason,chips=n,extra=extra)
 for present in [0,1,255]:
  for aux in [0,1,255]:
   test('stop',present=present,aux=aux,responses=[None]);test('late',present=present,aux=aux)
 for kind in [0,3]:
  for platform in [0,2]:
   for ext in [0,1]:
    for raw in range(256):test('direct',sensor_fields={'access_kind':kind,'remote_enabled':0,'extended':ext},platform=platform,raw=[raw])
  for state in [0,1,2,3,4,0xffffffff]:
   for failures in [-1,0,1,2,3,2147483647]:
    for rc in [0,-1,7]:test('direct',sensor_fields={'access_kind':kind,'state':state,'failures':failures,'remote_enabled':0},returns={'read_direct':rc},read_write_length=0)
  for remote in [1,255]:test('direct',sensor_fields={'access_kind':kind,'remote_enabled':remote})
  for idx in [0,1,7,255,256,0xffffffff]:test('direct',index=idx,sensor_fields={'access_kind':kind,'remote_enabled':0,'address':0xffffffff})
 rng=random.Random(135);vals=[0,1,2,3,4,5,7,0xffffffff]
 for _ in range(100):
  test('reply',state=rng.choice(vals),present=rng.randrange(2),selector=rng.choice([2,4,7]),payload=rng.getrandbits(32),sensor_fields={'index':[rng.choice(vals) for _ in range(3)],'state':[rng.choice(vals) for _ in range(3)]})
 result={'reference_sha256':REF,'counts':dict(counts),'total':sum(counts.values()),'events':events,'original_lookup_accept_aggregate_reply_stop':True,'physical_io':False,'real_threads':False,'overheat_and_gpio_write_boundaries':'scripted in differential suite','all_synchronous_reader_routes':False,'new_arm_instructions':0,'aml_reset_dispatch_prefix_executed':True,'source_path_bytes_and_log_pointers_checked':True,'source_string_constructors_executed':False}
 print('THERMAL_ROUTES135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
 if args.summary:Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
