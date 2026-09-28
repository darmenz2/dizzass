#!/usr/bin/env python3
"""0x7409c -> actual original PSU init/exchange/calibration, with scripted bus.
The current repository PSU API is required unless --allow-archive is explicit.
"""
import argparse,ctypes as C,json,struct,hashlib,itertools,collections
from pathlib import Path
from backend_prepare_135_oracle import Oracle as PrepareOracle,RANGES,B,MASK
from test_backend_prepare_135 import Native as PrepareNative
from psu_setup_135_oracle import SetupArm
from test_psu_protocol_135 import Voltage,Protocol,Ops,LOCK,BLOCK,WRITE,READ,DELAY,LOG,U8,U32,I32,P8
S=0x654c30;BUS=0x847000;DEVICE=B+0x108c
class Cal(C.Structure):
 _fields_=[('lower',I32),('upper',I32),('enabled',U8),('count',U32),('x',C.c_double*15),('y',C.c_double*15)]
class Identity(C.Structure):_fields_=[('initial_word',U32),('date_word',U32),('serial',U8*18)]
GET=C.CFUNCTYPE(U32,C.c_void_p,U32)
class InitOps(C.Structure):_fields_=[('select_bus_kind',GET),('mutex_init',LOCK)]
class Scratch(C.Structure):_fields_=[('response',U8*40),('auxiliary',U8*14)]
class Archive(C.Structure):
 _fields_=[('initial_word',U32),('enabled',U8),('lower',I32),('upper',I32),('serial',U8*18),('count',U32),('x',C.c_double*15),('y',C.c_double*15),('date_word',U32)]
def checksum(mode,r):
 n=len(r)
 return (sum(r[2:n-2]) if not mode else sum(r[i]|(r[i+1]<<8) for i in range(2,n-2,2)))&65535
def crc16(data):
 x=65535
 for b in data:
  x^=b
  for _ in range(8):x=(x>>1)^(0xa001 if x&1 else 0)
 return x
class Wire:
 def __init__(self,model,bad,cal):
  self.model=model;self.bad=bad;self.cal=cal;self.events=[];self.pending=bytearray()
  self.counts=collections.Counter();self.response=None;self.tx=b'';self.index=0
 def wb(self,a,m,r,data):self.events.append(('wb',a,m,r,data));self.pending=bytearray(data)
 def wy(self,a,m,r,v):self.events.append(('wy',a,m,r,v));self.pending.append(v&255)
 def delay(self,v):
  self.events.append(('delay',v))
  if v==400:
   self.tx=bytes(self.pending);self.pending.clear();self.index=0;self.response=None
   self.counts[self.tx[3]]+=1
 def reply(self,n,mode):
  r=bytearray(n);r[:2]=self.tx[:2];r[2]=n-2;r[3]=self.tx[3];cmd=self.tx[3]
  if cmd==2:r[4:6]=struct.pack('<H',self.model)
  elif cmd==1:r[4:6]=b'\x04\x00'
  elif cmd in (10,14):r[8:12]=b'\x12\x34\x56\x78'
  elif cmd==6:
   off=5 if len(self.tx)==8 else 6
   r[off:off+12]=bytes.fromhex('00123456789abcde12345678')
   r[off+12:off+14]=(123).to_bytes(2,'big');r[off+14:off+28]=bytes([2]*14)
   r[off+17]=128;r[off+28:off+30]=(10000).to_bytes(2,'big')
   v=crc16(r[off:off+30]);r[off+30:off+32]=v.to_bytes(2,'big')
   if self.cal=='bad':r[off+30]^=1
  v=checksum(mode,r)
  if mode and n&1:v=(v+256*(v&255))&65535
  r[-2:]=struct.pack('<H',v)
  if cmd==2 and self.counts[cmd]<=self.bad:r[0]^=255
  return bytes(r)
 def rb(self,a,m,r,n,mode):self.events.append(('rb',a,m,r,n));return self.reply(n,mode)
 def ry(self,a,m,r,mode):
  self.events.append(('ry',a,m,r))
  if self.response is None:
   n={1:8,2:8,6:39 if len(self.tx)==8 else 40,10:14,14:14}[self.tx[3]]
   self.response=self.reply(n,mode)
  value=self.response[self.index];self.index+=1;return value
class MixedArm(SetupArm):
 def extra_instruction(self,w,pc):
  if pc==0x100fc4:self.observe_initialize(self)
  return super().extra_instruction(w,pc)
