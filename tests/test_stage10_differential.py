#!/usr/bin/env python3
"""Original instructions versus compiled C on explicit, finite-input contracts.
Numeric conversion helpers execute from ELF; no expected-value replacement.
Pipeline group is a composition of bounded original slices, NOT full consumer.
"""
from pathlib import Path
import argparse,ctypes as C,json,math,os,random,struct,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from difficulty_oracle import DifficultyOracle
from rebuild_oracle import RebuildOracle
from verify_oracle import VerifyOracle
from test_stage9_differential import Candidate,Snapshot,Check,buf,ptr,cases,U8,U32,P
class MathResult(C.Structure):_fields_=[('midstate',U32*8),('target',U8*32)]
class DiffCheck(C.Structure):_fields_=[('checked',Check),('target',U8*32)]
def load():
    lib=C.CDLL(str(Path(os.environ.get('VN135_TEST_LIBRARY',ROOT/'build/libvn135_recovered.so')).resolve()))
    lib.vn135_frontend_target_from_difficulty.argtypes=[C.c_double,U32,P]
    lib.vn135_frontend_difficulty_from_target.argtypes=[P,U32,C.POINTER(C.c_double)]
    lib.vn135_frontend_work_math.argtypes=[P,C.c_double,U32,C.POINTER(MathResult)]
    lib.vn135_candidate_verify_difficulty.argtypes=[C.POINTER(Candidate),C.POINTER(Snapshot),P,C.c_size_t,
         C.c_double,C.POINTER(U32),U32,C.POINTER(DiffCheck)]
    return lib

def forward_values(selector):
    r=random.Random(10001+selector)
    n=math.ldexp(65535.0,224 if selector==1 else 208)
    edge=n/math.ldexp(1.,256)
    explicit=[0.,-0.,1.,2.,3.,0.1,1.5,65536.,1e6,1e12,1e20,1e40,1e60,sys.float_info.max,
              edge,math.nextafter(edge,math.inf),math.nextafter(1.,0.),math.nextafter(1.,math.inf)]
    for ex in [-16,0,16,32,64,128,192,224,256,512,900,1023]:
        x=math.ldexp(1.,ex)
        explicit.extend([math.nextafter(x,0.),x,math.nextafter(x,math.inf)])
    explicit.extend(math.ldexp(r.uniform(1.,2.),r.randrange(-15,1023)) for _ in range(180))
    return [x for x in explicit if x==0 or n/x<2.**256]

def target_tests(lib):
    o=DifficultyOracle();count=0;zero=0
    for selector in [0,1,2,7,0xffffffff]:
        for d in forward_values(selector):
            out=buf(b'\xcd'*34);expected=o.target(d,selector)
            rc=lib.vn135_frontend_target_from_difficulty(d,selector,ptr(out,1))
            assert rc==0 and bytes(out)==b'\xcd'+expected+b'\xcd',(d,selector,rc,bytes(out).hex(),expected.hex())
            assert o.events==(['lookup','zero-difficulty-log'] if d==0 else ['lookup']),o.events
            if d==0:zero+=1
            # Independent arithmetic check: within defined domain the original
            # target is integer truncation of the already rounded binary64 quotient.
            n=math.ldexp(65535.,224 if selector==1 else 208)
            assert int.from_bytes(expected,'little')==int(n/(1. if d==0. else d))
            count+=1
    # Known exact powers avoid validating against only the local ARM interpreter.
    for selector in [0,1,2]:
        for exponent in [0,1,16,32,64,128,192,224,240,256,900]:
            a=buf(bytes(32));assert lib.vn135_frontend_target_from_difficulty(2.**exponent,selector,a)==0
            numerator=65535<<(224 if selector==1 else 208)
            assert int.from_bytes(bytes(a),'little')==numerator//(1<<exponent)
    return {'comparisons':count,'zero_fallback_cases':zero,'independent_exact_power_cases':33,
            'original_integer_conversion_helpers_executed':True}

