#!/usr/bin/env python3
"""Whole original 6ec4c -> 58b50 -> b7798, 78eb8, 60a2c versus linked C.
Only lower sensor ops, chain-stop, key/registration, count/time/log are scripted.
No original bodies are stubbed on those five recovered call boundaries.
"""
import argparse, collections, ctypes as C, hashlib, itertools, json, random, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT/'tools'),str(Path(__file__).parent)]
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
import test_thermal_sensors_135 as T
import test_general_monitor_135 as G
import test_monitor_handlers_135 as H
from test_backend_resume_135 import Description
U,I,P=T.U,T.I,T.P
class View(C.Structure):
    _fields_=[('backend',C.POINTER(H.State)),('description',C.POINTER(Description)),('roles',C.POINTER(U))]
KEYCB=C.CFUNCTYPE(U,P)
REGCB=C.CFUNCTYPE(None,P,U,C.POINTER(G.State),U)
STOPCB=C.CFUNCTYPE(I,P,C.POINTER(G.Chain),C.c_char_p)
class Ops(C.Structure):
    _fields_=[('handlers',C.POINTER(H.Ops)),('temperature',C.POINTER(T.Ops)),('stop',STOPCB),('key',KEYCB),('register',REGCB)]
N=4;NC=3;BASE=G.BASE;MODEL=G.MODEL;GROUP=G.GROUP;TABLE=0x842600;CHAINS=G.CHAINS;SENSORS=G.SENSORS;KEY=0x820100
RECOVERED=((0x6ec4c,0x6f188),(0x58b50,0x58cf0),(0x78eb8,0x790b4),(0x60a2c,0x60d20),(0x56fcc,0x57028),(0x57030,0x57084))
ENTRIES=(0x6ec4c,0x58b50,0xb7798,0x78eb8,0x60a2c)

def value(p,key,i,default):
    v=p.get(key,default)
    return v[min(i,len(v)-1)] if isinstance(v,list) else v

def initial(p):
    types=list(p.get('types',[1,2]));roles=list(p.get('roles',[0,2]))
    if len(types)>N or len(roles)>N:raise ValueError('fixture exceeds four descriptors')
    count=p.get('sensors',len(types));types += [0]*(N-len(types));roles += [0]*(N-len(roles))
    if count>N:raise ValueError('count exceeds fixture')
    banks=[]
    for ci in range(NC):
        bank=[]
        for si in range(N):
            k=ci*N+si
            bank.append(T.template(index=si,access_kind=value(p,'kinds',k,types[si]),
                role=value(p,'sensor_roles',k,roles[si]),state=value(p,'sensor_states',k,0),
                remote_enabled=value(p,'remote',k,1),skip_initial_read=value(p,'skip',k,1)))
        banks.append(bank)
    return count,types,roles,banks

class Script:
    def __init__(self,p):self.p=p;self.events=[];self.calls=collections.Counter();self.reads=collections.Counter();self.time=0;self.snap=None;self.change=None
    def event(self,name,*args):
        n=self.calls[name];self.calls[name]+=1
        self.events.append((name,tuple(args),self.snap()))
        for op,nth,k,v in self.p.get('mutations',[]):
            if op==name and n==nth:self.change(k,v)
    def count(self):
        n=self.calls['count'];self.event('count');return value(self.p,'counts',n,3)
    def key(self):self.event('key');return self.p.get('key',0x44)
    def register(self,k,h):self.event('register',k,h)
    def stop(self,c):
        self.event('stop',c,'Failed to init temp sensors')
        if self.p.get('stop_sets_state',True):self.change('chain_state',[c,3])
        return self.p.get('stop_rc',-9)
    def fault(self,k):return value(self.p,'faults',k,'none')
    def call(self,name,k):
        self.event(name,k)
        return -7 if self.fault(k)==name else 0
    def read(self,k,reg):
        self.event('read',k,reg);n=self.reads[k];self.reads[k]+=1
        f=self.fault(k);rc=-1 if f=='read' or f=='read2' and n%3<2 else 0
        raw=0 if f=='id' else value(self.p,'raw',k,89)
        return rc,raw
    def write(self,k,reg,v):
        self.event('write',k,reg,v);return -5 if self.fault(k)=='write'+str(reg) else 0
    def now(self):
        n=self.time;self.time+=1;v=100.0+n*0.125;self.event('now',v);return v
    def delay(self,v):self.event('delay',v);return -6

