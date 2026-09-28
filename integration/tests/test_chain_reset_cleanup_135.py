#!/usr/bin/env python3
"""Unmodified 5ac80 + 545a0 instructions versus the composed C functions."""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import random
import struct
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_subset import signed
from arm32_difficulty_subset import ARM32Difficulty
import test_thermal_routes_135 as T
import test_general_monitor_135 as G

U, P, B = C.c_uint32, C.c_void_p, C.c_uint8
CHAIN, BACKENDS, MODELS, CHIPS, BUS = 0x842000, (0x840000, 0x841000), (0x843000, 0x843400), (0x844000, 0x845000), 0x847000
CAP = 4
SENSORS, GROUPS = (0x848000, 0x849000), (0x843800, 0x843900)
NOW=C.CFUNCTYPE(C.c_double,P)
AGG=C.CFUNCTYPE(None,P,T.CP)
class CleanupOps(C.Structure):
    _fields_=[('stop',C.POINTER(T.Stops)),('now',NOW),('aggregate',AGG)]
class View(C.Structure):
    _fields_ = [('chain', C.POINTER(G.GChain)), ('backend', C.POINTER(G.State)),
                ('word_80', U), ('tail', B * 4), ('time70',C.c_double), ('time78',C.c_double)]

def addr(x):
    return C.cast(x, P).value

class Machine(ARM32Difficulty):
    def extra_instruction(self, word, pc):
        assert any(lo <= pc < hi for lo, hi in [(0x5ac80, 0x5b11c), (0x545a0, 0x54924),
                                                (0x5e524, 0x5e53c), (0xa720c, 0xa7218), (0x58700,0x58b38), (0x590ef0,0x590fbc)]), hex(pc)
        self.visited.add(pc)
        if pc == 0x58700: self.aggregate_enter()
        if pc == 0x545a0:
            for i, byte in enumerate(self.scratch):
                self.write(self.r[13] - 48 + i, byte, 1)
        return super().extra_instruction(word, pc)

