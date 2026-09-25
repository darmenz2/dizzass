#!/usr/bin/env python3
"""Synthetic and libgcc-helper checks kept OUTSIDE reconstruction case counts.
Exact rational products/additions used for independent two-round references.
No independently certified emulator or physical ARM CPU involved.
"""
from pathlib import Path
from fractions import Fraction
import json,math,random,struct,sys
ROOT=Path(__file__).resolve().parents[1];sys.path[:0]=[str(ROOT/'tools'),str(ROOT/'tests')]
from elf32 import ELF32
from arm32_difficulty_subset import ARM32Difficulty
from difficulty_oracle import DifficultyOracle
m=ARM32Difficulty(ELF32(ROOT/'reference/cgminer.vendor.elf'));a=m.DATA_BASE
code=ELF32(ROOT/'tests/fixtures/arm32_stage10_instructions.o').section('.text')
ops=[int.from_bytes(code[i:i+4],'little') for i in range(0,len(code),4)]
assert ops==[0xec410b10,0xec532b18,0xeeb58b40,0xeebc7bc7,0xeeb84b47,0xee018b00,0xee018b40,0x0e018b00]
r=random.Random(10010);count=0

def single(w):m.write(a,w);m.run(a,stop=a+4,max_steps=2)
for bits in [0,1,0x8000000000000000,0x7ff8000000000012,0x7ff0000000000000,0xffffffffffffffff]+[r.getrandbits(64) for _ in range(150)]:
    m.reset((bits&0xffffffff,bits>>32));single(ops[0]);assert m.dbits(0)==bits;count+=1
    m.reset();m.set_dbits(8,bits);single(ops[1]);assert m.r[2]|m.r[3]<<32==bits;count+=1
for x in [0.,-0.,-1.,1.,-2.**80,2.**80]+[r.uniform(-1e20,1e20) for _ in range(120)]:
    m.reset();m.set_d(8,x);single(ops[2]);assert m.fp_flags==(x<0,x==0,x>=0,False);count+=1
for x in [-2.**100,-1.,-0.,0.,0.9,1.,1.9,2.**32-1,2.**32,2.**64]+[r.uniform(-1e9,1e10) for _ in range(120)]:
    m.reset();m.set_d(7,x);single(ops[3]);assert m.s[14]==max(0,min(2**32-1,int(x)));count+=1
for u in [0,1,0xffffffff,0x80000000]+[r.getrandbits(32) for _ in range(120)]:
    m.reset();m.s[14]=u;single(ops[4]);assert m.d(4)==float(u);count+=1
values=[(1.+2.**-27,1.-2.**-27,-1.),(1.+2.**-27,1.-2.**-27,1.)]
values += [(math.ldexp(r.uniform(-2,2),r.randrange(-100,100)),math.ldexp(r.uniform(-2,2),r.randrange(-100,100)),math.ldexp(r.uniform(-2,2),r.randrange(-100,100))) for _ in range(200)]
for x,y,z in values:
    product=float(Fraction(x)*Fraction(y))
    for op,sign in [(5,1),(6,-1)]:
        expected=float(Fraction(z)+sign*Fraction(product))
        m.reset();m.set_d(1,x);m.set_d(0,y);m.set_d(8,z);single(ops[op])
        assert struct.pack('<d',m.d(8))==struct.pack('<d',expected),(x,y,z,op,m.d(8),expected);count+=1
    m.reset();m.z=False;m.set_d(8,z);single(ops[7]);assert m.d(8)==z;count+=1
# An actual FMA here would produce -2^-54, not the original VMLA result zero.
x,y,z=values[0];assert float(Fraction(x)*Fraction(y)+Fraction(z)) == -2.**-54
m.reset();m.set_d(1,x);m.set_d(0,y);m.set_d(8,z);single(ops[5]);assert m.d(8)==0;count+=1
for op in [2,3,5]:
    m.reset();m.set_dbits(8,0x7ff0000000000000);m.set_dbits(7,0x7ff8000000000000)
    try:single(ops[op])
    except ValueError:count+=1
    else:raise AssertionError('nonfinite arithmetic must be explicitly rejected')
o=DifficultyOracle();helpers=0
uv=[0,1,2**64-1]+[max(0,min(2**64-1,(1<<i)+delta)) for i in range(64) for delta in [-1,0,1]]+[r.getrandbits(64) for _ in range(250)]
for u in uv:
    assert struct.pack('<d',o.u64_to_double(u))==struct.pack('<d',float(u));helpers+=1
fv=[-2.**100,-1.,-0.,0.,0.1,0.9,1.,1.9,2.**32-1,2.**32,2.**53-1,2.**53,math.nextafter(2.**64,0.),2.**64,2.**100]
fv += [math.ldexp(r.uniform(1,2),r.randrange(-20,120)) for _ in range(200)]
for v in fv:
    assert o.double_to_u64(v)==max(0,min(2**64-1,int(v)));helpers+=1
result={'status':'PASS','synthetic_instruction_checks':count,'original_conversion_helper_checks':helpers,
        'fused_vs_unfused_distinguished':True,'default_rounding_only':True,'hardware_tested':False}
(ROOT/'build/stage10-interpreter-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
