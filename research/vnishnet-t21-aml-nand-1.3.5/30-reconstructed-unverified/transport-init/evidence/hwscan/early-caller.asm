000e7a9c  104c2de9    push       {r4, sl, fp, lr}
000e7aa0  08b08de2    add        fp, sp, #8
000e7aa4  08d04de2    sub        sp, sp, #8
000e7aa8  303080e2    add        r3, r0, #0x30
000e7aac  0100a0e1    mov        r0, r1
000e7ab0  0210a0e3    mov        r1, #2
000e7ab4  0120a0e3    mov        r2, #1
000e7ab8  0140a0e3    mov        r4, #1
000e7abc  f60a00eb    bl         #0xea69c
000e7ac0  000050e3    cmp        r0, #0
000e7ac4  0e00000a    beq        #0xe7b04
