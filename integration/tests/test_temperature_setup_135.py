#!/usr/bin/env python3
"""Unchanged ARM 6ec4c + actual 60a2c versus their C composition.
I/O initialization, stop, registration and chip-check effects are scripts.
No firmware process, registry implementation or hardware is executed.
"""
import argparse, collections, ctypes as C, hashlib, itertools, json, random, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
import test_general_monitor_135 as G
import test_monitor_handlers_135 as H
from test_backend_resume_135 import Description
I=H.I;U=H.U;P=H.P
N=6;BASE=G.BASE;MODEL=G.MODEL;ALT_MODEL=0x846000
BANKS=(G.CHAINS,0x847000);GROUPS=(0x845000,0x845100);TABLES=(0x845200,0x845400)
KEY=0x820100
class View(C.Structure):
 _fields_=[('backend',C.POINTER(H.State)),('description',C.POINTER(Description)),('roles',C.POINTER(U))]
INIT=C.CFUNCTYPE(I,P,C.POINTER(G.Chain),U)
STOP=C.CFUNCTYPE(I,P,C.POINTER(G.Chain),C.c_char_p)
GETKEY=C.CFUNCTYPE(U,P)
REGISTER=C.CFUNCTYPE(None,P,U,C.POINTER(G.State),U)
CHECK=C.CFUNCTYPE(I,P,C.POINTER(G.State))
class Ops(C.Structure):
 _fields_=[('handlers',C.POINTER(H.Ops)),('initialize',INIT),('stop',STOP),('key',GETKEY),('register',REGISTER),('check',CHECK)]
RANGES=((0x6ec4c,0x6f188),(0x60a2c,0x60d20),(0xa720c,0xa7218),(0x56fcc,0x57028),(0x57030,0x57084))

def table_values(p):
 t=list(p.get('types',[2,1]))
 a=list(p.get('alt_types',[0,0]))
 assert len(t)<=N and len(a)<=N
 roles=list(p.get('roles',[2]*len(t)))
 ar=list(p.get('alt_roles',[0]*len(a)))
 assert len(roles)<=N and len(ar)<=N
 return [(p.get('desc_count',len(t)),t+[0]*(N-len(t)),roles+[0]*(N-len(roles))),
         (p.get('alt_count',len(a)),a+[0]*(N-len(a)),ar+[0]*(N-len(ar)))]

class Script:
 def __init__(self,p,snap,mutate):self.p=p;self.snap=snap;self.mutate=mutate;self.events=[];self.calls=collections.Counter()
 def call(self,name,*args):
  n=self.calls[name];self.calls[name]+=1
  if name!='log' or self.p.get('logging',True):
   self.events.append((name,tuple(args),self.snap()))
   for op,nth,key,val in self.p.get('mutations',[]):
    if op==name and nth==n:self.mutate(key,val)
  default={'count':self.p.get('count',3),'key':0x44,'check':1}.get(name,0)
  return H.choose(self.p.get('returns',{}),name,n,default)

