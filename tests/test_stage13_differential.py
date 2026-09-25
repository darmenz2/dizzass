#!/usr/bin/env python3
"""Original instruction comparisons for FIFO algorithms and composed queue paths.
Each reported comparison is one operation/state boundary, not a recovered function.
Native heap addresses are normalized to indices. Original memcpy is hooked, but
ring mutation/full/drop decisions execute in original instructions, not mocks.
"""
from pathlib import Path
import argparse,ctypes as C,json,os,random,struct,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from nonce_fifo_oracle import FifoOracle
from nonce_oracle import NonceOracle
U8=C.c_uint8;U32=C.c_uint32;P=C.c_void_p
class Fifo(C.Structure):_fields_=[('storage',P),('capacity',U32),('element_size',U32),('count',U32),('write_index',U32),('read_index',U32)]
class Queue(C.Structure):_fields_=[('ring',Fifo),('push_word',U32),('ready',U32)]
class Record(C.Structure):_fields_=[('bytes',U8*72)]
class Candidate(C.Structure):_fields_=[('words',U32*17)]
ALLOC=C.CFUNCTYPE(P,P,C.c_size_t);FREE=C.CFUNCTYPE(None,P,P);SYNC=C.CFUNCTYPE(C.c_int,P)
class Memory(C.Structure):_fields_=[('context',P),('allocate',ALLOC),('release',FREE)]
class Sync(C.Structure):_fields_=[('context',P),('initialize',SYNC),('lock',SYNC),('unlock',SYNC),('destroy',SYNC)]
class Arena:
    def __init__(self):
        self.buffers={};self.keep=[];self.events=[];self.errors=[];self.held=False
        self.allocate=ALLOC(self._allocate);self.release=FREE(self._release);self.mem=Memory(None,self.allocate,self.release)
        self.callbacks=[SYNC(self._sync(k)) for k in ('initialize','lock','unlock','destroy')];self.sync=Sync(None,*self.callbacks)
    def _allocate(self,ctx,n):
        try:
            b=C.create_string_buffer(b'\xcd'*n,n);p=C.addressof(b);self.buffers[p]=b;self.keep.append(b);self.events.append(('allocate',n));return p
        except BaseException as e:self.errors.append(repr(e));return None
    def _release(self,ctx,p):
        try:b=self.buffers.pop(p);self.events.append(('release',len(b)))
        except BaseException as e:self.errors.append(repr(e))
    def _sync(self,k):
        def f(ctx):
            try:
                if k=='lock':assert not self.held;self.held=True
                if k=='unlock':assert self.held;self.held=False
                if k in ('initialize','destroy'):assert not self.held
                self.events.append((k,));return 0
            except BaseException as e:self.errors.append(repr(e));return -1
        return f
    def check(self):assert not self.errors,self.errors;assert not self.held

def load():
    l=C.CDLL(str(Path(os.environ.get('VN135_TEST_LIBRARY',ROOT/'build/libvn135_recovered.so')).resolve()))
    fp=C.POINTER(Fifo);qp=C.POINTER(Queue);mp=C.POINTER(Memory);sp=C.POINTER(Sync);rp=C.POINTER(Record)
    l.vn135_fifo_init.argtypes=[fp,U32,U32,mp]
    l.vn135_fifo_push.argtypes=[fp,P];l.vn135_fifo_pop.argtypes=[fp,P]
    for k in ('is_full','is_empty','reset'):getattr(l,'vn135_fifo_'+k).argtypes=[fp]
    l.vn135_fifo_count.argtypes=[fp,C.POINTER(U32)];l.vn135_fifo_destroy.argtypes=[fp,mp]
    l.vn135_nonce_fifo_init.argtypes=[qp,mp,sp]
    l.vn135_nonce_fifo_push.argtypes=[qp,rp,sp,C.POINTER(U32)]
    l.vn135_nonce_fifo_pop.argtypes=[qp,rp,sp]
    for k in ('is_full','is_empty','reset'):getattr(l,'vn135_nonce_fifo_'+k).argtypes=[qp,sp]
    l.vn135_nonce_fifo_destroy.argtypes=[qp,mp,sp]
    l.vn135_nonce_record_pack.argtypes=[C.POINTER(Candidate),P,rp]
    l.vn135_nonce_record_unpack.argtypes=[rp,C.POINTER(Candidate),P]
    return l

