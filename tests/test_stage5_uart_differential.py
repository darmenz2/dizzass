#!/usr/bin/env python3
"""Stage 5: compare UART C against original ARM bytes with traced syscall hooks.
Not a UART device test. No target ELF is executed as a host/Linux process.
"""
from pathlib import Path
import ctypes as C
import hashlib, json, random, struct, sys, time
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32, signed
SHA = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
callback_failures=[]
sys.unraisablehook=lambda e: callback_failures.append(repr(e.exc_value))
elf = ELF32(ROOT/'reference/cgminer.vendor.elf')
assert hashlib.sha256(elf.data).hexdigest() == SHA
lib = C.CDLL(str(ROOT/'build/libvn135_recovered.so'))
P = C.c_void_p; I = C.c_int32; U = C.c_uint32; Z = C.c_size_t
class Uart(C.Structure):
    _fields_=[('path',P),('fd',I),('baud',U),('ready',C.c_bool)]
OPEN=C.CFUNCTYPE(I,P,P,U); DUP=C.CFUNCTYPE(P,P,P); FREE=C.CFUNCTYPE(None,P,P)
IOCTL=C.CFUNCTYPE(I,P,I,U,P); RW=C.CFUNCTYPE(I,P,I,P,U)
ERR=C.CFUNCTYPE(P,P); CLOSE=C.CFUNCTYPE(I,P,I); FLUSH=C.CFUNCTYPE(I,P,I,I)
INIT=C.CFUNCTYPE(I,P); VOID=C.CFUNCTYPE(None,P); SLEEP=C.CFUNCTYPE(None,P,U)
class Ops(C.Structure):
    _fields_=[('context',P),('open',OPEN),('duplicate',DUP),('release',FREE),('ioctl',IOCTL),
        ('read',RW),('write',RW),('error_number',ERR),('close',CLOSE),('flush',FLUSH),
        ('mutex_init',INIT),('lock',VOID),('unlock',VOID),('mutex_destroy',VOID),('sleep_ms',SLEEP)]
for name,args in {
 'open':[C.POINTER(Uart),C.POINTER(Ops),C.c_char_p],
 'set_baud':[C.POINTER(Uart),C.POINTER(Ops),U],
 'read':[C.POINTER(Uart),C.POINTER(Ops),P,Z],
 'write_legacy':[C.POINTER(Uart),C.POINTER(Ops),P,Z],
 'flush':[C.POINTER(Uart),C.POINTER(Ops)],
 'destroy':[C.POINTER(Uart),C.POINTER(Ops)]}.items():
 fn=getattr(lib,'vn135_uart_'+name);fn.argtypes=args;fn.restype=I
m=ARM32(elf); BASE=m.DATA_BASE; OBJ=BASE; BUF=BASE+0x1000; PATH=BASE+0x3000; HEAP=BASE+0x4000; ERRADDR=BASE+0x5000
PATH_BYTES=b'/dev/ttyTEST\x00'
GET=0x802c542a;SET=0x402c542b;AVAIL=0x541b
rng=random.Random(0x1350505);counts={};samples=[];start=time.monotonic()
def record(k):counts[k]=counts.get(k,0)+1

