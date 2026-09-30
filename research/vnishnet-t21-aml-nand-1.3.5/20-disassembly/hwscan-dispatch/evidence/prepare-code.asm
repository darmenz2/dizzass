000e6160  30482de9    push       {r4, r5, fp, lr}
000e6164  08b08de2    add        fp, sp, #8
000e6168  08d04de2    sub        sp, sp, #8
000e616c  80519fe5    ldr        r5, [pc, #0x180]
000e6170  0040a0e1    mov        r4, r0
000e6174  05509fe7    ldr        r5, [pc, r5]
000e6178  001095e5    ldr        r1, [r5]
000e617c  460600eb    bl         #0xe7a9c
000e6180  000050e3    cmp        r0, #0
000e6184  0c00000a    beq        #0xe61bc
000e6188  68019fe5    ldr        r0, [pc, #0x168]
000e618c  0150a0e3    mov        r5, #1
000e6190  64119fe5    ldr        r1, [pc, #0x164]
000e6194  64219fe5    ldr        r2, [pc, #0x164]
000e6198  00008fe0    add        r0, pc, r0
000e619c  60319fe5    ldr        r3, [pc, #0x160]
000e61a0  01108fe0    add        r1, pc, r1
000e61a4  02208fe0    add        r2, pc, r2
000e61a8  00508de5    str        r5, [sp]
000e61ac  03308fe0    add        r3, pc, r3
000e61b0  04308de5    str        r3, [sp, #4]
000e61b4  b830a0e3    mov        r3, #0xb8
000e61b8  440000ea    b          #0xe62d0
000e61bc  100084e2    add        r0, r4, #0x10
000e61c0  0010a0e3    mov        r1, #0
000e61c4  0020a0e3    mov        r2, #0
000e61c8  0030a0e3    mov        r3, #0
000e61cc  226f00eb    bl         #0x101e5c
000e61d0  000050e3    cmp        r0, #0
000e61d4  0c00000a    beq        #0xe620c
000e61d8  28019fe5    ldr        r0, [pc, #0x128]
000e61dc  0150a0e3    mov        r5, #1
000e61e0  24119fe5    ldr        r1, [pc, #0x124]
000e61e4  24219fe5    ldr        r2, [pc, #0x124]
000e61e8  00008fe0    add        r0, pc, r0
000e61ec  20319fe5    ldr        r3, [pc, #0x120]
000e61f0  01108fe0    add        r1, pc, r1
000e61f4  02208fe0    add        r2, pc, r2
000e61f8  00508de5    str        r5, [sp]
000e61fc  03308fe0    add        r3, pc, r3
000e6200  04308de5    str        r3, [sp, #4]
000e6204  bd30a0e3    mov        r3, #0xbd
000e6208  300000ea    b          #0xe62d0
000e620c  210600eb    bl         #0xe7a98
000e6210  000050e3    cmp        r0, #0
000e6214  0c00000a    beq        #0xe624c
000e6218  f8009fe5    ldr        r0, [pc, #0xf8]
000e621c  0150a0e3    mov        r5, #1
000e6220  f4109fe5    ldr        r1, [pc, #0xf4]
000e6224  f4209fe5    ldr        r2, [pc, #0xf4]
000e6228  00008fe0    add        r0, pc, r0
000e622c  f0309fe5    ldr        r3, [pc, #0xf0]
000e6230  01108fe0    add        r1, pc, r1
000e6234  02208fe0    add        r2, pc, r2
000e6238  00508de5    str        r5, [sp]
000e623c  03308fe0    add        r3, pc, r3
000e6240  04308de5    str        r3, [sp, #4]
000e6244  c230a0e3    mov        r3, #0xc2
000e6248  200000ea    b          #0xe62d0
000e624c  456a00eb    bl         #0x100b68
000e6250  0f0600eb    bl         #0xe7a94
000e6254  000050e3    cmp        r0, #0
000e6258  0c00000a    beq        #0xe6290
000e625c  c4009fe5    ldr        r0, [pc, #0xc4]
000e6260  0150a0e3    mov        r5, #1
000e6264  c0109fe5    ldr        r1, [pc, #0xc0]
000e6268  c0209fe5    ldr        r2, [pc, #0xc0]
000e626c  00008fe0    add        r0, pc, r0
000e6270  bc309fe5    ldr        r3, [pc, #0xbc]
000e6274  01108fe0    add        r1, pc, r1
000e6278  02208fe0    add        r2, pc, r2
000e627c  00508de5    str        r5, [sp]
000e6280  03308fe0    add        r3, pc, r3
000e6284  04308de5    str        r3, [sp, #4]
000e6288  c930a0e3    mov        r3, #0xc9
000e628c  0f0000ea    b          #0xe62d0
000e6290  0400a0e1    mov        r0, r4
000e6294  fb0200eb    bl         #0xe6e88
000e6298  000050e3    cmp        r0, #0
000e629c  0f00000a    beq        #0xe62e0
000e62a0  90009fe5    ldr        r0, [pc, #0x90]
000e62a4  0150a0e3    mov        r5, #1
000e62a8  8c109fe5    ldr        r1, [pc, #0x8c]
000e62ac  8c209fe5    ldr        r2, [pc, #0x8c]
000e62b0  00008fe0    add        r0, pc, r0
000e62b4  88309fe5    ldr        r3, [pc, #0x88]
000e62b8  01108fe0    add        r1, pc, r1
000e62bc  02208fe0    add        r2, pc, r2
000e62c0  00508de5    str        r5, [sp]
000e62c4  03308fe0    add        r3, pc, r3
000e62c8  04308de5    str        r3, [sp, #4]
000e62cc  ce30a0e3    mov        r3, #0xce
000e62d0  f66200eb    bl         #0xfeeb0
000e62d4  0000e0e3    mvn        r0, #0
000e62d8  08d04be2    sub        sp, fp, #8
000e62dc  3088bde8    pop        {r4, r5, fp, pc}
000e62e0  000095e5    ldr        r0, [r5]
000e62e4  000084e5    str        r0, [r4]
000e62e8  0000a0e3    mov        r0, #0
000e62ec  08d04be2    sub        sp, fp, #8
000e62f0  3088bde8    pop        {r4, r5, fp, pc}