def native_state(q,queue=False):
    f=q.ring if queue else q
    s={'active':bool(f.storage),'capacity':f.capacity,'stride':f.element_size,'count':f.count,
       'write_index':f.write_index,'read_index':f.read_index,
       'storage':C.string_at(f.storage,f.capacity*f.element_size) if f.storage else None}
    if queue:s['push_word']=q.push_word
    return s

def compare(lib,o,a,q,op,data=None,discard=False,cap=None,stride=None):
    expected=o.call(op,data,discard,cap,stride);a.events=[];isq=o.queue
    args=[C.byref(q)];drop=U32(0xdeadbeef);before=native_state(q,isq) if op!='init' else None
    if isq:
        if op=='init':rc=lib.vn135_nonce_fifo_init(*args,C.byref(a.mem),C.byref(a.sync))
        elif op=='push':
            b=Record();b.bytes[:]=data;rc=lib.vn135_nonce_fifo_push(*args,C.byref(b),C.byref(a.sync),C.byref(drop))
            assert bytes(b)==data and drop.value==int(before['count']==before['capacity'])
        elif op=='pop':
            b=Record();b.bytes[:]=b'\xa5'*72;rc=lib.vn135_nonce_fifo_pop(*args,None if discard else C.byref(b),C.byref(a.sync))
        elif op=='destroy':rc=lib.vn135_nonce_fifo_destroy(*args,C.byref(a.mem),C.byref(a.sync))
        else:rc=getattr(lib,'vn135_nonce_fifo_'+{'empty':'is_empty','full':'is_full'}.get(op,op))(*args,C.byref(a.sync))
    else:
        if op=='init':rc=lib.vn135_fifo_init(*args,cap,stride,C.byref(a.mem))
        elif op=='push':
            b=C.create_string_buffer(data,len(data));rc=lib.vn135_fifo_push(*args,b);assert b.raw==data
        elif op=='pop':
            b=C.create_string_buffer(b'\xa5'*q.element_size,q.element_size);rc=lib.vn135_fifo_pop(*args,None if discard else b)
        elif op=='destroy':rc=lib.vn135_fifo_destroy(*args,C.byref(a.mem))
        elif op=='count':
            v=U32();assert lib.vn135_fifo_count(*args,C.byref(v))==0;rc=v.value
        else:rc=getattr(lib,'vn135_fifo_'+{'empty':'is_empty','full':'is_full'}.get(op,op))(*args)
    a.check();assert native_state(q,isq)==expected['state'],('state mismatch',op)
    # Init/reset/destroy originally have no stable boolean API result. New status
    # is compared only on boolean operations or the original successful unlock.
    if op not in ('init','reset','destroy'):assert rc==expected['return'],(op,rc,expected['return'])
    else:assert rc==0
    if op=='pop' and not discard:assert bytes(b)==expected['output'],('pop bytes',isq)
    assert a.events==[e for e in expected['events'] if e[0]!='copy'],(a.events,expected['events'])
    # memcpy calls are original, and complete raw backing storage is compared.
    return expected

def ring_tests(lib):
    rnd=random.Random(13001);count=0;ops={};wraps=0;full=0
    for cap in (1,2,3,7,17,65):
        for stride in (1,4,9,68,72,127):
            o=FifoOracle();a=Arena();q=Fifo()
            compare(lib,o,a,q,'init',cap=cap,stride=stride);count+=1;ops['init']=ops.get('init',0)+1
            for i in range(240):
                # Deterministic prefixes guarantee full and empty, random tail
                # explores repeated resets and wrap after mixed operations.
                if i<cap+2:op='push'
                elif i<2*cap+5:op='pop'
                else:op=rnd.choice(['push']*5+['pop']*4+['full','empty','count','reset'])
                before=q.write_index;was_full=q.count==q.capacity
                compare(lib,o,a,q,op,rnd.randbytes(stride) if op=='push' else None,discard=(op=='pop' and i%7==0))
                if op=='push':wraps+=int(q.write_index<before);full+=int(was_full)
                count+=1;ops[op]=ops.get(op,0)+1
            compare(lib,o,a,q,'destroy');count+=1;ops['destroy']=ops.get('destroy',0)+1
            compare(lib,o,a,q,'destroy');count+=1;ops['destroy']+=1
            assert not a.buffers
    return {'comparisons':count,'operations':ops,'write_wraps':wraps,'full_pushes':full,'original_primitives_executed':8}

