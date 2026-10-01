00073dd4  24009de5    ldr        r0, [sp, #0x24]
00073dd8  2c20d8e5    ldrb       r2, [r8, #0x2c]
00073ddc  001096e5    ldr        r1, [r6]
00073de0  113e80e2    add        r3, r0, #0x110
00073de4  0200a0e3    mov        r0, #2
00073de8  fb7801eb    bl         #0xd21dc
00073dec  001099e5    ldr        r1, [sb]
00073df0  012041e2    sub        r2, r1, #1
00073df4  910201e0    mul        r1, r1, r2
00073df8  010011e3    tst        r1, #1
00073dfc  0900000a    beq        #0x73e28
00073e00  00109ae5    ldr        r1, [sl]
00073e04  090051e3    cmp        r1, #9
00073e08  060000da    ble        #0x73e28
00073e0c  24009de5    ldr        r0, [sp, #0x24]
00073e10  2c20d8e5    ldrb       r2, [r8, #0x2c]
00073e14  001096e5    ldr        r1, [r6]
00073e18  113e80e2    add        r3, r0, #0x110
00073e1c  0200a0e3    mov        r0, #2
00073e20  ed7801eb    bl         #0xd21dc
00073e24  eaffffea    b          #0x73dd4
00073e28  000050e3    cmp        r0, #0
00073e2c  0900001a    bne        #0x73e58
