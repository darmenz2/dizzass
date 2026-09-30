0045f7dc  010040e2    sub        r0, r0, #1
0045f7e0  011041e2    sub        r1, r1, #1
0045f7e4  0130f0e5    ldrb       r3, [r0, #1]!
0045f7e8  0120f1e5    ldrb       r2, [r1, #1]!
0045f7ec  020053e1    cmp        r3, r2
0045f7f0  0100001a    bne        #0x45f7fc
0045f7f4  000053e3    cmp        r3, #0
0045f7f8  f9ffff1a    bne        #0x45f7e4
0045f7fc  020043e0    sub        r0, r3, r2
0045f800  1eff2fe1    bx         lr
