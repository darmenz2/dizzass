#!/usr/bin/env python3
"""Stage14 real original instruction predicates compared with the new C.
All original arithmetic and signed64->double execute; external clock, locks,
strcmp and logging are explicit oracle hooks. Not a concurrent live runtime.
"""
from pathlib import Path
import ctypes as C,itertools,json,os,random,struct,sys
R=Path(__file__).resolve().parents[1]
from freshness_oracle import FreshnessOracle
U8=C.c_uint8;U32=C.c_uint32;I32=C.c_int32;U64=C.c_uint64;P=C.c_void_p
class View(C.Structure):_fields_=[('data',P),('size',C.c_size_t)]
class Gate(C.Structure):_fields_=[('word_1fc',U32),('a',U8),('b',U8),('c',U8),('d',U8)]
class Snapshot(C.Structure):_fields_=[('block',U32),('current',U32),('roll',I32),('share',U8),('active',U8),('notify',U8),('staged',U64),('now',U64),('job',View),('pooljob',View)]
class Result(C.Structure):_fields_=[('stale',I32),('reason',I32),('ids',U32),('time',U32),('expiry',C.c_double),('age',C.c_double)]
class Storage(C.Structure):_fields_=[('image',U8*632),('text',P*4),('sizes',C.c_size_t*4)]
MASK=(1<<64)-1
lib=C.CDLL(str(Path(os.environ.get('VN135_TEST_LIBRARY',R/'build/libvn135_recovered.so')).resolve()))
lib.vn135_pool_unusable_legacy.argtypes=[C.POINTER(Gate),C.POINTER(C.c_int)]
lib.vn135_frontend_work_stale_legacy.argtypes=[C.POINTER(Snapshot),C.POINTER(Result)]
lib.vn135_work_storage_stale_snapshot.argtypes=[C.POINTER(Storage),U32,U8,U8,U8,View,U64,C.POINTER(Result)]
def main():
    o=FreshnessOracle();rnd=random.Random(14001);gates=0;checks=0;reasons={};original_events={};adapters=0
    states=list(itertools.product([0,1,2,0x7fffffff,0xffffffff],*[ [0,1,2,255] for _ in range(4)]))
    states += [(rnd.getrandbits(32),*[rnd.randrange(256) for _ in range(4)]) for i in range(160)]
    for state in states:
        g=Gate(*state);v=C.c_int(-99);before=bytes(g)
        assert lib.vn135_pool_unusable_legacy(C.byref(g),C.byref(v))==0
        assert v.value==o.gate(state) and bytes(g)==before;gates+=1
    cases=[]
    ids=[(None,None),(None,b'a'),(b'a',None),(b'',b''),(b'a',b'a'),(b'a',b'b'),(b'\xffz',b'\xffz'),(b'',b'z'),(b'a'*512,b'a'*511+b'b')]
    for share in (0,1,255):
      for active,notify in ((0,0),(0,1),(1,0),(1,1),(255,2)):
       for job,pooljob in ids:
        for roll in (-2147483648,-1,0,60,61,599,600,601,2147483647):
         expiry=roll if roll>60 else 600
         for age in (-1,0,expiry-1,expiry,expiry+1):
          cases.append((71,71,roll,share,active,notify,2**32-3,2**32-3+age,job,pooljob))
    # Changed work block short-circuits even inactive pool and negative time.
    for i in range(90):
      cases.append((0,rnd.randrange(1,2**32),rnd.randrange(-2**31,2**31),i%2,i%256,(i*7)%256,0,2**64-1,b'a',b'b'))
    edges=[0,1,2**31-1,2**32-1,2**32,2**53-1,2**53,2**53+1,2**63-1,2**63,2**64-1]
    for staged,now in itertools.product(edges,edges):cases.append((1,1,60,1,0,0,staged,now,b'a',b'b'))
    for i in range(640):
      staged=rnd.getrandbits(64);age=rnd.choice([59,60,61,599,600,601,rnd.getrandbits(64)])
      job,pooljob=rnd.choice(ids);share=rnd.choice([0,1]);active=rnd.choice([0,1,2]);notify=rnd.choice([0,1,255]);roll=rnd.choice([0,60,61,600,rnd.randrange(-2**31,2**31)])
      cases.append((1,1,roll,share,active,notify,staged,(staged+age)&MASK,job,pooljob))
    for k,case in enumerate(cases):
      block,current,roll,share,active,notify,staged,now,job,pooljob=case
      bufs=[C.create_string_buffer(x+b'\0') if x is not None else None for x in (job,pooljob)]
      views=[View(C.addressof(b) if b is not None else None,len(x) if x is not None else 0) for b,x in zip(bufs,(job,pooljob))]
      s=Snapshot(block,current,roll,share,active,notify,staged&MASK,now&MASK,*views);before=bytes(s);out=Result()
      assert lib.vn135_frontend_work_stale_legacy(C.byref(s),C.byref(out))==0
      expected=o.stale(*case);assert out.stale==expected['stale'],(case,out.stale,expected)
      assert bytes(s)==before
      ev=expected['events'];assert out.ids==int('strcmp' in ev) and out.time==int('clock' in ev),(case,out.ids,out.time,ev)
      if block!=current:reason=1;assert ev==[]
      elif not share and (not active or not notify):reason=2;assert ev==['log']
      elif not share and job is not None and pooljob is not None and job!=pooljob:reason=3;assert ev==['lock','strcmp','unlock','after_unlock']
      else:
        reason=4 if out.stale else 0
        path=[] if share else ['lock']+(['strcmp'] if job is not None and pooljob is not None else [])+['unlock','after_unlock']
        assert ev==path+['clock']+(['log'] if out.stale else [])
      assert out.reason==reason
      if out.time:
        bits=(now-staged)&MASK;signed=bits-(1<<64) if bits>>63 else bits
        assert struct.pack('<d',out.age)==struct.pack('<d',float(signed))
        assert out.expiry==float(roll if roll>60 else 600)
      reasons[str(reason)]=reasons.get(str(reason),0)+1;checks+=1
      for e in ev:original_events[e]=original_events.get(e,0)+1
      if k%17==0:
        w=Storage();image=bytearray(b'\xa7'*632)
        for off in (0x18c,0x19c,0x1a8,0x1b0):struct.pack_into('<I',image,off,0)
        struct.pack_into('<I',image,0x1b8,block);struct.pack_into('<i',image,0x184,roll);struct.pack_into('<Q',image,0x170,staged&MASK)
        w.image[:]=image;w.text[0]=views[0].data;w.sizes[0]=views[0].size;before=bytes(w);other=Result()
        assert lib.vn135_work_storage_stale_snapshot(C.byref(w),current,share,active,notify,views[1],now&MASK,C.byref(other))==0
        assert (other.stale,other.reason,other.ids,other.time,other.age,other.expiry)==(out.stale,out.reason,out.ids,out.time,out.age,out.expiry)
        assert bytes(w)==before;adapters+=1
    result={'main_comparisons':gates+checks,'pool_gate':gates,'stale_work':checks,'reasons':reasons,'original_events':original_events,'adapter_compositions_separate':adapters,'original_signed64_to_double_executed':True,'original_synchronization_implemented':False,'hardware_tested':False}
    print(json.dumps(result,indent=2));(R/'build/stage14-results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
