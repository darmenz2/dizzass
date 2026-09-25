#!/usr/bin/env python3
"""Synthetic instruction tests, separate from reconstruction comparisons."""
from pathlib import Path
import json,random,sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce
m=ARM32Nonce(ELF32(ROOT/'reference/cgminer.vendor.elf'))
code=ELF32(ROOT/'tests/fixtures/arm32_stage7_instructions.o').section('.text')
a=m.DATA_BASE;m.mem[a:a+len(code)]=code
rng=random.Random(0x7135);count=0
values=[0,1,0xffffffff,0x80000000,0x7fffffff,0x00008000,0x80010000,0x12345678]+[rng.getrandbits(32) for _ in range(256)]
for n in values:
    for i,rot in enumerate((0,8,16,24)):
        m.reset((n,));got=m.run(a+8*i,max_steps=10)
        want=((n>>rot)|(n<<(32-rot) if rot else 0))&0xffff
        assert got==want;(count:=count+1)
def signed16(x):return ((x&0xffff)^0x8000)-0x8000
def signed32(x):return (x^0x80000000)-0x80000000
cases=[(x,y,z) for x in (0,1,0x7fff,0x8000,0xffff) for y in (0,1,0x7fff,0x8000,0xffff) for z in (0,0x7fffffff,0x80000000,0xffffffff)]
cases += [(rng.getrandbits(32),rng.getrandbits(32),rng.getrandbits(32)) for _ in range(512)]
for x,y,z in cases:
    total=signed16(x)*signed16(y)+signed32(z)
    for sticky in (False,True):
        m.reset((x,y,z));m.q=sticky
        assert m.run(a+32,max_steps=10)==total&0xffffffff
        assert m.q==(sticky or not -2**31<=total<2**31);count+=1
    for cond in (0,1):
        m.reset((x,y,z,cond));got=m.run(a+40,max_steps=10)
        assert got==(total&0xffffffff if cond==0 else x);count+=1
# Exercise the exact SMLABB form in table lookup: smlabb r10,r1,r2,r0.
m.write(a,0xe10a0281);m.write(a+4,0xe12fff1e)
for slot in range(32):
    m.reset((0x653458,slot,168));m.run(a,max_steps=10)
    assert m.r[10]==0x653458+slot*168;count+=1
out={'status':'PASS','synthetic_instruction_cases':count,'opcodes':['UXTH','SMLABB'],
     'Q_modeled':True,'independent_emulator_certification':False}
(ROOT/'build').mkdir(exist_ok=True);(ROOT/'build/stage7-interpreter-results.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out))
