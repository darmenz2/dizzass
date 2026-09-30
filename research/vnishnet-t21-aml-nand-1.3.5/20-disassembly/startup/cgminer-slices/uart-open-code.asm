0010e0c8  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
0010e0cc  1cb08de2    add        fp, sp, #0x1c
0010e0d0  04d04de2    sub        sp, sp, #4
0010e0d4  cc939fe5    ldr        sb, [pc, #0x3cc]
0010e0d8  0040a0e1    mov        r4, r0
0010e0dc  0150a0e1    mov        r5, r1
0010e0e0  09909fe7    ldr        sb, [pc, sb]
0010e0e4  000099e5    ldr        r0, [sb]
0010e0e8  bc839fe5    ldr        r8, [pc, #0x3bc]
0010e0ec  011040e2    sub        r1, r0, #1
0010e0f0  900100e0    mul        r0, r0, r1
0010e0f4  08809fe7    ldr        r8, [pc, r8]
0010e0f8  010010e3    tst        r0, #1
0010e0fc  0200000a    beq        #0x10e10c
0010e100  000098e5    ldr        r0, [r8]
0010e104  090050e3    cmp        r0, #9
0010e108  0d0000ca    bgt        #0x10e144
0010e10c  30604de2    sub        r6, sp, #0x30
0010e110  06d0a0e1    mov        sp, r6
0010e114  0500a0e1    mov        r0, r5
0010e118  021900e3    movw       r1, #0x902
0010e11c  6e1512eb    bl         #0x5936dc
0010e120  0070a0e1    mov        r7, r0
0010e124  000099e5    ldr        r0, [sb]
0010e128  011040e2    sub        r1, r0, #1
0010e12c  900100e0    mul        r0, r0, r1
0010e130  010010e3    tst        r0, #1
0010e134  0700000a    beq        #0x10e158
0010e138  000098e5    ldr        r0, [r8]
0010e13c  090050e3    cmp        r0, #9
0010e140  040000da    ble        #0x10e158
0010e144  30d04de2    sub        sp, sp, #0x30
0010e148  0500a0e1    mov        r0, r5
0010e14c  021900e3    movw       r1, #0x902
0010e150  611512eb    bl         #0x5936dc
0010e154  ecffffea    b          #0x10e10c
0010e158  010077e3    cmn        r7, #1
0010e15c  0c0000da    ble        #0x10e194
0010e160  000099e5    ldr        r0, [sb]
0010e164  2a8405e3    movw       r8, #0x542a
0010e168  2c8048e3    movt       r8, #0x802c
0010e16c  011040e2    sub        r1, r0, #1
0010e170  900100e0    mul        r0, r0, r1
0010e174  010010e3    tst        r0, #1
0010e178  1700000a    beq        #0x10e1dc
0010e17c  3c039fe5    ldr        r0, [pc, #0x33c]
0010e180  00009fe7    ldr        r0, [pc, r0]
0010e184  000090e5    ldr        r0, [r0]
0010e188  090050e3    cmp        r0, #9
0010e18c  280000ca    bgt        #0x10e234
0010e190  110000ea    b          #0x10e1dc
0010e194  14039fe5    ldr        r0, [pc, #0x314]
0010e198  14139fe5    ldr        r1, [pc, #0x314]
0010e19c  14239fe5    ldr        r2, [pc, #0x314]
0010e1a0  00008fe0    add        r0, pc, r0
0010e1a4  10339fe5    ldr        r3, [pc, #0x310]
0010e1a8  01108fe0    add        r1, pc, r1
0010e1ac  02208fe0    add        r2, pc, r2
0010e1b0  03308fe0    add        r3, pc, r3
0010e1b4  10d04de2    sub        sp, sp, #0x10
0010e1b8  0170a0e3    mov        r7, #1
0010e1bc  00708de5    str        r7, [sp]
0010e1c0  28008de9    stmib      sp, {r3, r5}
0010e1c4  2c30a0e3    mov        r3, #0x2c
0010e1c8  bdafffeb    bl         #0xfa0c4
0010e1cc  10d08de2    add        sp, sp, #0x10
0010e1d0  0000e0e3    mvn        r0, #0
0010e1d4  1cd04be2    sub        sp, fp, #0x1c
0010e1d8  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
0010e1dc  0400a0e1    mov        r0, r4
0010e1e0  0010a0e3    mov        r1, #0
0010e1e4  00a0a0e3    mov        sl, #0
0010e1e8  bb5f12eb    bl         #0x5a60dc
0010e1ec  0500a0e1    mov        r0, r5
0010e1f0  aa5512eb    bl         #0x5a38a0
0010e1f4  1c1084e2    add        r1, r4, #0x1c
0010e1f8  0620a0e1    mov        r2, r6
0010e1fc  810481e8    stm        r1, {r0, r7, sl}
0010e200  0700a0e1    mov        r0, r7
0010e204  0810a0e1    mov        r1, r8
0010e208  d02412eb    bl         #0x597550
0010e20c  001099e5    ldr        r1, [sb]
0010e210  012041e2    sub        r2, r1, #1
0010e214  910201e0    mul        r1, r1, r2
0010e218  010011e3    tst        r1, #1
0010e21c  1100000a    beq        #0x10e268
0010e220  9c129fe5    ldr        r1, [pc, #0x29c]
0010e224  01109fe7    ldr        r1, [pc, r1]
0010e228  001091e5    ldr        r1, [r1]
0010e22c  090051e3    cmp        r1, #9
0010e230  0c0000da    ble        #0x10e268
0010e234  0400a0e1    mov        r0, r4
0010e238  0010a0e3    mov        r1, #0
0010e23c  00a0a0e3    mov        sl, #0
0010e240  a55f12eb    bl         #0x5a60dc
0010e244  0500a0e1    mov        r0, r5
0010e248  945512eb    bl         #0x5a38a0
0010e24c  1c1084e2    add        r1, r4, #0x1c
0010e250  0620a0e1    mov        r2, r6
0010e254  810481e8    stm        r1, {r0, r7, sl}
0010e258  0700a0e1    mov        r0, r7
0010e25c  0810a0e1    mov        r1, r8
0010e260  ba2412eb    bl         #0x597550
0010e264  dcffffea    b          #0x10e1dc
0010e268  000050e3    cmp        r0, #0
0010e26c  0f00000a    beq        #0x10e2b0
0010e270  50029fe5    ldr        r0, [pc, #0x250]
0010e274  50129fe5    ldr        r1, [pc, #0x250]
0010e278  50229fe5    ldr        r2, [pc, #0x250]
0010e27c  00008fe0    add        r0, pc, r0
0010e280  4c329fe5    ldr        r3, [pc, #0x24c]
0010e284  01108fe0    add        r1, pc, r1
0010e288  02208fe0    add        r2, pc, r2
0010e28c  03308fe0    add        r3, pc, r3
0010e290  08d04de2    sub        sp, sp, #8
0010e294  0170a0e3    mov        r7, #1
0010e298  04308de5    str        r3, [sp, #4]
0010e29c  3630a0e3    mov        r3, #0x36
0010e2a0  00708de5    str        r7, [sp]
0010e2a4  86afffeb    bl         #0xfa0c4
0010e2a8  08d08de2    add        sp, sp, #8
0010e2ac  c7ffffea    b          #0x10e1d0
0010e2b0  070ca0e3    mov        r0, #0x700
0010e2b4  2e0096e8    ldm        r6, {r1, r2, r3, r5}
0010e2b8  9b3ec3e3    bic        r3, r3, #0x9b0
0010e2bc  b601c6e1    strh       r0, [r6, #0x16]
0010e2c0  140a0fe3    movw       r0, #0xfa14
0010e2c4  ff0f4fe3    movt       r0, #0xffff
0010e2c8  8b3e83e3    orr        r3, r3, #0x8b0
0010e2cc  000001e0    and        r0, r1, r0
0010e2d0  0110c2e3    bic        r1, r2, #1
0010e2d4  b42f07e3    movw       r2, #0x7fb4
0010e2d8  0b0086e8    stm        r6, {r0, r1, r3}
0010e2dc  ff2f4fe3    movt       r2, #0xffff
0010e2e0  2b1405e3    movw       r1, #0x542b
0010e2e4  022005e0    and        r2, r5, r2
0010e2e8  0c2086e5    str        r2, [r6, #0xc]
0010e2ec  2c1044e3    movt       r1, #0x402c
0010e2f0  0700a0e1    mov        r0, r7
0010e2f4  0620a0e1    mov        r2, r6
0010e2f8  942412eb    bl         #0x597550
0010e2fc  000050e3    cmp        r0, #0
0010e300  0c00000a    beq        #0x10e338
0010e304  000099e5    ldr        r0, [sb]
0010e308  c8419fe5    ldr        r4, [pc, #0x1c8]
0010e30c  011040e2    sub        r1, r0, #1
0010e310  c4519fe5    ldr        r5, [pc, #0x1c4]
0010e314  04408fe0    add        r4, pc, r4
0010e318  900100e0    mul        r0, r0, r1
0010e31c  05509fe7    ldr        r5, [pc, r5]
0010e320  010010e3    tst        r0, #1
0010e324  1900000a    beq        #0x10e390
0010e328  000095e5    ldr        r0, [r5]
0010e32c  090050e3    cmp        r0, #9
0010e330  2b0000ca    bgt        #0x10e3e4
0010e334  150000ea    b          #0x10e390
0010e338  00120ce3    movw       r1, #0xc200
0010e33c  0400a0e1    mov        r0, r4
0010e340  011040e3    movt       r1, #1
0010e344  730000eb    bl         #0x10e518
0010e348  000050e3    cmp        r0, #0
0010e34c  0c00000a    beq        #0x10e384
0010e350  000099e5    ldr        r0, [sb]
0010e354  9c419fe5    ldr        r4, [pc, #0x19c]
0010e358  011040e2    sub        r1, r0, #1
0010e35c  98519fe5    ldr        r5, [pc, #0x198]
0010e360  04408fe0    add        r4, pc, r4
0010e364  900100e0    mul        r0, r0, r1
0010e368  05509fe7    ldr        r5, [pc, r5]
0010e36c  010010e3    tst        r0, #1
0010e370  2800000a    beq        #0x10e418
0010e374  000095e5    ldr        r0, [r5]
0010e378  090050e3    cmp        r0, #9
0010e37c  3a0000ca    bgt        #0x10e46c
0010e380  240000ea    b          #0x10e418
0010e384  0000a0e3    mov        r0, #0
0010e388  1cd04be2    sub        sp, fp, #0x1c
0010e38c  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
0010e390  48019fe5    ldr        r0, [pc, #0x148]
0010e394  48119fe5    ldr        r1, [pc, #0x148]
0010e398  48219fe5    ldr        r2, [pc, #0x148]
0010e39c  00008fe0    add        r0, pc, r0
0010e3a0  01108fe0    add        r1, pc, r1
0010e3a4  02208fe0    add        r2, pc, r2
0010e3a8  08d04de2    sub        sp, sp, #8
0010e3ac  0130a0e3    mov        r3, #1
0010e3b0  18008de8    stm        sp, {r3, r4}
0010e3b4  4330a0e3    mov        r3, #0x43
0010e3b8  41afffeb    bl         #0xfa0c4
0010e3bc  08d08de2    add        sp, sp, #8
0010e3c0  000099e5    ldr        r0, [sb]
0010e3c4  011040e2    sub        r1, r0, #1
0010e3c8  900101e0    mul        r1, r0, r1
0010e3cc  0000e0e3    mvn        r0, #0
0010e3d0  010011e3    tst        r1, #1
0010e3d4  3100000a    beq        #0x10e4a0
0010e3d8  001095e5    ldr        r1, [r5]
0010e3dc  0a0051e3    cmp        r1, #0xa
0010e3e0  2e0000ba    blt        #0x10e4a0
0010e3e4  00019fe5    ldr        r0, [pc, #0x100]
0010e3e8  00119fe5    ldr        r1, [pc, #0x100]
0010e3ec  00219fe5    ldr        r2, [pc, #0x100]
0010e3f0  00008fe0    add        r0, pc, r0
0010e3f4  01108fe0    add        r1, pc, r1
0010e3f8  02208fe0    add        r2, pc, r2
0010e3fc  08d04de2    sub        sp, sp, #8
0010e400  0130a0e3    mov        r3, #1
0010e404  18008de8    stm        sp, {r3, r4}
0010e408  4330a0e3    mov        r3, #0x43
0010e40c  2cafffeb    bl         #0xfa0c4
0010e410  08d08de2    add        sp, sp, #8
0010e414  ddffffea    b          #0x10e390
0010e418  e0009fe5    ldr        r0, [pc, #0xe0]
0010e41c  e0109fe5    ldr        r1, [pc, #0xe0]
0010e420  e0209fe5    ldr        r2, [pc, #0xe0]
0010e424  00008fe0    add        r0, pc, r0
0010e428  01108fe0    add        r1, pc, r1
0010e42c  02208fe0    add        r2, pc, r2
0010e430  08d04de2    sub        sp, sp, #8
0010e434  0130a0e3    mov        r3, #1
0010e438  18008de8    stm        sp, {r3, r4}
0010e43c  4830a0e3    mov        r3, #0x48
0010e440  1fafffeb    bl         #0xfa0c4
0010e444  08d08de2    add        sp, sp, #8
0010e448  000099e5    ldr        r0, [sb]
0010e44c  011040e2    sub        r1, r0, #1
0010e450  900101e0    mul        r1, r0, r1
0010e454  0000e0e3    mvn        r0, #0
0010e458  010011e3    tst        r1, #1
0010e45c  0f00000a    beq        #0x10e4a0
0010e460  001095e5    ldr        r1, [r5]
0010e464  090051e3    cmp        r1, #9
0010e468  0c0000da    ble        #0x10e4a0
0010e46c  98009fe5    ldr        r0, [pc, #0x98]
0010e470  98109fe5    ldr        r1, [pc, #0x98]
0010e474  98209fe5    ldr        r2, [pc, #0x98]
0010e478  00008fe0    add        r0, pc, r0
0010e47c  01108fe0    add        r1, pc, r1
0010e480  02208fe0    add        r2, pc, r2
0010e484  08d04de2    sub        sp, sp, #8
0010e488  0130a0e3    mov        r3, #1
0010e48c  18008de8    stm        sp, {r3, r4}
0010e490  4830a0e3    mov        r3, #0x48
0010e494  0aafffeb    bl         #0xfa0c4
0010e498  08d08de2    add        sp, sp, #8
0010e49c  ddffffea    b          #0x10e418
0010e4a0  1cd04be2    sub        sp, fp, #0x1c
0010e4a4  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
