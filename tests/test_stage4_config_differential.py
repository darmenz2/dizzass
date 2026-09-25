#!/usr/bin/env python3
"""Original SET_CONFIG + original CRC + original cache versus compiled modules."""
from cache_oracle import *
SEND=C.CFUNCTYPE(C.c_int,ptr,C.POINTER(C.c_uint8),sz)
class Sender(C.Structure):_fields_=[('context',ptr),('send',SEND)]
class ChipRef(C.Structure):_fields_=[('index',i32),('address',u32)]
fn=lib.vn135_bm1398_set_config
fn.argtypes=[P,i32,u32,C.POINTER(ChipRef),u32,u32,C.POINTER(Sender)]
case_counts=collections.Counter();examples=[];beg=time.monotonic()
rng=random.Random(0x1350401)
for selector in range(8):
    p=Pair();assert p.init(selector,2,3)==0
    vectors=[]
    # Header behavior ==1 differs from cache fanout !=0; exercise all modes.
    for mode in [0,1,2,0xffffffff]:
        for status in [0,-1,-5,1]:
            for reg in [0,8,0x18,0x25,0xfc,0xff,0x108,0xffffffff]:
                vectors.append((mode,1,reg,1,0x103,False,status,True))
    for _ in range(128):
        vectors.append((rng.getrandbits(3),rng.choice([-1,0,1,2]),
            rng.choice([8,0x14,0x25,0x54,0xf0,256,0xffffffff]),rng.choice([-1,0,1,2,3]),
            rng.getrandbits(32),rng.choice([True,False]),rng.choice([0,0,0,-1,7]),rng.choice([True,False])))
    for mode,chain,reg,index,wire,null_chip,send_status,ready in vectors:
        value=rng.getrandbits(32)
        p.cache.initialized=int(ready);m.write(GLOBAL_READY,int(ready),1)
        old_trace=[];new_trace=[]
        context=m.DATA_BASE+0xd000;chip_addr=context+0x100
        m.write(context+24,chain)
        m.write(chip_addr,index);m.write(chip_addr+4,wire)
        def send_original(mm):
            assert mm.r[0]==context and mm.r[2]==9
            old_trace.append(bytes(mm.mem[mm.r[1]:mm.r[1]+9]).hex())
            mm.r[0]=send_status&0xffffffff
        m.reset((context,mode,0 if null_chip else chip_addr,reg,value))
        old=signed(m.run(0xee8e4,hooks={0xd26ac:send_original,0xfa0c4:lambda _:None}))
        @SEND
        def send_c(_,data,n):
            new_trace.append(C.string_at(data,n).hex());return send_status
        cref=ChipRef(index,wire);sender=Sender(None,send_c)
        new=fn(C.byref(p.cache),chain,mode,None if null_chip else C.byref(cref),reg,value,C.byref(sender))
        assert (old,old_trace)==(new,new_trace),(selector,mode,chain,reg,index,old,new,old_trace,new_trace)
        p.compare()
        label='transport failure: one dispatch, no cache mutation' if send_status else (
            'dispatch success, cache success' if new==0 else 'dispatch success, cache failure')
        case_counts[label]+=1
        if len(examples)<6 and selector==0 and mode in [0,1,2] and send_status==0:
            examples.append({'mode':mode,'register':hex(reg),'transport_result':send_status,'return':new,'packet':new_trace[0]})
    p.destroy()
result={'passed':True,'total_cases':sum(case_counts.values()),'cases':dict(case_counts),
        'seconds':round(time.monotonic()-beg,3),'reference_sha256':EXPECTED,'examples':examples,
        'method':'Complete original 0xee8e4, CRC5 and cache functions run together; only send boundary and diagnostics intercepted',
        'hardware_tested':False,'full_miner_tested':False,
        'limits':['Local A32 interpreter; no independent CPU certification.',
                  'The 0xd26ac transport boundary is injected; no UART or chip acknowledgement.',
                  'Pointer/context layout adapted. Added invalid API guards are not vendor behavior.',
                  'All original cache memory changes and return codes are compared; timing/log text omitted.']}
(ROOT/'build/stage4-config-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
