#!/usr/bin/env python3
"""Original AML TX + UART TX together, versus recovered C composition.
Original 0x10e6c0 is NOT intercepted: nested retries, sleeps and mutex calls
execute in the local instruction interpreter. Actual libc/syscalls are hooks.
"""
from pathlib import Path
import ctypes as C
import hashlib,json,random,sys,time,collections
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32,signed
callback_failures=[]
sys.unraisablehook=lambda e: callback_failures.append(repr(e.exc_value))
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
assert hashlib.sha256(elf.data).hexdigest()==SHA
lib=C.CDLL(str(ROOT/'build/libvn135_recovered.so'))
P=C.c_void_p;I=C.c_int32;U=C.c_uint32;Z=C.c_size_t
class Uart(C.Structure):_fields_=[('path',P),('fd',I),('baud',U),('ready',C.c_bool)]
OPEN=C.CFUNCTYPE(I,P,P,U);DUP=C.CFUNCTYPE(P,P,P);FREE=C.CFUNCTYPE(None,P,P)
IOCTL=C.CFUNCTYPE(I,P,I,U,P);RW=C.CFUNCTYPE(I,P,I,P,U);ERR=C.CFUNCTYPE(P,P)
CLOSE=C.CFUNCTYPE(I,P,I);FLUSH=C.CFUNCTYPE(I,P,I,I);INIT=C.CFUNCTYPE(I,P)
VOID=C.CFUNCTYPE(None,P);SLEEP=C.CFUNCTYPE(None,P,U)
class Ops(C.Structure):
    _fields_=[('context',P),('open',OPEN),('duplicate',DUP),('release',FREE),('ioctl',IOCTL),('read',RW),('write',RW),('error_number',ERR),('close',CLOSE),('flush',FLUSH),('mutex_init',INIT),('lock',VOID),('unlock',VOID),('mutex_destroy',VOID),('sleep_ms',SLEEP)]
ALLOC=C.CFUNCTYPE(P,P,Z);AMLWRITE=C.CFUNCTYPE(I,P,P,P,U)
class Aml(C.Structure):_fields_=[('context',P),('allocate',ALLOC),('release',FREE),('lock',VOID),('unlock',VOID),('write',AMLWRITE)]
lib.vn135_aml_send_command.argtypes=[P,C.POINTER(Aml),P,Z];lib.vn135_aml_send_command.restype=I
lib.vn135_uart_write_legacy.argtypes=[C.POINTER(Uart),C.POINTER(Ops),P,Z];lib.vn135_uart_write_legacy.restype=I
m=ARM32(elf);OBJ=m.DATA_BASE;BUF=OBJ+0x1000;HEAP=OBJ+0x3000;ERRPTR=OBJ+0x5000
outer=(0x1180c8+8+int.from_bytes(elf.read(0x11817c,4),'little'))&0xffffffff
assert outer!=OBJ
rng=random.Random(0x1350506);cases=collections.Counter();examples=[];beg=time.monotonic()
def original(payload,scenario):
    trace=[];index=0;n=len(payload)+2
    m.reset((0 if scenario=='no_uart' else OBJ,BUF,len(payload)))
    m.mem[OBJ:OBJ+40]=b'\0'*40;m.write(OBJ+32,17)
    m.mem[BUF:BUF+len(payload)]=payload;m.write(ERRPTR,11)
    def malloc(mm):
        assert mm.r[0]==n;trace.append(['allocate',n]);mm.r[0]=0 if scenario=='no_memory' else HEAP
    def copy(mm):
        dst,src,size=mm.r[:3];assert(dst,src,size)==(HEAP+2,BUF,len(payload))
        mm.mem[dst:dst+size]=mm.mem[src:src+size];mm.r[0]=dst
    def lock(mm):
        assert mm.r[0] in (OBJ,outer);trace.append(['lock','inner' if mm.r[0]==OBJ else 'outer']);mm.r[0]=0
    def unlock(mm):
        assert mm.r[0] in (OBJ,outer);trace.append(['unlock','inner' if mm.r[0]==OBJ else 'outer']);mm.r[0]=0
    def write(mm):
        nonlocal index
        assert(mm.r[0],mm.r[1],mm.r[2])==(17,HEAP,n)
        trace.append(['write',bytes(mm.mem[HEAP:HEAP+n]).hex()])
        rc,e=outcomes(scenario,n)[index];index+=1
        if e is not None:mm.write(ERRPTR,e)
        mm.r[0]=rc&0xffffffff
    def err(mm):trace.append(['errno_pointer']);mm.r[0]=ERRPTR
    def sleep(mm):assert mm.r[0]==20;trace.append(['sleep_ms',20]);mm.r[0]=0
    def free(mm):assert mm.r[0]==HEAP;trace.append(['release']);mm.r[0]=0
    rc=signed(m.run(0x117f7c,hooks={0x5940ec:malloc,0x5a2ee8:copy,0x5a6108:lock,0x5a66c4:unlock,0x5a8684:write,0x5931e4:err,0x10ef3c:sleep,0x593c8c:free,0xfa0c4:lambda _:None},max_steps=10000))
    return rc,trace

