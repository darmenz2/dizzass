#!/usr/bin/env python3
"""Compare new C to bounded original work-build/SHA instructions.
Caller-owned snapshots, successful locks/allocation and no concurrent mutation.
No ASIC, pool, acceptance, queue ownership or full vendor process execution.
"""
from pathlib import Path
import argparse,ctypes as C,hashlib,json,os,random,struct,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from rebuild_oracle import RebuildOracle
from verify_oracle import VerifyOracle
U8=C.c_uint8;U32=C.c_uint32;P=C.POINTER(U8)
class Candidate(C.Structure):
    _fields_=[('chain_id',U32),('chip_id',U32),('core_id',U32),('job_word_a4',U32),
      ('job_slot',U32),('version_word',U32),('job_word_70',U32),('job_word_74',U32),
      ('nonce',U32),('midstate',U32*8)]
class Template(C.Structure):
    _fields_=[('words',U8*112),('coinbase',P),('size',C.c_size_t),('offset',C.c_size_t),
      ('width',U32),('counter',C.c_uint64),('branches',P),('count',C.c_size_t)]
class Snapshot(C.Structure):
    _fields_=[('words',U8*112),('coinbase',P),('size',C.c_size_t),('offset',C.c_size_t),
      ('width',U32),('branches',P),('count',C.c_size_t)]
class Rebuilt(C.Structure):
    _fields_=[('words',U8*112),('root',U8*32),('counter',C.c_uint64),('width',U32)]
class VerifyWork(C.Structure):_fields_=[('words',U8*80),('digest',U8*32)]
class Check(C.Structure):
    _fields_=[('rebuilt',Rebuilt),('work',VerifyWork),('prefilter',C.c_int),
      ('hash_computed',U32),('target_checked',U32),('meets_target',U32)]
def buf(b):return (U8*max(1,len(b))).from_buffer_copy(b if b else b'\x00')
def ptr(a,off=0):return C.cast(C.byref(a,off),P)
def swap(b):return b''.join(b[i:i+4][::-1] for i in range(0,len(b),4))
def sha2(b):return hashlib.sha256(hashlib.sha256(b).digest()).digest()
def load():
    lib=C.CDLL(str(Path(os.environ.get('VN135_TEST_LIBRARY',ROOT/'build/libvn135_recovered.so')).resolve()))
    for name in ('vn135_sha256_bytes','vn135_sha256d_bytes'):
        getattr(lib,name).argtypes=[P,C.c_size_t,P];getattr(lib,name).restype=C.c_int
    lib.vn135_frontend_rebuild_prefix.argtypes=[C.POINTER(Template),C.POINTER(Rebuilt)]
    lib.vn135_rebuild_from_candidate.argtypes=[C.POINTER(Candidate),C.POINTER(Snapshot),P,C.c_size_t,C.POINTER(Rebuilt)]
    lib.vn135_candidate_verify_snapshot.argtypes=[C.POINTER(Candidate),C.POINTER(Snapshot),P,C.c_size_t,P,C.POINTER(U32),U32,C.POINTER(Check)]
    return lib

def sha_tests(lib):
    o=RebuildOracle();r=random.Random(9001);n=0;aliases=0
    sizes=[0,1,2,7,8,31,32,33,55,56,57,63,64,65,79,80,81,95,111,112,119,120,121,127,128,129,255,256,257,511,512,513,1024,4096]
    values=[r.randbytes(s) for s in sizes]+[r.randbytes(r.randrange(0,800)) for _ in range(72)]
    for b in values:
        raw=buf(b);out=buf(b'\x99'*32)
        expected=o.sha(b);assert expected==hashlib.sha256(b).digest()
        assert lib.vn135_sha256_bytes(raw,len(b),out)==0 and bytes(out)==expected;n+=1
        twice=o.sha(expected);assert twice==sha2(b)
        assert lib.vn135_sha256d_bytes(raw,len(b),out)==0 and bytes(out)==twice;n+=1
        # Separate API checks: overlapping/unaligned output does not clobber unread input.
        for fun,expected in [(lib.vn135_sha256_bytes,expected),(lib.vn135_sha256d_bytes,twice)]:
            a=buf(b'\xcd'+b+b'\xcd'*40)
            assert fun(ptr(a,1),len(b),ptr(a,3))==0 and bytes(a)[3:35]==expected;aliases+=1
    return {'comparisons':n,'alias_api_checks':aliases,'original_sha_executed':True}

def cases(seed,count):
    r=random.Random(seed)
    for i in range(count):
        width=i%9;size=max(width,[0,1,8,55,56,63,64,65,100,128,257,512][i%12])
        offset=(0 if i%3==0 else size-width if i%3==1 else r.randrange(size-width+1))
        counter=[0,1,0xffffffff,0x100000000,0xffffffffffffffff,0x7fffffffffffffff][i%6] if i<54 else r.getrandbits(64)
        nb=[0,1,2,3,8,16][i%6]
        yield r.randbytes(112),r.randbytes(size),offset,width,counter,[r.randbytes(32) for _ in range(nb)]

