#!/usr/bin/env python3
"""Execute original a6080 and 287a4 inside unchanged cleanup and stop policy.
Old entry callbacks observe the boundary, then their real ARM bodies execute.
Keep the entire previous backend trace plus ordered child traces/state views.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
from pathlib import Path
import test_voltage_stop_135 as V
import test_rescue_stop_135 as R
import test_exit_cleanup_135 as E
from arm32_difficulty_subset import ARM32Difficulty
S = V.S
ENTRIES = {'voltage':V.START,'rescue':R.START}
RANGES = {'voltage':(V.START,V.END),'rescue':(R.START,R.END)}
ADDRS = {'voltage':(V.FLAG,V.HANDLE),'rescue':(R.FLAG,R.HANDLE)}

class NestedMachine(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        assert any(a<=pc<b for a,b in (*E.RANGES,*RANGES.values())), hex(pc)
        self.visited.add(pc)
        if pc in self.observers:
            regs=self.r.copy(); self.observers[pc](self); self.r[:]=regs
        return super().extra_instruction(w,pc)
    def run(self,entry,hooks,max_steps):
        self.observers={ep:hooks[ep] for ep in ENTRIES.values()}
        hooks={k:v for k,v in hooks.items() if k not in self.observers}
        self.child_events=[]
        for kind,(flag,handle) in ADDRS.items():
            p=self.parameters[kind]
            self.write(flag,p.get('flag',1),1)
            self.write(handle,p.get('handle',700 if kind=='voltage' else 500))
        for x,y in ((V.OPAQUE_X,V.OPAQUE_Y),(R.OPAQUE_X,R.OPAQUE_Y)):
            self.write(x,0xffffffff);self.write(y,10)
        def snap():
            return tuple((self.read(f,1),self.read(h)) for f,h in ADDRS.values()) + (
                self.read(S.BASE+0x20),self.read(S.BASE+0xff1,1),self.read(S.BASE+0xfec),
                self.read(S.BASE+0x102c),self.read(S.BASE+0x1030,1))
        def mutate(kind,k,v):
            other='rescue' if kind=='voltage' else 'voltage'
            addresses={'flag':(ADDRS[kind][0],1),'handle':(ADDRS[kind][1],4),
                       'other_flag':(ADDRS[other][0],1),'other_handle':(ADDRS[other][1],4),
                       'parent_state':(S.BASE+0x20,4),'parent_powered':(S.BASE+0xff1,1),
                       'parent_fec':(S.BASE+0xfec,4),'parent_handle6':(S.BASE+0x102c,4),
                       'parent_flag6':(S.BASE+0x1030,1)}
            a,n=addresses[k];self.write(a,v,n)
        scripts={k:R.Script(self.parameters[k],snap,lambda f,v,k=k:mutate(k,f,v)) for k in ENTRIES}
        for ep,name,n in ((0x5a6b20,'self',0),(0x5a5bb0,'detach',1),
                          (0x5a4754,'cancel',1),(0x5a5d2c,'join',2)):
            outer=hooks[ep]
            def route(m,outer=outer,name=name,n=n):
                kind=next((k for k,(a,b) in RANGES.items() if a<=m.r[14]<b),None)
                if kind is None:return outer(m)
                args=tuple(m.r[:n])
                if name=='join':assert args[1]==0;args=(args[0],False)
                sc=scripts[kind];m.r[0]=sc.call(name,*args)&R.MASK
                self.child_events.append((kind,sc.events[-1]))
            hooks[ep]=route
        return super().run(entry,hooks=hooks,max_steps=max_steps)

class Original:
    def __init__(self,elf):
        self.base=E.Original(elf);self.base.m=NestedMachine(elf)
    def run(self,entry,p,children):
        m=self.base.m;m.parameters=children
        outer=self.base.run(entry,p)
        return outer,tuple((m.read(f,1),m.read(h)) for f,h in ADDRS.values()),m.child_events

class Native:
    def __init__(self,lib):
        self.base=E.Native(lib)
        self.original={'before':self.base.before,'common':self.base.common}
        self.functions={'voltage':V.Native(lib).f,'rescue':R.Native(lib).f}
    def run(self,entry,p,children):
        workers={k:R.Worker(d.get('handle',700 if k=='voltage' else 500),d.get('flag',1)) for k,d in children.items()}
        errors=[];events=[]
        def wrap(which):
            def teardown(ps,po,power,opaque,scratch):
                s=C.cast(ps,C.POINTER(S.State)).contents
                old=C.cast(po,C.POINTER(S.Ops)).contents
                bound=S.Ops.from_buffer_copy(old)
                def snap():
                    return tuple((workers[k].running,workers[k].handle) for k in ENTRIES) + (
                        s.state,s.power.byte_ff1,s.word_fec,s.threads[6].handle,s.threads[6].running)
                def mutate(kind,k,v):
                    other='rescue' if kind=='voltage' else 'voltage'
                    if k=='flag':workers[kind].running=v
                    elif k=='handle':workers[kind].handle=v
                    elif k=='other_flag':workers[other].running=v
                    elif k=='other_handle':workers[other].handle=v
                    elif k=='parent_state':s.state=v
                    elif k=='parent_powered':s.power.byte_ff1=v
                    elif k=='parent_fec':s.word_fec=v
                    elif k=='parent_handle6':s.threads[6].handle=v
                    elif k=='parent_flag6':s.threads[6].running=v
                    else:raise AssertionError(k)
                keep=[];ops={}
                for kind in ENTRIES:
                    sc=R.Script(children[kind],snap,lambda k,v,kind=kind:mutate(kind,k,v))
                    def cb(ty,name,sc=sc,kind=kind):
                        def call(_, *args):
                            try:
                                if name=='join':assert not args[1];args=(args[0],False)
                                rc=sc.call(name,*args);events.append((kind,sc.events[-1]));return rc
                            except BaseException as e:errors.append(e);return 0
                        f=ty(call);keep.append(f);return f
                    o=S.Ops();o.self=cb(S.SELF,'self');o.detach=cb(S.HANDLE,'detach')
                    o.cancel=cb(S.HANDLE,'cancel');o.join=cb(S.JOIN,'join');ops[kind]=o
                def step(ctx,ep,arg):
                    try:
                        result=old.step(ctx,ep,arg)
                        for kind,address in ENTRIES.items():
                            if ep==address:
                                assert arg==0
                                self.functions[kind](C.byref(workers[kind]),C.byref(ops[kind]),ctx)
                        return result
                    except BaseException as e:errors.append(e);return 0
                callback=S.STEP(step);bound.step=callback
                self.original[which](ps,C.byref(bound),power,opaque,scratch)
            return teardown
        self.base.before=wrap('before');self.base.common=wrap('common')
        outer=self.base.run(entry,p)
        if errors:raise errors[0]
        return outer,tuple((workers[k].running,workers[k].handle) for k in ENTRIES),events

def cases(quick=False):
    for entry in ('before','common','policy'):
        for flag,self_ in ((0,999),(1,999),(1,700)):
            yield entry,{}, {'flag':flag,'self':self_}, {}
    if quick:return
    for entry,state,ready,flag in itertools.product(('before','common','policy'),
                   (0,2,3,4,6,0xffffffff),(0,1),(0,1,255)):
        yield entry,{'state':state,'returns':{'ready':ready}}, {'flag':flag}, {}
    # Voltage stop sits between prior backend threads and slot 100c, earlier
    # than rescue; mutate future slots to check live ordering and independence.
    mutations=[('self','handle',999),('self','flag',255),('cancel','handle',0x80000000),
               ('cancel','parent_state',7),('cancel','parent_fec',0xabcdef),
               ('join','parent_powered',0),('join','parent_handle6',321),
               ('join','parent_flag6',0),('join','other_flag',0),
               ('join','other_handle',999),('detach','parent_state',8)]
    for entry,(op,field,v) in itertools.product(('before','common','policy'),mutations):
        yield entry,{}, {'self':700 if op=='detach' else 999,'mutations':[(op,0,field,v)]}, {}
    for entry in ('before','common'):
        for slot in range(10):
            flags=[0]*10;flags[slot]=1
            yield entry,{'flags':flags}, {'handle':100+slot,'self':100+slot}, {'handle':100+slot,'self':100+slot}
    for limit,attempts,retune,disabled in itertools.product((-1,0,1,2),(0,2),(0,1),(0,1)):
        yield 'policy',{'limit':limit,'attempts':attempts,'retune':retune,'disabled':disabled}, {}, {}
    for entry,rc in itertools.product(('before','common','policy'),(-2147483648,-3,0,3,2147483647)):
        yield entry,{'returns':{'off':rc},'flags':[0]*10}, {
            'returns':{'cancel':rc,'join':rc,'detach':rc}}, {'self':500,'returns':{'detach':rc}}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true');a=ap.parse_args()
    elf=R.ELF32(R.ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==R.HASH
    native=Native(C.CDLL(str(Path(a.library).resolve())));original=Original(elf)
    counts=collections.Counter();backend_events=child_events=0
    for entry,p,voltage,rescue in cases(a.quick):
        children={'voltage':voltage,'rescue':rescue}
        want=original.run(entry,p,children);got=native.run(entry,p,children)
        if want!=got:raise AssertionError(('NESTED_ORIGINAL_MISMATCH',entry,p,children,want,got))
        counts[entry]+=1;backend_events+=len(want[0][2]);child_events+=len(want[2])
    summary={'cases':sum(counts.values()),'entries':dict(counts),
             'backend_events':backend_events,'child_events':child_events,
             'arm_steps':original.base.steps,'visited_instruction_addresses':len(original.base.visited),
             'original_nested_a6080_and_287a4':True,'original_policy_and_power_stop':True,
             'real_threads':False,'voltage_operations':False}
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('VOLTAGE_STOP135_NESTED_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
