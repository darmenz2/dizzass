0011c978  704c2de9    push       {r4, r5, r6, sl, fp, lr}
0011c97c  10b08de2    add        fp, sp, #0x10
0011c980  08d04de2    sub        sp, sp, #8
0011c984  cc009fe5    ldr        r0, [pc, #0xcc]
0011c988  0040e0e3    mvn        r4, #0
0011c98c  00008fe0    add        r0, pc, r0
0011c990  0000d0e5    ldrb       r0, [r0]
0011c994  010050e3    cmp        r0, #1
0011c998  2b00001a    bne        #0x11ca4c
0011c99c  b8509fe5    ldr        r5, [pc, #0xb8]
0011c9a0  05509fe7    ldr        r5, [pc, r5]
0011c9a4  000095e5    ldr        r0, [r5]
0011c9a8  b0609fe5    ldr        r6, [pc, #0xb0]
0011c9ac  011040e2    sub        r1, r0, #1
0011c9b0  900100e0    mul        r0, r0, r1
0011c9b4  06609fe7    ldr        r6, [pc, r6]
0011c9b8  010010e3    tst        r0, #1
0011c9bc  0200000a    beq        #0x11c9cc
0011c9c0  000096e5    ldr        r0, [r6]
0011c9c4  090050e3    cmp        r0, #9
0011c9c8  0b0000ca    bgt        #0x11c9fc
0011c9cc  b50100e3    movw       r0, #0x1b5
0011c9d0  0010a0e3    mov        r1, #0
0011c9d4  0040a0e3    mov        r4, #0
0011c9d8  712000eb    bl         #0x124ba4
0011c9dc  001095e5    ldr        r1, [r5]
0011c9e0  012041e2    sub        r2, r1, #1
0011c9e4  910201e0    mul        r1, r1, r2
0011c9e8  010011e3    tst        r1, #1
0011c9ec  0600000a    beq        #0x11ca0c
0011c9f0  001096e5    ldr        r1, [r6]
0011c9f4  090051e3    cmp        r1, #9
0011c9f8  030000da    ble        #0x11ca0c
0011c9fc  b50100e3    movw       r0, #0x1b5
0011ca00  0010a0e3    mov        r1, #0
0011ca04  662000eb    bl         #0x124ba4
0011ca08  efffffea    b          #0x11c9cc
0011ca0c  000050e3    cmp        r0, #0
0011ca10  0d00000a    beq        #0x11ca4c
0011ca14  48009fe5    ldr        r0, [pc, #0x48]
0011ca18  0160a0e3    mov        r6, #1
0011ca1c  44109fe5    ldr        r1, [pc, #0x44]
0011ca20  44209fe5    ldr        r2, [pc, #0x44]
0011ca24  00008fe0    add        r0, pc, r0
0011ca28  40309fe5    ldr        r3, [pc, #0x40]
0011ca2c  01108fe0    add        r1, pc, r1
0011ca30  02208fe0    add        r2, pc, r2
0011ca34  00608de5    str        r6, [sp]
0011ca38  03308fe0    add        r3, pc, r3
0011ca3c  04308de5    str        r3, [sp, #4]
0011ca40  4430a0e3    mov        r3, #0x44
0011ca44  9e75ffeb    bl         #0xfa0c4
0011ca48  0040e0e3    mvn        r4, #0
0011ca4c  0400a0e1    mov        r0, r4
0011ca50  10d04be2    sub        sp, fp, #0x10
0011ca54  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
0011ca58  649a5300    subseq     sb, r3, r4, ror #20
0011ca5c  b02a4c00    strheq     r2, [ip], #-0xa0
0011ca60  5c214c00    subeq      r2, ip, ip, asr r1
0011ca64  051e4d00    subeq      r1, sp, r5, lsl #28
0011ca68  041e4d00    subeq      r1, sp, r4, lsl #28
0011ca6c  241e4d00    subeq      r1, sp, r4, lsr #28
0011ca70  941e4d00    umaaleq    r1, sp, r4, lr
