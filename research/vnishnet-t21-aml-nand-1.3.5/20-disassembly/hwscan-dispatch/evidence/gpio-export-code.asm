00111308  704c2de9    push       {r4, r5, r6, sl, fp, lr}
0011130c  10b08de2    add        fp, sp, #0x10
00111310  42df4de2    sub        sp, sp, #0x108
00111314  0050a0e1    mov        r5, r0
00111318  50019fe5    ldr        r0, [pc, #0x150]
0011131c  0140a0e1    mov        r4, r1
00111320  00008fe0    add        r0, pc, r0
00111324  5d420deb    bl         #0x461ca0
00111328  44019fe5    ldr        r0, [pc, #0x144]
0011132c  44119fe5    ldr        r1, [pc, #0x144]
00111330  00008fe0    add        r0, pc, r0
00111334  01108fe0    add        r1, pc, r1
00111338  ad250deb    bl         #0x45a9f4
0011133c  000050e3    cmp        r0, #0
00111340  2400000a    beq        #0x1113d8
00111344  48119fe5    ldr        r1, [pc, #0x148]
00111348  0520a0e1    mov        r2, r5
0011134c  0060a0e1    mov        r6, r0
00111350  01108fe0    add        r1, pc, r1
00111354  d0250deb    bl         #0x45aa9c
00111358  0600a0e1    mov        r0, r6
0011135c  aa240deb    bl         #0x45a60c
00111360  30219fe5    ldr        r2, [pc, #0x130]
00111364  08608de2    add        r6, sp, #8
00111368  011ca0e3    mov        r1, #0x100
0011136c  0530a0e1    mov        r3, r5
00111370  02208fe0    add        r2, pc, r2
00111374  0600a0e1    mov        r0, r6
00111378  e3280deb    bl         #0x45b70c
0011137c  18119fe5    ldr        r1, [pc, #0x118]
00111380  0600a0e1    mov        r0, r6
00111384  01108fe0    add        r1, pc, r1
00111388  99250deb    bl         #0x45a9f4
0011138c  000050e3    cmp        r0, #0
00111390  2000000a    beq        #0x111418
00111394  18119fe5    ldr        r1, [pc, #0x118]
00111398  0050a0e1    mov        r5, r0
0011139c  14019fe5    ldr        r0, [pc, #0x114]
001113a0  000054e3    cmp        r4, #0
001113a4  01108fe0    add        r1, pc, r1
001113a8  00008fe0    add        r0, pc, r0
001113ac  0100a011    movne      r0, r1
001113b0  0510a0e1    mov        r1, r5
001113b4  28260deb    bl         #0x45ac5c
001113b8  0500a0e1    mov        r0, r5
001113bc  92240deb    bl         #0x45a60c
001113c0  f4009fe5    ldr        r0, [pc, #0xf4]
001113c4  00008fe0    add        r0, pc, r0
001113c8  a3430deb    bl         #0x46225c
001113cc  0000a0e3    mov        r0, #0
001113d0  10d04be2    sub        sp, fp, #0x10
001113d4  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
001113d8  9c009fe5    ldr        r0, [pc, #0x9c]
001113dc  00008fe0    add        r0, pc, r0
001113e0  9d430deb    bl         #0x46225c
001113e4  94009fe5    ldr        r0, [pc, #0x94]
001113e8  0160a0e3    mov        r6, #1
001113ec  90109fe5    ldr        r1, [pc, #0x90]
001113f0  90209fe5    ldr        r2, [pc, #0x90]
001113f4  00008fe0    add        r0, pc, r0
001113f8  8c309fe5    ldr        r3, [pc, #0x8c]
001113fc  01108fe0    add        r1, pc, r1
00111400  02208fe0    add        r2, pc, r2
00111404  00608de5    str        r6, [sp]
00111408  03308fe0    add        r3, pc, r3
0011140c  04308de5    str        r3, [sp, #4]
00111410  1830a0e3    mov        r3, #0x18
00111414  0e0000ea    b          #0x111454
00111418  80009fe5    ldr        r0, [pc, #0x80]
0011141c  00008fe0    add        r0, pc, r0
00111420  8d430deb    bl         #0x46225c
00111424  78009fe5    ldr        r0, [pc, #0x78]
00111428  0160a0e3    mov        r6, #1
0011142c  74109fe5    ldr        r1, [pc, #0x74]
00111430  74209fe5    ldr        r2, [pc, #0x74]
00111434  00008fe0    add        r0, pc, r0
00111438  70309fe5    ldr        r3, [pc, #0x70]
0011143c  01108fe0    add        r1, pc, r1
00111440  02208fe0    add        r2, pc, r2
00111444  00608de5    str        r6, [sp]
00111448  03308fe0    add        r3, pc, r3
0011144c  04308de5    str        r3, [sp, #4]
00111450  2430a0e3    mov        r3, #0x24
00111454  95b6ffeb    bl         #0xfeeb0
00111458  30009fe5    ldr        r0, [pc, #0x30]
0011145c  00008fe0    add        r0, pc, r0
00111460  c4270deb    bl         #0x45b378
00111464  0000e0e3    mvn        r0, #0
00111468  10d04be2    sub        sp, fp, #0x10
0011146c  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
