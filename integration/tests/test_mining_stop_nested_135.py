#!/usr/bin/env python3
"""Execute original 663cc inside cleanup, preserving original child bodies.
Previous fixtures are composed via instances/subclasses, not global replacement.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import test_mining_stop_135 as M
import test_voltage_stop_nested_135 as V
from arm32_difficulty_subset import ARM32Difficulty
S=V.S

class NestedMachine(V.NestedMachine):
    def extra_instruction(self,w,pc):
        if M.START<=pc<M.END:
            self.visited.add(pc)
            if pc==M.START:
                regs=self.r.copy();self.mining_observer(self);self.r[:]=regs
            return ARM32Difficulty.extra_instruction(self,w,pc)
        return super().extra_instruction(w,pc)
    def run(self,entry,hooks,max_steps):
        hooks=hooks.copy();self.mining_observer=hooks.pop(M.START)
        M.seed(self,self.mining_parameters)
        def snap():
            return (self.read(S.BASE+0x20),self.read(S.BASE+0xff1,1),self.read(S.BASE+0xfec),
                    self.read(S.BASE+0x102c),self.read(S.BASE+0x1030,1))
        def mutate(k,v):
            off,n={'parent_state':(0x20,4),'parent_powered':(0xff1,1),'parent_fec':(0xfec,4),
                   'parent_handle6':(0x102c,4),'parent_flag6':(0x1030,1)}[k]
            self.write(S.BASE+off,v,n)
        self.mining_script,newhooks=M.bind_original(self,self.mining_parameters,snap,mutate)
        for ep,child in newhooks.items():
            outer=hooks.get(ep)
            def route(m,child=child,outer=outer):
                if M.START<=m.r[14]<M.END:return child(m)
                assert outer is not None,('unexpected caller',hex(m.r[14]))
                return outer(m)
            hooks[ep]=route
        return super().run(entry,hooks,max_steps)

class Original:
    def __init__(self,elf):
        self.base=V.Original(elf);self.base.base.m=NestedMachine(elf)
    def run(self,entry,p,mining,children):
        m=self.base.base.m;m.mining_parameters=mining
        outer=self.base.run(entry,p,children)
        return outer,M.snapshot(m),m.mining_script.events

class Native:
    def __init__(self,lib):
        self.base=V.Native(lib);self.original=self.base.original.copy();self.f=M.Native(lib).f
    def run(self,entry,p,mining,children):
        view=M.View(mining);errors=[];events=[]
        def wrap(which):
            def teardown(ps,po,power,opaque,scratch):
                s=C.cast(ps,C.POINTER(S.State)).contents
                old=C.cast(po,C.POINTER(S.Ops)).contents
                bound=S.Ops.from_buffer_copy(old)
                def snap():return (s.state,s.power.byte_ff1,s.word_fec,s.threads[6].handle,s.threads[6].running)
                def mutate(k,v):
                    if k=='parent_state':s.state=v
                    elif k=='parent_powered':s.power.byte_ff1=v
                    elif k=='parent_fec':s.word_fec=v
                    elif k=='parent_handle6':s.threads[6].handle=v
                    elif k=='parent_flag6':s.threads[6].running=v
                    else:raise AssertionError(k)
                ops,sc,errs,keep=M.bind_native(view,mining,snap,mutate)
                def step(ctx,ep,arg):
                    try:
                        rc=old.step(ctx,ep,arg)
                        if ep==M.START:
                            assert arg==0
                            self.f(C.byref(view.s),C.byref(ops),ctx)
                        return rc
                    except BaseException as e:errors.append(e);return 0
                cb=S.STEP(step);bound.step=cb
                self.original[which](ps,C.byref(bound),power,opaque,scratch)
                errors.extend(errs);events.extend(sc.events)
            return teardown
        self.base.original={k:wrap(k) for k in self.original}
        outer=self.base.run(entry,p,children)
        if errors:raise errors[0]
        view.guard()
        return outer,view.snap(),events

def cases(quick=False):
    children={'voltage':{},'rescue':{}}
    for entry in ('before','common','policy'):
        for flag in (0,1):yield entry,{}, {'tuning':flag},children
    if quick:return
    for entry,state,ready,flag in itertools.product(('before','common','policy'),(0,2,3,4,6,0xffffffff),(0,1),(0,1,255)):
        yield entry,{'state':state,'returns':{'ready':ready}}, {'tuning':flag},children
    for entry,op,field in itertools.product(('before','common','policy'),
            ('delay','cancel','join','0x65b3c','log'),('parent_state','parent_powered','parent_fec','parent_handle6','parent_flag6')):
        yield entry,{}, {'mutations':[(op,0,field,0)]},children
    for entry in ('before','common','policy'):
        for op,key,val in [('delay','tuning',0),('delay','tuning',255),('cancel','handle',0xffffffff),
                           ('join','byte_104a',17),('0x65b3c','tuning',3),('log','started_bits',0x7ff0000000000001)]:
            yield entry,{}, {'mutations':[(op,0,key,val)]},children
    for limit,attempts,retune,disabled in itertools.product((-1,0,1,2),(0,2),(0,1),(0,1)):
        yield 'policy',dict(limit=limit,attempts=attempts,retune=retune,disabled=disabled),{},children
    for entry in ('before','common','policy'):
        for flags in itertools.product((0,255),repeat=3):
            yield entry,{}, {'tuning':flags[0]}, {'voltage':{'flag':flags[1]},'rescue':{'flag':flags[2]}}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=M.R.ELF32(M.ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==M.HASH
    native=Native(C.CDLL(str(Path(a.library).resolve())));original=Original(elf)
    counts=collections.Counter();events=backend=other=0
    for entry,p,mining,children in cases(a.quick):
        want=original.run(entry,p,mining,children);got=native.run(entry,p,mining,children)
        if want!=got:raise AssertionError(('NESTED_ORIGINAL_MISMATCH',entry,p,mining,children,want,got))
        counts[entry]+=1;events+=len(want[2]);backend+=len(want[0][0][2]);other+=len(want[0][2])
    summary=dict(cases=sum(counts.values()),entries=dict(counts),mining_events=events,backend_events=backend,
        voltage_rescue_events=other,arm_steps=original.base.base.steps,
        original_663cc_inside_5f0fc_and_5fc54=True,original_voltage_rescue_policy_power=True,
        real_threads=False,hardware_io=False)
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('MINING_STOP135_NESTED_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