def old_run(op,sc):
    trace=[];attrs=bytearray(sc['attrs']);ioindex=0;windex=0
    m.reset();m.mem[OBJ:OBJ+64]=b'\0'*64
    m.write(OBJ+28,HEAP if sc.get('owned') else 0);m.write(OBJ+32,sc.get('fd',42));m.write(OBJ+36,sc.get('baud',921600))
    m.mem[PATH:PATH+len(PATH_BYTES)]=PATH_BYTES
    m.mem[HEAP:HEAP+len(PATH_BYTES)]=PATH_BYTES
    payload=sc.get('payload',b'');m.mem[BUF:BUF+max(64,len(payload))]=b'\xa5'*max(64,len(payload))
    if op=='write_legacy':m.mem[BUF:BUF+len(payload)]=payload
    m.write(ERRADDR,sc.get('errno',0))
    def open_(mm):
        assert mm.r[0]==PATH;trace.append(['open',PATH_BYTES[:-1].decode(),mm.r[1]])
        mm.r[0]=sc.get('open_rc',42)&0xffffffff
    def dup(mm):
        assert mm.r[0]==PATH;trace.append(['duplicate']);mm.r[0]=0 if sc.get('duplicate_fail') else HEAP
    def init(mm):
        assert mm.r[0]==OBJ and mm.r[1]==0;trace.append(['mutex_init']);mm.r[0]=sc.get('mutex_init_rc',0)&0xffffffff
    def ioctl(mm):
        nonlocal ioindex
        fd,req,p=mm.r[:3];rc=sc.get('ioctl_results',[0]*8)[ioindex];ioindex+=1
        if req==GET:
            trace.append(['get_attributes',signed(fd)])
            if rc==0:mm.mem[p:p+44]=attrs
        elif req==SET:
            value=bytes(mm.mem[p:p+44]);trace.append(['set_attributes',signed(fd),value.hex()])
            if rc==0:attrs[:]=value
        elif req==AVAIL:
            trace.append(['available',signed(fd)]);mm.write(p,sc.get('available',0))
        else:raise AssertionError(hex(req))
        mm.r[0]=rc&0xffffffff
    def read_(mm):
        fd,p,n=mm.r[:3];trace.append(['read',signed(fd),n]);rc=sc['read_rc']
        if rc>0:mm.mem[p:p+rc]=payload[:rc]
        mm.r[0]=rc&0xffffffff
    def lock(mm):assert mm.r[0]==OBJ;trace.append(['lock']);mm.r[0]=0
    def unlock(mm):assert mm.r[0]==OBJ;trace.append(['unlock']);mm.r[0]=0
    def write(mm):
        nonlocal windex
        fd,p,n=mm.r[:3];assert p==BUF
        trace.append(['write',signed(fd),n,bytes(mm.mem[p:p+n]).hex()])
        rc,err=sc['writes'][windex];windex+=1
        if err is not None:mm.write(ERRADDR,err)
        mm.r[0]=rc&0xffffffff
    def err(mm):trace.append(['errno_pointer']);mm.r[0]=ERRADDR
    def sleep(mm):
        trace.append(['sleep_ms',mm.r[0]])
        if sc.get('sleep_errno') is not None:mm.write(ERRADDR,sc['sleep_errno'])
        mm.r[0]=0
    def free(mm):assert mm.r[0]==HEAP;trace.append(['release']);mm.r[0]=0
    def close(mm):trace.append(['close',signed(mm.r[0])]);mm.r[0]=sc.get('close_rc',0)&0xffffffff
    def destroy(mm):assert mm.r[0]==OBJ;trace.append(['mutex_destroy']);mm.r[0]=0
    def flush(mm):trace.append(['flush',signed(mm.r[0]),signed(mm.r[1])]);mm.r[0]=sc.get('flush_rc',0)&0xffffffff
    hooks={0x5936dc:open_,0x5a38a0:dup,0x5a60dc:init,0x597550:ioctl,
      0x5a8498:read_,0x5a8684:write,0x5931e4:err,0x5a6108:lock,0x5a66c4:unlock,
      0x10ef3c:sleep,0x593c8c:free,0x5a811c:close,0x5a60b8:destroy,0x5a4334:flush,
      0xfa0c4:lambda mm:None}
    entry={'open':0x10e0c8,'set_baud':0x10e518,'read':0x10e938,'write_legacy':0x10e6c0,'flush':0x10e994,'destroy':0x10e9a0}[op]
    args={'open':(OBJ,PATH),'set_baud':(OBJ,sc.get('new_baud',115200)),
       'read':(OBJ,BUF,sc['length']),'write_legacy':(OBJ,BUF,sc['length']),
       'flush':(OBJ,),'destroy':(OBJ,)}[op]
    for i,a in enumerate(args):m.r[i]=a&0xffffffff
    result=signed(m.run(entry,hooks=hooks,max_steps=10000))
    return dict(result=None if op=='destroy' else result,trace=trace,
       state=[bool(m.read(OBJ+28)),signed(m.read(OBJ+32)),m.read(OBJ+36)],
       attrs=bytes(attrs).hex(),buffer=bytes(m.mem[BUF:BUF+sc['length']]).hex() if op=='read' else None)

