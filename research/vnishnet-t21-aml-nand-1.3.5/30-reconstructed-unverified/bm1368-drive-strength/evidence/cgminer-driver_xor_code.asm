000e5370 00482de9 push {fp, lr}
000e5374 0000a0e3 mov r0, #0
000e5378 000050e3 cmp r0, #0
000e537c 2100001a bne #0xe5408
000e5380 d0ec9fe5 ldr lr, [pc, #0xcd0]
000e5384 0ee09fe7 ldr lr, [pc, lr]
000e5388 cccc9fe5 ldr ip, [pc, #0xccc]
000e538c 0cc09fe7 ldr ip, [pc, ip]
000e5390 c83c9fe5 ldr r3, [pc, #0xcc8]
000e5394 03308fe0 add r3, pc, r3
000e5398 020000ea b #0xe53a8
000e539c 070052e3 cmp r2, #7
000e53a0 0200a0e1 mov r0, r2
000e53a4 1700000a beq #0xe5408
000e53a8 00209ee5 ldr r2, [lr]
000e53ac 011042e2 sub r1, r2, #1
000e53b0 920101e0 mul r1, r2, r1
000e53b4 010011e3 tst r1, #1
000e53b8 0200000a beq #0xe53c8
000e53bc 00109ce5 ldr r1, [ip]
000e53c0 090051e3 cmp r1, #9
000e53c4 0b0000ca bgt #0xe53f8
000e53c8 0010d3e7 ldrb r1, [r3, r0]
000e53cc 1e1021e2 eor r1, r1, #0x1e
000e53d0 0010c3e7 strb r1, [r3, r0]
000e53d4 00109ee5 ldr r1, [lr]
000e53d8 012041e2 sub r2, r1, #1
000e53dc 910201e0 mul r1, r1, r2
000e53e0 012080e2 add r2, r0, #1
000e53e4 010011e3 tst r1, #1
000e53e8 ebffff0a beq #0xe539c
000e53ec 00109ce5 ldr r1, [ip]
000e53f0 090051e3 cmp r1, #9
000e53f4 e8ffffda ble #0xe539c
