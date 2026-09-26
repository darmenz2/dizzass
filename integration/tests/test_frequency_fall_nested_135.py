#!/usr/bin/env python3
"""Execute original 65b3c inside original 663cc, not a success callback.
Shared views preserve before/after ordering and ignored child errors.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import test_frequency_fall_135 as F
import test_mining_stop_135 as M
from arm32_subset import ARM32, MASK

class Machine(ARM32):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in (*F.RANGES,(M.START,M.END))),hex(pc)
        self.visited.add(pc)
        if pc==F.START:
            regs=self.r.copy();self.observe_fall(self);self.r[:]=regs
        return super().extra_instruction(w,pc)

class Original:
    def __init__(self,elf):self.m=Machine(elf);self.steps=0;self.visited=set()
    def run(self,mining,p):
        m=self.m;m.mem[F.BASE:F.BASE+0x10000]=b'\xa5'*0x10000;m.visited=set()
        m.write(F.BASE+0x20,2);M.seed(m,mining)
        view=F.ArmView(m,p,given_backend=True)
        def mutate_extra(k,v):
            off,n=M.FIELDS[k[6:]];m.write(F.BASE+off,v,n)
        sc,childhooks=F.bind_original(view,p,lambda:M.snapshot(m),mutate_extra)
        mine,outerhooks=M.bind_original(m,mining,view.snapshot,view.mutate)
        m.observe_fall=outerhooks.pop(F.START)
        hooks=outerhooks.copy()
        for ep,child in childhooks.items():
            outer=hooks.get(ep)
            def route(q,child=child,outer=outer):
                if F.START<=q.r[14]<F.END:return child(q)
                assert outer is not None,('unexpected call site',hex(q.r[14]))
                return outer(q)
            hooks[ep]=route
        m.reset((F.BASE,));m.run(M.START,hooks=hooks,max_steps=7000)
        assert m.r[13]==m.STACK_TOP and not any(view.live)
        self.steps+=m.steps;self.visited|=m.visited
        return M.snapshot(m),mine.events,view.snapshot(),sc.events

class Native:
    def __init__(self,lib):self.f=M.Native(lib).f;self.child=F.Native(lib).f
    def run(self,mining,p):
        mv=M.View(mining);mv.g.state=2
        fv=F.View(p,g=mv.g)
        fo,fs,fkeep,ferr=F.bind_native(fv,p,mv.snap,lambda k,v:mv.put(k[6:],v))
        mo,ms,merr,mkeep=M.bind_native(mv,mining,fv.snapshot,fv.mutate)
        bound=M.S.Ops.from_buffer_copy(mo);old=mo.step;errors=[]
        def step(ctx,entry,arg):
            try:
                rc=old(ctx,entry,arg)
                if entry==F.START:self.child(C.byref(fv.s),C.byref(fo),ctx)
                return rc
            except BaseException as e:errors.append(e);return 0
        cb=M.S.STEP(step);bound.step=cb
        self.f(C.byref(mv.s),C.byref(bound),None)
        if ferr or merr or errors:raise (ferr+merr+errors)[0]
        assert not any(fv.live)
        return mv.snap(),ms.events,fv.snapshot(),fs.events

def cases(quick=False):
    for name,p in F.cases(True):yield name,{},p
    if quick:return
    for flag,fail in itertools.product((0,1,255),(None,0,1)):
        yield 'mining_flags_and_alloc_errors',{'tuning':flag,'byte_104a':255},{'alloc_fail':fail}
    for idx,rc in itertools.product(range(3),(-2147483648,-3,1,11,2147483647)):
        yield 'creation_failure_ignored_by_parent',{}, {'returns':{'create':[0]*idx+[rc]}}
    for op,n in (('count',0),('count',1),('count',2),('allocate',0),('allocate',1),('create',0),('join',0),('free',0),('free',1)):
        for field,v in [('tuning',7),('byte_104a',17),('started_bits',0x7ff0000000000001),('active',255),('warmup_done',255),('handle',0xface),('power',0xffffffff)]:
            yield 'child_mutates_parent_before_final_reset',{}, {'mutations':[(op,n,'extra_'+field,v)]}
    for op,n in (('0xfe218',0),('0xb8e54',0),('delay',0),('join',0),('0x65b3c',0),('log',0)):
        for field,val in [('target',[0,900]),('floor',[0,900]),('config_bank',1),('chain_bank',1),('chain',[0,0,'frequency',99])]:
            yield 'parent_mutates_child_fields',{'mutations':[(op,n,field,val)]},{}
    for n,m,k in itertools.product((0,1,3),(0,3),(0,3)):
        yield 'changing_chain_counts',{'returns':{'cancel':-3,'join':-5}}, {'returns':{'count':[n,m,k]},'configs':[(900,400),(100,400)]}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=F.R.ELF32(F.ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==F.HASH
    original=Original(elf);native=Native(C.CDLL(str(Path(a.library).resolve())))
    groups=collections.Counter();fall_events=mining_events=0
    for name,mining,p in cases(a.quick):
        want=original.run(mining,p);got=native.run(mining,p)
        if want!=got:raise AssertionError(('FREQUENCY_FALL_NESTED_MISMATCH',name,mining,p,want,got))
        groups[name]+=1;mining_events+=len(want[1]);fall_events+=len(want[3])
    result=dict(cases=sum(groups.values()),groups=dict(groups),mining_events=mining_events,fall_events=fall_events,
        arm_steps=original.steps,visited_instruction_addresses=len(original.visited),
        original_65b3c_inside_663cc=True,worker_65fcc_recovered=False,hardware_io=False,real_threads=False)
    if a.summary:Path(a.summary).write_text(json.dumps(result,indent=2)+'\n')
    print('FREQUENCY_FALL135_NESTED_PASS',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()
