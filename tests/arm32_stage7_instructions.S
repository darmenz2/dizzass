.syntax unified
.arm
.text
.global stage7_uxth0
stage7_uxth0:
    uxth r0,r0
    bx lr
.global stage7_uxth8
stage7_uxth8:
    uxth r0,r0,ror #8
    bx lr
.global stage7_uxth16
stage7_uxth16:
    uxth r0,r0,ror #16
    bx lr
.global stage7_uxth24
stage7_uxth24:
    uxth r0,r0,ror #24
    bx lr
.global stage7_smlabb
stage7_smlabb:
    smlabb r0,r0,r1,r2
    bx lr
.global stage7_conditional
stage7_conditional:
    cmp r3,#0
    smlabbeq r0,r0,r1,r2
    bx lr
