#!/usr/bin/env python3
"""Unchanged 57a10 instructions versus typed C; scripted device/lock effects."""
import argparse, collections, ctypes as C, hashlib, itertools, json, random, struct
from pathlib import Path
import test_general_monitor_135 as G
from test_thermal_routes_135 import Chip
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import MASK, signed
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[2]
START,END=0x57a10,0x57d34
CHAIN=0x840000
BACKENDS=(0x842000,0x842800)
CHIPS=(0x844000,0x845000)
APPLIES=(0x820040,0x820044)
PULSES=(0x820048,0x82004c)
CAP=8
I,U,P,D=G.I,G.U,G.P,G.D
GP=C.POINTER(G.GChain)
APPLY=C.CFUNCTYPE(I,P,GP,D)
PULSE=C.CFUNCTYPE(I,P,GP,U,U,U)
LOCK=C.CFUNCTYPE(I,P,GP)
PLATFORM=C.CFUNCTYPE(U,P)
LOG=C.CFUNCTYPE(None,P,U,U,D)
class Methods(C.Structure):_fields_=[('apply',APPLY),('pulse',PULSE)]
class View(C.Structure):_fields_=[('chain',GP),('methods',C.POINTER(Methods))]
class Ops(C.Structure):_fields_=[('lock',LOCK),('unlock',LOCK),('platform',PLATFORM),('log',LOG)]
def bits(f):return struct.pack('<d',f).hex()
def address(p):return C.cast(p,P).value or 0
def selected(p,key,n,default=0):
    v=p.get('returns',{}).get(key,default)
    return v[min(n,len(v)-1)] if isinstance(v,list) else v
class Script:
    def __init__(self,p,view):self.p=p;self.view=view;self.events=[];self.counts=collections.Counter()
    def call(self,name,*args):
        n=self.counts[name];self.counts[name]+=1
        self.events.append((name,*args,self.view.snapshot()))
        for stage,k,field,value in self.p.get('mutations',[]):
            if (name,n)==(stage,k):self.view.mutate(field,value)
        return selected(self.p,name,n,4 if name=='platform' else 0)

