#!/usr/bin/env python3
"""A-03: reuse 58d08/b71a8; compare unchanged ARM and nested shutdown callers.
Only source edge 5a60b8 (historically named mutex_init) and the OLD outer fixture's other boundaries are scripted.
No new opcodes, no original executable launched, no live mutex/thread/sensor I/O.
"""
import argparse
import ctypes as C
import hashlib
import itertools
import json
import random
import struct
from pathlib import Path
import test_thermal_sensors_135 as T
import test_general_monitor_135 as G
import test_exit_cleanup_135 as E
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
from elf32 import ELF32
ROOT=T.ROOT
ENTRY, END=0x58d08,0x58de8
RANGES=((ENTRY,END),(0xb71a8,0xb71e4),(0xa720c,0xa7218))
N,M=3,5
BASE,MODEL,CHAINS=E.BASE,E.MODEL,E.CHAINS
SENSORS,CONFIG=0x848000,0x84a000
P,U,I=C.c_void_p,C.c_uint32,C.c_int32
class Binding(C.Structure):
    _fields_=[('general',C.POINTER(G.State)),('capacity',C.c_size_t),
              ('temperature',C.POINTER(T.Ops)),('context',P)]
def address(c,b,i=0):return SENSORS+((c*2+b)*M+i)*128
def original_identity(a):
    q,r=divmod(a-SENSORS,128)
    assert r==0 and 0<=q<N*2*M,hex(a)
    c,q=divmod(q,2*M);b,i=divmod(q,M)
    return c,b,i

def initial(p,c,b,i):
    # Distinct persistent and cleared fields, including signed/sentinel states.
    states=p.get('states',[0,1,2,3,0xffffffff])
    return T.template(index=41+i,address=72+i,state=states[i],access_kind=i,
                      sample=50+c*7+i,corrected=-50-i,local_offset=-10-c,
                      remote_offset=13+i,failures=99+i,extended=255,
                      has_previous=255,sampled_at=100.25+c+i+b,
                      started_at=-12.5-i,previous_sample=-999,previous_corrected=300)

def presence(p,c):return p.get('presence',[1,255,0])[c]

class View:
    def __init__(self,p):
        self.general=G.State();self.model=G.Model();self.model.sensor_count=p.get('count',M)
        self.chains=(G.GChain*N)();self.general.model=C.pointer(self.model);self.general.chains=self.chains
        self.arrays=[[(T.Sensor*M)(*[initial(p,c,b,i) for i in range(M)]) for b in range(2)] for c in range(N)]
        for c in range(N):
            x=self.chains[c].thermal;x.present=presence(p,c);x.state=p.get('chain_state',4)
            x.index=100+c;x.sensor_count=p.get('local_count',1);x.chip_count=13
            x.sensors=None if p.get('null_sensors') else self.arrays[c][0]
    def identity(self,ptr):
        a=C.cast(ptr,P).value
        if a is None:return None
        for c,b in itertools.product(range(N),range(2)):
            q,r=divmod(a-C.addressof(self.arrays[c][b]),C.sizeof(T.Sensor))
            if r==0 and 0<=q<M:return c,b,q
        raise AssertionError(('unknown host sensor',a))
    def snapshot(self):
        return (self.model.sensor_count,tuple((x.thermal.present,x.thermal.state,x.thermal.sensor_count,
                 self.identity(x.thermal.sensors)) for x in self.chains),
                tuple(T.snapshot(s) for banks in self.arrays for bank in banks for s in bank))
    def mutate(self,field,value):
        if field=='count':self.model.sensor_count=value
        elif field=='bank':c,b=value;self.chains[c].thermal.sensors=self.arrays[c][b]
        elif field=='present':c,v=value;self.chains[c].thermal.present=v
        elif field=='sensor':c,b,i,name,v=value;setattr(self.arrays[c][b][i],name,v)
        else:raise AssertionError(field)

