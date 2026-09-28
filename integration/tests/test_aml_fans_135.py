#!/usr/bin/env python3
"""Original 1.3.5 AML fan code versus C. No real sysfs, threads or devices."""
import argparse, ctypes as C, hashlib, json, random, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import signed, MASK
REF='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
THREAD=0x655f70;CACHE=0x655f78;RUN=0x655f98;LOCK=0x655f9c
RANGES=[(0x118444,0x119354),(0x11936c,0x1199d4),(0xfb994,0xfd784),
        (0xfe258,0xfe310),(0x590ef0,0x590fbc),(0x5a2544,0x5a25b4)]
class FanArm(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        if not any(a<=pc<b for a,b in self.allowed):
            raise ValueError('Unexpected fan PC '+hex(pc))
        self.visited.add(pc)
        # Only witnessed unrounded A32 SMMUL. Historical interpreters unchanged.
        if w&0x0ff0f0f0==0x0750f010:
            d=(w>>16)&15;n=w&15;m=(w>>8)&15
            if 15 in (d,n,m):raise ValueError('SMMUL PC unsupported')
            self.r[d]=(signed(self.r[n])*signed(self.r[m])>>32)&MASK
            return True
        return super().extra_instruction(w,pc)
class Finished(Exception):pass
class Script:
    def __init__(self,sc=None):
        self.sc=sc or {};self.events=[];self.calls={};self.passno=0;self.lineidx=0
        self.snap=lambda:None;self.running=lambda v:None;self.thread=lambda v:None
    def ret(self,name,default):
        k=self.calls.get(name,0);self.calls[name]=k+1
        return self.sc.get('returns',{}).get(name,{}).get(k,default)
    def open(self,path,mode):
        h=self.ret('open',0x100+self.calls.get('open',0));self.events.append(('open',path,mode,h));return h
    def close(self,h):
        r=self.ret('close',0);self.events.append(('close',h,r));return r
    def write(self,h,fmt,v):
        r=self.ret('write',len(str(v)));self.events.append(('write',h,fmt,v,r));return r
    def read(self,h,fmt):
        i=self.calls.get('read',0);r=self.ret('read',1)
        v=self.sc.get('values',[100000,50000])[i]
        self.events.append(('read',h,fmt,v if r==1 else None,r));return r,v
    def mutex(self,u):
        n='unlock' if u else 'lock';r=self.ret(n,0);self.events.append((n,r));return r
    def create(self,entry,arg,old):
        r=self.ret('create',0);h=self.sc.get('handle',0x4255) if not self.sc.get('no_handle_write') else old
        self.events.append(('create',entry,arg,old,h,r));return r,h
    def cancel(self,value):
        r=self.ret('cancel',0);self.events.append(('cancel',value,r));return r
    def name(self,value):
        r=self.ret('name',0);self.events.append(('name',value,r));return r
    def seek(self,h,off,whence):
        r=self.ret('seek',0)
        if r==0 or self.sc.get('rewind_despite_error'): self.lineidx=0
        self.events.append(('seek',h,off,whence,r));return r
    def line(self,n,h):
        polls=self.sc.get('polls',[[]]);lines=polls[min(self.passno,len(polls)-1)]
        if self.lineidx>=len(lines):s=None
        else:s=lines[self.lineidx];self.lineidx+=1
        assert s is None or len(s)<n
        self.events.append(('line',n,h,s));return s
    def sleep(self,ms):
        self.events.append(('sample',ms,self.snap()))
        r=self.ret('sleep',0);self.passno+=1
        if self.passno>=len(self.sc.get('polls',[[]])):self.running(0)
        self.events.append(('sleep',ms,r));return r
    def self_thread(self):
        self.events.append(('self',self.snap()))
        if 'self_new_handle' in self.sc:self.thread(self.sc['self_new_handle'])
        return self.sc.get('self',0x9876)
    def lifecycle(self,name,handle):
        r=self.ret(name,0);self.events.append((name,handle,r,self.snap()))
        if name=='cancel_thread' and 'cancel_new_handle' in self.sc:
            self.thread(self.sc['cancel_new_handle'])
        return r
    def log(self,line,arg):self.events.append(('log',line,arg))
    def exit(self,v):self.events.append(('exit',v,self.snap()))
class Original:
    def __init__(self):
        self.elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
        assert hashlib.sha256(self.elf.data).hexdigest()==REF
        evidence=json.loads((ROOT/'integration/evidence/aml_fans_135.json').read_text())
        assert evidence['reference_sha256']==REF
        for entry in evidence['ranges']:
            a,b=int(entry['start'],16),int(entry['end_exclusive'],16)
            assert hashlib.sha256(self.elf.read(a,b-a)).hexdigest()==entry['sha256']
        for entry in evidence['data']:
            assert hashlib.sha256(self.elf.read(int(entry['address'],16),entry['size'])).hexdigest()==entry['sha256']
        assert struct.unpack('<4I',self.elf.read(0x5b29bc,16))==(27,26,28,29)
        self.m=FanArm(self.elf);m=self.m;m.allowed=RANGES;m.visited=set()
        m.reset();m.run(0x11936c,max_steps=30000)
        assert self.string(0x5ee2e3)=='/tmp/build/libbitmain/src/aml/fan_ctrl.c'
        m.reset((2,));m.run(0xfb994,stop=0xfd784,max_steps=30000)
        assert [m.read(a) for a in range(0x654b60,0x654b74,4)]==[0x118444,0x1189dc,0x118cc8,0x11910c,0x119258]
        self.initial=bytes(m.mem)
    def string(self,a):
        m=self.m;end=m.mem.find(0,a,a+2048);assert end>=a
        return bytes(m.mem[a:end]).decode('ascii')
    def snapshot(self):
        m=self.m;return (m.read(THREAD),m.read(RUN,1),tuple(m.read(CACHE+4*i) for i in range(8)))
    def execute(self,op,args=(),sc=None,state=None):
        m=self.m;m.mem[:]=self.initial;m.reset(args);s=Script(sc)
        state=state or (0x3210,0,tuple(range(100,108)))
        m.write(THREAD,state[0]);m.write(RUN,state[1],1)
        for i,v in enumerate(state[2]):m.write(CACHE+4*i,v)
        s.snap=self.snapshot;s.running=lambda v:m.write(RUN,v,1);s.thread=lambda v:m.write(THREAD,v)
        def op_open(m):m.r[0]=s.open(self.string(m.r[0]),self.string(m.r[1]))
        def op_close(m):m.r[0]=s.close(m.r[0])&MASK
        def op_write(m):m.r[0]=s.write(m.r[0],self.string(m.r[1]),m.r[2])&MASK
        def op_read(m):
            r,v=s.read(m.r[0],self.string(m.r[1]))
            if r==1:m.write(m.r[2],v)
            m.r[0]=r&MASK
        def lock(m):assert m.r[0]==LOCK;m.r[0]=s.mutex(0)&MASK
        def unlock(m):assert m.r[0]==LOCK;m.r[0]=s.mutex(1)&MASK
        def fmt(m):
            f=self.string(m.r[2]);out=(f%signed(m.r[3])).encode('ascii');n=m.r[1]
            data=out[:max(0,n-1)]+(b'\0' if n else b'');m.mem[m.r[0]:m.r[0]+len(data)]=data;m.r[0]=len(out)
        def create(m):
            assert m.r[0]==THREAD and m.r[1]==0
            r,h=s.create(m.r[2],m.r[3],m.read(THREAD));m.write(THREAD,h);m.r[0]=r&MASK
        def cancel(m):assert m.r[1]==0;m.r[0]=s.cancel(m.r[0])&MASK
        def name(m):
            assert m.r[0]==15 and m.r[2]==0 and m.r[3]==0 and m.read(m.r[13])==0
            m.r[0]=s.name(self.string(m.r[1]))&MASK
        def seek(m):m.r[0]=s.seek(m.r[0],signed(m.r[1]),signed(m.r[2]))&MASK
        def line(m):
            p=m.r[0];t=s.line(m.r[1],m.r[2])
            if t is None:m.r[0]=0
            else:b=t.encode()+b'\0';m.mem[p:p+len(b)]=b;m.r[0]=p
        def sleep(m):m.r[0]=s.sleep(m.r[0])&MASK
        def find(m):
            a=m.r[0];i=self.string(a).find(self.string(m.r[1]));m.r[0]=a+i if i>=0 else 0
        def strchr(m):
            a=m.r[0];i=self.string(a).find(chr(m.r[1]));m.r[0]=a+i if i>=0 else 0
        def memset(m):m.mem[m.r[0]:m.r[0]+m.r[2]]=bytes([m.r[1]&255])*m.r[2]
        def log(m):
            line=m.r[3];assert self.string(m.r[1])=='/tmp/build/libbitmain/src/aml/fan_ctrl.c'
            assert line in (57,127,170,218);s.log(line,m.read(m.r[13]+8) if line!=57 else 0);m.r[0]=0
        def self_(m):m.r[0]=s.self_thread()
        def detach_(m):m.r[0]=s.lifecycle('detach',m.r[0])&MASK
        def cancel_(m):m.r[0]=s.lifecycle('cancel_thread',m.r[0])&MASK
        def join_(m):
            assert m.r[1]==0
            m.r[0]=s.lifecycle('join',m.r[0])&MASK
        def exit_(m):s.exit(m.r[0]);raise Finished()
        hooks={0x59e5b0:op_open,0x59e084:op_close,0x59e658:op_write,0x59e958:op_read,
               0x5a6108:lock,0x5a66c4:unlock,0x59f558:fmt,0x5a55cc:create,
               0x5a6b2c:cancel,0x593af8:name,0x59eaec:seek,0x59e3f8:line,
               0x10ef3c:sleep,0x5a40bc:find,0x5a36a0:strchr,0x5a348c:memset,
               0xfa0c4:log,0x5a52d0:exit_,0x5a6b20:self_,0x5a5bb0:detach_,0x5a4754:cancel_,0x5a5d2c:join_}
        entries={'init':0xfe258,'set':0x118a04,'all':0xfe2e0,'duty':0xfe2f0,'rpm':0xfe300,'worker':0x1184fc,'shutdown':0x119258}
        try:r=m.run(entries[op],hooks=hooks,max_steps=150000)
        except Finished:r=None
        if op in ('set','all','worker','shutdown'):r=None
        return r,self.snapshot(),s.events
I=C.c_int32;U=C.c_uint32;V=C.c_void_p;S=C.c_char_p;P=C.POINTER(U)
class Sample(C.Structure):_fields_=[('rpm',U),('previous',U)]
class State(C.Structure):_fields_=[('thread',U),('running',C.c_uint8),('samples',Sample*4)]
TYPES=[C.CFUNCTYPE(U,V,S,S),C.CFUNCTYPE(I,V,U),C.CFUNCTYPE(I,V,U,S,U),
       C.CFUNCTYPE(I,V,U,S,P),C.CFUNCTYPE(I,V,U),C.CFUNCTYPE(I,V,P,U,U),
       C.CFUNCTYPE(I,V,U),C.CFUNCTYPE(I,V,S),C.CFUNCTYPE(I,V,U,I,I),
       C.CFUNCTYPE(V,V,V,U,U),C.CFUNCTYPE(I,V,U),C.CFUNCTYPE(None,V,U),C.CFUNCTYPE(None,V,U,U),C.CFUNCTYPE(U,V),C.CFUNCTYPE(I,V,U),C.CFUNCTYPE(I,V,U),C.CFUNCTYPE(I,V,U)]
class Ops(C.Structure):_fields_=list(zip(['open','close','write_uint','read_uint','mutex','create_thread',
  'cancel_state','name_thread','seek','read_line','sleep_ms','exit_thread','log','self_thread','detach_thread','cancel_thread','join_thread'],TYPES))
class Native:
    def __init__(self,path):
        self.lib=C.CDLL(str(Path(path).resolve()))
        signatures={'initialize':([C.POINTER(State),C.POINTER(Ops),V],I),
          'set_channel':([C.POINTER(Ops),V,U,I],None),'set_all':([C.POINTER(Ops),V,I],None),
          'get_duty':([C.POINTER(Ops),V],U),'get_rpm':([C.POINTER(State),C.POINTER(Ops),V,U],U),
          'rpm_worker':([C.POINTER(State),C.POINTER(Ops),V],None),'shutdown':([C.POINTER(State),C.POINTER(Ops),V],None)}
        for name,(a,r) in signatures.items():
            f=getattr(self.lib,'vn135_aml_fans_'+name+'_135');f.argtypes=a;f.restype=r
    def execute(self,op,args=(),sc=None,state=None):
        st=State();state=state or (0x3210,0,tuple(range(100,108)));st.thread=state[0];st.running=state[1]
        for i in range(4):st.samples[i].rpm=state[2][2*i];st.samples[i].previous=state[2][2*i+1]
        def snap():return (st.thread,st.running,tuple(v for t in st.samples for v in (t.rpm,t.previous)))
        s=Script(sc);s.snap=snap;s.running=lambda v:setattr(st,'running',v);s.thread=lambda v:setattr(st,'thread',v)
        def read(p,h,f,out):
            r,v=s.read(h,f.decode())
            if r==1:out[0]=v
            return r
        def create(p,h,e,a):r,v=s.create(e,a,h[0]);h[0]=v;return r
        def line(p,out,n,h):
            t=s.line(n,h)
            if t is None:return None
            C.memmove(out,t.encode()+b'\0',len(t)+1);return out
        funcs=[lambda p,a,b:s.open(a.decode(),b.decode()),lambda p,h:s.close(h),
               lambda p,h,f,v:s.write(h,f.decode(),v),read,lambda p,u:s.mutex(u),create,
               lambda p,v:s.cancel(v),lambda p,n:s.name(n.decode()),lambda p,h,o,w:s.seek(h,o,w),line,
               lambda p,ms:s.sleep(ms),lambda p,v:s.exit(v),lambda p,l,a:s.log(l,a),lambda p:s.self_thread(),lambda p,h:s.lifecycle('detach',h),lambda p,h:s.lifecycle('cancel_thread',h),lambda p,h:s.lifecycle('join',h)]
        callbacks=[t(f) for t,f in zip(TYPES,funcs)];ops=Ops(*callbacks)
        names={'init':'initialize','set':'set_channel','all':'set_all','duty':'get_duty','rpm':'get_rpm','worker':'rpm_worker','shutdown':'shutdown'}
        f=getattr(self.lib,'vn135_aml_fans_'+names[op]+'_135')
        r=f(C.byref(st),C.byref(ops),None,*args) if op in ('init','rpm','worker','shutdown') else f(C.byref(ops),None,*args)
        if op=='init':r &= MASK
        return r,snap(),s.events

def cases():
    for running in range(256):
        for worker in [0,0x3210,0xffffffff]:
            for self_ in [worker,worker^0xffffffff]:
                yield 'shutdown',(),{'self':self_},(worker,running,tuple(range(8)))
    for name in ['detach','cancel_thread','join']:
        for rc in [-1,1,-2147483648]:
            yield 'shutdown',(),{'self':0x3210 if name=='detach' else 0x2222,'returns':{name:{0:rc}}},(0x3210,1,tuple(range(8)))
    yield 'shutdown',(),{'self':0x7777,'self_new_handle':0x7777},(123,1,(0,)*8)
    yield 'shutdown',(),{'self':0x1111,'cancel_new_handle':0x5555},(123,1,(0,)*8)
    for code in [0,1,-1,22,-2147483648]:
        for old in [0,1,0xffffffff]:
            for write in [False,True]:yield 'init',(),{'returns':{'create':{0:code}},'no_handle_write':write},(old,0,tuple(range(8)))
    duties=[-2147483648,-101,-1,*range(0,102),255,65535,2147483647]
    for d in duties:
        for c in [0,1,2,0xffffffff]:yield 'set',(c,d),{},None
        yield 'all',(d,),{},None
    for mask in range(8):yield 'set',(1,30),{'returns':{'open':{i:0 for i in range(3) if mask>>i&1}}},None
    for kind,count in [('write',4),('close',3),('lock',1),('unlock',1)]:
        for i in range(count):yield 'set',(0,75),{'returns':{kind:{i:-1}}},None
    for i in range(6):yield 'all',(50,),{'returns':{'open':{i:0}}},None
    vals=[0,1,99999,100000,100001,0x7fffffff,0x80000000,0xffffffff]
    for p in vals:
        for d in vals:yield 'duty',(),{'values':[p,d]},None
    for p in range(101):yield 'duty',(),{'values':[100000,1000*p]},None
    for mask in range(4):yield 'duty',(),{'returns':{'open':{i:0 for i in range(2) if mask>>i&1}}},None
    for kind,count in [('read',2),('close',2),('lock',1),('unlock',1)]:
        for i in range(count):
            for rc in [-1,0,2]:yield 'duty',(),{'returns':{kind:{i:rc}}},None
    rng=random.Random(135)
    for _ in range(128):yield 'duty',(),{'values':[rng.getrandbits(32),rng.getrandbits(32)]},None
    for i in [0,1,2,3,4,5,0x80000000,0xffffffff]:
        for v in [0,1,0x7fffffff,0x80000000,0xffffffff]:yield 'rpm',(i,),{},(123,1,(v,3,v,5,v,7,v,9))
    zero=(123,0,(0,)*8)
    for open_rc in [0]:yield 'worker',(),{'returns':{'open':{0:open_rc}}},None
    for labels in [[27,26,28,29],[29,28,26,27]]:
        for prev in [0,1,100,0xfffffffe,0xffffffff]:
            for now in [0,1,100,111,0x7fffffff,0x80000000,0xffffffff]:
                lines=[f' {l}: {now} 777 0 0 gpiolib extra\n' for l in labels]
                yield 'worker',(),{'polls':[lines,lines]},(123,0,tuple(x for _ in range(4) for x in (0,prev)))
    yield 'worker',(),{'polls':[['header CPU0 CPU1\n',' 27: 20 30 wrong\n',' 99: 100 200 gpiolib\n'],[]]},zero
    # Preserve substring matching (127: also matches 27:), first-column-only data,
    # signed/wrapping conversion, missing labels retaining the cached values.
    for token in ['-1','+12','4294967296','999999999999999999999999','abc','0','123']:
        yield 'worker',(),{'polls':[[f' 127: {token} 888 gpiolib\n'],[' 27: 100 9999 gpiolib\n']]},zero
    for j in range(24):
        polls=[[f' {l}: {rng.randrange(5000)} 777777 gpiolib\n' for l in [27,26,28,29]] for _ in range(3)]
        yield 'worker',(),{'polls':polls},zero
    for kind,count in [('cancel',1),('name',1),('close',1),('seek',2),('sleep',2)]:
        for i in range(count):yield 'worker',(),{'polls':[[' 27: 100 0 gpiolib\n'],[' 27: 120 0 gpiolib\n']],'returns':{kind:{i:-1}}},zero

def smmul_fixtures(oracle):
    m=oracle.m;addr=m.DATA_BASE;m.allowed=RANGES+[(addr,addr+8)]
    m.write(addr,0xe751f211);m.write(addr+4,0xe12fff1e)
    vals=[0,1,0xffffffff,0x80000000,0x7fffffff,0x51eb851f,0x10000,0xffff0000]
    n=0
    for a in vals:
        for b in vals:
            m.reset((0,a,b));m.n,m.z,m.c,m.v=True,False,True,True
            m.run(addr);actual=m.r[1]
            product=(a if a<2**31 else a-2**32)*(b if b<2**31 else b-2**32)
            expected=int.from_bytes((product%(1<<64)).to_bytes(8,'little')[4:],'little')
            assert actual==expected and (m.n,m.z,m.c,m.v)==(True,False,True,True);n+=1
    m.allowed=RANGES;return n

def main():
    a=argparse.ArgumentParser();a.add_argument('library');a.add_argument('--summary');args=a.parse_args()
    o=Original();n=Native(args.library);counts={};events=0
    fixtures=smmul_fixtures(o)
    for i,(op,ar,sc,st) in enumerate(cases()):
        x=o.execute(op,ar,sc,st);y=n.execute(op,ar,sc,st)
        if x!=y:
            print('FAIL',i,op,ar,sc,st)
            if x[:2]!=y[:2]:print('states',x[:2],y[:2])
            for k,(u,v) in enumerate(zip(x[2],y[2])):
                if u!=v:print('event',k,u,v);break
            if len(x[2])!=len(y[2]):print('event counts',len(x[2]),len(y[2]),x[2][-8:],y[2][-8:])
            raise AssertionError('Original/C mismatch')
        counts[op]=counts.get(op,0)+1;events+=len(x[2])
    result={'comparisons':sum(counts.values()),'cases':counts,'events':events,
      'smmul_fixtures':fixtures,'reference_sha256':REF,'strings_constructor_executed':True,
      'aml_dispatch_executed':True,'rpm_worker_body_executed':True,
      'new_instruction_model':'SMMUL unrounded A32 only','physical_hardware':False,
      'real_threads':False,'external_io':'scripted callbacks','malformed_matched_lines_tested':False}
    print('AML_FANS135_ORIGINAL_PASS',json.dumps(result,sort_keys=True))
    if args.summary:Path(args.summary).write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