def new_run(op,sc):
    trace=[];attrs=bytearray(sc['attrs']);ioindex=0;windex=0;errors=[];errnum=I(sc.get('errno',0))
    owned=C.create_string_buffer(PATH_BYTES);payload=sc.get('payload',b'');buf=C.create_string_buffer(max(64,len(payload),sc['length']))
    C.memset(buf,0xa5,C.sizeof(buf))
    if op=='write_legacy' and payload:C.memmove(buf,payload,len(payload))
    u=Uart(C.addressof(owned) if sc.get('owned') else None,sc.get('fd',42),sc.get('baud',921600),sc.get('ready',True))
    @OPEN
    def open_(_,p,flags):
        if C.string_at(p)!=PATH_BYTES[:-1]:errors.append('bad path')
        trace.append(['open',C.string_at(p).decode(),flags]);return sc.get('open_rc',42)
    @DUP
    def dup(_,p):trace.append(['duplicate']);return None if sc.get('duplicate_fail') else C.addressof(owned)
    @INIT
    def init(_):trace.append(['mutex_init']);return sc.get('mutex_init_rc',0)
    @IOCTL
    def ioctl(_,fd,req,p):
        nonlocal ioindex
        rc=sc.get('ioctl_results',[0]*8)[ioindex];ioindex+=1
        if req==GET:
            trace.append(['get_attributes',fd])
            if rc==0:C.memmove(p,bytes(attrs),44)
        elif req==SET:
            value=C.string_at(p,44);trace.append(['set_attributes',fd,value.hex()])
            if rc==0:attrs[:]=value
        elif req==AVAIL:
            trace.append(['available',fd]);C.cast(p,C.POINTER(I))[0]=sc.get('available',0)
        else:errors.append('ioctl request')
        return rc
    @RW
    def read_(_,fd,p,n):
        trace.append(['read',fd,n]);rc=sc['read_rc']
        if rc>0:C.memmove(p,payload,rc)
        return rc
    @RW
    def write(_,fd,p,n):
        nonlocal windex
        trace.append(['write',fd,n,C.string_at(p,n).hex()]);rc,err=sc['writes'][windex];windex+=1
        if err is not None:errnum.value=err
        return rc
    @ERR
    def err(_):trace.append(['errno_pointer']);return C.addressof(errnum)
    @SLEEP
    def sleep(_,ms):
        trace.append(['sleep_ms',ms])
        if sc.get('sleep_errno') is not None:errnum.value=sc['sleep_errno']
    @VOID
    def lock(_):trace.append(['lock'])
    @VOID
    def unlock(_):trace.append(['unlock'])
    @VOID
    def destroy(_):trace.append(['mutex_destroy'])
    @FREE
    def free(_,p):
        if p!=C.addressof(owned):errors.append('bad release')
        trace.append(['release'])
    @CLOSE
    def close(_,fd):trace.append(['close',fd]);return sc.get('close_rc',0)
    @FLUSH
    def flush(_,fd,direction):trace.append(['flush',fd,direction]);return sc.get('flush_rc',0)
    ops=Ops(None,open_,dup,free,ioctl,read_,write,err,close,flush,init,lock,unlock,destroy,sleep)
    extra={'open':[PATH_BYTES],'set_baud':[sc.get('new_baud',115200)],'read':[buf,sc['length']],
       'write_legacy':[buf,sc['length']],'flush':[],'destroy':[]}[op]
    result=getattr(lib,'vn135_uart_'+op)(C.byref(u),C.byref(ops),*extra)
    assert not errors,errors
    return dict(result=None if op=='destroy' else result,trace=trace,state=[bool(u.path),u.fd,u.baud],
       attrs=bytes(attrs).hex(),buffer=C.string_at(buf,sc['length']).hex() if op=='read' else None)

