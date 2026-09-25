#!/usr/bin/env python3
"""NEW adapter integration: fragmented byte streams versus original RX slices.
This is not another reconstructed vendor function; no UART timing is modeled.
"""
import ctypes as C, json, random, time
from work_rx_oracle import RxOracle, ROOT, SHA
U=C.c_uint32;B=C.c_uint8;Z=C.c_size_t
class Policy(C.Structure):
    _fields_=[(n,U) for n in ('board_selector','chip_selector','special_mode','variant','payload_size','frame_size')]
class Message(C.Structure):
    _fields_=[(n,U) for n in ('kind','consumed','payload_size','chain_id','register_value','chip_address','register_address','crc5_field','job_slot')]+[('payload',B*9)]
class Stream(C.Structure):_fields_=[('policy',Policy),('chain_id',U),('used',U),('pending',B*11)]
lib=C.CDLL(str(ROOT/'build/libvn135_recovered.so'))
lib.vn135_work_rx_stream_init.argtypes=[C.POINTER(Stream),U,U,U,U];lib.vn135_work_rx_stream_init.restype=C.c_int
lib.vn135_work_rx_stream_feed.argtypes=[C.POINTER(Stream),C.POINTER(B),Z,C.POINTER(Z),C.POINTER(Message)];lib.vn135_work_rx_stream_feed.restype=C.c_int
rng=random.Random(0x613500);o=RxOracle();cases=0;events=0;chunk_replays=0;t0=time.monotonic()
for cfg in ((0,0,0),(4,6,0),(1,7,0),(1,2,0),(1,4,0),(1,5,0),(1,7,1),(1,2,1)):
    mode,n=o.policy(*cfg)
    for index in range(12):
        chain=rng.getrandbits(32);data=bytearray()
        for j in range(8):
            if j%3==0:data+=b'\xaa\xaa\x55'+rng.randbytes(3)
            data+=b'\xaa\x55'+rng.randbytes(n-2)
            if j%2==0:data+=rng.randbytes(2)
        data+=b'\xaa\x55'+rng.randbytes(index%(n-2))
        data=bytes(data);expected=[];pos=0
        while pos<len(data):
            result=o.frame(*cfg,chain,data[pos:pos+64],head=pos%64)
            if result['kind']==0:break
            expected.append(result);pos+=result['consumed']
        events+=len(expected);cases+=1
        for fragment in (1,2,3,7,11,23,len(data)):
            s=Stream();assert lib.vn135_work_rx_stream_init(C.byref(s),chain,*cfg)==0
            at=0;outindex=0
            while at<len(data):
                part=data[at:at+fragment];buf=(B*len(part)).from_buffer_copy(part);used=Z(999);msg=Message()
                rc=lib.vn135_work_rx_stream_feed(C.byref(s),buf,len(part),C.byref(used),C.byref(msg))
                assert rc>=0 and 0<used.value<=len(part);at+=used.value
                if rc==0:continue
                want=expected[outindex];outindex+=1
                assert (rc,msg.kind,msg.consumed,msg.chain_id)==(want['kind'],want['kind'],want['consumed'],want['chain'])
                assert bytes(msg.payload[:msg.payload_size])==want['payload']
                if rc in (2,4):
                    for k in ('register_value','chip_address','register_address','crc5_field'):assert getattr(msg,k)==want[k]
                if rc==3:assert msg.job_slot==want['job_slot']
            assert outindex==len(expected) and bytes(s.pending[:s.used])==data[pos:]
            chunk_replays+=1
result={'status':'PASS','reference_sha256':SHA,'distinct_byte_streams':cases,
        'original_parser_events':events,'chunking_replays':chunk_replays,
        'new_adapter_not_vendor_function':True,'wall_seconds':round(time.monotonic()-t0,3)}
(ROOT/'build/stage6-stream-differential-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
