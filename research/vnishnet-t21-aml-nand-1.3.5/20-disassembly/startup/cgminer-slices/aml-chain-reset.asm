0011bc14  f0482de9    push       {r4, r5, r6, r7, fp, lr}
0011bc18  10b08de2    add        fp, sp, #0x10
0011bc1c  10d04de2    sub        sp, sp, #0x10
0011bc20  14519fe5    ldr        r5, [pc, #0x114]
0011bc24  0040a0e1    mov        r4, r0
0011bc28  05509fe7    ldr        r5, [pc, r5]
0011bc2c  000095e5    ldr        r0, [r5]
0011bc30  012040e2    sub        r2, r0, #1
0011bc34  900200e0    mul        r0, r0, r2
0011bc38  010010e3    tst        r0, #1
0011bc3c  000095e5    ldr        r0, [r5]
0011bc40  f8609fe5    ldr        r6, [pc, #0xf8]
0011bc44  012040e2    sub        r2, r0, #1
0011bc48  900200e0    mul        r0, r0, r2
0011bc4c  06609fe7    ldr        r6, [pc, r6]
0011bc50  010010e3    tst        r0, #1
0011bc54  0200000a    beq        #0x11bc64
0011bc58  000096e5    ldr        r0, [r6]
0011bc5c  090050e3    cmp        r0, #9
0011bc60  f5ffffca    bgt        #0x11bc3c
0011bc64  030054e3    cmp        r4, #3
0011bc68  0a00003a    blo        #0x11bc98
0011bc6c  000095e5    ldr        r0, [r5]
0011bc70  cc709fe5    ldr        r7, [pc, #0xcc]
0011bc74  011040e2    sub        r1, r0, #1
0011bc78  07708fe0    add        r7, pc, r7
0011bc7c  900100e0    mul        r0, r0, r1
0011bc80  010010e3    tst        r0, #1
0011bc84  0a00000a    beq        #0x11bcb4
0011bc88  000096e5    ldr        r0, [r6]
0011bc8c  090050e3    cmp        r0, #9
0011bc90  1a0000ca    bgt        #0x11bd00
0011bc94  060000ea    b          #0x11bcb4
0011bc98  c0009fe5    ldr        r0, [pc, #0xc0]
0011bc9c  011021e2    eor        r1, r1, #1
0011bca0  00008fe0    add        r0, pc, r0
0011bca4  040190e7    ldr        r0, [r0, r4, lsl #2]
0011bca8  10d04be2    sub        sp, fp, #0x10
0011bcac  f048bde8    pop        {r4, r5, r6, r7, fp, lr}
0011bcb0  bb2300ea    b          #0x124ba4
0011bcb4  8c009fe5    ldr        r0, [pc, #0x8c]
0011bcb8  0130a0e3    mov        r3, #1
0011bcbc  88109fe5    ldr        r1, [pc, #0x88]
0011bcc0  88209fe5    ldr        r2, [pc, #0x88]
0011bcc4  00008fe0    add        r0, pc, r0
0011bcc8  01108fe0    add        r1, pc, r1
0011bccc  88008de8    stm        sp, {r3, r7}
0011bcd0  02208fe0    add        r2, pc, r2
0011bcd4  8230a0e3    mov        r3, #0x82
0011bcd8  08408de5    str        r4, [sp, #8]
0011bcdc  f878ffeb    bl         #0xfa0c4
0011bce0  000095e5    ldr        r0, [r5]
0011bce4  011040e2    sub        r1, r0, #1
0011bce8  900100e0    mul        r0, r0, r1
0011bcec  010010e3    tst        r0, #1
0011bcf0  0e00000a    beq        #0x11bd30
0011bcf4  000096e5    ldr        r0, [r6]
0011bcf8  0a0050e3    cmp        r0, #0xa
0011bcfc  0b0000ba    blt        #0x11bd30
0011bd00  4c009fe5    ldr        r0, [pc, #0x4c]
0011bd04  0130a0e3    mov        r3, #1
0011bd08  48109fe5    ldr        r1, [pc, #0x48]
0011bd0c  48209fe5    ldr        r2, [pc, #0x48]
0011bd10  00008fe0    add        r0, pc, r0
0011bd14  01108fe0    add        r1, pc, r1
0011bd18  88008de8    stm        sp, {r3, r7}
0011bd1c  02208fe0    add        r2, pc, r2
0011bd20  8230a0e3    mov        r3, #0x82
0011bd24  08408de5    str        r4, [sp, #8]
0011bd28  e578ffeb    bl         #0xfa0c4
0011bd2c  e0ffffea    b          #0x11bcb4
0011bd30  0000e0e3    mvn        r0, #0
0011bd34  10d04be2    sub        sp, fp, #0x10
0011bd38  f088bde8    pop        {r4, r5, r6, r7, fp, pc}
0011bd3c  7c394c00    subeq      r3, ip, ip, ror sb
0011bd40  b4334c00    strheq     r3, [ip], #-0x34
0011bd44  742b4d00    subeq      r2, sp, r4, ror fp
0011bd48  642a4d00    subeq      r2, sp, r4, ror #20
0011bd4c  672a4d00    subeq      r2, sp, r7, ror #20
0011bd50  882a4d00    subeq      r2, sp, r8, lsl #21
0011bd54  182a4d00    subeq      r2, sp, r8, lsl sl
0011bd58  1b2a4d00    subeq      r2, sp, fp, lsl sl
0011bd5c  3c2a4d00    subeq      r2, sp, ip, lsr sl
0011bd60  306d4900    subeq      r6, sb, r0, lsr sp
