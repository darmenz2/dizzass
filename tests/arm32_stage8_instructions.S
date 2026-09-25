.syntax unified
.arm
.text
.global stage8_blx_example
stage8_blx_example:
    push {r4,lr}
    blx r1
    pop {r4,pc}
.global stage8_blx_lr
stage8_blx_lr:
    blx lr