class Native:
 def __init__(self,lib):
  self.f=lib.vn135_backend_temperature_setup_135
  self.f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];self.f.restype=I
 def run(self,p):
  s,keep0=H.setup(p);g,model,_,chains,*_=keep0
  keep=list(keep0);alt=(G.GChain*3)()
  for i in range(3):
   C.memmove(C.byref(alt[i]),C.byref(chains[i]),C.sizeof(G.GChain));alt[i].thermal.index+=100
  banks=[chains,alt];keep.append(alt)
  tables=[];types=[];roles=[]
  for count,ts,rs in table_values(p):
   t=(U*N)(*ts);rr=(U*N)(*rs);types.append(t);roles.append(rr)
   tables.append(Description(0,0,count,t,0,0))
  v=View(C.pointer(s),C.pointer(tables[0]),roles[0]);selection=[0,0]
  def snap():
   return (g.mode,g.suppress_thermal,model.query_fault_87,s.partial_chains_105,s.minimum_chains_f8,
    tuple(selection),tuple((t.table_count,tuple(ts),tuple(rs)) for t,ts,rs in zip(tables,types,roles)),
    tuple(tuple((x.thermal.index,x.thermal.state,x.thermal.present) for x in bank) for bank in banks))
  def mutate(k,val):
   if k in ('mode','suppress_thermal'):setattr(g,k,val)
   elif k=='query_fault_87':model.query_fault_87=val
   elif k in ('partial_chains_105','minimum_chains_f8'):setattr(s,k,val)
   elif k=='select_description':selection[0]=val;v.description=C.pointer(tables[val]);v.roles=roles[val]
   elif k=='select_chains':selection[1]=val;g.chains=banks[val]
   elif k=='desc_count':tables[val[0]].table_count=val[1]
   elif k=='type':types[val[0]][val[1]]=val[2]
   elif k=='role':roles[val[0]][val[1]]=val[2]
   elif k.startswith('chain_'):setattr(banks[val[0]][val[1]].thermal,k[6:],val[2])
   else:raise AssertionError(k)
  for k,val in p.get('initial_mutations',[]):mutate(k,val)
  sc=Script(p,snap,mutate);errors=[]
  def guard(t,fn):
   def f(*args):
    try:return fn(*args)
    except BaseException as e:errors.append(e);return 0
   cb=t(f);keep.append(cb);return cb
  def ident(ptr):
   for b,bank in enumerate(banks):
    for i in range(3):
     if C.addressof(ptr.contents)==C.addressof(bank[i].thermal):return b,i
   raise AssertionError('bad chain pointer')
  def call(_,e,a,b):
   assert e==0xfe668 and a==b==0
   return sc.call('count')
  def log(_,line,level,a,b,detail):
   assert detail is None
   sc.call('log',line,level,a,b)
  h=H.Ops();h.call=guard(H.CALL,call)
  if p.get('logging',True):h.log=guard(H.LOG,log)
  def initialize(_,ptr,mode):return sc.call('init',*ident(ptr),mode)
  def stop(_,ptr,reason):
   assert reason==b'Failed to init temp sensors'
   return sc.call('stop',*ident(ptr),reason.decode())
  def reg(_,key,backend,handler):
   assert C.addressof(backend.contents)==C.addressof(g) and handler==0x78aa4
   sc.call('register',key,handler)
  def check(_,backend):
   assert C.addressof(backend.contents)==C.addressof(g)
   return sc.call('check')
  o=Ops(C.pointer(h),guard(INIT,initialize),guard(STOP,stop),guard(GETKEY,lambda _:sc.call('key')),guard(REGISTER,reg),guard(CHECK,check))
  result=[]
  for _ in range(p.get('laps',1)):result.append(self.f(C.byref(v),C.byref(o),None))
  if errors:raise errors[0]
  return result,snap(),sc.events

class Machine(ARM32Difficulty):
 def extra_instruction(self,w,pc):
  assert any(a<=pc<b for a,b in RANGES),('unapproved instruction',hex(pc))
  self.visited.add(pc)
  return super().extra_instruction(w,pc)
 def write(self,a,v,n=4):
  if getattr(self,'guard_writes',False) and not self.in_effect:
   assert self.STACK_BASE<=a and a+n<=self.STACK_TOP+0x1000,('unexpected source data store',hex(a))
  super().write(a,v,n)

