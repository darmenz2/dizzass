0011c4bc  f0309fe5    ldr        r3, [pc, #0xf0]
0011c4c0  0020a0e3    mov        r2, #0
0011c4c4  03308fe0    add        r3, pc, r3
0011c4c8  0200d3e7    ldrb       r0, [r3, r2]
0011c4cc  400020e2    eor        r0, r0, #0x40
0011c4d0  0200c3e7    strb       r0, [r3, r2]
0011c4d4  012082e2    add        r2, r2, #1
0011c4d8  0b0052e3    cmp        r2, #0xb
0011c4dc  f9ffff1a    bne        #0x11c4c8
0011c4e0  d0209fe5    ldr        r2, [pc, #0xd0]
0011c4e4  0030a0e3    mov        r3, #0
0011c4e8  02208fe0    add        r2, pc, r2
0011c4ec  020000ea    b          #0x11c4fc
0011c4f0  0b0050e3    cmp        r0, #0xb
0011c4f4  0030a0e1    mov        r3, r0
0011c4f8  1700000a    beq        #0x11c55c
0011c4fc  00009ce5    ldr        r0, [ip]
0011c500  011040e2    sub        r1, r0, #1
0011c504  900100e0    mul        r0, r0, r1
0011c508  010010e3    tst        r0, #1
0011c50c  0200000a    beq        #0x11c51c
0011c510  00009ee5    ldr        r0, [lr]
0011c514  090050e3    cmp        r0, #9
0011c518  0b0000ca    bgt        #0x11c54c
0011c51c  0300d2e7    ldrb       r0, [r2, r3]
0011c520  990020e2    eor        r0, r0, #0x99
0011c524  0300c2e7    strb       r0, [r2, r3]
0011c528  00009ce5    ldr        r0, [ip]
0011c52c  011040e2    sub        r1, r0, #1
0011c530  900101e0    mul        r1, r0, r1
0011c534  010083e2    add        r0, r3, #1
0011c538  010011e3    tst        r1, #1
0011c53c  ebffff0a    beq        #0x11c4f0
0011c540  00109ee5    ldr        r1, [lr]
0011c544  090051e3    cmp        r1, #9
0011c548  e8ffffda    ble        #0x11c4f0
0011c54c  0300d2e7    ldrb       r0, [r2, r3]
0011c550  990020e2    eor        r0, r0, #0x99
0011c554  0300c2e7    strb       r0, [r2, r3]
0011c558  efffffea    b          #0x11c51c
0011c55c  0000a0e3    mov        r0, #0
0011c560  000050e3    cmp        r0, #0
0011c564  0088bd18    popne      {fp, pc}
0011c568  4c109fe5    ldr        r1, [pc, #0x4c]
0011c56c  01108fe0    add        r1, pc, r1
0011c570  0020d1e7    ldrb       r2, [r1, r0]
0011c574  5f2022e2    eor        r2, r2, #0x5f
0011c578  0020c1e7    strb       r2, [r1, r0]
0011c57c  010080e2    add        r0, r0, #1
0011c580  0b0050e3    cmp        r0, #0xb
0011c584  f9ffff1a    bne        #0x11c570
0011c588  0088bde8    pop        {fp, pc}
