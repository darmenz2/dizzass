#!/usr/bin/env python3
"""Original 58b50 and nested existing b7798 versus C. No device/process I/O."""
import argparse
import collections
import ctypes as C
import hashlib
import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / 'tools'), str(Path(__file__).resolve().parent)]
from elf32 import ELF32
from arm32_subset import signed
from arm32_difficulty_subset import ARM32Difficulty
import test_thermal_sensors_135 as old
from test_general_monitor_135 import Model, State
from test_thermal_routes_135 import Chain

U, I, P = C.c_uint32, C.c_int32, C.c_void_p
CP, SP = C.POINTER(Chain), C.POINTER(old.Sensor)
INIT = C.CFUNCTYPE(I, P, CP, SP)
LOG = C.CFUNCTYPE(None, P, U, U, U, U)
class View(C.Structure):
    _fields_ = [('backend', C.POINTER(State)), ('chain', CP)]
class Ops(C.Structure):
    _fields_ = [('initialize', INIT), ('log', LOG)]
class Binding(C.Structure):
    _fields_ = [('temperature', C.POINTER(old.Ops)), ('context', P)]

N = 4
BANK = [old.S, old.S + 0x300]
MODELS = [old.MODEL, old.MODEL + 0x200]
GROUPS = [old.CFG, old.CFG + 0x400]

def inputs(p):
    banks = []
    for b in range(2):
        sensors = []
        for i in range(N):
            fields = dict(index=10 * b + i, access_kind=1, role=0, state=2)
            for key, val in p.get('sensor', {}).items():
                fields[key] = val[i % len(val)] if isinstance(val, list) else val
            sensors.append(old.template(**fields))
        banks.append(sensors)
    return banks

class Script(old.Scenario):
    def __init__(self, p):
        super().__init__(p)
        self.calls = collections.Counter()
        self.snap = None
        self.change = None
    def event(self, name, *args):
        n = self.calls[name]
        self.calls[name] += 1
        self.events.append((name, *args, self.snap()))
        for event, when, key, value in self.p.get('mutations', []):
            if event == name and when == n:
                self.change(key, value)
    def initialize(self, bank, index):
        n = self.calls['init']
        self.event('init', bank, index)
        seq = self.p.get('init_rc', [0])
        return seq[min(n, len(seq)-1)]

class Machine(old.ThermalArm):
    def extra_instruction(self, w, pc):
        self.visited.add(pc)
        if pc == 0xb7798 and self.observe_init:
            self.observe_init(self)
        if 0x58b50 <= pc < 0x58cf0:
            return ARM32Difficulty.extra_instruction(self, w, pc)
        return super().extra_instruction(w, pc)

def native(lib, p):
    banks = [(old.Sensor*N)(*ss) for ss in inputs(p)]
    models = [Model(4, 2, 88, p.get('count', N), 0), Model(4, 2, 88, 1, 0)]
    backend, chain = State(), Chain()
    backend.model = C.pointer(models[0]) if not p.get('null_model') else None
    chain.index, chain.state, chain.present = p.get('index', 3), p.get('state', 2), p.get('present', 1)
    chain.sensor_count = p.get('chain_count', 77)
    chain.sensors = banks[0]
    view = View(C.pointer(backend), C.pointer(chain))
    sc, errors = Script(p), []
    def bank_number(ptr):
        ad = C.cast(ptr, P).value
        for b, ar in enumerate(banks):
            delta = ad - C.addressof(ar)
            if 0 <= delta < C.sizeof(ar) and delta % C.sizeof(old.Sensor) == 0:
                return b, delta // C.sizeof(old.Sensor)
        raise AssertionError(('bad sensor pointer', ad))
    def snap():
        mp = C.cast(backend.model, P).value
        mi = next((i for i,m in enumerate(models) if C.addressof(m) == mp), -1)
        return (chain.index, chain.state, chain.present, chain.sensor_count,
                bank_number(chain.sensors)[0], mi, tuple(m.sensor_count for m in models),
                tuple(tuple(old.snapshot(s) for s in ar) for ar in banks))
    def change(key, val):
        if key == 'bank': chain.sensors = banks[val]
        elif key == 'model': backend.model = C.pointer(models[val])
        elif key == 'count': models[val[0]].sensor_count = val[1]
        elif key == 'chain': setattr(chain, val[0], val[1])
        elif key == 'sensor': setattr(banks[val[0]][val[1]], val[2], val[3])
        else: raise AssertionError(key)
    sc.snap, sc.change = snap, change
    temp_ops, keep = old.c_ops(sc, banks[0])
    binding = Binding(C.pointer(temp_ops), None)
    def init(_, cp, sp):
        try:
            assert C.addressof(cp.contents) == C.addressof(chain)
            b, i = bank_number(sp)
            if p.get('nested'):
                sc.event('init', b, i)
                return lib.vn135_chain_sensor_initialize_existing_135(C.byref(binding), cp, sp)
            return sc.initialize(b, i)
        except BaseException as ex:
            errors.append(ex); return -999
    def log(_, line, severity, cn, sn):
        try: sc.event('outer_log', line, severity, cn, sn)
        except BaseException as ex: errors.append(ex)
    cb = [INIT(init), LOG() if p.get('no_log') else LOG(log)]
    ops = Ops(*cb)
    before_chain = bytes(chain)
    rc = lib.vn135_chain_temperature_setup_135(C.byref(view), C.byref(ops), None, p.get('mode', 0))
    if errors: raise errors[0]
    # The coordinator may change only explicitly scripted chain fields.
    excluded = set()
    for name in ('index','state','present','sensor_count','sensors'):
        typ = dict(Chain._fields_)[name]
        excluded.update(range(getattr(Chain,name).offset, getattr(Chain,name).offset+C.sizeof(typ)))
    assert all(x == bytes(chain)[i] for i,x in enumerate(before_chain) if i not in excluded)
    return rc, sc.events, snap()

