/* SPDX-License-Identifier: GPL-3.0-only
 * Linux user-space diagnostic ONLY. Exactly four fixed syscall sites.
 * There is no general syscall(number, ...) or device/file open function. */
#if defined(__arm__)
.syntax unified
.arm
.arch armv7-a
.section .text._start,"ax",%progbits
.global _start
.type _start,%function
_start:
    mov r0,sp
    bic sp,sp,#7
    bl diag_main
    b diag_exit
.size _start,.-_start
.macro FUNC name
.section .text.\name,"ax",%progbits
.global \name
.type \name,%function
\name:
.endm
FUNC diag_write
    push {r7,lr}
    mov r2,r1
    mov r1,r0
    mov r0,#1
    mov r7,#4
    svc #0
    pop {r7,pc}
.size diag_write,.-diag_write
FUNC diag_uname
    push {r7,lr}
    mov r7,#122
    svc #0
    pop {r7,pc}
.size diag_uname,.-diag_uname
FUNC diag_clock
    push {r7,lr}
    mov r1,r0
    mov r0,#1
    movw r7,#263
    svc #0
    pop {r7,pc}
.size diag_clock,.-diag_clock
FUNC diag_exit
    mov r7,#1
    svc #0
    udf #0
.size diag_exit,.-diag_exit
#elif defined(__aarch64__)
.section .text._start,"ax",%progbits
.global _start
.type _start,%function
_start:
    mov x0,sp
    bl diag_main
    b diag_exit
.size _start,.-_start
.macro FUNC name
.section .text.\name,"ax",%progbits
.global \name
.type \name,%function
\name:
.endm
FUNC diag_write
    mov x2,x1
    mov x1,x0
    mov x0,#1
    mov x8,#64
    svc #0
    ret
.size diag_write,.-diag_write
FUNC diag_uname
    mov x8,#160
    svc #0
    ret
.size diag_uname,.-diag_uname
FUNC diag_clock
    mov x1,x0
    mov x0,#1
    mov x8,#113
    svc #0
    ret
.size diag_clock,.-diag_clock
FUNC diag_exit
    mov x8,#93
    svc #0
    brk #0
.size diag_exit,.-diag_exit
#else
#error Unsupported diagnostic architecture
#endif
.section .note.GNU-stack,"",%progbits
