0003720c  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
00037210  1cb08de2    add        fp, sp, #0x1c
00037214  ccd04de2    sub        sp, sp, #0xcc
00037218  14008de5    str        r0, [sp, #0x14]
0003721c  0170a0e1    mov        r7, r1
00037220  940f9fe5    ldr        r0, [pc, #0xf94]
00037224  0050a0e3    mov        r5, #0
00037228  4210a0e3    mov        r1, #0x42
0003722c  b62100e3    movw       r2, #0x1b6
00037230  00008fe0    add        r0, pc, r0
00037234  38508de5    str        r5, [sp, #0x38]
00037238  277115eb    bl         #0x5936dc
0003723c  0040a0e1    mov        r4, r0
00037240  e76f15eb    bl         #0x5931e4
00037244  0060a0e1    mov        r6, r0
00037248  010074e3    cmn        r4, #1
0003724c  0b0000ca    bgt        #0x37280
00037250  000096e5    ldr        r0, [r6]
00037254  f26f15eb    bl         #0x593224
00037258  dc2f9fe5    ldr        r2, [pc, #0xfdc]
0003725c  dc1f9fe5    ldr        r1, [pc, #0xfdc]
00037260  dc3f9fe5    ldr        r3, [pc, #0xfdc]
00037264  02208fe0    add        r2, pc, r2
00037268  01108fe0    add        r1, pc, r1
0003726c  00008de5    str        r0, [sp]
00037270  03308fe0    add        r3, pc, r3
00037274  0200a0e1    mov        r0, r2
00037278  a62e00e3    movw       r2, #0xea6
0003727c  0564ffeb    bl         #0x10298
00037280  0400a0e1    mov        r0, r4
00037284  0610a0e3    mov        r1, #6
00037288  005086e5    str        r5, [r6]
0003728c  077215eb    bl         #0x593ab0
00037290  000050e3    cmp        r0, #0
00037294  0a00000a    beq        #0x372c4
00037298  000096e5    ldr        r0, [r6]
0003729c  0b0050e3    cmp        r0, #0xb
000372a0  0700001a    bne        #0x372c4
000372a4  9c0f9fe5    ldr        r0, [pc, #0xf9c]
000372a8  ac2e00e3    movw       r2, #0xeac
000372ac  981f9fe5    ldr        r1, [pc, #0xf98]
000372b0  983f9fe5    ldr        r3, [pc, #0xf98]
000372b4  00008fe0    add        r0, pc, r0
000372b8  01108fe0    add        r1, pc, r1
000372bc  03308fe0    add        r3, pc, r3
000372c0  f463ffeb    bl         #0x10298
000372c4  2c608de5    str        r6, [sp, #0x2c]
000372c8  848f9fe5    ldr        r8, [pc, #0xf84]
000372cc  08809fe7    ldr        r8, [pc, r8]
000372d0  000098e5    ldr        r0, [r8]
000372d4  011040e2    sub        r1, r0, #1
000372d8  900100e0    mul        r0, r0, r1
000372dc  010010e3    tst        r0, #1
000372e0  0400000a    beq        #0x372f8
000372e4  6c0f9fe5    ldr        r0, [pc, #0xf6c]
000372e8  00009fe7    ldr        r0, [pc, r0]
000372ec  000090e5    ldr        r0, [r0]
000372f0  090050e3    cmp        r0, #9
000372f4  0c0000ca    bgt        #0x3732c
000372f8  fc0f9fe5    ldr        r0, [pc, #0xffc]
000372fc  00008fe0    add        r0, pc, r0
00037300  850c03eb    bl         #0xfa51c
00037304  001098e5    ldr        r1, [r8]
00037308  012041e2    sub        r2, r1, #1
