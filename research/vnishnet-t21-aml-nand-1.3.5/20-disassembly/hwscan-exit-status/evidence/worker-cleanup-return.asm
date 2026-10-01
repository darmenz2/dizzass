000e66d0  db0400eb    bl         #0xe7a44
000e66d4  000050e3    cmp        r0, #0
000e66d8  1e00000a    beq        #0xe6758
000e66dc  28059fe5    ldr        r0, [pc, #0x528]
000e66e0  0370a0e3    mov        r7, #3
000e66e4  24159fe5    ldr        r1, [pc, #0x524]
000e66e8  24259fe5    ldr        r2, [pc, #0x524]
000e66ec  00008fe0    add        r0, pc, r0
000e66f0  20359fe5    ldr        r3, [pc, #0x520]
000e66f4  01108fe0    add        r1, pc, r1
000e66f8  02208fe0    add        r2, pc, r2
000e66fc  00708de5    str        r7, [sp]
000e6700  03308fe0    add        r3, pc, r3
000e6704  04308de5    str        r3, [sp, #4]
000e6708  893100e3    movw       r3, #0x189
000e670c  e76100eb    bl         #0xfeeb0
000e6710  100084e2    add        r0, r4, #0x10
000e6714  0110a0e3    mov        r1, #1
000e6718  587600eb    bl         #0x104080
000e671c  000050e3    cmp        r0, #0
000e6720  0c00000a    beq        #0xe6758
000e6724  f0049fe5    ldr        r0, [pc, #0x4f0]
000e6728  0270a0e3    mov        r7, #2
000e672c  ec149fe5    ldr        r1, [pc, #0x4ec]
000e6730  ec249fe5    ldr        r2, [pc, #0x4ec]
000e6734  00008fe0    add        r0, pc, r0
000e6738  e8349fe5    ldr        r3, [pc, #0x4e8]
000e673c  01108fe0    add        r1, pc, r1
000e6740  02208fe0    add        r2, pc, r2
000e6744  00708de5    str        r7, [sp]
000e6748  03308fe0    add        r3, pc, r3
000e674c  04308de5    str        r3, [sp, #4]
000e6750  633fa0e3    mov        r3, #0x18c
000e6754  d56100eb    bl         #0xfeeb0
000e6758  0400a0e1    mov        r0, r4
000e675c  ef0200eb    bl         #0xe7320
000e6760  cc0400eb    bl         #0xe7a98
000e6764  000050e3    cmp        r0, #0
000e6768  0c00000a    beq        #0xe67a0
000e676c  b8049fe5    ldr        r0, [pc, #0x4b8]
000e6770  0170a0e3    mov        r7, #1
000e6774  b4149fe5    ldr        r1, [pc, #0x4b4]
000e6778  b4249fe5    ldr        r2, [pc, #0x4b4]
000e677c  00008fe0    add        r0, pc, r0
000e6780  b0349fe5    ldr        r3, [pc, #0x4b0]
000e6784  01108fe0    add        r1, pc, r1
000e6788  02208fe0    add        r2, pc, r2
000e678c  00708de5    str        r7, [sp]
000e6790  03308fe0    add        r3, pc, r3
000e6794  04308de5    str        r3, [sp, #4]
000e6798  1730a0e3    mov        r3, #0x17
000e679c  c36100eb    bl         #0xfeeb0
000e67a0  a56800eb    bl         #0x100a3c
000e67a4  456200eb    bl         #0xff0c0
000e67a8  0000a0e3    mov        r0, #0
000e67ac  18d04be2    sub        sp, fp, #0x18
000e67b0  f08dbde8    pop        {r4, r5, r6, r7, r8, sl, fp, pc}
