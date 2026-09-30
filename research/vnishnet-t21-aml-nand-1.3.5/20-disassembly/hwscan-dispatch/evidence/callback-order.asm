0010039c  00208ce5    str        r2, [ip]
001003a0  24269fe5    ldr        r2, [pc, #0x624]
001003a4  0130a0e3    mov        r3, #1
001003a8  02208fe0    add        r2, pc, r2
001003ac  0030c2e5    strb       r3, [r2]
001003b0  31ff2fe1    blx        r1
001003b4  0040e0e3    mvn        r4, #0
001003b8  000050e3    cmp        r0, #0
001003bc  adfcff1a    bne        #0xff678
001003c0  08069fe5    ldr        r0, [pc, #0x608]
001003c4  00009fe7    ldr        r0, [pc, r0]
001003c8  30ff2fe1    blx        r0
001003cc  000050e3    cmp        r0, #0
001003d0  0c00000a    beq        #0x100408
001003d4  f8059fe5    ldr        r0, [pc, #0x5f8]
001003d8  0170a0e3    mov        r7, #1
001003dc  f4159fe5    ldr        r1, [pc, #0x5f4]
001003e0  f4259fe5    ldr        r2, [pc, #0x5f4]
001003e4  00008fe0    add        r0, pc, r0
001003e8  f0359fe5    ldr        r3, [pc, #0x5f0]
001003ec  01108fe0    add        r1, pc, r1
001003f0  02208fe0    add        r2, pc, r2
001003f4  00708de5    str        r7, [sp]
001003f8  03308fe0    add        r3, pc, r3
001003fc  04308de5    str        r3, [sp, #4]
00100400  633100e3    movw       r3, #0x163
00100404  1d0000ea    b          #0x100480
00100408  d4059fe5    ldr        r0, [pc, #0x5d4]
0010040c  0370a0e3    mov        r7, #3
00100410  d0159fe5    ldr        r1, [pc, #0x5d0]
00100414  d0259fe5    ldr        r2, [pc, #0x5d0]
00100418  00008fe0    add        r0, pc, r0
0010041c  cc359fe5    ldr        r3, [pc, #0x5cc]
00100420  01108fe0    add        r1, pc, r1
00100424  02208fe0    add        r2, pc, r2
00100428  00708de5    str        r7, [sp]
0010042c  03308fe0    add        r3, pc, r3
00100430  04308de5    str        r3, [sp, #4]
00100434  673100e3    movw       r3, #0x167
00100438  9cfaffeb    bl         #0xfeeb0
0010043c  b0059fe5    ldr        r0, [pc, #0x5b0]
00100440  00009fe7    ldr        r0, [pc, r0]
00100444  30ff2fe1    blx        r0
00100448  000050e3    cmp        r0, #0
0010044c  0d00000a    beq        #0x100488
00100450  a0059fe5    ldr        r0, [pc, #0x5a0]
00100454  0170a0e3    mov        r7, #1
00100458  9c159fe5    ldr        r1, [pc, #0x59c]
0010045c  9c259fe5    ldr        r2, [pc, #0x59c]
00100460  00008fe0    add        r0, pc, r0
00100464  98359fe5    ldr        r3, [pc, #0x598]
00100468  01108fe0    add        r1, pc, r1
0010046c  02208fe0    add        r2, pc, r2
00100470  00708de5    str        r7, [sp]
00100474  03308fe0    add        r3, pc, r3
00100478  04308de5    str        r3, [sp, #4]
0010047c  693100e3    movw       r3, #0x169
00100480  8afaffeb    bl         #0xfeeb0
00100484  7bfcffea    b          #0xff678
00100488  0040a0e3    mov        r4, #0
0010048c  79fcffea    b          #0xff678
