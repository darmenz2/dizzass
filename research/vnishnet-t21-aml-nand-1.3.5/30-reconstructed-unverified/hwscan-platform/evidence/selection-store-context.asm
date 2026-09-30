000e9140  7c329fe5    ldr        r3, [pc, #0x27c]
000e9144  7c129fe5    ldr        r1, [pc, #0x27c]
000e9148  7c229fe5    ldr        r2, [pc, #0x27c]
000e914c  03308fe0    add        r3, pc, r3
000e9150  78729fe5    ldr        r7, [pc, #0x278]
000e9154  01108fe0    add        r1, pc, r1
000e9158  74629fe5    ldr        r6, [pc, #0x274]
000e915c  02208fe0    add        r2, pc, r2
000e9160  07708fe0    add        r7, pc, r7
000e9164  06609fe7    ldr        r6, [pc, r6]
000e9168  000086e5    str        r0, [r6]
000e916c  0300a0e3    mov        r0, #3
000e9170  81008de8    stm        sp, {r0, r7}
000e9174  0300a0e1    mov        r0, r3
000e9178  4d30a0e3    mov        r3, #0x4d
000e917c  08408de5    str        r4, [sp, #8]
000e9180  4a5700eb    bl         #0xfeeb0
