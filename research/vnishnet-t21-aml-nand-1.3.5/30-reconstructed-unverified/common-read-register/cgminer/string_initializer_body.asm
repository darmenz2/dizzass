000d2c0c  00482de9  push     {fp, lr}
000d2c10  0000a0e3  mov      r0, #0
000d2c14  000050e3  cmp      r0, #0
000d2c18  2100001a  bne      #0xd2ca4
000d2c1c  70e19fe5  ldr      lr, [pc, #0x170]
000d2c20  0ee09fe7  ldr      lr, [pc, lr]
000d2c24  6cc19fe5  ldr      ip, [pc, #0x16c]
000d2c28  0cc09fe7  ldr      ip, [pc, ip]
000d2c2c  68319fe5  ldr      r3, [pc, #0x168]
000d2c30  03308fe0  add      r3, pc, r3
000d2c34  020000ea  b        #0xd2c44
000d2c38  070052e3  cmp      r2, #7
000d2c3c  0200a0e1  mov      r0, r2
000d2c40  1700000a  beq      #0xd2ca4
000d2c44  00209ee5  ldr      r2, [lr]
000d2c48  011042e2  sub      r1, r2, #1
000d2c4c  920101e0  mul      r1, r2, r1
000d2c50  010011e3  tst      r1, #1
000d2c54  0200000a  beq      #0xd2c64
000d2c58  00109ce5  ldr      r1, [ip]
000d2c5c  090051e3  cmp      r1, #9
000d2c60  0b0000ca  bgt      #0xd2c94
000d2c64  0010d3e7  ldrb     r1, [r3, r0]
000d2c68  3b1021e2  eor      r1, r1, #0x3b
000d2c6c  0010c3e7  strb     r1, [r3, r0]
000d2c70  00109ee5  ldr      r1, [lr]
000d2c74  012041e2  sub      r2, r1, #1
000d2c78  910201e0  mul      r1, r1, r2
000d2c7c  012080e2  add      r2, r0, #1
000d2c80  010011e3  tst      r1, #1
000d2c84  ebffff0a  beq      #0xd2c38
000d2c88  00109ce5  ldr      r1, [ip]
000d2c8c  090051e3  cmp      r1, #9
000d2c90  e8ffffda  ble      #0xd2c38
000d2c94  0010d3e7  ldrb     r1, [r3, r0]
000d2c98  3b1021e2  eor      r1, r1, #0x3b
000d2c9c  0010c3e7  strb     r1, [r3, r0]
000d2ca0  efffffea  b        #0xd2c64
000d2ca4  0000a0e3  mov      r0, #0
000d2ca8  000050e3  cmp      r0, #0
000d2cac  0700001a  bne      #0xd2cd0
000d2cb0  e8109fe5  ldr      r1, [pc, #0xe8]
000d2cb4  01108fe0  add      r1, pc, r1
000d2cb8  0020d1e7  ldrb     r2, [r1, r0]
000d2cbc  0220e0e1  mvn      r2, r2
000d2cc0  0020c1e7  strb     r2, [r1, r0]
000d2cc4  010080e2  add      r0, r0, #1
000d2cc8  260050e3  cmp      r0, #0x26
000d2ccc  f9ffff1a  bne      #0xd2cb8
000d2cd0  0000a0e3  mov      r0, #0
000d2cd4  000050e3  cmp      r0, #0
000d2cd8  2100001a  bne      #0xd2d64
000d2cdc  c0e09fe5  ldr      lr, [pc, #0xc0]
000d2ce0  0ee09fe7  ldr      lr, [pc, lr]
000d2ce4  bcc09fe5  ldr      ip, [pc, #0xbc]
000d2ce8  0cc09fe7  ldr      ip, [pc, ip]
000d2cec  b8309fe5  ldr      r3, [pc, #0xb8]
000d2cf0  03308fe0  add      r3, pc, r3
000d2cf4  020000ea  b        #0xd2d04
000d2cf8  0b0052e3  cmp      r2, #0xb
000d2cfc  0200a0e1  mov      r0, r2
000d2d00  1700000a  beq      #0xd2d64
000d2d04  00209ee5  ldr      r2, [lr]
000d2d08  011042e2  sub      r1, r2, #1
000d2d0c  920101e0  mul      r1, r2, r1
000d2d10  010011e3  tst      r1, #1
000d2d14  0200000a  beq      #0xd2d24
000d2d18  00109ce5  ldr      r1, [ip]
000d2d1c  090051e3  cmp      r1, #9
000d2d20  0b0000ca  bgt      #0xd2d54
000d2d24  0010d3e7  ldrb     r1, [r3, r0]
000d2d28  e21021e2  eor      r1, r1, #0xe2
000d2d2c  0010c3e7  strb     r1, [r3, r0]
000d2d30  00109ee5  ldr      r1, [lr]
000d2d34  012041e2  sub      r2, r1, #1
000d2d38  910201e0  mul      r1, r1, r2
000d2d3c  012080e2  add      r2, r0, #1
000d2d40  010011e3  tst      r1, #1
000d2d44  ebffff0a  beq      #0xd2cf8
000d2d48  00109ce5  ldr      r1, [ip]
000d2d4c  090051e3  cmp      r1, #9
000d2d50  e8ffffda  ble      #0xd2cf8
000d2d54  0010d3e7  ldrb     r1, [r3, r0]
000d2d58  e21021e2  eor      r1, r1, #0xe2
000d2d5c  0010c3e7  strb     r1, [r3, r0]
000d2d60  efffffea  b        #0xd2d24
000d2d64  0000a0e3  mov      r0, #0
000d2d68  000050e3  cmp      r0, #0
000d2d6c  0088bd18  popne    {fp, pc}
000d2d70  38109fe5  ldr      r1, [pc, #0x38]
000d2d74  01108fe0  add      r1, pc, r1
000d2d78  0020d1e7  ldrb     r2, [r1, r0]
000d2d7c  1b2022e2  eor      r2, r2, #0x1b
000d2d80  0020c1e7  strb     r2, [r1, r0]
000d2d84  010080e2  add      r0, r0, #1
000d2d88  2d0050e3  cmp      r0, #0x2d
000d2d8c  f9ffff1a  bne      #0xd2d78
000d2d90  0088bde8  pop      {fp, pc}
