000e9184  58001be5    ldr        r0, [fp, #-0x58]
000e9188  000050e3    cmp        r0, #0
000e918c  7000001a    bne        #0xe9354
000e9190  50301be5    ldr        r3, [fp, #-0x50]
000e9194  000053e3    cmp        r3, #0
000e9198  1e00000a    beq        #0xe9218
000e919c  34029fe5    ldr        r0, [pc, #0x234]
000e91a0  0360a0e3    mov        r6, #3
000e91a4  30129fe5    ldr        r1, [pc, #0x230]
000e91a8  30229fe5    ldr        r2, [pc, #0x230]
000e91ac  00008fe0    add        r0, pc, r0
000e91b0  2c729fe5    ldr        r7, [pc, #0x22c]
000e91b4  01108fe0    add        r1, pc, r1
000e91b8  02208fe0    add        r2, pc, r2
000e91bc  07708fe0    add        r7, pc, r7
000e91c0  c0008de8    stm        sp, {r6, r7}
000e91c4  08308de5    str        r3, [sp, #8]
000e91c8  5630a0e3    mov        r3, #0x56
000e91cc  375700eb    bl         #0xfeeb0
000e91d0  50001be5    ldr        r0, [fp, #-0x50]
000e91d4  12e7fceb    bl         #0x22e24
000e91d8  000050e3    cmp        r0, #0
000e91dc  0d00000a    beq        #0xe9218
000e91e0  00029fe5    ldr        r0, [pc, #0x200]
000e91e4  0160a0e3    mov        r6, #1
000e91e8  fc119fe5    ldr        r1, [pc, #0x1fc]
000e91ec  fc219fe5    ldr        r2, [pc, #0x1fc]
000e91f0  00008fe0    add        r0, pc, r0
000e91f4  50301be5    ldr        r3, [fp, #-0x50]
000e91f8  01108fe0    add        r1, pc, r1
000e91fc  f0719fe5    ldr        r7, [pc, #0x1f0]
000e9200  02208fe0    add        r2, pc, r2
000e9204  07708fe0    add        r7, pc, r7
000e9208  c0008de8    stm        sp, {r6, r7}
000e920c  08308de5    str        r3, [sp, #8]
000e9210  5830a0e3    mov        r3, #0x58
000e9214  3b0000ea    b          #0xe9308
000e9218  4c301be5    ldr        r3, [fp, #-0x4c]
000e921c  000053e3    cmp        r3, #0
000e9220  3c00000a    beq        #0xe9318
000e9224  cc419fe5    ldr        r4, [pc, #0x1cc]
000e9228  04409fe7    ldr        r4, [pc, r4]
000e922c  000094e5    ldr        r0, [r4]
000e9230  050050e3    cmp        r0, #5
000e9234  0c00001a    bne        #0xe926c
000e9238  bc019fe5    ldr        r0, [pc, #0x1bc]
000e923c  0170a0e3    mov        r7, #1
000e9240  b8119fe5    ldr        r1, [pc, #0x1b8]
000e9244  b8219fe5    ldr        r2, [pc, #0x1b8]
000e9248  00008fe0    add        r0, pc, r0
000e924c  b4319fe5    ldr        r3, [pc, #0x1b4]
000e9250  01108fe0    add        r1, pc, r1
000e9254  02208fe0    add        r2, pc, r2
000e9258  00708de5    str        r7, [sp]
000e925c  03308fe0    add        r3, pc, r3
000e9260  04308de5    str        r3, [sp, #4]
000e9264  5f30a0e3    mov        r3, #0x5f
000e9268  260000ea    b          #0xe9308
000e926c  98019fe5    ldr        r0, [pc, #0x198]
000e9270  0360a0e3    mov        r6, #3
000e9274  94119fe5    ldr        r1, [pc, #0x194]
000e9278  94219fe5    ldr        r2, [pc, #0x194]
000e927c  00008fe0    add        r0, pc, r0
000e9280  90719fe5    ldr        r7, [pc, #0x190]
000e9284  01108fe0    add        r1, pc, r1
000e9288  02208fe0    add        r2, pc, r2
000e928c  07708fe0    add        r7, pc, r7
000e9290  c0008de8    stm        sp, {r6, r7}
000e9294  08308de5    str        r3, [sp, #8]
000e9298  6330a0e3    mov        r3, #0x63
000e929c  035700eb    bl         #0xfeeb0
000e92a0  001094e5    ldr        r1, [r4]
000e92a4  4c001be5    ldr        r0, [fp, #-0x4c]
000e92a8  040051e3    cmp        r1, #4
000e92ac  0300008a    bhi        #0xe92c0
000e92b0  68219fe5    ldr        r2, [pc, #0x168]
000e92b4  02208fe0    add        r2, pc, r2
000e92b8  011192e7    ldr        r1, [r2, r1, lsl #2]
000e92bc  010000ea    b          #0xe92c8
000e92c0  54119fe5    ldr        r1, [pc, #0x154]
000e92c4  01108fe0    add        r1, pc, r1
000e92c8  a3eafceb    bl         #0x23d5c
000e92cc  000050e3    cmp        r0, #0
000e92d0  1000000a    beq        #0xe9318
000e92d4  48019fe5    ldr        r0, [pc, #0x148]
000e92d8  0160a0e3    mov        r6, #1
000e92dc  44119fe5    ldr        r1, [pc, #0x144]
000e92e0  44219fe5    ldr        r2, [pc, #0x144]
000e92e4  00008fe0    add        r0, pc, r0
000e92e8  4c301be5    ldr        r3, [fp, #-0x4c]
000e92ec  01108fe0    add        r1, pc, r1
000e92f0  38719fe5    ldr        r7, [pc, #0x138]
000e92f4  02208fe0    add        r2, pc, r2
000e92f8  07708fe0    add        r7, pc, r7
000e92fc  c0008de8    stm        sp, {r6, r7}
000e9300  08308de5    str        r3, [sp, #8]
000e9304  6530a0e3    mov        r3, #0x65
000e9308  e85600eb    bl         #0xfeeb0
000e930c  0000e0e3    mvn        r0, #0
000e9310  1cd04be2    sub        sp, fp, #0x1c
000e9314  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
000e9318  14019fe5    ldr        r0, [pc, #0x114]
000e931c  00009fe7    ldr        r0, [pc, r0]
000e9320  001090e5    ldr        r1, [r0]
000e9324  0000a0e3    mov        r0, #0
000e9328  000051e3    cmp        r1, #0
000e932c  0300001a    bne        #0xe9340
000e9330  4c101be5    ldr        r1, [fp, #-0x4c]
000e9334  50201be5    ldr        r2, [fp, #-0x50]
000e9338  011092e1    orrs       r1, r2, r1
000e933c  0500001a    bne        #0xe9358
000e9340  1cd04be2    sub        sp, fp, #0x1c
000e9344  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
000e9348  8d090beb    bl         #0x3ab984
000e934c  0000a0e3    mov        r0, #0
000e9350  51b1fceb    bl         #0x1589c
000e9354  3becfceb    bl         #0x24448
000e9358  0000a0e3    mov        r0, #0
000e935c  4eb1fceb    bl         #0x1589c
