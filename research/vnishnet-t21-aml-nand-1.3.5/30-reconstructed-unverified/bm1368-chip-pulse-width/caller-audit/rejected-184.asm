RANGE 0x1e5c60..0x1e5ca0
001e5c60  d8019fe5  ldr r0, [pc, #0x1d8]
001e5c64  00009fe7  ldr r0, [pc, r0]
001e5c68  011040e2  sub r1, r0, #1
001e5c6c  900100e0  mul r0, r0, r1
001e5c70  010010e3  tst r0, #1
001e5c74  0300000a  beq #0x1e5c88
001e5c78  c4019fe5  ldr r0, [pc, #0x1c4]
001e5c7c  00009fe7  ldr r0, [pc, r0]
001e5c80  090050e3  cmp r0, #9
001e5c84  140000ca  bgt #0x1e5cdc
001e5c88  846194e5  ldr r6, [r4, #0x184]
001e5c8c  0400a0e1  mov r0, r4
001e5c90  883194e5  ldr r3, [r4, #0x188]
001e5c94  0a10a0e1  mov r1, sl
001e5c98  0920a0e1  mov r2, sb
001e5c9c  36ff2fe1  blx r6
RANGE 0x1e5cbc..0x1e5cf8
001e5cbc  012041e2  sub r2, r1, #1
001e5cc0  910201e0  mul r1, r1, r2
001e5cc4  010011e3  tst r1, #1
001e5cc8  0a00000a  beq #0x1e5cf8
001e5ccc  78119fe5  ldr r1, [pc, #0x178]
001e5cd0  01109fe7  ldr r1, [pc, r1]
001e5cd4  090051e3  cmp r1, #9
001e5cd8  060000da  ble #0x1e5cf8
001e5cdc  846194e5  ldr r6, [r4, #0x184]
001e5ce0  0400a0e1  mov r0, r4
001e5ce4  883194e5  ldr r3, [r4, #0x188]
001e5ce8  0a10a0e1  mov r1, sl
001e5cec  0920a0e1  mov r2, sb
001e5cf0  36ff2fe1  blx r6
001e5cf4  e3ffffea  b #0x1e5c88
RANGE 0x1e5674..0x1e5680
001e5674  0150a0e1  mov r5, r1
001e5678  000052e3  cmp r2, #0
001e567c  0040a0e1  mov r4, r0
RANGE 0x1e5b04..0x1e5b10
001e5b04  38a04be2  sub sl, fp, #0x38
001e5b08  24908de2  add sb, sp, #0x24
001e5b0c  09808ae2  add r8, sl, #9
