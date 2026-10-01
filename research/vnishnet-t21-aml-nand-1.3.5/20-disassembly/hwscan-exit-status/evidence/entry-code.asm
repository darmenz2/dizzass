000158b8  00b0a0e3    mov        fp, #0
000158bc  00e0a0e3    mov        lr, #0
000158c0  10109fe5    ldr        r1, [pc, #0x10]
000158c4  01108fe0    add        r1, pc, r1
000158c8  0d00a0e1    mov        r0, sp
000158cc  0fc0c0e3    bic        ip, r0, #0xf
000158d0  0cd0a0e1    mov        sp, ip
000158d4  000000eb    bl         #0x158dc
