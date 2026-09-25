#!/usr/bin/env python3
"""Original instructions vs new C. Each bounded group writes its own results.
Only memcpy and chip/core attribution are injected in candidate preparation.
Original SHA initialization, block compression and update execute, not hooks.
"""
import argparse,ctypes as C,hashlib,json,random,struct,time
from nonce_oracle import NonceOracle,ROOT,SHA
U=C.c_uint32;B=C.c_uint8;Z=C.c_size_t;P=C.POINTER(B)
ID=C.CFUNCTYPE(U,C.c_void_p,U)
class Attr(C.Structure):_fields_=[('context',C.c_void_p),('chip',ID),('core',ID)]
class Job(C.Structure):_fields_=[('bytes',B*168)]
class Candidate(C.Structure):
    _fields_=[(n,U) for n in ('chain_id','chip_id','core_id','job_word_a4','job_slot','version_word','job_word_70','job_word_74','nonce')]+[('midstate',U*8)]
class Result(C.Structure):_fields_=[('candidate',Candidate),('compression_block',B*64)]
def load(path):
    lib=C.CDLL(str(path))
    lib.vn135_work_nonce_prepare.argtypes=[U,U,U,P,Z,C.POINTER(Job),C.POINTER(Attr),C.POINTER(Result)];lib.vn135_work_nonce_prepare.restype=C.c_int
    lib.vn135_work_nonce_version_bits.argtypes=[U,P,Z,C.POINTER(U)];lib.vn135_work_nonce_version_bits.restype=C.c_int
    lib.vn135_sha256_midstate64.argtypes=[P,C.POINTER(U)];lib.vn135_sha256_midstate64.restype=C.c_int
    lib.vn135_sha256_compress_block.argtypes=[C.POINTER(U),P];lib.vn135_sha256_compress_block.restype=C.c_int
    lib.vn135_bm1398_core_from_nonce.argtypes=[U,U];lib.vn135_bm1398_core_from_nonce.restype=U
    return lib

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('group',choices=['prepare','version','sha','core'])
    ap.add_argument('--library',type=str,default=str(ROOT/'build/libvn135_recovered.so'))
    ap.add_argument('--tag',default='gcc');args=ap.parse_args()
    lib=load(args.library);o=NonceOracle();rng=random.Random(0x1350707);counts={};samples=[];t0=time.monotonic()
    def rec(key):counts[key]=counts.get(key,0)+1
    if args.group=='prepare':
        callback_errors=[]
        for variant in range(3):
            for chip in list(range(8))+[0xffffffff]:
                for i in range(32):
                    payload=bytearray(rng.randbytes(7+variant))
                    # Cover every encoded slot for ordinary selectors.
                    payload[6 if variant==1 else 5]=(i<<3)|(payload[6 if variant==1 else 5]&7)
                    payload[-1]|=0x80
                    job=rng.randbytes(168);chain=rng.getrandbits(32);chipid=rng.getrandbits(32);coreid=rng.getrandbits(32)
                    original=o.prepare(variant,chip,chain,bytes(payload),job,chipid,coreid)
                    events=[]
                    @ID
                    def chipfn(ctx,n):
                        try:events.append(('chip',n));return chipid
                        except BaseException as e:callback_errors.append(str(e));return 0xffffffff
                    @ID
                    def corefn(ctx,n):
                        try:events.append(('core',n));return coreid
                        except BaseException as e:callback_errors.append(str(e));return 0xffffffff
                    attr=Attr(None,chipfn,corefn);j=Job.from_buffer_copy(job);buf=(B*len(payload)).from_buffer_copy(payload);out=Result()
                    assert lib.vn135_work_nonce_prepare(chip,variant,chain,buf,len(payload),C.byref(j),C.byref(attr),C.byref(out))==0
                    assert bytes(out.candidate)==original['candidate'],(variant,chip,i,bytes(out.candidate).hex(),original['candidate'].hex())
                    assert bytes(out.compression_block)==original['prefix']
                    assert events==original['calls'] and not callback_errors
                    assert bytes(j)==job and bytes(buf)==payload
                    rec('nonce_candidate_68bytes_prefix64_and_call_order')
                    if len(samples)<4:samples.append({'variant':variant,'chip_selector':chip,'payload':payload.hex(),'job_hex':job.hex(),'candidate_hex':bytes(out.candidate).hex(),'prefix_hex':bytes(out.compression_block).hex()})
    elif args.group=='version':
        m=o.m;sp=m.STACK_TOP-0x1000;fp=sp+504
        # All 65,536 possible two-byte inputs to the variant=2 transformation.
        # Low formats also exercise all values of the otherwise ignored bytes.
        def check(variant,value):
            payload=bytearray(9);payload[6]=value>>8;payload[7]=value&255
            m.reset();m.r[13]=sp;m.r[11]=fp;m.r[10]=m.DATA_BASE+0x1000;m.r[9]=m.DATA_BASE+0x4000
            m.write(sp+0x4c,variant);m.mem[fp-104:fp-95]=payload
            m.run(0xc4518,stop=0xc457c,max_steps=100)
            want=m.read(sp+0x2c);got=U(0);buf=(B*9).from_buffer_copy(payload)
            assert lib.vn135_work_nonce_version_bits(variant,buf,7+variant,C.byref(got))==0
            assert got.value==want,(variant,value,hex(got.value),hex(want))
        for value in range(65536):check(2,value);rec('version_variant2_exhaustive_uint16')
        for variant in (0,1):
            for value in (0,1,0x7fff,0x8000,0xffff)+tuple(rng.randrange(65536) for _ in range(128)):
                check(variant,value);rec('version_legacy_sentinel')
    elif args.group=='sha':
        iv=[0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19]
        blocks=[bytes(64),b'\xff'*64,bytes(range(64)),b'\x80'+bytes(63)]+[rng.randbytes(64) for _ in range(128)]
        for block in blocks:
            buf=(B*64).from_buffer_copy(block);out=(U*8)()
            assert lib.vn135_sha256_midstate64(buf,out)==0
            assert tuple(out)==o.sha_midstate(block);rec('sha_midstate_original_iv')
            initial=[rng.getrandbits(32) for _ in range(8)];state=(U*8)(*initial)
            assert lib.vn135_sha256_compress_block(state,buf)==0
            assert tuple(state)==o.sha_midstate(block,initial);rec('sha_compression_arbitrary_state')
        def hash_with_new_compression(message):
            data=message+b'\x80';data+=b'\0'*((56-len(data))%64)+(len(message)*8).to_bytes(8,'big')
            state=(U*8)(*iv)
            for off in range(0,len(data),64):assert lib.vn135_sha256_compress_block(state,(B*64).from_buffer_copy(data[off:off+64]))==0
            return struct.pack('>8I',*state)
        lengths=[0,1,2,3,7,31,32,55,56,57,63,64,65,79,80,81,119,120,127,128,129,255,256,511,512,1024]
        for length in lengths:
            for _ in range(4):
                message=rng.randbytes(length)
                assert hash_with_new_compression(message)==hashlib.sha256(message).digest();rec('independent_hashlib_padded_messages')
        for block in blocks[:20]:
            expected=hashlib.sha256(block).digest()
            assert o.digest64(block)==expected==hash_with_new_compression(block);rec('original_full_sha_and_hashlib64')
    else:
        m=o.m
        for model in (0,0x1397,0x1398,0x1368,0xffffffff):
            for nonce in [0,1,0xffffffff,0x80000000,0x7fffffff]+[rng.getrandbits(32) for _ in range(256)]:
                m.reset((nonce,));m.run(0xed974,hooks={0xfdfcc:lambda a:setattr0(a,model)},max_steps=100)
                assert lib.vn135_bm1398_core_from_nonce(model,nonce)==m.r[0];rec('chip1398_core_bit_helper')
    out={'status':'PASS','group':args.group,'build_tag':args.tag,'reference_sha256':SHA,'cases':counts,
         'total_cases':sum(counts.values()),'seconds':round(time.monotonic()-t0,3),'samples':samples,
         'injected':['chip/core attribution in preparation only','memcpy','memset in original SHA finalization oracle only','numeric model getter for core helper'],
         'original_sha_replaced_by_hook':False,'valid_share_or_hardware_test':False}
    path=ROOT/'build'/f'stage7-{args.group}-{args.tag}-results.json';path.write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:v for k,v in out.items() if k!='samples'},indent=2))
def setattr0(m,x):m.r[0]=x&0xffffffff
if __name__=='__main__':main()
