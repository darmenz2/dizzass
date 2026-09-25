"""A32 RX-slice extension: REV and LDRSB only; same no-I/O bounded model."""
from arm32_subset import ARM32, MASK

class ARM32RX(ARM32):
    def extra_instruction(self, w, pc):
        # REV Rd,Rm (word byte reversal).
        if w & 0x0fff0ff0 == 0x06bf0f30:
            d=(w >> 12)&15; n=w&15
            if d==15 or n==15: raise ValueError('REV PC operands not supported')
            self.r[d]=int.from_bytes(self.get(n,pc).to_bytes(4,'little'),'big')
            return True
        # LDRSB: sign-extended byte, immediate/register, pre/post addressing.
        if w & 0x0e1000f0 == 0x001000d0:
            rn=(w>>16)&15; rt=(w>>12)&15
            if rt==15: raise ValueError('LDRSB PC destination not supported')
            off=(((w>>4)&0xf0)|(w&15)) if w&(1<<22) else self.get(w&15,pc)
            base=self.get(rn,pc)
            end=(base+(off if w&(1<<23) else -off))&MASK
            address=end if w&(1<<24) else base
            x=self.read(address,1)
            self.r[rt]=(x-256 if x&128 else x)&MASK
            if w&(1<<21) or not w&(1<<24):self.r[rn]=end
            return True
        return super().extra_instruction(w,pc)
