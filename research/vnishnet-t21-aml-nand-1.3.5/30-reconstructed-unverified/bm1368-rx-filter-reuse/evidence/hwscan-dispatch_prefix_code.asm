000eaa24 00482de9 push {fp, lr}
000eaa28 0db0a0e1 mov fp, sp
000eaa2c 1a5800eb bl #0x100a9c
000eaa30 040050e3 cmp r0, #4
000eaa34 0900008a bhi #0xeaa60
000eaa38 04108fe2 add r1, pc, #4
000eaa3c 000191e7 ldr r0, [r1, r0, lsl #2]
000eaa40 00f081e0 add pc, r1, r0
