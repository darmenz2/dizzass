0046409c  80402de9    push       {r7, lr}
004640a0  0030a0e1    mov        r3, r0
004640a4  f870a0e3    mov        r7, #0xf8
004640a8  000000ef    svc        #0
004640ac  0170a0e3    mov        r7, #1
004640b0  0300a0e1    mov        r0, r3
004640b4  fbffffea    b          #0x4640a8
