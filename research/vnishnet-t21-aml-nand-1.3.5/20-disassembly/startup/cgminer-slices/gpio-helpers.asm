001248e4  704c2de9    push       {r4, r5, r6, sl, fp, lr}
001248e8  10b08de2    add        fp, sp, #0x10
001248ec  42df4de2    sub        sp, sp, #0x108
001248f0  0050a0e1    mov        r5, r0
001248f4  f0019fe5    ldr        r0, [pc, #0x1f0]
001248f8  0140a0e1    mov        r4, r1
001248fc  00008fe0    add        r0, pc, r0
00124900  000612eb    bl         #0x5a6108
00124904  e4019fe5    ldr        r0, [pc, #0x1e4]
00124908  e4119fe5    ldr        r1, [pc, #0x1e4]
0012490c  00008fe0    add        r0, pc, r0
00124910  01108fe0    add        r1, pc, r1
00124914  25e711eb    bl         #0x59e5b0
00124918  000050e3    cmp        r0, #0
0012491c  2400000a    beq        #0x1249b4
00124920  04129fe5    ldr        r1, [pc, #0x204]
00124924  0520a0e1    mov        r2, r5
00124928  0060a0e1    mov        r6, r0
0012492c  01108fe0    add        r1, pc, r1
00124930  48e711eb    bl         #0x59e658
00124934  0600a0e1    mov        r0, r6
00124938  d1e511eb    bl         #0x59e084
0012493c  ec219fe5    ldr        r2, [pc, #0x1ec]
00124940  08608de2    add        r6, sp, #8
00124944  011ca0e3    mov        r1, #0x100
00124948  0530a0e1    mov        r3, r5
0012494c  02208fe0    add        r2, pc, r2
00124950  0600a0e1    mov        r0, r6
00124954  ffea11eb    bl         #0x59f558
00124958  d4119fe5    ldr        r1, [pc, #0x1d4]
0012495c  0600a0e1    mov        r0, r6
00124960  01108fe0    add        r1, pc, r1
00124964  11e711eb    bl         #0x59e5b0
00124968  000050e3    cmp        r0, #0
0012496c  4800000a    beq        #0x124a94
00124970  d8119fe5    ldr        r1, [pc, #0x1d8]
00124974  0050a0e1    mov        r5, r0
00124978  d4019fe5    ldr        r0, [pc, #0x1d4]
0012497c  000054e3    cmp        r4, #0
00124980  01108fe0    add        r1, pc, r1
00124984  00008fe0    add        r0, pc, r0
00124988  0100a011    movne      r0, r1
0012498c  0510a0e1    mov        r1, r5
00124990  a0e711eb    bl         #0x59e818
00124994  0500a0e1    mov        r0, r5
00124998  b9e511eb    bl         #0x59e084
0012499c  b4019fe5    ldr        r0, [pc, #0x1b4]
001249a0  00008fe0    add        r0, pc, r0
001249a4  460712eb    bl         #0x5a66c4
001249a8  0000a0e3    mov        r0, #0
001249ac  10d04be2    sub        sp, fp, #0x10
001249b0  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
001249b4  3c419fe5    ldr        r4, [pc, #0x13c]
001249b8  04409fe7    ldr        r4, [pc, r4]
001249bc  000094e5    ldr        r0, [r4]
001249c0  34519fe5    ldr        r5, [pc, #0x134]
001249c4  011040e2    sub        r1, r0, #1
001249c8  900100e0    mul        r0, r0, r1
001249cc  05509fe7    ldr        r5, [pc, r5]
001249d0  28619fe5    ldr        r6, [pc, #0x128]
001249d4  06608fe0    add        r6, pc, r6
001249d8  010010e3    tst        r0, #1
001249dc  1200000a    beq        #0x124a2c
001249e0  000095e5    ldr        r0, [r5]
001249e4  090050e3    cmp        r0, #9
001249e8  0f0000da    ble        #0x124a2c
001249ec  24019fe5    ldr        r0, [pc, #0x124]
001249f0  00008fe0    add        r0, pc, r0
001249f4  320712eb    bl         #0x5a66c4
001249f8  1c019fe5    ldr        r0, [pc, #0x11c]
001249fc  0130a0e3    mov        r3, #1
00124a00  18119fe5    ldr        r1, [pc, #0x118]
00124a04  18219fe5    ldr        r2, [pc, #0x118]
00124a08  00008fe0    add        r0, pc, r0
00124a0c  01108fe0    add        r1, pc, r1
00124a10  48008de8    stm        sp, {r3, r6}
00124a14  02208fe0    add        r2, pc, r2
00124a18  1830a0e3    mov        r3, #0x18
00124a1c  a855ffeb    bl         #0xfa0c4
00124a20  00019fe5    ldr        r0, [pc, #0x100]
00124a24  00008fe0    add        r0, pc, r0
00124a28  4ce911eb    bl         #0x59ef60
00124a2c  d0009fe5    ldr        r0, [pc, #0xd0]
00124a30  00008fe0    add        r0, pc, r0
00124a34  220712eb    bl         #0x5a66c4
00124a38  c8009fe5    ldr        r0, [pc, #0xc8]
00124a3c  0130a0e3    mov        r3, #1
00124a40  c4109fe5    ldr        r1, [pc, #0xc4]
00124a44  c4209fe5    ldr        r2, [pc, #0xc4]
00124a48  00008fe0    add        r0, pc, r0
00124a4c  01108fe0    add        r1, pc, r1
00124a50  48008de8    stm        sp, {r3, r6}
00124a54  02208fe0    add        r2, pc, r2
00124a58  1830a0e3    mov        r3, #0x18
00124a5c  9855ffeb    bl         #0xfa0c4
00124a60  ac009fe5    ldr        r0, [pc, #0xac]
00124a64  00008fe0    add        r0, pc, r0
00124a68  3ce911eb    bl         #0x59ef60
00124a6c  000094e5    ldr        r0, [r4]
00124a70  011040e2    sub        r1, r0, #1
00124a74  900101e0    mul        r1, r0, r1
00124a78  0000e0e3    mvn        r0, #0
00124a7c  010011e3    tst        r1, #1
00124a80  c9ffff0a    beq        #0x1249ac
00124a84  001095e5    ldr        r1, [r5]
00124a88  0a0051e3    cmp        r1, #0xa
00124a8c  c6ffffba    blt        #0x1249ac
00124a90  d5ffffea    b          #0x1249ec
00124a94  9c009fe5    ldr        r0, [pc, #0x9c]
00124a98  00008fe0    add        r0, pc, r0
00124a9c  080712eb    bl         #0x5a66c4
00124aa0  94009fe5    ldr        r0, [pc, #0x94]
00124aa4  0160a0e3    mov        r6, #1
00124aa8  90109fe5    ldr        r1, [pc, #0x90]
00124aac  90209fe5    ldr        r2, [pc, #0x90]
00124ab0  00008fe0    add        r0, pc, r0
00124ab4  8c309fe5    ldr        r3, [pc, #0x8c]
00124ab8  01108fe0    add        r1, pc, r1
00124abc  02208fe0    add        r2, pc, r2
00124ac0  00608de5    str        r6, [sp]
00124ac4  03308fe0    add        r3, pc, r3
00124ac8  04308de5    str        r3, [sp, #4]
00124acc  2430a0e3    mov        r3, #0x24
00124ad0  7b55ffeb    bl         #0xfa0c4
00124ad4  70009fe5    ldr        r0, [pc, #0x70]
00124ad8  00008fe0    add        r0, pc, r0
00124adc  1fe911eb    bl         #0x59ef60
00124ae0  0000e0e3    mvn        r0, #0
00124ae4  10d04be2    sub        sp, fp, #0x10
00124ae8  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
00124aec  30245300    subseq     r2, r3, r0, lsr r4
00124af0  1ca94c00    subeq      sl, ip, ip, lsl sb
00124af4  2fa94c00    subeq      sl, ip, pc, lsr #18
00124af8  6ca44b00    subeq      sl, fp, ip, ror #8
00124afc  cca94b00    subeq      sl, fp, ip, asr #19
00124b00  7fa84c00    subeq      sl, ip, pc, ror r8
00124b04  fc225300    ldrsheq    r2, [r3], #-0x2c
00124b08  f9a74c00    strdeq     sl, fp, [ip], #-0x79
00124b0c  bba74c00    strheq     sl, [ip], #-0x7b
00124b10  f4a74c00    strdeq     sl, fp, [ip], #-0x74
00124b14  09a84c00    subeq      sl, ip, sb, lsl #16
00124b18  3c235300    subseq     r2, r3, ip, lsr r3
00124b1c  39a84c00    subeq      sl, ip, sb, lsr r8
00124b20  fba74c00    strdeq     sl, fp, [ip], #-0x7b
00124b24  34a84c00    subeq      sl, ip, r4, lsr r8
00124b28  49a84c00    subeq      sl, ip, sb, asr #16
00124b2c  47a94c00    subeq      sl, ip, r7, asr #18
00124b30  2aa94c00    subeq      sl, ip, sl, lsr #18
00124b34  dfa84c00    ldrdeq     sl, fp, [ip], #-0x8f
00124b38  94225300    .byte      0x94, 0x22, 0x53, 0x00
00124b3c  91a74c00    umaaleq    sl, ip, r1, r7
00124b40  4fa74c00    subeq      sl, ip, pc, asr #14
00124b44  8ca74c00    subeq      sl, ip, ip, lsl #15
00124b48  d3a74c00    ldrdeq     sl, fp, [ip], #-0x73
00124b4c  95a74c00    umaaleq    sl, ip, r5, r7
00124b50  37a94c00    subeq      sl, ip, r7, lsr sb
00124b54  30a94c00    subeq      sl, ip, r0, lsr sb
00124b58  8c235300    subseq     r2, r3, ip, lsl #7
00124b5c  104c2de9    push       {r4, sl, fp, lr}
00124b60  08b08de2    add        fp, sp, #8
00124b64  01dc4de2    sub        sp, sp, #0x100
00124b68  30209fe5    ldr        r2, [pc, #0x30]
00124b6c  0d40a0e1    mov        r4, sp
00124b70  0030a0e1    mov        r3, r0
00124b74  0400a0e1    mov        r0, r4
00124b78  02208fe0    add        r2, pc, r2
00124b7c  011ca0e3    mov        r1, #0x100
00124b80  74ea11eb    bl         #0x59f558
00124b84  0400a0e1    mov        r0, r4
00124b88  0010a0e3    mov        r1, #0
00124b8c  5c0d12eb    bl         #0x5a8104
00124b90  100f6fe1    clz        r0, r0
00124b94  a002a0e1    lsr        r0, r0, #5
00124b98  08d04be2    sub        sp, fp, #8
00124b9c  108cbde8    pop        {r4, sl, fp, pc}
00124ba0  43a74c00    subeq      sl, ip, r3, asr #14
00124ba4  f04b2de9    push       {r4, r5, r6, r7, r8, sb, fp, lr}
00124ba8  18b08de2    add        fp, sp, #0x18
00124bac  11de4de2    sub        sp, sp, #0x110
00124bb0  0040a0e1    mov        r4, r0
00124bb4  60019fe5    ldr        r0, [pc, #0x160]
00124bb8  0150a0e1    mov        r5, r1
00124bbc  00008fe0    add        r0, pc, r0
00124bc0  500512eb    bl         #0x5a6108
00124bc4  54219fe5    ldr        r2, [pc, #0x154]
00124bc8  10608de2    add        r6, sp, #0x10
00124bcc  011ca0e3    mov        r1, #0x100
00124bd0  0430a0e1    mov        r3, r4
00124bd4  02208fe0    add        r2, pc, r2
00124bd8  0600a0e1    mov        r0, r6
00124bdc  5dea11eb    bl         #0x59f558
00124be0  3c119fe5    ldr        r1, [pc, #0x13c]
00124be4  0600a0e1    mov        r0, r6
00124be8  01108fe0    add        r1, pc, r1
00124bec  6fe611eb    bl         #0x59e5b0
00124bf0  000050e3    cmp        r0, #0
00124bf4  0e00000a    beq        #0x124c34
00124bf8  5c119fe5    ldr        r1, [pc, #0x15c]
00124bfc  000055e3    cmp        r5, #0
00124c00  01500013    movwne     r5, #1
00124c04  0060a0e1    mov        r6, r0
00124c08  01108fe0    add        r1, pc, r1
00124c0c  0520a0e1    mov        r2, r5
00124c10  90e611eb    bl         #0x59e658
00124c14  0600a0e1    mov        r0, r6
00124c18  19e511eb    bl         #0x59e084
00124c1c  3c019fe5    ldr        r0, [pc, #0x13c]
00124c20  00008fe0    add        r0, pc, r0
00124c24  a60612eb    bl         #0x5a66c4
00124c28  0000a0e3    mov        r0, #0
00124c2c  18d04be2    sub        sp, fp, #0x18
00124c30  f08bbde8    pop        {r4, r5, r6, r7, r8, sb, fp, pc}
00124c34  ec509fe5    ldr        r5, [pc, #0xec]
00124c38  05509fe7    ldr        r5, [pc, r5]
00124c3c  000095e5    ldr        r0, [r5]
00124c40  e4609fe5    ldr        r6, [pc, #0xe4]
00124c44  011040e2    sub        r1, r0, #1
00124c48  900100e0    mul        r0, r0, r1
00124c4c  06609fe7    ldr        r6, [pc, r6]
00124c50  d8709fe5    ldr        r7, [pc, #0xd8]
00124c54  07708fe0    add        r7, pc, r7
00124c58  010010e3    tst        r0, #1
00124c5c  1300000a    beq        #0x124cb0
00124c60  000096e5    ldr        r0, [r6]
00124c64  090050e3    cmp        r0, #9
00124c68  100000da    ble        #0x124cb0
00124c6c  d4009fe5    ldr        r0, [pc, #0xd4]
00124c70  00008fe0    add        r0, pc, r0
00124c74  920612eb    bl         #0x5a66c4
00124c78  cc009fe5    ldr        r0, [pc, #0xcc]
00124c7c  0130a0e3    mov        r3, #1
00124c80  c8109fe5    ldr        r1, [pc, #0xc8]
00124c84  c8209fe5    ldr        r2, [pc, #0xc8]
00124c88  00008fe0    add        r0, pc, r0
00124c8c  01108fe0    add        r1, pc, r1
00124c90  88008de8    stm        sp, {r3, r7}
00124c94  02208fe0    add        r2, pc, r2
00124c98  4830a0e3    mov        r3, #0x48
00124c9c  08408de5    str        r4, [sp, #8]
00124ca0  0755ffeb    bl         #0xfa0c4
00124ca4  ac009fe5    ldr        r0, [pc, #0xac]
00124ca8  00008fe0    add        r0, pc, r0
00124cac  abe811eb    bl         #0x59ef60
00124cb0  7c009fe5    ldr        r0, [pc, #0x7c]
00124cb4  00008fe0    add        r0, pc, r0
00124cb8  810612eb    bl         #0x5a66c4
00124cbc  74009fe5    ldr        r0, [pc, #0x74]
00124cc0  0130a0e3    mov        r3, #1
00124cc4  70109fe5    ldr        r1, [pc, #0x70]
00124cc8  70209fe5    ldr        r2, [pc, #0x70]
00124ccc  00008fe0    add        r0, pc, r0
00124cd0  01108fe0    add        r1, pc, r1
00124cd4  88008de8    stm        sp, {r3, r7}
00124cd8  02208fe0    add        r2, pc, r2
00124cdc  4830a0e3    mov        r3, #0x48
00124ce0  08408de5    str        r4, [sp, #8]
00124ce4  f654ffeb    bl         #0xfa0c4
00124ce8  54009fe5    ldr        r0, [pc, #0x54]
00124cec  00008fe0    add        r0, pc, r0
00124cf0  9ae811eb    bl         #0x59ef60
00124cf4  000095e5    ldr        r0, [r5]
00124cf8  011040e2    sub        r1, r0, #1
00124cfc  900101e0    mul        r1, r0, r1
00124d00  0000e0e3    mvn        r0, #0
00124d04  010011e3    tst        r1, #1
00124d08  c7ffff0a    beq        #0x124c2c
00124d0c  001096e5    ldr        r1, [r6]
00124d10  0a0051e3    cmp        r1, #0xa
00124d14  c4ffffba    blt        #0x124c2c
00124d18  d3ffffea    b          #0x124c6c
00124d1c  70215300    subseq     r2, r3, r0, ror r1
00124d20  fea64c00    strdeq     sl, fp, [ip], #-0x6e
00124d24  57a64c00    subeq      sl, ip, r7, asr r6
00124d28  28a84b00    subeq      sl, fp, r8, lsr #16
00124d2c  6ca24b00    subeq      sl, fp, ip, ror #4
00124d30  9ba64c00    umaaleq    sl, ip, fp, r6
00124d34  78205300    subseq     r2, r3, r8, ror r0
00124d38  75a54c00    subeq      sl, ip, r5, ror r5
00124d3c  37a54c00    subeq      sl, ip, r7, lsr r5
00124d40  70a54c00    subeq      sl, ip, r0, ror r5
00124d44  81a54c00    subeq      sl, ip, r1, lsl #11
00124d48  bc205300    ldrheq     r2, [r3], #-0xc
00124d4c  b9a54c00    strheq     sl, [ip], #-0x59
00124d50  7ba54c00    subeq      sl, ip, fp, ror r5
00124d54  b4a54c00    strheq     sl, [ip], #-0x54
00124d58  c5a54c00    subeq      sl, ip, r5, asr #11
00124d5c  08a74c00    subeq      sl, ip, r8, lsl #14
00124d60  0c215300    subseq     r2, r3, ip, lsl #2
00124d64  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
00124d68  1cb08de2    add        fp, sp, #0x1c
00124d6c  04d04de2    sub        sp, sp, #4
00124d70  b4919fe5    ldr        sb, [pc, #0x1b4]
00124d74  0050a0e1    mov        r5, r0
00124d78  0180a0e1    mov        r8, r1
00124d7c  09909fe7    ldr        sb, [pc, sb]
00124d80  000099e5    ldr        r0, [sb]
00124d84  a4a19fe5    ldr        sl, [pc, #0x1a4]
00124d88  011040e2    sub        r1, r0, #1
00124d8c  900100e0    mul        r0, r0, r1
00124d90  0aa09fe7    ldr        sl, [pc, sl]
00124d94  010010e3    tst        r0, #1
00124d98  0200000a    beq        #0x124da8
00124d9c  00009ae5    ldr        r0, [sl]
00124da0  090050e3    cmp        r0, #9
00124da4  1b0000ca    bgt        #0x124e18
00124da8  84019fe5    ldr        r0, [pc, #0x184]
00124dac  014c4de2    sub        r4, sp, #0x100
00124db0  00008fe0    add        r0, pc, r0
00124db4  04d0a0e1    mov        sp, r4
00124db8  08604de2    sub        r6, sp, #8
00124dbc  06d0a0e1    mov        sp, r6
00124dc0  10704de2    sub        r7, sp, #0x10
00124dc4  07d0a0e1    mov        sp, r7
00124dc8  ce0412eb    bl         #0x5a6108
00124dcc  64219fe5    ldr        r2, [pc, #0x164]
00124dd0  0400a0e1    mov        r0, r4
00124dd4  011ca0e3    mov        r1, #0x100
00124dd8  0530a0e1    mov        r3, r5
00124ddc  02208fe0    add        r2, pc, r2
00124de0  dce911eb    bl         #0x59f558
00124de4  50119fe5    ldr        r1, [pc, #0x150]
00124de8  0400a0e1    mov        r0, r4
00124dec  01108fe0    add        r1, pc, r1
00124df0  eee511eb    bl         #0x59e5b0
00124df4  0040a0e1    mov        r4, r0
00124df8  000099e5    ldr        r0, [sb]
00124dfc  011040e2    sub        r1, r0, #1
00124e00  900100e0    mul        r0, r0, r1
00124e04  010010e3    tst        r0, #1
00124e08  1400000a    beq        #0x124e60
00124e0c  00009ae5    ldr        r0, [sl]
00124e10  090050e3    cmp        r0, #9
00124e14  110000da    ble        #0x124e60
00124e18  44019fe5    ldr        r0, [pc, #0x144]
00124e1c  014c4de2    sub        r4, sp, #0x100
00124e20  00008fe0    add        r0, pc, r0
00124e24  04d0a0e1    mov        sp, r4
00124e28  08d04de2    sub        sp, sp, #8
00124e2c  10d04de2    sub        sp, sp, #0x10
00124e30  b40412eb    bl         #0x5a6108
00124e34  2c219fe5    ldr        r2, [pc, #0x12c]
00124e38  0400a0e1    mov        r0, r4
00124e3c  011ca0e3    mov        r1, #0x100
00124e40  0530a0e1    mov        r3, r5
00124e44  02208fe0    add        r2, pc, r2
00124e48  c2e911eb    bl         #0x59f558
00124e4c  18119fe5    ldr        r1, [pc, #0x118]
00124e50  0400a0e1    mov        r0, r4
00124e54  01108fe0    add        r1, pc, r1
00124e58  d4e511eb    bl         #0x59e5b0
00124e5c  d1ffffea    b          #0x124da8
00124e60  000054e3    cmp        r4, #0
00124e64  1900000a    beq        #0x124ed0
00124e68  e8109fe5    ldr        r1, [pc, #0xe8]
00124e6c  0400a0e1    mov        r0, r4
00124e70  0620a0e1    mov        r2, r6
00124e74  01108fe0    add        r1, pc, r1
00124e78  b6e611eb    bl         #0x59e958
00124e7c  d8109fe5    ldr        r1, [pc, #0xd8]
00124e80  0050a0e3    mov        r5, #0
00124e84  0000d6e5    ldrb       r0, [r6]
00124e88  0820a0e1    mov        r2, r8
00124e8c  01108fe0    add        r1, pc, r1
00124e90  0000c7e5    strb       r0, [r7]
00124e94  0700a0e1    mov        r0, r7
00124e98  0150c7e5    strb       r5, [r7, #1]
00124e9c  e9e911eb    bl         #0x59f648
00124ea0  0000d6e5    ldrb       r0, [r6]
00124ea4  300050e2    subs       r0, r0, #0x30
00124ea8  01000013    movwne     r0, #1
00124eac  000088e5    str        r0, [r8]
00124eb0  0400a0e1    mov        r0, r4
00124eb4  72e411eb    bl         #0x59e084
00124eb8  a0009fe5    ldr        r0, [pc, #0xa0]
00124ebc  00008fe0    add        r0, pc, r0
00124ec0  ff0512eb    bl         #0x5a66c4
00124ec4  0500a0e1    mov        r0, r5
00124ec8  1cd04be2    sub        sp, fp, #0x1c
00124ecc  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
00124ed0  68009fe5    ldr        r0, [pc, #0x68]
00124ed4  00008fe0    add        r0, pc, r0
00124ed8  f90512eb    bl         #0x5a66c4
00124edc  60009fe5    ldr        r0, [pc, #0x60]
00124ee0  60109fe5    ldr        r1, [pc, #0x60]
00124ee4  60209fe5    ldr        r2, [pc, #0x60]
00124ee8  00008fe0    add        r0, pc, r0
00124eec  5c309fe5    ldr        r3, [pc, #0x5c]
00124ef0  01108fe0    add        r1, pc, r1
00124ef4  02208fe0    add        r2, pc, r2
00124ef8  03308fe0    add        r3, pc, r3
00124efc  08d04de2    sub        sp, sp, #8
00124f00  0170a0e3    mov        r7, #1
00124f04  04308de5    str        r3, [sp, #4]
00124f08  5f30a0e3    mov        r3, #0x5f
00124f0c  00708de5    str        r7, [sp]
00124f10  6b54ffeb    bl         #0xfa0c4
00124f14  08d08de2    add        sp, sp, #8
00124f18  34009fe5    ldr        r0, [pc, #0x34]
00124f1c  00008fe0    add        r0, pc, r0
00124f20  0ee811eb    bl         #0x59ef60
00124f24  0050e0e3    mvn        r5, #0
00124f28  e5ffffea    b          #0x124ec4
00124f2c  689a4b00    subeq      sb, fp, r8, ror #20
00124f30  f8ad4b00    strdeq     sl, fp, [fp], #-0xd8
00124f34  7c1f5300    subseq     r1, r3, ip, ror pc
00124f38  f6a44c00    strdeq     sl, fp, [ip], #-0x46
00124f3c  27a54c00    subeq      sl, ip, r7, lsr #10
00124f40  581e5300    subseq     r1, r3, r8, asr lr
00124f44  59a34c00    subeq      sl, ip, sb, asr r3
00124f48  17a34c00    subeq      sl, ip, r7, lsl r3
00124f4c  54a34c00    subeq      sl, ip, r4, asr r3
00124f50  1da44c00    subeq      sl, ip, sp, lsl r4
00124f54  51a34c00    subeq      sl, ip, r1, asr r3
00124f58  b9a44c00    strheq     sl, [ip], #-0x49
00124f5c  e7a34c00    subeq      sl, ip, r7, ror #7
00124f60  701e5300    subseq     r1, r3, r0, ror lr
00124f64  0c1f5300    subseq     r1, r3, ip, lsl #30
00124f68  8ea44c00    subeq      sl, ip, lr, lsl #9
00124f6c  bfa44c00    strheq     sl, [ip], #-0x4f
00124f70  f04b2de9    push       {r4, r5, r6, r7, r8, sb, fp, lr}
00124f74  18b08de2    add        fp, sp, #0x18
00124f78  08d04de2    sub        sp, sp, #8
00124f7c  ec919fe5    ldr        sb, [pc, #0x1ec]
00124f80  0060a0e1    mov        r6, r0
00124f84  0140a0e1    mov        r4, r1
00124f88  09909fe7    ldr        sb, [pc, sb]
00124f8c  000099e5    ldr        r0, [sb]
00124f90  dc819fe5    ldr        r8, [pc, #0x1dc]
00124f94  011040e2    sub        r1, r0, #1
00124f98  900100e0    mul        r0, r0, r1
00124f9c  08809fe7    ldr        r8, [pc, r8]
00124fa0  010010e3    tst        r0, #1
00124fa4  0200000a    beq        #0x124fb4
00124fa8  000098e5    ldr        r0, [r8]
00124fac  090050e3    cmp        r0, #9
00124fb0  170000ca    bgt        #0x125014
00124fb4  bc019fe5    ldr        r0, [pc, #0x1bc]
00124fb8  015c4de2    sub        r5, sp, #0x100
00124fbc  00008fe0    add        r0, pc, r0
00124fc0  05d0a0e1    mov        sp, r5
00124fc4  4f0412eb    bl         #0x5a6108
00124fc8  ac219fe5    ldr        r2, [pc, #0x1ac]
00124fcc  0500a0e1    mov        r0, r5
00124fd0  011ca0e3    mov        r1, #0x100
00124fd4  0630a0e1    mov        r3, r6
00124fd8  02208fe0    add        r2, pc, r2
00124fdc  5de911eb    bl         #0x59f558
00124fe0  98119fe5    ldr        r1, [pc, #0x198]
00124fe4  0500a0e1    mov        r0, r5
00124fe8  01108fe0    add        r1, pc, r1
00124fec  6fe511eb    bl         #0x59e5b0
00124ff0  0050a0e1    mov        r5, r0
00124ff4  000099e5    ldr        r0, [sb]
00124ff8  011040e2    sub        r1, r0, #1
00124ffc  900100e0    mul        r0, r0, r1
00125000  010010e3    tst        r0, #1
00125004  1200000a    beq        #0x125054
00125008  000098e5    ldr        r0, [r8]
0012500c  090050e3    cmp        r0, #9
00125010  0f0000da    ble        #0x125054
00125014  8c019fe5    ldr        r0, [pc, #0x18c]
00125018  015c4de2    sub        r5, sp, #0x100
0012501c  00008fe0    add        r0, pc, r0
00125020  05d0a0e1    mov        sp, r5
00125024  370412eb    bl         #0x5a6108
00125028  7c219fe5    ldr        r2, [pc, #0x17c]
0012502c  0500a0e1    mov        r0, r5
00125030  011ca0e3    mov        r1, #0x100
00125034  0630a0e1    mov        r3, r6
00125038  02208fe0    add        r2, pc, r2
0012503c  45e911eb    bl         #0x59f558
00125040  68119fe5    ldr        r1, [pc, #0x168]
00125044  0500a0e1    mov        r0, r5
00125048  01108fe0    add        r1, pc, r1
0012504c  57e511eb    bl         #0x59e5b0
00125050  d7ffffea    b          #0x124fb4
00125054  000055e3    cmp        r5, #0
00125058  0c00000a    beq        #0x125090
0012505c  000099e5    ldr        r0, [sb]
00125060  34619fe5    ldr        r6, [pc, #0x134]
00125064  011040e2    sub        r1, r0, #1
00125068  30719fe5    ldr        r7, [pc, #0x130]
0012506c  06608fe0    add        r6, pc, r6
00125070  900100e0    mul        r0, r0, r1
00125074  07708fe0    add        r7, pc, r7
00125078  010010e3    tst        r0, #1
0012507c  1b00000a    beq        #0x1250f0
00125080  000098e5    ldr        r0, [r8]
00125084  090050e3    cmp        r0, #9
00125088  2b0000ca    bgt        #0x12513c
0012508c  170000ea    b          #0x1250f0
00125090  ec009fe5    ldr        r0, [pc, #0xec]
00125094  00008fe0    add        r0, pc, r0
00125098  890512eb    bl         #0x5a66c4
0012509c  e4009fe5    ldr        r0, [pc, #0xe4]
001250a0  e4109fe5    ldr        r1, [pc, #0xe4]
001250a4  e4209fe5    ldr        r2, [pc, #0xe4]
001250a8  00008fe0    add        r0, pc, r0
001250ac  e0309fe5    ldr        r3, [pc, #0xe0]
001250b0  01108fe0    add        r1, pc, r1
001250b4  02208fe0    add        r2, pc, r2
001250b8  03308fe0    add        r3, pc, r3
001250bc  08d04de2    sub        sp, sp, #8
001250c0  0170a0e3    mov        r7, #1
001250c4  04308de5    str        r3, [sp, #4]
001250c8  8830a0e3    mov        r3, #0x88
001250cc  00708de5    str        r7, [sp]
001250d0  fb53ffeb    bl         #0xfa0c4
001250d4  08d08de2    add        sp, sp, #8
001250d8  b8009fe5    ldr        r0, [pc, #0xb8]
001250dc  00008fe0    add        r0, pc, r0
001250e0  9ee711eb    bl         #0x59ef60
001250e4  0000e0e3    mvn        r0, #0
001250e8  18d04be2    sub        sp, fp, #0x18
001250ec  f08bbde8    pop        {r4, r5, r6, r7, r8, sb, fp, pc}
001250f0  000054e3    cmp        r4, #0
001250f4  0600a0e1    mov        r0, r6
001250f8  0700a001    moveq      r0, r7
001250fc  0510a0e1    mov        r1, r5
00125100  c4e511eb    bl         #0x59e818
00125104  0500a0e1    mov        r0, r5
00125108  dde311eb    bl         #0x59e084
0012510c  90009fe5    ldr        r0, [pc, #0x90]
00125110  00008fe0    add        r0, pc, r0
00125114  6a0512eb    bl         #0x5a66c4
00125118  000099e5    ldr        r0, [sb]
0012511c  011040e2    sub        r1, r0, #1
00125120  900101e0    mul        r1, r0, r1
00125124  0000a0e3    mov        r0, #0
00125128  010011e3    tst        r1, #1
0012512c  0d00000a    beq        #0x125168
00125130  001098e5    ldr        r1, [r8]
00125134  090051e3    cmp        r1, #9
00125138  0a0000da    ble        #0x125168
0012513c  000054e3    cmp        r4, #0
00125140  0600a0e1    mov        r0, r6
00125144  0700a001    moveq      r0, r7
00125148  0510a0e1    mov        r1, r5
0012514c  b1e511eb    bl         #0x59e818
00125150  0500a0e1    mov        r0, r5
00125154  cae311eb    bl         #0x59e084
00125158  54009fe5    ldr        r0, [pc, #0x54]
0012515c  00008fe0    add        r0, pc, r0
00125160  570512eb    bl         #0x5a66c4
00125164  e1ffffea    b          #0x1250f0
00125168  18d04be2    sub        sp, fp, #0x18
0012516c  f08bbde8    pop        {r4, r5, r6, r7, r8, sb, fp, pc}
00125170  54a54b00    subeq      sl, fp, r4, asr r5
00125174  7c9f4b00    subeq      sb, fp, ip, ror pc
00125178  701d5300    subseq     r1, r3, r0, ror sp
0012517c  9ea24c00    umaaleq    sl, ip, lr, r2
00125180  57a24c00    subeq      sl, ip, r7, asr r2
00125184  981c5300    .byte      0x98, 0x1c, 0x53, 0x00
00125188  99a14c00    umaaleq    sl, ip, sb, r1
0012518c  57a14c00    subeq      sl, ip, r7, asr r1
00125190  94a14c00    umaaleq    sl, ip, r4, r1
00125194  5da24c00    subeq      sl, ip, sp, asr r2
00125198  91a14c00    umaaleq    sl, ip, r1, r1
0012519c  4ba24c00    subeq      sl, ip, fp, asr #4
001251a0  40a24c00    subeq      sl, ip, r0, asr #4
001251a4  1c1c5300    subseq     r1, r3, ip, lsl ip
001251a8  101d5300    subseq     r1, r3, r0, lsl sp
001251ac  3ea24c00    subeq      sl, ip, lr, lsr r2
001251b0  f7a14c00    strdeq     sl, fp, [ip], #-0x17
001251b4  d01b5300    ldrsbeq    r1, [r3], #-0xb0
001251b8  f0482de9    push       {r4, r5, r6, r7, fp, lr}
001251bc  10b08de2    add        fp, sp, #0x10
001251c0  08d04de2    sub        sp, sp, #8
001251c4  0040a0e1    mov        r4, r0
001251c8  2c019fe5    ldr        r0, [pc, #0x12c]
001251cc  00008fe0    add        r0, pc, r0
001251d0  cc0312eb    bl         #0x5a6108
001251d4  24019fe5    ldr        r0, [pc, #0x124]
001251d8  24119fe5    ldr        r1, [pc, #0x124]
001251dc  00008fe0    add        r0, pc, r0
001251e0  01108fe0    add        r1, pc, r1
001251e4  f1e411eb    bl         #0x59e5b0
001251e8  000050e3    cmp        r0, #0
001251ec  0d00000a    beq        #0x125228
001251f0  28619fe5    ldr        r6, [pc, #0x128]
001251f4  0050a0e1    mov        r5, r0
001251f8  06609fe7    ldr        r6, [pc, r6]
001251fc  000096e5    ldr        r0, [r6]
00125200  1c719fe5    ldr        r7, [pc, #0x11c]
00125204  011040e2    sub        r1, r0, #1
00125208  900100e0    mul        r0, r0, r1
0012520c  07709fe7    ldr        r7, [pc, r7]
00125210  010010e3    tst        r0, #1
00125214  1800000a    beq        #0x12527c
00125218  000097e5    ldr        r0, [r7]
0012521c  090050e3    cmp        r0, #9
00125220  280000ca    bgt        #0x1252c8
00125224  140000ea    b          #0x12527c
00125228  d8009fe5    ldr        r0, [pc, #0xd8]
0012522c  00008fe0    add        r0, pc, r0
00125230  230512eb    bl         #0x5a66c4
00125234  d0009fe5    ldr        r0, [pc, #0xd0]
00125238  0170a0e3    mov        r7, #1
0012523c  cc109fe5    ldr        r1, [pc, #0xcc]
00125240  cc209fe5    ldr        r2, [pc, #0xcc]
00125244  00008fe0    add        r0, pc, r0
00125248  c8309fe5    ldr        r3, [pc, #0xc8]
0012524c  01108fe0    add        r1, pc, r1
00125250  02208fe0    add        r2, pc, r2
00125254  00708de5    str        r7, [sp]
00125258  03308fe0    add        r3, pc, r3
0012525c  04308de5    str        r3, [sp, #4]
00125260  a030a0e3    mov        r3, #0xa0
00125264  9653ffeb    bl         #0xfa0c4
00125268  ac009fe5    ldr        r0, [pc, #0xac]
0012526c  00008fe0    add        r0, pc, r0
00125270  3ae711eb    bl         #0x59ef60
00125274  0000e0e3    mvn        r0, #0
00125278  1d0000ea    b          #0x1252f4
0012527c  a4109fe5    ldr        r1, [pc, #0xa4]
00125280  0500a0e1    mov        r0, r5
00125284  0420a0e1    mov        r2, r4
00125288  01108fe0    add        r1, pc, r1
0012528c  f1e411eb    bl         #0x59e658
00125290  0500a0e1    mov        r0, r5
00125294  7ae311eb    bl         #0x59e084
00125298  8c009fe5    ldr        r0, [pc, #0x8c]
0012529c  00008fe0    add        r0, pc, r0
001252a0  070512eb    bl         #0x5a66c4
001252a4  000096e5    ldr        r0, [r6]
001252a8  011040e2    sub        r1, r0, #1
001252ac  900101e0    mul        r1, r0, r1
001252b0  0000a0e3    mov        r0, #0
001252b4  010011e3    tst        r1, #1
001252b8  0d00000a    beq        #0x1252f4
001252bc  001097e5    ldr        r1, [r7]
001252c0  090051e3    cmp        r1, #9
001252c4  0a0000da    ble        #0x1252f4
001252c8  60109fe5    ldr        r1, [pc, #0x60]
001252cc  0500a0e1    mov        r0, r5
001252d0  0420a0e1    mov        r2, r4
001252d4  01108fe0    add        r1, pc, r1
001252d8  dee411eb    bl         #0x59e658
001252dc  0500a0e1    mov        r0, r5
001252e0  67e311eb    bl         #0x59e084
001252e4  48009fe5    ldr        r0, [pc, #0x48]
001252e8  00008fe0    add        r0, pc, r0
001252ec  f40412eb    bl         #0x5a66c4
001252f0  e1ffffea    b          #0x12527c
001252f4  10d04be2    sub        sp, fp, #0x10
001252f8  f088bde8    pop        {r4, r5, r6, r7, fp, pc}
001252fc  601b5300    subseq     r1, r3, r0, ror #22
00125300  54a14c00    subeq      sl, ip, r4, asr r1
00125304  5fa04c00    subeq      sl, ip, pc, asr r0
00125308  001b5300    subseq     r1, r3, r0, lsl #22
0012530c  fd9f4c00    strdeq     sb, sl, [ip], #-0xfd
00125310  bb9f4c00    strheq     sb, [ip], #-0xfb
00125314  f89f4c00    strdeq     sb, sl, [ip], #-0xf8
00125318  f1a04c00    strdeq     sl, fp, [ip], #-1
0012531c  01a04c00    subeq      sl, ip, r1
00125320  30aa4b00    subeq      sl, fp, r0, lsr sl
00125324  3c944b00    subeq      sb, fp, ip, lsr r4
00125328  eb9f4c00    subeq      sb, ip, fp, ror #31
0012532c  901a5300    .byte      0x90, 0x1a, 0x53, 0x00
00125330  9f9f4c00    umaaleq    sb, ip, pc, pc
00125334  441a5300    subseq     r1, r3, r4, asr #20
