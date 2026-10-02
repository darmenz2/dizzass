000e3c04 f04b2de9 push {r4, r5, r6, r7, r8, sb, fp, lr}
000e3c08 18b08de2 add fp, sp, #0x18
000e3c0c 10d04de2 sub sp, sp, #0x10
000e3c10 0040a0e1 mov r4, r0
000e3c14 180090e5 ldr r0, [r0, #0x18]
000e3c18 0c208de2 add r2, sp, #0xc
000e3c1c 0180a0e1 mov r8, r1
000e3c20 a810a0e3 mov r1, #0xa8
000e3c24 578d00eb bl #0x107188
000e3c28 0050e0e3 mvn r5, #0
000e3c2c 000050e3 cmp r0, #0
000e3c30 6300001a bne #0xe3dc4
000e3c34 180094e5 ldr r0, [r4, #0x18]
000e3c38 08208de2 add r2, sp, #8
000e3c3c 1810a0e3 mov r1, #0x18
000e3c40 508d00eb bl #0x107188
000e3c44 000050e3 cmp r0, #0
000e3c48 5d00001a bne #0xe3dc4
000e3c4c 7c919fe5 ldr sb, [pc, #0x17c]
000e3c50 09909fe7 ldr sb, [pc, sb]
000e3c54 000099e5 ldr r0, [sb]
000e3c58 011040e2 sub r1, r0, #1
000e3c5c 900100e0 mul r0, r0, r1
000e3c60 010010e3 tst r0, #1
000e3c64 000099e5 ldr r0, [sb]
000e3c68 64619fe5 ldr r6, [pc, #0x164]
000e3c6c 011040e2 sub r1, r0, #1
000e3c70 900101e0 mul r1, r0, r1
000e3c74 06609fe7 ldr r6, [pc, r6]
000e3c78 0c009de5 ldr r0, [sp, #0xc]
000e3c7c 010011e3 tst r1, #1
000e3c80 0200000a beq #0xe3c90
000e3c84 001096e5 ldr r1, [r6]
000e3c88 090051e3 cmp r1, #9
000e3c8c f4ffffca bgt #0xe3c64
000e3c90 000058e3 cmp r8, #0
000e3c94 0800000a beq #0xe3cbc
000e3c98 001099e5 ldr r1, [sb]
000e3c9c 012041e2 sub r2, r1, #1
000e3ca0 910201e0 mul r1, r1, r2
000e3ca4 010011e3 tst r1, #1
000e3ca8 0900000a beq #0xe3cd4
000e3cac 001096e5 ldr r1, [r6]
000e3cb0 090051e3 cmp r1, #9
000e3cb4 130000ca bgt #0xe3d08
000e3cb8 050000ea b #0xe3cd4
000e3cbc 08209de5 ldr r2, [sp, #8]
000e3cc0 f010c0e3 bic r1, r0, #0xf0
000e3cc4 0c108de5 str r1, [sp, #0xc]
000e3cc8 0f0882e3 orr r0, r2, #0xf0000
000e3ccc ff2480e3 orr r2, r0, #0xff000000
000e3cd0 100000ea b #0xe3d18
000e3cd4 001099e5 ldr r1, [sb]
000e3cd8 003096e5 ldr r3, [r6]
000e3cdc 012041e2 sub r2, r1, #1
000e3ce0 910207e0 mul r7, r1, r2
000e3ce4 08209de5 ldr r2, [sp, #8]
000e3ce8 0f1100e3 movw r1, #0x10f
000e3cec 011080e1 orr r1, r0, r1
000e3cf0 0f26c2e3 bic r2, r2, #0xf00000
000e3cf4 0c108de5 str r1, [sp, #0xc]
000e3cf8 010017e3 tst r7, #1
000e3cfc 0500000a beq #0xe3d18
000e3d00 0a0053e3 cmp r3, #0xa
000e3d04 030000ba blt #0xe3d18
000e3d08 0f1100e3 movw r1, #0x10f
000e3d0c 011080e1 orr r1, r0, r1
000e3d10 0c108de5 str r1, [sp, #0xc]
000e3d14 eeffffea b #0xe3cd4
000e3d18 08208de5 str r2, [sp, #8]
000e3d1c 0400a0e1 mov r0, r4
000e3d20 00108de5 str r1, [sp]
000e3d24 0110a0e3 mov r1, #1
000e3d28 0020a0e3 mov r2, #0
000e3d2c a830a0e3 mov r3, #0xa8
000e3d30 4f0300eb bl #0xe4a74
000e3d34 000050e3 cmp r0, #0
000e3d38 2100001a bne #0xe3dc4
000e3d3c 000099e5 ldr r0, [sb]
000e3d40 011040e2 sub r1, r0, #1
000e3d44 900100e0 mul r0, r0, r1
000e3d48 010010e3 tst r0, #1
000e3d4c 0200000a beq #0xe3d5c
000e3d50 000096e5 ldr r0, [r6]
000e3d54 090050e3 cmp r0, #9
000e3d58 110000ca bgt #0xe3da4
000e3d5c 08009de5 ldr r0, [sp, #8]
000e3d60 0110a0e3 mov r1, #1
000e3d64 00008de5 str r0, [sp]
000e3d68 0400a0e1 mov r0, r4
000e3d6c 0020a0e3 mov r2, #0
000e3d70 1830a0e3 mov r3, #0x18
000e3d74 3e0300eb bl #0xe4a74
000e3d78 0050a0e1 mov r5, r0
000e3d7c 000099e5 ldr r0, [sb]
000e3d80 000055e3 cmp r5, #0
000e3d84 011040e2 sub r1, r0, #1
000e3d88 0050e013 mvnne r5, #0
000e3d8c 900100e0 mul r0, r0, r1
000e3d90 010010e3 tst r0, #1
000e3d94 0a00000a beq #0xe3dc4
000e3d98 000096e5 ldr r0, [r6]
000e3d9c 090050e3 cmp r0, #9
000e3da0 070000da ble #0xe3dc4
000e3da4 08009de5 ldr r0, [sp, #8]
000e3da8 0110a0e3 mov r1, #1
000e3dac 00008de5 str r0, [sp]
000e3db0 0400a0e1 mov r0, r4
000e3db4 0020a0e3 mov r2, #0
000e3db8 1830a0e3 mov r3, #0x18
000e3dbc 2c0300eb bl #0xe4a74
000e3dc0 e5ffffea b #0xe3d5c
000e3dc4 0500a0e1 mov r0, r5
000e3dc8 18d04be2 sub sp, fp, #0x18
000e3dcc f08bbde8 pop {r4, r5, r6, r7, r8, sb, fp, pc}
