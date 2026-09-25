#!/usr/bin/env python3
"""Deterministic differential tests for bounded Stage8 original-code slices.
SHA is executed in original A32 instructions, not replaced by expected results.
Each group writes an explicit machine-readable result and fails on callback errors.
"""
from pathlib import Path
import argparse,ctypes as C,hashlib,json,random,struct,sys
ROOT=Path(__file__).resolve().parents[1]
from verify_oracle import VerifyOracle
U8=C.c_uint8;U32=C.c_uint32;P=C.POINTER(U8)
def arr(data):return (U8*len(data)).from_buffer_copy(data)
def swap_words(data):return b''.join(data[i:i+4][::-1] for i in range(0,len(data),4))
def dhash(data):return hashlib.sha256(hashlib.sha256(data).digest()).digest()
class Work(C.Structure):_fields_=[('words',U8*80),('digest',U8*32)]
class Job(C.Structure):_fields_=[('key',U32),('reference',C.c_void_p),('word_1fc',U32)]
Hash=C.CFUNCTYPE(None,C.c_void_p,P,P)
Reject=C.CFUNCTYPE(C.c_int,C.c_void_p,C.c_void_p)
p=argparse.ArgumentParser();p.add_argument('group',choices=['hash','target','prefilter','job','registry'])
p.add_argument('--library',default=str(ROOT/'build/libvn135_recovered.so'))
p.add_argument('--tag',default='gcc');args=p.parse_args()
lib=C.CDLL(str(Path(args.library).resolve()));o=VerifyOracle();rng=random.Random(0x8135)
lib.vn135_sha256d_header80.argtypes=[P,P];lib.vn135_sha256d_header80.restype=C.c_int
lib.vn135_frontend_hash_words80.argtypes=[P,P];lib.vn135_frontend_hash_words80.restype=C.c_int
lib.vn135_target256_check_le.argtypes=[P,P];lib.vn135_target256_check_le.restype=C.c_int
lib.vn135_frontend_nonce_prefilter.argtypes=[C.POINTER(Work),C.POINTER(U32),U32,U32,Hash,C.c_void_p]
lib.vn135_frontend_nonce_prefilter.restype=C.c_int
lib.vn135_frontend_sha256d_prefilter.argtypes=[C.POINTER(Work),C.POINTER(U32),U32,U32]
lib.vn135_frontend_sha256d_prefilter.restype=C.c_int
lib.vn135_recent_job_select.argtypes=[C.POINTER(Job),U32,Reject,C.c_void_p,C.POINTER(C.c_size_t)]
lib.vn135_recent_job_select.restype=C.c_int
lib.vn135_reference_absent.argtypes=[C.POINTER(C.c_void_p),C.c_int32,C.c_void_p]
lib.vn135_reference_absent.restype=C.c_int
lib.vn135_recent_job_select_registered.argtypes=[C.POINTER(Job),U32,C.POINTER(C.c_void_p),C.c_int32,C.POINTER(C.c_size_t)]
lib.vn135_recent_job_select_registered.restype=C.c_int
count=0;details={}
if args.group=='hash':
    headers=[bytes(80),b'\xff'*80,bytes(range(80)),bytes(range(79,-1,-1))]
    headers += [bytes([b])*80 for b in (1,0x55,0x80,0xaa,0xfe)]
    # Each bit of the nonce portion plus both edges of each source word.
    for word in range(20):
        for bit in (0,31):
            a=bytearray(80);struct.pack_into('<I',a,4*word,1<<bit);headers.append(bytes(a))
    headers += [rng.randbytes(80) for _ in range(256)]
    for words in headers:
        raw=swap_words(words);want=o.hash_words(words);independent=dhash(raw)
        assert want==independent
        out=arr(b'\xa1'*32);assert lib.vn135_frontend_hash_words80(arr(words),out)==0
        assert bytes(out)==want
        assert lib.vn135_sha256d_header80(arr(raw),out)==0 and bytes(out)==want
        # Both fixed APIs explicitly allow overlap with output, including unaligned buffers.
        buf=arr(b'\x3d'+words+b'\x7a'*40)
        ptr=C.cast(C.byref(buf,1),P);outptr=C.cast(C.byref(buf,6),P)
        assert lib.vn135_frontend_hash_words80(ptr,outptr)==0
        assert bytes(buf[6:38])==want and buf[0]==0x3d and bytes(buf[81:])==b'\x7a'*40
        count+=1
    details={'original_full_work_hash_calls':count,'hashlib_cross_checks':count,
             'serialized_and_word_swapped_APIs_compared_per_case':True,'original_real_SHA_executed':True}
