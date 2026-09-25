#!/usr/bin/env python3
"""Compare new C with actual RX and ring-pop instructions on stable configs.
Counts are cases, not all-input proof, and not hardware/CRC/share acceptance.
"""
from pathlib import Path
import ctypes as C, json, random, struct, time
from work_rx_oracle import RxOracle, ROOT, SHA
U=C.c_uint32; B=C.c_uint8; Z=C.c_size_t; P=C.POINTER(B)
class Policy(C.Structure):
    _fields_=[(n,U) for n in ('board_selector','chip_selector','special_mode','variant','payload_size','frame_size')]
class Message(C.Structure):
    _fields_=[(n,U) for n in ('kind','consumed','payload_size','chain_id','register_value','chip_address','register_address','crc5_field','job_slot')]+[('payload',B*9)]
lib=C.CDLL(str(ROOT/'build/libvn135_recovered.so'))
lib.vn135_work_rx_policy_init.argtypes=[C.POINTER(Policy),U,U,U];lib.vn135_work_rx_policy_init.restype=C.c_int
lib.vn135_work_rx_filtered_register.argtypes=[U];lib.vn135_work_rx_filtered_register.restype=U
lib.vn135_work_rx_job_slot.argtypes=[U,U,P,Z,C.POINTER(U)];lib.vn135_work_rx_job_slot.restype=C.c_int
lib.vn135_work_rx_next.argtypes=[C.POINTER(Policy),U,P,Z,C.POINTER(Message)];lib.vn135_work_rx_next.restype=C.c_int
oracle=RxOracle();rng=random.Random(0x1350606);counts={};samples=[];t0=time.monotonic()
def record(k):counts[k]=counts.get(k,0)+1

def check_policy(board,chip,special):
    p=Policy();assert lib.vn135_work_rx_policy_init(C.byref(p),board,chip,special)==0
    variant,minimum=oracle.policy(board,chip,special)
    assert (p.variant,p.frame_size)==(variant,minimum),(board,chip,special)
    assert p.payload_size==minimum-2
    record('layout_selection')
    return p

selectors=list(range(10))+[0x1398,0x80000000,0xffffffff]
for board in (0,1,2,3,4,5,0xffffffff):
    for chip in selectors:
        for special in (0,1,2,0xffffffff):check_policy(board,chip,special)
for chip in selectors+[rng.getrandbits(32) for _ in range(128)]:
    assert lib.vn135_work_rx_filtered_register(chip)==oracle.filtered_register(chip)
    record('register_filter_dispatch')
for chip in selectors:
    for variant in (0,1,2):
        for _ in range(32):
            payload=rng.randbytes(7+variant);arr=(B*len(payload)).from_buffer_copy(payload);slot=U(99)
            assert lib.vn135_work_rx_job_slot(chip,variant,arr,len(payload),C.byref(slot))==0
            assert slot.value==oracle.job_slot(chip,variant,payload)
            record('nonce_job_slot_bits')

def check_frame(cfg,data,head):
    board,chip,special=cfg;chain=rng.getrandbits(32)
    p=Policy();lib.vn135_work_rx_policy_init(C.byref(p),board,chip,special)
    original=oracle.frame(board,chip,special,chain,data,head)
    buf=(B*max(len(data),1))();buf[:len(data)]=data;got=Message()
    code=lib.vn135_work_rx_next(C.byref(p),chain,buf,len(data),C.byref(got))
    assert (code,got.kind,got.consumed,got.chain_id)==(original['kind'],original['kind'],original['consumed'],original['chain']), (cfg,data.hex(),original,list(bytes(got)))
    assert bytes(buf[:len(data)])==data,'C modified input'
    assert bytes(got.payload[:got.payload_size])==original['payload']
    if code in (2,4):
        for name in ('register_value','chip_address','register_address','crc5_field'):
            assert getattr(got,name)==original[name],(name,cfg,data.hex(),original,getattr(got,name))
    if code==3:assert got.job_slot==original['job_slot']
    record({0:'frame_incomplete',1:'frame_noise',2:'register_enqueued',3:'nonce_raw',4:'register_filtered'}[code])
    if len(samples)<12:samples.append({'config':cfg,'bytes':data.hex(),'kind':code,'consumed':got.consumed})

configs=[(0,0,0),(4,6,0),(1,7,0),(1,2,0),(1,4,0),(1,5,0),
         (0,5,0),(1,7,1),(1,2,1),(4,6,2),(0,0,1),(1,0xffffffff,0)]
for cfg in configs:
    p=Policy();lib.vn135_work_rx_policy_init(C.byref(p),*cfg);n=p.frame_size
    for size in range(n):
        for prefix in (b'\xaa\x55',b'\xaa\xaa',b'\0\x55'):
            check_frame(cfg,(prefix+rng.randbytes(n))[:size],(size*7)%64)
    # Every possible classification/checksum byte; both normal and filtered register.
    for last in range(256):
        payload=bytearray(rng.randbytes(p.payload_size));payload[-1]=last
        field=(1 if not cfg[2] and p.variant==1 else 0)+5
        if last%2==0:payload[field]=0x40
        check_frame(cfg,b'\xaa\x55'+bytes(payload),rng.randrange(64))
    for size in (n,n+1,n+11):
        for prefix in (b'\0\x55',b'\xaa\xaa',b'\xaa\x54',b'\x55\xaa'):
            check_frame(cfg,(prefix+rng.randbytes(size))[:size],rng.randrange(64))
    # Suffix preservation and wrap at every ring position.
    for head in range(64):
        check_frame(cfg,b'\xaa\x55'+rng.randbytes(p.payload_size+5),head)

result={'status':'PASS','reference_sha256':SHA,'cases':counts,'new_differential_cases':sum(counts.values()),
        'wall_seconds':round(time.monotonic()-t0,3),'sample_cases':samples,
        'scope':'Stable-selector RX layout; original prefix/pop/normal+special register paths, filter dispatcher/callees and job-slot bit extraction. Actual original ring pops execute.',
        'injected':['board/chip/special getter values','memcpy','mutex unlock','register enqueue'],
        'not_verified':['model name mapping','CRC verification','actual job lookup','nonce validation','threading','UART device','accepted shares']}
(ROOT/'build/stage6-rx-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
