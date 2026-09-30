0010dce8  704c2de9    push       {r4, r5, r6, sl, fp, lr}
0010dcec  10b08de2    add        fp, sp, #0x10
0010dcf0  10d04de2    sub        sp, sp, #0x10
0010dcf4  b0619fe5    ldr        r6, [pc, #0x1b0]
0010dcf8  0050a0e3    mov        r5, #0
0010dcfc  06608fe0    add        r6, pc, r6
0010dd00  030075e3    cmn        r5, #3
0010dd04  0800001a    bne        #0x10dd2c
0010dd08  0f0000ea    b          #0x10dd4c
0010dd0c  0400a0e1    mov        r0, r4
0010dd10  0010a0e3    mov        r1, #0
0010dd14  7b0d00eb    bl         #0x111308
0010dd18  015045e2    sub        r5, r5, #1
0010dd1c  000050e3    cmp        r0, #0
0010dd20  1f00001a    bne        #0x10dda4
0010dd24  030075e3    cmn        r5, #3
0010dd28  0700000a    beq        #0x10dd4c
0010dd2c  054116e7    ldr        r4, [r6, -r5, lsl #2]
0010dd30  0400a0e1    mov        r0, r4
0010dd34  e10d00eb    bl         #0x1114c0
0010dd38  000050e3    cmp        r0, #0
0010dd3c  f2ffff0a    beq        #0x10dd0c
0010dd40  0400a0e1    mov        r0, r4
0010dd44  cc0e00eb    bl         #0x11187c
0010dd48  efffffea    b          #0x10dd0c
0010dd4c  5c619fe5    ldr        r6, [pc, #0x15c]
0010dd50  0050a0e3    mov        r5, #0
0010dd54  06608fe0    add        r6, pc, r6
0010dd58  030075e3    cmn        r5, #3
0010dd5c  0800001a    bne        #0x10dd84
0010dd60  1d0000ea    b          #0x10dddc
0010dd64  0400a0e1    mov        r0, r4
0010dd68  0110a0e3    mov        r1, #1
0010dd6c  650d00eb    bl         #0x111308
0010dd70  015045e2    sub        r5, r5, #1
0010dd74  000050e3    cmp        r0, #0
0010dd78  2700001a    bne        #0x10de1c
0010dd7c  030075e3    cmn        r5, #3
0010dd80  1500000a    beq        #0x10dddc
0010dd84  054116e7    ldr        r4, [r6, -r5, lsl #2]
0010dd88  0400a0e1    mov        r0, r4
0010dd8c  cb0d00eb    bl         #0x1114c0
0010dd90  000050e3    cmp        r0, #0
0010dd94  f2ffff0a    beq        #0x10dd64
0010dd98  0400a0e1    mov        r0, r4
0010dd9c  b60e00eb    bl         #0x11187c
0010dda0  efffffea    b          #0x10dd64
0010dda4  18019fe5    ldr        r0, [pc, #0x118]
0010dda8  006065e2    rsb        r6, r5, #0
0010ddac  14119fe5    ldr        r1, [pc, #0x114]
0010ddb0  0150a0e3    mov        r5, #1
0010ddb4  10219fe5    ldr        r2, [pc, #0x110]
0010ddb8  00008fe0    add        r0, pc, r0
0010ddbc  0c319fe5    ldr        r3, [pc, #0x10c]
0010ddc0  01108fe0    add        r1, pc, r1
0010ddc4  02208fe0    add        r2, pc, r2
0010ddc8  00508de5    str        r5, [sp]
0010ddcc  03308fe0    add        r3, pc, r3
0010ddd0  48008de9    stmib      sp, {r3, r6}
0010ddd4  5330a0e3    mov        r3, #0x53
0010ddd8  1c0000ea    b          #0x10de50
0010dddc  56e0ffeb    bl         #0x105f3c
0010dde0  000050e3    cmp        r0, #0
0010dde4  1d00000a    beq        #0x10de60
0010dde8  e4009fe5    ldr        r0, [pc, #0xe4]
0010ddec  0160a0e3    mov        r6, #1
0010ddf0  e0109fe5    ldr        r1, [pc, #0xe0]
0010ddf4  e0209fe5    ldr        r2, [pc, #0xe0]
0010ddf8  00008fe0    add        r0, pc, r0
0010ddfc  dc309fe5    ldr        r3, [pc, #0xdc]
0010de00  01108fe0    add        r1, pc, r1
0010de04  02208fe0    add        r2, pc, r2
0010de08  00608de5    str        r6, [sp]
0010de0c  03308fe0    add        r3, pc, r3
0010de10  04308de5    str        r3, [sp, #4]
0010de14  6330a0e3    mov        r3, #0x63
0010de18  0c0000ea    b          #0x10de50
0010de1c  90009fe5    ldr        r0, [pc, #0x90]
0010de20  006065e2    rsb        r6, r5, #0
0010de24  8c109fe5    ldr        r1, [pc, #0x8c]
0010de28  0150a0e3    mov        r5, #1
0010de2c  88209fe5    ldr        r2, [pc, #0x88]
0010de30  00008fe0    add        r0, pc, r0
0010de34  84309fe5    ldr        r3, [pc, #0x84]
0010de38  01108fe0    add        r1, pc, r1
0010de3c  02208fe0    add        r2, pc, r2
0010de40  00508de5    str        r5, [sp]
0010de44  03308fe0    add        r3, pc, r3
0010de48  48008de9    stmib      sp, {r3, r6}
0010de4c  5d30a0e3    mov        r3, #0x5d
0010de50  16c4ffeb    bl         #0xfeeb0
0010de54  0000e0e3    mvn        r0, #0
0010de58  10d04be2    sub        sp, fp, #0x10
0010de5c  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
0010de60  291400eb    bl         #0x112f0c
0010de64  000050e3    cmp        r0, #0
0010de68  0c00000a    beq        #0x10dea0
0010de6c  70009fe5    ldr        r0, [pc, #0x70]
0010de70  0160a0e3    mov        r6, #1
0010de74  6c109fe5    ldr        r1, [pc, #0x6c]
0010de78  6c209fe5    ldr        r2, [pc, #0x6c]
0010de7c  00008fe0    add        r0, pc, r0
0010de80  68309fe5    ldr        r3, [pc, #0x68]
0010de84  01108fe0    add        r1, pc, r1
0010de88  02208fe0    add        r2, pc, r2
0010de8c  00608de5    str        r6, [sp]
0010de90  03308fe0    add        r3, pc, r3
0010de94  04308de5    str        r3, [sp, #4]
0010de98  6830a0e3    mov        r3, #0x68
0010de9c  ebffffea    b          #0x10de50
0010dea0  0000a0e3    mov        r0, #0
0010dea4  10d04be2    sub        sp, fp, #0x10
0010dea8  708cbde8    pop        {r4, r5, r6, sl, fp, pc}
