0045a9f4  f0412de9    push       {r4, r5, r6, r7, r8, lr}
0045a9f8  0050a0e1    mov        r5, r0
0045a9fc  94009fe5    ldr        r0, [pc, #0x94]
0045aa00  0160a0e1    mov        r6, r1
0045aa04  0010d1e5    ldrb       r1, [r1]
0045aa08  00008fe0    add        r0, pc, r0
0045aa0c  431300eb    bl         #0x45f720
0045aa10  004050e2    subs       r4, r0, #0
0045aa14  0400001a    bne        #0x45aa2c
0045aa18  97deffeb    bl         #0x45247c
0045aa1c  1630a0e3    mov        r3, #0x16
0045aa20  003080e5    str        r3, [r0]
0045aa24  0400a0e1    mov        r0, r4
0045aa28  f081bde8    pop        {r4, r5, r6, r7, r8, pc}
0045aa2c  0600a0e1    mov        r0, r6
0045aa30  0570a0e3    mov        r7, #5
0045aa34  ab3600eb    bl         #0x4684e8
0045aa38  0040a0e1    mov        r4, r0
0045aa3c  b62100e3    movw       r2, #0x1b6
0045aa40  0500a0e1    mov        r0, r5
0045aa44  021884e3    orr        r1, r4, #0x20000
0045aa48  000000ef    svc        #0
0045aa4c  32e0ffeb    bl         #0x452b1c
0045aa50  005050e2    subs       r5, r0, #0
0045aa54  0040a0b3    movlt      r4, #0
0045aa58  f1ffffba    blt        #0x45aa24
0045aa5c  020714e3    tst        r4, #0x80000
0045aa60  0300000a    beq        #0x45aa74
0045aa64  dd70a0e3    mov        r7, #0xdd
0045aa68  0210a0e3    mov        r1, #2
0045aa6c  0120a0e3    mov        r2, #1
0045aa70  000000ef    svc        #0
0045aa74  0610a0e1    mov        r1, r6
0045aa78  0500a0e1    mov        r0, r5
0045aa7c  1b3600eb    bl         #0x4682f0
0045aa80  004050e2    subs       r4, r0, #0
0045aa84  e6ffff1a    bne        #0x45aa24
0045aa88  0670a0e3    mov        r7, #6
0045aa8c  0500a0e1    mov        r0, r5
0045aa90  000000ef    svc        #0
0045aa94  e2ffffea    b          #0x45aa24
