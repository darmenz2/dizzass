"""A32 nonce-slice extension: UXTH and SMLABB only.
SMLABB updates sticky Q for synthetic tests; original slice never reads Q.
No hardware, syscalls, or ELF process execution.
"""
from arm32_rx_subset import ARM32RX
from arm32_subset import MASK, signed, ror

class ARM32Nonce(ARM32RX):
    def reset(self,args=()):
        super().reset(args)
        self.q=False
    def extra_instruction(self,w,pc):
        if w & 0x0fff03f0 == 0x06ff0070:  # UXTH Rd,Rm{,ROR #0/8/16/24}
            d=(w>>12)&15;n=w&15
            if d==15 or n==15:raise ValueError('UXTH PC operands unsupported')
            self.r[d]=ror(self.get(n,pc),((w>>10)&3)*8)&0xffff
            return True
        if w & 0x0ff000f0 == 0x01000080:  # SMLABB Rd,Rm,Rs,Rn
            d=(w>>16)&15;n=(w>>12)&15;s=(w>>8)&15;a=w&15
            if 15 in (d,n,s,a):raise ValueError('SMLABB PC operands unsupported')
            def s16(x):return (x&0xffff)-0x10000 if x&0x8000 else x&0xffff
            result=s16(self.get(a,pc))*s16(self.get(s,pc))+signed(self.get(n,pc))
            self.r[d]=result&MASK
            self.q=self.q or not (-0x80000000<=result<=0x7fffffff)
            return True
        return super().extra_instruction(w,pc)