class NativeView:
    def __init__(self,p):
        self.chain=G.GChain();C.memset(C.byref(self.chain),0xa5,C.sizeof(self.chain))
        self.banks=[(Chip*CAP)() for _ in range(2)]
        for bank,cs in enumerate(self.banks):
            C.memset(cs,0x5a,C.sizeof(cs))
            for i,c in enumerate(cs):c.word_08=100*(i+1)+bank
        c=self.chain.thermal;c.index=p.get('index',2);c.state=p.get('state',2);c.present=p.get('present',1)
        c.cleared_words[:]=p.get('cache',[123,0x66666666,0x77777777,456])
        c.chips=self.banks[0];self.chain.detected_8c=p.get('count',3)
        self.slots=[[0,0],[1,1]];self.methods=(Methods*2)();self.v=View(C.pointer(self.chain),C.pointer(self.methods[0]))
        self.keep=[];self.errors=[];self.sc=Script(p,self);self.cb_apply=[];self.cb_pulse=[]
        def wrap(ty,fn):
            def cb(*a):
                try:return fn(*a)
                except BaseException as error:self.errors.append(error);return 0
            x=ty(cb);self.keep.append(x);return x
        def apply(slot,chain,f):
            assert address(chain)==C.addressof(self.chain)
            return self.sc.call('apply',slot,bits(f))
        def pulse(slot,chain,b,a,one):
            assert address(chain)==C.addressof(self.chain) and one==1
            return self.sc.call('pulse',slot,b,a,one)
        for slot in range(2):
            self.cb_apply.append(wrap(APPLY,lambda _,c,f,s=slot:apply(s,c,f)))
            self.cb_pulse.append(wrap(PULSE,lambda _,c,b,a,t,s=slot:pulse(s,c,b,a,t)))
        for slot in range(2):self.methods[slot]=Methods(self.cb_apply[slot],self.cb_pulse[slot])
        def lock(name,chain):
            assert address(chain)==C.addressof(self.chain);return self.sc.call(name)
        log=LOG() if p.get('nolog') else wrap(LOG,lambda _,l,i,f:self.sc.call('log',l,i,bits(f)))
        self.ops=Ops(wrap(LOCK,lambda _,c:lock('lock',c)),wrap(LOCK,lambda _,c:lock('unlock',c)),
                     wrap(PLATFORM,lambda _:self.sc.call('platform')),log)
    def bank(self):return [C.addressof(b) for b in self.banks].index(address(self.chain.thermal.chips))
    def snapshot(self):
        c=self.chain.thermal
        return ((address(self.v.methods)-C.addressof(self.methods))//C.sizeof(Methods),self.bank(),self.chain.detected_8c,
                c.index,c.state,c.present,tuple(c.cleared_words),tuple(tuple(x.word_08 for x in cs) for cs in self.banks),tuple(tuple(x) for x in self.slots))
    def mutate(self,k,v):
        c=self.chain.thermal
        if k=='owner':self.v.methods=C.pointer(self.methods[v])
        elif k=='bank':c.chips=self.banks[v]
        elif k=='count':assert 0<=v<=CAP;self.chain.detected_8c=v
        elif k in ('index','state','present'):setattr(c,k,v)
        elif k=='cache':c.cleared_words[v[0]]=v[1]&MASK
        elif k=='chip':self.banks[v[0]][v[1]].word_08=v[2]&MASK
        elif k=='slot':
            owner,which,slot=v;self.slots[owner][which]=slot
            setattr(self.methods[owner],'apply' if which==0 else 'pulse',(self.cb_apply if which==0 else self.cb_pulse)[slot])
        else:raise AssertionError(k)
    def raw(self):return [C.string_at(C.addressof(self.chain),C.sizeof(self.chain))]+[C.string_at(C.addressof(b),C.sizeof(b)) for b in self.banks]
    def immutable(self,before):
        after=list(map(bytearray,self.raw()))
        for k in ('index','state','present','cleared_words','chips'):
            field=getattr(G.Chain,k);a=field.offset;after[0][a:a+field.size]=before[0][a:a+field.size]
        field=G.GChain.detected_8c;after[0][field.offset:field.offset+4]=before[0][field.offset:field.offset+4]
        for bank in range(2):
            for i in range(CAP):
                a=i*C.sizeof(Chip)+Chip.word_08.offset;after[bank+1][a:a+4]=before[bank+1][a:a+4]
        assert after==before,'extra native state write'

