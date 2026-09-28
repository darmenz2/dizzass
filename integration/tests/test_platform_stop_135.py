#!/usr/bin/env python3
"""A-02: original dispatch and selected methods, bounded offline interpretation.
No vendor executable, real device, system call or new interpreter opcode runs.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import random
from pathlib import Path
import test_mining_stop_135 as M
from elf32 import ELF32
from arm32_subset import ARM32, MASK

ROOT, HASH = M.ROOT, M.HASH
SLOT, SKIP = 0x654b34, 0x654b22
ENTRIES = (0x115d88, 0x11fda4, 0x11bfbc, 0x1238cc, 0x10cf34)
RANGES = ((0xfe218, 0xfe224), (0x115d88, 0x115e18),
          (0x11fda4, 0x11fdd8), (0x11bfbc, 0x11bfc0),
          (0x1238cc, 0x1238d0), (0x10cf34, 0x10cf38),
          (0xfe024, 0xfe034), (M.START, M.END))
U, B, P = C.c_uint32, C.c_uint8, C.c_void_p
VOID = C.CFUNCTYPE(None, P)
READ = C.CFUNCTYPE(U, P, U)
WRITE = C.CFUNCTYPE(U, P, U, U)
GET = C.CFUNCTYPE(U, P)
SET = C.CFUNCTYPE(U, P, U)
class Slot(C.Structure):
    _fields_ = [('invoke', VOID), ('context', P)]
class Ops(C.Structure):
    _fields_ = [('read', READ), ('write', WRITE), ('get', GET), ('set', SET)]
class Binding(C.Structure):
    _fields_ = [('skip', C.POINTER(B)), ('ops', C.POINTER(Ops)), ('context', P)]

class Machine(ARM32):
    def __init__(self, elf):
        super().__init__(elf)
        self.visited = set()
        self.initializing = False
    def extra_instruction(self, word, pc):
        assert any(a <= pc < b for a, b in RANGES) or (self.initializing and 0xfb994 <= pc < 0xfddfc), ('UNREVIEWED', hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(word, pc)

def opaque(m, value):
    for literal, pc in ((0x115e18, 0x115d94), (0x115e1c, 0x115da8),
                        (0x11fdd8, 0x11fda8), (0x11fddc, 0x11fdb0)):
        m.write(m.read((pc + 8 + m.read(literal)) & MASK), value)

def configure(lib):
    lib.vn135_platform_stop_dispatch_135.argtypes = [C.POINTER(Slot)]
    lib.vn135_platform_stop_dispatch_135.restype = None
    for name in ('noop', 'xil'):
        f = getattr(lib, 'vn135_platform_stop_' + name + '_135')
        f.argtypes = [P]
        f.restype = None
    lib.vn135_backend_stop_mining_135.argtypes = [C.POINTER(M.State), C.POINTER(M.S.Ops), P]
    lib.vn135_backend_stop_mining_135.restype = None

class Script:
    def __init__(self, p, read_skip, write_skip, extra=lambda:(), change_extra=None):
        self.p, self.read_skip, self.write_skip = p, read_skip, write_skip
        self.words = [p.get('register', MASK), p.get('flags', MASK)]
        self.events = []
        self.extra, self.change_extra = extra, change_extra
    def snapshot(self):
        return (self.read_skip(), *self.words)
    def call(self, name, *args):
        self.events.append((name, args, self.snapshot(), self.extra()))
        for event, key, value in self.p.get('mutations', []):
            if event == name:
                if key == 'skip': self.write_skip(value)
                elif key == 'register': self.words[0] = value
                elif key == 'flags': self.words[1] = value
                else:
                    assert self.change_extra is not None
                    self.change_extra(key, value)
        if name == 'read': return self.words[0]
        if name == 'get': return self.words[1]
        if name == 'write' and not self.p.get('ignore_effects'): self.words[0] = args[1]
        if name == 'set' and not self.p.get('ignore_effects'): self.words[1] = args[0]
        return self.p.get('write_result', MASK)

def original_hooks(m, p, extra=lambda:(), change_extra=None):
    m.write(SKIP, p.get('skip', 0), 1)
    opaque(m, p.get('opaque', MASK))
    sc = Script(p, lambda:m.read(SKIP, 1), lambda v:m.write(SKIP, v, 1), extra, change_extra)
    def read(mm):
        assert mm.r[0] == 27
        mm.r[0] = sc.call('read', 27)
    def write(mm):
        assert mm.r[0] == 27
        mm.r[0] = sc.call('write', 27, mm.r[1])
    def get(mm): mm.r[0] = sc.call('get')
    def set_(mm): mm.r[0] = sc.call('set', mm.r[0])
    return sc, {0x112320:read, 0x111c48:write, 0xfe7b4:get, 0xfe83c:set_}

def native_hooks(lib, p, extra=lambda:(), change_extra=None):
    skip = B(p.get('skip', 0))
    sc = Script(p, lambda:skip.value, lambda v:setattr(skip, 'value', v), extra, change_extra)
    errors = []
    def checked(typ, fn):
        def f(*a):
            try: return fn(*a)
            except BaseException as exc: errors.append(exc); return 0
        return typ(f)
    ops = Ops(checked(READ, lambda _, idx:sc.call('read', idx)),
              checked(WRITE, lambda _, idx, val:sc.call('write', idx, val)),
              checked(GET, lambda _:sc.call('get')),
              checked(SET, lambda _, val:sc.call('set', val)))
    binding = Binding(C.pointer(skip), C.pointer(ops), None)
    if p.get('skip', 0): binding.ops = C.POINTER(Ops)()  # unreachable callbacks, not success stubs
    entry = p.get('entry', ENTRIES[0])
    method = VOID(('vn135_platform_stop_xil_135' if entry == ENTRIES[0] else 'vn135_platform_stop_noop_135', lib))
    slot = Slot(method, C.addressof(binding))
    return slot, sc, errors, (skip, ops, binding, method)

def check_equal(a, b, label):
    if a != b: raise AssertionError(('SEMANTIC_MISMATCH', label, a, b))

def direct_cases(quick=False):
    yield dict()
    yield dict(skip=1)
    yield dict(register=0x00400000, flags=0x40, write_result=MASK)
    yield dict(mutations=[('read','skip',255),('write','flags',0x12345678)])
    yield dict(register=0, flags=0, ignore_effects=True)
    if quick: return
    for skip in range(256): yield dict(skip=skip, register=0xa5a5a5a5, flags=0x5a5a5a5a)
    for bit in range(32):
        for complement in (False, True):
            w = ((1 << bit) ^ (MASK if complement else 0))
            yield dict(register=w, flags=w, write_result=w)
    for event, key, value in itertools.product(('read','write','get','set'), ('skip','register','flags'), (0, 1, 64, 0xffffffff)):
        yield dict(mutations=[(event,key,value & (255 if key == 'skip' else MASK))])
    for seed in (0,1,2,0x7fffffff,0x80000000,MASK):
        for entry in ENTRIES: yield dict(entry=entry,opaque=seed,register=seed,flags=seed)
    rng = random.Random(0xfe218)
    for _ in range(256):
        yield dict(register=rng.getrandbits(32),flags=rng.getrandbits(32),write_result=rng.getrandbits(32),opaque=rng.getrandbits(32),ignore_effects=bool(rng.getrandbits(1)))

def direct(elf, lib, quick):
    m = Machine(elf); cases = events = steps = 0
    for p in direct_cases(quick):
        m.write(SLOT, p.get('entry', ENTRIES[0]));m.reset((0xdeadbeef, 7, 9, 11))
        sc, hooks = original_hooks(m, p)
        before = bytes(m.mem); m.run(0xfe218, hooks=hooks, max_steps=160)
        assert m.r[13] == m.STACK_TOP
        # Only skip may be changed by our script; all other non-stack memory is read-only.
        after = bytearray(m.mem); after[SKIP] = before[SKIP]
        after[m.STACK_BASE:m.STACK_TOP + 0x1000] = before[m.STACK_BASE:m.STACK_TOP + 0x1000]
        assert after == before, 'unexpected original non-stack write'
        slot, new, errors, keep = native_hooks(lib,p)
        lib.vn135_platform_stop_dispatch_135(C.byref(slot))
        if errors: raise errors[0]
        check_equal((sc.snapshot(),sc.events),(new.snapshot(),new.events),p)
        cases += 1; events += len(sc.events);steps += m.steps
    return dict(cases=cases,events=events,steps=steps,visited=len(m.visited))

def dispatch(elf, lib):
    m = Machine(elf); cases = 0
    # Retargeting/reentry: selected callback completes once, next call reads new slot.
    for seed, reenter in itertools.product((0,1,0x80000000,MASK),(False,True)):
        old=[];new=[];errors=[];slot=Slot()
        def b(mm): old.append('B');mm.r[0]=seed
        def a(mm):
            assert mm.r[0] == 0x84f400
            old.append('A');mm.write(SLOT,0x84f404)
            if reenter:
                saved=mm.r[:];flags=(mm.n,mm.z,mm.c,mm.v)
                mm.r[13]-=0x100;mm.r[14]=mm.RETURN
                mm.run(0xfe218,hooks={0x84f404:b},max_steps=100)
                mm.r=saved;mm.n,mm.z,mm.c,mm.v=flags
            mm.r[0]=seed
        m.write(SLOT,0x84f400)
        for i in range(2):
            m.reset((0xffffffff-i,));m.run(0xfe218,hooks={0x84f400:a,0x84f404:b},max_steps=100)
            assert m.r[13] == m.STACK_TOP
        @VOID
        def nb(ctx):
            if ctx != 123:errors.append(ctx)
            new.append('B')
        @VOID
        def na(ctx):
            if ctx != 123:errors.append(ctx)
            new.append('A');slot.invoke=nb
            if reenter:lib.vn135_platform_stop_dispatch_135(C.byref(slot))
        slot.invoke=na;slot.context=123
        lib.vn135_platform_stop_dispatch_135(C.byref(slot));lib.vn135_platform_stop_dispatch_135(C.byref(slot))
        assert not errors;check_equal(old,new,'retarget');cases+=1
    return dict(cases=cases)

class Assigned(Exception): pass
class InitMachine(Machine):
    def write(self, address, value, n=4):
        super().write(address,value,n)
        if address == SLOT:
            raise Assigned((self.r[15]-4,value))

def provenance(elf):
    results=[]
    for controller, model, subtype in itertools.product(range(5),(0,4,7),(0,1,MASK)):
        m=InitMachine(elf);m.initializing=True;m.reset((controller,model,subtype,0))
        try:m.run(0xfb994,max_steps=700)
        except Assigned as found:
            pc,target=found.args[0];assert target == ENTRIES[controller]
            assert m.read(0x654b08)==controller and m.read(0x654b0c)==model
            results.append(dict(controller=controller,model=model,subtype=subtype,store=hex(pc),target=hex(target)))
        else:raise AssertionError('slot assignment not reached')
    return dict(cases=len(results),results=results,scope='stop at first slot write, not full platform initialization')

def nested(elf,lib,quick):
    m=Machine(elf);total=events=steps=0
    for entry, skip, flag, mutate in itertools.product(ENTRIES,(0,1,255),(0,1),(False,True)):
        if quick and (skip>1 or mutate):continue
        p=dict(entry=entry,skip=skip,tuning=flag,byte_104a=255,
               mutations=[('write','tuning',0),('write','flags',0x12345678)] if mutate else [])
        m.mem[M.BASE:M.BASE+0x1100]=b'\xa5'*0x1100;M.seed(m,p);m.write(SLOT,entry)
        def change(k,v):off,n=M.FIELDS[k];m.write(M.BASE+off,v,n)
        sc,hooks=original_hooks(m,p,lambda:M.snapshot(m),change)
        parent,ph=M.bind_original(m,{},sc.snapshot)
        del ph[0xfe218];hooks.update(ph)
        old_before=bytes(m.mem[M.BASE:M.BASE+0x1100])
        m.reset((M.BASE,));m.run(M.START,hooks=hooks,max_steps=350)
        assert m.r[13]==m.STACK_TOP
        old_after=bytearray(m.mem[M.BASE:M.BASE+0x1100])
        for off,n in M.FIELDS.values():old_after[off:off+n]=old_before[off:off+n]
        assert old_after==old_before
        view=M.View(p);slot,new,errs,keep=native_hooks(lib,p,view.snap,view.put)
        ops,nparent,err,keepers=M.bind_native(view,{},new.snapshot)
        @M.S.STEP
        def step(_,ep,arg):
            if ep==0xfe218:
                lib.vn135_platform_stop_dispatch_135(C.byref(slot));return 0
            try:return nparent.call(hex(ep),arg)&MASK
            except BaseException as exc:err.append(exc);return 0
        ops.step=step
        lib.vn135_backend_stop_mining_135(C.byref(view.s),C.byref(ops),None)
        if errs+err:raise (errs+err)[0]
        view.guard()
        check_equal((M.snapshot(m),sc.snapshot(),sc.events,parent.events),
                    (view.snap(),new.snapshot(),new.events,nparent.events),('nested',p))
        total+=1;events+=len(sc.events)+len(parent.events);steps+=m.steps
    return dict(cases=total,events=events,steps=steps)

def main():
    a=argparse.ArgumentParser();a.add_argument('library');a.add_argument('--summary');a.add_argument('--quick',action='store_true');args=a.parse_args()
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==HASH
    lib=C.CDLL(str(Path(args.library).resolve()));configure(lib)
    out=dict(direct=direct(elf,lib,args.quick),dispatch=dispatch(elf,lib),nested=nested(elf,lib,args.quick),provenance=provenance(elf),hardware=False,new_opcodes=0)
    if args.summary:Path(args.summary).write_text(json.dumps(out,indent=2)+'\n')
    print('PLATFORM_STOP135_ORIGINAL_PASS',json.dumps({k:v for k,v in out.items() if k!='provenance'},sort_keys=True),'bindings='+str(out['provenance']['cases']))
if __name__=='__main__':main()
