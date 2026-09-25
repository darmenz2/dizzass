"""Finite-input VFP extension for the two documented PLL search functions.

This is a bounded local test interpreter, not a full CPU/FPSCR implementation.
Uses Python binary64 for the default nearest-even arithmetic exercised here.
Does not model floating exception flags, non-default rounding, denormals, or
signalling NaNs; non-finite arithmetic is rejected. No Linux or device I/O.
"""
from __future__ import annotations
import math
import struct
from arm32_subset import ARM32, MASK, signed

class ARM32VFP(ARM32):
    def reset(self,args=()):
        super().reset(args)
        self.s=[0]*64
        self.fp_flags=(False,False,False,False)
    def dbits(self,n): return self.s[2*n] | (self.s[2*n+1]<<32)
    def set_dbits(self,n,b): self.s[2*n]=b&MASK; self.s[2*n+1]=(b>>32)&MASK
    def d(self,n): return struct.unpack('<d',self.dbits(n).to_bytes(8,'little'))[0]
    def set_d(self,n,x):
        if not math.isfinite(x): raise ValueError('Non-finite VFP arithmetic outside verified test domain')
        self.set_dbits(n,int.from_bytes(struct.pack('<d',x),'little'))
    def extra_instruction(self,w,pc):
        if super().extra_instruction(w,pc): return True
        if w&0x0fffffff==0x0ef1fa10:
            self.n,self.z,self.c,self.v=self.fp_flags
            return True
        # VMOV between an ARM core register and one single-precision register.
        if w&0x0fe00f7f==0x0e000a10:
            sn=((w>>16)&15)*2+((w>>7)&1); rt=(w>>12)&15
            if rt==15: raise ValueError('VMOV PC unsupported')
            if w&(1<<20): self.r[rt]=self.s[sn]
            else: self.s[sn]=self.get(rt,pc)
            return True
        # VFP cp11 load/store. D registers share storage with S register pairs.
        if w&0x0e000f00==0x0c000b00:
            rn=(w>>16)&15;dn=((w>>12)&15)+(((w>>22)&1)*16)
            pre=bool(w&(1<<24));up=bool(w&(1<<23));wb=bool(w&(1<<21));load=bool(w&(1<<20))
            size=(w&255)*4;base=self.get(rn,pc)
            if pre and not wb:
                addr=base+(size if up else -size)
                if load: self.set_dbits(dn,self.read(addr,8))
                else: self.write(addr,self.dbits(dn),8)
                return True
            if wb and ((pre and not up) or (not pre and up)) and size%8==0:
                n=size//8
                if dn+n>32: raise ValueError('Invalid VFP register span')
                addr=base-size if not up else base
                for i in range(n):
                    if load: self.set_dbits(dn+i,self.read(addr+i*8,8))
                    else: self.write(addr+i*8,self.dbits(dn+i),8)
                self.r[rn]=(base+(size if up else -size))&MASK
                return True
            raise ValueError(f'Unsupported VFP transfer {w:08x} at {pc:x}')
        dn=((w>>12)&15)+(((w>>22)&1)*16)
        nn=((w>>16)&15)+(((w>>7)&1)*16)
        mn=(w&15)+(((w>>5)&1)*16)
        op=w&0x0fb00f50
        if op in (0x0e200b00,0x0e300b00,0x0e300b40,0x0e800b00):
            a,b=self.d(nn),self.d(mn)
            if not math.isfinite(a) or not math.isfinite(b): raise ValueError('Non-finite VFP input')
            if op==0x0e200b00: y=a*b
            elif op==0x0e300b00: y=a+b
            elif op==0x0e300b40: y=a-b
            else:
                if b==0.0: raise ValueError('VFP division by zero outside tested domain')
                y=a/b
            self.set_d(dn,y);return True
        unary=w&0x0fbf0fd0
        if unary==0x0eb80bc0: # vcvt.f64.s32 Dd, Sm
            sn=((w&15)*2)+((w>>5)&1)
            self.set_d(dn,float(signed(self.s[sn])));return True
        if unary==0x0ebd0bc0: # vcvt.s32.f64 Sd, Dm: truncate, signed saturation
            sd=(((w>>12)&15)*2)+((w>>22)&1);v=self.d(mn)
            if not math.isfinite(v): raise ValueError('Non-finite VCVT')
            self.s[sd]=max(-(1<<31),min((1<<31)-1,math.trunc(v)))&MASK
            return True
        if unary==0x0eb00b40:
            self.set_dbits(dn,self.dbits(mn));return True
        if unary==0x0eb00bc0:
            self.set_dbits(dn,self.dbits(mn)&0x7fffffffffffffff);return True
        if w&0x0fbf0f50==0x0eb40b40: # VCMP/VCMPE, register operands
            a,b=self.d(dn),self.d(mn)
            if not math.isfinite(a) or not math.isfinite(b): raise ValueError('Non-finite VCMP')
            self.fp_flags=(a<b,a==b,a>=b,False)
            return True
        return False
