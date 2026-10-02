000e3a1c f0482de9 push {r4, r5, r6, r7, fp, lr}
000e3a20 10b08de2 add fp, sp, #0x10
000e3a24 10d04de2 sub sp, sp, #0x10
000e3a28 0040a0e3 mov r4, #0
000e3a2c 0050a0e1 mov r5, r0
000e3a30 0c408de5 str r4, [sp, #0xc]
000e3a34 0c208de2 add r2, sp, #0xc
000e3a38 180090e5 ldr r0, [r0, #0x18]
000e3a3c 0160a0e1 mov r6, r1
000e3a40 5810a0e3 mov r1, #0x58
000e3a44 cf8d00eb bl #0x107188
000e3a48 000050e3 cmp r0, #0
000e3a4c 0e00000a beq #0xe3a8c
000e3a50 30519fe5 ldr r5, [pc, #0x130]
000e3a54 05509fe7 ldr r5, [pc, r5]
000e3a58 000095e5 ldr r0, [r5]
000e3a5c 28619fe5 ldr r6, [pc, #0x128]
000e3a60 011040e2 sub r1, r0, #1
000e3a64 900100e0 mul r0, r0, r1
000e3a68 06609fe7 ldr r6, [pc, r6]
000e3a6c 1c719fe5 ldr r7, [pc, #0x11c]
000e3a70 07708fe0 add r7, pc, r7
000e3a74 010010e3 tst r0, #1
000e3a78 2100000a beq #0xe3b04
000e3a7c 000096e5 ldr r0, [r6]
000e3a80 090050e3 cmp r0, #9
000e3a84 310000ca bgt #0xe3b50
000e3a88 1d0000ea b #0xe3b04
000e3a8c 0c009de5 ldr r0, [sp, #0xc]
000e3a90 0f1006e2 and r1, r6, #0xf
000e3a94 0020a0e3 mov r2, #0
000e3a98 5830a0e3 mov r3, #0x58
000e3a9c 0f0ac0e3 bic r0, r0, #0xf000
000e3aa0 0160a0e3 mov r6, #1
000e3aa4 010680e1 orr r0, r0, r1, lsl #12
000e3aa8 0c008de5 str r0, [sp, #0xc]
000e3aac 00008de5 str r0, [sp]
000e3ab0 0500a0e1 mov r0, r5
000e3ab4 0110a0e3 mov r1, #1
000e3ab8 ed0300eb bl #0xe4a74
000e3abc 000050e3 cmp r0, #0
000e3ac0 2d00000a beq #0xe3b7c
000e3ac4 e0009fe5 ldr r0, [pc, #0xe0]
000e3ac8 e0109fe5 ldr r1, [pc, #0xe0]
000e3acc e0209fe5 ldr r2, [pc, #0xe0]
000e3ad0 00008fe0 add r0, pc, r0
000e3ad4 183095e5 ldr r3, [r5, #0x18]
000e3ad8 01108fe0 add r1, pc, r1
000e3adc d4709fe5 ldr r7, [pc, #0xd4]
000e3ae0 02208fe0 add r2, pc, r2
000e3ae4 013083e2 add r3, r3, #1
000e3ae8 07708fe0 add r7, pc, r7
000e3aec c0008de8 stm sp, {r6, r7}
000e3af0 08308de5 str r3, [sp, #8]
000e3af4 853200e3 movw r3, #0x285
000e3af8 715900eb bl #0xfa0c4
000e3afc 0040e0e3 mvn r4, #0
000e3b00 1d0000ea b #0xe3b7c
000e3b04 88009fe5 ldr r0, [pc, #0x88]
000e3b08 0130a0e3 mov r3, #1
000e3b0c 84109fe5 ldr r1, [pc, #0x84]
000e3b10 84209fe5 ldr r2, [pc, #0x84]
000e3b14 00008fe0 add r0, pc, r0
000e3b18 01108fe0 add r1, pc, r1
000e3b1c 88008de8 stm sp, {r3, r7}
000e3b20 02208fe0 add r2, pc, r2
000e3b24 7b3200e3 movw r3, #0x27b
000e3b28 655900eb bl #0xfa0c4
000e3b2c 000095e5 ldr r0, [r5]
000e3b30 0040e0e3 mvn r4, #0
000e3b34 011040e2 sub r1, r0, #1
000e3b38 900100e0 mul r0, r0, r1
000e3b3c 010010e3 tst r0, #1
000e3b40 0d00000a beq #0xe3b7c
000e3b44 000096e5 ldr r0, [r6]
000e3b48 0a0050e3 cmp r0, #0xa
000e3b4c 0a0000ba blt #0xe3b7c
000e3b50 48009fe5 ldr r0, [pc, #0x48]
000e3b54 0130a0e3 mov r3, #1
000e3b58 44109fe5 ldr r1, [pc, #0x44]
000e3b5c 44209fe5 ldr r2, [pc, #0x44]
000e3b60 00008fe0 add r0, pc, r0
000e3b64 01108fe0 add r1, pc, r1
000e3b68 88008de8 stm sp, {r3, r7}
000e3b6c 02208fe0 add r2, pc, r2
000e3b70 7b3200e3 movw r3, #0x27b
000e3b74 525900eb bl #0xfa0c4
000e3b78 e1ffffea b #0xe3b04
000e3b7c 0400a0e1 mov r0, r4
000e3b80 10d04be2 sub sp, fp, #0x10
000e3b84 f088bde8 pop {r4, r5, r6, r7, fp, pc}
