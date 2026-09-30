0011ca74  f0482de9    push       {r4, r5, r6, r7, fp, lr}
0011ca78  10b08de2    add        fp, sp, #0x10
0011ca7c  08d04de2    sub        sp, sp, #8
0011ca80  30019fe5    ldr        r0, [pc, #0x130]
0011ca84  0040a0e3    mov        r4, #0
0011ca88  00008fe0    add        r0, pc, r0
0011ca8c  0000d0e5    ldrb       r0, [r0]
0011ca90  010050e3    cmp        r0, #1
0011ca94  4400001a    bne        #0x11cbac
0011ca98  1c519fe5    ldr        r5, [pc, #0x11c]
0011ca9c  05509fe7    ldr        r5, [pc, r5]
0011caa0  000095e5    ldr        r0, [r5]
0011caa4  14619fe5    ldr        r6, [pc, #0x114]
0011caa8  011040e2    sub        r1, r0, #1
0011caac  900100e0    mul        r0, r0, r1
0011cab0  06609fe7    ldr        r6, [pc, r6]
0011cab4  010010e3    tst        r0, #1
0011cab8  0200000a    beq        #0x11cac8
0011cabc  000096e5    ldr        r0, [r6]
0011cac0  090050e3    cmp        r0, #9
0011cac4  0a0000ca    bgt        #0x11caf4
0011cac8  b50100e3    movw       r0, #0x1b5
0011cacc  0110a0e3    mov        r1, #1
0011cad0  332000eb    bl         #0x124ba4
0011cad4  001095e5    ldr        r1, [r5]
0011cad8  012041e2    sub        r2, r1, #1
0011cadc  910201e0    mul        r1, r1, r2
0011cae0  010011e3    tst        r1, #1
0011cae4  0600000a    beq        #0x11cb04
0011cae8  001096e5    ldr        r1, [r6]
0011caec  090051e3    cmp        r1, #9
0011caf0  030000da    ble        #0x11cb04
0011caf4  b50100e3    movw       r0, #0x1b5
0011caf8  0110a0e3    mov        r1, #1
0011cafc  282000eb    bl         #0x124ba4
0011cb00  f0ffffea    b          #0x11cac8
0011cb04  000050e3    cmp        r0, #0
0011cb08  2700000a    beq        #0x11cbac
0011cb0c  000095e5    ldr        r0, [r5]
0011cb10  ac709fe5    ldr        r7, [pc, #0xac]
0011cb14  011040e2    sub        r1, r0, #1
0011cb18  07708fe0    add        r7, pc, r7
0011cb1c  900100e0    mul        r0, r0, r1
0011cb20  010010e3    tst        r0, #1
0011cb24  0200000a    beq        #0x11cb34
0011cb28  000096e5    ldr        r0, [r6]
0011cb2c  090050e3    cmp        r0, #9
0011cb30  120000ca    bgt        #0x11cb80
0011cb34  8c009fe5    ldr        r0, [pc, #0x8c]
0011cb38  0130a0e3    mov        r3, #1
0011cb3c  88109fe5    ldr        r1, [pc, #0x88]
0011cb40  88209fe5    ldr        r2, [pc, #0x88]
0011cb44  00008fe0    add        r0, pc, r0
0011cb48  01108fe0    add        r1, pc, r1
0011cb4c  88008de8    stm        sp, {r3, r7}
0011cb50  02208fe0    add        r2, pc, r2
0011cb54  5130a0e3    mov        r3, #0x51
0011cb58  5975ffeb    bl         #0xfa0c4
0011cb5c  000095e5    ldr        r0, [r5]
0011cb60  0040e0e3    mvn        r4, #0
0011cb64  011040e2    sub        r1, r0, #1
0011cb68  900100e0    mul        r0, r0, r1
0011cb6c  010010e3    tst        r0, #1
0011cb70  0d00000a    beq        #0x11cbac
0011cb74  000096e5    ldr        r0, [r6]
0011cb78  090050e3    cmp        r0, #9
0011cb7c  0a0000da    ble        #0x11cbac
0011cb80  4c009fe5    ldr        r0, [pc, #0x4c]
0011cb84  0130a0e3    mov        r3, #1
0011cb88  48109fe5    ldr        r1, [pc, #0x48]
0011cb8c  48209fe5    ldr        r2, [pc, #0x48]
0011cb90  00008fe0    add        r0, pc, r0
0011cb94  01108fe0    add        r1, pc, r1
0011cb98  88008de8    stm        sp, {r3, r7}
0011cb9c  02208fe0    add        r2, pc, r2
0011cba0  5130a0e3    mov        r3, #0x51
0011cba4  4675ffeb    bl         #0xfa0c4
0011cba8  e1ffffea    b          #0x11cb34
0011cbac  0400a0e1    mov        r0, r4
0011cbb0  10d04be2    sub        sp, fp, #0x10
0011cbb4  f088bde8    pop        {r4, r5, r6, r7, fp, pc}
0011cbb8  68995300    subseq     sb, r3, r8, ror #18
0011cbbc  20354c00    subeq      r3, ip, r0, lsr #10
0011cbc0  a02b4c00    subeq      r2, ip, r0, lsr #23
0011cbc4  d41d4d00    ldrdeq     r1, r2, [sp], #-0xd4
0011cbc8  e51c4d00    subeq      r1, sp, r5, ror #25
0011cbcc  e81c4d00    subeq      r1, sp, r8, ror #25
0011cbd0  041d4d00    subeq      r1, sp, r4, lsl #26
0011cbd4  991c4d00    umaaleq    r1, sp, sb, ip
0011cbd8  9c1c4d00    umaaleq    r1, sp, ip, ip
0011cbdc  b81c4d00    strheq     r1, [sp], #-0xc8
