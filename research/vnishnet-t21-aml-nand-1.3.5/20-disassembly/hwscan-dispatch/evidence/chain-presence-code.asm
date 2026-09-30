000e640c  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000e6410  1cb08de2    add        fp, sp, #0x1c
000e6414  0cd04de2    sub        sp, sp, #0xc
000e6418  0040a0e1    mov        r4, r0
000e641c  216a00eb    bl         #0x100ca8
000e6420  010050e3    cmp        r0, #1
000e6424  260000ba    blt        #0xe64c4
000e6428  dc909fe5    ldr        sb, [pc, #0xdc]
000e642c  0050a0e1    mov        r5, r0
000e6430  d8609fe5    ldr        r6, [pc, #0xd8]
000e6434  0070a0e3    mov        r7, #0
000e6438  09908fe0    add        sb, pc, sb
000e643c  03a0a0e3    mov        sl, #3
000e6440  06608fe0    add        r6, pc, r6
000e6444  0c0000ea    b          #0xe647c
000e6448  00a08de5    str        sl, [sp]
000e644c  0620a0e1    mov        r2, r6
000e6450  c4009fe5    ldr        r0, [pc, #0xc4]
000e6454  173100e3    movw       r3, #0x117
000e6458  00008fe0    add        r0, pc, r0
000e645c  03008de9    stmib      sp, {r0, r1}
000e6460  0910a0e1    mov        r1, sb
000e6464  b4009fe5    ldr        r0, [pc, #0xb4]
000e6468  00008fe0    add        r0, pc, r0
000e646c  8f6200eb    bl         #0xfeeb0
000e6470  457f87e2    add        r7, r7, #0x114
000e6474  015055e2    subs       r5, r5, #1
000e6478  1100000a    beq        #0xe64c4
000e647c  0c8094e5    ldr        r8, [r4, #0xc]
000e6480  0700b8e7    ldr        r0, [r8, r7]!
000e6484  5f6900eb    bl         #0x100a08
000e6488  001098e5    ldr        r1, [r8]
000e648c  000050e3    cmp        r0, #0
000e6490  0400c8e5    strb       r0, [r8, #4]
000e6494  011081e2    add        r1, r1, #1
000e6498  eaffff0a    beq        #0xe6448
000e649c  00a08de5    str        sl, [sp]
000e64a0  0620a0e1    mov        r2, r6
000e64a4  68009fe5    ldr        r0, [pc, #0x68]
000e64a8  153100e3    movw       r3, #0x115
000e64ac  00008fe0    add        r0, pc, r0
000e64b0  03008de9    stmib      sp, {r0, r1}
000e64b4  0910a0e1    mov        r1, sb
000e64b8  58009fe5    ldr        r0, [pc, #0x58]
000e64bc  00008fe0    add        r0, pc, r0
000e64c0  e9ffffea    b          #0xe646c
000e64c4  f76900eb    bl         #0x100ca8
000e64c8  010050e3    cmp        r0, #1
000e64cc  0b0000ba    blt        #0xe6500
000e64d0  0c1094e5    ldr        r1, [r4, #0xc]
000e64d4  042081e2    add        r2, r1, #4
000e64d8  0010a0e3    mov        r1, #0
000e64dc  1431d2e4    ldrb       r3, [r2], #0x114
000e64e0  010050e2    subs       r0, r0, #1
000e64e4  031081e0    add        r1, r1, r3
000e64e8  fbffff1a    bne        #0xe64dc
000e64ec  0000a0e3    mov        r0, #0
000e64f0  000051e3    cmp        r1, #0
000e64f4  0000e003    mvneq      r0, #0
000e64f8  1cd04be2    sub        sp, fp, #0x1c
000e64fc  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
000e6500  0000e0e3    mvn        r0, #0
000e6504  1cd04be2    sub        sp, fp, #0x1c
000e6508  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
