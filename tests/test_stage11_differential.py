#!/usr/bin/env python3
"""Compare Stage11 C with original ARM ranges, including original strdup body.
Known ARM pointer slots are normalized to native sidecar strings, not truncated
host pointers. Opaque nonpointer bytes are compared, not declared understood.
"""
from pathlib import Path
import argparse,ctypes as C,json,os,random,struct,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tests'))
from work_storage_oracle import StorageOracle,normalize,OFFSETS
U8=C.c_uint8;U32=C.c_uint32;P=C.c_void_p
class Work(C.Structure):
    _fields_=[('image',U8*632),('text',P*4),('text_size',C.c_size_t*4)]
class View(C.Structure):_fields_=[('data',P),('size',C.c_size_t)]
class Metadata(C.Structure):_fields_=[('bits',C.c_uint64),('a',View),('b',View),('c',View)]
ALLOC=C.CFUNCTYPE(P,P,C.c_size_t);FREE=C.CFUNCTYPE(None,P,P)
class Memory(C.Structure):_fields_=[('context',P),('allocate',ALLOC),('release',FREE)]
WP=C.POINTER(Work)
class Arena:
    def __init__(self,fail=0):
        self.fail=fail;self.attempt=0;self.blocks={};self.keep=[];self.events=[];self.errors=[]
        self.alloc=ALLOC(self._allocate);self.free=FREE(self._free);self.ops=Memory(None,self.alloc,self.free)
    def block(self,data,kind):
        b=C.create_string_buffer(data,len(data));self.keep.append(b);p=C.addressof(b)
        self.blocks[p]=(b,kind);return p
    def _allocate(self,ctx,n):
        try:
            if n==C.sizeof(Work):
                self.events.append(('object',632,True));return self.block(b'\xcd'*n,'object')
            ok=not(self.fail&(1<<self.attempt));self.attempt+=1
            self.events.append(('alloc',n,ok))
            return self.block(b'\xcd'*n,'text') if ok else None
        except BaseException as e:self.errors.append(repr(e));return None
    def _free(self,ctx,p):
        try:
            b,kind=self.blocks.pop(p)
            self.events.append(('free-object',) if kind=='object' else ('free',C.string_at(p)))
        except BaseException as e:self.errors.append(repr(e))
    def source(self,image,texts):
        w=Work();w.image[:]=normalize(image)
        for i,s in enumerate(texts):
            if s is not None:w.text[i]=self.block(s+b'\0','text');w.text_size[i]=len(s)
        return w
    def guard(self):assert not self.errors,self.errors

def texts(w):return [None if not p else C.string_at(p,w.text_size[i]) for i,p in enumerate(w.text)]
def load():
    lib=C.CDLL(str(Path(os.environ.get('VN135_TEST_LIBRARY',ROOT/'build/libvn135_recovered.so')).resolve()))
    lib.vn135_frontend_work_metadata_copy_legacy.argtypes=[WP,C.POINTER(Metadata),C.POINTER(Memory),C.POINTER(U32)]
    lib.vn135_frontend_work_clone_unrolled.argtypes=[WP,U32,C.POINTER(Memory),C.POINTER(WP),C.POINTER(U32)]
    lib.vn135_frontend_work_storage_clear.argtypes=[WP,C.POINTER(Memory)]
    lib.vn135_frontend_work_storage_delete.argtypes=[C.POINTER(WP),C.POINTER(Memory)]
    lib.vn135_work_clone_atomic.argtypes=[WP,U32,C.POINTER(Memory),C.POINTER(WP)]
    lib.vn135_frontend_work_builder_fields.argtypes=[P,U32,U32]
    lib.vn135_frontend_work_wrapper_fields.argtypes=[P,U32,U32,U32,C.POINTER(U32),U32,U32]
    lib.vn135_frontend_hash_words80.argtypes=[P,P]
    return lib

def octets(r,n):return bytes(r.randrange(1,256) for _ in range(n))
def metadata_tests(lib):
    o=StorageOracle();r=random.Random(11001);count=0
    for case in range(72):
        strings=[octets(r,case%130),octets(r,(case*7)%240),octets(r,case%17)]
        image=normalize(r.randbytes(632));bits=r.getrandbits(64)
        for fail in range(8):
            expected=o.metadata(image,strings,bits,fail);a=Arena(fail);w=a.source(image,[None]*4)
            buffers=[C.create_string_buffer(s+b'\0') for s in strings]
            v=Metadata(bits,*[View(C.addressof(b),len(s)) for b,s in zip(buffers,strings)])
            mask=U32(0xeeeeeeee);before=bytes(v)
            rc=lib.vn135_frontend_work_metadata_copy_legacy(C.byref(w),C.byref(v),C.byref(a.ops),C.byref(mask))
            expected_mask=sum((1<<i) for i in (0,1,2) if expected['texts'][i] is None)
            assert rc==(1 if expected_mask else 0) and mask.value==expected_mask
            assert bytes(w.image)==expected['image'] and texts(w)==expected['texts']
            assert a.events==expected['events'],(a.events,expected['events'])
            assert bytes(v)==before and [b.raw[:len(s)+1] for b,s in zip(buffers,strings)]==[s+b'\0' for s in strings]
            assert lib.vn135_frontend_work_storage_clear(C.byref(w),C.byref(a.ops))==0
            a.guard();assert not a.blocks;count+=1
    return {'comparisons':count,'original_strdup_body_executed':True,'all_three_fail_patterns':True}

