#!/usr/bin/env python3
"""Finite ARM/C LED comparisons; existing GPIO/parent bodies, scripted OS edges."""
import argparse
import collections
import ctypes as C
import itertools
import json
from pathlib import Path
from unittest.mock import patch
import gpio_power_135_oracle as G
import test_gpio_power_135 as T
import test_exit_cleanup_135 as E
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed

ROOT = Path(__file__).resolve().parents[2]
U, I, V = C.c_uint32, C.c_int32, C.c_void_p
PINS, READY = 0x654aa8, 0x654ab0
ENTRIES = {'clear': 0xf98b8, 'set': 0xf9840}
SPANS = [(0xf96a0, 0xf9a18)]
SET = C.CFUNCTYPE(I, V, U, U)
class State(C.Structure):
    _fields_ = [('ready', C.c_uint8), ('pins', U * 2)]
class Ops(C.Structure):
    _fields_ = [('set_value', SET)]

class Script:
    def __init__(self, p):
        self.p = p
        self.events = []
        self.calls = collections.Counter()
        self.snapshot = None
        self.mutate = None
    def call(self, name, args=()):
        n = self.calls[name]
        self.calls[name] += 1
        self.events.append((name, args, self.snapshot()))
        for event, occurrence, key, value in self.p.get('mutations', []):
            if event == name and occurrence == n:
                self.mutate(key, value)
        rc = self.p.get('returns', {}).get(name, 0x842000 if name == 'open' else 0)
        return rc[min(n, len(rc)-1)] if isinstance(rc, list) else rc

class Native:
    def __init__(self, lib):
        self.lib = lib
        for name in ('clear', 'set'):
            f = getattr(lib, 'vn135_led_' + name + '_135')
            f.argtypes = [C.POINTER(State), C.POINTER(Ops), V, U]
            f.restype = None
        lib.vn135_led_gpio_set_135.argtypes = [V, U, U]
        lib.vn135_led_gpio_set_135.restype = I
        lib.vn135_led_shutdown_step_135.argtypes = [C.POINTER(State), C.POINTER(Ops), V, U, U]
        lib.vn135_led_shutdown_step_135.restype = I
    def setup(self, p, script, composed=False):
        state = State(p.get('ready', 1), (U*2)(*p.get('pins', (17, 29))))
        script.snapshot = lambda: (state.ready, tuple(state.pins))
        def mutate(key, value):
            if key == 'ready': state.ready = value
            else: state.pins[int(key[-1])] = value
        script.mutate = mutate
        errors, refs = [], []
        def cb(kind, fn):
            def checked(*a):
                try: return fn(*a)
                except BaseException as error:
                    errors.append(error)
                    return 0
            f = kind(checked); refs.append(f); return f
        go = T.Gops()
        go.lock = cb(T.CB0, lambda _: script.call('lock'))
        go.unlock = cb(T.CB0, lambda _: script.call('unlock'))
        go.open = cb(T.OPEN, lambda _, path, mode: script.call('open', (path, mode)))
        go.number = cb(T.NUM, lambda _, h, fmt, val: script.call('number', (h, fmt, val)))
        go.close = cb(T.CLOSE, lambda _, h: script.call('close', (h,)))
        go.perror = cb(T.PERROR, lambda _, text: script.call('perror', (text,)))
        go.log = cb(T.LOG, lambda _, src, line, val: script.call('log', (src, line, val)))
        gio = T.Gio(C.pointer(go), None)
        def set_value(_, pin, value):
            if composed:
                return self.lib.vn135_led_gpio_set_135(C.byref(gio), pin, value)
            return script.call('set_value', (pin, value))
        ops = Ops(cb(SET, set_value))
        self.refs = (refs, go, gio, ops, state)
        return state, ops, errors
    def run(self, entry, p, composed=False):
        sc = Script(p)
        state, ops, errors = self.setup(p, sc, composed)
        f = getattr(self.lib, 'vn135_led_' + entry + '_135')
        f(C.byref(state), C.byref(ops), None, p.get('selector', 2))
        if errors: raise errors[0]
        return sc.snapshot(), sc.events

