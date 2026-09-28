#!/usr/bin/env python3
"""Actual 70e30 -> 6ec4c -> 58b50 -> b7798, 78eb8, 60a2c instructions.
Optional subsequent 5fc54 executes on the SAME emulated backend, not a fresh one.
Its lower cleanup/device/thread actions are explicit scripts, not a live runtime.
"""
import argparse,collections,ctypes as C,hashlib,itertools,json,struct,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT/'tools'),str(Path(__file__).parent)]
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
import test_thermal_sensors_135 as T
import backend_resume_135_oracle as R
import test_backend_shutdown_135 as S
U,I=C.c_uint32,C.c_int32
FIELDS='state mode selector platform kind role sensors count fault_mask fault_kind partial suppress minimum create_fail create_rc error_write scheduled on_rc voltage_rc off_rc fail_step fail_rc followup repeat_stop join_flag join_seed join_value join_rc join_writes self_handle board_flag key present_mask chain_state no_log'.split()
SIGNED={'sensors','count','minimum','create_fail','create_rc','on_rc','voltage_rc','off_rc','fail_rc','join_rc'}
class Case(C.Structure):_fields_=[(n,I if n in SIGNED else U) for n in FIELDS]
class Result(C.Structure):_fields_=[('rc',I),('event_count',U),('length',U*3),('phase_events',U*3),('snapshot',(U*256)*3),('events',(U*6)*1024)]
(E_STEP,E_LOG,E_POWER_LOG,E_SENSOR_LOG,E_CREATE,E_JOIN,E_DUP,E_FREE,E_TIME,E_REGISTER,E_STOP,E_CONFIG,E_READ,E_WRITE,E_FINISH,E_SELF,E_CANCEL,E_DETACH,E_MARK,E_ON,E_VOLT,E_OFF,E_RESET,E_COUNT)=range(1,25)
B,MODEL,LIMITS,GROUP,TABLE,CHAINS,SENSORS,PLATFORM=R.B,R.PROFILE,R.LIMITS,R.TABLE,R.ENTRIES,R.CHAINS,R.ITEMS,R.PLATFORM
KEY=0x850100;NC=3;NS=2
ENTRIES=(0x70e30,0x6ec4c,0x58b50,0xb7798,0x78eb8,0x60a2c,0x5fc54,0x6c224,0x6b778)
REC=tuple(R.RANGES)+tuple(S.ALLOWED)+((0x6ec4c,0x6f188),(0x58b50,0x58cf0),(0x78eb8,0x790b4),(0x60a2c,0x60d20),(0x56fcc,0x57028),(0x57030,0x57084),(0xa71dc,0xa7218))
class M(T.ThermalArm):
    def extra_instruction(self,w,pc):
        self.visited.add(pc)
        if pc in ENTRIES:self.entries[pc]+=1
        if any(a<=pc<b for a,b in REC):return ARM32Difficulty.extra_instruction(self,w,pc)
        return super().extra_instruction(w,pc)

class Native:
    def __init__(self,library):
        self.lib=C.CDLL(str(Path(library).resolve()))
        self.lib.rt135_default.argtypes=[C.POINTER(Case)]
        self.lib.rt135_run.argtypes=[C.POINTER(Case),C.POINTER(Result)];self.lib.rt135_run.restype=I
    def case(self,d):
        p=Case();self.lib.rt135_default(C.byref(p))
        for k,v in d.items():
            if k not in FIELDS:raise ValueError(k)
            setattr(p,k,v)
        return p
    def run(self,p):
        out=Result()
        if self.lib.rt135_run(C.byref(p),C.byref(out)):raise RuntimeError('harness failed')
        return out.rc,[tuple(out.snapshot[i][:out.length[i]]) for i in range(3)],list(out.phase_events),[tuple(out.events[i]) for i in range(out.event_count)]

