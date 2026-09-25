.syntax unified
.arm
.fpu vfpv3
.text
.global stage9_probe
stage9_probe:
    adcs r2, r0, r1
    adc r2, r0, #0
    adcs r2, r0, r1, lsl #3
    ldrd r0, r1, [r2, #8]
    ldrd r0, r1, [r2, #-8]!
    ldrd r0, r1, [r2], #8
    ldrd r0, r1, [r2, r3]
    strd r0, r1, [r2, #8]
    strd r0, r1, [r2, #-8]!
    strd r0, r1, [r2], #8
    strd r0, r1, [r2, r3]
    bx lr
