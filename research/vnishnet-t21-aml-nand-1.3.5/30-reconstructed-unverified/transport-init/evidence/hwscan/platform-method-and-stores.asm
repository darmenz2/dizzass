000ea6d4  ec009fe5    ldr        r0, [pc, #0xec]
000ea6d8  000052e3    cmp        r2, #0
000ea6dc  00009fe7    ldr        r0, [pc, r0]
000ea6e0  e4c09fe5    ldr        ip, [pc, #0xe4]
000ea6e4  0cc09fe7    ldr        ip, [pc, ip]
000ea6e8  00c0a011    movne      ip, r0
000ea6ec  070000ea    b          #0xea710
000ea6f0  d8c09fe5    ldr        ip, [pc, #0xd8]
000ea6f4  0cc09fe7    ldr        ip, [pc, ip]
000ea6f8  040000ea    b          #0xea710
000ea6fc  d0c09fe5    ldr        ip, [pc, #0xd0]
000ea700  0cc09fe7    ldr        ip, [pc, ip]
000ea704  010000ea    b          #0xea710
000ea708  c8c09fe5    ldr        ip, [pc, #0xc8]
000ea70c  0cc09fe7    ldr        ip, [pc, ip]
000ea710  c4009fe5    ldr        r0, [pc, #0xc4]
000ea714  070051e3    cmp        r1, #7
000ea718  00009fe7    ldr        r0, [pc, r0]
000ea71c  18c080e5    str        ip, [r0, #0x18]
000ea720  b8009fe5    ldr        r0, [pc, #0xb8]
000ea724  00009fe7    ldr        r0, [pc, r0]
000ea728  000083e5    str        r0, [r3]
000ea72c  0d00008a    bhi        #0xea768
000ea730  04008fe2    add        r0, pc, #4
000ea734  011190e7    ldr        r1, [r0, r1, lsl #2]
000ea738  01f080e0    add        pc, r0, r1