def expected_root(coinbase,offset,width,counter,branches):
    cb=bytearray(coinbase);cb[offset:offset+width]=counter.to_bytes(8,'little')[:width]
    root=sha2(cb)
    for b in branches:root=sha2(root+b)
    return bytes(cb),root

def prefix_tests(lib):
    o=RebuildOracle();n=0;sha_calls=0
    for words,coinbase,offset,width,counter,branches in cases(9002,198):
        original=o.prefix(words,coinbase,offset,width,counter,branches)
        cb=buf(b'\xa5'+coinbase+b'\x5a');br=buf(b''.join(branches));out=Rebuilt()
        job=Template((U8*112).from_buffer_copy(words),ptr(cb,1),len(coinbase),offset,width,counter,br,len(branches))
        assert lib.vn135_frontend_rebuild_prefix(C.byref(job),C.byref(out))==0
        mutated,root=expected_root(coinbase,offset,width,counter,branches)
        expect=words[:36]+swap(root)+words[68:]
        assert bytes(out.words)==original['words']==expect
        assert bytes(out.root)==root
        assert out.counter==original['counter_used']==counter and out.width==original['counter_size']==width
        assert job.counter==original['counter_next']==(counter+1)&0xffffffffffffffff
        assert bytes(cb)==b'\xa5'+original['coinbase']+b'\x5a'==b'\xa5'+mutated+b'\x5a'
        assert bytes(job.words)==words
        assert len(original['sha_inputs'])==2+2*len(branches)
        assert original['sha_inputs'][0]==mutated
        sha_calls+=len(original['sha_inputs']);n+=1
    return {'comparisons':n,'original_sha_calls':sha_calls,'compared_work_bytes':112,
            'full_632byte_work_reconstructed':False}

def candidate_tests(lib):
    o=RebuildOracle();v=VerifyOracle();r=random.Random(9003);n=0;integrated=0
    for i,(words,coinbase,offset,width,counter,branches) in enumerate(cases(9004,144)):
        cs=[r.getrandbits(32) for _ in range(17)];cs[4]=i%32;cs[6]=counter&0xffffffff;cs[7]=counter>>32
        candidate=Candidate.from_buffer_copy(struct.pack('<17I',*cs));candidate_before=bytes(candidate)
        original=o.candidate_prefix(words,coinbase,offset,width,candidate_before,branches)
        cb=buf(coinbase);br=buf(b''.join(branches));scratch=buf(b'\xe5'*(len(coinbase)+2));out=Rebuilt()
        snap=Snapshot((U8*112).from_buffer_copy(words),cb,len(coinbase),offset,width,br,len(branches))
        before=bytes(snap)
        assert lib.vn135_rebuild_from_candidate(C.byref(candidate),C.byref(snap),ptr(scratch,1),len(coinbase),C.byref(out))==0
        mutated,root=expected_root(coinbase,offset,width,counter,branches)
        assert bytes(out.words)==original['words']==struct.pack('<I',candidate.version_word)+words[4:36]+swap(root)+words[68:]
        assert bytes(out.root)==root and out.counter==counter and out.width==width
        assert bytes(scratch)==b'\xe5'+mutated+b'\xe5'
        assert bytes(candidate)==candidate_before and bytes(snap)==before and bytes(cb)[:len(coinbase)]==coinbase;n+=1
        # Composition of original slices, NOT whole consumer execution.
        last=candidate.nonce if i%4==0 else (candidate.nonce+1)&0xffffffff;selector=i%3
        original_verify=v.prefilter(original['words'][:80],bytes(32),last,candidate.nonce,selector)
        target=r.randbytes(32);t=buf(target);previous=U32(last);check=Check()
        rc=lib.vn135_candidate_verify_snapshot(C.byref(candidate),C.byref(snap),ptr(scratch,1),len(coinbase),t,C.byref(previous),selector,C.byref(check))
        assert rc==0 and previous.value==original_verify['last']
        assert check.prefilter==original_verify['outcome']
        assert bytes(check.work.words)==original_verify['words'] and bytes(check.work.digest)==original_verify['digest']
        assert check.hash_computed==(check.prefilter!=1)
        assert check.target_checked==(check.prefilter==0)
        assert check.meets_target==(v.target(original_verify['digest'],target) if check.target_checked else 0)
        assert bytes(snap)==before and bytes(candidate)==candidate_before;integrated+=1
    return {'comparisons':n,'slice_composition_cases':integrated,'real_caller_wrapper_core':True,
            'full_consumer_or_job_lifecycle':False}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('group',choices=['sha','prefix','candidate']);a=p.parse_args()
    lib=load();result={'stage':9,'group':a.group,'status':'PASS',**{'sha':sha_tests,'prefix':prefix_tests,'candidate':candidate_tests}[a.group](lib)}
    (ROOT/f'build/stage9-{a.group}-{"clang" if "clang" in os.environ.get("VN135_TEST_LIBRARY","") else "gcc"}-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
if __name__=='__main__':main()
