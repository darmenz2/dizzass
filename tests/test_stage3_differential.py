#!/usr/bin/env python3
"""Stage 3: new host C versus bounded execution of unchanged original ARM bytes.
No process emulation or hardware I/O. All external calls below are explicit.
"""
from pathlib import Path
import ctypes as C
import hashlib,json,math,random,struct,sys,time
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32,signed
from arm32_vfp_subset import ARM32VFP
EXPECTED='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
assert hashlib.sha256(elf.data).hexdigest()==EXPECTED
lib=C.CDLL(str(ROOT/'build/libvn135_recovered.so'))
u32=C.c_uint32;i32=C.c_int32;u8=C.c_uint8;sz=C.c_size_t;ptr=C.c_void_p
rng=random.Random(0x1350301);counts={};beg=time.monotonic();samples=[]
def record(key):counts[key]=counts.get(key,0)+1
class Limits(C.Structure):
    _fields_=[(s,C.c_double) for s in ['reference','maximum','reserved16','minimum']]+[(s,i32) for s in ['ref','feedback','post','reserved44']]+[('error',C.c_double)]
class Result(C.Structure):
    _fields_=[('vco',C.c_double)]+[(s,i32) for s in ['ref','feedback','post1','post2','written','reserved28']]
assert C.sizeof(Limits)==56 and C.sizeof(Result)==32
real=Limits.in_dll(lib,'vn135_bm1398_pll_limits')
assert bytes(real)==elf.read(0x5ebea8,56)
# Both PC-relative materializations resolve to this record.
for insn,literal in [(0xeb8f0,0xebcbc),(0xebd54,0xec170)]:
    assert ((int.from_bytes(elf.read(literal,4),'little')+insn+8)&0xffffffff)==0x5ebea8
m=ARM32VFP(elf)
frequencies=[0.,0.001,0.1,0.5,1.,7.,25.,50.,99.9,100.,100.1,13325.,20000.,1e9]
frequencies += [float(x) for x in range(200,1001,5)]
for x in [100.,400.,500.,625.,3125.,13325.]:
    frequencies += [math.nextafter(x,-math.inf),x,math.nextafter(x,math.inf)]
vectors=[(Limits.from_buffer_copy(bytes(real)),f) for f in frequencies]
for _ in range(384):
    cfg=Limits(rng.choice([19.2,24.,25.,50.]),rng.choice([1000.,3200.,6000.,14000.]),0.,
       rng.choice([0.,600.,1600.,2000.]),rng.randrange(0,5),rng.choice([0,7,8,120,250,512,4095]),
       rng.randrange(-1,9),0,rng.choice([-1.,0.,0.1,2.5,1e9]))
    vectors.append((cfg,rng.uniform(0.,20000.)))
# Edge cases for VCO guards and feedback conversion saturation.
for vmin,vmax in [(0.,0.),(2000.,2000.),(3125.,3125.),(3200.,3200.),(13325.,13325.),(4000.,2000.)]:
    for freq in [0.,25.,400.,500.,2000.,3125.,13325.]:
        vectors.append((Limits(25.,vmax,0.,vmin,2,4095,7,0,2.5),freq))
for name,entry in [('legacy',0xff288),('round4',0xff660)]:
    fn=getattr(lib,'vn135_pll_search_'+name)
    fn.argtypes=[C.POINTER(Limits),C.c_double,C.POINTER(Result)];fn.restype=C.c_int
    for cfg,freq in vectors:
        out=Result();C.memset(C.byref(out),0xa5,32)
        new=fn(C.byref(cfg),freq,C.byref(out))
        m.reset((m.DATA_BASE,m.DATA_BASE+256));m.set_d(0,freq)
        m.mem[m.DATA_BASE:m.DATA_BASE+56]=bytes(cfg)
        m.mem[m.DATA_BASE+256:m.DATA_BASE+288]=b'\xa5'*32
        old=signed(m.run(entry,hooks={0xfa0c4:lambda x:None},max_steps=2500000))
        raw=bytes(m.mem[m.DATA_BASE+256:m.DATA_BASE+288])
        assert (old,raw)==(new,bytes(out)),(name,freq,bytes(cfg).hex(),old,new,raw.hex(),bytes(out).hex())
        record('PLL '+name+': return and all 32 result bytes')
        if bytes(cfg)==bytes(real) and freq in [0.,200.,400.,500.,625.,1000.]:
            samples.append({'algorithm':name,'requested_mhz':freq,'return':new,'result_hex':raw.hex(),
               'vco_mhz':out.vco,'dividers':[out.ref,out.feedback,out.post1,out.post2]})