def clone_tests(lib):
    o=StorageOracle();r=random.Random(11002);count=0
    for present in range(16):
        for case in range(6):
            strings=[(octets(r,(case*59+i*13)%310) if case else b'') if present&(1<<i) else None for i in range(4)]
            image=normalize(r.randbytes(632));fresh=[0,1,0x7fffffff,0x80000000,0xfffffffe,0xffffffff][case]
            for fail in range(1<<present.bit_count()):
                expected=o.clone(image,strings,fresh,fail);a=Arena(fail);src=a.source(image,strings)
                before=bytes(src);srcblocks=set(a.blocks);out=WP();mask=U32(0xdddddddd)
                rc=lib.vn135_frontend_work_clone_unrolled(C.byref(src),fresh,C.byref(a.ops),C.byref(out),C.byref(mask))
                expected_mask=sum(1<<i for i in range(4) if strings[i] is not None and expected['texts'][i] is None)
                assert rc==(1 if expected_mask else 0) and mask.value==expected_mask and out
                assert bytes(out.contents.image)==expected['image'] and texts(out.contents)==expected['texts']
                assert a.events==expected['events'] and bytes(src)==before
                for i,s in enumerate(strings):
                    if out.contents.text[i]:assert out.contents.text[i]!=src.text[i]
                assert lib.vn135_frontend_work_storage_delete(C.byref(out),C.byref(a.ops))==0 and not out
                assert set(a.blocks)==srcblocks
                assert lib.vn135_frontend_work_storage_clear(C.byref(src),C.byref(a.ops))==0
                a.guard();assert not a.blocks;count+=1
    return {'comparisons':count,'unrolled_only':True,'outer_allocation_success_precondition':True,
            'compared_all_opaque_image_bytes_after_known_pointer_normalization':True}

def cleanup_tests(lib):
    o=StorageOracle();r=random.Random(11003);clear_count=delete_count=0
    for present in range(16):
        for case in range(12):
            strings=[(octets(r,case*7+i) if case else b'') if present&(1<<i) else None for i in range(4)]
            image=normalize(r.randbytes(632));expected=o.clear(image,strings);a=Arena();w=a.source(image,strings)
            assert lib.vn135_frontend_work_storage_clear(C.byref(w),C.byref(a.ops))==0
            assert bytes(w.image)==expected['image']==bytes(632) and texts(w)==expected['texts']==[None]*4
            assert a.events==expected['events'];a.guard();assert not a.blocks;clear_count+=1
            # Repeated clear: no allocations/frees, full zero image retained.
            oldevents=a.events[:];assert lib.vn135_frontend_work_storage_clear(C.byref(w),C.byref(a.ops))==0
            assert a.events==oldevents
            expected=o.delete(image,strings);a=Arena();w=a.source(image,strings)
            addr=a.block(bytes(w),'object');out=C.cast(addr,WP)
            assert lib.vn135_frontend_work_storage_delete(C.byref(out),C.byref(a.ops))==0 and not out
            assert a.events==expected['events'];a.guard();assert not a.blocks;delete_count+=1
    expected=o.delete(bytes(632),[None]*4,False);assert expected['events']==[('null-work-log',)]
    a=Arena();out=WP();assert lib.vn135_frontend_work_storage_delete(C.byref(out),C.byref(a.ops))==0
    assert not a.events # Diagnostic deliberately omitted in the new API.
    return {'comparisons':clear_count+delete_count,'clear':clear_count,'delete':delete_count,
            'null_original_diagnostic_observed_separately':True,'repeated_clear_checked':clear_count}

def fields_tests(lib):
    o=StorageOracle();r=random.Random(11004);count=0
    for i in range(320):
        image=normalize(r.randbytes(632));template=r.getrandbits(32);global_cookie=r.getrandbits(32)
        expected=o.builder(image,template,global_cookie);out=(U8*632).from_buffer_copy(image)
        assert lib.vn135_frontend_work_builder_fields(out,template,global_cookie)==0 and bytes(out)==expected
        count+=1
        args=[r.getrandbits(32),global_cookie,([0,1,0x7fffffff,0xffffffff][i%4] if i<16 else r.getrandbits(32)),r.getrandbits(32),r.getrandbits(32)]
        expected=o.wrapper(image,*args);out=(U8*632).from_buffer_copy(image);counter=U32(args[2])
        assert lib.vn135_frontend_work_wrapper_fields(out,expected['reference'],args[0],args[1],C.byref(counter),args[3],args[4])==0
        assert bytes(out)==expected['image'] and counter.value==expected['counter'];count+=1
    return {'comparisons':count,'builder':320,'wrapper':320,'all_other_image_bytes_unchanged':True}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('group',choices=['metadata','clone','cleanup','fields']);a=p.parse_args()
    lib=load();result={'stage':11,'group':a.group,'status':'PASS',**{'metadata':metadata_tests,'clone':clone_tests,'cleanup':cleanup_tests,'fields':fields_tests}[a.group](lib)}
    tag='clang' if 'clang' in os.environ.get('VN135_TEST_LIBRARY','') else 'gcc'
    (ROOT/f'build/stage11-{a.group}-{tag}-results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result),flush=True)
if __name__=='__main__':main()