class Original:
    def __init__(self):
        elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        if hashlib.sha256(elf.data).hexdigest()!=T.ELF_HASH:raise ValueError('reference changed')
        self.m=M(elf);self.steps=0;self.visited=set();self.entries=collections.Counter()
        self.strings={int(x['base'],16):x for x in json.loads((ROOT/'evidence/stage1/cgminer_xor_strings.json').read_text())}
    def run(self,p):
        m=self.m;m.mem[0x840000:0x850000]=bytes(0x10000);m.visited=set();m.entries=collections.Counter()
        events=[];snapshots=[(),(),()];phase_events=[0,0,0];ticks=0;creates=0;registered=0;in_stop=False
        def ev(e,*args):
            if len(events)>=1024:raise AssertionError('too many events')
            events.append(tuple([e]+[v&0xffffffff for v in args]+[0]*(5-len(args))))
        def ca(c):return CHAINS+800*c
        def sa(c,s):return SENSORS+0x400*c+128*s
        for a,v in [(B+0x18,MODEL),(B+0x1c,LIMITS),(B+0x230,CHAINS),(B+0x19c,KEY),(MODEL+0x58,GROUP),(GROUP,TABLE),(GROUP+0x18,p.sensors),(MODEL+0x10,3),(MODEL+0x48,108),(MODEL+0x88,p.selector),(MODEL+0xb4,0x44332211),(B+0x50,p.mode),(B+0x20,p.state),(B+0xdc,12000),(LIMITS+0x34,15000),(B+0x90,R.NEW),(B+0xfc8,R.OLD),(B+0xfe8,77),(B+0xfec,88),(B+0xf8,p.minimum)]:m.write(a,v)
        for a,v in [(B+0xfe6,1),(B+0xf6,p.suppress),(B+0x105,p.partial),(B+0x1054,p.join_flag),(MODEL+0x87,p.board_flag),(PLATFORM,0xa5)]:m.write(a,v,1)
        m.write(B+0x28,int.from_bytes(struct.pack('<d',-99.25),'little'),8)
        for o,v in [(0x1044,0x20202020),(0x101c,0x30303030),(0x1014,0x40404040),(0x1050,0x10101010)]:m.write(B+o,v)
        for j in range(NS):m.write(TABLE+28*j,p.kind);m.write(TABLE+28*j+4,p.role)
        for o,v in [(0x1d0,0x850000),(0x1d4,0x850010),(0x1d8,0x850020),(0x1dc,0x850030)]:m.write(B+o,v)
        for c in range(NC):
            for off,v in [(0x18,c+10),(0x1c,B),(0x20,p.chain_state),(0x290,sa(c,0)),(0x2b4,0x84a000)]:m.write(ca(c)+off,v)
            m.write(ca(c)+0x24,(p.present_mask>>c)&1,1)
            for j in range(NS):
                s=T.template(index=j,access_kind=p.kind,role=p.role,state=0,remote_enabled=1,skip_initial_read=1)
                T.put_sensor(m,s,sa(c,j));m.write(sa(c,j)+0x44,0x87650000+c*10+j)
        m.mem[R.OLD:R.OLD+4]=b'old\0';m.mem[R.NEW:R.NEW+4]=b'new\0'
        join_ptr=m.STACK_TOP-56;m.write(join_ptr,p.join_seed);resume_scratch=p.join_seed
        def snapshot():
            result=[m.read(B+0x20),m.read(B+0x24,1),m.read(B+0xff1,1),m.read(B+0x20c),m.read(PLATFORM,1),m.read(B+0x28),m.read(B+0x2c)]
            ptr=m.read(B+0xfc8);result.extend((0 if not ptr else 2 if ptr==R.NEW else 1,resume_scratch,m.read(B+0xfe6,1),m.read(B+0xfe8),m.read(B+0xfec),registered))
            for off in S.OFFSETS:result.extend((m.read(B+off),m.read(B+off+4,1)))
            for c in range(NC):
                result.extend((m.read(ca(c)+0x20),m.read(ca(c)+0x24,1)))
                for j in range(NS):
                    s=T.get_sensor(m,sa(c,j))
                    for n,t in T.Sensor._fields_:
                        v=getattr(s,n)
                        if t is T.D:result.extend(struct.unpack('<II',struct.pack('<d',v)))
                        else:result.append(v&0xffffffff)
                    result.append(m.read(sa(c,j)+0x44))
            return tuple(result)
        def ret(v=0):m.r[0]=int(v)&0xffffffff
        def count(_):ev(E_COUNT);ret(p.count)
        def scalar(_,e):
            if e in R.BACKEND_ARG and m.r[0]!=B:raise AssertionError(('backend',hex(e),hex(m.r[0])))
            args=(0,0,0)
            if e==0x106e58:args=tuple(m.r[:3])
            elif e in (0x10ef3c,0x829e8):args=(m.r[0],0,0)
            elif e in (0x6e734,0x6709c,0x66244,0x644a8):args=(m.r[1],0,0)
            elif e==0x49c98:args=(m.r[1],0,0)
            elif e==0x55400:args=((m.r[0]-CHAINS)//800,0,0)
            ev(E_STEP,e,*args)
            ret(p.fail_rc if e==p.fail_step else p.mode if e==0x82d60 else p.platform if e==0xfdfbc else 1 if e==0x34920 else 0)
        hooks={e:(lambda mm,e=e:scalar(mm,e)) for e in R.STEP_IDS if e not in (0x6ec4c,0x60a2c,0xfe668)}
        hooks[0xfe668]=count
        def now(_):
            nonlocal ticks
            v=100.0+0.125*ticks;ticks+=1
            ev(E_TIME,*struct.unpack('<II',struct.pack('<d',v)));m.set_d(0,v)
        def loc(a):
            for c in range(NC):
                d=a-sa(c,0)
                if 0<=d<NS*128 and d%128==0:return c*NS+d//128
            raise AssertionError(('bad sensor',hex(a)))
        def bad(i,k):return bool(p.fault_mask&(1<<i)) and p.fault_kind==k
        def config(_):i=loc(m.r[1]-0x1c);ev(E_CONFIG,i);ret(-7 if bad(i,1) else 0)
        def read(_):
            i=loc(m.r[1]-0x1c);ev(E_READ,i,m.r[3]);m.write(m.read(m.r[13]),0 if bad(i,3) else 89,1);ret(-1 if bad(i,2) else 0)
        def write(_):i=loc(m.r[1]-0x1c);ev(E_WRITE,i,m.r[3],m.read(m.r[13])&255);ret(-5 if bad(i,4) else 0)
        def finish(_):i=loc(m.r[1]-0x1c);ev(E_FINISH,i);ret(-6 if bad(i,5) else 0)
        def key(_):ev(E_STEP,0x19c,0,0,0);ret(p.key)
        def register(_):
            nonlocal registered
            if in_stop:
                if m.r[2] or m.r[3]:raise AssertionError('wrong removal request')
                ev(E_REGISTER,m.r[1],0,0);registered=0
            else:
                if m.r[2]!=B:raise AssertionError('wrong registration context')
                ev(E_REGISTER,m.r[1],1,m.r[3]);registered=1
            # Observation only. No callback table, output exchange or host call.
            ret()
        def stop(_):
            c=(m.r[0]-CHAINS)//800
            if not 0<=c<NC or m.r[0]!=ca(c) or m.r[1]!=0x5e689b:raise AssertionError('bad stop binding')
            ev(E_STOP,c);m.write(ca(c)+0x20,3);ret(-19)
        def on(_):ev(E_ON);ret(p.on_rc)
        def voltage(_):
            if m.r[0]!=B+0x108c:raise AssertionError('voltage context')
            ev(E_VOLT,m.r[1]);ret(p.voltage_rc)
        def create(_):
            nonlocal creates
            creates+=1;off=m.r[0]-B;ev(E_CREATE,off,m.r[2]);rc=p.create_rc if creates==p.create_fail else 0
            if off not in (0x1044,0x1014,0x101c) or m.r[1] or m.r[3]!=B:raise AssertionError('create args')
            if not rc or p.error_write:m.write(B+off,0x60000000+off)
            if not rc and p.scheduled:m.write(B+off+4,1,1)
            ret(rc)
        def join(_):
            if not in_stop and m.r[1]!=join_ptr:raise AssertionError('resume join scratch')
            ev(E_JOIN,m.r[0],int(bool(m.r[1])))
            if m.r[1] and p.join_writes:m.write(m.r[1],p.join_value)
            ret(p.join_rc)
        def duplicate(_):ev(E_DUP,2 if m.r[0]==R.NEW else 1);ret(R.NEW)
        def release(_):ev(E_FREE,2 if m.r[0]==R.NEW else 1);ret()
        def log(_):
            if p.no_log:ret();return
            line=m.r[3];sp=m.r[13];level=m.read(sp);a=b=0
            if line in (4997,5000,5005,1973,1976,5019,5022):ev(E_POWER_LOG,line,m.read(sp+8) if line in (1973,1976) else 0)
            elif line in (688,704,83,94,107,118,714):ev(E_SENSOR_LOG,line,m.read(sp+8),m.read(sp+12),m.read(sp+16) if line==83 else 0)
            else:
                if line in (6124,6157,1208,1811,451):a=m.read(sp+8)
                if line in (6157,1208,451):b=m.read(sp+12)
                ev(E_LOG,line,level,a,b)
            ret()
        hooks.update({0x1ed58:now,0x850000:config,0x850010:read,0x850020:write,0x850030:finish,KEY:key,0x108b40:register,0x56d18:stop,0xfe310:on,0x104134:voltage,0x5a55cc:create,0x5a5d2c:join,0x5a38a0:duplicate,0x593c8c:release,0xfa0c4:log})
        m.reset((B,));m.write(join_ptr,p.join_seed);rc=signed(m.run(0x70e30,hooks=hooks,max_steps=150000));self.steps+=m.steps
        resume_scratch=m.read(join_ptr);snapshots[0]=snapshot();phase_events[0]=len(events)
        if p.followup:
            in_stop=True
            def stop_scalar(_,e):
                arg=(m.r[0]-CHAINS)//800 if e in (0x58d08,0x5a9fc,0x5ac80) else m.r[0] if e in (0xf98b8,0xf9840) else 0
                ev(E_STEP,e,arg,0,0);ret(1 if e==0xfdeb4 else p.platform if e==0xfdfbc else 0)
            for e in (0xfdeb4,0x8291c,0x860b8,0xfdfbc,0xa6080,0x663cc,0x58d08,0x5a9fc,0x5ac80,0x1082b4,0x2f6ec,0xf98b8,0xf9840,0x5a6684,0x5a66c4):hooks[e]=lambda mm,e=e:stop_scalar(mm,e)
            def self_hook(_):ev(E_SELF);ret(p.self_handle)
            def cancel(_):ev(E_CANCEL,m.r[0]);ret(-5)
            def detach(_):ev(E_DETACH,m.r[0]);ret(-3)
            def off(_):ev(E_OFF);ret(p.off_rc)
            def reset(_):ev(E_RESET,(m.r[0]-CHAINS)//800);ret(-7)
            def marker(_):
                x=self.strings[m.r[0]]
                if x['text']!='/tmp/stopped':raise AssertionError('marker path')
                ev(E_MARK);ret(-1)
            hooks.update({0x5a6b20:self_hook,0x5a4754:cancel,0x5a5bb0:detach,0x102b04:off,0x55370:reset,0x10ee90:marker})
            for phase in range(1,3 if p.repeat_stop else 2):
                m.reset((B,));m.run(0x5fc54,hooks=hooks,max_steps=150000);self.steps+=m.steps
                snapshots[phase]=snapshot();phase_events[phase]=len(events)
        self.visited.update(m.visited);self.entries.update(m.entries)
        return rc,snapshots,phase_events,events

def witnesses():
    yield 'healthy',{}
    yield 'setup_rejected',{'fault_mask':1}
    yield 'setup_noncritical',{'fault_mask':0x15,'role':0}
    yield 'partial_creation',{'create_fail':2,'error_write':1}
    yield 'join_retained',{'join_flag':1,'join_seed':7,'join_writes':0,'join_rc':-5}
    yield 'join_written',{'join_flag':1,'join_value':0,'join_seed':7}
    yield 'selector_full_width',{'mode':258,'role':0,'fault_mask':0x15}
    yield 'late_zero_failure',{'fail_step':0xa20a0,'fail_rc':-3}
    yield 'recovery_branch',{'fail_step':0x644a8,'fail_rc':1}
    yield 'stop_policy_boundary',{'fail_step':0x644a8,'fail_rc':2}
    yield 'psu_on_failure',{'on_rc':-1}
    yield 'psu_set_failure',{'voltage_rc':-1}
    yield 'psu_off_failure',{'off_rc':-1}
    yield 'key_full_width',{'key':0xfedcba98}
    yield 'no_automatic_cleanup',{'fault_mask':1,'followup':0}
    yield 'no_thread_scheduling',{'scheduled':0}
    yield 'no_descriptors',{'kind':0,'present_mask':0}
    yield 'no_logs',{'no_log':1,'fault_mask':1}

def cases():
    yield from witnesses()
    for kind,role,mode,mask in itertools.product((1,2),(0,2),(0,2,258),(0,1,0x15)):
        yield 'sensor_modes',dict(kind=kind,role=role,mode=mode,fault_mask=mask)
    for fk,partial,suppress in itertools.product(range(1,6),(0,1),(0,1)):
        yield 'sensor_errors',dict(fault_kind=fk,fault_mask=1,partial=partial,suppress=suppress)
    for fail,err,writes,scheduled in itertools.product((1,2,3),(-11,1),(0,1),(0,1)):
        yield 'thread_errors',dict(create_fail=fail,create_rc=err,error_write=writes,scheduled=scheduled)
    for selector,platform,mode in itertools.product((4,6,7),(0,1,2),(0,1)):
        yield 'platforms',dict(selector=selector,platform=platform,mode=mode)
    for ep in (0x106e58,0x66504,0x6c61c,0x6c89c,0x6e734,0x6f1cc,0x6709c,0x6f8ac,0x6fae8,0x644a8,0x55400,0xa20a0):
        for rc in (-1,1,2):yield 'later_failures',dict(fail_step=ep,fail_rc=rc)
    for state in (0,1,4,5,6,0xffffffff):yield 'entry_state',dict(state=state)
    for flag,write,value,rc in itertools.product((1,255),(0,1),(0,7),(-5,0)):
        yield 'join',dict(join_flag=flag,join_writes=write,join_value=value,join_seed=9,join_rc=rc)
    for n,count,mask in itertools.product((-1,0,1,2),(-1,0,1,3),(0,7)):
        yield 'counts',dict(sensors=n,count=count,present_mask=mask)
    for self_value,off,board in itertools.product((999,0x60001044,0x6000101c),(0,-1),(0,1)):
        yield 'cleanup',dict(self_handle=self_value,off_rc=off,board_flag=board)

def staging_checks():
    """Exercise pinned-file rejection without editing any tracked source."""
    manifest=json.loads((ROOT/'integration/evidence/resume_temperature_135.json').read_text())
    tool=ROOT/'tools/prepare_resume_temperature_135.py'
    with tempfile.TemporaryDirectory(prefix='a12-stage-test-',dir=ROOT/'build') as tmp:
        root=Path(tmp);source=root/'source';out=root/'out'
        for item in manifest['dependencies']:
            path=Path(item['path']);target=source/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes((ROOT/'build/a12-deps'/path).read_bytes())
        def command(destination,check=False,expected=None):
            args=[sys.executable,str(tool),'--out',str(destination)]
            args+=['--check'] if check else ['--source-tree',str(source)]
            result=subprocess.run(args,cwd=ROOT,capture_output=True,text=True,timeout=20)
            if expected is None:
                if result.returncode or 'RESUME_TEMPERATURE_DEPENDENCIES_PASS 8' not in result.stdout:
                    raise RuntimeError(('staging baseline failed',result.stdout,result.stderr))
            elif result.returncode==0 or expected not in result.stderr:
                raise RuntimeError(('staging rejection missing',expected,result.returncode,result.stderr))
        command(out)
        command(out,check=True)
        first=Path(manifest['dependencies'][0]['path']);original=(source/first).read_bytes()
        (source/first).write_bytes(original+b'\n/* changed input */\n')
        command(root/'rejected-source',expected='dependency bytes mismatch')
        if (root/'rejected-source').exists():raise RuntimeError('output created before input validation')
        (source/first).write_bytes(original)
        altered=original+b'\n/* changed staged file */\n';(out/first).write_bytes(altered)
        command(out,check=True,expected='dependency bytes mismatch')
        command(out,expected='refusing changed existing dependency')
        if (out/first).read_bytes()!=altered:raise RuntimeError('changed output overwritten')
        command(ROOT/'build',expected='destination must be a child')
    print('RESUME_TEMPERATURE135_STAGING_TESTS_PASS cases=6')
    return 0

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library',nargs='?');ap.add_argument('--staging-checks',action='store_true');ap.add_argument('--summary');ap.add_argument('--witnesses',action='store_true');ap.add_argument('--limit',type=int)
    a=ap.parse_args()
    if a.staging_checks:return staging_checks()
    if not a.library:ap.error('library is required unless --staging-checks is set')
    native=Native(a.library);original=Original();counts=collections.Counter();events=0
    for n,(name,d) in enumerate(witnesses() if a.witnesses else cases()):
        if a.limit is not None and n>=a.limit:break
        p=native.case(d);expected=original.run(p);actual=native.run(p)
        if actual!=expected:
            print('SEMANTIC_MISMATCH',name,d)
            print('results',expected[0],actual[0],'phases',expected[2],actual[2])
            for i,(x,y) in enumerate(zip(expected[1],actual[1])):
                if x!=y:print('snapshot',i,[(j,u,v) for j,(u,v) in enumerate(zip(x,y)) if u!=v][:15],len(x),len(y))
            for i,(x,y) in enumerate(itertools.zip_longest(expected[3],actual[3])):
                if x!=y:print('event',i,x,y);break
            return 1
        counts[name]+=1;events+=len(actual[3])
    summary=dict(status='PASS',scenarios=sum(counts.values()),events=events,arm_steps=original.steps,instruction_addresses=len(original.visited),entries={hex(k):v for k,v in sorted(original.entries.items())},groups=dict(counts))
    if a.summary:Path(a.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('RESUME_TEMPERATURE135_ORIGINAL_PASS',json.dumps(summary));return 0
if __name__=='__main__':raise SystemExit(main())
