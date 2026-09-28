#!/usr/bin/env python3
"""Original common shutdown, its worker and existing PSU-off caller.
All external hardware/thread operations are scripted, never performed.
"""
import argparse,ctypes as C,hashlib,json,random,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
U=C.c_uint32;I=C.c_int32;B=C.c_uint8;P=C.c_void_p
class Thread(C.Structure):_fields_=[('handle',U),('running',B)]
class Power(C.Structure):_fields_=[('byte_ff1',B),('word_20c',U)]
class State(C.Structure):
 _fields_=[('state',U),('mode',U),('model_chip_selector',U),('persistent_marker',B),('byte_fe6',B),('board_byte_4f',B),('word_fe8',U),('word_fec',U),('threads',Thread*10),('power',Power),('fan_count',I),('fan_readings',C.POINTER(I))]
class Scratch(C.Structure):_fields_=[('cleanup',U*2),('join_result',U)]
CB0=C.CFUNCTYPE(I,P);DELAY=C.CFUNCTYPE(I,P,U);SELF=C.CFUNCTYPE(U,P);HANDLE=C.CFUNCTYPE(I,P,U);JOIN=C.CFUNCTYPE(I,P,U,C.POINTER(U));NAME=C.CFUNCTYPE(I,P,C.c_char_p);STEP=C.CFUNCTYPE(U,P,U,U);CLEAN=C.CFUNCTYPE(I,P,C.POINTER(U),U);LOG=C.CFUNCTYPE(None,P,U)
class Ops(C.Structure):_fields_=[('trylock',CB0),('unlock',CB0),('delay_ms',DELAY),('self',SELF),('detach',HANDLE),('cancel',HANDLE),('join',JOIN),('set_thread_name',NAME),('step',STEP),('cleanup',CLEAN),('mark_stopped',NAME),('log',LOG)]
SETV=C.CFUNCTYPE(I,P,C.c_uint16);PLOG=C.CFUNCTYPE(None,P,I,U,U)
class PowerOps(C.Structure):_fields_=[('psu_on',CB0),('psu_off',CB0),('set_voltage',SETV),('chain_count',CB0),('reset_chain',HANDLE),('log',PLOG)]
HASH='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
BASE=0x840000;MODEL=0x844000;CHAINS=0x845000;FANS=0x847000
OFFSETS=[0x1044,0x1014,0x100c,0xffc,0x101c,0x1004,0x102c,0xff4,0x103c,0x1050]
ALLOWED=((0x5fc54,0x606c0),(0x72ba4,0x72bf0),(0x6b778,0x6b8c8),(0xa71dc,0xa7218))
class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  if pc and not any(lo<=pc<hi for lo,hi in ALLOWED):raise ValueError('Unexpected shutdown instruction %x'%pc)
  return super().extra_instruction(w,pc)
def make_state(p):
 fans=(I*max(1,p.get('fans',4)))(*range(1,max(1,p.get('fans',4))+1))
 s=State(p.get('state',2),p.get('mode',0),p.get('chip',4),p.get('persistent',1),1,p.get('boardflag',0),77,88,(Thread*10)(*(Thread(i+100,v) for i,v in enumerate(p.get('flags',[1]*10)))),Power(1,13500),p.get('fans',4),None if p.get('nullfans') else fans)
 return s,fans
class Script:
 def __init__(self,p,snapshot,mutate):self.p=p;self.events=[];self.snap=snapshot;self.mutate=mutate;self.tries=0;self.counts=0;self.selves=0
 def event(self,*args):self.events.append((*args,self.snap()))
 def call(self,name,*args):
  self.event(name,*args)
  if name=='trylock':self.tries+=1;return -9 if self.tries<=self.p.get('lock_failures',0) else 0
  if name=='self':
   vals=self.p.get('selves',[self.p.get('self',999)]);v=vals[self.selves%len(vals)];self.selves+=1
   if self.p.get('mutate_self'):self.mutate('self',v)
   return v
  if name=='cancel' and self.p.get('mutate_cancel'):self.mutate('cancel',args[0])
  if name=='trylock' and self.p.get('mutate_marker'):self.mutate('marker',0)
  if name=='count':
   vals=self.p.get('counts',[self.p.get('chains',3)]);v=vals[self.counts%len(vals)];self.counts+=1;return v
  return self.p.get('returns',{}).get(name,0)
 def step(self,ep,arg):
  self.event('step',ep,arg)
  if ep==0xfdeb4:return self.p.get('platform_ready',1)
  if ep==0x8291c:return self.p.get('special',0)
  if ep==0xfdfbc:return self.p.get('selector',0)
  if ep==0x19c:return 0x851500
  return self.p.get('step_rc',0)&0xffffffff