def check(op,**kwargs):
    sc=dict(attrs=rng.randbytes(44),length=0);sc.update(kwargs)
    a=old_run(op,sc);b=new_run(op,sc)
    assert a==b,(op,sc,a,b)
    record(op)
    return b

for _ in range(256):
    baud=rng.getrandbits(32)
    for results in [[0,0],[-1,0],[0,-1]]:check('set_baud',new_baud=baud,ioctl_results=results)
for n in [0,1,7,9,11,32,64,256,4096]:
    payload=rng.randbytes(n)
    for avail in [0,1,n,4096,-1]:
        for io in [0,-1,7]:
            for rd in sorted(set([-1,0,n//2,n])):
                check('read',length=n,payload=payload,available=avail,ioctl_results=[io],read_rc=rd)
for n in [0,1,9,11,32,256]:
    payload=rng.randbytes(n)
    choices=[(n,0),(n,11),(-1,11),(-1,4),(-1,5),(max(n-1,0),None),(0,None)]
    for _ in range(256):
        writes=[rng.choice(choices) for _ in range(5)]
        check('write_legacy',length=n,payload=payload,writes=writes,errno=rng.choice([0,4,11]),sleep_errno=rng.choice([None,None,0,11]))
# Explicit critical traces: transient errors and short-write stale errno.
for name,writes in [('five_eagain',[(-1,11)]*5),('partial_stale_errno',[(4,None),(9,None)]+[(-1,5)]*3),('interrupted',[(-1,4)]*5)]:
    result=check('write_legacy',length=9,payload=b'123456789',errno=11,writes=writes)
    samples.append({'name':name,**result})
for _ in range(40):
    for fail in [-1,0,1,2,3]:
        results=[0]*4
        if fail>=0:results[fail]=-1
        for dupfail in [False,True]:
            check('open',fd=-1,baud=0,owned=False,ready=False,open_rc=42,ioctl_results=results,duplicate_fail=dupfail)
for open_rc in [-1,-2,-2147483648,0,1,2147483647]:
    check('open',fd=-1,baud=0,ready=False,open_rc=open_rc)
for fd in [-1,0,1,42,2147483647]:
    for owned in [False,True]:
        for close_rc in [0,-1]:check('destroy',fd=fd,owned=owned,close_rc=close_rc)
    for result in [-1,0,1,100]:check('flush',fd=fd,flush_rc=result)
result=dict(passed=True,reference_sha256=SHA,cases=counts,total_cases=sum(counts.values()),
 elapsed_seconds=round(time.monotonic()-start,3),examples=samples,
 method='C compared to complete unchanged A32 UART routines with explicitly traced Linux/POSIX boundary hooks',
 hardware_tested=False,full_miner_tested=False,
 limits=['Local subset interpreter, not an independent emulator or proof for all inputs.',
 'read/write/ioctl/open/memory/mutex/sleep/errno are deterministic boundary hooks; diagnostics omitted.',
 'New callback API uses an explicit fd/path context, not the vendor ARM mutex ABI.',
 'Occupied-context, null callback, pointer/capacity and repeated-destroy guards are new API behavior.',
 'Legacy write retries preserve even the stale-errno short-write behavior. No safety endorsement.'])
assert not callback_failures, callback_failures
(ROOT/'build/stage5-uart-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['passed','total_cases','cases','elapsed_seconds']},indent=2))
