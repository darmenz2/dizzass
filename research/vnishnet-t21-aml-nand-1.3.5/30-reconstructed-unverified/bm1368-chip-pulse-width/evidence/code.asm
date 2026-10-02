000e33e0  f04d2de9    push       {r4, r5, r6, r7, r8, sl, fp, lr}
000e33e4  18b08de2    add        fp, sp, #0x18
000e33e8  10d04de2    sub        sp, sp, #0x10
000e33ec  0060a0e1    mov        r6, r0
000e33f0  3800a0e3    mov        r0, #0x38
000e33f4  830100e0    and        r0, r0, r3, lsl #3
000e33f8  0140a0e1    mov        r4, r1
000e33fc  0010a0e3    mov        r1, #0
000e3400  3c30a0e3    mov        r3, #0x3c
000e3404  1203c7e7    bfi        r0, r2, #6, #2
000e3408  0420a0e1    mov        r2, r4
000e340c  020980e3    orr        r0, r0, #0x8000
000e3410  0050a0e3    mov        r5, #0
000e3414  020180e3    orr        r0, r0, #0x80000000
000e3418  00008de5    str        r0, [sp]
000e341c  0600a0e1    mov        r0, r6
000e3420  930500eb    bl         #0xe4a74
000e3424  000050e3    cmp        r0, #0
000e3428  1f00000a    beq        #0xe34ac
000e342c  84809fe5    ldr        r8, [pc, #0x84]
000e3430  0140a0e3    mov        r4, #1
000e3434  80509fe5    ldr        r5, [pc, #0x80]
000e3438  833100e3    movw       r3, #0x183
000e343c  7c709fe5    ldr        r7, [pc, #0x7c]
000e3440  08808fe0    add        r8, pc, r8
000e3444  180096e5    ldr        r0, [r6, #0x18]
000e3448  05508fe0    add        r5, pc, r5
000e344c  70109fe5    ldr        r1, [pc, #0x70]
000e3450  07708fe0    add        r7, pc, r7
000e3454  010080e2    add        r0, r0, #1
000e3458  08008de5    str        r0, [sp, #8]
000e345c  01108fe0    add        r1, pc, r1
000e3460  04108de5    str        r1, [sp, #4]
000e3464  0800a0e1    mov        r0, r8
000e3468  0510a0e1    mov        r1, r5
000e346c  0720a0e1    mov        r2, r7
000e3470  00408de5    str        r4, [sp]
000e3474  125b00eb    bl         #0xfa0c4
000e3478  180096e5    ldr        r0, [r6, #0x18]
000e347c  0720a0e1    mov        r2, r7
000e3480  40109fe5    ldr        r1, [pc, #0x40]
000e3484  1a3200e3    movw       r3, #0x21a
000e3488  010080e2    add        r0, r0, #1
000e348c  08008de5    str        r0, [sp, #8]
000e3490  01108fe0    add        r1, pc, r1
000e3494  04108de5    str        r1, [sp, #4]
000e3498  0800a0e1    mov        r0, r8
000e349c  0510a0e1    mov        r1, r5
000e34a0  00408de5    str        r4, [sp]
000e34a4  065b00eb    bl         #0xfa0c4
000e34a8  0050e0e3    mvn        r5, #0
000e34ac  0500a0e1    mov        r0, r5
000e34b0  18d04be2    sub        sp, fp, #0x18
000e34b4  f08dbde8    pop        {r4, r5, r6, r7, r8, sl, fp, pc}
