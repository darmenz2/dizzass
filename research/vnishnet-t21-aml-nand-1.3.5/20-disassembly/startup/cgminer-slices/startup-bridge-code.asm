00010150  1f402de9    push       {r0, r1, r2, r3, r4, lr}
00010154  48309fe5    ldr        r3, [pc, #0x48]
00010158  48209fe5    ldr        r2, [pc, #0x48]
0001015c  03308fe0    add        r3, pc, r3
00010160  022093e7    ldr        r2, [r3, r2]
00010164  08208de5    str        r2, [sp, #8]
00010168  3c209fe5    ldr        r2, [pc, #0x3c]
0001016c  022093e7    ldr        r2, [r3, r2]
00010170  0c208de5    str        r2, [sp, #0xc]
00010174  0020a0e3    mov        r2, #0
00010178  04208de5    str        r2, [sp, #4]
0001017c  2c209fe5    ldr        r2, [pc, #0x2c]
00010180  023093e7    ldr        r3, [r3, r2]
00010184  042080e2    add        r2, r0, #4
00010188  00308de5    str        r3, [sp]
0001018c  08309de5    ldr        r3, [sp, #8]
00010190  001090e5    ldr        r1, [r0]
00010194  0c009de5    ldr        r0, [sp, #0xc]
00010198  c60b16eb    bl         #0x5930b8
0001019c  14d08de2    add        sp, sp, #0x14
000101a0  04f09de4    pop        {pc}