class Original:
    def __init__(self):
        self.gpio = G.Oracle()
        self.m = self.gpio.m
        self.m.allowed += SPANS
        self.visited = set()
        self.steps = 0
    def setup(self, p, sc):
        m = self.m
        m.write(READY, p.get('ready', 1), 1)
        for i, pin in enumerate(p.get('pins', (17, 29))): m.write(PINS+4*i, pin)
        sc.snapshot = lambda: (m.read(READY, 1), (m.read(PINS), m.read(PINS+4)))
        sc.mutate = lambda key, val: m.write(READY if key == 'ready' else PINS+4*int(key[-1]), val, 1 if key == 'ready' else 4)
    def run(self, entry, p, composed=False):
        sc = Script(p); m = self.m
        def augment(machine, hooks):
            self.setup(p, sc)
            if not composed:
                hooks[0x124ba4] = lambda _: setattr_return(m, sc.call('set_value', (m.r[0], m.r[1])))
        with patch.dict(G.ENTRIES, {'led': ENTRIES[entry]}):
            # Old Oracle only supplies GPIO syscall effects. It executes the
            # original LED/124ba4 instruction bodies, not a Python LED model.
            self.gpio.run('led', sc, pin=p.get('selector', 2), augment=augment)
        self.steps += m.steps; self.visited |= m.visited
        return sc.snapshot(), sc.events
    def provenance(self):
        m = self.m; cases = 0
        for pins in ((17, 29), (0, 0xffffffff), (0x80000000, 256)):
            for exported in itertools.product((0, 1), repeat=2):
                m.write(READY, 0, 1); m.write(PINS, 999); m.write(PINS+4, 888)
                events = []
                def probe(_):
                    n = sum(e[0] == 'probe' for e in events)
                    events.append(('probe', m.r[0])); setattr_return(m, exported[n])
                def export(_):
                    events.append(('export', m.r[0], m.r[1])); setattr_return(m, 0)
                hooks = {0xfe558: lambda _: setattr_return(m, pins[0]),
                         0xfe5e0: lambda _: setattr_return(m, pins[1]),
                         0x124b5c: probe, 0x1248e4: export}
                m.reset(); rc = m.run(0xf96a0, hooks=hooks, max_steps=2000)
                assert rc == 0 and m.read(READY,1) == 1
                assert (m.read(PINS),m.read(PINS+4)) == pins
                assert events == [('probe',pins[0])] + ([] if exported[0] else [('export',pins[0],1)]) + [('probe',pins[1])] + ([] if exported[1] else [('export',pins[1],1)])
                cases += 1
        return cases

def setattr_return(m, value):
    m.r[0] = int(value) & 0xffffffff

def direct_cases(quick=False):
    for entry, ready, selector in itertools.product(ENTRIES, range(256) if not quick else (0,1,2,255), (0,1,2,3)):
        yield entry, dict(ready=ready, selector=selector)
    for entry, selector, pin in itertools.product(ENTRIES, (2,255,256,0x80000000,0xffffffff), (0,0xffffffff,0x80000000,0x7fffffff)):
        yield entry, dict(selector=selector, pins=(pin,pin^0xffffffff))
    for entry, rc, field, value in itertools.product(ENTRIES, (-1,0,7), ('ready','pin0','pin1'), (0,1,255,0xffffffff)):
        yield entry, dict(returns={'set_value':[rc,-9]}, mutations=[('set_value',0,field,value)], selector=2)
    for entry in ENTRIES:
        for selector in (0,1,2):
            yield entry, dict(selector=selector, returns={'set_value':[-1,0]})

def composed_cases():
    for entry, ready, selector in itertools.product(ENTRIES, (0,1,2,255), (0,1,2,3)):
        yield entry, dict(ready=ready,selector=selector)
    for entry, pin in itertools.product(ENTRIES, (0,256,0x7fffffff,0x80000000,0xffffffff)):
        for returns in ({}, {'open':[0,0x842000]}, {'open':[0x842000,0]},
                        {'lock':-1,'unlock':-1,'number':-1,'close':-1}, {'open':0}):
            yield entry, dict(pins=(pin,pin^0xffffffff),returns=returns)
    for entry, point, key, val in itertools.product(ENTRIES, ('lock','open','number','unlock','perror'), ('ready','pin1'), (0,77)):
        yield entry, dict(mutations=[(point,0,key,val)],returns={'open':0} if point=='perror' else {})

