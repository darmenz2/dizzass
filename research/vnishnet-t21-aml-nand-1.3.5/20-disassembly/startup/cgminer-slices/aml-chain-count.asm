0011b6c8  30009fe5    ldr        r0, [pc, #0x30]
0011b6cc  00009fe7    ldr        r0, [pc, r0]
0011b6d0  2c109fe5    ldr        r1, [pc, #0x2c]
0011b6d4  01109fe7    ldr        r1, [pc, r1]
0011b6d8  002090e5    ldr        r2, [r0]
0011b6dc  013042e2    sub        r3, r2, #1
0011b6e0  920302e0    mul        r2, r2, r3
0011b6e4  010012e3    tst        r2, #1
0011b6e8  0200000a    beq        #0x11b6f8
0011b6ec  002091e5    ldr        r2, [r1]
0011b6f0  090052e3    cmp        r2, #9
0011b6f4  f7ffffca    bgt        #0x11b6d8
0011b6f8  0300a0e3    mov        r0, #3
0011b6fc  1eff2fe1    bx         lr
0011b700  58374c00    subeq      r3, ip, r8, asr r7
0011b704  c43c4c00    subeq      r3, ip, r4, asr #25
