0011187c  30482de9    push       {r4, r5, fp, lr}
00111880  08b08de2    add        fp, sp, #8
00111884  08d04de2    sub        sp, sp, #8
00111888  0040a0e1    mov        r4, r0
0011188c  ac009fe5    ldr        r0, [pc, #0xac]
00111890  00008fe0    add        r0, pc, r0
00111894  01410deb    bl         #0x461ca0
00111898  a4009fe5    ldr        r0, [pc, #0xa4]
0011189c  a4109fe5    ldr        r1, [pc, #0xa4]
001118a0  00008fe0    add        r0, pc, r0
001118a4  01108fe0    add        r1, pc, r1
001118a8  51240deb    bl         #0x45a9f4
001118ac  000050e3    cmp        r0, #0
001118b0  0c00000a    beq        #0x1118e8
001118b4  a8109fe5    ldr        r1, [pc, #0xa8]
001118b8  0420a0e1    mov        r2, r4
001118bc  0050a0e1    mov        r5, r0
001118c0  01108fe0    add        r1, pc, r1
001118c4  74240deb    bl         #0x45aa9c
001118c8  0500a0e1    mov        r0, r5
001118cc  4e230deb    bl         #0x45a60c
001118d0  90009fe5    ldr        r0, [pc, #0x90]
001118d4  00008fe0    add        r0, pc, r0
001118d8  5f420deb    bl         #0x46225c
001118dc  0000a0e3    mov        r0, #0
001118e0  08d04be2    sub        sp, fp, #8
001118e4  3088bde8    pop        {r4, r5, fp, pc}
001118e8  5c009fe5    ldr        r0, [pc, #0x5c]
001118ec  00008fe0    add        r0, pc, r0
001118f0  59420deb    bl         #0x46225c
001118f4  54009fe5    ldr        r0, [pc, #0x54]
001118f8  0150a0e3    mov        r5, #1
001118fc  50109fe5    ldr        r1, [pc, #0x50]
00111900  50209fe5    ldr        r2, [pc, #0x50]
00111904  00008fe0    add        r0, pc, r0
00111908  4c309fe5    ldr        r3, [pc, #0x4c]
0011190c  01108fe0    add        r1, pc, r1
00111910  02208fe0    add        r2, pc, r2
00111914  00508de5    str        r5, [sp]
00111918  03308fe0    add        r3, pc, r3
0011191c  04308de5    str        r3, [sp, #4]
00111920  a030a0e3    mov        r3, #0xa0
00111924  61b5ffeb    bl         #0xfeeb0
00111928  30009fe5    ldr        r0, [pc, #0x30]
0011192c  00008fe0    add        r0, pc, r0
00111930  90260deb    bl         #0x45b378
00111934  0000e0e3    mvn        r0, #0
00111938  08d04be2    sub        sp, fp, #8
0011193c  3088bde8    pop        {r4, r5, fp, pc}
