000d21dc  704c2de9    push       {r4, r5, r6, sl, fp, lr}
000d21e0  10b08de2    add        fp, sp, #0x10
000d21e4  00c0a0e1    mov        ip, r0
000d21e8  0000e0e3    mvn        r0, #0
000d21ec  04005ce3    cmp        ip, #4
000d21f0  bc00008a    bhi        #0xd24e8
000d21f4  0340a0e1    mov        r4, r3
000d21f8  ec329fe5    ldr        r3, [pc, #0x2ec]
000d21fc  03309fe7    ldr        r3, [pc, r3]
000d2200  04608fe2    add        r6, pc, #4
000d2204  0c5196e7    ldr        r5, [r6, ip, lsl #2]
000d2208  05f086e0    add        pc, r6, r5
