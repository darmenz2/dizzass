#!/usr/bin/env python3
"""Synthetic BLX-register checks, NOT counted as firmware reconstruction cases."""
from pathlib import Path
import json,sys,random
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_verify_subset import ARM32Verify
m=ARM32Verify(ELF32(ROOT/'reference/cgminer.vendor.elf'));a=m.DATA_BASE;target=a+0x100
fixture=ELF32(ROOT/'tests/fixtures/arm32_stage8_instructions.o').section('.text')
assert int.from_bytes(fixture[4:8],'little')==0xe12fff31
assert int.from_bytes(fixture[12:16],'little')==0xe12fff3e
count=0
# Expected condition table explicitly, independent of interpreter cond().
for reg in range(15):
    for cond in range(15):
        for flags in range(16):
            m.reset();n,z,c,v=[bool(flags&(1<<i)) for i in range(4)]
            m.n=n;m.z=z;m.c=c;m.v=v;m.q=bool(flags&1)
            expected=(z,not z,c,not c,n,not n,v,not v,c and not z,not c or z,
                      n==v,n!=v,not z and n==v,z or n!=v,True)[cond]
            oldlr=target if reg==14 else m.RETURN;m.r[reg]=target
            m.write(a,(cond<<28)|0x012fff30|reg)
            m.run(a,stop=target if expected else a+4,max_steps=2)
            assert m.r[14]==(a+4 if expected else oldlr)
            assert (m.n,m.z,m.c,m.v,m.q)==(n,z,c,v,bool(flags&1));count+=1
for reg in range(15):
    for off in (1,2,3):
        m.reset();m.r[reg]=target+off;m.write(a,0xe12fff30|reg)
        try:m.run(a,max_steps=3)
        except ValueError as exc:assert 'unsupported' in str(exc);count+=1
        else:raise AssertionError('accepted unsupported BLX target')
m.reset();m.write(a,0xe12fff3f)
try:m.run(a,max_steps=2)
except ValueError as exc:assert 'PC unsupported' in str(exc);count+=1
else:raise AssertionError('accepted BLX pc')
# Full assembler-generated push -> BLX -> real callee -> pop/return.
m.mem[a:a+len(fixture)]=fixture;m.write(target,0xe2800003);m.write(target+4,0xe12fff1e)
for value in [0,1,0x7fffffff,0x80000000,0xffffffff]+[random.Random(i).getrandbits(32) for i in range(128)]:
    m.reset((value,target));assert m.run(a,max_steps=20)==(value+3)&0xffffffff;count+=1
out={'status':'PASS','synthetic_instruction_cases':count,'instructions':['BLX register, A32 targets'],
     'unsupported_thumb_rejected':True,'ELF_not_executed_as_process':True}
(ROOT/'build/stage8-interpreter-results.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out))
