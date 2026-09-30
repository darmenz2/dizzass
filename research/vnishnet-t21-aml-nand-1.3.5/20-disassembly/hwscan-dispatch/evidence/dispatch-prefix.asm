000ff5f0  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000ff5f4  1cb08de2    add        fp, sp, #0x1c
000ff5f8  0cd04de2    sub        sp, sp, #0xc
000ff5fc  050050e3    cmp        r0, #5
000ff600  0c00001a    bne        #0xff638
000ff604  840e9fe5    ldr        r0, [pc, #0xe84]
000ff608  0140a0e3    mov        r4, #1
000ff60c  801e9fe5    ldr        r1, [pc, #0xe80]
000ff610  802e9fe5    ldr        r2, [pc, #0xe80]
000ff614  00008fe0    add        r0, pc, r0
000ff618  7c3e9fe5    ldr        r3, [pc, #0xe7c]
000ff61c  01108fe0    add        r1, pc, r1
000ff620  02208fe0    add        r2, pc, r2
000ff624  00408de5    str        r4, [sp]
000ff628  03308fe0    add        r3, pc, r3
000ff62c  04308de5    str        r3, [sp, #4]
000ff630  5d30a0e3    mov        r3, #0x5d
000ff634  0d0000ea    b          #0xff670
000ff638  080051e3    cmp        r1, #8
000ff63c  1000001a    bne        #0xff684
000ff640  580e9fe5    ldr        r0, [pc, #0xe58]
000ff644  0140a0e3    mov        r4, #1
000ff648  541e9fe5    ldr        r1, [pc, #0xe54]
000ff64c  542e9fe5    ldr        r2, [pc, #0xe54]
000ff650  00008fe0    add        r0, pc, r0
000ff654  503e9fe5    ldr        r3, [pc, #0xe50]
000ff658  01108fe0    add        r1, pc, r1
000ff65c  02208fe0    add        r2, pc, r2
000ff660  00408de5    str        r4, [sp]
000ff664  03308fe0    add        r3, pc, r3
000ff668  04308de5    str        r3, [sp, #4]
000ff66c  6230a0e3    mov        r3, #0x62
000ff670  0efeffeb    bl         #0xfeeb0
000ff674  0040e0e3    mvn        r4, #0
000ff678  0400a0e1    mov        r0, r4
000ff67c  1cd04be2    sub        sp, fp, #0x1c
000ff680  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
000ff684  24ee9fe5    ldr        lr, [pc, #0xe24]
000ff688  0040a0e1    mov        r4, r0
000ff68c  205e9fe5    ldr        r5, [pc, #0xe20]
000ff690  000054e3    cmp        r4, #0
000ff694  1c6e9fe5    ldr        r6, [pc, #0xe1c]
000ff698  0ee08fe0    add        lr, pc, lr
000ff69c  18ae9fe5    ldr        sl, [pc, #0xe18]
000ff6a0  05508fe0    add        r5, pc, r5
000ff6a4  148e9fe5    ldr        r8, [pc, #0xe14]
000ff6a8  06608fe0    add        r6, pc, r6
000ff6ac  109e9fe5    ldr        sb, [pc, #0xe10]
000ff6b0  0aa08fe0    add        sl, pc, sl
000ff6b4  0cce9fe5    ldr        ip, [pc, #0xe0c]
000ff6b8  08808fe0    add        r8, pc, r8
000ff6bc  087e9fe5    ldr        r7, [pc, #0xe08]
000ff6c0  09908fe0    add        sb, pc, sb
000ff6c4  00108ee5    str        r1, [lr]
000ff6c8  0cc08fe0    add        ip, pc, ip
000ff6cc  07708fe0    add        r7, pc, r7
000ff6d0  004085e5    str        r4, [r5]
000ff6d4  f41d9fe5    ldr        r1, [pc, #0xdf4]
000ff6d8  002087e5    str        r2, [r7]
000ff6dc  0030c6e5    strb       r3, [r6]
000ff6e0  01108fe0    add        r1, pc, r1
000ff6e4  e82d9fe5    ldr        r2, [pc, #0xde8]
000ff6e8  08009be5    ldr        r0, [fp, #8]
000ff6ec  02209fe7    ldr        r2, [pc, r2]
000ff6f0  e03d9fe5    ldr        r3, [pc, #0xde0]
000ff6f4  03309fe7    ldr        r3, [pc, r3]
000ff6f8  0230a001    moveq      r3, r2
000ff6fc  d82d9fe5    ldr        r2, [pc, #0xdd8]
000ff700  003081e5    str        r3, [r1]
000ff704  000054e3    cmp        r4, #0
000ff708  d01d9fe5    ldr        r1, [pc, #0xdd0]
000ff70c  02208fe0    add        r2, pc, r2
000ff710  01109fe7    ldr        r1, [pc, r1]
000ff714  c83d9fe5    ldr        r3, [pc, #0xdc8]
000ff718  03309fe7    ldr        r3, [pc, r3]
000ff71c  0130a001    moveq      r3, r1
000ff720  00308ae5    str        r3, [sl]
000ff724  bc1d9fe5    ldr        r1, [pc, #0xdbc]
000ff728  01109fe7    ldr        r1, [pc, r1]
000ff72c  b83d9fe5    ldr        r3, [pc, #0xdb8]
000ff730  03309fe7    ldr        r3, [pc, r3]
000ff734  0130a001    moveq      r3, r1
000ff738  000054e3    cmp        r4, #0
000ff73c  003088e5    str        r3, [r8]
000ff740  a81d9fe5    ldr        r1, [pc, #0xda8]
000ff744  01109fe7    ldr        r1, [pc, r1]
000ff748  a43d9fe5    ldr        r3, [pc, #0xda4]
000ff74c  03309fe7    ldr        r3, [pc, r3]
000ff750  0130a001    moveq      r3, r1
000ff754  003089e5    str        r3, [sb]
000ff758  981d9fe5    ldr        r1, [pc, #0xd98]
000ff75c  01109fe7    ldr        r1, [pc, r1]
000ff760  943d9fe5    ldr        r3, [pc, #0xd94]
000ff764  03309fe7    ldr        r3, [pc, r3]
000ff768  0130a001    moveq      r3, r1
000ff76c  000054e3    cmp        r4, #0
000ff770  00308ce5    str        r3, [ip]
000ff774  841d9fe5    ldr        r1, [pc, #0xd84]
000ff778  01109fe7    ldr        r1, [pc, r1]
000ff77c  803d9fe5    ldr        r3, [pc, #0xd80]
000ff780  03309fe7    ldr        r3, [pc, r3]
000ff784  0130a001    moveq      r3, r1
000ff788  040054e3    cmp        r4, #4
000ff78c  003082e5    str        r3, [r2]
000ff790  9800008a    bhi        #0xff9f8
000ff794  04108fe2    add        r1, pc, #4
000ff798  042191e7    ldr        r2, [r1, r4, lsl #2]
000ff79c  02f081e0    add        pc, r1, r2
