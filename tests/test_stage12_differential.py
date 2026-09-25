#!/usr/bin/env python3
"""Original time-roll on valid input, including original hex conversions.
New guards/rollback/encoder-ENOMEM policy are tested separately, not disguised as
original behavior. Original binary only executes bounded A32 instructions.
"""
from pathlib import Path
import argparse,ctypes as C,hashlib,json,os,random,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from test_stage11_differential import Work,WP,Memory,U32,Arena,normalize,load,texts,octets
from work_time_oracle import TimeOracle

def time_load():
    lib=load()
    lib.vn135_frontend_work_clone_time_legacy.argtypes=[WP,U32,U32,C.POINTER(Memory),C.POINTER(WP),C.POINTER(U32)]
    lib.vn135_work_clone_time_atomic.argtypes=[WP,U32,U32,C.POINTER(Memory),C.POINTER(WP)]
    lib.vn135_work_time_decode8.argtypes=[C.c_void_p,C.POINTER(U32)]
    lib.vn135_work_time_encode8.argtypes=[U32,C.c_void_p]
    return lib

def codec_tests(lib):
    o=TimeOracle();r=random.Random(12001);count=0
    values=[0,1,15,16,255,256,65535,65536,0x7fffffff,0x80000000,0xfffffffe,0xffffffff]
    values += [r.getrandbits(32) for _ in range(384)]
    for value in values:
        encoded=o.encode(value);out=C.create_string_buffer(b'\xa5'*11,11)
        assert lib.vn135_work_time_encode8(value,C.byref(out,1))==0
        assert out.raw[0]==0xa5 and out.raw[-1]==0xa5
        assert out.raw[1:10]==encoded[:9]==f'{value:08x}'.encode()+b'\0'
        assert encoded[9:]==bytes(3)
        count+=1
        for casing in (str.lower,str.upper):
            s=casing(f'{value:08x}').encode();original,raw=o.decode(s)
            dst=U32(0xaabbccdd)
            assert original==1 and lib.vn135_work_time_decode8(s,C.byref(dst))==0
            assert dst.value==int.from_bytes(raw,'big')==value
            count+=1
    return {'comparisons':count,'values':len(values),'original_hex_bodies_executed':True,
            'alphabet_initialized_by_original_instructions':True}

def clone_tests(lib):
    o=TimeOracle();r=random.Random(12002);count=0;rolls=0;absent=0;disagree=0;failures=0
    vectors=[(0,0,0),(0,0,1),(0xffffffff,0xffffffff,1),(0,0,0xffffffff),
             (0x7fffffff,0x80000000,1),(0x80000000,0x7fffffff,0x80000000),
             (1231006505,1231006505,1),(0xfffffffe,0,2)]
    vectors += [(r.getrandbits(32),r.getrandbits(32),r.getrandbits(32)) for _ in range(16)]
    for present in range(16):
        for case,(header_time,text_time,delta) in enumerate(vectors):
            strings=[octets(r,(case*17+i*9)%87) if present&(1<<i) else None for i in range(4)]
            if strings[1] is not None:strings[1]=(f'{text_time:08X}' if case%2 else f'{text_time:08x}').encode()
            image=bytearray(normalize(r.randbytes(632)));image[0x44:0x48]=header_time.to_bytes(4,'big')
            image=bytes(image);fresh=r.getrandbits(32)
            if case<8:fresh=[0,1,0xffffffff,0x80000000][case%4]
            order=[i for i in (0,2,1,3) if strings[i] is not None]
            for fail in range(1<<len(order)):
                # Original encoder does not guard failed calloc; NEW API guards
                # it, but its undefined write path is not a differential test.
                if delta and 1 in order and fail&(1<<order.index(1)):continue
                expected=o.clone_time(image,strings,fresh,delta,fail)
                a=Arena(fail);src=a.source(image,strings);before=bytes(src);blocks=set(a.blocks)
                out=WP();mask=U32(0xdeadbeef)
                rc=lib.vn135_frontend_work_clone_time_legacy(C.byref(src),fresh,delta,C.byref(a.ops),C.byref(out),C.byref(mask))
                emask=sum(1<<i for i in range(4) if strings[i] is not None and expected['texts'][i] is None)
                assert out and rc==(1 if emask else 0) and mask.value==emask
                assert bytes(out.contents.image)==expected['image'],(case,present,fail,delta)
                assert texts(out.contents)==expected['texts'],(texts(out.contents),expected['texts'])
                assert a.events==expected['events'] and bytes(src)==before
                if delta:
                    assert int.from_bytes(bytes(out.contents.image)[0x44:0x48],'big')==(header_time+delta)&0xffffffff
                    rolls+=1
                    if strings[1] is not None:
                        assert C.string_at(out.contents.text[1],12)==expected['time_allocation']
                        assert texts(out.contents)[1]==f'{(text_time+delta)&0xffffffff:08x}'.encode()
                        disagree+=int(header_time!=text_time)
                    else:absent+=1
                failures+=int(bool(emask))
                for i,s in enumerate(strings):
                    if out.contents.text[i]:assert out.contents.text[i]!=src.text[i]
                assert lib.vn135_frontend_work_storage_delete(C.byref(out),C.byref(a.ops))==0
                assert set(a.blocks)==blocks
                assert lib.vn135_frontend_work_storage_clear(C.byref(src),C.byref(a.ops))==0
                a.guard();assert not a.blocks;count+=1
    return {'comparisons':count,'nonzero_delta':rolls,'absent_time_text':absent,
            'independent_mismatching_header_and_text':disagree,'partial_other_string_failures':failures,
            'compares_full_normalized_image_and_copy_order':True,
            'failed_original_encoder_allocation_not_in_domain':True}

