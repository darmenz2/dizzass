#!/usr/bin/env python3
"""Unmodified A32 predicate and whole-monitor compositions; no device/process I/O."""
import argparse
import ctypes as C
import hashlib
import itertools
import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
from arm32_difficulty_subset import ARM32Difficulty
import test_general_monitor_135 as gm
from test_thermal_sensors_135 import Sensor, template, put_sensor, snapshot

ENTRY = 0x78eb8
RANGES = ((ENTRY, 0x790b4), (0xa720c, 0xa7218), (0x56fcc, 0x57028))
REF = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
BK, MD, GROUP, CHAINS, SENSORS = 0x840000, 0x841000, 0x841400, 0x842000, 0x844000
COUNT = C.CFUNCTYPE(C.c_int32, C.c_void_p)

def require(ok, detail):
    if not ok:
        raise ValueError(detail)

class Mismatch(AssertionError):
    pass

class Scene:
    def __init__(self, p):
        self.p = p
        self.models = [gm.Model(0, 0, 88, p.get('sensors', 4), 0), gm.Model(0, 0, 88, 1, 0)]
        self.banks = [(gm.GChain * 3)(), (gm.GChain * 3)()]
        self.sensors = [[(Sensor * 4)() for _ in range(3)] for _ in range(2)]
        self.g = gm.State()
        self.model_index = self.bank_index = 0
        self.g.model = C.pointer(self.models[0])
        self.g.chains = self.banks[0]
        for b, bank in enumerate(self.banks):
            for i, c in enumerate(bank):
                c.thermal.index = 100 + 10 * b + i
                c.thermal.state = p.get('state', 2)
                c.thermal.present = p.get('present', 1)
                c.thermal.sensor_count = p.get('cached_count', 0)
                c.thermal.sensors = self.sensors[b][i]
                c.fault_3c = 0x55aa
                c.detected_8c = 88
                for j in range(4):
                    self.sensors[b][i][j] = template(index=j+100, access_kind=2, role=2, state=3,
                        sample=-45, corrected=4567, sampled_at=-1000, failures=99)
        for b, i, j, field, value in p.get('set_sensor', []):
            setattr(self.sensors[b][i][j], field, value)
        for b, i, field, value in p.get('set_chain', []):
            setattr(self.banks[b][i].thermal, field, value)
        for b, i in p.get('null_sensors', []):
            self.banks[b][i].thermal.sensors = C.POINTER(Sensor)()
        if p.get('null_chains'):
            self.g.chains = C.POINTER(gm.GChain)()
            self.bank_index = -1

    def change(self):
        q = self.p.get('change', {})
        if 'model_count' in q:
            i, n = q['model_count']; self.models[i].sensor_count = n
        if 'model' in q:
            self.model_index = q['model']; self.g.model = C.pointer(self.models[self.model_index])
        if 'bank' in q:
            self.bank_index = q['bank']; self.g.chains = self.banks[self.bank_index]
        for b, i, j, k, v in q.get('sensor', []):
            setattr(self.sensors[b][i][j], k, v)
        for b, i, k, v in q.get('chain', []):
            setattr(self.banks[b][i].thermal, k, v)

    def snap(self):
        return (tuple(m.sensor_count for m in self.models), self.model_index, self.bank_index,
            tuple(tuple((c.thermal.index, c.thermal.state, c.thermal.present, c.thermal.sensor_count,
                         bool(c.thermal.sensors), tuple(snapshot(s) for s in self.sensors[b][i]))
                        for i, c in enumerate(bank)) for b, bank in enumerate(self.banks)))

    def raw(self):
        return tuple(bytes(x) for x in [self.g, *self.models, *self.banks,
                     *(a for bank in self.sensors for a in bank)])

