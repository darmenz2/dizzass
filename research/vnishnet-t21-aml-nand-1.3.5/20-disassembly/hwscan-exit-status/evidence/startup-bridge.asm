000158dc  1f402de9    push       {r0, r1, r2, r3, r4, lr}
000158e0  48309fe5    ldr        r3, [pc, #0x48]
000158e4  48209fe5    ldr        r2, [pc, #0x48]
000158e8  03308fe0    add        r3, pc, r3
000158ec  022093e7    ldr        r2, [r3, r2]
000158f0  08208de5    str        r2, [sp, #8]
000158f4  3c209fe5    ldr        r2, [pc, #0x3c]
000158f8  022093e7    ldr        r2, [r3, r2]
000158fc  0c208de5    str        r2, [sp, #0xc]
00015900  0020a0e3    mov        r2, #0
00015904  04208de5    str        r2, [sp, #4]
00015908  2c209fe5    ldr        r2, [pc, #0x2c]
0001590c  023093e7    ldr        r3, [r3, r2]
00015910  042080e2    add        r2, r0, #4
00015914  00308de5    str        r3, [sp]
00015918  08309de5    ldr        r3, [sp, #8]
0001591c  001090e5    ldr        r1, [r0]
00015920  0c009de5    ldr        r0, [sp, #0xc]
00015924  89f210eb    bl         #0x452350
00015928  14d08de2    add        sp, sp, #0x14
0001592c  04f09de4    pop        {pc}
