#!/usr/bin/env python3
"""Synthetic instruction checks, separate from vendor reconstruction counts."""
from pathlib import Path
import json,random,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_rebuild_subset import ARM32Rebuild
MASK=(1<<32)-1
m=ARM32Rebuild(ELF32(ROOT/'reference/cgminer.vendor.elf'))
a=m.DATA_BASE;data=a+0x1000
code=ELF32(ROOT/'tests/fixtures/arm32_stage9_instructions.o').section('.text')
ops=[int.from_bytes(code[i:i+4],'little') for i in range(0,len(code),4)]
assert ops[:3]==[0xe0b02001,0xe2a02000,0xe0b02181]
count=0;r=random.Random(910)
def single(w):
    m.write(a,w);m.run(a,stop=a+4,max_steps=2)
def sig(x):return x-(1<<32) if x>>31 else x
for x,y in [(0,0),(MASK,0),(MASK,1),(0x7fffffff,0),(0x7fffffff,1),
            (0x80000000,0x80000000),(MASK,MASK)]+[(r.getrandbits(32),r.getrandbits(32)) for _ in range(256)]:
    for carry in (False,True):
        for i in range(3):
            m.reset((x,y));m.n,m.z,m.c,m.v=True,False,carry,True
            b=y if i==0 else 0 if i==1 else (y<<3)&MASK
            total=x+b+int(carry);expected=total&MASK
            single(ops[i]);assert m.r[2]==expected
            if i!=1:
                assert (m.n,m.z,m.c,m.v)==(bool(expected>>31),expected==0,total>MASK,
                         not -(1<<31)<=sig(x)+sig(b)+int(carry)<(1<<31))
            else:assert (m.n,m.z,m.c,m.v)==(True,False,carry,True)
            count+=1
for val in [0,1,0xffffffffffffffff,0x0123456789abcdef]+[r.getrandbits(64) for _ in range(128)]:
    for i in range(3,11):
        m.reset((val&MASK,val>>32,data,12));m.n,m.z,m.c,m.v=True,False,True,False
        kind=(i-3)%4;address=data+(8 if kind==0 else -8 if kind==1 else 0 if kind==2 else 12)
        end=data+(-8 if kind==1 else 8) if kind in (1,2) else data
        # Address divisible by 4 but not necessarily 8 is supported explicitly.
        m.mem[data-16:data+32]=b'\xcc'*48
        if i<7:m.write(address,val,8)
        single(ops[i])
        if i<7:assert (m.r[0]|m.r[1]<<32)==val
        else:assert m.read(address,8)==val
        assert m.r[2]==end
        assert (m.n,m.z,m.c,m.v)==(True,False,True,False);count+=1
# Conditional instruction with condition false must not act.
for w in ops[:11]:
    m.reset();m.z=False;m.r[2]=1
    before=m.r[:15];single(w&0x0fffffff)
    assert m.r[:15]==before;count+=1
# Unsupported PC, odd destination, writeback alias and unaligned form.
for w,base in [(ops[0]|(15<<12),data),(ops[3]|(1<<12),data),
               ((ops[4]&~(15<<16))|(0<<16),data), (ops[3],data+1)]:
    m.reset((data,0,base))
    try:single(w)
    except ValueError:count+=1
    else:raise AssertionError('unsupported form accepted')
result={'status':'PASS','synthetic_instruction_cases':count,
        'instructions':['ADC/ADCS','LDRD/STRD restricted aligned forms'],
        'independent_hardware_validation':False}
(ROOT/'build/stage9-interpreter-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