class SemanticMismatch(AssertionError): pass

class Native:
    def __init__(self,lib):
        self.f=lib.vn135_temperature_start_composition_135;self.f.argtypes=[C.POINTER(View),C.POINTER(Ops),P];self.f.restype=I
    def run(self,p):
        count,types,roles,initial_banks=initial(p)
        hp=dict(p);hp.pop("faults",None)
        s,keep=H.setup(hp);g,model,_,chains,banks,*_=keep
        model.sensor_count=count
        for ci in range(NC):
            chains[ci].thermal.sensor_count=99
            for si in range(N):banks[ci][si]=initial_banks[ci][si]
        ts=(U*N)(*types);rs=(U*N)(*roles);description=Description(0,0,count,ts,0,0)
        view=View(C.pointer(s),C.pointer(description),rs);sc=Script(p);errors=[];callbacks=[];cookie=U(0xa11cafe)
        def snap():
            return (g.mode,g.suppress_thermal,model.sensor_count,model.query_fault_87,s.partial_chains_105,s.minimum_chains_f8,
                tuple(ts),tuple(rs),tuple((c.thermal.index,c.thermal.state,c.thermal.present) for c in chains),
                tuple(tuple(T.snapshot(x) for x in ar) for ar in banks))
        def change(k,v):
            if k=='count':model.sensor_count=v;description.table_count=v
            elif k=='type':ts[v[0]]=v[1]
            elif k=='role':rs[v[0]]=v[1]
            elif k=='suppress':g.suppress_thermal=v
            elif k=='mode':g.mode=v
            elif k=='chain_state':chains[v[0]].thermal.state=v[1]
            elif k=='present':chains[v[0]].thermal.present=v[1]
            elif k=='sensor_state':banks[v[0]][v[1]].state=v[2]
            else:raise AssertionError(k)
        sc.snap=snap;sc.change=change
        def cb(typ,fn):
            def guard(*args):
                try:
                    if args[0]!=C.addressof(cookie):raise AssertionError('callback context not forwarded')
                    return fn(*args)
                except BaseException as ex:errors.append(ex);return 0.0 if typ==T.NOW else 0
            f=typ(guard);callbacks.append(f);return f
        def loc(ptr):
            addr=C.addressof(ptr.contents)
            for ci,bank in enumerate(banks):
                d=addr-C.addressof(bank)
                if 0<=d<C.sizeof(bank) and d%C.sizeof(T.Sensor)==0:return ci*N+d//C.sizeof(T.Sensor)
            raise AssertionError('bad sensor')
        def chainloc(ptr):
            return next(ci for ci in range(NC) if C.addressof(ptr.contents)==C.addressof(chains[ci].thermal))
        def scalar(_,entry,a,b):
            assert entry==0xfe668 and a==b==0
            return sc.count()
        def hlog(_,line,level,a,b,detail):
            assert detail is None
            sc.event('outer_log',line,level,a,b)
        h=H.Ops();h.call=cb(H.CALL,scalar)
        if not p.get('no_log'):h.log=cb(H.LOG,hlog)
        def read(_,sp,reg,out):
            rc,raw=sc.read(loc(sp),reg);out[0]=raw;return rc
        t=T.Ops();t.now=cb(T.NOW,lambda _:sc.now());t.configure_reading=cb(T.MUT,lambda _,sp:sc.call('configure',loc(sp)))
        t.read_register=cb(T.RD,read);t.write_register=cb(T.WR,lambda _,sp,r,v:sc.write(loc(sp),r,v));t.finish_configuration=cb(T.MUT,lambda _,sp:sc.call('finish',loc(sp)))
        t.delay_ms=cb(T.DELAY,lambda _,v:sc.delay(v))
        if not p.get('no_log'):t.log=cb(T.LOG,lambda _,l,c,i,v:sc.event('inner_log',l,c,i,v))
        def stop(_,cp,reason):assert reason==b'Failed to init temp sensors';return sc.stop(chainloc(cp))
        def reg(_,k,gp,h):assert C.addressof(gp.contents)==C.addressof(g) and h==0x78aa4;sc.register(k,h)
        o=Ops(C.pointer(h),C.pointer(t),cb(STOPCB,stop),cb(KEYCB,lambda _:sc.key()),cb(REGCB,reg))
        rc=[self.f(C.byref(view),C.byref(o),C.byref(cookie)) for _ in range(p.get('laps',1))]
        if errors:raise SemanticMismatch(str(errors[0]))
        return rc,sc.events,snap()

