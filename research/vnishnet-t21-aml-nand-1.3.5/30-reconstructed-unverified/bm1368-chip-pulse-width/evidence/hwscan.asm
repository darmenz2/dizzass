000f3174 f04d2de9 push {r4, r5, r6, r7, r8, sl, fp, lr}
000f3178 18b08de2 add fp, sp, #0x18
000f317c 10d04de2 sub sp, sp, #0x10
000f3180 0060a0e1 mov r6, r0
000f3184 3800a0e3 mov r0, #0x38
000f3188 830100e0 and r0, r0, r3, lsl #3
000f318c 0140a0e1 mov r4, r1
000f3190 0010a0e3 mov r1, #0
000f3194 3c30a0e3 mov r3, #0x3c
000f3198 1203c7e7 bfi r0, r2, #6, #2
000f319c 0420a0e1 mov r2, r4
000f31a0 020980e3 orr r0, r0, #0x8000
000f31a4 0050a0e3 mov r5, #0
000f31a8 020180e3 orr r0, r0, #0x80000000
000f31ac 00008de5 str r0, [sp]
000f31b0 0600a0e1 mov r0, r6
000f31b4 f00200eb bl #0xf3d7c
000f31b8 000050e3 cmp r0, #0
000f31bc 1f00000a beq #0xf3240
000f31c0 84809fe5 ldr r8, [pc, #0x84]
000f31c4 0140a0e3 mov r4, #1
000f31c8 80509fe5 ldr r5, [pc, #0x80]
000f31cc 833100e3 movw r3, #0x183
000f31d0 7c709fe5 ldr r7, [pc, #0x7c]
000f31d4 08808fe0 add r8, pc, r8
000f31d8 180096e5 ldr r0, [r6, #0x18]
000f31dc 05508fe0 add r5, pc, r5
000f31e0 70109fe5 ldr r1, [pc, #0x70]
000f31e4 07708fe0 add r7, pc, r7
000f31e8 010080e2 add r0, r0, #1
000f31ec 08008de5 str r0, [sp, #8]
000f31f0 01108fe0 add r1, pc, r1
000f31f4 04108de5 str r1, [sp, #4]
000f31f8 0800a0e1 mov r0, r8
000f31fc 0510a0e1 mov r1, r5
000f3200 0720a0e1 mov r2, r7
000f3204 00408de5 str r4, [sp]
000f3208 282f00eb bl #0xfeeb0
000f320c 180096e5 ldr r0, [r6, #0x18]
000f3210 0720a0e1 mov r2, r7
000f3214 40109fe5 ldr r1, [pc, #0x40]
000f3218 1a3200e3 movw r3, #0x21a
000f321c 010080e2 add r0, r0, #1
000f3220 08008de5 str r0, [sp, #8]
000f3224 01108fe0 add r1, pc, r1
000f3228 04108de5 str r1, [sp, #4]
000f322c 0800a0e1 mov r0, r8
000f3230 0510a0e1 mov r1, r5
000f3234 00408de5 str r4, [sp]
000f3238 1c2f00eb bl #0xfeeb0
000f323c 0050e0e3 mvn r5, #0
000f3240 0500a0e1 mov r0, r5
000f3244 18d04be2 sub sp, fp, #0x18
000f3248 f08dbde8 pop {r4, r5, r6, r7, r8, sl, fp, pc}
