#!/usr/bin/env python3
"""65b3c unchanged ARM body versus typed C orchestration, no real workers.
Allocation/thread callbacks are scripted; 56fcc and a71e8 execute as instructions.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import random
from pathlib import Path
import test_general_monitor_135 as G
import test_rescue_stop_135 as R
from arm32_subset import ARM32, MASK, signed
ROOT,HASH,BASE=R.ROOT,R.HASH,0x840000
START,END=0x65b3c,0x65f68
MODEL=(0x844000,0x844800)
CHAINS=(0x845000,0x847000)
ARGS,HANDLES=0x849000,0x849800
CAPACITY=6
RANGES=((START,END),(0xa71e8,0xa71f4),(0x56fcc,0x57028))
LOGS={4481:(1,0x5e5406),4487:(1,0x5e5406),4496:(3,0x5e54dc),4506:(1,0x5e54fd)}
I,U,P=C.c_int32,C.c_uint32,C.c_void_p
class Config(C.Structure):_fields_=[('floor_0c',I),('target_18',I)]
class State(C.Structure):_fields_=[('general',C.POINTER(G.State)),('config',C.POINTER(Config))]
class Argument(C.Structure):_fields_=[('backend',C.POINTER(State)),('chain',C.POINTER(G.GChain))]
COUNT=C.CFUNCTYPE(I,P)
ALLOC=C.CFUNCTYPE(P,P,I,U,U)
FREE=C.CFUNCTYPE(None,P,I,P)
CREATE=C.CFUNCTYPE(I,P,C.POINTER(U),U,C.POINTER(Argument))
JOIN=C.CFUNCTYPE(I,P,U,C.POINTER(U))
LOG=C.CFUNCTYPE(None,P,U,U,I)
class Ops(C.Structure):_fields_=[('count',COUNT),('allocate',ALLOC),('release',FREE),('create',CREATE),('join',JOIN),('log',LOG)]
def ptr(p):return C.cast(p,P).value or 0

def initial_chains(p,bank):
    default=[(1,1,600+i*100) for i in range(CAPACITY)]
    values=p.get('banks',[p.get('chains',default),default])[bank]
    return list(values)+default[len(values):]

def init_opaque(m,seed=0):
    for lit,pc in ((0x65f68,0x65b50),(0x65f6c,0x65b64),(0x65fac,0x65d40),
                   (0x65fb0,0x65d58),(0x65fb4,0x65d74),(0x57028,0x56ff4),(0x5702c,0x56ffc)):
        target=m.read((pc+8+m.read(lit))&MASK)
        m.write(target,seed)

class View:
    def __init__(self,p,g=None):
        self.g=g if g is not None else G.State()
        if g is None:self.g.state=2;self.g.active=1
        self.configs=(Config*2)(*(Config(*v) for v in p.get('configs',[(100,400),(150,500)])))
        self.banks=[(G.GChain*CAPACITY)() for _ in range(2)]
        for b in range(2):
            for c,(present,state,freq) in zip(self.banks[b],initial_chains(p,b)):
                c.thermal.present=present;c.thermal.state=state;c.thermal.cleared_words[0]=freq&MASK
        self.s=State(C.pointer(self.g),C.pointer(self.configs[0]));self.g.chains=self.banks[0]
        self.arrays=[(Argument*CAPACITY)(),(U*CAPACITY)()];self.live=[False,False];self.sizes=[0,0]
        self.keep=[];self.errors=[]
    def cfg_bank(self):return 0 if ptr(self.s.config)==C.addressof(self.configs[0]) else 1
    def chain_identity(self,p):
        if not ptr(p):return None
        for bank,cs in enumerate(self.banks):
            n=(ptr(p)-C.addressof(cs))//C.sizeof(G.GChain)
            if 0<=n<CAPACITY and ptr(p)==C.addressof(cs[n]):return (bank,n)
        raise AssertionError(('unknown chain pointer',ptr(p)))
    def snapshot(self):
        configs=tuple((x.floor_0c,x.target_18) for x in self.configs)
        chains=tuple(tuple((x.thermal.present,x.thermal.state,x.thermal.cleared_words[0]) for x in b) for b in self.banks)
        args=tuple((0 if ptr(a.backend)==C.addressof(self.s) else None,self.chain_identity(a.chain)) for a in self.arrays[0][:self.sizes[0]]) if self.live[0] else None
        handles=tuple(self.arrays[1][:self.sizes[1]]) if self.live[1] else None
        return (self.cfg_bank(),self.chain_identity(self.g.chains)[0],configs,chains,self.g.state,self.g.active,args,handles)
    def mutate(self,k,v):
        if k=='config_bank':self.s.config=C.pointer(self.configs[v])
        elif k=='chain_bank':self.g.chains=self.banks[v]
        elif k in ('target','floor'):setattr(self.configs[v[0]],k+'_18' if k=='target' else 'floor_0c',v[1])
        elif k=='chain':
            b,i,f,x=v;c=self.banks[b][i].thermal
            if f=='frequency':c.cleared_words[0]=x&MASK
            else:setattr(c,f,x)
        elif k=='handle':self.arrays[1][v[0]]=v[1]&MASK
        elif k=='gstate':self.g.state=v
        elif k=='gactive':self.g.active=v
        else:raise AssertionError(k)

class ArmView:
    def __init__(self,m,p,given_backend=False):
        self.m=m;self.live=[False,False];self.sizes=[0,0]
        if not given_backend:m.write(BASE+0x20,2);m.write(BASE+0x24,1,1)
        m.write(BASE+0x18,MODEL[0]);m.write(BASE+0x230,CHAINS[0])
        for b,(floor,target) in enumerate(p.get('configs',[(100,400),(150,500)])):
            m.write(MODEL[b]+0xd8,floor);m.write(MODEL[b]+0xe4,target)
            for i,(present,state,freq) in enumerate(initial_chains(p,b)):
                at=CHAINS[b]+i*800;m.write(at+0x20,state);m.write(at+0x24,present,1);m.write(at+0x28,freq)
        init_opaque(m,p.get('opaque',0xffffffff))
    def chain_identity(self,p):
        if p==0:return None
        for b,base in enumerate(CHAINS):
            if base<=p<base+CAPACITY*800 and (p-base)%800==0:return (b,(p-base)//800)
        raise AssertionError(('unknown ARM chain',hex(p)))
    def snapshot(self):
        m=self.m;configs=tuple((signed(m.read(a+0xd8)),signed(m.read(a+0xe4))) for a in MODEL)
        chains=tuple(tuple((m.read(a+i*800+0x24,1),m.read(a+i*800+0x20),m.read(a+i*800+0x28)) for i in range(CAPACITY)) for a in CHAINS)
        args=tuple((0 if m.read(ARGS+8*i)==BASE else None,self.chain_identity(m.read(ARGS+8*i+4))) for i in range(self.sizes[0])) if self.live[0] else None
        handles=tuple(m.read(HANDLES+i*4) for i in range(self.sizes[1])) if self.live[1] else None
        return (MODEL.index(m.read(BASE+0x18)),self.chain_identity(m.read(BASE+0x230))[0],configs,chains,m.read(BASE+0x20),m.read(BASE+0x24,1),args,handles)
    def mutate(self,k,v):
        m=self.m
        if k=='config_bank':m.write(BASE+0x18,MODEL[v])
        elif k=='chain_bank':m.write(BASE+0x230,CHAINS[v])
        elif k in ('target','floor'):m.write(MODEL[v[0]]+(0xe4 if k=='target' else 0xd8),v[1])
        elif k=='chain':
            b,i,f,x=v;off,n={'state':(0x20,4),'present':(0x24,1),'frequency':(0x28,4)}[f];m.write(CHAINS[b]+i*800+off,x,n)
        elif k=='handle':m.write(HANDLES+v[0]*4,v[1])
        elif k=='gstate':m.write(BASE+0x20,v)
        elif k=='gactive':m.write(BASE+0x24,v,1)
        else:raise AssertionError(k)

class Script(R.Script):
    def __init__(self,p,view,extra_snap=lambda:(),extra_mutate=None):
        def mutate(k,v):
            if k.startswith('extra_'):
                assert extra_mutate is not None;extra_mutate(k,v)
            else:view.mutate(k,v)
        super().__init__(p,lambda:(view.snapshot(),extra_snap()),mutate)
    def call(self,name,*args):
        n=self.calls[name];rc=super().call(name,*args)
        if name=='count':return R.select(self.p,'count',n,self.p.get('count',3))
        return rc

def allocation_fails(p,kind,count,stride):
    return count>MASK//stride or p.get('alloc_fail')==kind or (count==0 and p.get('null_zero',False))

def bind_native(view,p,extra_snap=lambda:(),extra_mutate=None):
    sc=Script(p,view,extra_snap,extra_mutate);callbacks=[];errors=[]
    def cb(ty,fn):
        def f(*a):
            try:return fn(*a)
            except BaseException as e:errors.append(e);return None if ty in (ALLOC,FREE,LOG) else 0
        c=ty(f);callbacks.append(c);return c
    def allocate(_,kind,count,stride):
        assert kind in (0,1) and stride==(8 if kind==0 else 4)
        sc.call('allocate',kind,count,stride)
        if allocation_fails(p,kind,count,stride):return None
        assert count<=CAPACITY,('unbounded fixture allocation',count)
        array=view.arrays[kind];C.memset(C.addressof(array),0,C.sizeof(array))
        view.live[kind]=True;view.sizes[kind]=count
        return C.addressof(array)
    def release(_,kind,address):
        assert view.live[kind] and address==C.addressof(view.arrays[kind]);sc.call('free',kind);view.live[kind]=False
    def create(_,handle,entry,arg):
        assert entry==0x65fcc and view.live==[True,True]
        i=(ptr(arg)-C.addressof(view.arrays[0]))//C.sizeof(Argument)
        assert 0<=i<view.sizes[0] and ptr(arg)==C.addressof(view.arrays[0][i])
        assert ptr(handle)==C.addressof(view.arrays[1])+4*i and ptr(arg.contents.backend)==C.addressof(view.s)
        rc=sc.call('create',i,entry,0,view.chain_identity(arg.contents.chain))
        if not p.get('no_handle_write'):handle[0]=R.select(p,'handle_value',i,0x600+i)&MASK
        return rc
    def join(_,handle,out):
        assert not out;return sc.call('join',handle,False)
    ops=Ops(cb(COUNT,lambda _:sc.call('count')),cb(ALLOC,allocate),cb(FREE,release),cb(CREATE,create),cb(JOIN,join),LOG())
    if not p.get('nolog'):ops.log=cb(LOG,lambda _,line,level,val:sc.call('log',line,level,val))
    return ops,sc,callbacks,errors

def bind_original(view,p,extra_snap=lambda:(),extra_mutate=None):
    m=view.m;sc=Script(p,view,extra_snap,extra_mutate)
    def count(_):m.r[0]=sc.call('count')&MASK
    def allocate(_):
        n,stride=m.r[:2];kind=0 if stride==8 else 1
        assert stride==(8 if kind==0 else 4);sc.call('allocate',kind,n,stride)
        if allocation_fails(p,kind,n,stride):m.r[0]=0;return
        assert n<=CAPACITY;address=(ARGS,HANDLES)[kind]
        m.mem[address:address+n*stride]=b'\0'*(n*stride);view.live[kind]=True;view.sizes[kind]=n;m.r[0]=address
    def release(_):
        kind=(ARGS,HANDLES).index(m.r[0]);assert view.live[kind]
        sc.call('free',kind);view.live[kind]=False;m.r[0]=0xcccccccc
    def create(_):
        handle,attr,entry,arg=m.r[:4];i=(arg-ARGS)//8
        assert 0<=i<view.sizes[0] and arg==ARGS+8*i and handle==HANDLES+4*i
        assert attr==0 and entry==0x65fcc and m.read(arg)==BASE
        rc=sc.call('create',i,entry,0,view.chain_identity(m.read(arg+4)))
        if not p.get('no_handle_write'):m.write(handle,R.select(p,'handle_value',i,0x600+i))
        m.r[0]=rc&MASK
    def join(_):
        assert m.r[1]==0;m.r[0]=sc.call('join',m.r[0],False)&MASK
    def log(_):
        assert tuple(m.r[:3])==(0x5e50dc,0x5e50be,0x5e50e3)
        line=m.r[3];level,msg=LOGS[line];sp=m.r[13]
        assert m.read(sp)==level and m.read(sp+4)==msg
        val=signed(m.read(sp+8)) if line in (4496,4506) else 0
        if not p.get('nolog'):sc.call('log',line,level,val)
        m.r[0]=0xabababab
    return sc,{0xfe668:count,0x593bb4:allocate,0x593c8c:release,0x5a55cc:create,0x5a5d2c:join,0xfa0c4:log}

class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES),('unexpected frequency-fall instruction',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)
class Original:
    def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,p):
        m=self.m;m.mem[BASE:BASE+0x10000]=b'\xa5'*0x10000;m.visited=set()
        view=ArmView(m,p);sc,hooks=bind_original(view,p)
        before=bytes(m.mem[BASE:BASE+0x1100]);m.reset((BASE,));rc=m.run(START,hooks=hooks,max_steps=6000)
        assert m.r[13]==m.STACK_TOP and not any(view.live)
        self.steps+=m.steps;self.visited|=m.visited
        # No backend writes except explicitly scripted scalar/pointer mutations.
        after=bytearray(m.mem[BASE:BASE+0x1100])
        for off,n in ((0x18,4),(0x230,4),(0x20,4),(0x24,1)):after[off:off+n]=before[off:off+n]
        assert after==before,'unexpected original backend write'
        return signed(rc),view.snapshot(),sc.events
class Native:
    def __init__(self,lib):
        self.f=lib.vn135_backend_fall_frequency_135
        self.f.argtypes=[C.POINTER(State),C.POINTER(Ops),P];self.f.restype=I
    def run(self,p):
        view=View(p);ops,sc,keep,errors=bind_native(view,p)
        result=self.f(C.byref(view.s),C.byref(ops),None)
        if errors:raise errors[0]
        assert not any(view.live)
        return result,view.snapshot(),sc.events

def cases(quick=False):
    # Each targeted mutation below must be rejected by one of these real paths.
    yield 'baseline',{}
    yield 'already_at_target',{'configs':[(100,600),(150,500)]}
    yield 'allocation_arguments_failure',{'alloc_fail':0}
    yield 'allocation_handles_failure',{'alloc_fail':1}
    yield 'create_failure_after_success',{'returns':{'create':[0,11]}}
    yield 'ignore_join_failure',{'returns':{'join':-3}}
    yield 'include_inactive_chain_in_creation',{'chains':[(1,1,700),(0,1,100),(1,1,800)]}
    yield 'minimum_not_maximum',{'chains':[(1,1,800),(1,1,300),(1,1,900)]}
    yield 'configuration_floor_dominates',{'configs':[(700,400),(100,400)],'chains':[(0,1,900)]*6}
    yield 'all_workers_then_no_active_still_zero',{'returns':{'count':[3,3,0]}}
    yield 'zero_initial_but_positive_later',{'returns':{'count':[0,3,3]}}
    yield 'zero_initial_and_no_active_later',{'configs':[(700,400),(100,400)],'returns':{'count':[0,0,0]}}
    yield 'live_handle_at_join',{'mutations':[('join',0,'handle',[1,0xface])]}
    yield 'first_configuration_pointer_is_captured',{'configs':[(100,900),(700,400)],'mutations':[('allocate',0,'config_bank',1)]}
    yield 'second_configuration_pointer_is_captured',{'configs':[(900,400),(100,400)],'mutations':[('count',1,'config_bank',1)]}
    yield 'chain_pointer_is_fresh_per_worker',{'mutations':[('create',0,'chain_bank',1)]}
    if quick:return
    for n in range(CAPACITY+1):
        for fail in (None,0,1):yield 'allocation_count',{'count':n,'alloc_fail':fail}
    for n in (0x20000000,0x40000000,0x7fffffff,0x80000000,0xffffffff):
        yield 'source_allocation_overflow',{'count':signed(n)}
    for count,mincount,after in itertools.product((0,1,3,6),(0,1,3,6),(-1,0,1,3,6)):
        yield 'independent_counts',{'returns':{'count':[count,mincount,after]},'configs':[(700,400),(100,400)]}
    for st,present in itertools.product((0,1,2,3,4,5,6,7,0x7fffffff,0x80000000,0xffffffff),(0,1,127,255)):
        yield 'chain_predicate',{'chains':[(present,st,300),(1,1,700),(1,1,800)]}
    for floor,target,freq in itertools.product((-2147483648,-1,0,100,400,700,2147483647),repeat=3):
        yield 'signed_frequency_boundaries',{'configs':[(floor,target),(100,500)],'chains':[(1,1,freq)]*6}
    for n in range(1,CAPACITY+1):
        for i in range(n):
            for rc in (-2147483648,-3,1,11,2147483647):
                yield 'partial_creation_failure',{'count':n,'returns':{'create':[0]*i+[rc]}}
    for name,occ in [('count',0),('allocate',0),('allocate',1),('count',1),('log',0),('create',0),('create',1),('join',0),('count',2),('free',0),('free',1)]:
        for k,v in [('target',[0,900]),('floor',[0,900]),('config_bank',1),('chain_bank',1),('chain',[0,0,'frequency',0xffffffff]),('chain',[0,1,'present',0]),('gstate',7),('gactive',0)]:
            yield 'effect_boundary_mutation',{'mutations':[(name,occ,k,v)]}
    for op,n in itertools.product(('create','join'),range(3)):
        yield 'handle_mutation',{'mutations':[(op,n,'handle',[2,0xffffffff])],'returns':{'join':-3}}
    for x in (0,1,2,9,10,0x7fffffff,0x80000000,0xffffffff):yield 'opaque_words',{'opaque':x}
    yield 'calloc_zero_null',{'count':0,'null_zero':True}
    yield 'optional_log',{'nolog':True}
    yield 'worker_does_not_write_handle',{'no_handle_write':True}
    rng=random.Random(0x65b3c)
    for _ in range(300):
        n=rng.randrange(7);p={'count':n,'configs':[(rng.randrange(-200,1200),rng.randrange(-200,1000)),(500,600)],
            'banks':[[(rng.choice((0,1,255)),rng.randrange(9),rng.randrange(-100,1200)) for _ in range(6)] for _ in range(2)],
            'returns':{'create':rng.choice((0,0,0,1,-3)),'join':rng.choice((0,-1,11))},'opaque':rng.getrandbits(32)}
        if rng.randrange(4)==0:p['alloc_fail']=rng.randrange(2)
        yield 'seeded',p

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=R.ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
    native=Native(C.CDLL(str(Path(a.library).resolve())));original=Original(elf)
    counts=collections.Counter();events=0
    for name,p in cases(a.quick):
        want=original.run(p);got=native.run(p)
        if got!=want:
            raise AssertionError(('FREQUENCY_FALL_ORIGINAL_MISMATCH',name,p,want,got))
        counts[name]+=1;events+=len(want[2])
    result={'cases':sum(counts.values()),'groups':dict(counts),'events':events,'arm_steps':original.steps,
        'visited_instruction_addresses':len(original.visited),'original_65b3c_getters_predicates':True,
        'worker_65fcc_recovered':False,'real_threads':False,'hardware_io':False,'allocator_effects':'explicit typed fixtures'}
    if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
    print('FREQUENCY_FALL135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