# Confirm parameter packing precisely at the original SET_CONFIG call boundary.
pack=lib.vn135_bm1398_pll_parameter_word;pack.argtypes=[u32]*4;pack.restype=u32
m=ARM32(elf)
for values in [(0,0,0,0),(2,250,7,7),(63,4095,7,7),(64,4096,8,8),(0xffffffff,)*4]+[tuple(rng.getrandbits(32) for _ in range(4)) for _ in range(512)]:
    m.reset();ctx=m.DATA_BASE+0x1000;m.r[4]=ctx
    for index,value in enumerate(values):m.write(m.r[13]+32+index*4,value)
    m.run(0xec01c,stop=0xee8e4)
    assert (m.r[0],m.r[1],m.r[2],m.r[3],m.read(m.r[13]))==(ctx,1,0,8,pack(*values))
    record('PLL register 0x08 word at SET_CONFIG boundary')

mask=lib.vn135_aml_chain_mask;mask.argtypes=[i32,u32,u32];mask.restype=u32
for model in [0,0x1398,0x1489,0x1368,0xffffffff]:
    for mode in [0,1,2,0xffffffff]:
        for index in list(range(-4,40))+[255,256,257,-255,-256,-257,2147483647,-2147483648]:
            def lookup(machine):machine.r[0]=model
            m.reset((index,mode));old=m.run(0x118180,hooks={0xfdfcc:lookup})
            assert old==mask(index,mode,model),(index,mode,model,old,mask(index,mode,model))
            record('AML chain mask with injected model lookup')

ALLOC=C.CFUNCTYPE(ptr,ptr,sz);FREE=C.CFUNCTYPE(None,ptr,ptr)
LOCK=C.CFUNCTYPE(None,ptr);WRITE=C.CFUNCTYPE(i32,ptr,ptr,C.POINTER(u8),u32)
class Transport(C.Structure):
    _fields_=[('context',ptr),('allocate',ALLOC),('release',FREE),('lock',LOCK),('unlock',LOCK),('write',WRITE)]