class Original:
 def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set();self.entries=collections.Counter()
 def run(self,p):
  m=self.m;m.guard_writes=False;m.in_effect=True;m.mem[BASE:BASE+0x10000]=bytes(0x10000)
  m.write(BASE+0x18,MODEL);m.write(BASE+0x230,BANKS[0]);m.write(BASE+0x19c,KEY)
  m.write(BASE+0x50,p.get('mode',0));m.write(BASE+0xf6,p.get('suppress_thermal',0),1)
  m.write(BASE+0x105,p.get('partial_chains_105',0),1);m.write(BASE+0xf8,p.get('minimum_chains_f8',2))
  for model,group,table,(count,ts,rs) in zip((MODEL,ALT_MODEL),GROUPS,TABLES,table_values(p)):
   m.write(model+0x58,group);m.write(model+0x87,p.get('query_fault_87',0),1)
   m.write(group,table);m.write(group+0x18,count)
   for j in range(N):m.write(table+28*j,ts[j]);m.write(table+28*j+4,rs[j])
  for b,base in enumerate(BANKS):
   for i in range(3):
    addr=base+800*i;m.write(addr+0x18,G.seq(p,'indices',i,i+10)+100*b)
    m.write(addr+0x20,G.seq(p,'chain_states',i,2));m.write(addr+0x24,G.seq(p,'present',i,1),1)
  selection=[0,0]
  def snap():
   return (m.read(BASE+0x50),m.read(BASE+0xf6,1),m.read(MODEL+0x87,1),m.read(BASE+0x105,1),signed(m.read(BASE+0xf8)),
    tuple(selection),tuple((signed(m.read(group+0x18)),tuple(m.read(table+28*j) for j in range(N)),tuple(m.read(table+28*j+4) for j in range(N))) for group,table in zip(GROUPS,TABLES)),
    tuple(tuple((m.read(b+800*i+0x18),m.read(b+800*i+0x20),m.read(b+800*i+0x24,1)) for i in range(3)) for b in BANKS))
  def mutate(k,v):
   if k=='mode':m.write(BASE+0x50,v)
   elif k=='suppress_thermal':m.write(BASE+0xf6,v,1)
   elif k=='query_fault_87':
    for addr in (MODEL,ALT_MODEL):m.write(addr+0x87,v,1)
   elif k=='partial_chains_105':m.write(BASE+0x105,v,1)
   elif k=='minimum_chains_f8':m.write(BASE+0xf8,v)
   elif k=='select_description':selection[0]=v;m.write(BASE+0x18,(MODEL,ALT_MODEL)[v])
   elif k=='select_chains':selection[1]=v;m.write(BASE+0x230,BANKS[v])
   elif k=='desc_count':m.write(GROUPS[v[0]]+0x18,v[1])
   elif k in ('type','role'):m.write(TABLES[v[0]]+28*v[1]+(4 if k=='role' else 0),v[2])
   elif k.startswith('chain_'):
    off,n={'chain_index':(0x18,4),'chain_state':(0x20,4),'chain_present':(0x24,1)}[k]
    m.write(BANKS[v[0]]+800*v[1]+off,v[2],n)
   else:raise AssertionError(k)
  for k,v in p.get('initial_mutations',[]):mutate(k,v)
  sc=Script(p,snap,mutate)
  def ident(addr):
   for b,base in enumerate(BANKS):
    if base<=addr<base+2400 and (addr-base)//800>=0 and (addr-base)%800==0:return b,(addr-base)//800
   raise AssertionError(('bad original chain',hex(addr)))
  def effect(fn):
   def f(_):
    m.in_effect=True
    try:result=fn();m.r[0]=int(result or 0)&0xffffffff
    finally:m.in_effect=False
   return f
  def initialize():return sc.call('init',*ident(m.r[0]),m.r[1])
  def stop():
   assert m.r[1]==0x5e689b,hex(m.r[1])
   return sc.call('stop',*ident(m.r[0]),'Failed to init temp sensors')
  def register():
   assert m.r[2]==BASE and m.r[3]==0x78aa4
   scratch=m.r[0];sc.call('register',m.r[1],m.r[3])
   m.write(scratch,0xabc);m.write(scratch+4,0xdef)
   return 0
  def check():assert m.r[0]==BASE;return sc.call('check')
  def log():
   line=m.r[3];sp=m.r[13];fmt=m.read(sp+4)
   assert m.r[2] in (0x5e50be,0x5e50e3)
   assert fmt=={1811:0x5e6874,445:0x5e6030,451:0x5e607a}[line]
   return sc.call('log',line,m.read(sp),m.read(sp+8) if line!=445 else 0,m.read(sp+12) if line==451 else 0)
  hooks={0xfe668:effect(lambda:sc.call('count')),0x58b50:effect(initialize),0x56d18:effect(stop),KEY:effect(lambda:sc.call('key')),0x108b40:effect(register),0x78eb8:effect(check),0xfa0c4:effect(log)}
  results=[];m.visited=set()
  for _ in range(p.get('laps',1)):
   m.guard_writes=False;m.reset((BASE,));m.guard_writes=True;m.in_effect=False
   results.append(signed(m.run(0x6ec4c,hooks=hooks,max_steps=30000)))
   self.steps+=m.steps
  m.guard_writes=False;self.visited|=m.visited
  return results,snap(),sc.events

