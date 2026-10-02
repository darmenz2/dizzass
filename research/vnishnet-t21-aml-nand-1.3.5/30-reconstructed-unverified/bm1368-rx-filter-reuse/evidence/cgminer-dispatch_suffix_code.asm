000d2ab8 3048bde8 pop {r4, r5, fp, lr}
000d2abc c20a00ea b #0xd55cc
000d2ac0 0000e0e3 mvn r0, #0
000d2ac4 280000ea b #0xd2b6c
000d2ac8 24419fe5 ldr r4, [pc, #0x124]
000d2acc 04409fe7 ldr r4, [pc, r4]
000d2ad0 000094e5 ldr r0, [r4]
000d2ad4 1c519fe5 ldr r5, [pc, #0x11c]
000d2ad8 011040e2 sub r1, r0, #1
000d2adc 900100e0 mul r0, r0, r1
000d2ae0 05509fe7 ldr r5, [pc, r5]
000d2ae4 010010e3 tst r0, #1
000d2ae8 2000000a beq #0xd2b70
000d2aec 000095e5 ldr r0, [r5]
000d2af0 090050e3 cmp r0, #9
000d2af4 260000ca bgt #0xd2b94
000d2af8 1c0000ea b #0xd2b70
000d2afc 3048bde8 pop {r4, r5, fp, lr}
000d2b00 076900ea b #0xecf24
000d2b04 f0409fe5 ldr r4, [pc, #0xf0]
000d2b08 04409fe7 ldr r4, [pc, r4]
000d2b0c 000094e5 ldr r0, [r4]
000d2b10 e8509fe5 ldr r5, [pc, #0xe8]
000d2b14 011040e2 sub r1, r0, #1
000d2b18 900100e0 mul r0, r0, r1
000d2b1c 05509fe7 ldr r5, [pc, r5]
000d2b20 010010e3 tst r0, #1
000d2b24 1c00000a beq #0xd2b9c
000d2b28 000095e5 ldr r0, [r5]
000d2b2c 090050e3 cmp r0, #9
000d2b30 220000ca bgt #0xd2bc0
000d2b34 180000ea b #0xd2b9c
000d2b38 c4409fe5 ldr r4, [pc, #0xc4]
000d2b3c 04409fe7 ldr r4, [pc, r4]
000d2b40 000094e5 ldr r0, [r4]
000d2b44 bc509fe5 ldr r5, [pc, #0xbc]
000d2b48 011040e2 sub r1, r0, #1
000d2b4c 900100e0 mul r0, r0, r1
000d2b50 05509fe7 ldr r5, [pc, r5]
000d2b54 010010e3 tst r0, #1
000d2b58 1a00000a beq #0xd2bc8
000d2b5c 000095e5 ldr r0, [r5]
000d2b60 090050e3 cmp r0, #9
000d2b64 200000ca bgt #0xd2bec
000d2b68 160000ea b #0xd2bc8
000d2b6c 3088bde8 pop {r4, r5, fp, pc}
000d2b70 3b2000eb bl #0xdac64
000d2b74 001094e5 ldr r1, [r4]
000d2b78 012041e2 sub r2, r1, #1
000d2b7c 910201e0 mul r1, r1, r2
000d2b80 010011e3 tst r1, #1
000d2b84 f8ffff0a beq #0xd2b6c
000d2b88 001095e5 ldr r1, [r5]
000d2b8c 0a0051e3 cmp r1, #0xa
000d2b90 f5ffffba blt #0xd2b6c
000d2b94 322000eb bl #0xdac64
000d2b98 f4ffffea b #0xd2b70
000d2b9c 8d3100eb bl #0xdf1d8
000d2ba0 001094e5 ldr r1, [r4]
000d2ba4 012041e2 sub r2, r1, #1
000d2ba8 910201e0 mul r1, r1, r2
000d2bac 010011e3 tst r1, #1
000d2bb0 edffff0a beq #0xd2b6c
000d2bb4 001095e5 ldr r1, [r5]
000d2bb8 0a0051e3 cmp r1, #0xa
000d2bbc eaffffba blt #0xd2b6c
000d2bc0 843100eb bl #0xdf1d8
000d2bc4 f4ffffea b #0xd2b9c
000d2bc8 fd4300eb bl #0xe3bc4
000d2bcc 001094e5 ldr r1, [r4]
000d2bd0 012041e2 sub r2, r1, #1
000d2bd4 910201e0 mul r1, r1, r2
000d2bd8 010011e3 tst r1, #1
000d2bdc e2ffff0a beq #0xd2b6c
000d2be0 001095e5 ldr r1, [r5]
000d2be4 0a0051e3 cmp r1, #0xa
000d2be8 dfffffba blt #0xd2b6c
000d2bec f44300eb bl #0xe3bc4
000d2bf0 f4ffffea b #0xd2bc8