elif args.group=='target':
    cases=[(bytes(32),bytes(32)),(b'\xff'*32,b'\xff'*32),(bytes(32),b'\xff'*32),(b'\xff'*32,bytes(32))]
    # Force comparison down to every limb, exercise unsigned edges and lower-limb irrelevance.
    edges=[0,1,0x7fffffff,0x80000000,0xfffffffe,0xffffffff]
    for limb in range(8):
        for x in edges:
            for y in edges:
                h=[rng.getrandbits(32) for _ in range(8)];t=h.copy()
                h[limb]=x;t[limb]=y
                for i in range(limb):h[i]=0xffffffff;t[i]=0
                cases.append((struct.pack('<8I',*h),struct.pack('<8I',*t)))
    for _ in range(1024):
        h=rng.randbytes(32);cases.append((h,h))
        cases.append((h,rng.randbytes(32)))
    for h,t in cases:
        want=o.target(h,t)
        assert want==int(int.from_bytes(h,'little')<=int.from_bytes(t,'little'))
        a=arr(b'\x9d'+h+b'\x8e');b=arr(b'\x12'+t+b'\x13')
        assert lib.vn135_target256_check_le(C.cast(C.byref(a,1),P),C.cast(C.byref(b,1),P))==want
        assert bytes(a)==b'\x9d'+h+b'\x8e' and bytes(b)==b'\x12'+t+b'\x13'
        count+=1
    details={'original_compare_calls':count,'all_eight_decisive_limbs':True,'equality_accepted':True}
elif args.group=='prefilter':
    cases=[]
    for selector in (0,1,2,7,0xffffffff):
        for high in (0,1,0xfffe,0xffff,0x10000,0x7fffffff,0x80000000,0xffffffff):
            for duplicate in (False,True):
                for nonce in (0,1,0xffffffff):
                    cases.append((nonce if duplicate else nonce^1,nonce,selector,
                                  rng.randbytes(28)+struct.pack('<I',high)))
    cases += [(rng.getrandbits(32),rng.getrandbits(32),rng.randrange(3),rng.randbytes(32)) for _ in range(512)]
    # Full original prefilter with the original hash function deliberately selected.
    real_cases=[(rng.getrandbits(32),rng.getrandbits(32),i%3,None) for i in range(128)]
    real_cases += [(n,n,i%3,None) for i,n in enumerate((0,1,0xffffffff))]
    for last,nonce,selector,forced in cases+real_cases:
        words=rng.randbytes(80);old_digest=rng.randbytes(32)
        want=o.prefilter(words,old_digest,last,nonce,selector,forced)
        work=Work((U8*80).from_buffer_copy(words),(U8*32).from_buffer_copy(old_digest));lastp=U32(last)
        calls=[];errors=[]
        @Hash
        def hash_cb(ctx,src,dst):
            try:
                assert ctx==0x1234
                calls.append(('hash',lastp.value,C.string_at(src,80)))
                C.memmove(dst,forced,32)
            except BaseException as exc:errors.append(repr(exc))
        if forced is None:got=lib.vn135_frontend_sha256d_prefilter(C.byref(work),C.byref(lastp),nonce,selector)
        else:got=lib.vn135_frontend_nonce_prefilter(C.byref(work),C.byref(lastp),nonce,selector,hash_cb,0x1234)
        assert not errors,errors
        assert (got,lastp.value,bytes(work.words),bytes(work.digest))==(want['outcome'],want['last'],want['words'],want['digest'])
        assert [e for e in want['events'] if e[0]=='getter']==([] if last==nonce else [('getter',),('getter',)])
        if forced is not None:assert calls==[e for e in want['events'] if e[0]=='hash']
        if forced is None and last!=nonce:assert bytes(work.digest)==dhash(swap_words(bytes(work.words)))
        count+=1
    # Stateful replay: a hash failure still updates last_nonce, next identical nonce is duplicate.
    work=Work();lastp=U32(1);errors=[];calls=[]
    @Hash
    def fail_hash(ctx,src,dst):
        try:calls.append(1);C.memmove(dst,b'\xff'*32,32)
        except BaseException as exc:errors.append(repr(exc))
    assert lib.vn135_frontend_nonce_prefilter(C.byref(work),C.byref(lastp),2,0,fail_hash,None)==2
    assert lib.vn135_frontend_nonce_prefilter(C.byref(work),C.byref(lastp),2,1,fail_hash,None)==1
    assert not errors and calls==[1] and lastp.value==2
    details={'forced_hash_boundary_cases':len(cases),'real_original_SHA_bound_cases':len(real_cases),
             'stateful_replay_native_checks':2,'stopped_before_accounting_and_submission':True}
