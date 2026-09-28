#!/usr/bin/env python3
"""65fcc and nested 60a2c A32 instructions vs isolated C. No device or OS I/O."""
import argparse, collections, ctypes as C, hashlib, itertools, json, random
from pathlib import Path
import test_monitor_handlers_135 as H
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed, MASK
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[2]
BASE,MODEL,CHAINS=H.BASE,H.MODEL,H.CHAINS
ARG=0x849000
I,U,P,D=H.I,H.U,H.P,H.D
class Config(C.Structure): _fields_=[('floor',I),('target',I)]
class Fall(C.Structure): _fields_=[('general',C.POINTER(H.G.State)),('config',C.POINTER(Config))]
class Argument(C.Structure): _fields_=[('backend',C.POINTER(Fall)),('chain',C.POINTER(H.G.GChain))]
class Control(C.Structure): _fields_=[('word_10',U),('word_20',U)]
class View(C.Structure): _fields_=[('control',C.POINTER(Control)),('handlers',C.POINTER(H.State))]
CALL=C.CFUNCTYPE(I,P,U,U,U)
SET=C.CFUNCTYPE(I,P,C.POINTER(H.G.GChain),U,U,D)
STOP=C.CFUNCTYPE(I,P,C.POINTER(H.G.Chain),C.c_char_p)
CREATE=C.CFUNCTYPE(I,P,C.POINTER(U),U,C.POINTER(Fall))
LOG=C.CFUNCTYPE(None,P,U,U,I)
class Ops(C.Structure): _fields_=[('call',CALL),('set',SET),('stop',STOP),('create',CREATE),('log',LOG),('decisions',C.POINTER(H.Ops))]
NAMES={0x5a6b2c:'cancel_type',0x593af8:'name',0x10ef3c:'delay',0x49c98:'event',0x6b778:'power_stop',0x5a52d0:'exit'}
RANGES=((0x65fcc,0x66210),(0x60a2c,0x60d20),(0x56fcc,0x57028),(0x57030,0x57084),(0xa71e8,0xa7200),(0xa720c,0xa7218))
class ThreadExit(Exception): pass
class Machine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES), ('unexpected code',hex(pc))
        self.visited.add(pc)
        # The ONLY added A32 opcode: exact SMMUL r0,r4,r0 at this pinned PC.
        if pc==0x6603c:
            assert w==0xe750f014
            self.r[0]=((signed(self.r[4])*signed(self.r[0]))>>32)&MASK
            return True
        return super().extra_instruction(w,pc)

def pick(p,k,n,default=0):
    v=p.get('returns',{}).get(k,default)
    return v[min(n,len(v)-1)] if isinstance(v,list) else v
class Script:
    def __init__(self,p,snap,mutate): self.p=p;self.snap=snap;self.mutate=mutate;self.events=[];self.counts=collections.Counter()
    def call(self,name,*args):
        n=self.counts[name];self.counts[name]+=1
        self.events.append((name,*args,self.snap()))
        for at,index,key,value in self.p.get('mutations',[]):
            if at==name and index==n:self.mutate(key,value)
        if name=='stop_chain':self.mutate('state',(0,self.p.get('stop_state',3)))
        return pick(self.p,name,n,3 if name=='count' else 0)

def fields(p):
    return dict(frequency=p.get('frequency',635)&MASK,target=p.get('target',400),
        word10=p.get('word10',17)&MASK,word20=p.get('word20',29)&MASK,
        states=p.get('states',[2,2,2]),present=p.get('present',[1,1,1]),
        index=p.get('index',0)&MASK,minimum=p.get('minimum',2),
        partial=p.get('partial',0),query=p.get('query',0))

