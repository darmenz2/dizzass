#!/usr/bin/env python3
"""Synthetic SBC/SBCS flag and integer tests plus actual signed64 conversion.
Not an independent CPU model certification. Original subtraction is NOT hooked.
"""
import itertools,json,random,struct
from freshness_oracle import FreshnessOracle
from arm32_subset import MASK,signed
m=FreshnessOracle().m;r=random.Random(1414);count=0
edges=[0,1,2,0x7ffffffe,0x7fffffff,0x80000000,0x80000001,0xfffffffe,0xffffffff]
values=list(itertools.product(edges,edges))+[(r.getrandbits(32),r.getrandbits(32)) for i in range(640)]
# The instruction word is also checked against the original SBC in stale_work.
assert m.read(0x320ec)==0xe0c31001
for reverse in (False,True):
 for a,b in values:
  for carry in (False,True):
   for setflags in (False,True):
    m.reset((a,b));m.c=carry;m.n,m.z,m.v=True,False,True;before=(m.n,m.z,m.c,m.v)
    w=(0xe0e02001 if reverse else 0xe0c02001) | (int(setflags)<<20)
    m.write(m.DATA_BASE,w);m.run(m.DATA_BASE,stop=m.DATA_BASE+4,max_steps=10)
    aa,bb=(b,a) if reverse else (a,b)
    total=aa+(MASK^bb)+int(carry);expected=total&MASK
    assert m.r[2]==expected
    if setflags:
     sm=signed(aa)-signed(bb)-int(not carry)
     assert (m.n,m.z,m.c,m.v)==(bool(expected>>31),expected==0,total>MASK,sm<-(1<<31) or sm>(1<<31)-1)
    else:assert (m.n,m.z,m.c,m.v)==before
    count+=1
# Actual helper receives bits as r0/r1 and returns binary64 in r0/r1.
conv=0
for x in [-(1<<63),-(1<<63)+1,-(1<<53)-1,-1,0,1,(1<<53)+1,(1<<63)-1]+[r.randrange(-(1<<63),1<<63) for i in range(256)]:
 bits=x&((1<<64)-1);m.reset((bits&MASK,bits>>32));m.run(0x59134c,max_steps=2000)
 assert struct.pack('<II',m.r[0],m.r[1])==struct.pack('<d',float(x));conv+=1
print(json.dumps({'synthetic_SBC_RSC_cases':count,'original_i64_conversion':conv,'not_in_main_comparison_total':True}))
