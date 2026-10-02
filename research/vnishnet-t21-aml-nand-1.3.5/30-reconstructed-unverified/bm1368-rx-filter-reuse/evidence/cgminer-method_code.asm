000e3bc4 30009fe5 ldr r0, [pc, #0x30]
000e3bc8 00009fe7 ldr r0, [pc, r0]
000e3bcc 2c109fe5 ldr r1, [pc, #0x2c]
000e3bd0 01109fe7 ldr r1, [pc, r1]
000e3bd4 002090e5 ldr r2, [r0]
000e3bd8 013042e2 sub r3, r2, #1
000e3bdc 920302e0 mul r2, r2, r3
000e3be0 010012e3 tst r2, #1
000e3be4 0200000a beq #0xe3bf4
000e3be8 002091e5 ldr r2, [r1]
000e3bec 090052e3 cmp r2, #9
000e3bf0 f7ffffca bgt #0xe3bd4
000e3bf4 4000a0e3 mov r0, #0x40
000e3bf8 1eff2fe1 bx lr
