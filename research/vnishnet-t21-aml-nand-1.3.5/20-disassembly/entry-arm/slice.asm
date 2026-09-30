0001012c  00b0a0e3    mov        fp, #0
00010130  00e0a0e3    mov        lr, #0
00010134  10109fe5    ldr        r1, [pc, #0x10]
00010138  01108fe0    add        r1, pc, r1
0001013c  0d00a0e1    mov        r0, sp
00010140  0fc0c0e3    bic        ip, r0, #0xf
00010144  0cd0a0e1    mov        sp, ip
00010148  000000eb    bl         #0x10150
0001014c  c0fefeff    .byte      0xc0, 0xfe, 0xfe, 0xff
00010150  1f402de9    push       {r0, r1, r2, r3, r4, lr}
00010154  48309fe5    ldr        r3, [pc, #0x48]
00010158  48209fe5    ldr        r2, [pc, #0x48]
0001015c  03308fe0    add        r3, pc, r3
00010160  022093e7    ldr        r2, [r3, r2]
00010164  08208de5    str        r2, [sp, #8]
00010168  3c209fe5    ldr        r2, [pc, #0x3c]
