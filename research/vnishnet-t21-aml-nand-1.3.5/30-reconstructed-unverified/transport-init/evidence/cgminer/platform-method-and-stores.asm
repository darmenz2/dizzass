000d2220  c8c29fe5    ldr        ip, [pc, #0x2c8]
000d2224  0cc09fe7    ldr        ip, [pc, ip]
000d2228  00309ce5    ldr        r3, [ip]
000d222c  015043e2    sub        r5, r3, #1
000d2230  930503e0    mul        r3, r3, r5
000d2234  010013e3    tst        r3, #1
000d2238  00309ce5    ldr        r3, [ip]
000d223c  000052e3    cmp        r2, #0
000d2240  ac629fe5    ldr        r6, [pc, #0x2ac]
000d2244  015043e2    sub        r5, r3, #1
000d2248  930505e0    mul        r5, r3, r5
000d224c  06609fe7    ldr        r6, [pc, r6]
000d2250  a0329fe5    ldr        r3, [pc, #0x2a0]
000d2254  03309fe7    ldr        r3, [pc, r3]
000d2258  0630a011    movne      r3, r6
000d225c  010015e3    tst        r5, #1
000d2260  1900000a    beq        #0xd22cc
000d2264  90629fe5    ldr        r6, [pc, #0x290]
000d2268  06609fe7    ldr        r6, [pc, r6]
000d226c  006096e5    ldr        r6, [r6]
000d2270  0a0056e3    cmp        r6, #0xa
000d2274  efffffaa    bge        #0xd2238
000d2278  130000ea    b          #0xd22cc
000d227c  7cc29fe5    ldr        ip, [pc, #0x27c]
000d2280  0cc09fe7    ldr        ip, [pc, ip]
000d2284  78629fe5    ldr        r6, [pc, #0x278]
000d2288  06609fe7    ldr        r6, [pc, r6]
000d228c  74329fe5    ldr        r3, [pc, #0x274]
000d2290  03309fe7    ldr        r3, [pc, r3]
000d2294  00509ce5    ldr        r5, [ip]
000d2298  012045e2    sub        r2, r5, #1
000d229c  950202e0    mul        r2, r5, r2
000d22a0  010012e3    tst        r2, #1
000d22a4  0800000a    beq        #0xd22cc
000d22a8  002096e5    ldr        r2, [r6]
000d22ac  0a0052e3    cmp        r2, #0xa
000d22b0  f7ffffaa    bge        #0xd2294
000d22b4  040000ea    b          #0xd22cc
000d22b8  4c329fe5    ldr        r3, [pc, #0x24c]
000d22bc  03309fe7    ldr        r3, [pc, r3]
000d22c0  010000ea    b          #0xd22cc
000d22c4  44329fe5    ldr        r3, [pc, #0x244]
000d22c8  03309fe7    ldr        r3, [pc, r3]
000d22cc  40229fe5    ldr        r2, [pc, #0x240]
000d22d0  070051e3    cmp        r1, #7
000d22d4  02209fe7    ldr        r2, [pc, r2]
000d22d8  183082e5    str        r3, [r2, #0x18]
000d22dc  34229fe5    ldr        r2, [pc, #0x234]
000d22e0  02209fe7    ldr        r2, [pc, r2]
000d22e4  002084e5    str        r2, [r4]
000d22e8  7e00008a    bhi        #0xd24e8
000d22ec  04008fe2    add        r0, pc, #4
000d22f0  011190e7    ldr        r1, [r0, r1, lsl #2]
000d22f4  01f080e0    add        pc, r0, r1