class ArmView:
    def __init__(self,m,p,parent=False):
        self.m=m
        if not parent:m.write(BASE+0x18,MODEL);m.write(BASE+0x230,CHAINS)
        m.write(MODEL+0x58,CONFIG);m.write(CONFIG+0x18,p.get('count',M))
        for c in range(N):
            a=CHAINS+800*c
            m.write(a+0x1c,BASE);m.write(a+0x18,100+c)
            m.write(a+0x24,presence(p,c),1);m.write(a+0x20,p.get('chain_state',4))
            m.write(a+0x290,0 if p.get('null_sensors') else address(c,0))
            # No field for route.sensor_count here: the source uses the model.
            for b,i in itertools.product(range(2),range(M)):T.put_sensor(m,initial(p,c,b,i),address(c,b,i))
        self.local_count=p.get('local_count',1)
        for literal,pc in ((0x58de8,0x58d40),(0x58dec,0x58d64)):
            slot=pc+8+m.read(literal);target=m.read(slot)
            m.write(target,p.get('opaque',0xffffffff))
        self.before=[bytes(m.mem[address(c,b,i):address(c,b,i)+128]) for c,b,i in itertools.product(range(N),range(2),range(M))]
    def snapshot(self):
        m=self.m
        return (signed(m.read(CONFIG+0x18)),tuple((m.read(CHAINS+c*800+0x24,1),m.read(CHAINS+c*800+0x20),self.local_count,
                 original_identity(m.read(CHAINS+c*800+0x290)) if m.read(CHAINS+c*800+0x290) else None) for c in range(N)),
                tuple(T.snapshot(T.get_sensor(m,address(c,b,i))) for c,b,i in itertools.product(range(N),range(2),range(M))))
    def mutate(self,field,value):
        m=self.m
        if field=='count':m.write(CONFIG+0x18,value)
        elif field=='bank':c,b=value;m.write(CHAINS+c*800+0x290,address(c,b))
        elif field=='present':c,v=value;m.write(CHAINS+c*800+0x24,v,1)
        elif field=='sensor':
            c,b,i,name,v=value;s=T.get_sensor(m,address(c,b,i));setattr(s,name,v)
            off,n=T.OFF[name]
            word=int.from_bytes(struct.pack('<d',getattr(s,name)),'little') if n==8 else getattr(s,name)
            m.write(address(c,b,i)+off,word,n)
        else:raise AssertionError(field)
    def guards(self):
        known={j for off,n in T.OFF.values() for j in range(off,off+n)}
        for old,(c,b,i) in zip(self.before,itertools.product(range(N),range(2),range(M))):
            now=self.m.mem[address(c,b,i):address(c,b,i)+128]
            assert all(now[j]==old[j] for j in range(128) if j not in known),'unmodeled sensor write'

class Script:
    def __init__(self,view,p,parent=lambda:()):self.view=view;self.p=p;self.events=[];self.calls=0;self.parent=parent
    def event(self,name,*args):self.events.append((name,*args,self.view.snapshot(),self.parent()))
    def mutex(self,identity):
        self.event('sync_5a60b8',*identity);n=self.calls;self.calls+=1
        for at,field,value in self.p.get('mutations',[]):
            if at==n:self.view.mutate(field,value)
        values=self.p.get('mutex_rc',[-22,0,1])
        return values[n%len(values)]

def native_ops(view,sc):
    errors=[]
    def cb(_,s):
        try:return sc.mutex(view.identity(s))
        except BaseException as exc:errors.append(exc);return -1
    keep=T.MUT(cb);ops=T.Ops();ops.mutex_init=keep
    return ops,keep,errors

class Machine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES),('unexpected instruction',hex(pc))
        self.visited.add(pc);return super().extra_instruction(w,pc)

class Original:
    def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,p):
        m=self.m;m.mem[BASE:BASE+0x10000]=bytes(0x10000);view=ArmView(m,p);sc=Script(view,p)
        def mutex(_):
            assert m.r[14]==0xb71b8;m.r[0]=sc.mutex(original_identity(m.r[0]))&0xffffffff
        for c in p.get('indices',[0]):
            sc.event('enter',c);m.reset((CHAINS+c*800,));m.visited=set()
            m.run(ENTRY,hooks={0x5a60b8:mutex},max_steps=10000)
            assert m.r[13]==m.STACK_TOP
            self.steps+=m.steps;self.visited|=m.visited
        view.guards();return view.snapshot(),sc.events