class Machine(T.ThermalArm):
    def extra_instruction(self,w,pc):
        self.visited.add(pc)
        if pc in ENTRIES:self.entries[pc]+=1
        if any(a<=pc<b for a,b in RECOVERED):return ARM32Difficulty.extra_instruction(self,w,pc)
        return super().extra_instruction(w,pc)
    def write(self,a,v,n=4):
        if getattr(self,'watch',False) and not self.effect:
            stack=self.STACK_BASE<=a and a+n<=self.STACK_TOP+0x1000
            if not stack and not any(lo<=a and a+n<=hi for lo,hi in self.sensor_fields):
                raise AssertionError(('unexpected source write',hex(a),n))
        super().write(a,v,n)

class Original:
    def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set();self.entries=collections.Counter()
    def run(self,p):
        count,types,roles,banks=initial(p);m=self.m;m.watch=False;m.effect=True
        m.mem[BASE:BASE+0x10000]=bytes(0x10000);m.visited=set();m.entries=collections.Counter()
        def sa(ci,si):return SENSORS+ci*0x300+si*128
        def ca(ci):return CHAINS+ci*800
        for a,v in [(BASE+0x18,MODEL),(MODEL+0x58,GROUP),(GROUP,TABLE),(GROUP+0x18,count),(BASE+0x230,CHAINS),(BASE+0x19c,KEY),(BASE+0x50,p.get('mode',0)),(BASE+0xf8,p.get('minimum_chains_f8',2))]:m.write(a,v)
        for a,v in [(BASE+0xf6,p.get('suppress_thermal',0)),(BASE+0x105,p.get('partial_chains_105',0)),(MODEL+0x87,p.get('query_fault_87',0))]:m.write(a,v,1)
        for si in range(N):m.write(TABLE+28*si,types[si]);m.write(TABLE+28*si+4,roles[si])
        for off,addr in [(0x1d0,0x850000),(0x1d4,0x850010),(0x1d8,0x850020),(0x1dc,0x850030)]:m.write(BASE+off,addr)
        for ci in range(NC):
            for off,v in [(0x18,value(p,'indices',ci,ci+10)),(0x20,value(p,'chain_states',ci,2)),(0x1c,BASE),(0x290,sa(ci,0)),(0x2b4,0x849000)]:m.write(ca(ci)+off,v)
            m.write(ca(ci)+0x24,value(p,'present',ci,1),1)
            for si in range(N):T.put_sensor(m,banks[ci][si],sa(ci,si))
        m.sensor_fields=[(sa(ci,si)+off,sa(ci,si)+off+size) for ci in range(NC) for si in range(N) for off,size in T.OFF.values()]
        sc=Script(p)
        def snap():
            return (m.read(BASE+0x50),m.read(BASE+0xf6,1),signed(m.read(GROUP+0x18)),m.read(MODEL+0x87,1),m.read(BASE+0x105,1),signed(m.read(BASE+0xf8)),
                tuple(m.read(TABLE+28*i) for i in range(N)),tuple(m.read(TABLE+28*i+4) for i in range(N)),
                tuple((m.read(ca(ci)+0x18),m.read(ca(ci)+0x20),m.read(ca(ci)+0x24,1)) for ci in range(NC)),
                tuple(tuple(T.snapshot(T.get_sensor(m,sa(ci,si))) for si in range(N)) for ci in range(NC)))
        def change(k,v):
            if k=='count':m.write(GROUP+0x18,v)
            elif k=='type':m.write(TABLE+28*v[0],v[1])
            elif k=='role':m.write(TABLE+28*v[0]+4,v[1])
            elif k=='suppress':m.write(BASE+0xf6,v,1)
            elif k=='mode':m.write(BASE+0x50,v)
            elif k=='chain_state':m.write(ca(v[0])+0x20,v[1])
            elif k=='present':m.write(ca(v[0])+0x24,v[1],1)
            elif k=='sensor_state':m.write(sa(v[0],v[1])+0x2c,v[2])
            else:raise AssertionError(k)
        sc.snap=snap;sc.change=change
        def sloc(addr):
            for ci in range(NC):
                d=addr-sa(ci,0)
                if 0<=d<N*128 and d%128==0:return ci*N+d//128
            raise AssertionError(('bad sensor',hex(addr)))
        def effect(fn):
            def hook(_):
                m.effect=True
                try:m.r[0]=int(fn() or 0)&0xffffffff
                finally:m.effect=False
            return hook
        def read():
            rc,raw=sc.read(sloc(m.r[1]-0x1c),m.r[3]);m.write(m.read(m.r[13]),raw,1);return rc
        def stop():
            assert m.r[1]==0x5e689b
            ci=(m.r[0]-CHAINS)//800;assert 0<=ci<NC and m.r[0]==ca(ci)
            return sc.stop(ci)
        def reg():
            assert m.r[2]==BASE and m.r[3]==0x78aa4
            out=m.r[0];sc.register(m.r[1],m.r[3]);m.write(out,0xaaa);m.write(out+4,0xbbb)
        def log():
            if p.get('no_log'):return
            sp=m.r[13];line=m.r[3]
            if line in (1208,1811,445,451):
                a=m.read(sp+8) if line!=445 else 0;b=m.read(sp+12) if line in (1208,451) else 0
                sc.event('outer_log',line,m.read(sp),a,b)
            else:sc.event('inner_log',line,m.read(sp+8),m.read(sp+12),m.read(sp+16) if line==83 else 0)
        def now():m.set_d(0,sc.now())
        hooks={0xfe668:effect(sc.count),KEY:effect(sc.key),0x108b40:effect(reg),0x56d18:effect(stop),0xfa0c4:effect(log),
               0x850000:effect(lambda:sc.call('configure',sloc(m.r[1]-0x1c))),0x850010:effect(read),
               0x850020:effect(lambda:sc.write(sloc(m.r[1]-0x1c),m.r[3],m.read(m.r[13])&255)),
               0x850030:effect(lambda:sc.call('finish',sloc(m.r[1]-0x1c))),0x1ed58:effect(now),0x10ef3c:effect(lambda:sc.delay(m.r[0]))}
        result=[]
        for _ in range(p.get('laps',1)):
            m.watch=False;m.reset((BASE,));m.watch=True;m.effect=False
            result.append(signed(m.run(0x6ec4c,hooks=hooks,max_steps=120000)));self.steps+=m.steps
        m.watch=False;self.visited.update(m.visited);self.entries.update(m.entries)
        return result,sc.events,snap()

