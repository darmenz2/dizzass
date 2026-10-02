000f3354 704c2de9 push {r4, r5, r6, sl, fp, lr}
000f3358 10b08de2 add fp, sp, #0x10
000f335c 10d04de2 sub sp, sp, #0x10
000f3360 0040a0e1 mov r4, r0
000f3364 070001e2 and r0, r1, #7
000f3368 00008de5 str r0, [sp]
000f336c 0400a0e1 mov r0, r4
000f3370 0110a0e3 mov r1, #1
000f3374 0020a0e3 mov r2, #0
000f3378 5430a0e3 mov r3, #0x54
000f337c 0160a0e3 mov r6, #1
000f3380 0050a0e3 mov r5, #0
000f3384 7c0200eb bl #0xf3d7c
000f3388 000050e3 cmp r0, #0
000f338c 0f00000a beq #0xf33d0
000f3390 44009fe5 ldr r0, [pc, #0x44]
000f3394 44109fe5 ldr r1, [pc, #0x44]
000f3398 44209fe5 ldr r2, [pc, #0x44]
000f339c 00008fe0 add r0, pc, r0
000f33a0 183094e5 ldr r3, [r4, #0x18]
000f33a4 01108fe0 add r1, pc, r1
000f33a8 38509fe5 ldr r5, [pc, #0x38]
000f33ac 02208fe0 add r2, pc, r2
000f33b0 013083e2 add r3, r3, #1
000f33b4 08308de5 str r3, [sp, #8]
000f33b8 a93100e3 movw r3, #0x1a9
000f33bc 05508fe0 add r5, pc, r5
000f33c0 00608de5 str r6, [sp]
000f33c4 04508de5 str r5, [sp, #4]
000f33c8 b82e00eb bl #0xfeeb0
000f33cc 0050e0e3 mvn r5, #0
000f33d0 0500a0e1 mov r0, r5
000f33d4 10d04be2 sub sp, fp, #0x10
000f33d8 708cbde8 pop {r4, r5, r6, sl, fp, pc}
