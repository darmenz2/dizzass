00022424  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
00022428  34d04de2    sub        sp, sp, #0x34
0002242c  c4039fe5    ldr        r0, [pc, #0x3c4]
00022430  00008fe0    add        r0, pc, r0
00022434  0c8090e5    ldr        r8, [r0, #0xc]
00022438  000058e3    cmp        r8, #0
0002243c  0500000a    beq        #0x22458
00022440  089090e5    ldr        sb, [r0, #8]
00022444  aa1a0ae3    movw       r1, #0xaaaa
00022448  aa1a40e3    movt       r1, #0xaaa
0002244c  010059e1    cmp        sb, r1
00022450  7d00009a    bls        #0x2264c
00022454  c4b7ffeb    bl         #0x1036c
00022458  0440a0e3    mov        r4, #4
0002245c  0070a0e3    mov        r7, #0
00022460  0000a0e3    mov        r0, #0
00022464  08008de5    str        r0, [sp, #8]
00022468  870087e0    add        r0, r7, r7, lsl #1
0002246c  04408de5    str        r4, [sp, #4]
00022470  000184e0    add        r0, r4, r0, lsl #2
00022474  00408de5    str        r4, [sp]
00022478  0c008de5    str        r0, [sp, #0xc]
0002247c  0d00a0e1    mov        r0, sp
00022480  862000eb    bl         #0x2a6a0
00022484  010010e3    tst        r0, #1
00022488  3100000a    beq        #0x22554
0002248c  0140a0e1    mov        r4, r1
00022490  04009de5    ldr        r0, [sp, #4]
00022494  0c109de5    ldr        r1, [sp, #0xc]
00022498  ab9a0ae3    movw       sb, #0xaaab
0002249c  aa9a4ae3    movt       sb, #0xaaaa
000224a0  000041e0    sub        r0, r1, r0
000224a4  2001a0e1    lsr        r0, r0, #2
000224a8  900900e0    mul        r0, r0, sb
000224ac  030050e3    cmp        r0, #3
000224b0  0300a093    movls      r0, #3
000224b4  017080e2    add        r7, r0, #1
000224b8  0761a0e1    lsl        r6, r7, #2
000224bc  0600a0e1    mov        r0, r6
000224c0  a2c210eb    bl         #0x452f50
000224c4  000050e3    cmp        r0, #0
000224c8  a500000a    beq        #0x22764
000224cc  0050a0e1    mov        r5, r0
000224d0  0f009de8    ldm        sp, {r0, r1, r2, r3}
000224d4  20608de2    add        r6, sp, #0x20
000224d8  14808de2    add        r8, sp, #0x14
000224dc  004085e5    str        r4, [r5]
000224e0  0140a0e3    mov        r4, #1
000224e4  20c08de2    add        ip, sp, #0x20
000224e8  1c408de5    str        r4, [sp, #0x1c]
000224ec  18508de5    str        r5, [sp, #0x18]
000224f0  14708de5    str        r7, [sp, #0x14]
000224f4  0f008ce8    stm        ip, {r0, r1, r2, r3}
000224f8  020000ea    b          #0x22508
000224fc  047185e7    str        r7, [r5, r4, lsl #2]
00022500  014084e2    add        r4, r4, #1
00022504  1c408de5    str        r4, [sp, #0x1c]
00022508  0600a0e1    mov        r0, r6
0002250c  632000eb    bl         #0x2a6a0
00022510  010050e3    cmp        r0, #1
00022514  2b00001a    bne        #0x225c8
00022518  14009de5    ldr        r0, [sp, #0x14]
0002251c  0170a0e1    mov        r7, r1
00022520  000054e1    cmp        r4, r0
00022524  f4ffff1a    bne        #0x224fc
00022528  24009de5    ldr        r0, [sp, #0x24]
0002252c  2c109de5    ldr        r1, [sp, #0x2c]
00022530  000041e0    sub        r0, r1, r0
00022534  2001a0e1    lsr        r0, r0, #2
00022538  900900e0    mul        r0, r0, sb
0002253c  012080e2    add        r2, r0, #1
00022540  0800a0e1    mov        r0, r8
00022544  0410a0e1    mov        r1, r4
00022548  77b8ffeb    bl         #0x1072c
0002254c  18509de5    ldr        r5, [sp, #0x18]
00022550  e9ffffea    b          #0x224fc
00022554  04009de5    ldr        r0, [sp, #4]
00022558  0c109de5    ldr        r1, [sp, #0xc]
0002255c  001051e0    subs       r1, r1, r0
00022560  0e00000a    beq        #0x225a0
00022564  ab2a0ae3    movw       r2, #0xaaab
00022568  045080e2    add        r5, r0, #4
0002256c  aa2a4ae3    movt       r2, #0xaaaa
00022570  911282e0    umull      r1, r2, r1, r2
00022574  a241a0e1    lsr        r4, r2, #3
00022578  020000ea    b          #0x22588
0002257c  0c5085e2    add        r5, r5, #0xc
00022580  014054e2    subs       r4, r4, #1
00022584  0500000a    beq        #0x225a0
00022588  040015e5    ldr        r0, [r5, #-4]
0002258c  000050e3    cmp        r0, #0
00022590  f9ffff0a    beq        #0x2257c
00022594  000095e5    ldr        r0, [r5]
00022598  34c210eb    bl         #0x452e70
0002259c  f6ffffea    b          #0x2257c
000225a0  08009de5    ldr        r0, [sp, #8]
000225a4  000050e3    cmp        r0, #0
000225a8  0100000a    beq        #0x225b4
000225ac  00009de5    ldr        r0, [sp]
000225b0  2ec210eb    bl         #0x452e70
000225b4  0000a0e3    mov        r0, #0
000225b8  0410a0e3    mov        r1, #4
000225bc  34d08de2    add        sp, sp, #0x34
000225c0  f04fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000225c4  d60f03ea    b          #0xe6524
000225c8  24009de5    ldr        r0, [sp, #0x24]
000225cc  2c109de5    ldr        r1, [sp, #0x2c]
000225d0  001051e0    subs       r1, r1, r0
000225d4  0c00000a    beq        #0x2260c
000225d8  911982e0    umull      r1, r2, r1, sb
000225dc  046080e2    add        r6, r0, #4
000225e0  a251a0e1    lsr        r5, r2, #3
000225e4  020000ea    b          #0x225f4
000225e8  0c6086e2    add        r6, r6, #0xc
000225ec  015055e2    subs       r5, r5, #1
000225f0  0500000a    beq        #0x2260c
000225f4  040016e5    ldr        r0, [r6, #-4]
000225f8  000050e3    cmp        r0, #0
000225fc  f9ffff0a    beq        #0x225e8
00022600  000096e5    ldr        r0, [r6]
00022604  19c210eb    bl         #0x452e70
00022608  f6ffffea    b          #0x225e8
0002260c  28009de5    ldr        r0, [sp, #0x28]
00022610  000050e3    cmp        r0, #0
00022614  0100000a    beq        #0x22620
00022618  20009de5    ldr        r0, [sp, #0x20]
0002261c  13c210eb    bl         #0x452e70
00022620  18509de5    ldr        r5, [sp, #0x18]
00022624  0400a0e1    mov        r0, r4
00022628  14609de5    ldr        r6, [sp, #0x14]
0002262c  0510a0e1    mov        r1, r5
00022630  bb0f03eb    bl         #0xe6524
00022634  000056e3    cmp        r6, #0
00022638  1200000a    beq        #0x22688
0002263c  0500a0e1    mov        r0, r5
00022640  34d08de2    add        sp, sp, #0x34
00022644  f04fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, lr}
00022648  08c210ea    b          #0x452e70
0002264c  890089e0    add        r0, sb, sb, lsl #1
00022650  0070a0e3    mov        r7, #0
00022654  0061b0e1    lsls       r6, r0, #2
00022658  0c00000a    beq        #0x22690
0002265c  0600a0e1    mov        r0, r6
00022660  3ac210eb    bl         #0x452f50
00022664  000050e3    cmp        r0, #0
00022668  4100000a    beq        #0x22774
0002266c  0040a0e1    mov        r4, r0
00022670  0900a0e1    mov        r0, sb
00022674  20108de2    add        r1, sp, #0x20
00022678  000059e3    cmp        sb, #0
0002267c  910081e8    stm        r1, {r0, r4, r7}
00022680  0800001a    bne        #0x226a8
00022684  76ffffea    b          #0x22464
00022688  34d08de2    add        sp, sp, #0x34
0002268c  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
00022690  0440a0e3    mov        r4, #4
00022694  0000a0e3    mov        r0, #0
00022698  20108de2    add        r1, sp, #0x20
0002269c  000059e3    cmp        sb, #0
000226a0  910081e8    stm        r1, {r0, r4, r7}
000226a4  6effff0a    beq        #0x22464
000226a8  0070a0e3    mov        r7, #0
000226ac  0050a0e3    mov        r5, #0
000226b0  080000ea    b          #0x226d8
000226b4  24409de5    ldr        r4, [sp, #0x24]
000226b8  0400a0e1    mov        r0, r4
000226bc  017087e2    add        r7, r7, #1
000226c0  05b0a0e7    str        fp, [r0, r5]!
000226c4  0c5085e2    add        r5, r5, #0xc
000226c8  070059e1    cmp        sb, r7
000226cc  f4a0c0e1    strd       sl, fp, [r0, #4]
000226d0  28708de5    str        r7, [sp, #0x28]
000226d4  1a00000a    beq        #0x22744
000226d8  076198e7    ldr        r6, [r8, r7, lsl #2]
000226dc  000056e3    cmp        r6, #0
000226e0  1800000a    beq        #0x22748
000226e4  0600a0e1    mov        r0, r6
000226e8  b4f410eb    bl         #0x45f9c0
000226ec  00b0a0e1    mov        fp, r0
000226f0  000050e3    cmp        r0, #0
000226f4  0b00000a    beq        #0x22728
000226f8  0b00a0e1    mov        r0, fp
000226fc  13c210eb    bl         #0x452f50
00022700  000050e3    cmp        r0, #0
00022704  1200000a    beq        #0x22754
00022708  0610a0e1    mov        r1, r6
0002270c  0b20a0e1    mov        r2, fp
00022710  00a0a0e1    mov        sl, r0
00022714  4cf210eb    bl         #0x45f04c
00022718  20009de5    ldr        r0, [sp, #0x20]
0002271c  000057e1    cmp        r7, r0
00022720  e4ffff1a    bne        #0x226b8
00022724  030000ea    b          #0x22738
00022728  01a0a0e3    mov        sl, #1
0002272c  20009de5    ldr        r0, [sp, #0x20]
00022730  000057e1    cmp        r7, r0
00022734  dfffff1a    bne        #0x226b8
00022738  20008de2    add        r0, sp, #0x20
0002273c  91c2ffeb    bl         #0x13188
00022740  dbffffea    b          #0x226b4
00022744  0970a0e1    mov        r7, sb
00022748  20009de5    ldr        r0, [sp, #0x20]
0002274c  24409de5    ldr        r4, [sp, #0x24]
00022750  43ffffea    b          #0x22464
00022754  0100a0e3    mov        r0, #1
00022758  0b10a0e1    mov        r1, fp
0002275c  bdb6ffeb    bl         #0x10258
00022760  020000ea    b          #0x22770
00022764  0400a0e3    mov        r0, #4
00022768  0610a0e1    mov        r1, r6
0002276c  b9b6ffeb    bl         #0x10258
00022770  fedeffe7    trap       
00022774  0400a0e3    mov        r0, #4
00022778  0610a0e1    mov        r1, r6
0002277c  b5b6ffeb    bl         #0x10258
00022780  ffffffea    b          #0x22784
00022784  0040a0e1    mov        r4, r0
00022788  0d00a0e1    mov        r0, sp
0002278c  772000eb    bl         #0x2a970
00022790  0400a0e1    mov        r0, r4
00022794  4a2e11eb    bl         #0x46e0c4
00022798  0040a0e1    mov        r4, r0
0002279c  00005be3    cmp        fp, #0
000227a0  0300000a    beq        #0x227b4
000227a4  0a00a0e1    mov        r0, sl
000227a8  b0c110eb    bl         #0x452e70
000227ac  000000ea    b          #0x227b4
000227b0  0040a0e1    mov        r4, r0
000227b4  20008de2    add        r0, sp, #0x20
000227b8  2f0903eb    bl         #0xe4c7c
000227bc  0400a0e1    mov        r0, r4
000227c0  3f2e11eb    bl         #0x46e0c4
000227c4  ffffffea    b          #0x227c8
000227c8  0040a0e1    mov        r4, r0
000227cc  20008de2    add        r0, sp, #0x20
000227d0  662000eb    bl         #0x2a970
000227d4  14009de5    ldr        r0, [sp, #0x14]
000227d8  000050e3    cmp        r0, #0
000227dc  0100001a    bne        #0x227e8
000227e0  0400a0e1    mov        r0, r4
000227e4  362e11eb    bl         #0x46e0c4
000227e8  18009de5    ldr        r0, [sp, #0x18]
000227ec  9fc110eb    bl         #0x452e70
000227f0  0400a0e1    mov        r0, r4
000227f4  322e11eb    bl         #0x46e0c4