class World:
    def __init__(self, parameters, machine=None):
        self.p, self.m = parameters, machine
        self.events, self.calls, self.keep, self.errors = [], collections.Counter(), [], []
        self.reply = list(parameters.get('scratch', [0x31, 0x32]))
        self.chain = G.GChain()
        self.models, self.backends = (G.Model * 2)(), (G.State * 2)()
        self.chips = [(T.Chip * CAP)() for _ in range(2)]
        self.sensors = [(T.Sensor * CAP)() for _ in range(2)]
        self.view = View(C.pointer(self.chain), C.pointer(self.backends[0]), 0x81828384, (B * 4)(7, 8, 9, 10), -17.25, 73.5)
        c = self.chain.thermal
        c.index, c.state, c.present, c.auxiliary_enabled = 0, 7, 1, 1
        c.extra_stop_enabled, c.chip_count = 0, 0  # Deliberately different from board fields.
        c.cleared_words[:] = [11, 22, 33, 44]
        c.statistics[:] = bytes([0xa7] * 44)
        self.chain.fault_3c, self.chain.detected_8c = 0xf1f2f3f4, 0xe1e2e3e4
        for bank in range(2):
            self.models[bank].expected_chips_48 = 3 - bank
            self.models[bank].query_fault_87 = 1
            self.models[bank].sensor_count = 3 - bank
            for i in range(CAP):
                self.sensors[bank][i] = T.template(index=100+bank*10+i, state=2,
                    access_kind=parameters.get('kinds',[1,3,4,0])[i],
                    skip_initial_read=parameters.get('skip',[1,1,1,1])[i],
                    remote_offset=-37, local_offset=19, extended=12, has_previous=14,
                    failures=23, sampled_at=79.25+i, started_at=-99.75-i)
                for key,value in parameters.get('sensor_values',{}).items():
                    setattr(self.sensors[bank][i],key,value)
            self.backends[bank].model = C.pointer(self.models[bank])
            for i, chip in enumerate(self.chips[bank]):
                chip.index, chip.word_08, chip.valid = 100 + i, 0xc0000000 + i, 0x80 + i
                chip.statistics[:] = bytes([0x40 + bank * 10 + i] * 44)
                # Arbitrary bits, including NaNs: no floating arithmetic in reset.
                raw = (0x7ff8000000000031 + bank * 4 + i).to_bytes(8, 'little')
                C.memmove(C.addressof(chip) + T.Chip.temperature.offset, raw, 8)
        c.chips = self.chips[0]
        c.sensors = self.sensors[0]
        c.local[:],c.remote[:]=[11,22,33],[44,55,66]
        c.local_valid,c.remote_valid=7,9
        c.local_tail[:],c.remote_tail[:]=[3,4,5],[6,7,8]
        if machine:
            machine.mem[0x840000:0x850000] = bytes([0xa5]) * 0x10000
            machine.write(CHAIN + 0x1c, BACKENDS[0]); machine.write(CHAIN + 0x88, CHIPS[0])
            machine.write(CHAIN + 0x2b4, BUS)
            machine.write(CHAIN + 0x290, SENSORS[0])
            machine.mem[CHAIN+0x70:CHAIN+0x80]=struct.pack('<dd',self.view.time70,self.view.time78)
            machine.mem[CHAIN+0x294:CHAIN+0x2b4]=struct.pack('<3iB3s3iB3s',*c.local,c.local_valid,bytes(c.local_tail),*c.remote,c.remote_valid,bytes(c.remote_tail))
            for off, value, n in [(0x18,c.index,4),(0x20,c.state,4),(0x24,1,1),(0x25,1,1),
                                  (0x3c,self.chain.fault_3c,4),(0x80,self.view.word_80,4),
                                  (0x8c,self.chain.detected_8c,4)]:
                machine.write(CHAIN + off, value, n)
            for i, off in enumerate((0x28, 0x30, 0x34, 0x38)):
                machine.write(CHAIN + off, c.cleared_words[i])
            machine.mem[CHAIN+0x40:CHAIN+0x70] = bytes(c.statistics) + bytes(self.view.tail)
            for bank in range(2):
                machine.write(BACKENDS[bank] + 0x18, MODELS[bank])
                machine.write(BACKENDS[bank] + 0xf7,0,1)
                machine.write(MODELS[bank] + 0x48, self.models[bank].expected_chips_48)
                machine.write(MODELS[bank] + 0x87, 1, 1)
                machine.write(MODELS[bank]+0x58,GROUPS[bank])
                machine.write(GROUPS[bank]+0x18,self.models[bank].sensor_count)
                for i,sensor in enumerate(self.sensors[bank]):
                    T.put_sensor(machine,sensor,SENSORS[bank]+i*128)
                for i, chip in enumerate(self.chips[bank]):
                    at = CHIPS[bank] + i * 96
                    machine.write(at, chip.index); machine.write(at+8, chip.word_08)
                    machine.write(at+0x50, chip.valid, 1)
                    machine.mem[at+0x18:at+0x44] = bytes(chip.statistics)
                    machine.mem[at+0x58:at+0x60] = C.string_at(C.addressof(chip)+T.Chip.temperature.offset,8)
        for key in ('index','state','present','aux'):
            if key in parameters:
                self.mutate(key, parameters[key])
        self.mutate('count', [0, parameters.get('count',3)])
        self.mutate('flag', [0, parameters.get('flag',1)])
        self.mutate('sensor_count',[0,parameters.get('sensors',3)])
        for key, value in parameters.get('initial', []):
            self.mutate(key, value)
        self.before = bytes(machine.mem[0x840000:0x850000]) if machine else bytes(self.chain)

    def mutate(self, key, value):
        c, m = self.chain.thermal, self.m
        fields = {'index':(0x18,'index',4), 'state':(0x20,'state',4),
                  'present':(0x24,'present',1), 'aux':(0x25,'auxiliary_enabled',1)}
        if key in fields:
            off, name, n = fields[key]
            if m: m.write(CHAIN+off,value,n)
            else: setattr(c,name,value)
        elif key in ('count','flag'):
            bank, val = value
            if m: m.write(MODELS[bank]+(0x48 if key=='count' else 0x87),val,4 if key=='count' else 1)
            else: setattr(self.models[bank], 'expected_chips_48' if key=='count' else 'query_fault_87', val)
        elif key == 'sensor_count':
            bank,val=value
            if m:m.write(GROUPS[bank]+0x18,val)
            else:self.models[bank].sensor_count=val
        elif key == 'sensors':
            if m:m.write(CHAIN+0x290,SENSORS[value])
            else:c.sensors=self.sensors[value]
        elif key == 'backend':
            if m: m.write(CHAIN+0x1c, BACKENDS[value])
            else: self.view.backend = C.pointer(self.backends[value])
        elif key == 'model':
            backend, model = value
            if m: m.write(BACKENDS[backend]+0x18, MODELS[model])
            else: self.backends[backend].model = C.pointer(self.models[model])
        elif key == 'chips':
            if m: m.write(CHAIN+0x88, CHIPS[value])
            else: c.chips = self.chips[value]
        else:
            raise AssertionError(('unknown mutation',key))

    def snapshot(self):
        if self.m:
            m = self.m
            fields = tuple(m.read(CHAIN+off,n) for off,n in [(0x18,4),(0x20,4),(0x24,1),(0x25,1),
                            (0x28,4),(0x30,4),(0x34,4),(0x38,4),(0x80,4),(0x3c,4),(0x8c,4)])
            stats = bytes(m.mem[CHAIN+0x40:CHAIN+0x70])
            chips = tuple((m.read(a+i*96),m.read(a+i*96+8),m.read(a+i*96+0x50,1),
                           bytes(m.mem[a+i*96+0x18:a+i*96+0x44]),bytes(m.mem[a+i*96+0x58:a+i*96+0x60]))
                          for a in CHIPS for i in range(CAP))
            models = tuple((signed(m.read(a+0x48)),m.read(a+0x87,1),signed(m.read(GROUPS[i]+0x18))) for i,a in enumerate(MODELS))
            sensors=tuple(T.snapshot(T.get_sensor(m,a+i*128)) for a in SENSORS for i in range(CAP))
            times=bytes(m.mem[CHAIN+0x70:CHAIN+0x80])
            sensor_bank=SENSORS.index(m.read(CHAIN+0x290))
            aggregate=bytes(m.mem[CHAIN+0x294:CHAIN+0x2b4])
            links = (BACKENDS.index(m.read(CHAIN+0x1c)),CHIPS.index(m.read(CHAIN+0x88)),
                     tuple(MODELS.index(m.read(a+0x18)) for a in BACKENDS))
        else:
            c = self.chain.thermal
            fields = (c.index,c.state,c.present,c.auxiliary_enabled,*c.cleared_words,self.view.word_80,
                      self.chain.fault_3c,self.chain.detected_8c)
            stats = bytes(c.statistics)+bytes(self.view.tail)
            chips = tuple((x.index,x.word_08,x.valid,bytes(x.statistics),
                           C.string_at(C.addressof(x)+T.Chip.temperature.offset,8)) for bank in self.chips for x in bank)
            models = tuple((x.expected_chips_48,x.query_fault_87,x.sensor_count) for x in self.models)
            sensors=tuple(T.snapshot(x) for bank in self.sensors for x in bank)
            times=struct.pack('<dd',self.view.time70,self.view.time78)
            sensor_bank=next(i for i,b in enumerate(self.sensors) if C.addressof(b)==addr(c.sensors))
            aggregate=struct.pack('<3iB3s3iB3s',*c.local,c.local_valid,bytes(c.local_tail),*c.remote,c.remote_valid,bytes(c.remote_tail))
            links = (next(i for i in range(2) if addr(self.view.backend)==C.addressof(self.backends[i])),
                     next(i for i in range(2) if addr(c.chips)==C.addressof(self.chips[i])),
                     tuple(next(i for i in range(2) if addr(b.model)==C.addressof(self.models[i])) for b in self.backends))
        return fields,stats,chips,models,links,sensors,times,sensor_bank,aggregate

    def event(self, name, *args):
        n = self.calls[name]; self.calls[name] += 1
        self.events.append((name,args,self.snapshot()))
        for op, nth, key, value in self.p.get('mutations',[]):
            if name == op and n == nth: self.mutate(key,value)
        values = self.p.get('returns',{}).get(name,0)
        return values[min(n,len(values)-1)] if isinstance(values,list) else values

    def exchange(self, index, bus_address, tx, previous):
        n = self.calls['exchange']
        rc = self.event('exchange',index,bus_address,tx,tuple(previous))
        responses = self.p.get('responses',[[0x15,1]])
        response = responses[min(n,len(responses)-1)]
        return rc, previous if response is None else response

    def guard(self):
        if self.m:
            after = bytearray(self.m.mem[0x840000:0x850000])
            allowed = [(CHAIN+o,n) for o,n in [(0x18,16),(0x28,4),(0x30,12),(0x40,48),(0x70,16),(0x80,4),(0x88,8),(0x290,4)]]
            allowed += [(a+0x18,4) for a in BACKENDS]+[(a+o,n) for a in MODELS for o,n in [(0x48,4),(0x87,1)]]
            allowed += [(a+0x18,4) for a in GROUPS]
            if self.p.get('compose'):allowed += [(CHAIN+0x294,32)]
            allowed += [(a+i*128+o,n) for a in SENSORS for i in range(CAP) for o,n in [(0x2c,4),(0x3c,8),(0x4c,4),(0x58,12),(0x68,10),(0x74,8)]]
            allowed += [(a+i*96+o,n) for a in CHIPS for i in range(CAP) for o,n in [(8,4),(0x18,44),(0x50,1),(0x58,8)]]
            for a,n in allowed:
                off=a-0x840000; after[off:off+n]=self.before[off:off+n]
            assert after == self.before, 'unexpected original memory change'
        else:
            after = bytearray(bytes(self.chain))
            for name in ('index','state','present','auxiliary_enabled','cleared_words','statistics','chips','sensors'):
                off = getattr(T.Chain,name).offset
                n = C.sizeof(dict(T.Chain._fields_)[name])
                after[off:off+n]=self.before[off:off+n]
            if self.p.get('compose'):
                for name in ('local','remote','local_valid','remote_valid','local_tail','remote_tail'):
                    off=getattr(T.Chain,name).offset;n=C.sizeof(dict(T.Chain._fields_)[name])
                    after[off:off+n]=self.before[off:off+n]
            off=G.GChain.detected_8c.offset
            after[off:off+4]=self.before[off:off+4]
            assert after == self.before, 'unexpected native chain field change'