def original(o,case,wire,kind):
 def augment(m,hooks,invoke):
  del hooks[0x100fc4]
  evidence=json.loads((Path(__file__).parents[1]/'evidence/psu_setup_135.json').read_text())
  protocol=json.loads((Path(__file__).parents[1]/'evidence/psu_protocol_135.json').read_text())
  m.allowed=RANGES+[(int(x['start'],16),int(x['end_exclusive'],16)) for x in evidence['ranges']+protocol['ranges']]
  # Shared code ranges include original checksum/serial/grid helpers.
  m.allowed += [(0xffff8,0x102bd0),(0x105d30,0x105f58),(0xf7e90,0xf7f10),(0x596778,0x596818)]
  for e in (evidence,protocol):
   assert hashlib.sha256(o.elf.data).hexdigest()==e['reference_sha256']
   for x in e['ranges']:
    a,b=int(x['start'],16),int(x['end_exclusive'],16)
    assert hashlib.sha256(o.elf.read(a,b-a)).hexdigest()==x['sha256']
  m.mem[S:S+0x134]=b'\0'*0x134;m.write(S+4,34,2);m.write(S+8,4)
  m.mem[BUS:BUS+64]=b'\0'*64;m.write(BUS+24,kind)
  def observe(mm):
   assert mm.r[0]==DEVICE
   invoke('psu',tuple(mm.r[1:4]))
  m.observe_initialize=observe
  oldlock=hooks[0x5a6108];oldunlock=hooks[0x5a66c4];oldlog=hooks[0xfa0c4]
  def bus(mm):wire.events.append(('get_bus',mm.r[0]));mm.r[0]=BUS
  def init(mm):assert mm.r[:2]==[DEVICE,0];wire.events.append(('init',));mm.r[0]=0
  def lock(mm):
   if mm.r[0]!=DEVICE:return oldlock(mm)
   wire.events.append(('lock',));mm.r[0]=0
  def unlock(mm):
   if mm.r[0]!=DEVICE:return oldunlock(mm)
   wire.events.append(('unlock',));mm.r[0]=0
  def wb(mm):
   assert mm.r[0]==BUS;ptr,n=mm.read(mm.r[13]),mm.read(mm.r[13]+4)
   wire.wb(*mm.r[1:4],bytes(mm.mem[ptr:ptr+n]));mm.r[0]=0
  def rb(mm):
   assert mm.r[0]==BUS;ptr,n=mm.read(mm.r[13]),mm.read(mm.r[13]+4)
   data=wire.rb(*mm.r[1:4],n,mm.read(S+12));mm.mem[ptr:ptr+n]=data;mm.r[0]=0
  def wy(mm):assert mm.r[0]==BUS;wire.wy(*mm.r[1:4],mm.read(mm.r[13]));mm.r[0]=0
  def ry(mm):assert mm.r[0]==BUS;mm.r[0]=wire.ry(*mm.r[1:4],mm.read(S+12))
  def delay(mm):wire.delay(mm.r[0]);mm.r[0]=0
  dumps={}
  def fmt(mm):dest,cap,ptr,n=mm.r[:4];assert cap==1024;dumps[dest]=bytes(mm.mem[ptr:ptr+n]);mm.r[0]=0
  def log(mm):
   if not 0x100000<=mm.r[14]<0x106000:return oldlog(mm)
   line=mm.r[3];a=b=0;data=b''
   if line in (515,519,540,868):a=mm.read(mm.r[13]+8)
   elif line==957:a=mm.read(mm.r[13]+8);b=mm.read(mm.r[13]+12)
   elif line in (937,939):data=dumps[mm.read(mm.r[13]+8)]
   elif line in (768,813):ptr=mm.read(mm.r[13]+8);data=bytes(mm.mem[ptr:ptr+17])
   wire.events.append(('log',line,a,b,data));mm.r[0]=0
  def divide(mm):
   assert mm.r[2:4]==[36,0];v=(mm.r[0]|mm.r[1]<<32)//36;mm.r[0]=v&MASK;mm.r[1]=v>>32
  hooks.update({0xfe420:bus,0x5a60dc:init,0x5a6108:lock,0x5a66c4:unlock,0xfe538:wb,0xfe528:rb,
   0x126fcc:wy,0x128188:ry,0x10ed2c:delay,0x10f170:fmt,0xfa0c4:log,0x591480:divide})
  return set(range(DEVICE+24,DEVICE+29))
 result=o.run(case,augment=augment)
 m=o.m
 data=(m.read(S),m.read(S+296),bytes(m.mem[S+29:S+47]),m.read(S+16,1),m.read(S+48),
       bytes(m.mem[S+56:S+176]),bytes(m.mem[S+176:S+296]),m.read(S+12),m.read(S+4,2),m.read(S+8))
 assert 0x100fc4 in m.visited and 0x102bd0 in m.visited
 return result,data