def c_run(lib,p):
 s,fans=make_state(p);scratch=Scratch((U*2)(0x12345678,0xaabbccdd),0xface);errors=[]
 def snap():return (s.state,s.byte_fe6,s.word_fe8,s.word_fec,tuple((t.handle,t.running) for t in s.threads),(s.power.byte_ff1,s.power.word_20c),tuple(fans) if s.fan_readings else None)
 def mutate(kind,v):
  if kind=='cancel':
   for t in s.threads:
    if t.handle==v:t.handle+=5000;break
  if kind=='self':s.threads[p.get('self_slot',0)].handle=v
  if kind=='marker':s.persistent_marker=0
 sc=Script(p,snap,mutate)
 def wrap(fn,default=0):
  def f(*args):
   try:return fn(*args)
   except BaseException as e:errors.append(e);return default
  return f
 def join(_,h,out):
  rc=sc.call('join',h,bool(out))
  if out and p.get('write_join',True):out[0]=0xbeef
  return rc
 def cleanup(_,buf,value):
  rc=sc.call('cleanup',value)
  if p.get('write_cleanup',True):buf[0]=123;buf[1]=456
  return rc
 callbacks=[CB0(wrap(lambda _:sc.call('trylock'))),CB0(wrap(lambda _:sc.call('unlock'))),DELAY(wrap(lambda _,v:sc.call('delay',v))),SELF(wrap(lambda _:sc.call('self'))),HANDLE(wrap(lambda _,v:sc.call('detach',v))),HANDLE(wrap(lambda _,v:sc.call('cancel',v))),JOIN(wrap(join)),NAME(wrap(lambda _,v:sc.call('name',v.decode()))),STEP(wrap(lambda _,e,a:sc.step(e,a))),CLEAN(wrap(cleanup)),NAME(wrap(lambda _,v:sc.call('marker',v.decode()))),LOG(wrap(lambda _,v:sc.event('log',v)))]
 ops=Ops(*callbacks)
 pcb=[CB0(wrap(lambda _:sc.call('on'))),CB0(wrap(lambda _:sc.call('off'))),SETV(wrap(lambda _,v:sc.call('voltage',v))),CB0(wrap(lambda _:sc.call('count'))),HANDLE(wrap(lambda _,v:sc.call('reset',v))),PLOG(wrap(lambda _,source,line,arg:sc.event('log',line)))]
 power=PowerOps(*pcb)
 f=lib.vn135_backend_shutdown_worker_135 if p.get('worker') else lib.vn135_backend_shutdown_135
 result=f(C.byref(s),C.byref(ops),C.byref(power),None,C.byref(scratch))
 if errors:raise errors[0]
 return result,snap(),sc.events