def queue_tests(lib):
    rnd=random.Random(13002);o=FifoOracle(queue=True);a=Arena();q=Queue()
    compare(lib,o,a,q,'init');count=1;drops=0
    for i in range(580):
        cap=4096;stride=72;read=rnd.randrange(cap);occupancy=[0,1,4095,4096][i%4]
        # Preserve backing storage between cases; seed only valid queue geometry.
        w=(read+occupancy)%cap;q.ring.count=occupancy;q.ring.read_index=read;q.ring.write_index=w
        q.push_word=[0,1,0xfffffffe,0xffffffff,rnd.getrandbits(32)][i%5]
        o.seed(cap,stride,read,occupancy,push_word=q.push_word)
        for op in ('empty','full','push','pop','push'):
            if op=='push':drops+=int(q.ring.count==cap)
            compare(lib,o,a,q,op,rnd.randbytes(72) if op=='push' else None,discard=(op=='pop' and i%9==0));count+=1
        if i%8==0:compare(lib,o,a,q,'reset');count+=1
    compare(lib,o,a,q,'destroy');count+=1;assert not a.buffers
    # Original wrapper destructor on a second call invokes mutex destroy again;
    # the NEW ready guard suppresses it. Reinitialization is compared instead.
    compare(lib,o,a,q,'init');count+=1;compare(lib,o,a,q,'destroy');count+=1
    return {'comparisons':count,'dropped_oldest_cases':drops,'all_72_record_bytes_compared':True,
            'original_queue_and_ring_execute_together':True,'original_wrapper_procedures':7,
            'failed_allocation_or_mutex_not_original_domain':True}

def producer_compositions(lib):
    rnd=random.Random(13003);n=NonceOracle();o=FifoOracle(n.m,queue=True);a=Arena();q=Queue()
    compare(lib,o,a,q,'init');count=0
    for variant in range(3):
        for i in range(24):
            payload=bytearray(rnd.randbytes(7+variant));payload[-1]|=0x80
            row=rnd.randbytes(168);original=n.prepare(variant,2,1,bytes(payload),row,7,11)
            m=n.m;p=m.r[0];tail=rnd.randbytes(4);m.mem[p+68:p+72]=tail
            # Continue actual producer BL to actual original queue, not a mocked
            # queue-return. Stop immediately after that call; no thread loop.
            o.events=[];m.run(0xc46fc,stop=0xc4700,hooks=o.hooks(),max_steps=m.steps+20000)
            expected_events=o.events[:]
            c=Candidate();c.words[:]=struct.unpack('<17I',original['candidate']);r=Record()
            assert lib.vn135_nonce_record_pack(C.byref(c),tail,C.byref(r))==0
            assert bytes(r)==original['candidate']+tail
            a.events=[];d=U32();assert lib.vn135_nonce_fifo_push(C.byref(q),C.byref(r),C.byref(a.sync),C.byref(d))==0
            assert d.value==0 and native_state(q,True)==o.state()
            assert a.events==[e for e in expected_events if e[0]!='copy'];a.check()
            expected=compare(lib,o,a,q,'pop');out=Record();out.bytes[:]=expected['output']
            decoded=Candidate();trail=(U8*4)();assert lib.vn135_nonce_record_unpack(C.byref(out),C.byref(decoded),trail)==0
            assert bytes(decoded)==original['candidate'] and bytes(trail)==tail
            count+=1
    compare(lib,o,a,q,'destroy');assert not a.buffers
    return {'compositions':count,'original_producer_push_and_queue_pop':True,
            'separate_from_main_comparison_total':True,'opaque_tail_interpretation_recovered':False}

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('group',choices=['ring','queue','composition','all'],default='all',nargs='?');a=p.parse_args();lib=load()
    functions={'ring':ring_tests,'queue':queue_tests,'composition':producer_compositions};result={}
    for k,f in functions.items():
        if a.group in (k,'all'):result[k]=f(lib);print(k,json.dumps(result[k]),flush=True)
    result['main_comparisons']=sum(v.get('comparisons',0) for v in result.values())
    dest=ROOT/'build'/('stage13-'+a.group+'-results.json');dest.parent.mkdir(exist_ok=True)
    dest.write_text(json.dumps(result,indent=2)+'\n')
