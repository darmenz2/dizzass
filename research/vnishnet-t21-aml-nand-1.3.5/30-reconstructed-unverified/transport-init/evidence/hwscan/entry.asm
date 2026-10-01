000ea69c  00482de9    push       {fp, lr}
000ea6a0  0db0a0e1    mov        fp, sp
000ea6a4  040050e3    cmp        r0, #4
000ea6a8  2e00008a    bhi        #0xea768
000ea6ac  10c19fe5    ldr        ip, [pc, #0x110]
000ea6b0  0cc09fe7    ldr        ip, [pc, ip]
000ea6b4  04e08fe2    add        lr, pc, #4
000ea6b8  00019ee7    ldr        r0, [lr, r0, lsl #2]
000ea6bc  00f08ee0    add        pc, lr, r0