def inverse_tests(lib):
    o=DifficultyOracle();r=random.Random(10002);values=[bytes(32),b'\xff'*32]
    for bit in range(256):
        for delta in [-1,0,1]:
            x=(1<<bit)+delta
            if x>=0:values.append(x.to_bytes(32,'little'))
    values.extend(r.randbytes(32) for _ in range(180));count=0
    for i,t in enumerate(values):
        selector=[0,1,2,7,0xffffffff][i%5];a=buf(b'\xa3'+t+b'\x3a');d=C.c_double(-1.)
        expected=o.inverse(t,selector)
        assert lib.vn135_frontend_difficulty_from_target(ptr(a,1),selector,C.byref(d))==0
        assert struct.pack('<d',d.value)==struct.pack('<d',expected),(t.hex(),d.value,expected)
        assert bytes(a)==b'\xa3'+t+b'\x3a';count+=1
    return {'comparisons':count,'compared_all_binary64_bits':True,'zero_target_denominator_is_one':True}

def math_tests(lib):
    o=DifficultyOracle();r=random.Random(10003);count=0
    for i in range(256):
        selector=i%3;d=[0.,1.,3.,65536.,1e12,1e50,sys.float_info.max][i%7]
        words=r.randbytes(112);a=buf(b'\xa5'+words+b'\x5a');out=MathResult()
        expected_mid,expected_target=o.work_math(words,d,selector)
        assert lib.vn135_frontend_work_math(ptr(a,1),d,selector,C.byref(out))==0
        assert struct.pack('<8I',*out.midstate)==expected_mid
        assert bytes(out.target)==expected_target and bytes(a)==b'\xa5'+words+b'\x5a';count+=1
    return {'comparisons':count,'original_sha_and_target_execute_together':True,
            'all_other_632byte_work_bytes_checked_unchanged':True}

def pipeline_tests(lib):
    o=DifficultyOracle();rbuild=RebuildOracle();verify=VerifyOracle();r=random.Random(10004);count=0
    for i,(words,coinbase,offset,width,counter,branches) in enumerate(cases(10005,60)):
        cs=[r.getrandbits(32) for _ in range(17)];cs[4]=i%32;cs[6]=counter&0xffffffff;cs[7]=counter>>32
        candidate=Candidate.from_buffer_copy(struct.pack('<17I',*cs));cb=buf(coinbase);br=buf(b''.join(branches))
        snap=Snapshot((U8*112).from_buffer_copy(words),cb,len(coinbase),offset,width,br,len(branches))
        before_snap=bytes(snap);before_candidate=bytes(candidate);scratch=buf(b'\xcc'*(len(coinbase)+2))
        selector=i%3;d=[0.,1.,3.,65536.,1e12,1e40][i%6]
        target=o.target(d,selector)
        prefix=rbuild.candidate_prefix(words,coinbase,offset,width,bytes(candidate),branches)
        last=candidate.nonce if i%4==0 else (candidate.nonce+1)&0xffffffff
        original=verify.prefilter(prefix['words'][:80],bytes(32),last,candidate.nonce,selector)
        previous=U32(last);out=DiffCheck()
        assert lib.vn135_candidate_verify_difficulty(C.byref(candidate),C.byref(snap),ptr(scratch,1),len(coinbase),
            d,C.byref(previous),selector,C.byref(out))==0
        c=out.checked
        assert bytes(out.target)==target and bytes(c.rebuilt.words)==prefix['words']
        assert bytes(c.work.words)==original['words'] and bytes(c.work.digest)==original['digest']
        assert previous.value==original['last'] and c.prefilter==original['outcome']
        assert c.hash_computed==(c.prefilter!=1) and c.target_checked==(c.prefilter==0)
        assert c.meets_target==(verify.target(original['digest'],target) if c.target_checked else 0)
        assert bytes(scratch)==b'\xcc'+prefix['coinbase']+b'\xcc'
        assert bytes(snap)==before_snap and bytes(candidate)==before_candidate and bytes(cb)[:len(coinbase)]==coinbase
        count+=1
    return {'slice_composition_cases':count,'not_a_full_original_consumer':True}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('group',choices=['target','inverse','math','pipeline']);a=p.parse_args()
    lib=load();result={'stage':10,'group':a.group,'status':'PASS',**{'target':target_tests,'inverse':inverse_tests,'math':math_tests,'pipeline':pipeline_tests}[a.group](lib)}
    tag='clang' if 'clang' in os.environ.get('VN135_TEST_LIBRARY','') else 'gcc'
    (ROOT/f'build/stage10-{a.group}-{tag}-results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result),flush=True)
if __name__=='__main__':main()
