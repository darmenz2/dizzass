#!/usr/bin/env python3
"""Original synchronous reader + original AML SMBus bodies vs composed C.
Byte/word transaction output sizes follow Linux UAPI. The kernel/device effects
are scenarios; no firmware process, real bus or actual sensor is accessed.
"""
import argparse,ctypes as C,hashlib,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
import test_thermal_reader_135 as reader
import test_thermal_sensors_135 as thermal
import test_aml_smbus_135 as sm
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
from elf32 import ELF32
from test_thermal_routes_135 import Chain,CP
P=C.c_void_p;U=C.c_uint32;I=C.c_int32;B=C.c_uint8
A,S,BK,MODEL,BUS=thermal.A,thermal.S,thermal.BK,thermal.MODEL,thermal.BUS
class Machine(reader.ReaderArm):
 def extra_instruction(self,w,pc):
  if any(a<=pc<b for a,b in sm.ALLOWED) or 0x58d08<=pc<0x58de8 or 0xa720c<=pc<0xa7218:
   return ARM32Difficulty.extra_instruction(self,w,pc)
  return super().extra_instruction(w,pc)
class Script:
 def __init__(self,p):self.p=p;self.events=[];self.addr_n=0;self.select_n=0;self.tx_n=0;self.times=0
 def event(self,*a):self.events.append(a)
 def value(self,name,n,default):v=self.p.get(name,[default]);return v[min(n,len(v)-1)]
 def now(self):x=100.0+self.times*0.125;self.times+=1;self.event('now',x);return x
 def address(self,fd,ad):self.event('address',fd,ad);n=self.addr_n;self.addr_n+=1;return self.value('address',n,0)
 def select(self,nfds,reading,bitmap,sec,us):
  self.event('select',nfds,reading,tuple(bitmap),sec,us);n=self.select_n;self.select_n+=1
  return self.value('select',n,1)
 def transfer(self,fd,rw,cmd,protocol,before):
  self.event('transaction',fd,rw,cmd,protocol,tuple(before) if before is not None and not rw else None)
  n=self.tx_n;self.tx_n+=1;rc=self.value('transfers',n,0)
  if not rw:return rc,before
  assert protocol in (2,3)
  val=self.p.get('config',0) if cmd==3 else self.p.get('remote',80) if cmd==1 else self.p.get('raw',74)
  return rc,[val]+([self.p.get('high',197)] if protocol==3 else [])
 def simple(self,name,*a):self.event(name,*a);return -9
 def compare(self,a,b):self.event('model',a,b);return 0 if a==b else 1
 def offset(self,chain,index):self.event('offset',chain,index);return 5

def run_c(lib,p):
 sc=Script(p);arr=(thermal.Sensor*1)(thermal.template(index=0,access_kind=p.get('kind',4),remote_enabled=p.get('remote_enabled',0)))
 iface=sm.Iface(31);errors=[];scratch=reader.Scratch((B*10)(*([0]*10)))
 ctx=reader.Context(0,112,1,1,b'u3s21exph')
 def safe(fn,default=0):
  def f(*a):
   try:return fn(*a)
   except BaseException as e:errors.append(e);return default
  return f
 def mu(name):return safe(lambda _,s:sc.simple(name,'sensor' if s else 'iface'))
 tcbs=[thermal.MUT(safe(lambda _,s:sc.simple('init_mutex','sensor'))),thermal.MUT(mu('lock')),thermal.MUT(mu('unlock')),thermal.NOW(safe(lambda _:sc.now(),0.0)),thermal.MUT(),thermal.RD(),thermal.WR(),thermal.MUT(),thermal.DELAY(safe(lambda _,v:sc.simple('delay',v))),thermal.LOG(safe(lambda _,l,c,s,v:sc.simple('log_temperature',l,c,s,v)))]
 top=thermal.Ops(*tcbs)
 def select(_,n,r,b,t):
  rc=sc.select(n,r,list(b[:32]),t.contents.seconds,t.contents.microseconds)
  t.contents.microseconds=0;return rc
 def tx(_,fd,rw,cmd,proto,d):
  size=2 if proto==3 else 1
  before=list(C.string_at(d,size)) if d else None
  rc,out=sc.transfer(fd,rw,cmd,proto,before)
  if rw and d:C.memmove(d,bytes(out),len(out))
  return rc
 text=C.create_string_buffer(b'scripted error')
 smcbs=[sm.LOCK(safe(lambda _,i:sc.simple('lock','iface'))),sm.LOCK(safe(lambda _,i:sc.simple('unlock','iface'))),sm.ADDR(safe(lambda _,fd,ad:sc.address(fd,ad))),sm.SELECT(safe(select,-1)),sm.XFER(safe(tx,-1)),sm.SLEEP(safe(lambda _,n:sc.simple('sleep_us',n))),sm.ERR(safe(lambda _:sc.simple('errno') or 0)),sm.TEXT(safe(lambda _,e:(sc.simple('strerror',e),C.addressof(text))[1])),sm.LOG(safe(lambda _,l,a,b,t:sc.simple('log_smbus',l,a,b,t.decode() if t else None)))]
 sop=sm.Ops(*smcbs)
 def transfer(_,ep,ad,mode,reg,buf,protocol):
  assert mode==0 and ep in (0xfe440,0xfe518)
  fn=lib.vn135_aml_smbus_read_135 if ep==0xfe440 else lib.vn135_aml_smbus_write_135
  return fn(C.byref(iface),ad,reg,C.cast(buf,P),protocol,C.byref(sop),None)
 def offset(_,chain,index,out):out[0]=sc.offset(chain,index);return 1
 rcbs=[reader.PLATFORM(safe(lambda _:(sc.simple('platform'),2)[1])),reader.TRANSFER(safe(transfer,-1)),reader.COMPARE(safe(lambda _,a,b:sc.compare(a,b))),reader.OFFSET(safe(offset))]
 rop=reader.ReaderOps(C.pointer(top),*rcbs)
 rc=lib.vn135_temperature_read_135(arr,C.byref(ctx),C.byref(rop),None,C.byref(scratch))
 if errors:raise errors[0]
 return rc,thermal.snapshot(arr[0]),sc.events