send=lib.vn135_aml_send_command;send.argtypes=[ptr,C.POINTER(Transport),C.POINTER(u8),sz];send.restype=C.c_int
frame=lib.vn135_aml_frame_command;frame.argtypes=[C.POINTER(u8),sz,C.POINTER(u8),sz];frame.restype=C.c_int
trace_samples=[]
lengths=[0,1,2,8,9,10,31,64,127,255,256,1024,4096]+[rng.randrange(0,512) for _ in range(40)]
for length in lengths:
    payload=bytes(rng.getrandbits(8) for _ in range(length));src=(u8*max(1,length))(*payload)
    for condition in ['exact','short','negative','oversize','zero','alloc-fail','no-uart']:
        old_trace=[];new_trace=[];callback_errors=[];keep=[]
        total=length+2;uart=0 if condition=='no-uart' else 0x1234
        result_count={'exact':total,'short':total-1,'negative':-1,'oversize':total+1,'zero':0,'alloc-fail':0,'no-uart':0}[condition]
        heap=m.DATA_BASE+0x4000;source=m.DATA_BASE+0x1000
        def malloc(mm):
            old_trace.append(['allocate',mm.r[0]]);assert mm.r[0]==total
            mm.r[0]=0 if condition=='alloc-fail' else heap
        def memcpy(mm):
            dest,source_,n=mm.r[:3]
            assert (dest,source_,n)==(heap+2,source,length)
            mm.mem[dest:dest+n]=mm.mem[source_:source_+n];mm.r[0]=dest
        def lock(mm):old_trace.append(['lock']);mm.r[0]=0
        def write(mm):
            assert mm.r[:3]==[uart,heap,total]
            old_trace.append(['write',uart,bytes(mm.mem[heap:heap+total]).hex()]);mm.r[0]=result_count&0xffffffff
        def unlock(mm):old_trace.append(['unlock']);mm.r[0]=0
        def free(mm):assert mm.r[0]==heap;old_trace.append(['release']);mm.r[0]=0
        m.reset((uart,source,length));m.mem[source:source+length]=payload
        old=signed(m.run(0x117f7c,hooks={0x5940ec:malloc,0x5a2ee8:memcpy,0x5a6108:lock,
            0x10e6c0:write,0x5a66c4:unlock,0x593c8c:free,0xfa0c4:lambda mm:None}))
        @ALLOC
        def allocate_c(_,n):
            new_trace.append(['allocate',n])
            if condition=='alloc-fail':return None
            buf=C.create_string_buffer(n);keep.append(buf);return C.addressof(buf)
        @FREE
        def free_c(_,address):
            if not keep or address!=C.addressof(keep[0]):callback_errors.append('bad release pointer')
            new_trace.append(['release'])
        @LOCK
        def lock_c(_):new_trace.append(['lock'])
        @LOCK
        def unlock_c(_):new_trace.append(['unlock'])
        @WRITE
        def write_c(_,uart_,address,n):
            new_trace.append(['write',uart_,C.string_at(address,n).hex()]);return result_count
        t=Transport(None,allocate_c,free_c,lock_c,unlock_c,write_c)
        new=send(uart,C.byref(t),src,length)
        assert not callback_errors,callback_errors
        assert (old,old_trace)==(new,new_trace),(condition,length,old,new,old_trace,new_trace)
        record('AML send: return, allocation, lock, write bytes, unlock, release')
        if condition=='exact':
            output=(u8*(length+2))();assert frame(src,length,output,length+2)==0
            original_write=[x for x in old_trace if x[0]=='write'][0]
            assert bytes(output).hex()==original_write[2]
            record('AML pure framing versus original write buffer')
        if length==9:trace_samples.append({'condition':condition,'return':new,'trace':new_trace})
result={'reference_sha256':EXPECTED,'passed':True,'cases':counts,'total_cases':sum(counts.values()),
    'elapsed_seconds':round(time.monotonic()-beg,3),'pll_constraint_record':{'address':'0x5ebea8','hex':bytes(real).hex(),'model_mapping_to_T21_confirmed':False},
    'pll_vectors':samples,'aml_trace_examples':trace_samples,
    'method':'New host C compared with unchanged original A32 instructions under local finite-input VFP/A32 interpreter',
    'hardware_tested':False,'full_miner_tested':False,
    'limits':['Local subset interpreter is not an independently certified CPU emulator.',
    'VFP tests cover finite normal numbers/default rounding, not FPSCR exception behavior or denormals.',
    'Original logging calls are skipped; allocation/copy/serialization/UART/model lookup are injected and traced.',
    'New API pointer/capacity/finite-input/iteration guards are tested separately, not claimed vendor behavior.',
    'PLL packing tested at call boundary, not original full cache/write caller or physical PLL.',
    'No claim of timing, multitasking, UART hardware, T21 model dispatch, mining or autotune equivalence.']}
(ROOT/'build/stage3-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'passed':True,'total_cases':result['total_cases'],'cases':counts,'seconds':result['elapsed_seconds']},indent=2))
