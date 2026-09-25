.syntax unified
.arm
.text
.global stage6_rev
stage6_rev:
    rev r0, r0
    bx lr
.global stage6_ldrsb_zero
stage6_ldrsb_zero:
    ldrsb r0, [r1]
    bx lr
.global stage6_ldrsb_pre
stage6_ldrsb_pre:
    ldrsb r0, [r1, #3]!
    bx lr
.global stage6_ldrsb_post
stage6_ldrsb_post:
    ldrsb r0, [r1], #-3
    bx lr
.global stage6_ldrsb_reg
stage6_ldrsb_reg:
    ldrsb r0, [r1, -r2]!
    bx lr
.global stage6_conditional
stage6_conditional:
    cmp r2, #0
    ldrsbeq r0, [r1]
    bx lr