def cases():
 yield 'default',{}
 for types in ([],[0],[1],[2],[3],[4],[0xffffffff],[0,4,3,0],[0,1,2,1,2,4]):
  for role,count in itertools.product((0,1,2,3,0xffffffff),(-1,0,1,3)):
   yield 'descriptor_gate',dict(types=types,roles=[role]*len(types),count=count,minimum_chains_f8=0)
 for count in (-2147483648,-1,0):yield 'signed_descriptor_count',dict(desc_count=count)
 for value in range(9):
  for role in range(4):yield 'kind_role',dict(types=[value],roles=[role],returns={'check':0})
 for idx,rc,flag,mode in itertools.product(range(3),(-2147483648,-1,1,2147483647),(0,1,2,255),(0,2,0xffffffff)):
  ret=[0]*3;ret[idx]=rc
  yield 'init_fail',dict(returns={'init':ret,'stop':-123},suppress_thermal=flag,mode=mode)
 for check,states,flag,partial,minimum in itertools.product((0,1,-1),((2,2,2),(2,3,2),(2,5,2),(3,4,5),(0,6,0xffffffff)),(0,1),(0,1),(-1,0,2,4)):
  yield 'decision_composition',dict(chain_states=list(states),query_fault_87=flag,partial_chains_105=partial,minimum_chains_f8=minimum,returns={'check':check})
 for counts in ([0,3,3,3,3],[3,0,3,3,3],[3,3,0,3,0],[3,3,3,0,0],[1,3,2,1,3],[-1,0,0,0,-1]):
  yield 'independent_counts',dict(returns={'count':counts},minimum_chains_f8=0,types=[1],roles=[0])
 mutations=[('mode',2),('suppress_thermal',255),('suppress_thermal',0),('query_fault_87',1),('partial_chains_105',1),('minimum_chains_f8',4),('chain_index',[0,0,0xffffffff]),('chain_state',[0,1,5]),('chain_present',[0,0,0]),('select_description',1),('select_chains',1),('desc_count',[0,0]),('type',[0,0,4]),('role',[0,0,0])]
 for op,nth,(key,val) in itertools.product(('count','init','log','stop','key','register','check'),(0,1),mutations):
  yield 'callback_mutation',dict(returns={'init':[-1,0,-1]},alt_types=[1,2],alt_roles=[2,2],mutations=[(op,nth,key,val)])
 for key in (0,0x44,255,256,0xffffffff):yield 'full_key',dict(returns={'key':key})
 for logging in (True,False):
  for laps in (1,2,3):yield 'repeated',dict(logging=logging,laps=laps,returns={'init':-1})
 yield 'no_chips_left',dict(present=[0],minimum_chains_f8=0)
 yield 'captured_chain_after_array_swap',dict(returns={'init':-1},mutations=[('init',0,'select_chains',1)])
 yield 'role_after_registration',dict(types=[2],roles=[2],alt_types=[1],alt_roles=[0],mutations=[('register',0,'select_description',1)],returns={'check':0})
 yield 'late_failure_gate',dict(suppress_thermal=1,returns={'init':-1},mutations=[('log',0,'suppress_thermal',0)])
 rng=random.Random(0x6ec4c)
 for _ in range(220):
  types=[rng.randrange(5) for _ in range(rng.randrange(7))]
  yield 'mixed',dict(types=types,roles=[rng.randrange(4) for _ in types],count=rng.randrange(-1,4),minimum_chains_f8=rng.randrange(-1,5),chain_states=[rng.choice([0,2,3,4,5,0xffffffff]) for _ in range(3)],present=[rng.choice([0,1,255]) for _ in range(3)],query_fault_87=rng.randrange(2),partial_chains_105=rng.randrange(2),suppress_thermal=rng.randrange(3),returns={'init':[rng.choice([0,-1,1]) for _ in range(3)],'key':rng.getrandbits(32),'check':rng.choice([0,-1,1])})

def quick_cases():
 # Semantic mutation controls use explicit discriminating witnesses; the full
 # positive suite is run separately. The baseline uses this SAME witness set.
 yield 'default',{}
 yield 'only_kind1',dict(types=[1],roles=[0])
 yield 'only_kind2',dict(types=[2],roles=[0])
 yield 'only_kind3',dict(types=[3],roles=[2])
 yield 'init_failed',dict(returns={'init':-1})
 yield 'suppressed_failure',dict(returns={'init':-1},suppress_thermal=1)
 yield 'captured_chain',dict(returns={'init':-1},mutations=[('init',0,'select_chains',1)])
 yield 'full_key',dict(returns={'key':0xffffffff})
 yield 'chip_check_failure',dict(returns={'check':0})
 yield 'bad_chain_state',dict(chain_states=[2,3,2])
 yield 'minimum_count',dict(minimum_chains_f8=4)
 yield 'late_count',dict(returns={'count':[3,3,3,3,0]},minimum_chains_f8=0)
 yield 'late_role',dict(types=[2],roles=[2],alt_types=[1],alt_roles=[0],mutations=[('register',0,'select_description',1)],returns={'check':0})

def main():
 ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--limit',type=int);ap.add_argument('--quick',action='store_true');a=ap.parse_args()
 elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==G.REF
 original=Original(elf);native=Native(C.CDLL(str(Path(a.library).resolve())));categories=collections.Counter();events=0
 for i,(name,p) in enumerate(quick_cases() if a.quick else cases()):
  if a.limit is not None and i>=a.limit:break
  x=original.run(p);y=native.run(p)
  if x!=y:
   print('MISMATCH',i,name,json.dumps(p))
   for j,(u,v) in enumerate(itertools.zip_longest(x[2],y[2])):
    if u!=v:print('EVENT',j,'ARM',u,'C',v);break
   if x[:2]!=y[:2]:print('FINAL',x[:2],y[:2])
   raise AssertionError('TEMPERATURE_SETUP135_MISMATCH')
  categories[name]+=1;events+=len(x[2])
 report=dict(total=sum(categories.values()),categories=dict(categories),events=events,original_steps=original.steps,visited=len(original.visited),nested_original_60a2c=True,registry_body=False,real_io=False,reference_sha256=G.REF)
 if a.summary:Path(a.summary).write_text(json.dumps(report,indent=2)+'\n')
 print('TEMPERATURE_SETUP135_ORIGINAL_PASS',json.dumps(report))
if __name__=='__main__':main()
