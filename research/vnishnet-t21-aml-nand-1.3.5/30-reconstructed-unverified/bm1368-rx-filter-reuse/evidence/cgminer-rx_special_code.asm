000c4750 0a00a0e1 mov r0, sl
000c4754 0810a0e1 mov r1, r8
000c4758 0720a0e3 mov r2, #7
000c475c ef3500eb bl #0xd1f20
000c4760 62105be5 ldrb r1, [fp, #-0x62]
000c4764 68001be5 ldr r0, [fp, #-0x68]
000c4768 002319e5 ldr r2, [sb, #-0x300]
000c476c 1f1001e2 and r1, r1, #0x1f
000c4770 b4365be1 ldrh r3, [fp, #-0x64]
000c4774 58208de5 str r2, [sp, #0x58]
000c4778 bc35cde1 strh r3, [sp, #0x5c]
000c477c b416cde1 strh r1, [sp, #0x64]
000c4780 2018a0e1 lsr r1, r0, #0x10
000c4784 300fbfe6 rev r0, r0
000c4788 311fbfe6 rev r1, r1
000c478c 1f00cfe7 bfc r0, #0, #0x10
000c4790 610880e1 orr r0, r0, r1, ror #16
000c4794 60008de5 str r0, [sp, #0x60]
000c4798 b93800eb bl #0xd2a84
000c479c 4c139fe5 ldr r1, [pc, #0x34c]
000c47a0 01109fe7 ldr r1, [pc, r1]
000c47a4 001091e5 ldr r1, [r1]
000c47a8 012041e2 sub r2, r1, #1
000c47ac 910202e0 mul r2, r1, r2
000c47b0 63105be5 ldrb r1, [fp, #-0x63]
000c47b4 010012e3 tst r2, #1
000c47b8 1800000a beq #0xc4820
000c47bc 30239fe5 ldr r2, [pc, #0x330]
000c47c0 02209fe7 ldr r2, [pc, r2]
000c47c4 002092e5 ldr r2, [r2]
000c47c8 090052e3 cmp r2, #9
000c47cc 130000da ble #0xc4820
000c47d0 0a00a0e1 mov r0, sl
000c47d4 0810a0e1 mov r1, r8
000c47d8 0720a0e3 mov r2, #7
000c47dc cf3500eb bl #0xd1f20
000c47e0 62105be5 ldrb r1, [fp, #-0x62]
000c47e4 68001be5 ldr r0, [fp, #-0x68]
000c47e8 002319e5 ldr r2, [sb, #-0x300]
000c47ec 1f1001e2 and r1, r1, #0x1f
000c47f0 b4365be1 ldrh r3, [fp, #-0x64]
000c47f4 58208de5 str r2, [sp, #0x58]
000c47f8 bc35cde1 strh r3, [sp, #0x5c]
000c47fc b416cde1 strh r1, [sp, #0x64]
000c4800 2018a0e1 lsr r1, r0, #0x10
000c4804 300fbfe6 rev r0, r0
000c4808 311fbfe6 rev r1, r1
000c480c 1f00cfe7 bfc r0, #0, #0x10
000c4810 610880e1 orr r0, r0, r1, ror #16
000c4814 60008de5 str r0, [sp, #0x60]
000c4818 993800eb bl #0xd2a84
000c481c cbffffea b #0xc4750
000c4820 d0a29fe5 ldr sl, [pc, #0x2d0]
000c4824 0590a0e1 mov sb, r5
000c4828 010050e1 cmp r0, r1
000c482c 0aa09fe7 ldr sl, [pc, sl]
000c4830 c4529fe5 ldr r5, [pc, #0x2c4]
000c4834 05509fe7 ldr r5, [pc, r5]
000c4838 0100000a beq #0xc4844
000c483c 58008de2 add r0, sp, #0x58
000c4840 3c1001eb bl #0x108938
