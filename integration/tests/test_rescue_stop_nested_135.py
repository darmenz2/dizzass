#!/usr/bin/env python3
"""Extend unchanged exit/policy fixtures with the actual nested 287a4 body.
The prior fixture boundary is retained only as an entry observer. It is NOT
allowed to replace the new function: its unchanged ARM words execute to return.
Both reference and C retain every existing backend event, plus a separate
rescue-thread trace containing parent-state snapshots. No old module is patched.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import test_rescue_stop_135 as R
import test_exit_cleanup_135 as E
from arm32_difficulty_subset import ARM32Difficulty
S=R.S

class NestedMachine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert R.START<=pc<R.END or any(a<=pc<b for a,b in E.RANGES),hex(pc)
        self.visited.add(pc)
        if pc==R.START:
            # Preserve the old entry observation without replacing the body.
            # These selected fixtures do not mutate state at step_287a4.
            regs=self.r.copy();self.observer(self);self.r[:]=regs
        return super().extra_instruction(w,pc)
    def run(self,entry,hooks,max_steps):
        self.observer=hooks[0x287a4];hooks=dict(hooks);del hooks[0x287a4]
        p=self.rescue_parameters
        self.write(R.FLAG,p.get('flag',1),1);self.write(R.HANDLE,p.get('handle',500))
        self.write(R.OPAQUE_X,p.get('opaque',0xffffffff));self.write(R.OPAQUE_Y,10)
        def snap():return (self.read(R.FLAG,1),self.read(R.HANDLE),self.read(S.BASE+0x20),
                           self.read(S.BASE+0xff1,1),self.read(S.BASE+0xfec))
        def mutate(k,v):
            a,n={'flag':(R.FLAG,1),'handle':(R.HANDLE,4),'parent_state':(S.BASE+0x20,4),
                 'parent_powered':(S.BASE+0xff1,1),'parent_fec':(S.BASE+0xfec,4)}[k]
            self.write(a,v,n)
        self.script=R.Script(p,snap,mutate)
        for ep,name,n in ((0x5a6b20,'self',0),(0x5a5bb0,'detach',1),(0x5a4754,'cancel',1),(0x5a5d2c,'join',2)):
            outer=hooks[ep]
            def route(m,outer=outer,name=name,n=n):
                if not R.START<=m.r[14]<R.END:return outer(m)
                args=tuple(m.r[:n])
                if name=='join':args=(args[0],bool(args[1]));assert not m.r[1]
                m.r[0]=self.script.call(name,*args)&R.MASK
            hooks[ep]=route
        return super().run(entry,hooks=hooks,max_steps=max_steps)

class Original:
    def __init__(self,elf):
        self.base=E.Original(elf);self.base.m=NestedMachine(elf)
    def run(self,entry,p,rescue):
        m=self.base.m;m.rescue_parameters=rescue
        outer=self.base.run(entry,p)
        return outer,(m.read(R.FLAG,1),m.read(R.HANDLE)),m.script.events

class Native:
    def __init__(self,lib):
        self.base=E.Native(lib);self.helper=R.Native(lib).f;self.before=self.base.before
    def run(self,entry,p,rescue):
        worker=R.Worker(rescue.get('handle',500),rescue.get('flag',1))
        errors=[];events=[]
        def before(ps,po,power,opaque,scratch):
            s=C.cast(ps,C.POINTER(S.State)).contents
            old=C.cast(po,C.POINTER(S.Ops)).contents
            ops=S.Ops.from_buffer_copy(old)
            def snap():return (worker.running,worker.handle,s.state,s.power.byte_ff1,s.word_fec)
            def mutate(k,v):
                if k=='flag':worker.running=v
                elif k=='handle':worker.handle=v
                elif k=='parent_state':s.state=v
                elif k=='parent_powered':s.power.byte_ff1=v
                elif k=='parent_fec':s.word_fec=v
                else:raise AssertionError(k)
            sc=R.Script(rescue,snap,mutate);sc.events=events;keep=[]
            def cb(ty,name):
                def call(_, *args):
                    try:
                        if name=='join':args=(args[0],bool(args[1]))
                        return sc.call(name,*args)
                    except BaseException as e:errors.append(e);return 0
                f=ty(call);keep.append(f);return f
            global_ops=S.Ops();global_ops.self=cb(S.SELF,'self');global_ops.detach=cb(S.HANDLE,'detach')
            global_ops.cancel=cb(S.HANDLE,'cancel');global_ops.join=cb(S.JOIN,'join')
            def step(ctx,ep,arg):
                try:
                    result=old.step(ctx,ep,arg)
                    if ep==0x287a4:
                        assert arg==0
                        self.helper(C.byref(worker),C.byref(global_ops),ctx)
                    return result
                except BaseException as e:errors.append(e);return 0
            bound=S.STEP(step);ops.step=bound
            self.before(ps,C.byref(ops),power,opaque,scratch)
        self.base.before=before
        outer=self.base.run(entry,p)
        if errors:raise errors[0]
        return outer,(worker.running,worker.handle),events

def cases(quick=False):
    for entry in ('before','policy','common'):
        for flag,self_ in ((0,999),(1,999),(1,500)):
            yield entry,{}, {'flag':flag,'self':self_}
    if quick:return
    for state,flag,ready in itertools.product((0,2,3,4,6,0xffffffff),(0,1,255),(0,1)):
        yield 'before',{'state':state,'returns':{'ready':ready}}, {'flag':flag}
    for limit,rc,self_ in itertools.product((0,1,-1),(-3,0,3),(999,500)):
        yield 'policy',{'limit':limit,'attempts':2,'flags':[0]*10}, {'self':self_,'returns':{'cancel':rc,'join':rc,'detach':rc}}
    for op,field,v in (('self','handle',999),('self','flag',255),('cancel','handle',321),
                       ('cancel','parent_state',7),('cancel','parent_fec',0xabcdef),
                       ('join','parent_powered',0),('join','flag',1),('detach','parent_state',8)):
        for entry in ('before','policy'):
            yield entry,{}, {'self':500 if op=='detach' else 999,'mutations':[(op,0,field,v)]}
    for slot in range(10):
        flags=[0]*10;flags[slot]=1
        yield 'before',{'flags':flags}, {'handle':100+slot,'self':100+slot}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=R.ELF32(R.ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==R.HASH
    native=Native(C.CDLL(str(Path(a.library).resolve())));original=Original(elf)
    counts=collections.Counter();events=0;rescue_events=0
    for entry,p,g in cases(a.quick):
        want=original.run(entry,p,g);got=native.run(entry,p,g)
        if want!=got:raise AssertionError(('NESTED_ORIGINAL_MISMATCH',entry,p,g,want,got))
        counts[entry]+=1;events+=len(want[0][2]);rescue_events+=len(want[2])
    summary={'cases':sum(counts.values()),'entries':dict(counts),'backend_events':events,'rescue_events':rescue_events,
             'arm_steps':original.base.steps,'visited_instruction_addresses':len(original.base.visited),
             'original_nested_287a4':True,'original_policy_and_power_stop':True,'real_threads':False}
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('RESCUE_STOP135_NESTED_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
