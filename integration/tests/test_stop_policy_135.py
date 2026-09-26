#!/usr/bin/env python3
"""Compare unchanged A32 stop-policy/counter bodies and nested 60730 with C.
Missing profile, event, file and process effects are explicit bounded scripts.
The original exit call terminates interpretation; it is never allowed to return.
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
import test_monitor_handlers_135 as H

I, U, B, P, S = C.c_int32, C.c_uint32, C.c_uint8, C.c_void_p, C.c_char_p
BASE, MODEL, CHAINS, TABLE, TEXT = H.BASE, H.MODEL, H.CHAINS, H.TABLE, H.TEXT
FIELDS = {'word_30': (0x30, U, 4), 'retry_limit_88': (0x88, I, 4),
          'raise_failed_c8': (0xc8, B, 1), 'retune_104': (0x104, B, 1)}
class State(C.Structure):
    _fields_ = [('handlers', C.POINTER(H.State)), ('top_preset_90', C.POINTER(S)),
                ('text_3c', S)] + [(k, t) for k, (_, t, _) in FIELDS.items()]
OPEN = C.CFUNCTYPE(P, P, S, S)
SCAN = C.CFUNCTYPE(I, P, P, S, C.POINTER(I))
PRINT = C.CFUNCTYPE(I, P, P, S, I)
CLOSE = C.CFUNCTYPE(I, P, P)
class CounterOps(C.Structure):
    _fields_ = [('open', OPEN), ('scan', SCAN), ('print', PRINT), ('close', CLOSE)]
EVENT = C.CFUNCTYPE(U, P)
PROFILE = C.CFUNCTYPE(P, P, U, S)
ACTION = C.CFUNCTYPE(I, P, U, S)
DESCRIBE = C.CFUNCTYPE(I, P, P, C.c_size_t)
PROBE = C.CFUNCTYPE(I, P, S, C.POINTER(U))
VOID = C.CFUNCTYPE(None, P)
EXIT = C.CFUNCTYPE(None, P, U)
LOG = C.CFUNCTYPE(None, P, U, U, U, U, S)
class Ops(C.Structure):
    _fields_ = [('event', EVENT), ('profile', PROFILE), ('action', ACTION),
                ('describe', DESCRIBE), ('probe', PROBE),
                ('counter', C.POINTER(CounterOps)), ('before_exit', VOID),
                ('exit', EXIT), ('shutdown', VOID), ('log', LOG)]
RANGES = ((0x5e92c, 0x5f044), (0x5cea8, 0x5cf20), (0x5a24d4, 0x5a2544)) + H.RANGES[:2] + H.RANGES[4:8]
ENTRIES = {'policy': 0x5e92c, 'counter': 0x5cea8, 'check': 0x60730}
LOGS = {2113: 0x5e5200, 2114: 0x5e521b, 2123: 0x5e5235, 2139: 0x5e5259,
        **{k: H.LOGS[k] for k in (2167, 2173, 445, 451)}}

class Machine(ARM32Difficulty):
    def extra_instruction(self, word, pc):
        assert any(a <= pc < b for a, b in RANGES), ('unapproved instruction', hex(pc))
        self.visited.add(pc)
        return super().extra_instruction(word, pc)
class ProcessExit(Exception):
    pass

def pick(p, key, n, default):
    value = p.get(key, default)
    return value[min(n, len(value)-1)] if isinstance(value, list) else value

def setup(p):
    handler, keep = H.setup(p)
    top = S(H.enc(p.get('top', '200')))
    state = State(C.pointer(handler), C.pointer(top), H.enc(p.get('text_3c', '300')),
                  p.get('word_30', 1), p.get('retry_limit_88', 2),
                  p.get('raise_failed_c8', 1), p.get('retune_104', 1))
    handler.minimum_enabled_b0 = p.get('minimum_enabled_b0', 1)
    return state, handler, top, keep

class Script:
    def __init__(self, p, mutate, snapshot):
        self.p, self.mutate, self.snapshot = p, mutate, snapshot
        self.events, self.calls = [], collections.Counter()
        self.persisted = p.get('attempts', 0)
        self.current_event = p.get('event_code', 2008)
    def call(self, name, *args):
        n = self.calls[name]
        self.calls[name] += 1
        self.events.append((name, *args, self.snapshot(), self.persisted, self.current_event))
        if name == 'event': self.current_event = args[0]
        for op, nth, key, value in self.p.get('mutations', []):
            if name == op and nth == n:
                if key == 'event_code': self.current_event = value
                elif key == 'persisted': self.persisted = value
                else: self.mutate(key, value)
        defaults = {'event_code': self.current_event, 'select': 2, 'current': 1,
                    'read_open': 1, 'write_open': 2, 'scan': 1, 'print': 1,
                    'count': self.p.get('count', 3)}
        rc = pick(self.p.get('returns', {}), name, n, defaults.get(name, 0))
        if name == 'print' and self.p.get('persist_writes') and rc >= 0:
            self.persisted = args[2]
        if name == 'shutdown' and self.p.get('stop_mutates'):
            self.mutate('state', 6)
            self.mutate('running', 0)
        return rc
    def read_value(self, n):
        return pick(self.p, 'scan_value', n, self.persisted)
    def description(self, n):
        return pick(self.p, 'description', n, 'scripted event')

def normalize_profile(index, n):
    assert -1 <= index < n
    return index

class Native:
    def __init__(self, lib):
        self.policy = lib.vn135_stop_policy_135
        self.policy.argtypes = [C.POINTER(State), C.POINTER(Ops), P]
        self.policy.restype = I
        self.writer = lib.vn135_restart_count_store_135
        self.writer.argtypes = [C.POINTER(CounterOps), P, I]
        self.writer.restype = None
        self.check = lib.vn135_test_stop_chain_composed_135
        self.check.argtypes = [C.POINTER(State), C.POINTER(Ops), C.POINTER(H.Ops), P]
        self.check.restype = I
    def run(self, entry, p):
        state, h, top, keep = setup(p)
        g, model, _, chains, _, _, _, _, power, records, _ = keep
        callbacks, strings, errors, open_modes, scan_pointers = [], [], [], {}, {}
        def snapshot():
            return (tuple(getattr(state,k) for k in FIELDS), h.minimum_enabled_b0,
                    H.text(state.text_3c), H.text(top.value),
                    tuple((H.text(x.key),H.text(x.label)) for x in records),
                    tuple(getattr(g,k) for k in ('state','mode','running','active')),
                    h.minimum_chains_f8, h.partial_chains_105, model.query_fault_87,
                    tuple((c.thermal.state,c.thermal.present) for c in chains))
        def mutation(k,v):
            if k in FIELDS: setattr(state,k,v)
            elif k in ('minimum_enabled_b0','minimum_chains_f8','partial_chains_105'): setattr(h,k,v)
            elif k == 'query_fault_87': model.query_fault_87 = v
            elif k in ('state','mode','running','active'): setattr(g,k,v)
            elif k == 'chain_state': chains[v[0]].thermal.state = v[1]
            elif k == 'chain_present': chains[v[0]].thermal.present = v[1]
            elif k in ('top','text_3c'):
                strings.append(H.enc(v))
                if k == 'top': top.value = strings[-1]
                else: state.text_3c = strings[-1]
            elif k in ('profile_key','profile_label'):
                strings.append(H.enc(v[1]));setattr(records[v[0]],k[8:],strings[-1])
            else: raise ValueError(k)
        sc = Script(p, mutation, snapshot)
        def callback(ty, fn):
            def guarded(*args):
                try: return fn(*args)
                except BaseException as exc: errors.append(exc); return 0
            cb = ty(guarded);callbacks.append(cb);return cb
        def profile(_, ep, text):
            assert ep in (0x82ee8,0x82d68)
            name = 'select' if ep == 0x82ee8 else 'current'
            index = normalize_profile(sc.call(name,H.text(text)),len(records))
            return 0 if index == -1 else C.addressof(records[index])
        def describe(_, out, n):
            assert n == 512
            nth = sc.calls['describe']
            rc = sc.call('describe',bytes(C.string_at(out,n)))
            value = sc.description(nth)
            if value is not None:
                data = value.encode()+b'\0';assert len(data)<=n;C.memmove(out,data,len(data))
            return rc
        def probe(_, key, out):
            rc = sc.call('probe',H.text(key),tuple(out[i] for i in range(5)))
            for i,v in enumerate(p.get('probe_words',[0x123,0,456,0xdead,0])): out[i]=v
            return rc
        def count_open(_, path, mode):
            assert path == b'/tmp/restart_count' and mode in (b'rb',b'w')
            name = 'read_open' if mode == b'rb' else 'write_open'
            handle = sc.call(name,H.text(path),H.text(mode))
            if handle: assert handle not in open_modes;open_modes[handle]=mode
            return handle
        def scan(_, handle, fmt, out):
            assert open_modes[handle] == b'rb' and fmt == b'%d'
            n = sc.calls['scan'];rc = sc.call('scan',handle,H.text(fmt),out[0]);v=sc.read_value(n)
            if v is not None: out[0] = v
            scan_pointers[handle] = out
            return rc
        def count_print(_, handle, fmt, value):
            assert open_modes[handle] == b'w' and fmt == b'%d'
            return sc.call('print',handle,H.text(fmt),value)
        def close(_, handle):
            mode = open_modes.pop(handle)
            name = 'read_close' if mode == b'rb' else 'write_close'
            rc = sc.call(name,handle)
            if handle in scan_pointers:
                pointer=scan_pointers.pop(handle)
                if 'close_value' in p: pointer[0] = p['close_value']
            return rc
        counter = CounterOps(callback(OPEN,count_open),callback(SCAN,scan),
                             callback(PRINT,count_print),callback(CLOSE,close))
        ops = Ops(callback(EVENT,lambda _:sc.call('event_code')), callback(PROFILE,profile),
                  callback(ACTION,lambda _,ep,key:sc.call('action',ep,H.text(key))),
                  callback(DESCRIBE,describe),callback(PROBE,probe),C.pointer(counter),
                  callback(VOID,lambda _:sc.call('before_exit')),
                  callback(EXIT,lambda _,value:sc.call('exit',value)),
                  callback(VOID,lambda _:sc.call('shutdown')),
                  callback(LOG,lambda _,l,lev,a,b,s:sc.call('log',l,lev,a,b,H.text(s))))
        def hcall(_,ep,a,b):
            assert ep in (0xfe668,0x49c98)
            return sc.call('count') if ep == 0xfe668 else sc.call('event',a)
        hops = H.Ops();hops.call=callback(H.CALL,hcall)
        hops.log=callback(H.LOG,lambda _,l,lev,a,b,s:sc.call('log',l,lev,a,b,H.text(s)))
        result=[]
        for _ in range(p.get('laps',1)):
            if entry == 'counter': self.writer(C.byref(counter),None,p.get('store_value',3));flow=0
            elif entry == 'check': flow=self.check(C.byref(state),C.byref(ops),C.byref(hops),None)
            else: flow=self.policy(C.byref(state),C.byref(ops),None)
            result.append(flow)
        if errors: raise errors[0]
        assert not open_modes and not scan_pointers
        return result,snapshot(),sc.events,sc.persisted

class Original:
    def __init__(self,elf):
        self.elf=elf;self.m=Machine(elf);self.steps=0;self.visited=set();self.opcodes=set()
        strings=json.loads((ROOT/'evidence/stage1/cgminer_xor_strings.json').read_text())
        self.literals={int(x['base'],16):x for x in strings}
        # Short shared format omitted by the historical string catalog.
        self.literals[0x5e50bb]={'xor':60,'length':3,'text':'%d'}
        self.literals[0x5e5250]={'xor':67,'length':9,'text':'disabled'}
    def literal(self,a):
        x=self.literals[a];data=bytes(v^x['xor'] for v in self.elf.read(a,x['length']))
        assert data==x['text'].encode()+b'\0'
        return x['text']
    def run(self,entry,p):
        s,h,top,keep=setup(p);g,model,_,chains,_,_,_,_,power,records,_=keep;m=self.m
        m.mem[BASE:BASE+0x10000]=bytes(0x10000);m.visited=set();next_text=[TEXT]
        def puttext(value):
            if value is None:return 0
            data=value.encode()+b'\0';a=next_text[0];next_text[0]+=len(data)+8
            assert next_text[0]<BASE+0x10000;m.mem[a:a+len(data)]=data;return a
        def text(a):
            if not a:return None
            end=m.mem.find(0,a,a+513);assert end>=a,('unterminated',hex(a));m.check(a,end-a+1)
            return m.mem[a:end].decode()
        for k,(off,_,n) in FIELDS.items():m.write(BASE+off,getattr(s,k),n)
        m.write(BASE+0xb0,h.minimum_enabled_b0,1);m.write(BASE+0x3c,puttext(H.text(s.text_3c)))
        m.write(BASE+0x90,puttext(H.text(top.value)));m.write(BASE+0x18,MODEL);m.write(BASE+0x230,CHAINS)
        for k in ('state','mode','running','active'):
            off,n=H.G.OFF[k];m.write(BASE+off,getattr(g,k),n)
        m.write(BASE+0xf8,h.minimum_chains_f8);m.write(BASE+0x105,h.partial_chains_105,1)
        m.write(MODEL+0x87,model.query_fault_87,1)
        for i,c in enumerate(chains):m.write(CHAINS+i*800+0x20,c.thermal.state);m.write(CHAINS+i*800+0x24,c.thermal.present,1)
        for i,r in enumerate(records):m.write(TABLE+i*24,puttext(H.text(r.key)));m.write(TABLE+i*24+4,puttext(H.text(r.label)))
        def snapshot():
            return (tuple(signed(m.read(BASE+off,n)) if ty==I else m.read(BASE+off,n) for off,ty,n in FIELDS.values()),
                    m.read(BASE+0xb0,1),text(m.read(BASE+0x3c)),text(m.read(BASE+0x90)),
                    tuple((text(m.read(TABLE+i*24)),text(m.read(TABLE+i*24+4))) for i in range(len(records))),
                    tuple(m.read(BASE+H.G.OFF[k][0],H.G.OFF[k][1]) for k in ('state','mode','running','active')),
                    signed(m.read(BASE+0xf8)),m.read(BASE+0x105,1),m.read(MODEL+0x87,1),
                    tuple((m.read(CHAINS+i*800+0x20),m.read(CHAINS+i*800+0x24,1)) for i in range(3)))
        def mutation(k,v):
            if k in FIELDS: off,_,n=FIELDS[k];m.write(BASE+off,v,n)
            elif k in ('minimum_enabled_b0','minimum_chains_f8','partial_chains_105'):
                off,_,n=H.HF[k];m.write(BASE+off,v,n)
            elif k=='query_fault_87':m.write(MODEL+0x87,v,1)
            elif k in ('state','mode','running','active'):off,n=H.G.OFF[k];m.write(BASE+off,v,n)
            elif k=='chain_state':m.write(CHAINS+v[0]*800+0x20,v[1])
            elif k=='chain_present':m.write(CHAINS+v[0]*800+0x24,v[1],1)
            elif k in ('top','text_3c'):m.write(BASE+(0x90 if k=='top' else 0x3c),puttext(v))
            elif k in ('profile_key','profile_label'):m.write(TABLE+v[0]*24+(4 if k=='profile_label' else 0),puttext(v[1]))
            else:raise ValueError(k)
        sc=Script(p,mutation,snapshot);open_modes={};scan_pointers={}
        def ret(v=0):m.r[0]=int(v)&0xffffffff
        def event(_):assert m.r[0]==BASE+0x10b4;ret(sc.call('event_code'))
        def select(ep):
            def f(_):
                assert m.r[0]==BASE
                name='select' if ep==0x82ee8 else 'current'
                index=normalize_profile(sc.call(name,text(m.r[1]) if name=='select' else None),len(records))
                ret(0 if index==-1 else TABLE+index*24)
            return f
        def action(ep):
            def f(_):ret(sc.call('action',ep,text(m.r[0])))
            return f
        def describe(_):
            assert m.r[0]==BASE+0x10b4 and m.r[2]==512
            out=m.r[1];n=sc.calls['describe'];rc=sc.call('describe',bytes(m.mem[out:out+512]));value=sc.description(n)
            if value is not None:
                data=value.encode()+b'\0';assert len(data)<=512;m.mem[out:out+len(data)]=data
            ret(rc)
        def probe(_):
            assert m.r[0]==BASE;out=m.r[2]
            rc=sc.call('probe',text(m.r[1]),tuple(m.read(out+i*4) for i in range(5)))
            for i,v in enumerate(p.get('probe_words',[0x123,0,456,0xdead,0])):m.write(out+i*4,v)
            ret(rc)
        def count_open(_):
            path,mode=self.literal(m.r[0]),self.literal(m.r[1])
            assert path=='/tmp/restart_count' and mode in ('rb','w')
            handle=sc.call('read_open' if mode=='rb' else 'write_open',path,mode)
            if handle:assert handle not in open_modes;open_modes[handle]=mode
            ret(handle)
        def scan(_):
            handle,out=m.r[0],m.r[2];fmt=self.literal(m.r[1]);assert fmt=='%d' and open_modes[handle]=='rb'
            n=sc.calls['scan'];rc=sc.call('scan',handle,fmt,signed(m.read(out)));value=sc.read_value(n)
            if value is not None:m.write(out,value)
            scan_pointers[handle]=out;ret(rc)
        def count_print(_):
            handle=m.r[0];fmt=self.literal(m.r[1]);assert fmt=='%d' and open_modes[handle]=='w'
            ret(sc.call('print',handle,fmt,signed(m.r[2])))
        def close(_):
            handle=m.r[0];mode=open_modes.pop(handle);rc=sc.call('read_close' if mode=='rb' else 'write_close',handle)
            if handle in scan_pointers:
                out=scan_pointers.pop(handle)
                if 'close_value' in p:m.write(out,p['close_value'])
            ret(rc)
        def memset(_):
            assert m.r[1]==0 and m.r[2]==512;m.check(m.r[0],512)
            m.mem[m.r[0]:m.r[0]+512]=bytes(512)
        def compare(_):
            a=text(m.r[0]);b=self.literal(m.r[1]);assert a is not None and b=='disabled'
            ret((a>b)-(a<b))
        def log(_):
            line=m.r[3];sp=m.r[13];assert m.r[2]==0x5e50e3 if line in (2113,2114,2123,2139) else m.r[2] in (0x5e50be,0x5e50e3)
            assert m.read(sp+4)==LOGS[line],(line,hex(m.read(sp+4)))
            a=b=0;detail=None
            if line==2123:a,b=m.read(sp+8),m.read(sp+12);detail=text(m.read(sp+16))
            elif line in (2113,2114,2139):detail=text(m.read(sp+8))
            elif line==451:a,b=m.read(sp+8),m.read(sp+12)
            ret(sc.call('log',line,m.read(sp),a,b,detail))
        def before(_):assert m.r[0]==BASE;ret(sc.call('before_exit'))
        def end(_):assert m.r[0]==0;sc.call('exit',m.r[0]);raise ProcessExit
        def shutdown(_):assert m.r[0]==BASE;ret(sc.call('shutdown'))
        def chain_event(_):assert m.r[0]==BASE+0x10b4;ret(sc.call('event',m.r[1]))
        hooks={0x49e94:event,0x82ee8:select(0x82ee8),0x82d68:select(0x82d68),
               0x4dedc:action(0x4dedc),0x94090:action(0x94090),0x49bd8:describe,
               0x83080:probe,0x59e5b0:count_open,0x59e958:scan,0x59e658:count_print,
               0x59e084:close,0x5a348c:memset,0x5a375c:compare,0xfa0c4:log,
               0x5f0fc:before,0x10110:end,0x5fc54:shutdown,
               0xfe668:lambda _:ret(sc.call('count')),0x49c98:chain_event}
        result=[]
        for _ in range(p.get('laps',1)):
            m.reset((p.get('store_value',3) if entry=='counter' else BASE,));flow=0
            try:m.run(ENTRIES[entry],hooks=hooks,max_steps=50000)
            except ProcessExit:flow=1
            result.append(flow);self.steps+=m.steps
        assert not open_modes and not scan_pointers
        self.visited|=m.visited;self.opcodes|={m.read(x) for x in m.visited}
        return result,snapshot(),sc.events,sc.persisted

def cases():
    for entry in ENTRIES:yield entry,'baseline',{}
    for b0,c8,word,record in itertools.product((0,1,255),(0,1,255),(0,1,2,0xffffffff),(-1,0,1,2,3)):
        yield 'policy','profile_gates',dict(minimum_enabled_b0=b0,raise_failed_c8=c8,word_30=word,returns={'select':record})
    numeric=('100','200','300','2147483647','-2147483648',' +009tail',' \t-10.0','abc','0','-1')
    for key,top in itertools.product(numeric,numeric):
        yield 'policy','atoi_bounds',dict(profiles=((key,'Selected'),),top=top,returns={'select':0,'current':0})
    for limit,attempt,code,retune in itertools.product((-2147483648,-1,0,1,2,3,2147483647),(-2147483648,-1,0,1,2,3,2147483646,2147483647),(0,2007,2008,0xffffffff),(0,1,255)):
        yield 'policy','retry_retune_edges',dict(retry_limit_88=limit,attempts=attempt,event_code=code,retune_104=retune)
    for limit,attempt,top,record,rc in itertools.product((-1,0,2),(0,2),('disabled','Disabled','200'),(-1,0,1),(-1,0,1)):
        yield 'policy','probe_gates',dict(retry_limit_88=limit,attempts=attempt,top=top,minimum_enabled_b0=0,returns={'current':record,'probe':rc})
    for opened,rc,value,close in itertools.product((0,1),(-1,0,1),(None,-1,0,1,2,2147483647),(-1,0,1)):
        yield 'policy','count_read_failures',dict(scan_value=value,returns={'read_open':opened,'scan':rc,'read_close':close})
    for opened,rc,close in itertools.product((0,2),(-1,0,1,2147483647),(-1,0,1)):
        for entry in ('policy','counter'):
            yield entry,'count_write_failures',dict(returns={'write_open':opened,'print':rc,'write_close':close})
    for value in (-2147483648,-1,0,1,2147483647):yield 'counter','counter_values',dict(store_value=value)
    for changed in (-2147483648,-1,0,1,2,2147483647):
        yield 'policy','count_read_after_close',dict(attempts=0,close_value=changed)
    for data,rc in itertools.product((None,'','X','X'*511),(-1,0,512)):
        yield 'policy','description_bytes',dict(description=['first message',data],returns={'describe':rc})
    yield 'policy','shared_description',dict(description=['first message',None],returns={'describe':[0,-1]})
    for laps,limit,fail in itertools.product((2,3,4),(0,1,2,3),(False,True)):
        yield 'policy','repeated_entry_persistence',dict(laps=laps,retry_limit_88=limit,persist_writes=True,returns={'print':-1 if fail else 1})
    for count,states,limit,stop_mutates,flag in itertools.product((0,1,2,3),((2,2,2),(3,3,3),(5,2,2)),(0,1,2),(False,True),(0,1)):
        yield 'check','nested_chain_stop',dict(count=count,chain_states=list(states),retry_limit_88=limit,stop_mutates=stop_mutates,query_fault_87=flag,persist_writes=True)
    for running,state in itertools.product((0,1,255),(0,1,2,3,4,6,0xffffffff)):
        yield 'check','nested_entry_gate',dict(running=running,state=state,count=0)
    changes=dict(minimum_enabled_b0=0,raise_failed_c8=0,word_30=2,retry_limit_88=0,retune_104=0,
                 top='disabled',text_3c='200',profile_key=[2,'125'],profile_label=[1,'Changed label'],
                 event_code=2007,state=6,running=0,persisted=3)
    paths=[{},dict(attempts=2),dict(retry_limit_88=0),dict(count=0,retry_limit_88=0)]
    ops=('event_code','select','action','describe','log','read_open','scan','read_close',
         'write_open','print','write_close','current','probe','before_exit','exit','shutdown','event','count')
    for path in paths:
        for name,key in itertools.product(ops,changes):
            yield ('check' if 'count' in path else 'policy'),'callback_mutations',dict(path,mutations=[(name,0,key,changes[key])])
    # On retune, label is loaded after probe and key is loaded again after log.
    yield 'policy','retune_record_reread',dict(attempts=2,mutations=[('probe',0,'profile_label',[1,'Fresh label']),('log',2,'profile_key',[1,'777'])])
    rng=random.Random(0x5e92c)
    for _ in range(300):
        yield 'policy','mixed',dict(retry_limit_88=rng.choice((-1,0,1,2,5)),attempts=rng.randint(-2,7),
            event_code=rng.choice((2007,2008,2009)),minimum_enabled_b0=rng.randrange(2),
            retune_104=rng.randrange(2),raise_failed_c8=rng.randrange(2),word_30=rng.randrange(3),
            returns={'select':rng.randint(-1,3),'current':rng.randint(-1,3),'probe':rng.choice((-1,0,1)),
                     'read_open':rng.randrange(2),'write_open':rng.choice((0,2)),'print':rng.choice((-1,1))})

def main():
    parser=argparse.ArgumentParser();parser.add_argument('library');parser.add_argument('--summary');parser.add_argument('--limit',type=int)
    ns=parser.parse_args();elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==H.G.REF
    original,native=Original(elf),Native(C.CDLL(str(Path(ns.library).resolve())))
    counts=collections.Counter();events=0;exits=0
    for index,(entry,category,p) in enumerate(cases()):
        if ns.limit is not None and index>=ns.limit:break
        try:a,b=original.run(entry,p),native.run(entry,p)
        except BaseException:
            print('CASE_ERROR',index,entry,category,p);raise
        if a!=b:
            print('FAIL',index,entry,category,p)
            for j,(x,y) in enumerate(itertools.zip_longest(a[2],b[2])):
                if x!=y:print('EVENT',j,'ORIGINAL',x,'NATIVE',y);break
            if a[:2]!=b[:2] or a[3]!=b[3]:print('FINAL',a[:2],b[:2],a[3],b[3])
            raise AssertionError('stop policy mismatch')
        counts[entry+'/'+category]+=1;events+=len(a[2]);exits+=sum(a[0])
    report=dict(cases=dict(counts),total=sum(counts.values()),compared_events=events,
                original_steps=original.steps,visited_instruction_addresses=len(original.visited),
                process_exit_boundaries=exits,original_policy_and_counter=True,nested_original_60730_60a2c=True,
                original_atoi=True,new_arm_instructions=0,real_file_io=False,real_process_exit=False,
                hardware_io=False,real_threads=False,reference_sha256=H.G.REF)
    if ns.summary:Path(ns.summary).write_text(json.dumps(report,indent=2)+'\n')
    print('STOP_POLICY135_ORIGINAL_PASS',json.dumps(report,sort_keys=True))
if __name__=='__main__':main()