def outcomes(s,n):
    return {'exact':[(n,None)],'eagain_then_success':[(-1,11),(n,None)],
      'exhausted':[(-1,11)]*5,'positive_short_stale_errno':[(1,None),(n,None)],
      'short_nonretry':[(1,5)],'hard_error':[(-1,5)],'zero_exhausted':[(0,11)]*5,
      'interrupted':[(-1,4)],'overreport':[(n+1,0)],'late_success':[(-1,11)]*4+[(n,None)],
      'changed_error':[(-1,11),(-1,9)],'no_uart':[],'no_memory':[]}[s]

def recovered(payload,scenario):
    trace=[];index=0;error=I(11);n=len(payload)+2
    storage=C.create_string_buffer(n);src=C.create_string_buffer(payload);u=Uart(None,17,115200,True)
    @RW
    def write(_,fd,buf,count):
        nonlocal index
        assert fd==17 and count==n;trace.append(['write',C.string_at(buf,count).hex()])
        rc,e=outcomes(scenario,n)[index];index+=1
        if e is not None:error.value=e
        return rc
    @ERR
    def err(_):trace.append(['errno_pointer']);return C.addressof(error)
    @VOID
    def innerlock(_):trace.append(['lock','inner'])
    @VOID
    def innerunlock(_):trace.append(['unlock','inner'])
    @SLEEP
    def sleep(_,ms):trace.append(['sleep_ms',ms])
    o=Ops();o.write=write;o.error_number=err;o.lock=innerlock;o.unlock=innerunlock;o.sleep_ms=sleep
    @ALLOC
    def alloc(_,size):assert size==n;trace.append(['allocate',size]);return None if scenario=='no_memory' else C.addressof(storage)
    @FREE
    def free(_,address):assert address==C.addressof(storage);trace.append(['release'])
    @VOID
    def outerlock(_):trace.append(['lock','outer'])
    @VOID
    def outerunlock(_):trace.append(['unlock','outer'])
    @AMLWRITE
    def uartwrite(_,uart,buf,count):
        assert uart==C.addressof(u)
        return lib.vn135_uart_write_legacy(C.byref(u),C.byref(o),buf,count)
    a=Aml(None,alloc,free,outerlock,outerunlock,uartwrite)
    rc=lib.vn135_aml_send_command(None if scenario=='no_uart' else C.byref(u),C.byref(a),src,len(payload))
    return rc,trace

for scenario in ['exact','eagain_then_success','exhausted','positive_short_stale_errno','short_nonretry','hard_error','zero_exhausted','interrupted','overreport','late_success','changed_error','no_uart','no_memory']:
    for length in [0,1,2,7,9,10,11,16,64,128,255,256,1024]+[rng.randrange(1025) for _ in range(40)]:
        payload=rng.randbytes(length)
        old=original(payload,scenario);new=recovered(payload,scenario)
        assert old==new,(scenario,length,old,new);cases[scenario]+=1
        if length==9:examples.append({'scenario':scenario,'payload':payload.hex(),'return':new[0],'trace':new[1]})
result={'passed':True,'total_cases':sum(cases.values()),'cases':dict(cases),'reference_sha256':SHA,'elapsed_seconds':round(time.monotonic()-beg,3),
 'examples':examples,'executed_original_routines':['0x117f7c','0x10e6c0'],
 'method':'Original AML send executes original UART write; C AML callback composes recovered UART. Final OS write, allocation, locks, delay and logging intercepted.',
 'correction_to_stage3':'AML invokes its UART helper once, not necessarily the OS write once. The helper can retry the entire frame up to five times.',
 'hardware_tested':False,'mutex_concurrency_tested':False,'physical_uart_tested':False}
assert not callback_failures, callback_failures
(ROOT/'build/stage5-aml-uart-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['passed','total_cases','cases','elapsed_seconds']},indent=2))