class Native:
    def __init__(self,lib):
        self.f=lib.vn135_frequency_fall_worker_135
        self.f.argtypes=[C.POINTER(Argument),C.POINTER(View),C.POINTER(Ops),P];self.f.restype=I
    def run(self,p):
        q=fields(p);hs,keep=H.setup({});g,model,_,chains,*_=keep
        for j,c in enumerate(chains): c.thermal.state=q['states'][j];c.thermal.present=q['present'][j];c.thermal.index=j
        chains[0].thermal.cleared_words[0]=q['frequency'];chains[0].thermal.index=q['index']
        hs.minimum_chains_f8=q['minimum'];hs.partial_chains_105=q['partial'];model.query_fault_87=q['query']
        config=Config(100,q['target']);fall=Fall(C.pointer(g),C.pointer(config));arg=Argument(C.pointer(fall),C.pointer(chains[0]))
        ctrl=Control(q['word10'],q['word20']);view=View(C.pointer(ctrl),C.pointer(hs))
        def snap():
            return (tuple((c.thermal.state,c.thermal.present,c.thermal.index,c.thermal.cleared_words[0]) for c in chains),
                    config.target,ctrl.word_10,ctrl.word_20,hs.minimum_chains_f8,hs.partial_chains_105,model.query_fault_87,
                    bool(arg.backend),bool(arg.chain))
        def mutate(k,v):
            if k=='frequency':chains[0].thermal.cleared_words[0]=v&MASK
            elif k=='target':config.target=v
            elif k=='word10':ctrl.word_10=v&MASK
            elif k=='word20':ctrl.word_20=v&MASK
            elif k in ('state','present'):setattr(chains[v[0]].thermal,k,v[1])
            elif k=='index':chains[0].thermal.index=v&MASK
            elif k=='minimum':hs.minimum_chains_f8=v
            elif k=='partial':hs.partial_chains_105=v
            elif k=='query':model.query_fault_87=v
            elif k=='poison_argument':arg.backend=C.POINTER(Fall)();arg.chain=C.POINTER(H.G.GChain)()
            else:raise AssertionError(k)
        sc=Script(p,snap,mutate);callbacks=[];errors=[]
        def cb(ty,fn):
            def wrapped(*args):
                try:return fn(*args)
                except BaseException as error:errors.append(error);return 0
            v=ty(wrapped);callbacks.append(v);return v
        def apply(_,c,a,b,f):
            assert C.addressof(c.contents)==C.addressof(chains[0]);return sc.call('set',a,b,f)
        def stop(_,c,reason):
            assert C.addressof(c.contents)==C.addressof(chains[0].thermal)
            assert reason==b'Failed to set minimum frequency';return sc.call('stop_chain')
        def create(_,handle,entry,backend):
            assert C.addressof(backend.contents)==C.addressof(fall) and entry==0x72ba4
            rc=sc.call('create',entry);handle[0]=0x135;return rc
        def decision(_,e,a,b):
            assert (e,a,b)==(0xfe668,0,0);return sc.call('count')
        def hlog(_,line,level,a,b,detail):return sc.call('decision_log',line,level,a,b)
        hops=H.Ops();hops.call=cb(H.CALL,decision);hops.log=cb(H.LOG,hlog)
        ops=Ops(cb(CALL,lambda _,e,a,b:sc.call(NAMES[e],a,b)),cb(SET,apply),cb(STOP,stop),cb(CREATE,create),
                cb(LOG,lambda _,line,index,f:sc.call('log',line,index,f)),C.pointer(hops))
        before=[C.string_at(C.addressof(c),C.sizeof(c)) for c in chains]
        result=self.f(C.byref(arg),C.byref(view),C.byref(ops),None)
        if errors:raise errors[0]
        assert result==1 and sc.events[-1][0]=='exit'
        # Only scripted scalar mutations are allowed, no extra implicit writes.
        for j,c in enumerate(chains):
            after=bytearray(C.string_at(C.addressof(c),C.sizeof(c)))
            for field in ('state','present','index','cleared_words'):
                off=getattr(H.G.Chain,field).offset;n=getattr(H.G.Chain,field).size
                after[off:off+n]=before[j][off:off+n]
            assert after==before[j]
        return snap(),sc.events

