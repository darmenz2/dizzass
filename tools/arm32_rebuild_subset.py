"""Stage9 bounded A32 test aid: combine previous integer/VFP subsets; add
ADC and aligned-pair LDRD/STRD forms needed by the work materializer.
No OS, devices, Thumb, atomics or complete CPU/FPSCR implementation.
"""
from arm32_verify_subset import ARM32Verify
from arm32_vfp_subset import ARM32VFP
from arm32_subset import MASK, signed

class ARM32Rebuild(ARM32Verify, ARM32VFP):
    def extra_instruction(self, w, pc):
        # ADC{S}, data processing immediate or shifted register.
        if (w & 0x0de00000) == 0x00a00000 and (w & (1 << 25) or not (w & 0x90) == 0x90):
            d = (w >> 12) & 15
            if d == 15: raise ValueError('ADC PC destination unsupported')
            a = self.get((w >> 16) & 15, pc)
            b, _ = self.operand2(w, pc)
            carry_in = int(self.c)
            total = a + b + carry_in
            y = total & MASK
            self.r[d] = y
            if w & (1 << 20):
                self.n, self.z, self.c = bool(y >> 31), y == 0, total > MASK
                mathematical = signed(a) + signed(b) + carry_in
                self.v = not (-0x80000000 <= mathematical <= 0x7fffffff)
            return True
        op = w & 0x0e1000f0
        if op in (0x000000d0, 0x000000f0):
            rn = (w >> 16) & 15; rt = (w >> 12) & 15
            pre, wb = bool(w & (1 << 24)), bool(w & (1 << 21))
            if rt & 1 or rt > 12 or rn == 15:
                raise ValueError('Unsupported doubleword register form')
            if (wb or not pre) and rn in (rt, rt + 1):
                raise ValueError('Unsupported doubleword writeback alias')
            offset = (((w >> 4) & 0xf0) | (w & 15)) if w & (1 << 22) else self.get(w & 15, pc)
            base = self.get(rn, pc)
            end = (base + (offset if w & (1 << 23) else -offset)) & MASK
            address = end if pre else base
            if address & 3: raise ValueError('Unaligned doubleword unsupported')
            if op == 0x000000d0:
                x = self.read(address, 8)
                self.r[rt], self.r[rt + 1] = x & MASK, x >> 32
            else:
                self.write(address, self.get(rt, pc) | (self.get(rt + 1, pc) << 32), 8)
            if wb or not pre: self.r[rn] = end
            return True
        return super().extra_instruction(w, pc)
