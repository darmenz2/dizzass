000e907c  54501be5    ldr        r5, [fp, #-0x54]
000e9080  000055e3    cmp        r5, #0
000e9084  3e00000a    beq        #0xe9184
000e9088  1c439fe5    ldr        r4, [pc, #0x31c]
000e908c  0500a0e1    mov        r0, r5
000e9090  04408fe0    add        r4, pc, r4
000e9094  0410a0e1    mov        r1, r4
000e9098  cfd90deb    bl         #0x45f7dc
000e909c  000050e3    cmp        r0, #0
000e90a0  1f00000a    beq        #0xe9124
000e90a4  04439fe5    ldr        r4, [pc, #0x304]
000e90a8  0500a0e1    mov        r0, r5
000e90ac  04408fe0    add        r4, pc, r4
000e90b0  0410a0e1    mov        r1, r4
000e90b4  c8d90deb    bl         #0x45f7dc
000e90b8  000050e3    cmp        r0, #0
000e90bc  1a00000a    beq        #0xe912c
000e90c0  ec429fe5    ldr        r4, [pc, #0x2ec]
000e90c4  0500a0e1    mov        r0, r5
000e90c8  04408fe0    add        r4, pc, r4
000e90cc  0410a0e1    mov        r1, r4
000e90d0  c1d90deb    bl         #0x45f7dc
000e90d4  000050e3    cmp        r0, #0
000e90d8  1500000a    beq        #0xe9134
000e90dc  d4429fe5    ldr        r4, [pc, #0x2d4]
000e90e0  0500a0e1    mov        r0, r5
000e90e4  04408fe0    add        r4, pc, r4
000e90e8  0410a0e1    mov        r1, r4
000e90ec  bad90deb    bl         #0x45f7dc
000e90f0  000050e3    cmp        r0, #0
000e90f4  1000000a    beq        #0xe913c
000e90f8  bc629fe5    ldr        r6, [pc, #0x2bc]
000e90fc  0500a0e1    mov        r0, r5
000e9100  06608fe0    add        r6, pc, r6
000e9104  0610a0e1    mov        r1, r6
000e9108  b3d90deb    bl         #0x45f7dc
000e910c  ac429fe5    ldr        r4, [pc, #0x2ac]
000e9110  000050e3    cmp        r0, #0
000e9114  05000013    movwne     r0, #5
000e9118  04408fe0    add        r4, pc, r4
000e911c  0640a001    moveq      r4, r6
000e9120  060000ea    b          #0xe9140
000e9124  0200a0e3    mov        r0, #2
000e9128  040000ea    b          #0xe9140
000e912c  0100a0e3    mov        r0, #1
000e9130  020000ea    b          #0xe9140
000e9134  0300a0e3    mov        r0, #3
000e9138  000000ea    b          #0xe9140
000e913c  0400a0e3    mov        r0, #4