elif args.group=='job':
    cases=[]
    # First match can be unusable; later identical usable keys MUST NOT be tried.
    for key in (0,1,0x7fffffff,0xffffffff):
        for position in range(4):
            for nonnull in (False,True):
                for status in (0,1,2,0xffffffff):
                    for reject in (0,1,-1,0x7fffffff):
                        records=[(key^1,i+1,1) for i in range(3)]
                        if position<3:
                            records[position]=(key,position+1 if nonnull else 0,status)
                            for j in range(position+1,3):records[j]=(key,j+1,1)
                        cases.append((records,key,reject))
    for _ in range(512):
        records=[(rng.randrange(4),rng.randrange(5),rng.randrange(3)) for _ in range(3)]
        cases.append((records,rng.randrange(5),rng.randrange(3)-1))
    for records,key,reject_result in cases:
        want,events=o.job(records,key,reject_result)
        args_records=(Job*3)(*(Job(k,p or None,s) for k,p,s in records))
        before=bytes(args_records);calls=[];errors=[];index=C.c_size_t(777)
        @Reject
        def reject_cb(ctx,ref):
            try:assert ctx==0x9876;calls.append(ref)
            except BaseException as exc:errors.append(repr(exc))
            return reject_result
        got=lib.vn135_recent_job_select(args_records,key,reject_cb,0x9876,C.byref(index))
        assert not errors and calls==events and bytes(args_records)==before
        assert (got==0,index.value if got==0 else None)==want
        if got!=0:assert index.value==777
        # Distinct statuses are new diagnostics; original exposes only continue/skip.
        expected=1
        for k,p,s in records:
            if k==key:
                expected=2 if not p else 3 if reject_result else 4 if not s else 0;break
        assert got==expected
        count+=1
    details={'original_selection_slices':count,'original_final_policy_injected':True,
             'coherent_snapshot_only':True,'first_match_no_fallback':True}
elif args.group=='registry':
    cases=[]
    for n in range(17):
        refs=list(range(1,n+1))
        for target in (0,1,n,n+1,0xffffffff):cases.append((refs,target,n))
    cases += [([],0,n) for n in (0,-1,-2147483648)]
    cases += [([0,2,0,3],t,4) for t in (0,1,2,3,4)]
    cases += [(rng.sample(range(0,80),rng.randrange(0,65)),rng.randrange(0,90),None) for _ in range(256)]
    for refs,target,n in cases:
        if n is None:n=len(refs)
        want=o.membership(refs,target,n)
        array=(C.c_void_p*len(refs))(*refs)
        assert lib.vn135_reference_absent(array,n,target)==want==int(target not in refs[:max(0,n)])
        count+=1
    alone=count
    # Execute real original consumer selection AND real membership routine together.
    for i in range(512):
        records=[(rng.randrange(4),j+1 if rng.randrange(4) else 0,rng.randrange(3)) for j in range(3)]
        key=rng.randrange(5);registry=rng.sample(range(0,8),rng.randrange(0,8))
        want,events=o.job(records,key,0,registry)
        array=(Job*3)(*(Job(k,p or None,s) for k,p,s in records))
        refs=(C.c_void_p*len(registry))(*registry);index=C.c_size_t(888)
        got=lib.vn135_recent_job_select_registered(array,key,refs,len(registry),C.byref(index))
        assert (got==0,index.value if got==0 else None)==want
        if got!=0:assert index.value==888
        first=next((p for k,p,s in records if k==key),None)
        assert events==(['registry-lock','registry-unlock'] if first else [])
        count+=1
    details={'original_membership_calls':alone,'combined_original_consumer_and_membership':count-alone,
             'external_mutex_injected':True,'predicate_not_replaced_in_combined_tests':True}
result={'status':'PASS','group':args.group,'compiler_tag':args.tag,'original_comparison_cases':count,
        'library_sha256':hashlib.sha256(Path(args.library).read_bytes()).hexdigest(),
        'reference_sha256':hashlib.sha256(o.elf.data).hexdigest(),'details':details,
        'hardware_tested':False,'job_freshness_proven':False}
out=ROOT/'build'/f'stage8-{args.group}-{args.tag}.json';out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
