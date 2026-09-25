.syntax unified
.arm
.fpu vfpv3-d16
.text
.global stage10_ops
stage10_ops:
    vmov d0, r0, r1
    vmov r2, r3, d8
    vcmp.f64 d8, #0
    vcvt.u32.f64 s14, d7
    vcvt.f64.u32 d4, s14
    vmla.f64 d8, d1, d0
    vmls.f64 d8, d1, d0
    vmlaeq.f64 d8, d1, d0
