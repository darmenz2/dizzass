#!/usr/bin/env python3
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_subset import ARM32
m=ARM32(ELF32(ROOT/'reference/cgminer.vendor.elf'))
code=ELF32(ROOT/'tests/fixtures/arm32_instructions.o').section('.text')
m.mem[m.DATA_BASE:m.DATA_BASE+len(code)]=code
assert m.run(m.DATA_BASE)==63,'A32 subset self-test failed'
# Unknown unconditional opcodes must not silently become no-ops.
m.reset();m.write(m.DATA_BASE,0xffffffff)
try:m.run(m.DATA_BASE,max_steps=10)
except ValueError:pass
else:raise AssertionError('Unknown opcode was not rejected')
# A nonterminating branch must hit the strict budget.
m.reset();m.write(m.DATA_BASE,0xeafffffe)
try:m.run(m.DATA_BASE,max_steps=10)
except RuntimeError:pass
else:raise AssertionError('Step budget was not enforced')
print('bounded A32 interpreter self-tests: PASS')
