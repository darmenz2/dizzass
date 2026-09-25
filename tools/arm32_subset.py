"""Bounded A32 integer-instruction interpreter, NOT a general ARM emulator.

Only the opcodes needed for the documented offline slices are accepted. No
syscalls, I/O, native execution, VFP, Thumb, or hardware access are supported.
Unknown opcodes, unmapped access, unexpected calls and step exhaustion are errors.
Tests compare instruction words in the supplied original ELF against new C code.
This interpreter is an independent local test aid, not hardware certification.
"""
from __future__ import annotations
import struct
from elf32 import ELF32
MASK=0xffffffff

def ror(x,n):
    n%=32;return ((x>>n)|(x<<(32-n)))&MASK if n else x&MASK

def signed(x):return x-(1<<32) if x&(1<<31) else x

class ARM32:
    STACK_BASE=0x800000
    STACK_TOP=0x81f000
    RETURN=0x820000
    DATA_BASE=0x840000
    def __init__(self,elf):
        self.mem=bytearray(0x880000)
        self.regions=[]
        for s in elf.segments:
            a=s['addr'];n=s['memsz']
            if a+n>len(self.mem):raise ValueError('ELF mapping exceeds test memory')
            self.mem[a:a+s['filesz']]=elf.data[s['offset']:s['offset']+s['filesz']]
            self.regions.append((a,a+n))
        self.regions += [(self.STACK_BASE,self.STACK_TOP+0x1000),(self.DATA_BASE,self.DATA_BASE+0x10000)]
        self.reset()
    def reset(self,args=()):
        self.r=[0]*16;self.r[13]=self.STACK_TOP;self.r[14]=self.RETURN
        self.n=self.z=self.c=self.v=False;self.steps=0;self.trace=[]
        self.mem[self.STACK_BASE:self.STACK_TOP+0x1000]=b'\0'*0x20000
        for i,v in enumerate(args):
            if i<4:self.r[i]=v&MASK
            else:self.write(self.STACK_TOP+4*(i-4),v)
    def check(self,a,n):
        if n<0 or not any(l<=a and a+n<=h for l,h in self.regions):
            raise ValueError(f'Unmapped memory 0x{a:x}, {n}')
    def read(self,a,n=4):
        self.check(a,n);return int.from_bytes(self.mem[a:a+n],'little')
    def write(self,a,v,n=4):
        self.check(a,n);self.mem[a:a+n]=(v&((1<<(n*8))-1)).to_bytes(n,'little')
    def get(self,i,pc):return (pc+8)&MASK if i==15 else self.r[i]
    def cond(self,c):
        return (self.z,not self.z,self.c,not self.c,self.n,not self.n,self.v,not self.v,
                self.c and not self.z,not self.c or self.z,self.n==self.v,self.n!=self.v,
                not self.z and self.n==self.v,self.z or self.n!=self.v,True,False)[c]
    def shift(self,x,kind,n,reg=False):
        x&=MASK
        if reg and n==0:return x,self.c
        if kind==0:
            if n==0:return x,self.c
            if n<32:return (x<<n)&MASK,bool((x>>(32-n))&1)
            return 0,bool(x&1) if n==32 else False
        if kind==1:
            n=n or 32
            if n<32:return x>>n,bool((x>>(n-1))&1)
            return 0,bool(x>>31) if n==32 else False
        if kind==2:
            n=n or 32
            if n>=32:return (MASK if x>>31 else 0),bool(x>>31)
            return (signed(x)>>n)&MASK,bool((x>>(n-1))&1)
        if n==0:return ((int(self.c)<<31)|(x>>1)),bool(x&1)
        y=ror(x,n);return y,bool(y>>31)
    def operand2(self,w,pc):
        if w&(1<<25):
            n=((w>>8)&15)*2;y=ror(w&255,n);return y,(bool(y>>31) if n else self.c)
        rm=self.get(w&15,pc);kind=(w>>5)&3
        if w&16:
            n=self.get((w>>8)&15,pc)&255
            return self.shift(rm,kind,n,True)
        return self.shift(rm,kind,(w>>7)&31)
    def extra_instruction(self,w,pc):
        # CLZ. Kept ahead of generic data processing.
        if w&0x0fff0ff0==0x016f0f10:
            x=self.get(w&15,pc)
            self.r[(w>>12)&15]=32-x.bit_length()
            return True
        # LDRH/STRH with immediate or register offset, pre/post indexing.
        if w&0x0e0000f0==0x000000b0:
            rn=(w>>16)&15;rt=(w>>12)&15;base=self.get(rn,pc)
            off=(((w>>4)&0xf0)|(w&15)) if w&(1<<22) else self.get(w&15,pc)
            end=(base+(off if w&(1<<23) else -off))&MASK
            addr=end if w&(1<<24) else base
            if w&(1<<20): self.r[rt]=self.read(addr,2)
            else: self.write(addr,self.get(rt,pc),2)
            if w&(1<<21) or not w&(1<<24): self.r[rn]=end
            return True
        return False
    def run(self,start,stop=None,hooks=None,max_steps=250000):
        self.r[15]=start;hooks=hooks or {}
        while self.steps<max_steps:
            pc=self.r[15]
            if pc==self.RETURN or (stop is not None and pc==stop):return self.r[0]
            if pc in hooks:
                hooks[pc](self);self.r[15]=self.r[14];continue
            self.steps+=1;w=self.read(pc);self.r[15]=(pc+4)&MASK
            cond=w>>28
            if cond==15:raise ValueError(f'Unsupported unconditional opcode {w:08x} at {pc:x}')
            if not self.cond(cond):continue
            if self.extra_instruction(w,pc):continue
            # BX, MOVW/MOVT, UXTB, UBFX, BFI
            if w&0x0ffffff0==0x012fff10:
                dst=self.get(w&15,pc)
                if dst&1:raise ValueError('Thumb is not supported')
                self.r[15]=dst;continue
            if w&0x0ff00000 in (0x03000000,0x03400000):
                d=(w>>12)&15;imm=((w>>4)&0xf000)|(w&0xfff)
                self.r[d]=((self.r[d]&0xffff)|(imm<<16)) if w&0x00400000 else imm;continue
            if w&0x0fff03f0==0x06ef0070:
                self.r[(w>>12)&15]=ror(self.get(w&15,pc),((w>>10)&3)*8)&255;continue
            if w&0x0fe00070==0x07e00050:
                width=((w>>16)&31)+1;lsb=(w>>7)&31
                if width+lsb>32:raise ValueError('Bad UBFX')
                self.r[(w>>12)&15]=(self.get(w&15,pc)>>lsb)&((1<<width)-1);continue
            if w&0x0fe00070==0x07c00010:
                msb=(w>>16)&31;lsb=(w>>7)&31;d=(w>>12)&15
                if msb<lsb:raise ValueError('Bad BFI')
                mask=((1<<(msb-lsb+1))-1)<<lsb
                val=0 if (w&15)==15 else self.get(w&15,pc)
                self.r[d]=(self.r[d]&~mask)|((val<<lsb)&mask);continue
            # MUL / MLA
            if w&0x0fc000f0==0x00000090:
                d=(w>>16)&15;y=self.get(w&15,pc)*self.get((w>>8)&15,pc)
                if w&(1<<21):y+=self.get((w>>12)&15,pc)
                y&=MASK;self.r[d]=y
                if w&(1<<20):self.z=y==0;self.n=bool(y>>31)
                continue
            # B / BL
            if w&0x0e000000==0x0a000000:
                delta=w&0xffffff
                if delta&0x800000:delta-=1<<24
                dst=(pc+8+(delta<<2))&MASK
                if w&(1<<24):self.r[14]=pc+4
                self.r[15]=dst;continue
            # LDM / STM (including push/pop)
            if w&0x0e000000==0x08000000:
                rn=(w>>16)&15;regs=[i for i in range(16) if w&(1<<i)]
                base=self.get(rn,pc);up=bool(w&(1<<23));pre=bool(w&(1<<24));load=bool(w&(1<<20))
                a=base+(4 if pre else 0) if up else base-4*len(regs)+(0 if pre else 4)
                vals=[]
                for i in regs:
                    if load:vals.append((i,self.read(a)))
                    else:self.write(a,self.get(i,pc))
                    a+=4
                if w&(1<<21):self.r[rn]=(base+(4*len(regs) if up else -4*len(regs)))&MASK
                for i,val in vals:self.r[i]=val
                continue
            # LDR / STR, with byte transfers and post-indexing
            if w&0x0c000000==0x04000000:
                rn=(w>>16)&15;d=(w>>12)&15;base=self.get(rn,pc)
                if w&(1<<25):
                    if w&16:raise ValueError('Register-shifted transfer unsupported')
                    off,_=self.shift(self.get(w&15,pc),(w>>5)&3,(w>>7)&31)
                else:off=w&0xfff
                changed=(base+(off if w&(1<<23) else -off))&MASK
                a=changed if w&(1<<24) else base;n=1 if w&(1<<22) else 4
                if w&(1<<20):self.r[d]=self.read(a,n)
                else:self.write(a,self.get(d,pc),n)
                if (w&(1<<21)) or not w&(1<<24):self.r[rn]=changed
                continue
            # Classic data processing. Reject miscellaneous encodings.
            if w&0x0c000000==0:
                op=(w>>21)&15;setflags=bool(w&(1<<20));d=(w>>12)&15
                a=self.get((w>>16)&15,pc);b,carry=self.operand2(w,pc)
                overflow=self.v
                if op in (0,8):y=a&b
                elif op in (1,9):y=a^b
                elif op in (2,10,3):
                    x,t=(b,a) if op==3 else (a,b);y=(x-t)&MASK;carry=x>=t
                    overflow=bool(((x^t)&(x^y))>>31)
                elif op in (4,11):
                    y=(a+b)&MASK;carry=a+b>MASK;overflow=bool((~(a^b)&(a^y))&(1<<31))
                elif op==12:y=a|b
                elif op==13:y=b
                elif op==14:y=a&~b
                elif op==15:y=~b
                else:raise ValueError(f'Unsupported data op {op} at {pc:x}')
                y&=MASK
                if op not in (8,9,10,11):self.r[d]=y
                if setflags or op in (8,9,10,11):
                    self.z=y==0;self.n=bool(y>>31);self.c=bool(carry);self.v=bool(overflow)
                continue
            raise ValueError(f'Unsupported opcode 0x{w:08x} at 0x{pc:x}')
        raise RuntimeError(f'Step limit reached at 0x{self.r[15]:x}')
