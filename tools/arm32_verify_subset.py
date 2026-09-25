"""Stage 8: BLX register, ARM-state targets only. No Thumb or OS emulation."""
from arm32_nonce_subset import ARM32Nonce
class ARM32Verify(ARM32Nonce):
    def extra_instruction(self,w,pc):
        if w & 0x0ffffff0 == 0x012fff30:
            n=w&15
            if n==15: raise ValueError('BLX PC unsupported')
            target=self.get(n,pc)  # Read old LR before writing new LR for BLX LR.
            if target&3: raise ValueError('BLX Thumb/unaligned target unsupported')
            self.r[14]=(pc+4)&0xffffffff
            self.r[15]=target
            return True
        return super().extra_instruction(w,pc)