class ArmView:
    def __init__(self,m,p):
        self.m=m;m.mem[CHAIN:CHAIN+0x6000]=b'\xa5'*0x6000
        m.write(CHAIN+0x1c,BACKENDS[0]);m.write(CHAIN+0x88,CHIPS[0]);m.write(CHAIN+0x8c,p.get('count',3))
        for offset,key,default,n in ((0x18,'index',2,4),(0x20,'state',2,4),(0x24,'present',1,1)):
            m.write(CHAIN+offset,p.get(key,default),n)
        for i,off in enumerate((0x28,0x30,0x34,0x38)):m.write(CHAIN+off,p.get('cache',[123,0x66666666,0x77777777,456])[i])
        for bank,a in enumerate(CHIPS):
            m.mem[a:a+CAP*96]=b'\x5a'*(CAP*96)
            for i in range(CAP):m.write(a+i*96+8,100*(i+1)+bank)
        for i,a in enumerate(BACKENDS):m.write(a+0x140,APPLIES[i]);m.write(a+0x188,PULSES[i])
        for lit,pc in ((0x57d40,0x57a38),(0x57d44,0x57a5c)):
            a=m.read((pc+8+m.read(lit))&MASK);m.write(a,p.get('opaque',0xffffffff))
        self.sc=Script(p,self)
    def snapshot(self):
        m=self.m
        return (BACKENDS.index(m.read(CHAIN+0x1c)),CHIPS.index(m.read(CHAIN+0x88)),m.read(CHAIN+0x8c),
                m.read(CHAIN+0x18),m.read(CHAIN+0x20),m.read(CHAIN+0x24,1),
                tuple(m.read(CHAIN+x) for x in (0x28,0x30,0x34,0x38)),
                tuple(tuple(m.read(a+i*96+8) for i in range(CAP)) for a in CHIPS),
                tuple((APPLIES.index(m.read(a+0x140)),PULSES.index(m.read(a+0x188))) for a in BACKENDS))
    def mutate(self,k,v):
        m=self.m
        if k=='owner':m.write(CHAIN+0x1c,BACKENDS[v])
        elif k=='bank':m.write(CHAIN+0x88,CHIPS[v])
        elif k=='count':assert 0<=v<=CAP;m.write(CHAIN+0x8c,v)
        elif k in ('index','state','present'):m.write(CHAIN+{'index':0x18,'state':0x20,'present':0x24}[k],v,1 if k=='present' else 4)
        elif k=='cache':m.write(CHAIN+(0x28,0x30,0x34,0x38)[v[0]],v[1])
        elif k=='chip':m.write(CHIPS[v[0]]+v[1]*96+8,v[2])
        elif k=='slot':m.write(BACKENDS[v[0]]+(0x140,0x188)[v[1]],(APPLIES,PULSES)[v[1]][v[2]])
        else:raise AssertionError(k)
    def raw(self):return [bytes(self.m.mem[CHAIN:CHAIN+800])]+[bytes(self.m.mem[a:a+CAP*96]) for a in CHIPS]
    def immutable(self,before):
        after=list(map(bytearray,self.raw()))
        for a,n in ((0x18,4),(0x1c,4),(0x20,4),(0x24,1),(0x28,4),(0x30,8),(0x38,4),(0x88,4),(0x8c,4)):
            after[0][a:a+n]=before[0][a:a+n]
        for bank in range(2):
            for i in range(CAP):
                a=i*96+8;after[bank+1][a:a+4]=before[bank+1][a:a+4]
        assert after==before,'extra ARM state write'
    def hooks(self,p):
        m=self.m;sc=self.sc
        def apply(slot):
            def hook(_):
                assert m.r[0]==CHAIN+0x2b8;m.r[0]=sc.call('apply',slot,bits(m.d(0)))&MASK
            return hook
        def pulse(slot):
            def hook(_):
                assert m.r[0]==CHAIN+0x2b8 and m.r[3]==1
                m.r[0]=sc.call('pulse',slot,*m.r[1:4])&MASK
            return hook
        def lock(name):
            def hook(_):
                assert m.r[0]==CHAIN;m.r[0]=sc.call(name)&MASK
            return hook
        def platform(_):m.r[0]=sc.call('platform')&MASK
        def log(_):
            assert m.r[:3]==[0x5e4260,0x5e4267,0x5e4286]
            line=m.r[3];sp=m.r[13];assert line in (1060,1074) and m.read(sp)==1
            assert m.read(sp+4)==(0x5e47ef if line==1060 else 0x5e481a)
            f=struct.unpack('<d',m.read(sp+16,8).to_bytes(8,'little'))[0] if line==1060 else 0.0
            if not p.get('nolog'):sc.call('log',line,m.read(sp+8),bits(f))
            m.r[0]=0xc0de
        hooks={a:apply(i) for i,a in enumerate(APPLIES)}
        hooks.update({a:pulse(i) for i,a in enumerate(PULSES)})
        hooks.update({0x5a6108:lock('lock'),0x5a66c4:lock('unlock'),0xfdfbc:platform,0xfa0c4:log})
        return hooks
class Machine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert START<=pc<END,('unreviewed instruction',hex(pc));self.visited.add(pc)
        return super().extra_instruction(w,pc)
class Original:
    def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,p):
        m=self.m;m.visited=set();v=ArmView(m,p);before=v.raw();hooks=v.hooks(p);results=[]
        for _ in range(p.get('repeat',1)):
            m.reset((CHAIN,p.get('a',29),p.get('b',17)));m.set_d(0,p.get('frequency',600.75));m.set_d(8,123.125)
            result=m.run(START,hooks=hooks,max_steps=10000);results.append(signed(result))
            assert m.r[13]==m.STACK_TOP and m.d(8)==123.125
            self.steps+=m.steps;self.visited|=m.visited
        v.immutable(before);return results,v.snapshot(),v.sc.events
class Native:
    def __init__(self,lib):
        self.f=lib.vn135_chain_set_frequency_135;self.f.restype=I
        self.f.argtypes=[C.POINTER(View),U,U,D,C.POINTER(Ops),P]
    def run(self,p):
        v=NativeView(p);before=v.raw();results=[]
        for _ in range(p.get('repeat',1)):
            results.append(self.f(C.byref(v.v),p.get('a',29),p.get('b',17),p.get('frequency',600.75),C.byref(v.ops),None))
        if v.errors:raise v.errors[0]
        v.immutable(before);return results,v.snapshot(),v.sc.events