def original(elf, p):
    initial = inputs(p)
    sc = Script(p)
    m, hooks = old.build_arm(elf, sc, initial[0])
    m.__class__ = Machine
    m.visited, m.observe_init = set(), None
    for b in range(2):
        for i,s in enumerate(initial[b]): old.put_sensor(m, s, BANK[b]+128*i)
    m.write(old.A+0x18, p.get('index',3)); m.write(old.A+0x20,p.get('state',2))
    m.write(old.A+0x24,p.get('present',1),1)
    m.write(old.A+0x1c,old.BK); m.write(old.BK+0x18,0 if p.get('null_model') else MODELS[0])
    m.write(MODELS[1]+0x58,GROUPS[1]);m.write(GROUPS[1]+0x18,1)
    m.write(GROUPS[0]+0x18,p.get('count',N))
    # Shadow field only used to assert that cached route count is NOT the source count.
    shadow = [p.get('chain_count',77)]
    def location(addr):
        for b,base in enumerate(BANK):
            if base <= addr < base+N*128 and (addr-base)%128 == 0:
                return b,(addr-base)//128
        raise AssertionError(('bad original sensor pointer',hex(addr)))
    def snap():
        mp = m.read(old.BK+0x18)
        mi = MODELS.index(mp) if mp in MODELS else -1
        return (m.read(old.A+0x18),m.read(old.A+0x20),m.read(old.A+0x24,1),shadow[0],
                location(m.read(old.A+0x290))[0],mi,
                tuple(signed(m.read(g+0x18)) for g in GROUPS),
                tuple(tuple(old.snapshot(old.get_sensor(m,base+128*i)) for i in range(N)) for base in BANK))
    def change(key,val):
        if key=='bank': m.write(old.A+0x290,BANK[val])
        elif key=='model': m.write(old.BK+0x18,MODELS[val])
        elif key=='count':m.write(GROUPS[val[0]]+0x18,val[1])
        elif key=='chain':
            if val[0]=='sensor_count': shadow[0]=val[1]
            else:
                off,size={'index':(0x18,4),'state':(0x20,4),'present':(0x24,1)}[val[0]]
                m.write(old.A+off,val[1],size)
        elif key=='sensor':
            b,i,name,x=val;off,size=old.OFF[name];m.write(BANK[b]+128*i+off,x,size)
        else:raise AssertionError(key)
    sc.snap,sc.change=snap,change
    def init(machine):
        assert machine.r[0]==old.A
        b,i=location(machine.r[1]); machine.r[0]=sc.initialize(b,i)&0xffffffff
    if p.get('nested'):
        def observe(machine):
            assert machine.r[0]==old.A
            sc.event('init',*location(machine.r[1]))
        m.observe_init=observe
    else:hooks[0xb7798]=init
    lower_log=hooks[0xfa0c4]
    def log(machine):
        if machine.r[3] != 1208: return lower_log(machine)
        sp=machine.r[13]
        assert machine.r[:3]==[0x5e4260,0x5e4267,0x5e4286]
        assert machine.read(sp)==2 and machine.read(sp+4)==0x5e486f
        if not p.get('no_log'):
            sc.event('outer_log',1208,2,machine.read(sp+8),machine.read(sp+12))
        machine.r[0]=0
    hooks[0xfa0c4]=log
    before=[bytes(m.mem[b:b+N*128]) for b in BANK]
    m.reset((old.A,p.get('mode',0)))
    rc=signed(m.run(0x58b50,hooks=hooks,max_steps=100000))
    known=set().union(*(set(range(off,off+size)) for off,size in old.OFF.values()))
    for b,base in enumerate(BANK):
        assert all(m.mem[base+i]==before[b][i] for i in range(N*128) if i%128 not in known)
    return rc,sc.events,snap(),m.steps,m.visited