class DirectMachine(ARM32):
    def extra_instruction(self, word, pc):
        require(any(a <= pc < b for a, b in RANGES), 'unapproved instruction '+hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(word, pc)

class Original:
    def __init__(self, elf):
        self.m = DirectMachine(elf)
        self.steps = 0
        self.visited = set()

    def run(self, p):
        s = Scene(p); m = self.m
        m.reset((BK,)); m.visited = set()
        m.mem[BK:BK+0x10000] = b'\xa5'*0x10000
        def sync():
            m.write(BK+0x18, MD+s.model_index*0x100)
            m.write(BK+0x230, 0 if s.bank_index < 0 else CHAINS+s.bank_index*0x1000)
            for b in range(2):
                m.write(MD+b*0x100+0x58, GROUP+b*0x100)
                m.write(GROUP+b*0x100+0x18, s.models[b].sensor_count)
                for i, c in enumerate(s.banks[b]):
                    a = CHAINS+b*0x1000+i*800
                    m.write(a+0x18, c.thermal.index); m.write(a+0x20, c.thermal.state)
                    m.write(a+0x24, c.thermal.present, 1)
                    m.write(a+0x290, SENSORS+b*0x1000+i*0x200 if c.thermal.sensors else 0)
                    for j, x in enumerate(s.sensors[b][i]):
                        put_sensor(m, x, SENSORS+b*0x1000+i*0x200+j*128)
        sync()
        # Test real opaque arithmetic with arbitrary words; no patched instructions.
        for pc, literal, value in [(0x78eec,0x790b4,p.get('opaque',0)),
                                    (0x78f10,0x790b8,p.get('opaque2',11))]:
            slot=(pc+8+m.read(literal)) & 0xffffffff
            m.write(m.read(slot),value)
        expected = [bytes(m.mem[BK:BK+0x10000])]
        events = []
        def count(_):
            events.append(('count', s.snap()))
            s.change(); sync(); expected[0] = bytes(m.mem[BK:BK+0x10000])
            m.r[0] = p.get('chains',3) & 0xffffffff
        rc = m.run(ENTRY, hooks={0xfe668:count}, max_steps=20000)
        require(bytes(m.mem[BK:BK+0x10000]) == expected[0], 'original wrote input data')
        require(rc in (0,1), 'not boolean original result')
        self.steps += m.steps; self.visited |= m.visited
        return rc, s.snap(), events

class Native:
    def __init__(self, lib):
        self.fn = lib.vn135_backend_has_chip_sensor_135
        self.fn.argtypes = [C.POINTER(gm.State), COUNT, C.c_void_p]
        self.fn.restype = C.c_int32

    def run(self, p):
        s = Scene(p); events = []; errors = []; expected = [s.raw()]
        def count(_):
            try:
                events.append(('count',s.snap())); s.change(); expected[0]=s.raw()
                return p.get('chains',3)
            except BaseException as e:
                errors.append(e); return 0
        cb = COUNT(count)
        rc = self.fn(C.byref(s.g), cb, None)
        if errors: raise errors[0]
        require(s.raw()==expected[0], 'native wrote input data')
        return rc, s.snap(), events

def with_sensor(field, value, **more):
    return dict(set_sensor=[(0,0,0,'state',0),(0,0,0,field,value)], **more)

def witnesses():
    yield 'all_failed', {}
    yield 'state_zero_matches', with_sensor('state',0)
    yield 'state_two_matches', with_sensor('state',2)
    yield 'state_one_matches', with_sensor('state',1)
    yield 'kind_one_matches', with_sensor('access_kind',1)
    yield 'kind_zero_skipped', with_sensor('access_kind',0)
    yield 'kind_four_skipped', with_sensor('access_kind',4)
    yield 'wrong_role_skipped', with_sensor('role',1)
    yield 'full_kind_width', with_sensor('access_kind',257)
    yield 'full_role_width', with_sensor('role',258)
    yield 'absent', with_sensor('state',0,present=0)
    yield 'chain_state_3', with_sensor('state',0,state=3)
    yield 'chain_state_5', with_sensor('state',0,state=5)
    yield 'chain_state_zero_usable', with_sensor('state',0,state=0)
    yield 'negative_count', with_sensor('state',0,chains=-1)
    yield 'empty_sensor_count', with_sensor('state',0,sensors=0)
    yield 'last_chain_and_sensor', {'set_sensor':[(0,2,3,'state',2)]}
    yield 'sensor_count_captured', {'set_sensor':[(0,0,3,'state',2)],'change':{'model_count':[0,0]}}
    yield 'empty_count_captured', with_sensor('state',0,sensors=0,change={'model_count':[0,4]})
    yield 'chain_bank_after_count', {'set_sensor':[(1,2,3,'state',0)],'change':{'bank':1,'model':1}}

def cases():
    yield from witnesses()
    for kind,role,state in itertools.product((0,1,2,3,4,0xffffffff),(0,1,2,3,0xffffffff),(0,1,2,3,4,5,0xffffffff)):
        yield 'sensor_fields', {'set_sensor':[(0,0,0,'access_kind',kind),(0,0,0,'role',role),(0,0,0,'state',state)]}
    for state,present in itertools.product((0,1,2,3,4,5,6,7,0x80000000,0xffffffff),(0,1,2,255)):
        yield 'chain_predicate', with_sensor('state',0,state=state,present=present)
    for nc,ns in itertools.product((-2147483648,-1,0,1,2,3),(-2147483648,-1,0,1,2,3,4)):
        yield 'counts', dict(chains=nc,sensors=ns,set_sensor=[(0,2,3,'state',0)])
    for i,j in itertools.product(range(3),range(4)):
        yield 'match_position', {'set_sensor':[(0,i,j,'state',0)]}
    yield 'no_chains_array', {'chains':0,'null_chains':True}
    yield 'no_sensor_array', {'sensors':0,'null_sensors':[(0,i) for i in range(3)]}
    yield 'no_active_arrays', {'present':0,'null_sensors':[(0,i) for i in range(3)]}
    for new_value in (0,1,2,3,4):
        yield 'live_sensor', {'change':{'sensor':[(0,1,1,'state',new_value)]}}
        yield 'live_chain', with_sensor('state',0,change={'chain':[(0,0,'state',new_value)]})
    for value in (0,1,2,7,0x7fffffff,0x80000000,0xffffffff):
        yield 'opaque', dict(opaque=value,opaque2=0xffffffff,**with_sensor('state',0))
    rng = random.Random(0x78eb8)
    for _ in range(250):
        p=dict(chains=rng.randrange(-1,4),sensors=rng.randrange(-1,5),
               opaque=rng.getrandbits(32),opaque2=rng.getrandbits(32),
               cached_count=rng.randrange(5),set_sensor=[],set_chain=[])
        for i in range(3):
            for key,vals in [('state',(0,2,3,4,5,6,0xffffffff)),('present',(0,1,255))]:
                p['set_chain'].append((0,i,key,rng.choice(vals)))
            for j in range(4):
                for key,vals in [('state',(0,1,2,3,4,0xffffffff)),('access_kind',(0,1,2,3,4,0xffffffff)),('role',(0,1,2,3))]:
                    p['set_sensor'].append((0,i,j,key,rng.choice(vals)))
        yield 'seeded',p

class ParentMachine(gm.Machine):
    def extra_instruction(self,w,pc):
        if ENTRY <= pc < 0x790b4:
            self.visited.add(pc)
            return ARM32Difficulty.extra_instruction(self,w,pc)
        return super().extra_instruction(w,pc)

class ParentOriginal(gm.Original):
    def __init__(self,elf):
        super().__init__(elf); self.m=ParentMachine(elf); self.reached=0
        original_run=self.m.run
        def run(start,stop=None,hooks=None,max_steps=250000):
            hooks=dict(hooks or {})
            if ENTRY in hooks:
                observer=hooks[ENTRY]
                def check(m):
                    self.reached+=1
                    backend,lr=m.r[0],m.r[14]
                    observer(m)  # Preserve the prior fixture's event, not its canned result.
                    m.r[0],m.r[14]=backend,lr
                    original_run(ENTRY,stop=lr,hooks={0xfe668:hooks[0xfe668]},max_steps=max_steps)
                    m.r[14]=lr
                hooks[ENTRY]=check
            return original_run(start,stop=stop,hooks=hooks,max_steps=max_steps)
        self.m.run=run

class ParentNative:
    def __init__(self,lib):
        self.reached=0; self.child=Native(lib)
        real=lib.vn135_general_monitor_135
        real.argtypes=[C.POINTER(gm.State),C.POINTER(gm.Ops),C.c_void_p,C.POINTER(gm.Scratch)]
        real.restype=None
        owner=self
        class Call:
            def __call__(self,g,op,ctx,scratch):
                old=C.cast(op,C.POINTER(gm.Ops)).contents; errors=[]
                count=COUNT(lambda p:old.call(p,gm.OP['count'],0,0))
                def call(p,entry,a,b):
                    try:
                        value=old.call(p,entry,a,b)
                        if entry==ENTRY:
                            owner.reached+=1
                            return owner.child.fn(g,count,p)
                        return value
                    except BaseException as e:
                        errors.append(e); return 0
                cb=gm.CALL(call)
                new=gm.Ops(cb,*[getattr(old,n) for n,_ in gm.Ops._fields_[1:]])
                real(g,C.byref(new),ctx,scratch)
                if errors:raise errors[0]
        class Proxy:pass
        proxy=Proxy(); proxy.vn135_general_monitor_135=Call()
        self.parent=gm.Native(proxy)
    def run(self,p):return self.parent.run(p)

def parent_cases():
    for kind,state,role in itertools.product((0,1,2,4),(0,2,3),(1,2)):
        yield dict(suppress_thermal=1,sensor_kinds=[kind],sensor_states=[state],sensor_roles=[role])
    for state,suppress in itertools.product((0,2,3,6),(0,1)):
        yield dict(state=state,suppress_thermal=suppress,sensor_kinds=[2],sensor_roles=[2],sensor_states=[0])
    for count in (-1,0,1,3):
        yield dict(chain_count=count,suppress_thermal=1,sensor_kinds=[1],sensor_states=[0],sensor_roles=[2])
    yield dict(suppress_thermal=1,returns={'sensor_test':1}) # short-circuit before 78eb8
    yield dict(suppress_thermal=1,sensor_kinds=[2],sensor_states=[0],sensor_roles=[2],
               mutations=[('count',1,'sensor_count',0)])
    yield dict(suppress_thermal=1,sensor_kinds=[2],sensor_states=[3],sensor_roles=[2],
               mutations=[('count',1,'sensor_state',[1,0,0])])
    yield dict(suppress_thermal=1,sensor_kinds=[2],sensor_states=[0],sensor_roles=[2],
               returns={'create':-1},present=[0,0,0])

def compare(a,b,label):
    if a!=b:
        raise Mismatch('SEMANTIC_MISMATCH '+str(label)+'\n'+repr(a)+'\n'+repr(b))

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('library',type=Path);parser.add_argument('--summary',type=Path)
    parser.add_argument('--witness-only',action='store_true')
    args=parser.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    require(hashlib.sha256(elf.data).hexdigest()==REF,'reference hash')
    lib=C.CDLL(str(args.library.resolve())); original=Original(elf);native=Native(lib)
    n=events=0
    for label,p in (witnesses() if args.witness_only else cases()):
        a=original.run(p);b=native.run(p);compare(a,b,(n,label,p));n+=1;events+=len(a[2])
    report=dict(direct_cases=n,direct_events=events,original_steps=original.steps,
                original_instruction_addresses=len(original.visited))
    if not args.witness_only:
        po=ParentOriginal(elf);pn=ParentNative(lib);n=events=0
        for p in parent_cases():
            a=po.run(p);b=pn.run(p);compare(a,b,('parent',n,p));n+=1;events+=len(a[1])
        require(po.reached==pn.reached,'parent reach mismatch')
        report.update(parent_cases=n,parent_events=events,parent_steps=po.steps,predicate_calls=po.reached)
    if args.summary:
        args.summary.parent.mkdir(parents=True,exist_ok=True)
        args.summary.write_text(json.dumps(report,indent=2)+'\n')
    print('CHIP_SENSOR_CHECK135_ORIGINAL_PASS',json.dumps(report))

if __name__=='__main__':
    try:main()
    except Mismatch as e:
        print(e,file=sys.stderr);sys.exit(1)
