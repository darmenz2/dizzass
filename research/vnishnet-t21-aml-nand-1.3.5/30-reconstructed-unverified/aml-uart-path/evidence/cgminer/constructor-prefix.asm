0011c2b8  00482de9    push       {fp, lr}
0011c2bc  c8c29fe5    ldr        ip, [pc, #0x2c8]
0011c2c0  0cc09fe7    ldr        ip, [pc, ip]
0011c2c4  00009ce5    ldr        r0, [ip]
0011c2c8  011040e2    sub        r1, r0, #1
0011c2cc  900100e0    mul        r0, r0, r1
0011c2d0  010010e3    tst        r0, #1
0011c2d4  00009ce5    ldr        r0, [ip]
0011c2d8  b0e29fe5    ldr        lr, [pc, #0x2b0]
0011c2dc  011040e2    sub        r1, r0, #1
0011c2e0  900100e0    mul        r0, r0, r1
0011c2e4  0ee09fe7    ldr        lr, [pc, lr]
0011c2e8  010010e3    tst        r0, #1
0011c2ec  0200000a    beq        #0x11c2fc
0011c2f0  00009ee5    ldr        r0, [lr]
0011c2f4  090050e3    cmp        r0, #9
0011c2f8  f5ffffca    bgt        #0x11c2d4
0011c2fc  0020a0e3    mov        r2, #0
0011c300  000052e3    cmp        r2, #0
0011c304  0700001a    bne        #0x11c328
0011c308  84329fe5    ldr        r3, [pc, #0x284]
0011c30c  03308fe0    add        r3, pc, r3
0011c310  0200d3e7    ldrb       r0, [r3, r2]
0011c314  a30020e2    eor        r0, r0, #0xa3
0011c318  0200c3e7    strb       r0, [r3, r2]
0011c31c  012082e2    add        r2, r2, #1
0011c320  070052e3    cmp        r2, #7
0011c324  f9ffff1a    bne        #0x11c310
0011c328  0020a0e3    mov        r2, #0
0011c32c  000052e3    cmp        r2, #0
0011c330  0700001a    bne        #0x11c354
0011c334  5c329fe5    ldr        r3, [pc, #0x25c]
0011c338  03308fe0    add        r3, pc, r3
0011c33c  0200d3e7    ldrb       r0, [r3, r2]
0011c340  880020e2    eor        r0, r0, #0x88
0011c344  0200c3e7    strb       r0, [r3, r2]
0011c348  012082e2    add        r2, r2, #1
0011c34c  290052e3    cmp        r2, #0x29
0011c350  f9ffff1a    bne        #0x11c33c
0011c354  0020a0e3    mov        r2, #0
0011c358  000052e3    cmp        r2, #0
0011c35c  0700001a    bne        #0x11c380
0011c360  34329fe5    ldr        r3, [pc, #0x234]
0011c364  03308fe0    add        r3, pc, r3
0011c368  0200d3e7    ldrb       r0, [r3, r2]
0011c36c  c00020e2    eor        r0, r0, #0xc0
0011c370  0200c3e7    strb       r0, [r3, r2]
0011c374  012082e2    add        r2, r2, #1
0011c378  0b0052e3    cmp        r2, #0xb
0011c37c  f9ffff1a    bne        #0x11c368
0011c380  0020a0e3    mov        r2, #0
0011c384  000052e3    cmp        r2, #0
0011c388  0700001a    bne        #0x11c3ac
0011c38c  0c329fe5    ldr        r3, [pc, #0x20c]
0011c390  03308fe0    add        r3, pc, r3
0011c394  0200d3e7    ldrb       r0, [r3, r2]
0011c398  f60020e2    eor        r0, r0, #0xf6
0011c39c  0200c3e7    strb       r0, [r3, r2]
0011c3a0  012082e2    add        r2, r2, #1
0011c3a4  2a0052e3    cmp        r2, #0x2a
0011c3a8  f9ffff1a    bne        #0x11c394
0011c3ac  0020a0e3    mov        r2, #0
0011c3b0  000052e3    cmp        r2, #0
0011c3b4  0700001a    bne        #0x11c3d8
0011c3b8  e4319fe5    ldr        r3, [pc, #0x1e4]
0011c3bc  03308fe0    add        r3, pc, r3
0011c3c0  0200d3e7    ldrb       r0, [r3, r2]
0011c3c4  560020e2    eor        r0, r0, #0x56
0011c3c8  0200c3e7    strb       r0, [r3, r2]
0011c3cc  012082e2    add        r2, r2, #1
0011c3d0  2b0052e3    cmp        r2, #0x2b
0011c3d4  f9ffff1a    bne        #0x11c3c0
0011c3d8  00009ce5    ldr        r0, [ip]
0011c3dc  012040e2    sub        r2, r0, #1
0011c3e0  900200e0    mul        r0, r0, r2
0011c3e4  010010e3    tst        r0, #1
0011c3e8  00009ce5    ldr        r0, [ip]
0011c3ec  012040e2    sub        r2, r0, #1
0011c3f0  900200e0    mul        r0, r0, r2
0011c3f4  010010e3    tst        r0, #1
0011c3f8  0200000a    beq        #0x11c408
0011c3fc  00009ee5    ldr        r0, [lr]
0011c400  090050e3    cmp        r0, #9
0011c404  f7ffffca    bgt        #0x11c3e8
0011c408  0020a0e3    mov        r2, #0
0011c40c  000052e3    cmp        r2, #0
0011c410  0700001a    bne        #0x11c434
0011c414  8c319fe5    ldr        r3, [pc, #0x18c]
0011c418  03308fe0    add        r3, pc, r3
0011c41c  0200d3e7    ldrb       r0, [r3, r2]
0011c420  e30020e2    eor        r0, r0, #0xe3
0011c424  0200c3e7    strb       r0, [r3, r2]
0011c428  012082e2    add        r2, r2, #1
0011c42c  190052e3    cmp        r2, #0x19
0011c430  f9ffff1a    bne        #0x11c41c
0011c434  00009ce5    ldr        r0, [ip]
0011c438  012040e2    sub        r2, r0, #1
0011c43c  900200e0    mul        r0, r0, r2
0011c440  010010e3    tst        r0, #1
0011c444  00009ce5    ldr        r0, [ip]
0011c448  012040e2    sub        r2, r0, #1
0011c44c  900200e0    mul        r0, r0, r2
0011c450  010010e3    tst        r0, #1
0011c454  0200000a    beq        #0x11c464
0011c458  00009ee5    ldr        r0, [lr]
0011c45c  090050e3    cmp        r0, #9
0011c460  f7ffffca    bgt        #0x11c444
0011c464  0020a0e3    mov        r2, #0
0011c468  000052e3    cmp        r2, #0
0011c46c  0700001a    bne        #0x11c490
0011c470  34319fe5    ldr        r3, [pc, #0x134]
0011c474  03308fe0    add        r3, pc, r3
0011c478  0200d3e7    ldrb       r0, [r3, r2]
0011c47c  940020e2    eor        r0, r0, #0x94
0011c480  0200c3e7    strb       r0, [r3, r2]
0011c484  012082e2    add        r2, r2, #1
0011c488  1b0052e3    cmp        r2, #0x1b
0011c48c  f9ffff1a    bne        #0x11c478
0011c490  0020a0e3    mov        r2, #0
0011c494  000052e3    cmp        r2, #0
0011c498  0700001a    bne        #0x11c4bc
0011c49c  0c319fe5    ldr        r3, [pc, #0x10c]
0011c4a0  03308fe0    add        r3, pc, r3
0011c4a4  0200d3e7    ldrb       r0, [r3, r2]
0011c4a8  560020e2    eor        r0, r0, #0x56
0011c4ac  0200c3e7    strb       r0, [r3, r2]
0011c4b0  012082e2    add        r2, r2, #1
0011c4b4  160052e3    cmp        r2, #0x16
0011c4b8  f9ffff1a    bne        #0x11c4a4
