#!/usr/bin/env python3
"""Differential complete synchronous reading with explicit bus boundaries.
Original code is interpreted, never launched. No GPIO, UART or real thread I/O.
"""
import argparse, ctypes as C, hashlib, json, math, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT/'tools'),str(Path(__file__).resolve().parent)]
import test_thermal_sensors_135 as old
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed,ror
from elf32 import ELF32
from test_thermal_sensors_135 import Sensor,SP,Ops,template,snapshot,put_sensor,get_sensor,OFF,A,S,BK,MODEL,BUS,ELF_HASH
U=C.c_uint32;I=C.c_int32;B=C.c_uint8;P=C.c_void_p
class Context(C.Structure):
 _fields_=[('chain_index',U),('mux_address',U),('backend_active',B),('power_marked_on',B),('model_name',C.c_char_p)]
class Scratch(C.Structure):_fields_=[('bytes',B*10)]
PLATFORM=C.CFUNCTYPE(U,P);TRANSFER=C.CFUNCTYPE(I,P,U,U,U,U,C.POINTER(B),U)
COMPARE=C.CFUNCTYPE(I,P,C.c_char_p,C.c_char_p);OFFSET=C.CFUNCTYPE(I,P,U,U,C.POINTER(I))
class ReaderOps(C.Structure):_fields_=[('temperature',C.POINTER(Ops)),('platform_kind',PLATFORM),('transfer',TRANSFER),('compare_model',COMPARE),('model_offset',OFFSET)]
class ReaderArm(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if pc and not (0xb5d90<=pc<0xb73f4 or 0xb80a8<=pc<0xb8688):
   raise ValueError('Unexpected reader instruction %x'%pc)
  if w&0x0fff03f0==0x06af0070:
   d=(w>>12)&15;n=w&15;x=ror(self.get(n,pc),((w>>10)&3)*8)&255
   self.r[d]=(x-256 if x>=128 else x)&0xffffffff;return True
  if w&0x0f300f00==0x0d100a00: # VLDR one S register, no writeback
   n=(w>>16)&15;d=((w>>12)&15)*2+((w>>22)&1);off=(w&255)*4
   self.s[d]=self.read(self.get(n,pc)+(off if w&(1<<23) else -off));return True
  if w&0x0fb00f50==0x0e100b00: # VNMLS.f64: (-Dd) + separately rounded Dn*Dm
   d=((w>>12)&15)+((w>>22)&1)*16;n=((w>>16)&15)+((w>>7)&1)*16;m=(w&15)+((w>>5)&1)*16
   a,b,c=self.d(n),self.d(m),self.d(d)
   if not all(math.isfinite(x) for x in (a,b,c)):raise ValueError('Non-finite VNMLS')
   product=a*b;result=-c+product
   if not math.isfinite(result):raise ValueError('Non-finite VNMLS result')
   self.set_d(d,result);return True
  return super().extra_instruction(w,pc)
class Script(old.Scenario):
 def __init__(self,p):super().__init__(p);self.tn=0;self.pn=0
 def platform(self):
  modes=self.p.get('platforms',[self.p.get('platform',0)])
  v=modes[self.pn%len(modes)];self.pn+=1;self.event('platform',v);return v
 def transfer(self,entry,address,mode,reg,before,n):
  k=self.tn;self.tn+=1
  write=entry in (0xfe518,0xfe538)
  data=None if before is None else tuple(before)
  self.event('transfer',entry,address,mode,reg,n,data if write else None)
  bad=self.p.get('fail_at',[])
  rc=-7 if self.p.get('fail_all') or k in bad else 0
  if 'rc_sequence' in self.p:rc=self.p['rc_sequence'][k%len(self.p['rc_sequence'])]
  if write:return rc,before
  # Lower transport lengths are kept verbatim, not interpreted as safe
  # buffer capacities. Fixtures write the one meaningful observed byte.
  value=self.p.get('config',0) if reg==3 else self.p.get('remote_raw',80) if reg==1 else self.p.get('raw',74)
  out=list(before)
  if self.p.get('write_read',True):out[0]=value
  return rc,out
 def compare(self,actual,expected):self.event('model',actual.decode(),expected.decode());return 0 if actual==expected else 1
 def offset(self,chain,index):self.event('offset',chain,index);return self.p.get('have_offset',1),self.p.get('offset',5)

def compare_case(lib,elf,p):
 s=template(**p.get('sensor',{}));ac=Script(p);cc=Script(p)
 ctx=Context(p.get('chain',3),p.get('mux',112),p.get('active',1),p.get('power',1),p.get('model',b'u3s21exph'))
 arr=(Sensor*1)(Sensor.from_buffer_copy(bytes(s)));op,keep=old.c_ops(cc,arr)
 scratch=Scratch((B*10)(*p.get('scratch',[0]*10)))
 errors=[]
 def safe(fn,default):
  def wrap(*args):
   try:return fn(*args)
   except BaseException as e:errors.append(e);return default
  return wrap
 def ct(_,ep,ad,mode,reg,buf,n):
  # fe518 encodes a one-byte mux command in reg, or a register+ONE byte.
  size=(n-1 if ep==0xfe518 else n) if buf else 0
  before=[buf[i] for i in range(size)] if buf else None
  rc,out=cc.transfer(ep,ad,mode,reg,before,n)
  if buf and ep not in (0xfe518,0xfe538):
   for i,x in enumerate(out):buf[i]=x
  return rc
 def coff(_,chain,index,out):
  found,v=cc.offset(chain,index)
  if found:out[0]=v
  return found
 cb=[PLATFORM(safe(lambda _:cc.platform(),0)),TRANSFER(safe(ct,-1)),COMPARE(safe(lambda _,x,y:cc.compare(x,y),1)),OFFSET(safe(coff,0))]
 rop=ReaderOps(C.pointer(op),*cb)
 name='vn135_temperature_initialize_direct_135' if p.get('init') else 'vn135_temperature_read_135'
 cr=getattr(lib,name)(arr,C.byref(ctx),C.byref(rop),None,C.byref(scratch))
 if errors:raise errors[0]
 m=ReaderArm(elf)
 # Decode the actual model tag through its original constructor.
 m.run(0xb80a8);assert bytes(m.mem[0x5e9211:0x5e921b])==b'u3s21exph\0'
 for off,v in [(A+0x1c,BK),(A+0x18,ctx.chain_index),(A+0x2b4,BUS),(A+0x31c,ctx.mux_address),
               (BK+0x18,MODEL),(BK+0x1c,MODEL+0x500),(MODEL+4,MODEL+0x600),(BK+0x1d4,0x850010)]:m.write(off,v)
 m.write(BK+0x24,ctx.backend_active,1);m.write(BK+0xff1,ctx.power_marked_on,1)
 model=p.get('model',b'u3s21exph');m.mem[MODEL+0x600:MODEL+0x600+len(model)+1]=model+b'\0';put_sensor(m,s,S)
 def ret(v):m.r[0]=v&0xffffffff
 def idx(addr):return 0 if addr==S else -1
 def mu(n):return lambda _:ret(ac.lock(n,idx(m.r[0])))
 def direct(_):
  rc,value,put=ac.read(0,m.r[3])
  if put:m.write(m.read(m.r[13]),value,1)
  ret(rc)
 def transfer(ep):
  def run(_):
   assert m.r[0]==BUS
   ad=m.r[1]
   if ep in (0xfe440,0xfe518):mode=0;reg=m.r[2];ptr=m.r[3];n=m.read(m.r[13])
   else:mode=m.r[2];reg=m.r[3];ptr=m.read(m.r[13]);n=m.read(m.r[13]+4)
   size=(n-1 if ep==0xfe518 else n) if ptr else 0
   before=list(m.mem[ptr:ptr+size]) if ptr else None
   rc,out=ac.transfer(ep,ad,mode,reg,before,n)
   if ptr and ep not in (0xfe518,0xfe538):m.mem[ptr:ptr+size]=bytes(out)
   ret(rc)
  return run
 def cstring(addr):return bytes(m.mem[addr:addr+256]).split(b'\0')[0]
 def modelcmp(_):ret(ac.compare(cstring(m.r[0]),cstring(m.r[1])))
 def lookup(_):
  found,v=ac.offset(m.r[1],m.read(S+0x18));ptr=MODEL+0x1000
  if found:m.write(ptr+36+m.read(S+0x18)*4,v)
  ret(ptr if found else 0)
 def log(_):
  line=m.r[3];ac.log(line,m.read(m.r[13]+8) if line!=401 else 0,m.read(m.r[13]+12) if line==474 else 0,0);ret(0)
 hooks={0x5a6108:mu('lock'),0x5a66c4:mu('unlock'),0x1ed58:lambda _:m.set_d(0,ac.now()),0x850010:direct,
        0xfdfac:lambda _:ret(ac.platform()),0x10ef3c:lambda _:ret(ac.delay(m.r[0])),0x5a375c:modelcmp,0xb2a08:lookup,0xfa0c4:log}
 hooks.update({ep:transfer(ep) for ep in (0xfaeec,0xfe440,0xfe518,0xfe528,0xfe538)})
 m.reset((A,S));m.mem[m.STACK_TOP-45:m.STACK_TOP-35]=bytes(p.get('scratch',[0]*10))
 before=bytes(m.mem[S:S+128]);ar=signed(m.run(0xb5d90 if p.get('init') else 0xb5f40,hooks=hooks,max_steps=100000))
 result=get_sensor(m,S)
 assert ar==cr,('return',p,ar,cr)
 assert snapshot(result)==snapshot(arr[0]),('state',p,[(n,getattr(result,n),getattr(arr[0],n)) for n,_ in Sensor._fields_ if getattr(result,n)!=getattr(arr[0],n)])
 assert ac.events==cc.events,('events',p,ac.events,cc.events)
 allowed=set().union(*(set(range(o,o+n)) for o,n in OFF.values()))
 assert all(m.mem[S+i]==before[i] for i in range(128) if i not in allowed)
 return len(ac.events)

def instruction_fixtures(elf):
 # Verify both local instruction additions separately from recovered code.
 m=ReaderArm(elf);fixtures=loads=0
 for a in (-127.,-1.5,0.,1.,127.):
  for b in (-1.15,0.,1.15):
   for c in (-100.,-0.,0.,100.):
    m.reset();m.set_d(0,c);m.set_d(1,a);m.set_d(2,b)
    assert m.extra_instruction(0xee110b02,0)
    assert m.dbits(0)==int.from_bytes(struct.pack('<d',-c+a*b),'little');fixtures+=1
 for d,n,q in ((0,0,1),(0,1,0),(0,0,0),(31,16,31),(16,16,31),(31,31,16)):
  for seed in range(4):
   m.reset()
   for reg in set((d,n,q)):m.set_d(reg,(reg+1.5)*(seed-1))
   before=[m.dbits(i) for i in range(32)]
   regs=m.r[:];m.n,m.z,m.c,m.v=True,False,True,False
   expected=-m.d(d)+(m.d(n)*m.d(q))
   w=0xee100b00|((d&15)<<12)|((d>>4)<<22)|((n&15)<<16)|((n>>4)<<7)|(q&15)|((q>>4)<<5)
   assert m.extra_instruction(w,0)
   assert m.dbits(d)==int.from_bytes(struct.pack('<d',expected),'little')
   assert all(m.dbits(i)==before[i] for i in range(32) if i!=d)
   assert m.r==regs and (m.n,m.z,m.c,m.v)==(True,False,True,False);fixtures+=1
 for sd in (0,1,15,16,31):
  for rn in (0,3,13):
   for imm in (0,1,255):
    for up in (0,1):
     for bits in (0,0xffffffff,0x3f800000,0x80000000):
      m.reset();m.r[rn]=0x840800
      m.s[:]=[0x12345678]*len(m.s)
      m.write(m.r[rn]+(imm*4 if up else -imm*4),bits)
      regs=m.r[:];before=m.s[:];m.n,m.z,m.c,m.v=False,True,False,True
      w=0xed100a00|(up<<23)|((sd&1)<<22)|(rn<<16)|((sd//2)<<12)|imm
      assert m.extra_instruction(w,0)
      assert m.s[sd]==bits and m.r==regs
      assert all(v==before[i] for i,v in enumerate(m.s) if i!=sd)
      assert (m.n,m.z,m.c,m.v)==(False,True,False,True);loads+=1
 return fixtures,loads

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==ELF_HASH
 lib=C.CDLL(str(Path(args.library).resolve()))
 for n in ('vn135_temperature_read_135','vn135_temperature_initialize_direct_135'):
  f=getattr(lib,n);f.argtypes=[SP,C.POINTER(Context),C.POINTER(ReaderOps),P,C.POINTER(Scratch)];f.restype=I
 cases=[]
 for kind in (0,1,2,3,4,5,0xffffffff):
  for state in (0,1,2,3,4,0xffffffff):
   for remote in (0,1,255):
    for platform in (0,1):cases.append({'sensor':{'access_kind':kind,'state':state,'remote_enabled':remote},'platform':platform})
 for platform in (0,1):
  for remote in (0,1):
   for raw in range(256):cases.append({'sensor':{'access_kind':4,'remote_enabled':remote,'previous_sample':0,'has_previous':0},'platform':platform,'raw':raw,'remote_raw':255-raw})
 for kind in (0,1,3,4):
  for platform in (0,1):
   for failed in ([],[0],[1],[2],[3],[4],[5],[6],[7],list(range(50))):
    for failures in (-2147483648,-1,0,1,2,2147483647):
     cases.append({'sensor':{'access_kind':kind,'failures':failures,'remote_enabled':kind==4},'platform':platform,'fail_at':failed})
 for active in (0,1):
  for power in (0,1):
   for model in (b'u3s21exph',b'T21',b''):
    for offset in (-2147483648,-4,0,3,2147483647):
     cases.append({'sensor':{'access_kind':4,'remote_enabled':1},'active':active,'power':power,'model':model,'offset':offset})
 for index in (0,1,7,8,31,32,255,256,257):
  for platform in (0,1):cases.append({'sensor':{'access_kind':4,'index':index},'platform':platform,'power':0,'active':0})
 for kind in (0,1,2,3,4,5):
  for skip in (0,1):
   for fail in (0,1):cases.append({'init':True,'sensor':{'access_kind':kind,'skip_initial_read':skip},'fail_all':fail})
 for platform in (0,1):
  for config in (0,4,255):
   for writes in (True,False):
    cases.append({'sensor':{'access_kind':4,'remote_enabled':1},'platform':platform,'config':config,'write_read':writes})
 events=0
 for i,p in enumerate(cases):
  try:events+=compare_case(lib,elf,p)
  except BaseException:print('CASE',i,p,flush=True);raise
 fixtures,loads=instruction_fixtures(elf)
 summary={'cases':len(cases),'events':events,'original_full_synchronous_reader':True,'direct_initializer':True,'vnmls_finite_fixtures':fixtures,'vldr_bit_fixtures':loads,'bus_callbacks':'explicit one-meaningful-byte fixtures','all_async_temperature_requests_recovered':False,'physical_io':False,'reference_sha256':ELF_HASH}
 print('THERMAL_READER135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
 if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
