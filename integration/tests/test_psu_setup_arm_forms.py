#!/usr/bin/env python3
"""Synthetic checks of the local instruction extension; not ARM certification."""
import math
import struct
from psu_setup_135_oracle import SetupOracle

def main():
    o=SetupOracle();m=o.m;pc=0x840100;count=0
    def begin():
        o.begin_setup();m.allowed=[(pc,pc+4)];m.n,m.z,m.c,m.v=True,False,True,False
    def execute(word):
        nonlocal count
        flags=m.n,m.z,m.c,m.v
        assert m.extra_instruction(word,pc)
        assert (m.n,m.z,m.c,m.v)==flags
        count+=1
    # Sign/rotate/extension and source/destination aliasing.
    for value in (0,1,0x7fff,0x8000,0xffff,0x12345678,0x80000000,0xffffffff):
        for rd,rm in ((0,1),(1,1),(12,3)):
            begin();m.r[rm]=value;execute(0xe6bf0fb0|(rd<<12)|rm)
            b=value.to_bytes(4,'little');assert m.r[rd]==int.from_bytes(b[1::-1]+b[3:1:-1],'little')
            begin();m.r[rm]=value;execute(0xe6ff0fb0|(rd<<12)|rm)
            signed=int.from_bytes(value.to_bytes(4,'little')[:2],'big',signed=True)
            assert m.r[rd]==signed&0xffffffff
            for rot in (0,8,16,24):
                v=((value>>rot)|(value<<(32-rot)))&0xffffffff if rot else value
                begin();m.r[rm]=value;execute(0xe6bf0070|(rd<<12)|((rot//8)<<10)|rm)
                assert m.r[rd]==int.from_bytes(v.to_bytes(4,'little')[:2],'little',signed=True)&0xffffffff
                for base,mask in ((0xe6e00070,255),(0xe6f00070,65535)):
                    for rn in (rm,2):
                        begin();m.r[rn]=0xffffffff;m.r[rm]=value;acc=m.r[rn]
                        execute(base|(rn<<16)|(rd<<12)|((rot//8)<<10)|rm)
                        assert m.r[rd]==(acc+(v&mask))&0xffffffff
    # Single loads/stores must preserve adjacent S words, core registers and flags.
    for sn in (0,1,2,15,16,31):
        for offset in (-12,0,12):
            for load in (False,True):
                begin();m.r[4]=0x846100;addr=m.r[4]+offset
                m.s=[0xa5a5a5a5]*64;m.s[sn]=0x12345678;m.write(addr,0x89abcdef)
                saved=m.s[:];regs=m.r[:]
                word=0xed000a00|(4<<16)|((sn//2)<<12)|((sn&1)<<22)|(abs(offset)//4)
                if offset>=0:word|=1<<23
                if load:word|=1<<20
                execute(word);assert m.r==regs
                if load:saved[sn]=0x89abcdef
                assert m.s==saved and m.read(addr)==(0x89abcdef if load else 0x12345678)
    for dn in (0,1,15,16,31):
        for src in (0,1,15,16,31):
            begin();bits=0x8000000000000000 if dn==src else 0x4029000000000000;m.set_dbits(src,bits)
            execute(0xeeb10b40|((dn&15)<<12)|((dn>>4)<<22)|(src&15)|((src>>4)<<5))
            assert m.dbits(dn)==bits^(1<<63)
    for sn in (0,1,15,31):
        for value in (-0.,0.,-1.5,1.5,math.nextafter(1.+2**-24,0),1.+2**-24,math.nextafter(1.+2**-24,2)):
            begin();m.set_d(2,value)
            execute(0xeeb70bc0|((sn//2)<<12)|((sn&1)<<22)|2)
            assert m.s[sn]==int.from_bytes(struct.pack('<f',value),'little')
    for dn in (0,1,15,16,31):
        for base,value in ((0xeeb60b00,.5),(0xeebe0b00,-.5),(0xeeb70b00,1.)):
            begin();execute(base|((dn&15)<<12)|((dn>>4)<<22));assert m.d(dn)==value
        for value in (-1.,-0.,0.,1.):
            begin();m.set_d(dn,value);execute(0xeeb50bc0|((dn&15)<<12)|((dn>>4)<<22))
            assert m.fp_flags==(value<0,value==0,value>=0,False)
    for sn in (0,1,15,31):
        for value in (-1.,-0.,0.,1.):
            begin();m.s[sn]=int.from_bytes(struct.pack('<f',value),'little')
            execute(0xeeb50ac0|((sn//2)<<12)|((sn&1)<<22))
            assert m.fp_flags==(value<0,value==0,value>=0,False)
    round_count=0
    for absolute in (0.,.1,.5,1.,1.5,2.5,16.5,127.5,254.5,255.,65535.5):
        for sign in (-1.,1.):
            v=sign*absolute
            for sample in (v,math.nextafter(v,-math.inf),math.nextafter(v,math.inf)):
                # Avoid subnormal inputs outside the documented FP model.
                if sample and abs(sample)<2**-1022:continue
                fractional,whole=math.modf(sample)
                expected=whole+(math.copysign(1.,sample) if abs(fractional)>=.5 else 0.)
                expected=math.copysign(expected,sample)
                bits=int.from_bytes(struct.pack('<d',expected),'little')
                assert o.original_round(sample)==bits,(sample,hex(o.original_round(sample)),hex(bits))
                round_count+=1
    print('PSU_SETUP_ARM_FORMS_PASS synthetic=%d original_round=%d'%(count,round_count))
    return count,round_count
if __name__=='__main__':main()