class PSU:
 def __init__(self,path,allow_archive=False):
  self.lib=C.CDLL(str(Path(path).resolve()));self.current=hasattr(self.lib,'vn135_psu_initialize')
  if not self.current and not allow_archive:raise RuntimeError('Current PSU API required; archival fallback is opt-in only')
  if self.current:
   self.fn=self.lib.vn135_psu_initialize
   self.fn.argtypes=[C.POINTER(Protocol),C.POINTER(Cal),C.POINTER(Identity),I32,I32,U32,C.POINTER(InitOps),C.POINTER(Scratch)]
  else:
   self.fn=self.lib.vn135_psu_identify_calibrate
   self.fn.argtypes=[C.POINTER(Protocol),C.POINTER(Archive),C.POINTER(InitOps),I32,I32,U32,P8,P8]
  self.fn.restype=I32
 def run(self,wire,kind,lo,hi,mode):
  errors=[]
  def safe(fn):
   def wrap(*args):
    try:return fn(*args)
    except Exception as e:errors.append(e);return -999
   return wrap
  def lock(_):wire.events.append(('lock',));return 0
  def unlock(_):wire.events.append(('unlock',));return 0
  def wb(_,a,m,r,data,n):wire.wb(a,m,r,C.string_at(data,n));return 0
  def rb(_,a,m,r,data,n):C.memmove(data,wire.rb(a,m,r,n,p.checksum_mode),n);return 0
  def wy(_,a,m,r,value):wire.wy(a,m,r,value);return 0
  def ry(_,a,m,r):return wire.ry(a,m,r,p.checksum_mode)
  def delay(_,v):wire.delay(v);return 0
  def log(_,line,a,b,data,n):wire.events.append(('log',line,a,b,C.string_at(data,n) if n else b''))
  ops=Ops(LOCK(safe(lock)),LOCK(safe(unlock)),BLOCK(safe(wb)),BLOCK(safe(rb)),WRITE(safe(wy)),READ(safe(ry)),DELAY(safe(delay)),LOG(safe(log)))
  p=Protocol(mode,kind,16,Voltage(34,4,0,0,0),C.pointer(ops),None)
  def bus(_,index):wire.events.append(('get_bus',index));return kind
  def init(_):wire.events.append(('init',));return 0
  io=InitOps(GET(safe(bus)),LOCK(safe(init)));scratch=Scratch()
  if self.current:
   s=Cal();identity=Identity();rc=self.fn(C.byref(p),C.byref(s),C.byref(identity),lo,hi,mode,C.byref(io),C.byref(scratch))
  else:
   s=Archive();identity=s;rc=self.fn(C.byref(p),C.byref(s),C.byref(io),lo,hi,mode,scratch.response,scratch.auxiliary)
  if errors:raise errors[0]
  data=(identity.initial_word,identity.date_word,bytes(identity.serial),s.enabled,s.count,bytes(s.x),bytes(s.y),p.checksum_mode,p.voltage.model,p.voltage.word_08)
  return rc,data
def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--allow-archive',action='store_true');ap.add_argument('--summary');args=ap.parse_args()
 o=PrepareOracle();o.m=MixedArm(o.elf);pn=PrepareNative(Path(args.library).resolve());psu=PSU(args.library,args.allow_archive)
 n=events=0
 for kind,mode,model,bad,cal in itertools.product([0,1],[0,1],[34,193,65535],[0,3,6],['good','bad']):
  case={'fields':{'word_14':mode,'mode_50':2}}
  ow=Wire(model,bad,cal);expected,data=original(o,case,ow,kind)
  nw=Wire(model,bad,cal);saved=[]
  def initialize(lo,hi,m):
   result=psu.run(nw,kind,lo,hi,m);saved.append(result);return result[0]
  actual=pn.run(case,psu_initializer=initialize)
  for key in ('rc','state','events','calls'):assert expected[key]==actual[key],(key,kind,mode,model,bad,cal)
  assert len(saved)==1 and saved[0][1]==data,(kind,mode,model,bad,cal,'PSU state',saved[0][1],data)
  assert ow.events==nw.events,(kind,mode,model,bad,cal,'wire',ow.events,nw.events)
  n+=1;events+=len(ow.events)+len(expected['events'])
 out={'cases':n,'compared_events':events,'psu_api':'current' if psu.current else 'archival-explicit-opt-in',
 'original_prepare_initialize_exchange_calibration':True,'physical_psu':False,'real_threads':False}
 if args.summary:Path(args.summary).write_text(json.dumps(out,indent=2)+'\n')
 print('BACKEND_PREPARE_PSU135_PASS',json.dumps(out,sort_keys=True))
if __name__=='__main__':main()