class Original:
    def __init__(self):
        self.m = Machine(ELF32(ROOT/'reference/cgminer.vendor.elf')); self.steps=0
    def run(self,p):
        m=self.m; w=World(p,m); m.visited=set(); m.scratch=w.reply
        def ret(v): m.r[0]=v&0xffffffff
        def lock(name):
            def call(_):
                if m.r[0]==CHAIN: ret(w.event(name))
                else:
                    pair=next((bank,(m.r[0]-at)//128) for bank,at in enumerate(SENSORS) if 0<=m.r[0]-at<CAP*128 and (m.r[0]-at)%128==0)
                    ret(w.event('sensor_'+name,*pair))
            return call
        def reset(_):
            assert m.r[1]==1
            ret(w.event('reset',m.r[0],1))
        def wait(entry):
            return lambda _:ret(w.event('delay',entry,m.r[0]))
        def log(_):
            line=m.r[3]; n=4 if line==395 else 1; sp=m.r[13]
            assert m.r[1]==0x5e4267
            assert m.read(sp)=={1840:3,1843:1,395:2}[line], (line,m.read(sp))
            ret(w.event('log',2 if line==395 else 1,line,tuple(m.read(sp+8+i*4) for i in range(n))))
        def exchange(_):
            assert m.r[0]==BUS and m.r[3]==7 and m.read(m.r[13]+4)==2
            out=m.read(m.r[13]); previous=list(m.mem[out:out+2])
            rc,values=w.exchange(m.read(CHAIN+0x18),m.r[1],bytes(m.mem[m.r[2]:m.r[2]+7]),previous)
            m.mem[out:out+2]=bytes(values);ret(rc)
        def now(_):
            n=w.calls['now']; w.event('now'); m.set_d(0,p.get('times',[101.25,-3.75])[n%2])
        def aggregate(_):
            assert m.r[0]==CHAIN; w.event('aggregate'); ret(0xdeadbeef)
        def zero(_):
            at,value,n=m.r[:3]; assert value==0 and n in (48,44)
            m.check(at,n);m.mem[at:at+n]=bytes(n);ret(at)
        hooks={0xfde14:reset,0x10ed2c:wait(0x10ed2c),0x10ef3c:wait(0x10ef3c),
               0x1ed58:now,0x58700:aggregate,0x5a6108:lock('lock'),0x5a66c4:lock('unlock'),0xfa0c4:log,0xfada0:exchange,0x5a348c:zero}
        m.aggregate_enter=lambda:w.event('aggregate')
        if p.get('compose'):
            del hooks[0x58700]
            hooks[0x6687c]=lambda _:ret(w.event('supported') or p.get('supported',0))
        for _ in range(p.get('repeat',1)):
            m.reset((CHAIN,)); saved=[0xdada0000+i for i in range(8)];m.r[4:12]=saved
            m.run(0x5ac80,hooks=hooks,max_steps=5000); rc=None
            assert m.r[4:12]==saved and m.r[13]==m.STACK_TOP
            self.steps+=m.steps
        w.guard();return rc,w.snapshot(),w.events

class Native:
    def __init__(self,lib,routes=None):
        self.routes=routes
        if routes:
            routes.vn135_temperature_aggregate_135.argtypes=[T.CP,C.POINTER(T.Rops),P]
            routes.vn135_temperature_aggregate_135.restype=None
        self.fn=lib.vn135_chain_reset_cleanup_135
        self.fn.argtypes=[C.POINTER(View),C.POINTER(CleanupOps),P,C.POINTER(B)];self.fn.restype=None
    def run(self,p):
        w=World(p)
        def cb(kind,fn):
            def guarded(*args):
                try:return fn(*args)
                except BaseException as e:w.errors.append(e);return None if kind in (T.RLOG,AGG) else 0
            value=kind(guarded);w.keep.append(value);return value
        def mutex(name,chain):
            assert addr(chain)==C.addressof(w.chain.thermal)
            return w.event(name)
        def exchange(_,index,bus,tx,n,out,length):
            assert n==7 and length==2
            rc,pair=w.exchange(index,bus,bytes(tx[:n]),list(out[:length]))
            out[0],out[1]=pair;return rc
        ops=T.Stops(cb(T.RESET,lambda _,i,v:w.event('reset',i,v)),
                    cb(T.WAIT,lambda _,e,n:w.event('delay',e,n)),cb(T.EXCHANGE,exchange),
                    cb(T.IND,lambda _,v:w.event('UNEXPECTED_INDICATOR',v)),
                    cb(T.CBCHAIN,lambda _,c:mutex('lock',c)),cb(T.CBCHAIN,lambda _,c:mutex('unlock',c)),
                    cb(T.RLOG,lambda _,s,line,args,n:w.event('log',s,line,tuple(args[:n]))))
        def now(_):
            n=w.calls['now']; w.event('now'); return p.get('times',[101.25,-3.75])[n%2]
        def aggregate(_,chain):
            mutex('aggregate',chain)
            if not p.get('compose'):return
            assert self.routes is not None
            c=w.chain.thermal
            def sensor_lock(name,ptr):
                pair=next((bank,(addr(ptr)-C.addressof(arr))//C.sizeof(T.Sensor)) for bank,arr in enumerate(w.sensors)
                    if 0<=addr(ptr)-C.addressof(arr)<C.sizeof(arr))
                return w.event('sensor_'+name,*pair)
            temp=T.Ops()
            temp.lock=cb(T.MUT,lambda _,ptr:sensor_lock('lock',ptr))
            temp.unlock=cb(T.MUT,lambda _,ptr:sensor_lock('unlock',ptr))
            reply=T.Rops();reply.temperature=C.pointer(temp)
            reply.supported=cb(T.CB0,lambda _:w.event('supported') or p.get('supported',0))
            reply.lock=cb(T.CBCHAIN,lambda _,ptr:mutex('lock',ptr))
            reply.unlock=cb(T.CBCHAIN,lambda _,ptr:mutex('unlock',ptr))
            # The old aggregate requires a fresh, stable model-count projection.
            old=(c.sensor_count,c.chip_count)
            c.sensor_count=w.view.backend.contents.model.contents.sensor_count
            c.chip_count=w.view.backend.contents.model.contents.expected_chips_48
            self.routes.vn135_temperature_aggregate_135(chain,C.byref(reply),None)
            c.sensor_count,c.chip_count=old
        extra=CleanupOps(C.pointer(ops),cb(NOW,now),cb(AGG,aggregate))
        rx=(B*2)(*w.reply)
        for _ in range(p.get('repeat',1)):
            rc=self.fn(C.byref(w.view),C.byref(extra),None,rx)
        if w.errors:raise w.errors[0]
        w.guard();return rc,w.snapshot(),w.events

def cases(quick=False):
    yield 'baseline',{}
    yield 'all_aux_fail',{'responses':[[0,0]],'returns':{'exchange':-1,'lock':-2,'unlock':-3}}
    yield 'zero_count',{'count':0}
    yield 'negative_count',{'count':-1}
    yield 'state_preserved',{'state':4}
    yield 'index_wrap',{'index':0xffffffff,'responses':[[0,0]]}
    yield 'flag_from_model',{'flag':0}
    yield 'absent',{'present':0}
    yield 'lock_model_switch',{'mutations':[('lock',0,'model',[0,1])]}
    yield 'delay_backend_switch',{'mutations':[('delay',0,'backend',1)]}
    yield 'retry_index',{'responses':[[0,0]],'mutations':[('exchange',0,'index',7)]}
    yield 'repeat',{'repeat':2}
    yield 'all_kinds',{'sensors':4,'kinds':[0,3,4,5],'skip':[1,1,0,0]}
    yield 'now_model_switch',{'mutations':[('now',1,'model',[0,1])]}
    yield 'now_sensor_switch',{'mutations':[('now',0,'sensors',1)]}
    yield 'zero_sensors',{'sensors':0}
    yield 'negative_sensors',{'sensors':-1}
    yield 'zero_times',{'times':[-0.0,0.0]}
    yield 'independent_sensor_count',{'sensors':4,'count':0}
    yield 'unlock_error_aggregate',{'returns':{'unlock':-2147483648}}
    yield 'clock_sees_old_state',{'state':7,'mutations':[('now',1,'state',5)]}
    if quick:return
    for state,count,flag,present,aux in itertools.product([0,1,2,3,4,5,6,7,0x80000000,0xffffffff],[-1,0,1,4],[0,1,255],[0,1],[0,1]):
        yield 'gates',dict(state=state,count=count,flag=flag,present=present,aux=aux)
    for kind,skip,state in itertools.product([0,1,2,3,4,5,255,0xffffffff],[0,1,128,255],[0,1,2,3,0xffffffff]):
        yield 'sensor_gates',{'kinds':[kind]*4,'skip':[skip]*4,'sensor_values':{'state':state},'sensors':4}
    for n in [-2147483648,-1,0,1,4]:
        yield 'sensor_count',{'sensors':n}
    for byte in range(256):
        yield 'present-byte',{'present':byte}
    for replies in [[[0x15,1]],[[0,0],[0x15,1]],[[0,0],[0,0],[0x15,1]],[[0,0]], [None]]:
        for rc in [-2147483648,-1,0,1,2147483647]:
            yield 'errors',{'responses':replies,'returns':{n:rc for n in ['reset','delay','exchange','lock','unlock','log']}}
    mutations=[('index',0xffffffff),('state',5),('state',0),('present',0),('aux',0),
               ('count',[0,0]),('count',[0,4]),('flag',[0,0]),('model',[0,1]),('backend',1),('chips',1),('sensors',1),('sensor_count',[0,0]),('sensor_count',[0,4])]
    for op,n in [('reset',0),('delay',0),('delay',1),('exchange',0),('log',0),('log',1),('lock',0),('now',0),('now',1),('unlock',0),('aggregate',0)]:
        for key,val in mutations:
            yield 'mutation',{'responses':[[0,0]],'mutations':[(op,n,key,val)]}
    rng=random.Random(0x5ac80)
    for _ in range(100):
        yield 'random',{'index':rng.getrandbits(32),'state':rng.getrandbits(32),'count':rng.randrange(-1,5),
                        'flag':rng.randrange(256),'present':rng.randrange(256),'aux':rng.randrange(256),
                        'scratch':[rng.randrange(256),rng.randrange(256)],'responses':[None,[0x15,1]]}

def main():
    parser=argparse.ArgumentParser();parser.add_argument('library');parser.add_argument('--summary');parser.add_argument('--quick',action='store_true');parser.add_argument('--routes-library')
    args=parser.parse_args()
    assert hashlib.sha256((ROOT/'reference/cgminer.vendor.elf').read_bytes()).hexdigest()==T.REF
    original,native=Original(),Native(C.CDLL(str(Path(args.library).resolve())),C.CDLL(str(Path(args.routes_library).resolve())) if args.routes_library else None)
    total=events=nested=0
    scenarios=list(cases(args.quick))
    if args.routes_library:
        for state,present,supported,n in itertools.product([2,3,4,5,6],[0,1],[0,1],[0,1,4]):
            scenarios.append(('composed_aggregate',dict(compose=True,state=state,present=present,supported=supported,sensors=n,
                kinds=[0,1,3,4],skip=[0,0,0,0])))
    for label,p in scenarios:
        expected,actual=original.run(p),native.run(p)
        if expected!=actual:raise AssertionError(('MISMATCH',label,p,expected,actual))
        total+=1;events+=len(expected[2]);nested+=int(bool(p.get("compose")))
    report=dict(status='PASS',cases=total,events=events,original_steps=original.steps,hardware_io=False,
                composed_original_auxiliary=True,nested_aggregate_cases=nested,aggregate_boundary="composed for nested cases; scripted otherwise",reference_sha256=T.REF)
    print('CHAIN_RESET_CLEANUP135_ORIGINAL_PASS',json.dumps(report))
    if args.summary:Path(args.summary).write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':main()
