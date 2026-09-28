#!/usr/bin/env python3
"""Original AML SMBus functions vs the C port, through scripted OS boundaries.
No ioctl, select, I2C device, original process or physical hardware is executed.
"""
import argparse, ctypes as C, hashlib, itertools, json, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
HASH='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
U=C.c_uint32; I=C.c_int32; B=C.c_uint8; P=C.c_void_p; Q=C.c_int64
class Iface(C.Structure): _fields_=[('fd',I)]
class Timeout(C.Structure): _fields_=[('seconds',Q),('microseconds',Q)]
LOCK=C.CFUNCTYPE(I,P,C.POINTER(Iface)); ADDR=C.CFUNCTYPE(I,P,I,U)
SELECT=C.CFUNCTYPE(I,P,I,U,C.POINTER(U),C.POINTER(Timeout))
XFER=C.CFUNCTYPE(I,P,I,B,B,U,P); SLEEP=C.CFUNCTYPE(I,P,U)
ERR=C.CFUNCTYPE(I,P); TEXT=C.CFUNCTYPE(P,P,I)
LOG=C.CFUNCTYPE(None,P,U,Q,U,C.c_char_p)
class Ops(C.Structure):
 _fields_=[('lock',LOCK),('unlock',LOCK),('set_address',ADDR),('select_ready',SELECT),('transfer',XFER),('sleep_us',SLEEP),('get_errno',ERR),('error_text',TEXT),('log',LOG)]
IFACE=0x840100; DATA=0x840300; ERRNO=0x840500; TEXTBUF=0x840600
ALLOWED=((0x119d70,0x11a0d8),(0x11a12c,0x11a658),(0xfe440,0xfe504),(0xfe518,0xfe528))
class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if not any(lo<=pc<hi for lo,hi in ALLOWED):
   raise AssertionError('unexpected original instruction %x'%pc)
  return super().extra_instruction(w,pc)

