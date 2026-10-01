0010e220  020050e3    cmp        r0, #2
0010e224  18009f85    ldrhi      r0, [pc, #0x18]
0010e228  00008f80    addhi      r0, pc, r0
0010e22c  1eff2f81    bxhi       lr
0010e230  08109fe5    ldr        r1, [pc, #8]
0010e234  01108fe0    add        r1, pc, r1
0010e238  000191e7    ldr        r0, [r1, r0, lsl #2]
0010e23c  1eff2fe1    bx         lr