# Parent tests execute unchanged parent bodies and original LED bodies. The
# nested GPIO body is separately tested above, not claimed nested here.
class ParentMachine(E.Machine):
    def extra_instruction(self, word, pc):
        assert any(a <= pc < b for a,b in E.RANGES + tuple(SPANS)), hex(pc)
        self.visited.add(pc)
        if pc in getattr(self, 'led_entries', {}):
            args = self.r[:4]
            self.led_entries[pc](self)
            self.r[:4] = args
        return ARM32Difficulty.extra_instruction(self, word, pc)
    def run(self, start, stop=None, hooks=None, max_steps=250000):
        hooks = dict(hooks or {})
        self.led_entries = {ep: hooks.pop(ep) for ep in ENTRIES.values() if ep in hooks}
        hooks[0x124ba4] = lambda _: setattr_return(self, self.led_script.call('set_value',(self.r[0],self.r[1])))
        return super().run(start,stop=stop,hooks=hooks,max_steps=max_steps)

class ParentOriginal(E.Original):
    def __init__(self):
        super().__init__(G.ELF32(ROOT/'reference/cgminer.vendor.elf'))
        self.m = ParentMachine(self.elf)

def parent_cases():
    for entry, state, ready in itertools.product(('before','common','policy'), (0,2,4,6), (0,1,2,255)):
        yield entry, dict(state=state,limit=0), dict(ready=ready)
    for entry, key, val in itertools.product(('before','common'), ('ready','pin1'), (0,1,99)):
        yield entry, {}, dict(mutations=[('set_value',0,key,val)],returns={'set_value':-1})
    for limit in (-1,1,2):
        yield 'policy', dict(limit=limit), dict(ready=1)

def parents(native):
    original = ParentOriginal(); cn = E.Native(native.lib)
    count = events = led_events = 0
    saved = E.Script
    for entry, p, led_p in parent_cases():
        sc = Script(led_p); state, ops, errors = native.setup(led_p,sc)
        class ParentScript(saved):
            def call(self, name, *args):
                rc = super().call(name, *args)
                if name in ('step_f98b8','step_f9840'):
                    ep = int(name[5:],16)
                    assert native.lib.vn135_led_shutdown_step_135(C.byref(state),C.byref(ops),None,ep,args[0]) == 1
                return rc
        with patch.object(E,'Script',ParentScript):
            actual = cn.run(entry,p)
        if errors: raise errors[0]
        actual_led = (sc.snapshot(),sc.events)
        os = Script(led_p); Original.setup(original,led_p,os)
        original.m.led_script = os
        expected = original.run(entry,p)
        expected_led = (os.snapshot(),os.events)
        assert actual == expected, ('parent MISMATCH',entry,p,actual,expected)
        assert actual_led == expected_led, ('parent LED MISMATCH',entry,p,actual_led,expected_led)
        count += 1; events += len(expected[2]); led_events += len(os.events)
    return dict(cases=count,parent_events=events,led_events=led_events,steps=original.steps)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('library',type=Path);ap.add_argument('--summary',type=Path)
    ap.add_argument('--quick',action='store_true')
    args=ap.parse_args()
    lib=C.CDLL(str(args.library.resolve()));native=Native(lib);original=Original()
    report={}
    for label, cases, composed in (('direct',direct_cases(args.quick),False),('gpio_composed',composed_cases(),True)):
        count=events=0
        for entry,p in cases:
            a=native.run(entry,p,composed); b=original.run(entry,p,composed)
            if a!=b: raise AssertionError(('LED_ORACLE_MISMATCH',label,entry,p,a,b))
            count+=1;events+=len(b[1])
        report[label]=dict(cases=count,events=events)
    report['initializer_provenance_cases']=original.provenance()
    report['led_gpio_steps']=original.steps
    report['parents']=parents(native)
    report['status']='PASS'
    if args.summary:
        args.summary.parent.mkdir(parents=True,exist_ok=True)
        args.summary.write_text(json.dumps(report,indent=2)+'\n')
    print('LED_OUTPUT135_ORIGINAL_PASS',json.dumps(report))
if __name__=='__main__': main()
