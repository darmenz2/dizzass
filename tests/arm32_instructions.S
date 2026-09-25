.syntax unified
.arm
.text
.global arm_subset_selftest
arm_subset_selftest:
    mov r0, #0
    mov r2, #0
    subs r1, r2, #1
    orrcc r0, r0, #1
    mvn r2, #0
    adds r2, r2, #1
    orreq r0, r0, #2
    orrcs r0, r0, #4
    movw r2, #0xabcd
    movt r2, #0x1234
    uxtb r3, r2
    cmp r3, #0xcd
    orreq r0, r0, #8
    ubfx r3, r2, #8, #8
    cmp r3, #0xab
    orreq r0, r0, #16
    mov r3, #0
    mov r2, #3
    bfi r3, r2, #4, #2
    cmp r3, #0x30
    orreq r0, r0, #32
    push {r0, r1, lr}
    mov r0, #0
    pop {r0, r1, lr}
    bx lr
