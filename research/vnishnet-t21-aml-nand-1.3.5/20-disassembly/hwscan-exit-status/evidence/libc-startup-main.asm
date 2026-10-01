0045231c  73402de9    push       {r0, r1, r4, r5, r6, lr}
00452320  0250a0e1    mov        r5, r2
00452324  012081e2    add        r2, r1, #1
00452328  0140a0e1    mov        r4, r1
0045232c  022185e0    add        r2, r5, r2, lsl #2
00452330  0060a0e1    mov        r6, r0
00452334  04208de5    str        r2, [sp, #4]
00452338  e7ffffeb    bl         #0x4522dc
0045233c  04209de5    ldr        r2, [sp, #4]
00452340  0510a0e1    mov        r1, r5
00452344  0400a0e1    mov        r0, r4
00452348  36ff2fe1    blx        r6
0045234c  520defeb    bl         #0x1589c
00452350  70402de9    push       {r4, r5, r6, lr}
00452354  0060a0e1    mov        r6, r0
00452358  010081e2    add        r0, r1, #1
0045235c  0150a0e1    mov        r5, r1
00452360  000182e0    add        r0, r2, r0, lsl #2
00452364  0240a0e1    mov        r4, r2
00452368  001092e5    ldr        r1, [r2]
0045236c  59ffffeb    bl         #0x4520d8
00452370  14309fe5    ldr        r3, [pc, #0x14]
00452374  0420a0e1    mov        r2, r4
00452378  0510a0e1    mov        r1, r5
0045237c  0600a0e1    mov        r0, r6
00452380  03308fe0    add        r3, pc, r3
00452384  7040bde8    pop        {r4, r5, r6, lr}
00452388  13ff2fe1    bx         r3
