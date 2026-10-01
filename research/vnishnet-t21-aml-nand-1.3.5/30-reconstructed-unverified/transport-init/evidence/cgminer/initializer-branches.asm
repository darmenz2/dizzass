000d2318  fc519fe5    ldr        r5, [pc, #0x1fc]
000d231c  05509fe7    ldr        r5, [pc, r5]
000d2320  000095e5    ldr        r0, [r5]
000d2324  f4619fe5    ldr        r6, [pc, #0x1f4]
000d2328  011040e2    sub        r1, r0, #1
000d232c  900100e0    mul        r0, r0, r1
000d2330  06609fe7    ldr        r6, [pc, r6]
000d2334  010010e3    tst        r0, #1
000d2338  3600000a    beq        #0xd2418
000d233c  000096e5    ldr        r0, [r6]
000d2340  090050e3    cmp        r0, #9
000d2344  3d0000ca    bgt        #0xd2440
000d2348  320000ea    b          #0xd2418
000d234c  d0519fe5    ldr        r5, [pc, #0x1d0]
000d2350  05509fe7    ldr        r5, [pc, r5]
000d2354  000095e5    ldr        r0, [r5]
000d2358  c8619fe5    ldr        r6, [pc, #0x1c8]
000d235c  011040e2    sub        r1, r0, #1
000d2360  900100e0    mul        r0, r0, r1
000d2364  06609fe7    ldr        r6, [pc, r6]
000d2368  010010e3    tst        r0, #1
000d236c  3600000a    beq        #0xd244c
000d2370  000096e5    ldr        r0, [r6]
000d2374  090050e3    cmp        r0, #9
000d2378  3d0000ca    bgt        #0xd2474
000d237c  320000ea    b          #0xd244c
000d2380  0400a0e1    mov        r0, r4
000d2384  704cbde8    pop        {r4, r5, r6, sl, fp, lr}
000d2388  0e6100ea    b          #0xea7c8
000d238c  98519fe5    ldr        r5, [pc, #0x198]
000d2390  05509fe7    ldr        r5, [pc, r5]
000d2394  000095e5    ldr        r0, [r5]
000d2398  90619fe5    ldr        r6, [pc, #0x190]
000d239c  011040e2    sub        r1, r0, #1
000d23a0  900100e0    mul        r0, r0, r1
000d23a4  06609fe7    ldr        r6, [pc, r6]
000d23a8  010010e3    tst        r0, #1
000d23ac  3300000a    beq        #0xd2480
000d23b0  000096e5    ldr        r0, [r6]
000d23b4  090050e3    cmp        r0, #9
000d23b8  3a0000ca    bgt        #0xd24a8
000d23bc  2f0000ea    b          #0xd2480
000d23c0  0400a0e1    mov        r0, r4
000d23c4  704cbde8    pop        {r4, r5, r6, sl, fp, lr}
000d23c8  203c00ea    b          #0xe1450
000d23cc  60519fe5    ldr        r5, [pc, #0x160]
000d23d0  05509fe7    ldr        r5, [pc, r5]
000d23d4  000095e5    ldr        r0, [r5]
000d23d8  58619fe5    ldr        r6, [pc, #0x158]
000d23dc  011040e2    sub        r1, r0, #1
000d23e0  900100e0    mul        r0, r0, r1
000d23e4  06609fe7    ldr        r6, [pc, r6]
000d23e8  010010e3    tst        r0, #1
000d23ec  3000000a    beq        #0xd24b4
000d23f0  000096e5    ldr        r0, [r6]
000d23f4  090050e3    cmp        r0, #9
000d23f8  370000ca    bgt        #0xd24dc
000d23fc  2c0000ea    b          #0xd24b4
000d2400  0400a0e1    mov        r0, r4
000d2404  704cbde8    pop        {r4, r5, r6, sl, fp, lr}
000d2408  547800ea    b          #0xf0560
000d240c  0400a0e1    mov        r0, r4
000d2410  704cbde8    pop        {r4, r5, r6, sl, fp, lr}
000d2414  0b8800ea    b          #0xf4448
000d2418  0400a0e1    mov        r0, r4
000d241c  650200eb    bl         #0xd2db8
000d2420  001095e5    ldr        r1, [r5]
000d2424  012041e2    sub        r2, r1, #1
000d2428  910201e0    mul        r1, r1, r2
000d242c  010011e3    tst        r1, #1
000d2430  2c00000a    beq        #0xd24e8
000d2434  001096e5    ldr        r1, [r6]
000d2438  0a0051e3    cmp        r1, #0xa
000d243c  290000ba    blt        #0xd24e8
000d2440  0400a0e1    mov        r0, r4
000d2444  5b0200eb    bl         #0xd2db8
000d2448  f2ffffea    b          #0xd2418
000d244c  0400a0e1    mov        r0, r4
000d2450  081a00eb    bl         #0xd8c78
000d2454  001095e5    ldr        r1, [r5]
000d2458  012041e2    sub        r2, r1, #1
000d245c  910201e0    mul        r1, r1, r2
000d2460  010011e3    tst        r1, #1
000d2464  1f00000a    beq        #0xd24e8
000d2468  001096e5    ldr        r1, [r6]
000d246c  0a0051e3    cmp        r1, #0xa
000d2470  1c0000ba    blt        #0xd24e8
000d2474  0400a0e1    mov        r0, r4
000d2478  fe1900eb    bl         #0xd8c78
000d247c  f2ffffea    b          #0xd244c
000d2480  0400a0e1    mov        r0, r4
000d2484  d52900eb    bl         #0xdcbe0
000d2488  001095e5    ldr        r1, [r5]
000d248c  012041e2    sub        r2, r1, #1
000d2490  910201e0    mul        r1, r1, r2
000d2494  010011e3    tst        r1, #1
000d2498  1200000a    beq        #0xd24e8
000d249c  001096e5    ldr        r1, [r6]
000d24a0  0a0051e3    cmp        r1, #0xa
000d24a4  0f0000ba    blt        #0xd24e8
000d24a8  0400a0e1    mov        r0, r4
000d24ac  cb2900eb    bl         #0xdcbe0
000d24b0  f2ffffea    b          #0xd2480
000d24b4  0400a0e1    mov        r0, r4
000d24b8  0a4f00eb    bl         #0xe60e8
000d24bc  001095e5    ldr        r1, [r5]
000d24c0  012041e2    sub        r2, r1, #1
000d24c4  910201e0    mul        r1, r1, r2
000d24c8  010011e3    tst        r1, #1
000d24cc  0500000a    beq        #0xd24e8
000d24d0  001096e5    ldr        r1, [r6]
000d24d4  0a0051e3    cmp        r1, #0xa
000d24d8  020000ba    blt        #0xd24e8
000d24dc  0400a0e1    mov        r0, r4
000d24e0  004f00eb    bl         #0xe60e8
000d24e4  f2ffffea    b          #0xd24b4
000d24e8  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
