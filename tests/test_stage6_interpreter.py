#!/usr/bin/env python3
"""Synthetic tests for the newly implemented instruction encodings only."""
from pathlib import Path
import json, random, sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_rx_subset import ARM32RX
m=ARM32RX(ELF32(ROOT/'reference/cgminer.vendor.elf'))
code=ELF32(ROOT/'tests/fixtures/arm32_stage6_instructions.o').section('.text')
base=m.DATA_BASE; mem=base+0x1000
m.mem[base:base+len(code)]=code
n=0; rng=random.Random(0x6135)
for value in [0,1,0xffffffff,0x80000000,0x01234567]+[rng.getrandbits(32) for _ in range(512)]:
    m.reset((value,));got=m.run(base,max_steps=10)
    assert got==int.from_bytes(value.to_bytes(4,'little'),'big');n+=1
for byte in range(256):
    want=(byte if byte<128 else byte-256)&0xffffffff
    for offset,start,address,after,reg in ((8,mem,mem,mem,0),(16,mem,mem+3,mem+3,0),
                                         (24,mem,mem,mem-3,0),(32,mem+7,mem,mem,7)):
        m.reset((0,start,reg));m.write(address,byte,1)
        assert m.run(base+offset,max_steps=10)==want
        assert m.r[1]==after;n+=1
    for cond in (0,1):
        m.reset((0x12345678,mem,cond));m.write(mem,byte,1)
        assert m.run(base+40,max_steps=10)==(want if cond==0 else 0x12345678);n+=1
# Exact code bytes used in fixture must contain independently assembled REV/LDRSB.
assert int.from_bytes(code[:4],'little')==0xe6bf0f30
assert int.from_bytes(code[8:12],'little')==0xe1d100d0
# Instructions not supported by this restricted extension must still fail.
m.reset();m.write(base,0xffffffff)
try:m.run(base,max_steps=10)
except ValueError:pass
else:raise AssertionError('Unsupported opcode accepted')
output={'synthetic_instruction_cases':n,'extended_opcodes':['REV','LDRSB'],
        'independent_hardware_emulator':False,'status':'PASS'}
(ROOT/'build').mkdir(exist_ok=True)
(ROOT/'build/stage6-interpreter-results.json').write_text(json.dumps(output,indent=2)+'\n')
print(json.dumps(output))
