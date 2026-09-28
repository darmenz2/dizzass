#!/usr/bin/env python3
"""Compare original 5f0fc, nested power-stop and optional stop-policy callers.
Only the original instruction words run in the bounded interpreter. Thread,
I/O, low-level teardown, log and process effects are scripted at named edges.
"""
import argparse
import collections
import ctypes as C
import hashlib
import itertools
import json
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed
import test_backend_shutdown_135 as S
import test_stop_policy_135 as P

U, I, B = S.U, S.I, S.B
BASE, MODEL, CHAINS, FANS = S.BASE, S.MODEL, S.CHAINS, S.FANS
OFF = S.OFFSETS
INDIRECT = 0x850100
TEXT = 0x84c000
RANGES = ((0x5f0fc, 0x5fc1c), (0x6b778, 0x6b8c8),
          (0xa71dc, 0xa7218), (0x5fc54, 0x606c0),
          (0x5e92c, 0x5f044), (0x5cea8, 0x5cf20))
FIELDS = {'state': (0x20, U, 4), 'mode': (0x50, U, 4),
          'persistent_marker': (0xf4, B, 1), 'byte_fe6': (0xfe6, B, 1),
          'word_fe8': (0xfe8, U, 4), 'word_fec': (0xfec, U, 4)}
MODEL_FIELDS = {'chip': (0x88, U, 4), 'fans': (0xbc, I, 4),
                'boardflag': (0x87, B, 1)}
STEP_NOARG = (0xfdeb4, 0x8291c, 0x860b8, 0xfdfbc, 0xa6080, 0x663cc,
              0x287a4, 0x1082b4, 0x2f6ec)
STEP_CHAIN = (0x58d08, 0x5a9fc, 0x5ac80)

