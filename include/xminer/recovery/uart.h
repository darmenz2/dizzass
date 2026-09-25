/* SPDX-License-Identifier: GPL-3.0-only
 * New integration API for the recovered libbitmain/src/uart.c routines.
 * This is NOT the original vendor ABI. No operations run without callbacks.
 */
#ifndef VN135_RECOVERY_UART_H
#define VN135_RECOVERY_UART_H
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#define VN135_UART_TCGETS2 UINT32_C(0x802c542a)
#define VN135_UART_TCSETS2 UINT32_C(0x402c542b)
#define VN135_UART_FIONREAD UINT32_C(0x541b)
#define VN135_UART_OPEN_FLAGS UINT32_C(0x902)
#define VN135_UART_EAGAIN 11

/* The 44-byte ARM Linux kernel termios2 record observed in this binary.
 * Not libc struct termios. OS adapters must verify layout and ioctl constants.
 */
typedef struct {
    uint32_t input_flags, output_flags, control_flags, local_flags;
    uint8_t line, control_chars[19];
    uint32_t input_speed, output_speed;
} vn135_uart_attributes;
_Static_assert(sizeof(vn135_uart_attributes) == 44, "termios2 size");
_Static_assert(offsetof(vn135_uart_attributes, input_speed) == 36, "termios2 speeds");
_Static_assert(offsetof(vn135_uart_attributes, control_chars) == 17, "termios2 cc");

typedef struct {
    char *path;
    int32_t fd;
    uint32_t baud;
    bool mutex_ready; /* New lifecycle guard, not an original field. */
} vn135_uart;
#define VN135_UART_INITIALIZER { NULL, -1, 0, false }

typedef struct {
    void *context;
    int32_t (*open)(void *, const char *, uint32_t);
    char *(*duplicate)(void *, const char *);
    void (*release)(void *, void *);
    int32_t (*ioctl)(void *, int32_t, uint32_t, void *);
    int32_t (*read)(void *, int32_t, uint8_t *, uint32_t);
    int32_t (*write)(void *, int32_t, const uint8_t *, uint32_t);
    int32_t *(*error_number)(void *);
    int32_t (*close)(void *, int32_t);
    int32_t (*flush)(void *, int32_t, int32_t);
    int32_t (*mutex_init)(void *);
    void (*lock)(void *);
    void (*unlock)(void *);
    void (*mutex_destroy)(void *);
    void (*sleep_ms)(void *, uint32_t);
} vn135_uart_ops;

/* 0x10e0c8. Start with VN135_UART_INITIALIZER; a partial failure after open
 * deliberately retains fd/path until destroy, as in the inspected original.
 * New API rejects occupied contexts and missing callbacks with -2. */
int vn135_uart_open(vn135_uart *, const vn135_uart_ops *, const char *);
/* 0x10e518; does not program ASIC chip baud, only the host UART. */
int vn135_uart_set_baud(vn135_uart *, const vn135_uart_ops *, uint32_t);
/* 0x10e938: ioctl failure and an empty input queue both return zero. */
int32_t vn135_uart_read(vn135_uart *, const vn135_uart_ops *, uint8_t *, size_t);
/* 0x10e6c0: fidelity-only legacy behavior. Five whole-buffer write attempts
 * at most, with sleep(20) after each non-full result while errno == 11,
 * INCLUDING a final sleep when attempts are exhausted. Positive short writes
 * with stale errno==11 can replay the prefix. Not a safe write-all primitive.
 * Do not wire into live command delivery without reviewing this contract. */
int32_t vn135_uart_write_legacy(vn135_uart *, const vn135_uart_ops *, const uint8_t *, size_t);
/* 0x10e994. Flush direction 2 = both queues for the inspected Linux ABI. */
int32_t vn135_uart_flush(vn135_uart *, const vn135_uart_ops *);
/* 0x10e9a0. Call only after all concurrent users have stopped. */
int vn135_uart_destroy(vn135_uart *, const vn135_uart_ops *);
#endif