def run_original(elf,p):
 sc=Script(p);m=Machine(elf);m.run(0xb80a8)
 for off,v in ((A+0x1c,BK),(A+0x18,0),(A+0x2b4,BUS),(A+0x31c,112),(BK+0x18,MODEL),(MODEL+4,MODEL+0x600),(BUS+0x24,31),(0x654b94,0x11a12c),(0x654b98,0x119d70)):
  m.write(off,v)
 m.write(BK+0x24,1,1);m.write(BK+0xff1,1,1);m.mem[MODEL+0x600:MODEL+0x60a]=b'u3s21exph\0'
 thermal.put_sensor(m,thermal.template(index=0,access_kind=p.get('kind',4),remote_enabled=p.get('remote_enabled',0)),S)
 def ret(v):m.r[0]=int(v)&0xffffffff
 def mutex(name):return lambda _:ret(sc.simple(name,'iface' if m.r[0]==BUS else 'sensor' if m.r[0]==S else 'bus'))
 def ioctl(_):
  fd=signed(m.r[0]);req=m.r[1];arg=m.r[2]
  if req==0x703:ret(sc.address(fd,arg));return
  assert req==0x720
  rw=m.read(arg,1);cmd=m.read(arg+1,1);protocol=m.read(arg+4);ptr=m.read(arg+8)
  size=2 if protocol==3 else 1;before=list(m.mem[ptr:ptr+size]) if ptr else None
  rc,out=sc.transfer(fd,rw,cmd,protocol,before)
  if rw and ptr:m.mem[ptr:ptr+len(out)]=bytes(out)
  ret(rc)
 def memset(_):assert m.r[1]==0 and m.r[2]==128;m.mem[m.r[0]:m.r[0]+128]=bytes(128)
 def select(_):
  t=m.read(m.r[13]);b=m.r[1] or m.r[2];assert m.r[3]==0
  rc=sc.select(m.r[0],int(m.r[1]!=0),struct.unpack('<32I',m.mem[b:b+128]),*struct.unpack('<qq',m.mem[t:t+16]))
  m.write(t+8,0,8);ret(rc)
 def cstr(a):return bytes(m.mem[a:a+128]).split(b'\0')[0]
 def lookup(_):
  v=sc.offset(m.r[1],m.read(S+0x18));ptr=MODEL+0x1000;m.write(ptr+36,v);ret(ptr)
 def log(_):
  line=m.r[3];sp=m.r[13];a=b=0;text=None
  if line in (155,94):a=m.read(sp+8)
  elif line in (176,115):a=struct.unpack('<q',m.mem[sp+8:sp+16])[0]
  elif line in (195,134):a=m.read(sp+8);b=m.read(sp+12)
  elif line in (172,111):text=cstr(m.read(sp+8)).decode()
  elif line==401:ret(sc.simple('log_temperature',line,0,0,0));return
  else:raise AssertionError(('unexpected log',line))
  ret(sc.simple('log_smbus',line,a,b,text))
 def errno(_):sc.simple('errno');m.write(MODEL+0x1100,-9);ret(MODEL+0x1100)
 def strerror(_):sc.simple('strerror',signed(m.r[0]));m.mem[MODEL+0x1120:MODEL+0x112f]=b'scripted error\0';ret(MODEL+0x1120)
 def divide(_):
  x=struct.unpack('<q',struct.pack('<II',m.r[0],m.r[1]))[0];y=m.r[2]|m.r[3]<<32
  q=(-(abs(x)//y) if x<0 else x//y)&((1<<64)-1);m.r[0]=q&0xffffffff;m.r[1]=q>>32
 hooks={0x5a6108:mutex('lock'),0x5a66c4:mutex('unlock'),0x1ed58:lambda _:m.set_d(0,sc.now()),0xfdfac:lambda _:ret((sc.simple('platform'),2)[1]),0x10ef3c:lambda _:ret(sc.simple('delay',m.r[0])),0x5a375c:lambda _:ret(sc.compare(cstr(m.r[0]),cstr(m.r[1]))),0xb2a08:lookup,0x597550:ioctl,0x5a348c:memset,0x59cdb8:select,0x5a85e4:lambda _:ret(sc.simple('sleep_us',m.r[0])),0xfa0c4:log,0x5931e4:errno,0x593224:strerror,0x5913ac:divide}
 m.reset((A,S));m.mem[m.STACK_TOP-45:m.STACK_TOP-35]=bytes(10)
 rc=signed(m.run(0xb5f40,hooks=hooks,max_steps=200000))
 return rc,thermal.snapshot(thermal.get_sensor(m,S)),sc.events

def cleanup_case(lib,elf,count,present,state,kind):
 arr=(thermal.Sensor*4)(*[thermal.template(index=i,state=state,access_kind=kind) for i in range(4)])
 chain=Chain();chain.present=present;chain.sensors=arr
 sc=thermal.Scenario();op,cbs=thermal.c_ops(sc,arr)
 lib.vn135_temperature_chain_cleanup_135(C.byref(chain),count,C.byref(op),None)
 m=Machine(elf);m.reset((A,));m.write(A+0x1c,BK);m.write(BK+0x18,MODEL);m.write(MODEL+0x58,MODEL+0x500);m.write(MODEL+0x518,count);m.write(A+0x24,present,1);m.write(A+0x290,S)
 for i in range(4):thermal.put_sensor(m,thermal.template(index=i,state=state,access_kind=kind),S+i*128)
 events=[]
 def mutex(_):events.append(('init_mutex',(m.r[0]-S)//128));m.r[0]=0
 m.run(0x58d08,hooks={0x5a60b8:mutex},max_steps=10000)
 assert [thermal.snapshot(s) for s in arr]==[thermal.snapshot(thermal.get_sensor(m,S+i*128)) for i in range(4)]
 assert sc.events==events,(sc.events,events)
 return len(events)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==thermal.ELF_HASH
 lib=C.CDLL(str(Path(args.library).resolve()))
 lib.vn135_temperature_read_135.argtypes=[thermal.SP,C.POINTER(reader.Context),C.POINTER(reader.ReaderOps),P,C.POINTER(reader.Scratch)];lib.vn135_temperature_read_135.restype=I
 for n in ('read','write'):
  f=getattr(lib,'vn135_aml_smbus_'+n+'_135');f.argtypes=[C.POINTER(sm.Iface),U,U,P,U,C.POINTER(sm.Ops),P];f.restype=I
 lib.vn135_temperature_chain_cleanup_135.argtypes=[CP,I,C.POINTER(thermal.Ops),P];lib.vn135_temperature_chain_cleanup_135.restype=None
 cases=[]
 for kind in (3,4):
  for remote in (0,1):
   for raw in (0,1,63,64,127,128,255):cases.append(dict(kind=kind,remote_enabled=remote,raw=raw,remote=255-raw))
  for key,bad in (('address',-1),('select',0),('select',-1),('transfers',-1)):
   for n in range(9):cases.append(dict(kind=kind,**{key:[bad]*n+[0 if key!='select' else 1]}))
  cases.append(dict(kind=kind,transfers=[-1]));cases.append(dict(kind=kind,config=4))
 ev=0
 for p in cases:
  a=run_original(elf,p);b=run_c(lib,p);assert a==b,(p,a,b);ev+=len(a[2])
 clean=ce=0
 for count in (-1,0,1,2,4):
  for present in (0,1,255):
   for state in (0,1,2,3,4,0xffffffff):
    for kind in (0,2,4):ce+=cleanup_case(lib,elf,count,present,state,kind);clean+=1
 result=dict(reader_smbus_comparisons=len(cases),reader_events=ev,cleanup_comparisons=clean,cleanup_events=ce,original_reader_smbus_and_accept=True,original_cleanup_and_reset=True,word_output_bytes=2,kernel_device_effects='scripted',real_threads=False,physical_io=False)
 if args.summary:Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
 print('SENSOR_BUS135_COMPOSED_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
