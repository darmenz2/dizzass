000f33ec f0482de9 push {r4, r5, r6, r7, fp, lr}
000f33f0 10b08de2 add fp, sp, #0x10
000f33f4 10d04de2 sub sp, sp, #0x10
000f33f8 0040a0e3 mov r4, #0
000f33fc 0160a0e1 mov r6, r1
000f3400 0c408de5 str r4, [sp, #0xc]
000f3404 0050a0e1 mov r5, r0
000f3408 001091e5 ldr r1, [r1]
000f340c 0c308de2 add r3, sp, #0xc
000f3410 180090e5 ldr r0, [r0, #0x18]
000f3414 0270a0e1 mov r7, r2
000f3418 5820a0e3 mov r2, #0x58
000f341c 7f4900eb bl #0x105a20
000f3420 000050e3 cmp r0, #0
000f3424 0c00000a beq #0xf345c
000f3428 ac009fe5 ldr r0, [pc, #0xac]
000f342c 0170a0e3 mov r7, #1
000f3430 a8109fe5 ldr r1, [pc, #0xa8]
000f3434 a8209fe5 ldr r2, [pc, #0xa8]
000f3438 00008fe0 add r0, pc, r0
000f343c a4309fe5 ldr r3, [pc, #0xa4]
000f3440 01108fe0 add r1, pc, r1
000f3444 02208fe0 add r2, pc, r2
000f3448 00708de5 str r7, [sp]
000f344c 03308fe0 add r3, pc, r3
000f3450 04308de5 str r3, [sp, #4]
000f3454 613200e3 movw r3, #0x261
000f3458 1a0000ea b #0xf34c8
000f345c 0c009de5 ldr r0, [sp, #0xc]
000f3460 0f1007e2 and r1, r7, #0xf
000f3464 0620a0e1 mov r2, r6
000f3468 5830a0e3 mov r3, #0x58
000f346c 0f0ac0e3 bic r0, r0, #0xf000
000f3470 010680e1 orr r0, r0, r1, lsl #12
000f3474 0c008de5 str r0, [sp, #0xc]
000f3478 00008de5 str r0, [sp]
000f347c 0500a0e1 mov r0, r5
000f3480 0010a0e3 mov r1, #0
000f3484 3c0200eb bl #0xf3d7c
000f3488 000050e3 cmp r0, #0
000f348c 0f00000a beq #0xf34d0
000f3490 54009fe5 ldr r0, [pc, #0x54]
000f3494 0160a0e3 mov r6, #1
000f3498 50109fe5 ldr r1, [pc, #0x50]
000f349c 50209fe5 ldr r2, [pc, #0x50]
000f34a0 00008fe0 add r0, pc, r0
000f34a4 183095e5 ldr r3, [r5, #0x18]
000f34a8 01108fe0 add r1, pc, r1
000f34ac 44709fe5 ldr r7, [pc, #0x44]
000f34b0 02208fe0 add r2, pc, r2
000f34b4 013083e2 add r3, r3, #1
000f34b8 07708fe0 add r7, pc, r7
000f34bc c0008de8 stm sp, {r6, r7}
000f34c0 08308de5 str r3, [sp, #8]
000f34c4 6b3200e3 movw r3, #0x26b
000f34c8 782e00eb bl #0xfeeb0
000f34cc 0040e0e3 mvn r4, #0
000f34d0 0400a0e1 mov r0, r4
000f34d4 10d04be2 sub sp, fp, #0x10
000f34d8 f088bde8 pop {r4, r5, r6, r7, fp, pc}
