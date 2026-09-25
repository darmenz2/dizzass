#!/usr/bin/env python3
"""Synthetic instruction checks, separate from vendor-output comparisons.
The local interpreter is not independently certified; see its documented limits.
"""
from pathlib import Path
import sys,struct,math,random,json
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_vfp_subset import ARM32VFP
from arm32_subset import signed
obj=ELF32(ROOT/'tests/fixtures/arm32_stage3_instructions.o')
strings=obj.section('.strtab');symbols={}
raw=obj.section('.symtab')
for offset in range(0,len(raw),16):
    name,value,size,info,other,shndx=struct.unpack_from('<IIIBBH',raw,offset)
    text=strings[name:strings.find(b'\0',name)].decode()
    if text.startswith('fx_'): symbols[text]=value
assert len(symbols)==12
m=ARM32VFP(ELF32(ROOT/'reference/cgminer.vendor.elf'))
code=obj.section('.text');base=m.DATA_BASE;dst=base+0x2000
m.mem[base:base+len(code)]=code
rng=random.Random(0x13503);count=0

def call(name,args=(),a=0.,b=0.):
    m.reset(args);m.set_d(0,a);m.set_d(1,b)
    return m.run(base+symbols['fx_'+name],max_steps=100)
for x in [0,1,2,0x80000000,0xffffffff]+[rng.getrandbits(32) for _ in range(128)]:
    assert call('clz',(x,))==32-x.bit_length();count+=1
    assert call('half',(dst,x))==(x&65535)
    assert m.r[2]==dst+2 and m.read(dst,2)==(x&65535);count+=1
for name,op in [('add',lambda a,b:a+b),('sub',lambda a,b:a-b),
                ('mul',lambda a,b:a*b),('div',lambda a,b:a/b)]:
    for i in range(128):
        a=rng.uniform(-1e7,1e7);b=rng.uniform(0.001,1e7)
        call(name,(dst,),a,b)
        assert m.read(dst,8)==int.from_bytes(struct.pack('<d',op(a,b)),'little');count+=1
for a in [-0.,-1.,1.,-1e100,1e100]+[rng.uniform(-1e6,1e6) for _ in range(128)]:
    call('abs',(dst,),a)
    assert m.read(dst,8)==int.from_bytes(struct.pack('<d',abs(a)),'little');count+=1
for x in [-2147483648,-1,0,1,2147483647]+[rng.randrange(-(1<<31),(1<<31)) for _ in range(128)]:
    call('i2d',(x,dst));assert struct.unpack('<d',m.read(dst,8).to_bytes(8,'little'))[0]==float(x);count+=1
for x in [-1e20,-2147483648.9,-1.9,-0.,0.,1.9,2147483647.9,1e20]+[rng.uniform(-1e6,1e6) for _ in range(128)]:
    assert signed(call('d2i',(),x))==max(-(1<<31),min((1<<31)-1,math.trunc(x)));count+=1
for a,b in [(-0.,0.),(-1.,1.),(1.,-1.),(1.,1.)]+[(rng.random(),rng.random()) for _ in range(128)]:
    assert signed(call('cmp',(),a,b))==((a>b)-(a<b));count+=1
m.reset();m.set_d(0,123.);m.set_d(1,-456.);m.set_d(8,17.5);m.set_d(9,-38.)
sp=m.r[13];m.run(base+symbols['fx_push']);assert (m.d(8),m.d(9),m.r[13])==(17.5,-38.,sp);count+=1
m.reset((dst,dst+8));m.write(dst,0x8000000000000000,8);m.run(base+symbols['fx_load'])
assert m.read(dst+8,8)==0x8000000000000000;count+=1
for x in [float('nan'),float('inf'),-float('inf')]:
    try:m.set_d(0,x)
    except ValueError:count+=1
    else:raise AssertionError('Non-finite input accepted')
try:call('div',(dst,),1.,0.)
except ValueError:count+=1
else:raise AssertionError('Zero division accepted')
result={'passed':True,'synthetic_cases':count,'fixture_functions':len(symbols),
 'scope':'CLZ, halfword post-index store/load, finite binary64 arithmetic/conversions/flags/transfers',
 'independent_cpu_emulator':False}
(ROOT/'build/stage3-interpreter-results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