class Original:
    def __init__(self,elf): self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,p):
        m=self.m;q=fields(p);m.mem[BASE:BASE+0x10000]=b'\0'*0x10000;m.visited=set()
        m.write(ARG,BASE);m.write(ARG+4,CHAINS);m.write(BASE+0x18,MODEL);m.write(BASE+0x230,CHAINS)
        m.write(MODEL+0xe4,q['target']);m.write(MODEL+0x98,q['word10']);m.write(MODEL+0xa8,q['word20'])
        m.write(BASE+0xf8,q['minimum']);m.write(BASE+0x105,q['partial'],1);m.write(MODEL+0x87,q['query'],1)
        for j in range(3):
            at=CHAINS+800*j;m.write(at+0x20,q['states'][j]);m.write(at+0x24,q['present'][j],1);m.write(at+0x18,j)
        m.write(CHAINS+0x18,q['index']);m.write(CHAINS+0x28,q['frequency'])
        for lit,pc in [(0x66214,0x6605c),(0x66218,0x66070)]:
            address=m.read((pc+8+m.read(lit))&MASK);m.write(address,p.get('opaque',0xffffffff))
        def snap():
            return (tuple((m.read(CHAINS+800*j+0x20),m.read(CHAINS+800*j+0x24,1),m.read(CHAINS+800*j+0x18),m.read(CHAINS+800*j+0x28)) for j in range(3)),
                    signed(m.read(MODEL+0xe4)),m.read(MODEL+0x98),m.read(MODEL+0xa8),signed(m.read(BASE+0xf8)),m.read(BASE+0x105,1),m.read(MODEL+0x87,1),bool(m.read(ARG)),bool(m.read(ARG+4)))
        def mutate(k,v):
            if k=='frequency':m.write(CHAINS+0x28,v)
            elif k=='target':m.write(MODEL+0xe4,v)
            elif k in ('word10','word20'):m.write(MODEL+(0x98 if k=='word10' else 0xa8),v)
            elif k in ('state','present'):m.write(CHAINS+800*v[0]+(0x20 if k=='state' else 0x24),v[1],4 if k=='state' else 1)
            elif k=='index':m.write(CHAINS+0x18,v)
            elif k=='minimum':m.write(BASE+0xf8,v)
            elif k=='partial':m.write(BASE+0x105,v,1)
            elif k=='query':m.write(MODEL+0x87,v,1)
            elif k=='poison_argument':m.write(ARG,0);m.write(ARG+4,0)
            else:raise AssertionError(k)
        sc=Script(p,snap,mutate)
        def ret(v):m.r[0]=int(v)&MASK
        def scalar(entry):
            def hook(_):
                name=NAMES[entry];a=b=0
                if name=='cancel_type':assert m.r[:2]==[1,0];a=1
                elif name=='name':assert m.r[:4]==[15,0x5e6328,0,0] and m.read(m.r[13])==0;a=15
                elif name=='delay':assert m.r[0]==100;a=100
                elif name=='event':assert m.r[:2]==[BASE+0x10b4,2010];a=2010
                elif name=='power_stop':assert m.r[0]==BASE
                elif name=='exit':
                    assert m.r[0]==0;sc.call(name,0,0);raise ThreadExit()
                ret(sc.call(name,a,b))
            return hook
        def apply(_):
            assert m.r[0]==CHAINS;ret(sc.call('set',m.r[1],m.r[2],m.d(0)))
        def stop(_):
            assert m.r[:2]==[CHAINS,0x5e635e];ret(sc.call('stop_chain'))
        def create(_):
            out,attr,entry,arg=m.r[:4];assert (attr,entry,arg)==(0,0x72ba4,BASE)
            rc=sc.call('create',entry);m.write(out,0x135);ret(rc)
        def count(_):ret(sc.call('count'))
        def log(_):
            line=m.r[3];sp=m.r[13]
            if line in (4444,6483):
                assert m.r[:3]==[0x5e50dc,0x5e50be,0x5e50e3] and m.read(sp)==1
                assert m.read(sp+4)==(0x5e6336 if line==4444 else 0x5e5d0a)
                ret(sc.call('log',line,m.read(sp+8) if line==4444 else 0,signed(m.read(sp+12)) if line==4444 else 0))
            else:
                assert line in (445,451) and m.read(sp+4)==H.LOGS[line]
                ret(sc.call('decision_log',line,m.read(sp),m.read(sp+8) if line==451 else 0,m.read(sp+12) if line==451 else 0))
        hooks={entry:scalar(entry) for entry in NAMES};hooks.update({0x57a10:apply,0x56d18:stop,0x5a55cc:create,0xfe668:count,0xfa0c4:log})
        m.reset((ARG,))
        try:m.run(0x65fcc,hooks=hooks,max_steps=20000)
        except ThreadExit:pass
        else:raise AssertionError('missing non-returning thread-exit')
        assert m.r[13]==m.STACK_TOP-56
        self.steps+=m.steps;self.visited|=m.visited
        return snap(),sc.events

