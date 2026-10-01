000e6160  30482de9    push       {r4, r5, fp, lr}
000e6164  08b08de2    add        fp, sp, #8
000e6168  08d04de2    sub        sp, sp, #8
000e616c  80519fe5    ldr        r5, [pc, #0x180]
000e6170  0040a0e1    mov        r4, r0
000e6174  05509fe7    ldr        r5, [pc, r5]
000e6178  001095e5    ldr        r1, [r5]
000e617c  460600eb    bl         #0xe7a9c
000e6180  000050e3    cmp        r0, #0
000e6184  0c00000a    beq        #0xe61bc