def trunc_div(a,b): return (abs(a)//abs(b))*(-1 if (a<0)!=(b<0) else 1)
def initial(p): return bytes((n*17+3)&255 for n in range(40))
def size(p): return p.get('capacity',2 if p.get('protocol',2)==3 else 1)
def at(p,key,n,default):
 v=p.get(key,[default]);return v[min(n,len(v)-1)]
class Script:
 def __init__(self,p): self.p=p;self.events=[];self.count={'address':0,'select':0,'transfer':0}
 def event(self,*e): self.events.append(e)
 def address(self,fd,ad):
  self.event('address',fd,ad);n=self.count['address'];self.count['address']+=1
  return at(self.p,'address_rc',n,0)
 def select(self,nfds,read,bitmap,sec,usec):
  expected=[0]*32;fd=self.p.get('fd',7);expected[fd>>5]=1<<(fd&31)
  assert bitmap==expected,(bitmap,expected)
  assert nfds==fd+1 and read==self.p.get('read',1)
  assert (sec,usec)==(0,50000),(sec,usec)
  n=self.count['select'];self.count['select']+=1
  self.event('select',nfds,read,tuple(bitmap),sec,usec)
  out=expected.copy() if at(self.p,'ready',n,True) else [0]*32
  return at(self.p,'select_rc',n,1),out,self.p.get('after_sec',0),self.p.get('after_us',12345)
 def transfer(self,fd,rw,cmd,protocol,inp):
  self.event('transfer',fd,rw,cmd,protocol,inp)
  n=self.count['transfer'];self.count['transfer']+=1
  rc=at(self.p,'transfer_rc',n,0)
  # Deliberately modify data even on failure when requested, as ioctl may do.
  out=inp
  if inp is not None and self.p.get('mutate',True):
   out=bytes(((n*37+0xc0+i)&255) for i in range(len(inp)))
  return rc,out

def c_run(lib,p):
 sc=Script(p); errors=[];iface=Iface(p.get('fd',7));buf=(B*40).from_buffer_copy(initial(p))
 ptr=None if p.get('null') else C.addressof(buf)+8
 text=C.create_string_buffer(b'scripted EINTR')
 def safe(fn,default=0):
  def cb(*a):
   try:return fn(*a)
   except BaseException as ex:errors.append(ex);return default
  return cb
 def lock(_,obj):assert obj.contents.fd==iface.fd;sc.event('lock',iface.fd);return p.get('lock_rc',0)
 def unlock(_,obj):assert obj.contents.fd==iface.fd;sc.event('unlock',iface.fd);return p.get('unlock_rc',0)
 def select(_,nfds,r,b,t):
  rc,out,sec,us=sc.select(nfds,r,[b[i] for i in range(32)],t.contents.seconds,t.contents.microseconds)
  for i,v in enumerate(out):b[i]=v
  t.contents.seconds=sec;t.contents.microseconds=us;return rc
 def transfer(_,fd,rw,cmd,protocol,data):
  assert data==ptr
  rc,out=sc.transfer(fd,rw,cmd,protocol,None if data is None else C.string_at(data,size(p)))
  if data is not None:C.memmove(data,out,len(out))
  return rc
 def sleep(_,us):sc.event('sleep',us);return p.get('sleep_rc',0)
 def error(_):sc.event('errno');return p.get('errno',4)
 def errtext(_,e):sc.event('strerror',e);return C.addressof(text)
 def log(_,line,a,b,txt):sc.event('log',line,a,b,txt.decode() if txt else None)
 callbacks=[LOCK(safe(lock)),LOCK(safe(unlock)),ADDR(safe(lambda _,fd,ad:sc.address(fd,ad))),SELECT(safe(select,-1)),XFER(safe(transfer,-1)),SLEEP(safe(sleep)),ERR(safe(error)),TEXT(safe(errtext)),LOG(safe(log))]
 ops=Ops(*callbacks)
 fn=lib.vn135_aml_smbus_read_135 if p.get('read',1) else lib.vn135_aml_smbus_write_135
 rc=fn(C.byref(iface),p.get('address',0x4c),p.get('command',0xfe),ptr,p.get('protocol',2),C.byref(ops),None)
 if errors:raise errors[0]
 return rc,bytes(buf),sc.events,sc.count

def original_run(m,p):
 sc=Script(p);fd=p.get('fd',7);ptr=0 if p.get('null') else DATA+8
 m.reset((IFACE,p.get('address',0x4c),p.get('command',0xfe),ptr,p.get('protocol',2)))
 m.mem[IFACE:IFACE+0x80]=b'\xa5'*0x80;m.write(IFACE+0x24,fd)
 m.mem[DATA:DATA+40]=initial(p);m.write(ERRNO,p.get('errno',4));m.mem[TEXTBUF:TEXTBUF+15]=b'scripted EINTR\0'
 before=bytes(m.mem[IFACE:IFACE+0x80])
 def lock(a):assert a.r[0]==IFACE;sc.event('lock',fd);a.r[0]=p.get('lock_rc',0)&0xffffffff
 def unlock(a):assert a.r[0]==IFACE;sc.event('unlock',fd);a.r[0]=p.get('unlock_rc',0)&0xffffffff
 def ioctl(a):
  f=signed(a.r[0]);request=a.r[1];arg=a.r[2]
  if request==0x703:rc=sc.address(f,arg)
  elif request==0x720:
   rw=a.read(arg,1);cmd=a.read(arg+1,1);protocol=a.read(arg+4);data=a.read(arg+8)
   assert data==ptr
   rc,out=sc.transfer(f,rw,cmd,protocol,None if not data else bytes(a.mem[data:data+size(p)]))
   if data:a.mem[data:data+len(out)]=out
  else:raise AssertionError('unexpected ioctl %x'%request)
  a.r[0]=rc&0xffffffff
 def memset(a):
  dst,value,n=a.r[:3];assert n==128 and value==0
  a.mem[dst:dst+n]=bytes([value])*n
 def select(a):
  nfds=signed(a.r[0]);read=int(a.r[1]!=0);bits=a.r[1] or a.r[2]
  assert a.r[3]==0 and bool(a.r[1])!=bool(a.r[2])
  tp=a.read(a.r[13]);sec,us=struct.unpack('<qq',a.mem[tp:tp+16])
  rc,out,sec,us=sc.select(nfds,read,list(struct.unpack('<32I',a.mem[bits:bits+128])),sec,us)
  a.mem[bits:bits+128]=struct.pack('<32I',*out);a.mem[tp:tp+16]=struct.pack('<qq',sec,us)
  a.r[0]=rc&0xffffffff
 def sleep(a):sc.event('sleep',a.r[0]);a.r[0]=p.get('sleep_rc',0)&0xffffffff
 def error(a):sc.event('errno');a.r[0]=ERRNO
 def errtext(a):sc.event('strerror',signed(a.r[0]));a.r[0]=TEXTBUF
 def divide(a):
  x=a.r[0]|a.r[1]<<32;y=a.r[2]|a.r[3]<<32
  if x>>63:x-=1<<64
  if y>>63:y-=1<<64
  q=trunc_div(x,y)&((1<<64)-1);a.r[0]=q&0xffffffff;a.r[1]=q>>32
 def log(a):
  line=a.r[3];sp=a.r[13];x=y=0;txt=None
  if line in (94,155):x=a.read(sp+8)
  elif line in (115,176):x=struct.unpack('<q',a.mem[sp+8:sp+16])[0]
  elif line in (111,172):assert a.read(sp+8)==TEXTBUF;txt='scripted EINTR'
  elif line in (134,195):x=a.read(sp+8);y=a.read(sp+12)
  else:raise AssertionError('unexpected log line %s'%line)
  sc.event('log',line,x,y,txt)
 hooks={0x5a6108:lock,0x5a66c4:unlock,0x597550:ioctl,0x5a348c:memset,0x59cdb8:select,0x5a85e4:sleep,0x5931e4:error,0x593224:errtext,0x5913ac:divide,0xfa0c4:log}
 entry=(0xfe440 if p.get('read',1) else 0xfe518) if p.get('wrapper') else (0x11a12c if p.get('read',1) else 0x119d70)
 rc=signed(m.run(entry,hooks=hooks,max_steps=10000))
 assert bytes(m.mem[IFACE:IFACE+0x80])==before
 return rc,bytes(m.mem[DATA:DATA+40]),sc.events,sc.count

def cases():
 for rw,fd,proto,cmd in itertools.product((0,1),(0,7,31,32,1023),(1,2,3),(0,0xfe,0x1234)):
  yield dict(read=rw,fd=fd,protocol=proto,command=cmd)
 for rw in (0,1):
  for key,vals in [('address_rc',[-1,-2,-2147483648,0,1]),('select_rc',[-2,-1,0,1,2]),('transfer_rc',[-2147483648,-2,-1,0,1,2])]:
   for v in vals:yield dict(read=rw,**{key:[v]})
  for n in range(6):
   yield dict(read=rw,address_rc=[-1]*n+[0])
   yield dict(read=rw,select_rc=[0]*n+[1])
   yield dict(read=rw,ready=[False]*n+[True])
   yield dict(read=rw,transfer_rc=[-1]*n+[0])
  for us in (0,999,1000,49999,50000,-1001,2**40,-2**40):
   yield dict(read=rw,select_rc=[0],after_sec=100,after_us=us)
  for l,u,sl in itertools.product((0,-1),(0,-9),(0,-4)):
   yield dict(read=rw,lock_rc=l,unlock_rc=u,sleep_rc=sl,transfer_rc=[-1,0])
  for v in (0,1,127,128,255,0xffffffff):yield dict(read=rw,address=v)
  # Opaque transaction selectors are forwarded, not mistaken for capacities.
  for v in (0,4,5,6,8,255,0xffffffff):yield dict(read=rw,protocol=v,capacity=1,mutate=False)
  yield dict(read=rw,protocol=1,null=True,mutate=False)
 rng=random.Random(135720)
 for _ in range(300):
  yield dict(read=rng.randrange(2),fd=rng.choice([0,7,31,32,255,1023]),wrapper=bool(rng.randrange(2)),protocol=rng.choice([1,2,3]),address=rng.randrange(128),command=rng.randrange(65536),address_rc=[rng.choice([-1,0,0,0]) for _ in range(5)],select_rc=[rng.choice([-1,0,1,1,2]) for _ in range(5)],ready=[bool(rng.randrange(2)) for _ in range(5)],transfer_rc=[rng.choice([-1,0,1]) for _ in range(5)],after_us=rng.randrange(-100000,50001))

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
 raw=(ROOT/'reference/cgminer.vendor.elf').read_bytes();assert hashlib.sha256(raw).hexdigest()==HASH
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');dispatch=ARM32Difficulty(elf);dispatch.reset((2,));dispatch.run(0xfb994,stop=0xfd784,max_steps=30000)
 expected={0x654b94:0x11a12c,0x654b98:0x119d70,0x654b9c:0x11a6b0,0x654ba0:0x11ab24}
 for a,v in expected.items():assert dispatch.read(a)==v
 m=Machine(elf)
 for a,v in expected.items():m.write(a,v)
 lib=C.CDLL(str(Path(args.library).resolve()))
 for name in ('read','write'):
  f=getattr(lib,'vn135_aml_smbus_'+name+'_135');f.restype=I;f.argtypes=[C.POINTER(Iface),U,U,P,U,C.POINTER(Ops),P]
 count=events=0
 for p in cases():
  try:
   a=original_run(m,p);b=c_run(lib,p);assert a==b,(p,a,b)
  except BaseException:
   print('FAILED_CASE',p,file=sys.stderr);raise
  count+=1;events+=len(a[2])
 for rw in (0,1):
  assert c_run(lib,dict(read=rw,transfer_rc=[-1]))[3]['transfer']==3
  assert c_run(lib,dict(read=rw,address_rc=[-1]))[3]['address']==5
  assert c_run(lib,dict(read=rw,select_rc=[-1]))[3]['address']==1
 result=dict(comparisons=count,events=events,original_platform_dispatch=True,original_read_write_and_wrappers=True,new_arm_instructions=0,protocol_not_buffer_length=True,physical_io=False,real_threads=False,reference_sha256=HASH)
 if args.summary:Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
 print('AML_SMBUS135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
