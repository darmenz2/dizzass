000e8e24  040050e3    cmp        r0, #4
000e8e28  18009f85    ldrhi      r0, [pc, #0x18]
000e8e2c  00008f80    addhi      r0, pc, r0
000e8e30  1eff2f81    bxhi       lr
000e8e34  08109fe5    ldr        r1, [pc, #8]
000e8e38  01108fe0    add        r1, pc, r1
000e8e3c  000191e7    ldr        r0, [r1, r0, lsl #2]
000e8e40  1eff2fe1    bx         lr