def witnesses():
    yield 'healthy',{}
    yield 'critical_sensor_fail',{'faults':'configure'}
    yield 'noncritical_all_fail',{'types':[1,2],'roles':[0,0],'faults':'configure'}
    yield 'no_descriptors_no_chain',{'types':[],'roles':[],'counts':0}
    yield 'mode_not_truncated',{'roles':[0,0],'mode':258,'faults':'configure'}
    yield 'mode_2',{'roles':[0,0],'mode':2,'faults':'configure'}
    yield 'partial_accepted',{'faults':['configure','none','none','none'],'partial_chains_105':1,'minimum_chains_f8':1}
    yield 'suppressed_no_sensor',{'faults':'read','suppress_thermal':1}
    yield 'registration_late_failure',{'minimum_chains_f8':4}
    yield 'role_after_registration',{'mutations':[('register',0,'sensor_state',[0,1,3]),('register',0,'sensor_state',[1,1,3]),('register',0,'sensor_state',[2,1,3])]}
    yield 'post_log_suppression',{'faults':'configure','mutations':[('outer_log',1,'suppress',1)]}
    yield 'fresh_final_count',{'counts':[3,3,3,3,3,0]}
    yield 'post_registration_count',{'mutations':[('register',0,'count',0)]}
    yield 'full_key',{'key':0xffffffff}
    yield 'skip_types',{'types':[0,3,4,2],'roles':[0,0,0,2],'skip':0}
    yield 'kinds_and_roles',{'types':[1,2],'kinds':4,'sensor_roles':2}
    yield 'two_runs',{'laps':2}

