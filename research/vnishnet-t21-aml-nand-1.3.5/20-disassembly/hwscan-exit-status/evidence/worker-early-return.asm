000e6524  f04d2de9    push       {r4, r5, r6, r7, r8, sl, fp, lr}
000e6528  18b08de2    add        fp, sp, #0x18
000e652c  10d04de2    sub        sp, sp, #0x10
000e6530  0050a0e1    mov        r5, r0
000e6534  0300a0e3    mov        r0, #3
000e6538  0140a0e1    mov        r4, r1
000e653c  de6100eb    bl         #0xfecbc
000e6540  d0059fe5    ldr        r0, [pc, #0x5d0]
000e6544  00008fe0    add        r0, pc, r0
000e6548  d66200eb    bl         #0xff0a8
000e654c  000050e3    cmp        r0, #0
000e6550  4400001a    bne        #0xe6668
000e6554  c8059fe5    ldr        r0, [pc, #0x5c8]
000e6558  ff1100e3    movw       r1, #0x1ff
000e655c  00008fe0    add        r0, pc, r0
000e6560  81cf0deb    bl         #0x45a36c
000e6564  0500a0e1    mov        r0, r5
000e6568  0410a0e1    mov        r1, r4
000e656c  360a00eb    bl         #0xe8e4c
000e6570  010070e3    cmn        r0, #1
000e6574  170000da    ble        #0xe65d8
000e6578  b8759fe5    ldr        r7, [pc, #0x5b8]
000e657c  0010a0e3    mov        r1, #0
000e6580  0020a0e3    mov        r2, #0
000e6584  0130a0e3    mov        r3, #1
000e6588  0140a0e3    mov        r4, #1
000e658c  07709fe7    ldr        r7, [pc, r7]
000e6590  00108de5    str        r1, [sp]
000e6594  0210a0e3    mov        r1, #2
000e6598  000097e5    ldr        r0, [r7]
000e659c  136400eb    bl         #0xff5f0
000e65a0  000050e3    cmp        r0, #0
000e65a4  1b00000a    beq        #0xe6618
000e65a8  8c059fe5    ldr        r0, [pc, #0x58c]
000e65ac  8c159fe5    ldr        r1, [pc, #0x58c]
000e65b0  8c259fe5    ldr        r2, [pc, #0x58c]
000e65b4  00008fe0    add        r0, pc, r0
000e65b8  88359fe5    ldr        r3, [pc, #0x588]
000e65bc  01108fe0    add        r1, pc, r1
000e65c0  02208fe0    add        r2, pc, r2
000e65c4  00408de5    str        r4, [sp]
000e65c8  03308fe0    add        r3, pc, r3
000e65cc  04308de5    str        r3, [sp, #4]
000e65d0  4d3fa0e3    mov        r3, #0x134
000e65d4  0b0000ea    b          #0xe6608
000e65d8  48059fe5    ldr        r0, [pc, #0x548]
000e65dc  0170a0e3    mov        r7, #1
000e65e0  44159fe5    ldr        r1, [pc, #0x544]
000e65e4  44259fe5    ldr        r2, [pc, #0x544]
000e65e8  00008fe0    add        r0, pc, r0
000e65ec  40359fe5    ldr        r3, [pc, #0x540]
000e65f0  01108fe0    add        r1, pc, r1
000e65f4  02208fe0    add        r2, pc, r2
000e65f8  00708de5    str        r7, [sp]
000e65fc  03308fe0    add        r3, pc, r3
000e6600  04308de5    str        r3, [sp, #4]
000e6604  2f3100e3    movw       r3, #0x12f
000e6608  286200eb    bl         #0xfeeb0
000e660c  0000e0e3    mvn        r0, #0
000e6610  18d04be2    sub        sp, fp, #0x18
000e6614  f08dbde8    pop        {r4, r5, r6, r7, r8, sl, fp, pc}