def witnesses():
    return [
      {'present':0,'count':4,'init_rc':[-1]},
      {'state':3,'init_rc':[-1]}, {'state':4,'init_rc':[-1]}, {'state':5,'init_rc':[-1]},
      {'count':2,'chain_count':0,'init_rc':[-1]},
      {'sensor':{'access_kind':[0,3,4,1],'skip_initial_read':0},'init_rc':[-1]},
      {'sensor':{'access_kind':[4,2,1,5],'skip_initial_read':1},'init_rc':[1]},
      {'mode':2,'init_rc':[-9]},
      {'mode':258,'init_rc':[-1]},
      {'sensor':{'role':[0,2,0,0]},'init_rc':[-1]},
      {'init_rc':[-1], 'mutations':[['outer_log',0,'sensor',[0,0,'role',2]]]},
      {'sensor':{'role':2}, 'init_rc':[-1], 'mutations':[['outer_log',0,'sensor',[0,0,'role',0]]]},
      {'init_rc':[-1], 'mutations':[['init',0,'bank',1],['init',0,'count',[0,1]],['init',0,'model',1],['init',0,'chain',['present',0]],['init',0,'chain',['state',3]]]},
      {'init_rc':[-1], 'mutations':[['outer_log',0,'bank',1],['outer_log',0,'sensor',[0,0,'state',99]]]},
      {'index':0xffffffff,'sensor':{'index':0xffffffff},'init_rc':[-1]},
      {'init_rc':[-1], 'mutations':[['init',0,'chain',['index',42]],['init',0,'sensor',[0,0,'index',99]]]},
      {'nested':True,'sensor':{'access_kind':[4,1,2,1],'skip_initial_read':1},'raw':89},
    ]

def cases(quick=False):
    out=witnesses()
    if quick:return out
    for present in (0,1,2,255):
        for state in (0,1,2,3,4,5,6,0x80000000,0xffffffff):
            for count in (-2147483648,-1,0,1,4):
                out.append(dict(present=present,state=state,count=count,init_rc=[-1,0]))
    for kind in (0,1,2,3,4,5,255,0xffffffff):
        for skip in (0,1,255):
            for role in (0,1,2,3,0xffffffff):
                for mode in (0,1,2,3,258,0xffffffff):
                    out.append({'sensor':{'access_kind':kind,'skip_initial_read':skip,'role':role},'mode':mode,'init_rc':[-7,0,1]})
    for state in (0,3,4,5):
        out.append(dict(state=state,present=0,null_model=True))
    for state in (3,4,5):out.append(dict(state=state,present=1,null_model=True))
    for rc in (0,1,-1,-2147483648,2147483647):
        out.append(dict(init_rc=[rc],no_log=True))
    rng=random.Random(58050)
    for _ in range(96):
        out.append({'sensor':{'access_kind':[rng.choice([0,1,2,3,4,5]) for _ in range(N)],'state':[rng.getrandbits(32) for _ in range(N)],'role':[rng.randrange(4) for _ in range(N)],'skip_initial_read':[rng.randrange(2) for _ in range(N)]},'mode':rng.choice([0,2,258]),'init_rc':[rng.choice([0,-1,5]) for _ in range(N)]})
    for kind in (1,2,4,5):
        for raw in (0,26,85,89,255):
            for failures in (0,1,2,3):
                for mode in (0,2):
                    out.append({'nested':True,'sensor':{'access_kind':kind,'remote_enabled':1,'skip_initial_read':1},'raw':raw,'read_failures':failures,'mode':mode})
    for config in ({'configure_rc':-7},{'write_rc':{9:-1}},{'write_rc':{17:-1}},{'finish_rc':-2},{'read_failures':3,'write_read':False}):
        for kind in (1,2):out.append(dict(config,nested=True,sensor={'access_kind':kind,'remote_enabled':1}))
    return out

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==old.ELF_HASH
    lib=C.CDLL(str(Path(a.library).resolve()))
    lib.vn135_chain_temperature_setup_135.argtypes=[C.POINTER(View),C.POINTER(Ops),P,U]
    lib.vn135_chain_temperature_setup_135.restype=I
    lib.vn135_chain_sensor_initialize_existing_135.argtypes=[P,CP,SP]
    lib.vn135_chain_sensor_initialize_existing_135.restype=I
    counts=collections.Counter();events=collections.Counter();steps=0;visited=set()
    for i,p in enumerate(cases(a.quick)):
        cr,ce,cs=native(lib,p); ar,ae,ast,st,pcs=original(elf,p)
        if (cr,ce,cs)!=(ar,ae,ast):
            print('SEMANTIC_MISMATCH',i,json.dumps(p),file=sys.stderr)
            print('return',cr,ar,'events',ce,ae,'state',cs,ast,file=sys.stderr)
            raise SystemExit(1)
        key='nested' if p.get('nested') else 'direct';counts[key]+=1;events[key]+=len(ae);steps+=st;visited.update(pcs)
    result=dict(status='PASS',counts=dict(counts),events=dict(events),arm_steps=steps,instruction_addresses=len(visited),reference_sha256=old.ELF_HASH,real_hardware=False,live_threads=False,existing_initializer_reused=True)
    print('CHAIN_TEMPERATURE_SETUP135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
    if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
