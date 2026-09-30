0001012c  00b0a0e3    mov        fp, #0
00010130  00e0a0e3    mov        lr, #0
00010134  10109fe5    ldr        r1, [pc, #0x10]
00010138  01108fe0    add        r1, pc, r1
0001013c  0d00a0e1    mov        r0, sp
00010140  0fc0c0e3    bic        ip, r0, #0xf
00010144  0cd0a0e1    mov        sp, ip
00010148  000000eb    bl         #0x10150
