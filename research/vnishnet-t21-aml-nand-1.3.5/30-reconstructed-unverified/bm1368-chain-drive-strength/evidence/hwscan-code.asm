000f34fc 704c2de9 push {r4, r5, r6, sl, fp, lr}
000f3500 10b08de2 add fp, sp, #0x10
000f3504 10d04de2 sub sp, sp, #0x10
000f3508 0040a0e3 mov r4, #0
000f350c 0050a0e1 mov r5, r0
000f3510 0c408de5 str r4, [sp, #0xc]
000f3514 0c208de2 add r2, sp, #0xc
000f3518 180090e5 ldr r0, [r0, #0x18]
000f351c 0160a0e1 mov r6, r1
000f3520 5810a0e3 mov r1, #0x58
000f3524 484800eb bl #0x10564c
000f3528 000050e3 cmp r0, #0
000f352c 0c00000a beq #0xf3564
000f3530 b0009fe5 ldr r0, [pc, #0xb0]
000f3534 0160a0e3 mov r6, #1
000f3538 ac109fe5 ldr r1, [pc, #0xac]
000f353c ac209fe5 ldr r2, [pc, #0xac]
000f3540 00008fe0 add r0, pc, r0
000f3544 a8309fe5 ldr r3, [pc, #0xa8]
000f3548 01108fe0 add r1, pc, r1
000f354c 02208fe0 add r2, pc, r2
000f3550 00608de5 str r6, [sp]
000f3554 03308fe0 add r3, pc, r3
000f3558 04308de5 str r3, [sp, #4]
000f355c 7b3200e3 movw r3, #0x27b
000f3560 1b0000ea b #0xf35d4
000f3564 0c009de5 ldr r0, [sp, #0xc]
000f3568 0f1006e2 and r1, r6, #0xf
000f356c 0020a0e3 mov r2, #0
000f3570 5830a0e3 mov r3, #0x58
000f3574 0f0ac0e3 bic r0, r0, #0xf000
000f3578 0160a0e3 mov r6, #1
000f357c 010680e1 orr r0, r0, r1, lsl #12
000f3580 0c008de5 str r0, [sp, #0xc]
000f3584 00008de5 str r0, [sp]
000f3588 0500a0e1 mov r0, r5
000f358c 0110a0e3 mov r1, #1
000f3590 f90100eb bl #0xf3d7c
000f3594 000050e3 cmp r0, #0
000f3598 0f00000a beq #0xf35dc
000f359c 54009fe5 ldr r0, [pc, #0x54]
000f35a0 54109fe5 ldr r1, [pc, #0x54]
000f35a4 54209fe5 ldr r2, [pc, #0x54]
000f35a8 00008fe0 add r0, pc, r0
000f35ac 183095e5 ldr r3, [r5, #0x18]
000f35b0 01108fe0 add r1, pc, r1
000f35b4 48509fe5 ldr r5, [pc, #0x48]
000f35b8 02208fe0 add r2, pc, r2
000f35bc 013083e2 add r3, r3, #1
000f35c0 08308de5 str r3, [sp, #8]
000f35c4 853200e3 movw r3, #0x285
000f35c8 05508fe0 add r5, pc, r5
000f35cc 00608de5 str r6, [sp]
000f35d0 04508de5 str r5, [sp, #4]
000f35d4 352e00eb bl #0xfeeb0
000f35d8 0040e0e3 mvn r4, #0
000f35dc 0400a0e1 mov r0, r4
000f35e0 10d04be2 sub sp, fp, #0x10
000f35e4 708cbde8 pop {r4, r5, r6, sl, fp, pc}