def cases(quick=False):
    for f,n,platform,apply,pulse in itertools.product([449.9,450.0,635.75,-0.0],[0,1,3],[0,4],[-1,0],[-1,0]):
        yield 'gates',dict(frequency=f,count=n,returns={'platform':platform,'apply':apply,'pulse':pulse})
    yield 'owner-captured-before-platform',dict(mutations=[('unlock',0,'owner',1),('platform',0,'owner',0)])
    yield 'slot-read-after-platform',dict(mutations=[('platform',0,'slot',(0,1,1))])
    yield 'min-read-after-platform',dict(mutations=[('platform',0,'cache',(0,400))])
    yield 'cached-write-after-lock',dict(mutations=[('lock',0,'bank',1),('lock',0,'count',5)])
    yield 'inactive',dict(present=0)
    yield 'inactive-state',dict(state=4)
    yield 'inactive-state-five',dict(state=5)
    if quick:return
    for present in range(256):yield 'all-flag-bytes',dict(present=present)
    for state in [0,1,2,3,4,5,6,7,0x7fffffff,0x80000000,0xffffffff]:yield 'states',dict(state=state)
    for f in [-1e30,-2147483649.,-2147483648.,-2147483647.9,-450.9,-1.9,-.9,0.,.9,1.9,449.,449.999,450.001,2147483646.9,2147483647.,2147483648.,1e30]:
        for n in [0,1,2,8]:yield 'finite-conversion',dict(frequency=f,count=n)
    changes=[('owner',1),('bank',1),('count',0),('count',5),('state',4),('present',0),('index',MASK),
             ('cache',(0,100)),('cache',(3,MASK)),('chip',(0,0,111)),('slot',(0,1,1)),('slot',(1,1,0))]
    for stage,(k,v),error in itertools.product(['apply','lock','unlock','platform','pulse','log'],changes,[0,1,2]):
        yield 'callback-change',dict(mutations=[(stage,0,k,v)],returns={'apply':-7 if error==1 else 0,'pulse':-9 if error==2 else 0,'lock':-3,'unlock':-4})
    for err in (0,1,2):
        for stage in ('apply','unlock','platform','log'):
            yield 'repeat',dict(repeat=2,mutations=[(stage,0,'owner',1)],returns={'apply':err==1,'pulse':err==2})
    for err in [0,1,2]:yield 'no-logger',dict(nolog=True,returns={'apply':err==1,'pulse':err==2})
    rng=random.Random(0x57a10)
    for _ in range(250):
        yield 'mixed',dict(count=rng.randrange(9),state=rng.choice([0,2,3,4,6,MASK]),present=rng.randrange(256),index=rng.getrandbits(32),
            a=rng.getrandbits(32),b=rng.getrandbits(32),frequency=rng.uniform(-100,1700),opaque=rng.getrandbits(32),
            returns={'platform':rng.choice([0,1,2,3,4,5,MASK]),'apply':rng.choice([0,0,-5]),'pulse':rng.choice([0,-7])})

def main():
    parser=argparse.ArgumentParser();parser.add_argument('library');parser.add_argument('--summary');parser.add_argument('--quick',action='store_true');args=parser.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    original=Original(elf);native=Native(C.CDLL(str(Path(args.library).resolve())));count=events=0
    for name,p in cases(args.quick):
        expected=original.run(p);actual=native.run(p)
        if actual!=expected:
            print('CHAIN_FREQUENCY135_MISMATCH',name,json.dumps(p),flush=True)
            for i,(a,b) in enumerate(itertools.zip_longest(actual[2],expected[2])):
                if a!=b:print('event',i,'native',a,'original',b);break
            print('final',actual[:2],expected[:2]);raise AssertionError('C differs from unchanged original')
        count+=1;events+=len(expected[2])
    summary=dict(cases=count,events=events,steps=original.steps,instruction_addresses=len(original.visited),physical_io=False,real_threads=False,new_arm_opcodes=0)
    print('CHAIN_FREQUENCY135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
    if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