def composition_tests(lib):
    o=TimeOracle();r=random.Random(12003);count=0
    fixture=json.loads((ROOT/'evidence/stage9/genesis-vector.json').read_text())['data']
    vectors=json.loads((ROOT/'evidence/stage12/time-vectors.json').read_text())['rows']
    for case in range(70):
        image=bytearray(normalize(r.randbytes(632)));delta=r.getrandbits(32)
        if case<6:
            image[:112]=bytes.fromhex(fixture['words']);delta=vectors[case]['delta']
        stamp=int.from_bytes(image[0x44:0x48],'big');strings=[b'offline-only',f'{stamp:08X}'.encode(),b'extra',None]
        expected=o.clone_time(image,strings,case,delta);m=o.m
        before=bytes(m.mem[o.new:o.new+632]);m.reset((o.new,))
        m.run(0x2d994,hooks=o.hooks(),max_steps=80000)
        digest=bytes(m.mem[o.new+0x120:o.new+0x140]);modified=bytearray(before);modified[0x120:0x140]=digest
        assert m.mem[o.new:o.new+632]==modified
        a=Arena();src=a.source(image,strings);out=WP();actual=C.create_string_buffer(32)
        assert lib.vn135_work_clone_time_atomic(C.byref(src),case,delta,C.byref(a.ops),C.byref(out))==0
        assert bytes(out.contents.image)==expected['image']
        assert lib.vn135_frontend_hash_words80(C.byref(out.contents.image),actual)==0
        header=b''.join(bytes(out.contents.image[i:i+4])[::-1] for i in range(0,80,4))
        assert actual.raw==digest==hashlib.sha256(hashlib.sha256(header).digest()).digest()
        assert bytes(out.contents.image)==expected['image']
        if case<6:assert digest.hex()==vectors[case]['raw_sha256d']
        assert lib.vn135_frontend_work_storage_delete(C.byref(out),C.byref(a.ops))==0
        assert lib.vn135_frontend_work_storage_clear(C.byref(src),C.byref(a.ops))==0
        a.guard();assert not a.blocks;count+=1
    return {'separate_compositions':count,'original_clone_then_original_sha256d':True,
            'hashlib_independent_check':True,'pool_policy_checked':False}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('group',choices=['codec','clone','composition']);a=p.parse_args()
    result={'stage':12,'status':'PASS','group':a.group,**{'codec':codec_tests,'clone':clone_tests,'composition':composition_tests}[a.group](time_load())}
    tag='clang' if 'clang' in os.environ.get('VN135_TEST_LIBRARY','') else 'gcc'
    (ROOT/f'build/stage12-{a.group}-{tag}-results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result),flush=True)
if __name__=='__main__':main()