class Machine(ARM32Difficulty):
    def extra_instruction(self, word, pc):
        assert any(a <= pc < b for a, b in RANGES), ('unapproved instruction', hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(word, pc)

class ExitRequested(Exception):
    pass

def value(p, key, n, default=0):
    v = p.get(key, default)
    return v[min(n, len(v)-1)] if isinstance(v, list) else v

def setup(p):
    s, _ = S.make_state(p)
    fans = (I * 12)(*[i*37-111 for i in range(12)])
    s.fan_readings = None if p.get('nullfans') else fans
    for key in FIELDS:
        if key in p: setattr(s, key, p[key])
    s.board_byte_4f = p.get('boardflag', 1)
    s.power.byte_ff1 = p.get('powered', 1)
    s.power.word_20c = p.get('voltage', 13500)
    scratch = S.Scratch((U*2)(0x12345678, 0xaabbccdd), 0xdeadbeef)
    return s, fans, scratch

class Script:
    def __init__(self, p, snapshot, mutate):
        self.p, self.snapshot, self.mutate = p, snapshot, mutate
        self.events, self.calls = [], collections.Counter()
        self.persisted = p.get('attempts', 0)
    def call(self, name, *args):
        n = self.calls[name]; self.calls[name] += 1
        self.events.append((name, *args, self.snapshot(), self.persisted))
        for op, nth, field, v in self.p.get('mutations', []):
            if name == op and n == nth: self.mutate(field, v)
        defaults = {'self': 999, 'count': 3, 'ready': 1, 'chip': 4,
                    'indirect': 0x123400, 'read_open': 1, 'write_open': 2,
                    'scan': 1, 'print': 1, 'event': 2008, 'current': 1}
        rc = value(self.p.get('returns', {}), name, n, defaults.get(name, 0))
        if name == 'trylock' and n < self.p.get('lock_failures', 0): rc = -16
        if name == 'print' and rc >= 0: self.persisted = args[2]
        return rc

def step_name(ep):
    return {0xfdeb4:'ready', 0x8291c:'special', 0xfdfbc:'platform',
            0x19c:'indirect'}.get(ep, f'step_{ep:x}')

class Native:
    def __init__(self, lib):
        self.before = lib.vn135_backend_before_exit_135
        self.common = lib.vn135_backend_shutdown_135
        for f in (self.before, self.common):
            f.restype = None
            f.argtypes = [C.POINTER(S.State), C.POINTER(S.Ops), C.POINTER(S.PowerOps), S.P, C.POINTER(S.Scratch)]
        self.policy = lib.vn135_stop_policy_135
        self.policy.argtypes = [C.POINTER(P.State), C.POINTER(P.Ops), S.P]
        self.policy.restype = I
    def run(self, entry, p):
        s, fans, scratch = setup(p)
        callbacks, errors = [], []
        def snapshot():
            return (tuple(getattr(s,k) for k in FIELDS), s.model_chip_selector,
                    s.fan_count, s.board_byte_4f, bool(s.fan_readings),
                    tuple((t.handle,t.running) for t in s.threads),
                    (s.power.byte_ff1,s.power.word_20c),tuple(fans))
        def mutate(k,v):
            if k in FIELDS: setattr(s,k,v)
            elif k == 'chip': s.model_chip_selector = v
            elif k == 'fans': assert -2 <= v <= 12; s.fan_count = v
            elif k == 'boardflag': s.board_byte_4f = v
            elif k == 'powered': s.power.byte_ff1 = v
            elif k == 'voltage': s.power.word_20c = v
            elif k == 'nullfans': s.fan_readings = None if v else fans
            elif k == 'handle': s.threads[v[0]].handle = v[1]
            elif k == 'flag': s.threads[v[0]].running = v[1]
            else: raise ValueError(k)
        sc = Script(p, snapshot, mutate)
        def cb(ty,fn):
            def guarded(*args):
                try: return fn(*args)
                except BaseException as exc: errors.append(exc); return 0
            f = ty(guarded); callbacks.append(f); return f
        def join(_,handle,out):
            rc = sc.call('join',handle,bool(out))
            if out and p.get('write_join',True): out[0] = 0xbeef
            return rc
        def cleanup(_,buf,v):
            rc = sc.call('cleanup',v)
            if p.get('write_cleanup',True): buf[0]=123;buf[1]=456
            return rc
        o = S.Ops(cb(S.CB0,lambda _:sc.call('trylock')),cb(S.CB0,lambda _:sc.call('unlock')),
                  cb(S.DELAY,lambda _,v:sc.call('delay',v)),cb(S.SELF,lambda _:sc.call('self')),
                  cb(S.HANDLE,lambda _,v:sc.call('detach',v)),cb(S.HANDLE,lambda _,v:sc.call('cancel',v)),
                  cb(S.JOIN,join),cb(S.NAME,lambda _,s:sc.call('name',s.decode())),
                  cb(S.STEP,lambda _,ep,a:sc.call(step_name(ep),a)),cb(S.CLEAN,cleanup),
                  cb(S.NAME,lambda _,s:sc.call('marker',s.decode())),
                  cb(S.LOG,lambda _,line:sc.call('log',line)))
        power = S.PowerOps(cb(S.CB0,lambda _:sc.call('on')),cb(S.CB0,lambda _:sc.call('off')),
                  cb(S.SETV,lambda _,v:sc.call('voltage',v)),cb(S.CB0,lambda _:sc.call('count')),
                  cb(S.HANDLE,lambda _,i:sc.call('reset',i)),
                  cb(S.PLOG,lambda _,src,line,arg:sc.call('power_log',line,arg)))
        if p.get('nolog'): o.log = S.LOG(); power.log = S.PLOG()
        def teardown(fn): fn(C.byref(s),C.byref(o),C.byref(power),None,C.byref(scratch))
        # Minimal existing policy view: top-preset raising is disabled here;
        # its exhaustive field/profile behavior remains the preceding suite.
        h = P.H.State(); top = P.S(b'disabled' if p.get('disabled') else b'200')
        ps = P.State(C.pointer(h),C.pointer(top),b'300',0,p.get('limit',2),0,p.get('retune',1))
        record = P.H.Profile(b'200',b'scripted profile')
        open_modes = {}
        def count_open(_,path,mode):
            assert path == b'/tmp/restart_count' and mode in (b'rb',b'w')
            handle=sc.call('read_open' if mode==b'rb' else 'write_open',path.decode(),mode.decode())
            if handle: open_modes[handle]=mode
            return handle
        def scan(_,handle,fmt,out):
            assert open_modes[handle]==b'rb' and fmt==b'%d'
            rc=sc.call('scan',handle,fmt.decode(),out[0]);out[0]=sc.persisted
            return rc
        def printer(_,handle,fmt,v):
            assert open_modes[handle]==b'w' and fmt==b'%d'
            return sc.call('print',handle,fmt.decode(),v)
        def close(_,handle):
            return sc.call('read_close' if open_modes.pop(handle)==b'rb' else 'write_close',handle)
        counter=P.CounterOps(cb(P.OPEN,count_open),cb(P.SCAN,scan),cb(P.PRINT,printer),cb(P.CLOSE,close))
        def describe(_,out,n):
            assert n==512;rc=sc.call('describe');data=b'scripted event\0';C.memmove(out,data,len(data));return rc
        def current(_,ep,text):
            assert ep==0x82d68 and text is None
            return C.addressof(record) if sc.call('current') else 0
        def probe(_,key,out):
            assert tuple(out[:5])==(0,)*5
            return sc.call('probe',key.decode())
        po=P.Ops(cb(P.EVENT,lambda _:sc.call('event')),cb(P.PROFILE,current),
                 cb(P.ACTION,lambda _,ep,key:sc.call('action',ep,key.decode())),cb(P.DESCRIBE,describe),
                 cb(P.PROBE,probe),C.pointer(counter),cb(P.VOID,lambda _:teardown(self.before)),
                 cb(P.EXIT,lambda _,status:sc.call('exit',status)),cb(P.VOID,lambda _:teardown(self.common)),
                 cb(P.LOG,lambda _,l,lev,a,b,t:sc.call('policy_log',l,lev,a,b,t.decode())))
        if entry=='policy': flow=self.policy(C.byref(ps),C.byref(po),None)
        else: teardown(self.before if entry=='before' else self.common); flow=0
        if errors: raise errors[0]
        assert not open_modes
        return flow,snapshot(),sc.events,sc.persisted

class Original:
    def __init__(self,elf):
        self.elf=elf;self.m=Machine(elf);self.visited=set();self.steps=0
        self.strings={int(x['base'],16):x for x in json.loads((ROOT/'evidence/stage1/cgminer_xor_strings.json').read_text())}
        self.strings.update({0x5e50bb:{'xor':60,'length':3,'text':'%d'},
                             0x5e5250:{'xor':67,'length':9,'text':'disabled'}})
    def literal(self,a):
        x=self.strings[a];data=bytes(v^x['xor'] for v in self.elf.read(a,x['length']))
        assert data==x['text'].encode()+b'\0';return x['text']
    def run(self,entry,p):
        s,fans,_=setup(p);m=self.m;m.mem[BASE:BASE+0x10000]=bytes(0x10000);m.visited=set()
        for k,(off,_,n) in FIELDS.items():m.write(BASE+off,getattr(s,k),n)
        for off,v in ((0x18,MODEL),(0x230,CHAINS),(0x238,0 if p.get('nullfans') else FANS),
                      (0x19c,INDIRECT),(0x20c,s.power.word_20c)):m.write(BASE+off,v)
        m.write(BASE+0xff1,s.power.byte_ff1,1)
        for k,(off,_,n) in MODEL_FIELDS.items():
            m.write(MODEL+off,{'chip':s.model_chip_selector,'fans':s.fan_count,'boardflag':s.board_byte_4f}[k],n)
        for i,off in enumerate(OFF):m.write(BASE+off,s.threads[i].handle);m.write(BASE+off+4,s.threads[i].running,1)
        for i,v in enumerate(fans):m.write(FANS+i*36+0x20,v)
        def snapshot():
            return (tuple(m.read(BASE+off,n) for off,_,n in FIELDS.values()),m.read(MODEL+0x88),
                    signed(m.read(MODEL+0xbc)),m.read(MODEL+0x87,1),bool(m.read(BASE+0x238)),
                    tuple((m.read(BASE+off),m.read(BASE+off+4,1)) for off in OFF),
                    (m.read(BASE+0xff1,1),m.read(BASE+0x20c)),tuple(signed(m.read(FANS+i*36+0x20)) for i in range(12)))
        def mutate(k,v):
            if k in FIELDS:off,_,n=FIELDS[k];m.write(BASE+off,v,n)
            elif k in MODEL_FIELDS:off,_,n=MODEL_FIELDS[k];m.write(MODEL+off,v,n)
            elif k=='powered':m.write(BASE+0xff1,v,1)
            elif k=='voltage':m.write(BASE+0x20c,v)
            elif k=='nullfans':m.write(BASE+0x238,0 if v else FANS)
            elif k=='handle':m.write(BASE+OFF[v[0]],v[1])
            elif k=='flag':m.write(BASE+OFF[v[0]]+4,v[1],1)
            else:raise ValueError(k)
        sc=Script(p,snapshot,mutate)
        def ret(v=0):m.r[0]=int(v)&0xffffffff
        def call(name,arg=None,backend=False):
            def f(_):
                if backend:assert m.r[0]==BASE
                ret(sc.call(name,*(() if arg is None else arg())))
            return f
        def clean(_):
            assert m.r[2]==m.r[3]==0
            out=m.r[0];rc=sc.call('cleanup',m.r[1])
            if p.get('write_cleanup',True):m.write(out,123);m.write(out+4,456)
            ret(rc)
        def join(_):
            out=m.r[1];rc=sc.call('join',m.r[0],bool(out))
            if out and p.get('write_join',True):m.write(out,0xbeef)
            ret(rc)
        def log(_):
            line=m.r[3];sp=m.r[13]
            if line in (6420,6504):
                assert m.read(sp)==3
                expected='Shutting down the miner'
                assert self.literal(m.read(sp+4))==expected,(line,self.literal(m.read(sp+4)))
                if not p.get('nolog'):ret(sc.call('log',line))
            elif line in (5019,5022):
                if not p.get('nolog'):ret(sc.call('power_log',line,0))
            else:
                assert line in (2123,2139),line
                a=b=0
                if line==2123:a=m.read(sp+8);b=m.read(sp+12);detail=text(m.read(sp+16))
                else:detail=text(m.read(sp+8))
                ret(sc.call('policy_log',line,m.read(sp),a,b,detail))
        hooks={0x5a6684:call('trylock',backend=True),0x5a66c4:call('unlock',backend=True),
               0x10ef3c:call('delay',lambda:(m.r[0],)),0x5a6b20:call('self'),
               0x5a5bb0:call('detach',lambda:(m.r[0],)),0x5a4754:call('cancel',lambda:(m.r[0],)),
               0x5a5d2c:join,0x108b40:clean,0xfe668:call('count'),
               0x102b04:call('off'),0x55370:call('reset',lambda:((m.r[0]-CHAINS)//800,)),
               0xfa0c4:log,INDIRECT:call('indirect',lambda:(0,)),
               0x10ee90:call('marker',lambda:(self.literal(m.r[0]),))}
        for ep in STEP_NOARG:hooks[ep]=call(step_name(ep),lambda:(0,),ep in (0xa6080,0x663cc))
        for ep in STEP_CHAIN:
            hooks[ep]=call(step_name(ep),lambda:((m.r[0]-CHAINS)//800,))
        for ep in (0xf98b8,0xf9840):hooks[ep]=call(step_name(ep),lambda:(m.r[0],))
        def text(addr):
            if not addr:return None
            end=m.mem.find(0,addr,addr+513);assert end>=addr
            m.check(addr,end-addr+1);return m.mem[addr:end].decode()
        def put(a,t):m.mem[a:a+len(t)+1]=t.encode()+b'\0';return a
        m.write(BASE+0x88,p.get('limit',2));m.write(BASE+0x104,p.get('retune',1),1)
        m.write(BASE+0x90,put(TEXT,'disabled' if p.get('disabled') else '200'))
        m.write(TEXT+0x100,put(TEXT+0x200,'200'));m.write(TEXT+0x104,put(TEXT+0x240,'scripted profile'))
        open_modes={}
        def count_open(_):
            path,mode=self.literal(m.r[0]),self.literal(m.r[1]);assert path=='/tmp/restart_count' and mode in ('rb','w')
            handle=sc.call('read_open' if mode=='rb' else 'write_open',path,mode)
            if handle:open_modes[handle]=mode
            ret(handle)
        def scan(_):
            assert open_modes[m.r[0]]=='rb' and self.literal(m.r[1])=='%d'
            out=m.r[2];rc=sc.call('scan',m.r[0],'%d',signed(m.read(out)));m.write(out,sc.persisted);ret(rc)
        def printer(_):
            assert open_modes[m.r[0]]=='w' and self.literal(m.r[1])=='%d'
            ret(sc.call('print',m.r[0],'%d',signed(m.r[2])))
        def close(_):ret(sc.call('read_close' if open_modes.pop(m.r[0])=='rb' else 'write_close',m.r[0]))
        def describe(_):
            assert m.r[0]==BASE+0x10b4 and m.r[2]==512
            out=m.r[1];rc=sc.call('describe');put(out,'scripted event');ret(rc)
        def current(_):assert m.r[0]==BASE;ret(TEXT+0x100 if sc.call('current') else 0)
        def probe(_):
            assert m.r[0]==BASE and all(m.read(m.r[2]+i*4)==0 for i in range(5))
            ret(sc.call('probe',text(m.r[1])))
        def memset(_):
            assert m.r[1]==0 and m.r[2]==512;m.check(m.r[0],512);m.mem[m.r[0]:m.r[0]+512]=bytes(512)
        def strcmp(_):a=text(m.r[0]);b=self.literal(m.r[1]);ret((a>b)-(a<b))
        def end(_):assert m.r[0]==0;sc.call('exit',0);raise ExitRequested
        hooks.update({0x49e94:call('event'),0x59e5b0:count_open,0x59e958:scan,
                      0x59e658:printer,0x59e084:close,0x49bd8:describe,
                      0x82d68:current,0x83080:probe,0x5a348c:memset,0x5a375c:strcmp,
                      0x94090:call('action',lambda:(0x94090,text(m.r[0]))),0x10110:end})
        m.reset((BASE,));flow=0
        try:m.run({'before':0x5f0fc,'policy':0x5e92c,'common':0x5fc54}[entry],hooks=hooks,max_steps=150000)
        except ExitRequested:flow=1
        self.visited|=m.visited;self.steps+=m.steps
        assert not open_modes
        return flow,snapshot(),sc.events,sc.persisted

def cases(quick=False):
    yield 'before','baseline',{}
    yield 'policy','nested_retry',{}
    yield 'policy','nested_common',{'limit':0}
    yield 'policy','nested_retune',{'limit':-1,'attempts':3}
    if quick:return
    yield 'before','optional_log',{'nolog':1}
    yield 'before','optional_log',{'nolog':1,'returns':{'off':-1}}
    for state,ready,mode in itertools.product((0,1,2,3,4,5,6,7,0x80000000,0xffffffff),(0,1,0xffffffff),(0,2,3)):
        yield 'before','entry_gates',dict(state=state,mode=mode,returns={'ready':ready})
    for mask in range(1024):
        yield 'before','thread_masks',dict(flags=[(mask>>i)&1 for i in range(10)])
    for slot in range(10):
        for selfid,flag in itertools.product((100+slot,999),(0,1,255)):
            flags=[0]*10;flags[slot]=flag
            yield 'before','thread_identity',dict(flags=flags,returns={'self':selfid})
    for chip,platform,board in itertools.product((0,4,5,6,7,8,0xffffffff),(-1,0,1,2,3,4,5),(0,1,255)):
        yield 'before','model_gates',dict(chip=chip,boardflag=board,returns={'platform':platform})
    for n,mode,null in itertools.product((-2,0,1,2,4,12),(0,1,2,0xffffffff),(0,1)):
        yield 'before','fan_gates',dict(fans=n,mode=mode,nullfans=null)
    for counts,board,off in itertools.product(([0],[-1],[3],[1,0,2],[0,2,1],[3,1,2]),(0,1),(-7,0,1)):
        yield 'before','counts_and_power',dict(boardflag=board,returns={'count':counts,'off':off})
    baseline=Original.ACTIVE_BASELINE
    # Every externally observable edge is independently failed and used as a
    # mutation boundary. This never changes the oracle or its branch outcomes.
    edge_counts=collections.Counter(e[0] for e in baseline[2])
    for name,n in edge_counts.items():
        if name in ('log','power_log'):continue
        for rc in (-1,1,0x7fffffff):
            if name=='trylock':continue
            if name=='count':rc=min(rc,5)
            yield 'before','effect_errors',{'returns':{name:rc}}
        for occurrence in range(n):
            for k,v in [('state',6),('boardflag',0),('boardflag',1),('mode',2),('fans',1),('chip',6),('powered',0),('voltage',0xabcdef01)]:
                yield 'before','edge_mutations',{'mutations':[(name,occurrence,k,v)]}
    for slot in range(9):
        flags=[0]*10;flags[slot]=1
        for op,field,v in [('self','handle',(slot,999)),('cancel','handle',(slot,4242)),
                           ('join','flag',(slot,1)),('self','flag',(8,1))]:
            yield 'before','handle_rereads',dict(flags=flags,mutations=[(op,0,field,v)])
    for failures in (1,2,17):
        yield 'before','lock_wait',dict(lock_failures=failures)
        yield 'before','state_after_lock',dict(lock_failures=failures,mutations=[('delay',0,'state',4)])
    for rc in (0,1):
        yield 'before','ready_reread',dict(state=0,returns={'ready':rc},mutations=[('ready',0,'state',2)])
        yield 'before','ready_reread',dict(state=2,returns={'ready':rc},mutations=[('ready',0,'state',0)])
    for limit,attempts,event,retune in itertools.product((-1,0,1,2),(0,1,2,3),(2007,2008),(0,1)):
        yield 'policy','nested_paths',dict(limit=limit,attempts=attempts,retune=retune,returns={'event':event})
    for state,board,off in itertools.product((0,2,4,6),(0,1),(-1,0)):
        for extra in ({},{'limit':0},{'limit':-1},{'disabled':1,'limit':-1}):
            yield 'policy','nested_teardown',dict(state=state,boardflag=board,returns={'off':off},**extra)
    rng=random.Random(0x5f0fc)
    for _ in range(300):
        yield 'before','mixed',dict(state=rng.randrange(8),chip=rng.randrange(9),mode=rng.randrange(4),
             flags=[rng.choice([0,1,255]) for _ in range(10)],boardflag=rng.randrange(2),fans=rng.randrange(7),
             nullfans=rng.randrange(2),lock_failures=rng.randrange(4),powered=rng.randrange(2),
             returns={'self':rng.randrange(98,112),'platform':rng.randrange(6),'special':rng.randrange(2),
                      'ready':rng.randrange(2),'off':rng.choice([0,0,-1]),'count':[rng.randrange(6) for _ in range(3)]})

def main():
    ap=argparse.ArgumentParser();ap.add_argument('library');ap.add_argument('--summary');ap.add_argument('--quick',action='store_true')
    args=ap.parse_args();elf=ELF32(ROOT/'reference/cgminer.vendor.elf');assert hashlib.sha256(elf.data).hexdigest()==S.HASH
    lib=C.CDLL(str(Path(args.library).resolve()));native=Native(lib);original=Original(elf)
    Original.ACTIVE_BASELINE=original.run('before',{})
    original.steps=0;original.visited=set()
    counts=collections.Counter();events=0
    for entry,group,p in cases(args.quick):
        a=original.run(entry,p);c=native.run(entry,p)
        if a!=c:
            print('MISMATCH',entry,group,p)
            for i,(x,y) in enumerate(itertools.zip_longest(a[2],c[2])):
                if x!=y:print('event',i,'original',x,'native',y);break
            print('final',a[:2],c[:2]);raise AssertionError('original/native mismatch')
        counts[group]+=1;events+=len(a[2])
    summary={'cases':sum(counts.values()),'groups':dict(counts),'events':events,'steps':original.steps,
             'visited_addresses':len(original.visited),'reference_sha256':S.HASH,
             'original_5f0fc':True,'nested_original_5e92c_and_power_stop':True,'new_arm_opcodes':0,
             'thread_effects':'scripted','file_io':False,'process_exit':False,'physical_off_verified':False}
    if args.summary:Path(args.summary).write_text(json.dumps(summary,indent=2)+'\n')
    print('EXIT_CLEANUP135_ORIGINAL_PASS',json.dumps(summary,sort_keys=True))
if __name__=='__main__':main()