class Native:
    def __init__(self,lib,legacy=False):
        self.legacy=legacy
        self.raw=lib.vn135_temperature_chain_cleanup_135
        self.raw.argtypes=[C.POINTER(G.Chain),I,C.POINTER(T.Ops),P];self.raw.restype=None
        self.f=lib.vn135_sensor_cleanup_step_135;self.f.argtypes=[C.POINTER(Binding),U,U];self.f.restype=I
    def run(self,p):
        v=View(p);sc=Script(v,p);ops,keep,errors=native_ops(v,sc)
        binding=Binding(C.pointer(v.general),N,C.pointer(ops),None)
        for c in p.get('indices',[0]):
            sc.event('enter',c)
            if self.legacy:self.raw(C.byref(v.chains[c].thermal),v.model.sensor_count,C.byref(ops),None)
            else:assert self.f(C.byref(binding),ENTRY,c)==1,'valid binding not handled'
        if errors:raise errors[0]
        return v.snapshot(),sc.events

class NestedMachine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in RANGES+E.RANGES),hex(pc)
        self.visited.add(pc)
        if pc==ENTRY:
            regs=self.r.copy();self.observer(self);self.r[:]=regs
            self.script.event('enter',(self.r[0]-CHAINS)//800)
        return super().extra_instruction(w,pc)
    def run(self,entry,hooks,max_steps):
        self.observer=hooks[ENTRY];hooks=dict(hooks);del hooks[ENTRY]
        self.view=ArmView(self,self.parameters,parent=True)
        self.script=Script(self.view,self.parameters,lambda:(self.read(BASE+0x20),self.read(BASE+0xff1,1)))
        def mutex(_):
            assert self.r[14]==0xb71b8
            self.r[0]=self.script.mutex(original_identity(self.r[0]))&0xffffffff
        hooks[0x5a60b8]=mutex
        return super().run(entry,hooks=hooks,max_steps=max_steps)
class NestedOriginal:
    def __init__(self,elf):self.base=E.Original(elf);self.base.m=NestedMachine(elf)
    def run(self,entry,p,params):
        m=self.base.m;m.parameters=params
        out=self.base.run(entry,p);m.view.guards()
        return out,m.view.snapshot(),m.script.events
class NestedNative:
    def __init__(self,lib):self.lib=lib
    def run(self,entry,p,params):
        base=E.Native(self.lib);f=Native(self.lib).f;v=View(params);events=[];errors=[]
        def wrap(original):
            def call(ps,po,power,opaque,scratch):
                s=C.cast(ps,C.POINTER(E.S.State)).contents;old=C.cast(po,C.POINTER(E.S.Ops)).contents
                ops=E.S.Ops.from_buffer_copy(old)
                sc=Script(v,params,lambda:(s.state,s.power.byte_ff1));sc.events=events
                temperature,keep,errs=native_ops(v,sc)
                binding=Binding(C.pointer(v.general),N,C.pointer(temperature),None)
                def step(ctx,source,index):
                    try:
                        result=old.step(ctx,source,index)
                        if source==ENTRY:
                            sc.event('enter',index)
                            assert f(C.byref(binding),source,index)==1
                        return result
                    except BaseException as exc:errors.append(exc);return 0
                cb=E.S.STEP(step);ops.step=cb
                original(ps,C.byref(ops),power,opaque,scratch);errors.extend(errs)
            return call
        base.before=wrap(base.before);base.common=wrap(base.common)
        out=base.run(entry,p)
        if errors:raise errors[0]
        return out,v.snapshot(),events

def cases(quick=False):
    yield {'indices':[0,1,2]}
    yield {'presence':[0,0,0],'count':0x7fffffff,'null_sensors':1}
    yield {'count':-2147483648,'null_sensors':1}
    yield {'count':0,'null_sensors':1}
    yield {'count':1,'states':[0xffffffff]*M,'local_count':5}
    yield {'count':4,'states':[1]*M,'mutations':[(0,'count',1)],'indices':[0,1]}
    yield {'count':4,'states':[1]*M,'mutations':[(0,'present',(0,0))]}
    if quick:return
    for present,state,count in itertools.product((0,1,255),(0,1,3,4,0xffffffff),(-1,0,1,3,5)):
        yield {'presence':[present]*N,'chain_state':state,'count':count,'indices':[0,1,2]}
    for state,kind in itertools.product((0,1,2,3,4,0x80000000,0xffffffff),range(M)):
        states=[0]*M;states[kind]=state;yield {'states':states,'indices':[0,0,1]}
    for mask in range(1<<M):yield {'states':[(mask>>i)&1 for i in range(M)],'indices':[0,1,2,0]}
    for v in (-2147483648,-1,0,1,5,2147483647):yield {'local_count':v,'indices':[0,1]}
    for rc in (-2147483648,-22,-1,0,1,2147483647):yield {'mutex_rc':[rc]}
    for field,v in [('count',0),('count',M),('bank',(0,1)),('present',(0,0)),
                    ('sensor',(0,0,1,'state',1)),('sensor',(0,0,2,'state',0)),
                    ('sensor',(0,0,0,'sampled_at',-25.5)),('sensor',(0,0,0,'sample',1234))]:
        yield {'states':[1]*M,'mutations':[(0,field,v)],'indices':[0,1]}
    rng=random.Random(5808)
    for _ in range(80):
        yield {'count':rng.randrange(-1,M+1),'presence':[rng.choice([0,1,255]) for _ in range(N)],
               'states':[rng.choice([0,1,2,3,0xffffffff]) for _ in range(M)],'opaque':rng.getrandbits(32),'indices':[0,2,1,0]}

def nested_cases(quick=False):
    for entry,p in [('before',{}),('common',{}),('policy',{'limit':1}),('policy',{'limit':0})]:
        yield entry,p,{}
    if quick:return
    for entry,count,present in itertools.product(('before','common'),(-1,0,1,3,5),(0,1,255)):
        yield entry,{'flags':[0]*10}, {'count':count,'presence':[present]*N}
    for entry,count in itertools.product(('before','common'),([0],[-1],[1],[2],[3],[3,1,2])):
        yield entry,{'flags':[0]*10,'returns':{'count':count}},{}
    for entry,state,ready in itertools.product(('before','common'),(0,2,4,6),(0,1)):
        yield entry,{'state':state,'returns':{'ready':ready}},{}
    for limit in (0,1,-1):
        for at in (0,3):
            yield 'policy',{'limit':limit},{'states':[1]*M,'mutations':[(at,'count',1)]}


def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');args=ap.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==T.ELF_HASH
    lib=C.CDLL(str(Path(args.library).resolve()));a=Original(elf);b=Native(lib);legacy=Native(lib,legacy=True)
    direct=events=0
    for p in cases(args.quick):
        want=a.run(p);got=b.run(p)
        assert got==want,('SENSOR_CLEANUP_ORIGINAL_MISMATCH','binding',p,want,got)
        raw=legacy.run(p)
        assert raw==want,('SENSOR_CLEANUP_ORIGINAL_MISMATCH','existing helper',p,want,raw)
        direct+=1;events+=len(want[1])
    na=NestedOriginal(elf);nb=NestedNative(lib);nested=outer=inner=0
    for entry,p,params in nested_cases(args.quick):
        want=na.run(entry,p,params);got=nb.run(entry,p,params)
        assert got==want,('SENSOR_CLEANUP_NESTED_MISMATCH',entry,p,params,want,got)
        nested+=1;outer+=len(want[0][2]);inner+=len(want[2])
    summary=dict(direct_cases=direct,legacy_reuse_comparisons=direct,direct_events=events,nested_cases=nested,parent_events=outer,sensor_events=inner,
                 direct_steps=a.steps,nested_steps=na.base.steps,original_cleanup_and_reset=True,unchanged_legacy=True,
                 real_mutex=False,hardware=False)
    if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('SENSOR_CLEANUP_BINDING135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
