001114c0  104c2de9    push       {r4, sl, fp, lr}
001114c4  08b08de2    add        fp, sp, #8
001114c8  01dc4de2    sub        sp, sp, #0x100
001114cc  30209fe5    ldr        r2, [pc, #0x30]
001114d0  0d40a0e1    mov        r4, sp
001114d4  0030a0e1    mov        r3, r0
001114d8  0400a0e1    mov        r0, r4
001114dc  02208fe0    add        r2, pc, r2
001114e0  011ca0e3    mov        r1, #0x100
001114e4  88280deb    bl         #0x45b70c
001114e8  0400a0e1    mov        r0, r4
001114ec  0010a0e3    mov        r1, #0
001114f0  82480deb    bl         #0x463700
001114f4  100f6fe1    clz        r0, r0
001114f8  a002a0e1    lsr        r0, r0, #5
001114fc  08d04be2    sub        sp, fp, #8
00111500  108cbde8    pop        {r4, sl, fp, pc}
