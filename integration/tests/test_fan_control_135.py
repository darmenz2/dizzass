#!/usr/bin/env python3
"""Bounded comparison with supplied 1.3.5 instructions. No device or process I/O."""
import argparse,ctypes as C,hashlib,json,math,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import MASK,signed
REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
PID_ADDR=0x654a30;CTRL=0x654a28;MODE=0x654a88;LAST=0x654a90;MANUAL=0x654a98;HOLD=0x654aa0;READY=0x68c170;LOCK=0x654a10
RANGES=[(0xf8568,0xf8654),(0xf86a8,0xf89a0),(0xf8a30,0xf8b28),(0xf8b60,0xf8c3c),
        (0xf8c70,0xf8db8),(0xf8df0,0xf8e68),(0xf8e78,0xf90b8),(0xf910c,0xf91e0),
        (0xf91f4,0xf9268),(0xf9278,0xf92e0),(0xf92e8,0xf9674),
        (0xfb530,0xfb5ac),(0xfb5b8,0xfb630),(0xfb638,0xfb6c0),(0xfb6d0,0xfb910),
        (0xfb928,0xfb98c),(0x596778,0x596818),(0xb4c58,0xb4dc8),(0xa71dc,0xa71e8)]
class Arm(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        if not any(a<=pc<b for a,b in RANGES):raise ValueError('Out of bounded code '+hex(pc))
        self.visited.add(pc)
        # VFP multiple increment-after, WITHOUT writeback; previous interpreter
        # already handles scalar loads and push/pop. Register bank is snapshotted.
        if w&0x0f800f00==0x0c800b00 and not w&(1<<21):
            rn=(w>>16)&15;dn=((w>>12)&15)+(((w>>22)&1)*16);size=(w&255)*4
            if rn==15 or size==0 or size%8 or dn+size//8>32:raise ValueError('VFP span')
            a=self.get(rn,pc)
            if w&(1<<20):
                vals=[self.read(a+8*i,8) for i in range(size//8)]
                for i,v in enumerate(vals):self.set_dbits(dn+i,v)
            else:
                vals=[self.dbits(dn+i) for i in range(size//8)]
                for i,v in enumerate(vals):self.write(a+8*i,v,8)
            return True
        # Previously exercised setup/round encodings, local finite-only scope.
        if w&0x0fbf0fff==0x0eb50bc0:
            v=self.d(((w>>12)&15)+(((w>>22)&1)*16))
            if not math.isfinite(v):raise ValueError('Non-finite compare')
            self.fp_flags=(v<0,v==0,v>=0,False);return True
        if w&0x0fbf0fd0==0x0eb10b40:
            d=((w>>12)&15)+(((w>>22)&1)*16);n=(w&15)+(((w>>5)&1)*16)
            self.set_dbits(d,self.dbits(n)^(1<<63));return True
        imm=w&0x0fbf0fff
        if imm in (0x0eb60b00,0x0ebe0b00,0x0eb70b00):
            self.set_d(((w>>12)&15)+(((w>>22)&1)*16),
                {0x0eb60b00:0.5,0x0ebe0b00:-0.5,0x0eb70b00:1.0}[imm]);return True
        return super().extra_instruction(w,pc)
class PID(C.Structure):
    _fields_=[(x,C.c_double) for x in ('target','input','output','lower','upper')]+[
        ('direction',C.c_uint32),('reserved_2c',C.c_uint32)]+[(x,C.c_double) for x in ('kp','ki','kd','previous_error','integral')]
class Control(C.Structure):
    _fields_=[('ceiling',C.c_int32),('pid',PID),('mode',C.c_uint32),('last_sample',C.c_double),
        ('manual_duty',C.c_int32),('full_duty_since',C.c_double),('initialized',C.c_uint8)]
class Time(C.Structure):_fields_=[('seconds',C.c_int64),('microseconds',C.c_int64)]
I=C.CFUNCTYPE(C.c_int32,C.c_void_p);V=C.CFUNCTYPE(None,C.c_void_p)
SET=C.CFUNCTYPE(None,C.c_void_p,C.c_int32);MUT=C.CFUNCTYPE(C.c_int32,C.c_void_p,C.c_uint32)
CLOCK=C.CFUNCTYPE(C.c_int32,C.c_void_p,C.POINTER(Time));LOG=C.CFUNCTYPE(None,C.c_void_p,C.c_uint32,C.c_int32)
class Ops(C.Structure):_fields_=[('initialize',I),('shutdown',V),('get_duty',I),('set_duty',SET),('mutex',MUT),('clock',CLOCK),('log',LOG)]
class Record(C.Structure):_fields_=[('lock',C.c_uint8*24),('index',C.c_uint32),('lost',C.c_uint8),('reserved',C.c_uint8*3),('value',C.c_int32)]
class Records(C.Structure):_fields_=[('count',C.c_int32),('ceiling',C.c_int32),('records',C.POINTER(Record))]
ALLOC=C.CFUNCTYPE(C.c_void_p,C.c_void_p,C.c_uint32,C.c_uint32)
INITREC=C.CFUNCTYPE(C.c_int32,C.c_void_p,C.POINTER(Record))
INITCTRL=C.CFUNCTYPE(C.c_int32,C.c_void_p,C.c_int32)
class RecordsOps(C.Structure):_fields_=[('allocate',ALLOC),('mutex_init',INITREC),('controller_init',INITCTRL)]
def db(v):return struct.pack('<d',v)
def snap_c(s):return (s.ceiling,bytes(s.pid),s.mode,db(s.last_sample),s.manual_duty,db(s.full_duty_since),s.initialized)
def mkstate():
    s=Control();s.ceiling=85;s.pid=PID(65,50,43,0,100,1,0x9abcdeff,3,.04,.15,7,19)
    s.mode=0;s.last_sample=100;s.manual_duty=47;s.full_duty_since=80;s.initialized=9;return s
class Scenario:
    def __init__(self,sc=None):self.sc=sc or {};self.events=[];self.calls={};self.scratch=(99,123456)
    def ret(self,n,default=0):
        k=self.calls.get(n,0);self.calls[n]=k+1
        return self.sc.get('returns',{}).get(n,{}).get(k,default)
    def event(self,n,*args):self.events.append((n,*args))
    def init(self):r=self.ret('initialize');self.event('initialize',r);return r
    def mutex(self,u):r=self.ret('unlock' if u else 'lock');self.event('mutex',u,r);return r
    def clock(self):
        k=self.calls.get('clock',0);rc=self.ret('clock');vals=self.sc.get('times',[(101,500000),(102,250000)])
        if not self.sc.get('clock_no_write'):self.scratch=vals[min(k,len(vals)-1)]
        self.event('clock',rc,*self.scratch);return rc,self.scratch
    def get(self):r=self.ret('get',57);self.event('get',r);return r
    def set(self,n):self.event('set',n)
    def log(self,l,a):self.event('log',l,a)
    def stop(self):self.event('shutdown')
class Original:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(self.elf.data).hexdigest()==REF
        evidence=json.loads((ROOT/'integration/evidence/fan_control_135.json').read_text())
        assert evidence['reference_sha256']==REF
        for item in evidence['ranges']:
            a,b=int(item['start'],16),int(item['end_exclusive'],16)
            assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==item['sha256']
        item=evidence['path_evidence']
        assert hashlib.sha256(self.elf.read(int(item['address'],16),item['length'])).hexdigest()==item['raw_sha256']
        self.m=Arm(self.elf);m=self.m;m.visited=set();m.run(0xf92e8,max_steps=50000)
        assert self.string(0x5ecde9)=='/tmp/build/libbitmain/src/fan_ctrl.c'
        self.initial=bytes(m.mem)
    def string(self,a):
        e=self.m.mem.find(0,a,a+2048);assert e>=a;return bytes(self.m.mem[a:e]).decode('ascii')
    def begin(self,s):
        m=self.m;m.mem[:]=self.initial;m.reset();m.visited=set()
        m.write(CTRL,s.ceiling);m.mem[PID_ADDR:PID_ADDR+88]=bytes(s.pid);m.write(MODE,s.mode)
        m.mem[LAST:LAST+8]=db(s.last_sample);m.write(MANUAL,s.manual_duty)
        m.mem[HOLD:HOLD+8]=db(s.full_duty_since);m.write(READY,s.initialized,1)
    def snap(self):
        m=self.m;return (signed(m.read(CTRL)),bytes(m.mem[PID_ADDR:PID_ADDR+88]),m.read(MODE),
                        bytes(m.mem[LAST:LAST+8]),signed(m.read(MANUAL)),bytes(m.mem[HOLD:HOLD+8]),m.read(READY,1))
    def hooks(self,s):
        def init(m):m.r[0]=s.init()&MASK
        def mutex(m):assert m.r[0]==LOCK;m.r[0]=s.mutex(0)&MASK
        def unlock(m):assert m.r[0]==LOCK;m.r[0]=s.mutex(1)&MASK
        def get(m):m.r[0]=s.get()&MASK
        def set_(m):s.set(signed(m.r[0]))
        def clock(m):
            assert m.r[1]==0;r,t=s.clock();m.write(m.r[0],t[0],8);m.write(m.r[0]+8,t[1],8);m.r[0]=r&MASK
        def i64double(m):
            v=m.r[0]|m.r[1]<<32;v=v-(1<<64) if v>>63 else v
            bits=int.from_bytes(db(float(v)),'little');m.r[0]=bits&MASK;m.r[1]=bits>>32
        def log(m):
            line=m.r[3];assert self.string(m.r[1])=='/tmp/build/libbitmain/src/fan_ctrl.c'
            assert line in (87,88,93,119,140,160)
            a=signed(m.read(m.r[13]+8)) if line in (87,88,93,119) else 0;s.log(line,a)
        return {0xfe258:init,0xfe2f0:get,0xfe2e0:set_,0xfe248:lambda m:s.stop(),
                0x5a6108:mutex,0x5a66c4:unlock,0x5a7288:clock,0x59134c:i64double,0xfa0c4:log}
    def control(self,name,args,s,sc):
        self.begin(s);m=self.m;m.reset(args);q=Scenario(sc)
        addr={'init':0xf8568,'auto':0xf86a8,'manual':0xf8a30,'full2':0xf8b60,'full3':0xf8c70,
              'gap':0xf8df0,'update':0xf8e78,'mode':0xf910c,'target':0xf911c,'get_target':0xf91f4,'shutdown':0xf9278}[name]
        rc=m.run(addr,hooks=self.hooks(q),max_steps=30000)
        result=(signed(rc) if name in ('init','get_target') else rc if name=='mode' else db(m.d(0)) if name=='gap' else None)
        return result,self.snap(),q.events
    def pid(self,name,args,state):
        self.begin(mkstate());m=self.m;a=m.DATA_BASE;m.mem[a:a+88]=bytes(state);m.reset((a,))
        for i,v in enumerate(args):
            if name=='direction':m.r[1]=v
            else:m.set_d(i,v)
        m.run({'init':0xfb530,'gains':0xfb584,'limits':0xfb590,'target':0xfb5b8,
               'get_target':0xfb5c0,'direction':0xfb5c8,'input':0xfb5d0,'seed':0xfb638,
               'step':0xfb6d0,'output':0xfb928}[name],max_steps=10000)
        return bytes(m.mem[a:a+88]),db(m.d(0)) if name in ('get_target','output') else None

def configure(lib):
    for n in ('init','gains','limits','target','get_target','direction','input','seed','step','output'):
        f=getattr(lib,'vn135_pid_'+n);argc={'init':3,'gains':3,'limits':2,'get_target':0,'output':0}.get(n,1)
        f.argtypes=[C.POINTER(PID)]+[C.c_uint32 if n=='direction' else C.c_double]*argc
        f.restype=C.c_double if n in ('get_target','output') else None
    common=[C.POINTER(Control),C.POINTER(Ops),C.c_void_p];time=[C.POINTER(Time)]
    specs={'init':(common+[C.c_int32]+time,C.c_int),'auto':(common+[C.c_int32]*4+time,None),
           'manual':(common+[C.c_int32]+time,None),'full_mode2':(common+time,None),'full_mode3':(common+time,None),
           'integral_gap':([C.POINTER(Control)],C.c_double),'update':(common+[C.c_int32]+time,None),
           'mode':([C.POINTER(Control)],C.c_uint32),'target':([C.POINTER(Control),C.c_int32],None),
           'get_target':([C.POINTER(Control)],C.c_int32),'shutdown':([C.POINTER(Ops),C.c_void_p],None)}
    for n,(args,ret) in specs.items():f=getattr(lib,'vn135_fan_control_'+n);f.argtypes=args;f.restype=ret
    lib.vn135_fan_records_init.argtypes=[C.POINTER(Records),C.POINTER(RecordsOps),C.c_void_p];lib.vn135_fan_records_init.restype=C.c_int

def callbacks(q):
    def clock(_,t):r,v=q.clock();t.contents.seconds,t.contents.microseconds=v;return r
    return Ops(I(lambda _:q.init()),V(lambda _:q.stop()),I(lambda _:q.get()),SET(lambda _,v:q.set(v)),
               MUT(lambda _,u:q.mutex(u)),CLOCK(clock),LOG(lambda _,l,v:q.log(l,v)))
def native_control(lib,name,args,state,sc):
    s=Control.from_buffer_copy(bytes(state));q=Scenario(sc);o=callbacks(q);t=Time(*q.scratch)
    n={'full2':'full_mode2','full3':'full_mode3','gap':'integral_gap'}.get(name,name)
    f=getattr(lib,'vn135_fan_control_'+n)
    if name=='shutdown':res=f(C.byref(o),None)
    elif name in ('mode','gap','get_target','target'):res=f(C.byref(s),*args)
    else:res=f(C.byref(s),C.byref(o),None,*args,C.byref(t))
    if name=='gap':res=db(res)
    return res,snap_c(s),q.events

def records_case(original,lib,count,fail,controller_fail,shrink=None,composed=False):
    orig=original;m=orig.m;s=mkstate();orig.begin(s);backend=m.DATA_BASE+0x1000;model=m.DATA_BASE+0x3000
    arena=m.DATA_BASE+0x4000;capacity=max(count,1)+2;nbytes=36*capacity;old=arena+0x2000
    m.mem[arena-16:arena+nbytes+16]=b'\xa5'*(nbytes+32);m.mem[arena:arena+nbytes]=bytes(nbytes)
    m.write(backend+0x18,model);m.write(model+0xbc,count);m.write(backend+0x64,85);m.write(backend+0x238,old)
    q=Scenario({'returns':{'initialize':{0:controller_fail}}});hooks=orig.hooks(q)
    events=[];idx=0
    def alloc(mm):
        assert mm.r[:2]==[count,36];events.append(('alloc',count,36));mm.r[0]=0 if fail else arena
    def mutex(mm):
        nonlocal idx
        i=(mm.r[0]-arena)//36;assert mm.r[1]==0
        events.append(('mutex',i,bytes(mm.mem[arena+36*i:arena+36*(i+1)])))
        mm.write(mm.r[0],0x55667788);mm.r[0]=(-7)&MASK
        if shrink is not None and idx==0:mm.write(model+0xbc,shrink)
        idx+=1
    def ctrl(mm):events.append(('controller',signed(mm.r[0])));mm.r[0]=controller_fail&MASK
    hooks.update({0x593bb4:alloc,0x5a60dc:mutex})
    if not composed:hooks[0xf8568]=ctrl
    m.reset((backend,));rc=signed(m.run(0xb4c58,hooks=hooks,max_steps=30000))
    expected=(rc,m.read(backend+0x238)==0,m.read(model+0xbc),bytes(m.mem[arena:arena+nbytes]),events,orig.snap(),q.events)
    assert bytes(m.mem[arena-16:arena])==b'\xa5'*16 and bytes(m.mem[arena+nbytes:arena+nbytes+16])==b'\xa5'*16
    arr=(Record*capacity)();oldarr=(Record*capacity)();native=Records(count,85,oldarr);seen=[];j=0
    ctl=Control.from_buffer_copy(bytes(s));qn=Scenario({'returns':{'initialize':{0:controller_fail}}});ops=callbacks(qn);tm=Time(*qn.scratch)
    def ca(_,c,z):seen.append(('alloc',c,z));return None if fail else C.addressof(arr)
    def cm(_,r):
        nonlocal j
        i=(C.addressof(r.contents)-C.addressof(arr))//36;seen.append(('mutex',i,bytes(r.contents)))
        C.memmove(C.addressof(r.contents),struct.pack('<I',0x55667788),4)
        if shrink is not None and j==0:native.count=shrink
        j+=1;return -7
    def ci(_,v):
        if composed:return lib.vn135_fan_control_init(C.byref(ctl),C.byref(ops),None,v,C.byref(tm))
        seen.append(('controller',v));return controller_fail
    ro=RecordsOps(ALLOC(ca),INITREC(cm),INITCTRL(ci));nr=lib.vn135_fan_records_init(C.byref(native),C.byref(ro),None)
    actual=(nr,not bool(native.records),native.count,bytes(arr),seen,snap_c(ctl),qn.events)
    assert actual==expected,('records',count,fail,controller_fail,shrink,composed,expected,actual)
    return len(events)+len(q.events)

def verify_extensions(oracle):
    m=oracle.m;count=0
    for load in (False,True):
        for regs in (1,2,3,4):
            for dn in (0,3,8):
                m.reset();m.visited=set();a=m.DATA_BASE
                for i in range(regs):m.write(a+8*i,0x8877665544332211+i,8);m.set_dbits(dn+i,0x1122334455667788+i)
                expected=[m.read(a+8*i,8) if load else m.dbits(dn+i) for i in range(regs)]
                m.r[0]=a;flags=(m.n,m.z,m.c,m.v)
                w=0xec800b00|(int(load)<<20)|((dn&15)<<12)|((dn>>4)<<22)|(regs*2)
                assert m.extra_instruction(w,0xfb530)
                assert m.r[0]==a and (m.n,m.z,m.c,m.v)==flags
                assert expected==[m.dbits(dn+i) if load else m.read(a+8*i,8) for i in range(regs)]
                count+=1
    for v in (-1000.5,-2.5,-1.5,-.5,-.499999,-.0,0,.499999,.5,1.5,2.5,999.5,2147483647.5):
        m.reset();m.set_d(0,v);m.run(0x596778,max_steps=500)
        expected=math.copysign(float(math.floor(abs(v)+.5)),v)
        assert db(m.d(0))==db(expected),(v,m.d(0),expected)
        count+=1
    return count

def main():
    p=argparse.ArgumentParser();p.add_argument('library');p.add_argument('--summary');a=p.parse_args()
    lib=C.CDLL(str(Path(a.library).resolve()));configure(lib);oracle=Original();rng=random.Random(1350926)
    counts={};events=0
    def compare(name,args=(),s=None,sc=None):
        nonlocal events
        s=s or mkstate();expected=oracle.control(name,args,s,sc or {});got=native_control(lib,name,args,s,sc or {})
        assert got==expected,(name,args,snap_c(s),sc,expected,got)
        counts[name]=counts.get(name,0)+1;events+=len(expected[2])
        return got
    for name in ('init','auto','manual','full2','full3','gap','update','mode','target','get_target','shutdown'):
        args={'init':(85,),'auto':(55,65,0,100),'manual':(50,),'update':(55,),'target':(60,)}.get(name,())
        compare(name,args)
    pidcount=0
    for name in ('init','gains','limits','target','get_target','direction','input','seed','step','output'):
        for i in range(160):
            st=mkstate().pid;st.direction=rng.choice([0,1,2,255,MASK]);st.input=rng.uniform(-100,140)
            st.target=rng.uniform(-20,120);st.output=rng.uniform(-250,250)
            st.integral=rng.uniform(-500,500);st.previous_error=rng.uniform(-50,50)
            st.kp=rng.uniform(0,7);st.ki=rng.uniform(0,.3);st.kd=rng.uniform(0,.5)
            st.lower=rng.uniform(-40,20);st.upper=rng.uniform(30,110)
            args={'init':(3,.02,.07),'gains':(rng.random(),rng.random(),rng.random()),
                  'limits':rng.choice([(0,100),(100,0),(1,.9995),(1,.999),(0,0)]),
                  'target':(rng.uniform(-100,120),),'direction':(rng.choice([0,1,2,MASK]),),
                  'input':(rng.uniform(-100,120),),'seed':(rng.uniform(-50,160),),
                  'step':(rng.choice([-.1,0,.009999,.01,.010001,.1,1,5,20]),)}.get(name,())
            expected=oracle.pid(name,args,st);copy=PID.from_buffer_copy(bytes(st));r=getattr(lib,'vn135_pid_'+name)(C.byref(copy),*args)
            got=(bytes(copy),db(r) if name in ('get_target','output') else None)
            assert expected==got,('pid',name,i,args,expected,got)
            pidcount+=1
    for mode in (0,1,2,3,7,MASK):
        for ready in (0,1,2,255):
            s=mkstate();s.mode=mode;s.initialized=ready
            for value in (-1,0,40,85,100,101,2147483647,-2147483648):
                compare('manual',(value,),s);compare('target',(value,),s)
                compare('auto',(value,value,0,100),s)
            compare('full2',(),s);compare('full3',(),s);compare('get_target',(),s)
    for i in range(400):
        s=mkstate();s.mode=rng.choice([0,1,2,3,4,MASK]);s.pid.direction=rng.choice([0,1,2])
        s.full_duty_since=rng.choice([80,90,91,91.5,92,110]);s.last_sample=rng.choice([100,101.491,101.5,103])
        s.manual_duty=rng.choice([-10,0,30,100,110]);v=rng.choice([-1,40,64,65,84,85,86,200])
        compare('update',(v,),s)
    for name,args in (('init',(90,)),('auto',(45,90,0,100)),('manual',(30,)),('full2',()),('full3',()),('update',(90,))):
        for retname in ('initialize','lock','unlock','clock','get'):
            for rc in (-9,-1,0,1,7):
                compare(name,args,sc={'returns':{retname:{0:rc,1:rc}},'clock_no_write':retname=='clock' and rc!=0})
    for ceiling in (-2147483648,-1,0,4,5,85,2147483647):
        for target in (-2147483648,-1,0,4,85,2147483647):
            s=mkstate();s.ceiling=ceiling
            compare('auto',(55,target,0,100),s)
    for value in (-3.5,-2.5,-.5,-.0,.5,1.5,65.5,84.5):
        s=mkstate();s.pid.target=value
        compare('auto',(55,60,0,100),s)
    for run in range(4):
        s=mkstate()
        for step in range(50):
            name,args='update',(rng.choice([40,64,84,85,95]),)
            if step==0:name,args='init',(85,)
            elif step in (1,35):name,args='auto',(50,65,20,95)
            elif step==15:name,args='manual',(40,)
            elif step==25:name,args='full3',()
            _,snapshot,_=compare(name,args,s,{'times':[(1000+step,run*10000),(1000+step,500000)]})
            s.ceiling=snapshot[0];s.pid=PID.from_buffer_copy(snapshot[1]);s.mode=snapshot[2]
            s.last_sample=struct.unpack('<d',snapshot[3])[0];s.manual_duty=snapshot[4]
            s.full_duty_since=struct.unpack('<d',snapshot[5])[0];s.initialized=snapshot[6]
    recordcount=0
    for count in (0,1,2,4,8,16):
        for fail in (False,True):
            for rc in (-9,-1,0,1,7):
                for composed in (False,True):
                    events+=records_case(oracle,lib,count,fail,rc,composed=composed);recordcount+=1
    for shrink in (0,1,2,4):events+=records_case(oracle,lib,4,False,-1,shrink);recordcount+=1
    ext=verify_extensions(oracle)
    summary={'reference_sha256':REF,'pid_comparisons':pidcount,'control_comparisons':sum(counts.values()),
        'control_counts':counts,'records_comparisons':recordcount,'compared_events':events,
        'vfp_block_fixtures':24,'round_fixtures':ext-24,'original_pid_bodies':True,'original_string_constructor':True,
        'physical_io':False,'real_threads':False,'clock_and_hardware':'scripted callbacks',
        'domain':'finite binary64; initialized valid objects; synchronous lifetime'}
    print('FAN_CONTROL135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