def cases():
    for freq,target in itertools.product([-201,-151,-101,-100,-51,-50,-49,-1,0,1,49,50,51,99,100,149,150,151,399,400,401,449,450,499,500,501,635,1200],[-200,-50,0,100,400,425,450,600,1250]):
        yield 'round-clamp',dict(frequency=freq,target=target)
    for present,state in itertools.product(range(256),[0,2,3,4,5,6,0xffffffff]):
        yield 'predicate',dict(present=[present,1,1],states=[state,2,2],frequency=400)
    for fail,minimum,partial,query,stopstate,created in itertools.product([0,1,2],[-1,0,2,3],[0,1],[0,1],[2,3,5],[-1,0,11]):
        yield 'error-path',dict(returns={'set':[0]*fail+[7],'create':created},minimum=minimum,partial=partial,query=query,stop_state=stopstate)
    mutations={'frequency':900,'target':725,'word10':0xfedcba98,'word20':0x89abcdef,'state':(0,5),'present':(0,0),'index':0xffffffff,'minimum':4,'partial':1,'query':1,'poison_argument':True}
    for stage,key in itertools.product(['cancel_type','name','set','delay','log','stop_chain','count','decision_log','event','create','power_stop'],mutations):
        for failed in (False,True):
            yield 'callback-mutation',dict(mutations=[(stage,0,key,mutations[key])],returns={'set':([0,7] if failed else 0),'create':11})
    rng=random.Random(0x65fcc)
    for _ in range(100):
        yield 'mixed',dict(frequency=rng.randrange(-200,1500),target=rng.randrange(-100,1600),word10=rng.getrandbits(32),word20=rng.getrandbits(32),opaque=rng.getrandbits(32),returns={'set':rng.choice([0,1,-1]),'create':rng.choice([0,-1])},minimum=rng.randrange(-1,4),stop_state=rng.choice([2,3,5]))
    for freq in [-2147483648,-2147483601,2147483647,2147483600]:
        # Force first apply failure to bound extreme signed fixtures.
        yield 'signed-boundary',dict(frequency=freq,target=-2147483648,returns={'set':1})

def rounding_fixtures(elf):
    m=Machine(elf);m.visited=set();rng=random.Random(50)
    values=list(range(-1001,1002))+[-2147483648,-2147483647,2147483646,2147483647]+[signed(rng.getrandbits(32)) for _ in range(4096)]
    for n in values:
        m.reset();m.r[4]=n&MASK;m.run(0x66034,stop=0x66050,max_steps=16)
        q=abs(n)//50*(-1 if n<0 else 1)
        assert signed(m.r[5])==q*50,(n,signed(m.r[5]),q*50)
    return len(values)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');args=ap.parse_args()
    ref=ROOT/'reference/cgminer.vendor.elf';assert hashlib.sha256(ref.read_bytes()).hexdigest()==H.G.REF
    elf=ELF32(ref);original=Original(elf);native=Native(C.CDLL(str(Path(args.library).resolve())))
    counts=collections.Counter();events=0
    for name,p in cases():
        expected=original.run(p);actual=native.run(p)
        if expected!=actual:
            print('MISMATCH',name,json.dumps(p));print('ORIGINAL',expected);print('NATIVE',actual);raise AssertionError('worker comparison mismatch')
        counts[name]+=1;events+=len(expected[1])
    summary={'cases':sum(counts.values()),'events':events,'instructions':original.steps,'visited':len(original.visited),'groups':dict(counts),'rounding_fixtures':rounding_fixtures(elf),'new_scoped_opcode':'SMMUL r0,r4,r0 at 6603c only','nested_original_60a2c':True,'physical_io':False,'real_threads':False}
    if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('FREQUENCY_WORKER135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