def cases():
    yield from witnesses()
    for f,k,role,mode,suppress in itertools.product(('none','configure','read','read2','id','write9','write17','finish'),(1,2),(0,2),(0,2),(0,1)):
        yield 'all_faults',dict(types=[k],roles=[role],faults=f,mode=mode,suppress_thermal=suppress)
    for states,present in itertools.product(((2,2,2),(2,3,2),(3,4,5),(0,6,0xffffffff)),((1,1,1),(0,0,0),(0,1,1))):
        for flag,partial in itertools.product((0,1),(0,1)):
            yield 'chain_decisions',dict(chain_states=list(states),present=list(present),query_fault_87=flag,partial_chains_105=partial,minimum_chains_f8=1)
    for sensors in (-1,0,1,4):
        for count in (-1,0,1,3):yield 'counts',dict(sensors=sensors,types=[1,2,1,2],roles=[0,2,0,2],counts=count)
    for raw in (0,26,85,89,255):
        for remote in (0,1,255):yield 'device_ids',dict(raw=raw,remote=remote)
    for f in ('configure','read','id','write17','finish'):
        for i in range(12):
            fs=['none']*12;fs[i]=f
            yield 'one_failure',dict(types=[1,2,1,2],roles=[0,2,0,2],faults=fs,partial_chains_105=1,minimum_chains_f8=1)
    for logging in (True,False):
        for laps in (1,2):yield 'repeat_fault',dict(no_log=not logging,laps=laps,faults='read',suppress_thermal=1)
    rng=random.Random(0xa11)
    for _ in range(80):
        n=rng.randrange(5);ts=[rng.randrange(5) for _ in range(n)];rs=[rng.randrange(3) for _ in range(n)]
        yield 'mixed',dict(types=ts,roles=rs,mode=rng.choice([0,1,2,258]),counts=rng.randrange(4),faults=[rng.choice(['none','configure','read','id','write17']) for _ in range(12)],suppress_thermal=rng.randrange(2),partial_chains_105=rng.randrange(2),minimum_chains_f8=rng.randrange(4))

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    if hashlib.sha256(elf.data).hexdigest()!=T.ELF_HASH:raise ValueError('reference mismatch')
    original=Original(elf);native=Native(C.CDLL(str(Path(a.library).resolve())));counts=collections.Counter();outcomes=collections.Counter();events=0
    for i,(name,p) in enumerate(witnesses() if a.quick else cases()):
        ar=original.run(p)
        try:cr=native.run(p)
        except SemanticMismatch as ex:
            print('SEMANTIC_MISMATCH callback contract',i,name,str(ex),file=sys.stderr);return 1
        if ar!=cr:
            print('SEMANTIC_MISMATCH',i,name,json.dumps(p),file=sys.stderr)
            print('RESULT',ar[0],cr[0],file=sys.stderr)
            for j,(x,y) in enumerate(itertools.zip_longest(ar[1],cr[1])):
                if x!=y:print('EVENT',j,x,y,file=sys.stderr);break
            if ar[2]!=cr[2]:print('FINAL',ar[2],cr[2],file=sys.stderr)
            return 1
        counts[name]+=1;events+=len(ar[1]);outcomes[str(ar[0])]+=1
    report=dict(status='PASS',scenarios=sum(counts.values()),categories=dict(counts),outcomes=dict(outcomes),events=events,original_steps=original.steps,instruction_addresses=len(original.visited),original_entries={hex(k):v for k,v in original.entries.items()},real_io=False)
    print('TEMPERATURE_START_COMPOSITION135_ORIGINAL_PASS',json.dumps(report,sort_keys=True))
    if a.summary:Path(a.summary).write_text(json.dumps(report,indent=2)+'\n')
    return 0
if __name__=='__main__':sys.exit(main())
