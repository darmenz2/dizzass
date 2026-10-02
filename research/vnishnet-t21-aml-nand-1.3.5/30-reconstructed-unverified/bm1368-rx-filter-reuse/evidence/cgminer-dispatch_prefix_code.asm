000d2a84 30482de9 push {r4, r5, fp, lr}
000d2a88 08b08de2 add fp, sp, #8
000d2a8c 4aad00eb bl #0xfdfbc
000d2a90 040050e3 cmp r0, #4
000d2a94 0900008a bhi #0xd2ac0
000d2a98 04108fe2 add r1, pc, #4
000d2a9c 000191e7 ldr r0, [r1, r0, lsl #2]
000d2aa0 00f081e0 add pc, r1, r0