def a_run(elf,p):
 m=Machine(elf);s,fans=make_state(p)
 for off,v in [(0x18,MODEL),(0x20,s.state),(0x50,s.mode),(0xfe8,s.word_fe8),(0xfec,s.word_fec),(0x20c,s.power.word_20c),(0x230,CHAINS),(0x238,0 if p.get('nullfans') else FANS),(0x19c,0x850100)]:m.write(BASE+off,v)
 for off,v in [(0xf4,s.persistent_marker),(0xfe6,s.byte_fe6),(0xff1,s.power.byte_ff1)]:m.write(BASE+off,v,1)
 m.write(MODEL+0x88,s.model_chip_selector);m.write(MODEL+0xbc,s.fan_count);m.write(MODEL+0x38+0x4f,s.board_byte_4f,1)
 for i,off in enumerate(OFFSETS):m.write(BASE+off,s.threads[i].handle);m.write(BASE+off+4,s.threads[i].running,1)
 for i,v in enumerate(fans):m.write(FANS+i*36+0x20,v)
 def snap():return (m.read(BASE+0x20),m.read(BASE+0xfe6,1),m.read(BASE+0xfe8),m.read(BASE+0xfec),tuple((m.read(BASE+x),m.read(BASE+x+4,1)) for x in OFFSETS),(m.read(BASE+0xff1,1),m.read(BASE+0x20c)),tuple(signed(m.read(FANS+i*36+0x20)) for i in range(len(fans))) if m.read(BASE+0x238) else None)
 def mutate(kind,v):
  if kind=='cancel':
   for x in OFFSETS:
    if m.read(BASE+x)==v:m.write(BASE+x,v+5000);break
  if kind=='self':m.write(BASE+OFFSETS[p.get('self_slot',0)],v)
  if kind=='marker':m.write(BASE+0xf4,0,1)
 sc=Script(p,snap,mutate)
 def ret(x):m.r[0]=x&0xffffffff
 def call(name,argument=None):return lambda _:ret(sc.call(name,*(() if argument is None else argument())))
 def join(_):
  rc=sc.call('join',m.r[0],bool(m.r[1]))
  if m.r[1] and p.get('write_join',True):m.write(m.r[1],0xbeef)
  ret(rc)
 def clean(_):
  assert m.r[2]==m.r[3]==0
  rc=sc.call('cleanup',m.r[1])
  if p.get('write_cleanup',True):m.write(m.r[0],123);m.write(m.r[0]+4,456)
  ret(rc)
 # Proven literals, independent of path taken by the shutdown body.
 strings=json.loads((ROOT/'evidence/stage1/cgminer_xor_strings.json').read_text())
 def text(addr):
  item=next(x for x in strings if int(x['base'],16)==addr)
  raw=elf.read(addr,item['length']);data=bytes(x^item['xor'] for x in raw)
  assert data==item['text'].encode()+b'\0';return item['text']
 def mark(_):ret(sc.call('marker',text(m.r[0])))
 def name(_):
  assert m.r[0]==15 and m.r[2]==m.r[3]==m.read(m.r[13])==0
  ret(sc.call('name',text(m.r[1])))
 hooks={0x5a6684:call('trylock'),0x5a66c4:call('unlock'),0x10ef3c:call('delay',lambda:(m.r[0],)),0x5a6b20:call('self'),0x5a5bb0:call('detach',lambda:(m.r[0],)),0x5a4754:call('cancel',lambda:(m.r[0],)),0x5a5d2c:join,0x593af8:name,0x108b40:clean,0x10ee90:mark,
        0xfe668:call('count'),0x102b04:call('off'),0x55370:call('reset',lambda:((m.r[0]-CHAINS)//800,)),0xfa0c4:lambda _:ret(sc.event('log',m.r[3]) or 0)}
 for ep in (0xfdeb4,0x8291c,0x860b8,0xfdfbc,0xa6080,0x663cc,0x58d08,0x5a9fc,0x5ac80,0x1082b4,0x2f6ec,0xf98b8,0xf9840):
  def h(_,ep=ep):ret(sc.step(ep,(m.r[0]-CHAINS)//800 if ep in (0x58d08,0x5a9fc,0x5ac80) else m.r[0] if ep in (0xf98b8,0xf9840) else 0))
  hooks[ep]=h
 hooks[0x850100]=lambda _:ret(sc.step(0x19c,0))
 m.reset((BASE,));result=signed(m.run(0x72ba4 if p.get('worker') else 0x5fc54,hooks=hooks,max_steps=100000))
 return result if p.get('worker') else None,snap(),sc.events

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
 lib=C.CDLL(str(Path(args.library).resolve()))
 for name in ('vn135_backend_shutdown_135','vn135_backend_shutdown_worker_135'):
  f=getattr(lib,name);f.restype=I if name.endswith("worker_135") else None;f.argtypes=[C.POINTER(State),C.POINTER(Ops),C.POINTER(PowerOps),P,C.POINTER(Scratch)]
 cases=[]
 for worker in (0,1):
  for state in (0,1,2,3,4,5,6,7,0xffffffff):
   for ready in (0,1):
    for persistent in (0,255):cases.append(dict(worker=worker,state=state,platform_ready=ready,persistent=persistent))
 for slot in range(10):
  for flag in (0,1,255):
   for selfid in (999,100+slot):
    for mutate in (0,1):
     flags=[0]*10;flags[slot]=flag;cases.append(dict(flags=flags,self=selfid,mutate_cancel=mutate))
 for chip in (0,4,6,7,8,0xffffffff):
  for selector in (0,1,2,3,4,0xffffffff):
   for mode in (0,2):cases.append(dict(chip=chip,selector=selector,mode=mode))
 for i in range(256):cases.append(dict(flags=[i]*10,returns={'off':-7,'unlock':-9,'detach':-1,'cancel':-1,'join':-1,'marker':-1},lock_failures=i%4))
 for slot in range(9):cases.append(dict(mutate_self=1,self_slot=slot,self=1000+slot))
 for chains in (-1,0,1,3):
  for fans in (0,1,4):
   for boardflag in (0,255):
    for null in (0,1):cases.append(dict(chains=chains,fans=fans,boardflag=boardflag,nullfans=null,special=1,step_rc=0xffffffff))
 cases += [dict(counts=[0,2,3]),dict(counts=[3,0,1],worker=1),dict(counts=[1,3,0],returns={'off':-1}),dict(lock_failures=7,worker=1)]
 events=0
 for i,p in enumerate(cases):
  a=a_run(elf,p);c=c_run(lib,p)
  if a!=c:
   print('FAILED',i,p,'return',a[0],c[0],'final',a[1],c[1])
   for j in range(max(len(a[2]),len(c[2]))):
    x=a[2][j] if j<len(a[2]) else None;y=c[2][j] if j<len(c[2]) else None
    if x!=y:print('EVENT',j,'ARM',x,'C',y);break
   raise AssertionError('shutdown comparison')
  events+=len(a[2])
 summary={'cases':len(cases),'events':events,'whole_shutdown_and_worker':True,'nested_original_power_stop':True,'lower_thread_and_hardware_effects':'explicit callbacks','physical_off_verified':False,'real_threads':False,'reference_sha256':HASH}
 print('BACKEND_SHUTDOWN135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
 if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
