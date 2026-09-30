0011c5c0  704c2de9    push       {r4, r5, r6, sl, fp, lr}
0011c5c4  10b08de2    add        fp, sp, #0x10
0011c5c8  08d04de2    sub        sp, sp, #8
0011c5cc  b50100e3    movw       r0, #0x1b5
0011c5d0  612100eb    bl         #0x124b5c
0011c5d4  000050e3    cmp        r0, #0
0011c5d8  1800000a    beq        #0x11c640
0011c5dc  18439fe5    ldr        r4, [pc, #0x318]
0011c5e0  04409fe7    ldr        r4, [pc, r4]
0011c5e4  000094e5    ldr        r0, [r4]
0011c5e8  10539fe5    ldr        r5, [pc, #0x310]
0011c5ec  011040e2    sub        r1, r0, #1
0011c5f0  900100e0    mul        r0, r0, r1
0011c5f4  05509fe7    ldr        r5, [pc, r5]
0011c5f8  010010e3    tst        r0, #1
0011c5fc  0200000a    beq        #0x11c60c
0011c600  000095e5    ldr        r0, [r5]
0011c604  090050e3    cmp        r0, #9
0011c608  090000ca    bgt        #0x11c634
0011c60c  b50100e3    movw       r0, #0x1b5
0011c610  e82200eb    bl         #0x1251b8
0011c614  000094e5    ldr        r0, [r4]
0011c618  011040e2    sub        r1, r0, #1
0011c61c  900100e0    mul        r0, r0, r1
0011c620  010010e3    tst        r0, #1
0011c624  0500000a    beq        #0x11c640
0011c628  000095e5    ldr        r0, [r5]
0011c62c  090050e3    cmp        r0, #9
0011c630  020000da    ble        #0x11c640
0011c634  b50100e3    movw       r0, #0x1b5
0011c638  de2200eb    bl         #0x1251b8
0011c63c  f2ffffea    b          #0x11c60c
0011c640  bc529fe5    ldr        r5, [pc, #0x2bc]
0011c644  05509fe7    ldr        r5, [pc, r5]
0011c648  000095e5    ldr        r0, [r5]
0011c64c  b4629fe5    ldr        r6, [pc, #0x2b4]
0011c650  011040e2    sub        r1, r0, #1
0011c654  900100e0    mul        r0, r0, r1
0011c658  06609fe7    ldr        r6, [pc, r6]
0011c65c  010010e3    tst        r0, #1
0011c660  0200000a    beq        #0x11c670
0011c664  000096e5    ldr        r0, [r6]
0011c668  090050e3    cmp        r0, #9
0011c66c  0a0000ca    bgt        #0x11c69c
0011c670  b50100e3    movw       r0, #0x1b5
0011c674  0110a0e3    mov        r1, #1
0011c678  992000eb    bl         #0x1248e4
0011c67c  001095e5    ldr        r1, [r5]
0011c680  012041e2    sub        r2, r1, #1
0011c684  910201e0    mul        r1, r1, r2
0011c688  010011e3    tst        r1, #1
0011c68c  0600000a    beq        #0x11c6ac
0011c690  001096e5    ldr        r1, [r6]
0011c694  090051e3    cmp        r1, #9
0011c698  030000da    ble        #0x11c6ac
0011c69c  b50100e3    movw       r0, #0x1b5
0011c6a0  0110a0e3    mov        r1, #1
0011c6a4  8e2000eb    bl         #0x1248e4
0011c6a8  f0ffffea    b          #0x11c670
0011c6ac  000050e3    cmp        r0, #0
0011c6b0  0f00000a    beq        #0x11c6f4
0011c6b4  50029fe5    ldr        r0, [pc, #0x250]
0011c6b8  0160a0e3    mov        r6, #1
0011c6bc  4c129fe5    ldr        r1, [pc, #0x24c]
0011c6c0  4c229fe5    ldr        r2, [pc, #0x24c]
0011c6c4  00008fe0    add        r0, pc, r0
0011c6c8  48329fe5    ldr        r3, [pc, #0x248]
0011c6cc  01108fe0    add        r1, pc, r1
0011c6d0  02208fe0    add        r2, pc, r2
0011c6d4  00608de5    str        r6, [sp]
0011c6d8  03308fe0    add        r3, pc, r3
0011c6dc  04308de5    str        r3, [sp, #4]
0011c6e0  2630a0e3    mov        r3, #0x26
0011c6e4  7676ffeb    bl         #0xfa0c4
0011c6e8  0000e0e3    mvn        r0, #0
0011c6ec  10d04be2    sub        sp, fp, #0x10
0011c6f0  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
0011c6f4  000095e5    ldr        r0, [r5]
0011c6f8  011040e2    sub        r1, r0, #1
0011c6fc  900100e0    mul        r0, r0, r1
0011c700  010010e3    tst        r0, #1
0011c704  0200000a    beq        #0x11c714
0011c708  000096e5    ldr        r0, [r6]
0011c70c  090050e3    cmp        r0, #9
0011c710  0f0000ca    bgt        #0x11c754
0011c714  00429fe5    ldr        r4, [pc, #0x200]
0011c718  0110a0e3    mov        r1, #1
0011c71c  fc319fe5    ldr        r3, [pc, #0x1fc]
0011c720  0020a0e3    mov        r2, #0
0011c724  04408fe0    add        r4, pc, r4
0011c728  03308fe0    add        r3, pc, r3
0011c72c  0400a0e1    mov        r0, r4
0011c730  bc2400eb    bl         #0x125a28
0011c734  001095e5    ldr        r1, [r5]
0011c738  012041e2    sub        r2, r1, #1
0011c73c  910201e0    mul        r1, r1, r2
0011c740  010011e3    tst        r1, #1
0011c744  0a00000a    beq        #0x11c774
0011c748  001096e5    ldr        r1, [r6]
0011c74c  090051e3    cmp        r1, #9
0011c750  070000da    ble        #0x11c774
0011c754  04029fe5    ldr        r0, [pc, #0x204]
0011c758  0110a0e3    mov        r1, #1
0011c75c  00329fe5    ldr        r3, [pc, #0x200]
0011c760  0020a0e3    mov        r2, #0
0011c764  00008fe0    add        r0, pc, r0
0011c768  03308fe0    add        r3, pc, r3
0011c76c  ad2400eb    bl         #0x125a28
0011c770  e7ffffea    b          #0x11c714
0011c774  000050e3    cmp        r0, #0
0011c778  0a00000a    beq        #0x11c7a8
0011c77c  000095e5    ldr        r0, [r5]
0011c780  9c419fe5    ldr        r4, [pc, #0x19c]
0011c784  011040e2    sub        r1, r0, #1
0011c788  04408fe0    add        r4, pc, r4
0011c78c  900100e0    mul        r0, r0, r1
0011c790  010010e3    tst        r0, #1
0011c794  1a00000a    beq        #0x11c804
0011c798  000096e5    ldr        r0, [r6]
0011c79c  090050e3    cmp        r0, #9
0011c7a0  2a0000ca    bgt        #0x11c850
0011c7a4  160000ea    b          #0x11c804
0011c7a8  240084e2    add        r0, r4, #0x24
0011c7ac  dd1100e3    movw       r1, #0x1dd
0011c7b0  772fa0e3    mov        r2, #0x1dc
0011c7b4  322600eb    bl         #0x126084
0011c7b8  000050e3    cmp        r0, #0
0011c7bc  0a00000a    beq        #0x11c7ec
0011c7c0  000095e5    ldr        r0, [r5]
0011c7c4  74419fe5    ldr        r4, [pc, #0x174]
0011c7c8  011040e2    sub        r1, r0, #1
0011c7cc  04408fe0    add        r4, pc, r4
0011c7d0  900100e0    mul        r0, r0, r1
0011c7d4  010010e3    tst        r0, #1
0011c7d8  2700000a    beq        #0x11c87c
0011c7dc  000096e5    ldr        r0, [r6]
0011c7e0  090050e3    cmp        r0, #9
0011c7e4  370000ca    bgt        #0x11c8c8
0011c7e8  230000ea    b          #0x11c87c
0011c7ec  68019fe5    ldr        r0, [pc, #0x168]
0011c7f0  0110a0e3    mov        r1, #1
0011c7f4  00008fe0    add        r0, pc, r0
0011c7f8  0010c0e5    strb       r1, [r0]
0011c7fc  0000a0e3    mov        r0, #0
0011c800  3b0000ea    b          #0x11c8f4
0011c804  1c019fe5    ldr        r0, [pc, #0x11c]
0011c808  0130a0e3    mov        r3, #1
0011c80c  18119fe5    ldr        r1, [pc, #0x118]
0011c810  18219fe5    ldr        r2, [pc, #0x118]
0011c814  00008fe0    add        r0, pc, r0
0011c818  01108fe0    add        r1, pc, r1
0011c81c  18008de8    stm        sp, {r3, r4}
0011c820  02208fe0    add        r2, pc, r2
0011c824  2b30a0e3    mov        r3, #0x2b
0011c828  2576ffeb    bl         #0xfa0c4
0011c82c  000095e5    ldr        r0, [r5]
0011c830  011040e2    sub        r1, r0, #1
0011c834  900101e0    mul        r1, r0, r1
0011c838  0000e0e3    mvn        r0, #0
0011c83c  010011e3    tst        r1, #1
0011c840  2b00000a    beq        #0x11c8f4
0011c844  001096e5    ldr        r1, [r6]
0011c848  0a0051e3    cmp        r1, #0xa
0011c84c  280000ba    blt        #0x11c8f4
0011c850  dc009fe5    ldr        r0, [pc, #0xdc]
0011c854  0130a0e3    mov        r3, #1
0011c858  d8109fe5    ldr        r1, [pc, #0xd8]
0011c85c  d8209fe5    ldr        r2, [pc, #0xd8]
0011c860  00008fe0    add        r0, pc, r0
0011c864  01108fe0    add        r1, pc, r1
0011c868  18008de8    stm        sp, {r3, r4}
0011c86c  02208fe0    add        r2, pc, r2
0011c870  2b30a0e3    mov        r3, #0x2b
0011c874  1276ffeb    bl         #0xfa0c4
0011c878  e1ffffea    b          #0x11c804
0011c87c  c0009fe5    ldr        r0, [pc, #0xc0]
0011c880  0130a0e3    mov        r3, #1
0011c884  bc109fe5    ldr        r1, [pc, #0xbc]
0011c888  bc209fe5    ldr        r2, [pc, #0xbc]
0011c88c  00008fe0    add        r0, pc, r0
0011c890  01108fe0    add        r1, pc, r1
0011c894  18008de8    stm        sp, {r3, r4}
0011c898  02208fe0    add        r2, pc, r2
0011c89c  3030a0e3    mov        r3, #0x30
0011c8a0  0776ffeb    bl         #0xfa0c4
0011c8a4  000095e5    ldr        r0, [r5]
0011c8a8  011040e2    sub        r1, r0, #1
0011c8ac  900101e0    mul        r1, r0, r1
0011c8b0  0000e0e3    mvn        r0, #0
0011c8b4  010011e3    tst        r1, #1
0011c8b8  0d00000a    beq        #0x11c8f4
0011c8bc  001096e5    ldr        r1, [r6]
0011c8c0  0a0051e3    cmp        r1, #0xa
0011c8c4  0a0000ba    blt        #0x11c8f4
0011c8c8  80009fe5    ldr        r0, [pc, #0x80]
0011c8cc  0130a0e3    mov        r3, #1
0011c8d0  7c109fe5    ldr        r1, [pc, #0x7c]
0011c8d4  7c209fe5    ldr        r2, [pc, #0x7c]
0011c8d8  00008fe0    add        r0, pc, r0
0011c8dc  01108fe0    add        r1, pc, r1
0011c8e0  18008de8    stm        sp, {r3, r4}
0011c8e4  02208fe0    add        r2, pc, r2
0011c8e8  3030a0e3    mov        r3, #0x30
0011c8ec  f475ffeb    bl         #0xfa0c4
0011c8f0  e1ffffea    b          #0x11c87c
0011c8f4  10d04be2    sub        sp, fp, #0x10
0011c8f8  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
0011c8fc  44284c00    subeq      r2, ip, r4, asr #16
0011c900  a42d4c00    subeq      r2, ip, r4, lsr #27
0011c904  e0274c00    subeq      r2, ip, r0, ror #15
0011c908  402d4c00    subeq      r2, ip, r0, asr #26
0011c90c  65214d00    subeq      r2, sp, r5, ror #2
0011c910  64214d00    subeq      r2, sp, r4, ror #2
0011c914  84214d00    subeq      r2, sp, r4, lsl #3
0011c918  87214d00    subeq      r2, sp, r7, lsl #3
0011c91c  88985300    subseq     sb, r3, r8, lsl #17
0011c920  57214d00    subeq      r2, sp, r7, asr r1
0011c924  03214d00    subeq      r2, sp, r3, lsl #2
0011c928  15204d00    subeq      r2, sp, r5, lsl r0
0011c92c  18204d00    subeq      r2, sp, r8, lsl r0
0011c930  34204d00    subeq      r2, sp, r4, lsr r0
0011c934  c91f4d00    subeq      r1, sp, sb, asr #31
0011c938  cc1f4d00    subeq      r1, sp, ip, asr #31
0011c93c  e81f4d00    subeq      r1, sp, r8, ror #31
0011c940  de204d00    ldrdeq     r2, r3, [sp], #-0xe
0011c944  9d1f4d00    umaaleq    r1, sp, sp, pc
0011c948  a01f4d00    subeq      r1, sp, r0, lsr #31
0011c94c  bc1f4d00    strheq     r1, [sp], #-0xfc
0011c950  511f4d00    subeq      r1, sp, r1, asr pc
0011c954  541f4d00    subeq      r1, sp, r4, asr pc
0011c958  701f4d00    subeq      r1, sp, r0, ror pc
0011c95c  fc9b5300    ldrsheq    sb, [r3], #-0xbc
0011c960  48985300    subseq     sb, r3, r8, asr #16
0011c964  17214d00    subeq      r2, sp, r7, lsl r1
0011c968  04009fe5    ldr        r0, [pc, #4]
0011c96c  00008fe0    add        r0, pc, r0
0011c970  1eff2fe1    bx         lr
0011c974  40965300    subseq     sb, r3, r0, asr #12
