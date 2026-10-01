000e949c  000094e5    ldr        r0, [r4]
000e94a0  3d5e00eb    bl         #0x100d9c
000e94a4  0060a0e1    mov        r6, r0
000e94a8  000094e5    ldr        r0, [r4]
000e94ac  0650c4e5    strb       r5, [r4, #6]
000e94b0  0610a0e1    mov        r1, r6
000e94b4  000184e5    str        r0, [r4, #0x100]
000e94b8  e80084e2    add        r0, r4, #0xe8
000e94bc  1e5e00eb    bl         #0x100d3c
000e94c0  000050e3    cmp        r0, #0
000e94c4  1d00000a    beq        #0xe9540
