0011c080  58109fe5    ldr        r1, [pc, #0x58]
0011c084  01109fe7    ldr        r1, [pc, r1]
0011c088  002091e5    ldr        r2, [r1]
0011c08c  013042e2    sub        r3, r2, #1
0011c090  920302e0    mul        r2, r2, r3
0011c094  010012e3    tst        r2, #1
0011c098  002091e5    ldr        r2, [r1]
0011c09c  013042e2    sub        r3, r2, #1
0011c0a0  920302e0    mul        r2, r2, r3
0011c0a4  010012e3    tst        r2, #1
0011c0a8  0400000a    beq        #0x11c0c0
0011c0ac  30209fe5    ldr        r2, [pc, #0x30]
0011c0b0  02209fe7    ldr        r2, [pc, r2]
0011c0b4  002092e5    ldr        r2, [r2]
0011c0b8  090052e3    cmp        r2, #9
0011c0bc  f5ffffca    bgt        #0x11c098
0011c0c0  020050e3    cmp        r0, #2
0011c0c4  20009f85    ldrhi      r0, [pc, #0x20]
0011c0c8  00008f80    addhi      r0, pc, r0
0011c0cc  1eff2f81    bxhi       lr
0011c0d0  10109fe5    ldr        r1, [pc, #0x10]
0011c0d4  01108fe0    add        r1, pc, r1
0011c0d8  000191e7    ldr        r0, [r1, r0, lsl #2]
0011c0dc  1eff2fe1    bx         lr
