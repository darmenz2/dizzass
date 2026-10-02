000e35c0 f04d2de9 push {r4, r5, r6, r7, r8, sl, fp, lr}
000e35c4 18b08de2 add fp, sp, #0x18
000e35c8 10d04de2 sub sp, sp, #0x10
000e35cc 0040a0e1 mov r4, r0
000e35d0 070001e2 and r0, r1, #7
000e35d4 00008de5 str r0, [sp]
000e35d8 0400a0e1 mov r0, r4
000e35dc 0110a0e3 mov r1, #1
000e35e0 0020a0e3 mov r2, #0
000e35e4 5430a0e3 mov r3, #0x54
000e35e8 0050a0e3 mov r5, #0
000e35ec 200500eb bl #0xe4a74
000e35f0 000050e3 cmp r0, #0
000e35f4 3100000a beq #0xe36c0
000e35f8 fc809fe5 ldr r8, [pc, #0xfc]
000e35fc 08809fe7 ldr r8, [pc, r8]
000e3600 000098e5 ldr r0, [r8]
000e3604 f4709fe5 ldr r7, [pc, #0xf4]
000e3608 011040e2 sub r1, r0, #1
000e360c 900100e0 mul r0, r0, r1
000e3610 07709fe7 ldr r7, [pc, r7]
000e3614 e8609fe5 ldr r6, [pc, #0xe8]
000e3618 06608fe0 add r6, pc, r6
000e361c 010010e3 tst r0, #1
000e3620 0200000a beq #0xe3630
000e3624 000097e5 ldr r0, [r7]
000e3628 090050e3 cmp r0, #9
000e362c 150000ca bgt #0xe3688
000e3630 d0009fe5 ldr r0, [pc, #0xd0]
000e3634 0150a0e3 mov r5, #1
000e3638 cc109fe5 ldr r1, [pc, #0xcc]
000e363c cc209fe5 ldr r2, [pc, #0xcc]
000e3640 00008fe0 add r0, pc, r0
000e3644 183094e5 ldr r3, [r4, #0x18]
000e3648 01108fe0 add r1, pc, r1
000e364c 02208fe0 add r2, pc, r2
000e3650 60008de8 stm sp, {r5, r6}
000e3654 013083e2 add r3, r3, #1
000e3658 08308de5 str r3, [sp, #8]
000e365c a93100e3 movw r3, #0x1a9
000e3660 975a00eb bl #0xfa0c4
000e3664 000098e5 ldr r0, [r8]
000e3668 0050e0e3 mvn r5, #0
000e366c 011040e2 sub r1, r0, #1
000e3670 900100e0 mul r0, r0, r1
000e3674 010010e3 tst r0, #1
000e3678 1000000a beq #0xe36c0
000e367c 000097e5 ldr r0, [r7]
000e3680 090050e3 cmp r0, #9
000e3684 0d0000da ble #0xe36c0
000e3688 8c009fe5 ldr r0, [pc, #0x8c]
000e368c 0150a0e3 mov r5, #1
000e3690 88109fe5 ldr r1, [pc, #0x88]
000e3694 88209fe5 ldr r2, [pc, #0x88]
000e3698 00008fe0 add r0, pc, r0
000e369c 183094e5 ldr r3, [r4, #0x18]
000e36a0 01108fe0 add r1, pc, r1
000e36a4 02208fe0 add r2, pc, r2
000e36a8 60008de8 stm sp, {r5, r6}
000e36ac 013083e2 add r3, r3, #1
000e36b0 08308de5 str r3, [sp, #8]
000e36b4 a93100e3 movw r3, #0x1a9
000e36b8 815a00eb bl #0xfa0c4
000e36bc dbffffea b #0xe3630
000e36c0 4c009fe5 ldr r0, [pc, #0x4c]
000e36c4 00009fe7 ldr r0, [pc, r0]
000e36c8 48109fe5 ldr r1, [pc, #0x48]
000e36cc 01109fe7 ldr r1, [pc, r1]
000e36d0 002090e5 ldr r2, [r0]
000e36d4 013042e2 sub r3, r2, #1
000e36d8 920302e0 mul r2, r2, r3
000e36dc 010012e3 tst r2, #1
000e36e0 0200000a beq #0xe36f0
000e36e4 002091e5 ldr r2, [r1]
000e36e8 090052e3 cmp r2, #9
000e36ec f7ffffca bgt #0xe36d0
000e36f0 0500a0e1 mov r0, r5
000e36f4 18d04be2 sub sp, fp, #0x18
000e36f8 f08dbde8 pop {r4, r5, r6, r7, r8, sl, fp, pc}
