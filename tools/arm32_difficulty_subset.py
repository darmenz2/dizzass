"""Stage10 bounded extensions for original difficulty/target routines.
Default binary64 round-to-nearest/even only. VMLA/VMLS are deliberately two
rounded operations, NOT fused. No FPSCR exception flags, non-default rounding,
NaN/Inf arithmetic or physical CPU claim. VCVT.u32 saturates finite inputs.
"""
import math
from arm32_rebuild_subset import ARM32Rebuild
from arm32_subset import MASK

class ARM32Difficulty(ARM32Rebuild):
    def extra_instruction(self, w, pc):
        # VMOV two core registers <-> a double register; bit-preserving.
        if w & 0x0fe00fd0 == 0x0c400b10:
            rt=(w>>12)&15; rt2=(w>>16)&15; dm=(w&15)+(((w>>5)&1)*16)
            if rt==15 or rt2==15 or rt==rt2:
                raise ValueError('Unsupported paired core register VMOV')
            if w & (1<<20):
                bits=self.dbits(dm);self.r[rt]=bits&MASK;self.r[rt2]=bits>>32
            else:
                self.set_dbits(dm,self.r[rt]|(self.r[rt2]<<32))
            return True
        dn=((w>>12)&15)+(((w>>22)&1)*16)
        nn=((w>>16)&15)+(((w>>7)&1)*16)
        mn=(w&15)+(((w>>5)&1)*16)
        if w & 0x0fbf0fff == 0x0eb50b40:  # VCMP Dd, #0
            a=self.d(dn)
            if not math.isfinite(a):raise ValueError('Non-finite comparison')
            self.fp_flags=(a<0.0,a==0.0,a>=0.0,False)
            return True
        unary=w & 0x0fbf0fd0
        if unary==0x0ebc0bc0:  # VCVT.u32.f64 Sd, Dm
            sd=((w>>12)&15)*2+((w>>22)&1);a=self.d(mn)
            if not math.isfinite(a):raise ValueError('Non-finite conversion')
            self.s[sd]=max(0,min(MASK,math.trunc(a)))
            return True
        if unary==0x0eb80b40:  # VCVT.f64.u32 Dd, Sm
            sn=(w&15)*2+((w>>5)&1)
            self.set_d(dn,float(self.s[sn]));return True
        op=w & 0x0fb00f50
        if op in (0x0e000b00,0x0e000b40):  # VMLA/VMLS.f64
            a,b,c=self.d(nn),self.d(mn),self.d(dn)
            if not all(math.isfinite(x) for x in (a,b,c)):
                raise ValueError('Non-finite multiply accumulate input')
            product=a*b
            if not math.isfinite(product):raise ValueError('Non-finite product')
            self.set_d(dn,c-product if op==0x0e000b40 else c+product)
            return True
        return super().extra_instruction(w,pc)
