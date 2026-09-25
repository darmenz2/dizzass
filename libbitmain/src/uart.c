/* SPDX-License-Identifier: GPL-3.0-only
 * Partial source reconstruction: /tmp/build/libbitmain/src/uart.c.
 * Source path verified by decoding 33 bytes at 0x5edbbf with XOR 0xaa.
 * The Stage 1 heuristic truncated that path at 11 bytes; it is not a new
 * invented vendor filename. Original syscall/mutex/logging implementations
 * are replaced by explicit integration callbacks. Diagnostics are omitted.
 */
#include "xminer/recovery/uart.h"
#include <limits.h>

int vn135_uart_set_baud(vn135_uart *u, const vn135_uart_ops *o, uint32_t baud)
{
    if (!u || !o || !o->ioctl) return -2;
    vn135_uart_attributes a;
    if (o->ioctl(o->context, u->fd, VN135_UART_TCGETS2, &a) != 0) return -1;
    a.control_flags = (a.control_flags & UINT32_C(0xeff0eff0)) | UINT32_C(0x10001000);
    a.input_speed = baud;
    a.output_speed = baud;
    if (o->ioctl(o->context, u->fd, VN135_UART_TCSETS2, &a) != 0) return -1;
    u->baud = baud;
    return 0;
}

int vn135_uart_open(vn135_uart *u, const vn135_uart_ops *o, const char *path)
{
    if (!u || !o || !path || !o->open || !o->duplicate || !o->release ||
        !o->ioctl || !o->close || !o->mutex_init || !o->mutex_destroy) return -2;
    if (u->fd != -1 || u->path || u->mutex_ready) return -2;
    int32_t fd = o->open(o->context, path, VN135_UART_OPEN_FLAGS);
    if (fd < 0) return -1;
    /* Original ignores mutex_init and strdup failure. Preserve that here;
     * a production wrapper may add fail-closed admission before use. */
    (void)o->mutex_init(o->context);
    u->mutex_ready = true;
    u->path = o->duplicate(o->context, path);
    u->fd = fd;
    u->baud = 0;
    vn135_uart_attributes a;
    if (o->ioctl(o->context, fd, VN135_UART_TCGETS2, &a) != 0) return -1;
    a.input_flags &= UINT32_C(0xfffffa14);
    a.output_flags &= UINT32_C(0xfffffffe);
    a.control_flags = (a.control_flags & ~UINT32_C(0x9b0)) | UINT32_C(0x8b0);
    a.local_flags &= UINT32_C(0xffff7fb4);
    a.control_chars[5] = 0;
    a.control_chars[6] = 7;
    if (o->ioctl(o->context, fd, VN135_UART_TCSETS2, &a) != 0) return -1;
    return vn135_uart_set_baud(u, o, 115200);
}

int32_t vn135_uart_read(vn135_uart *u, const vn135_uart_ops *o, uint8_t *out, size_t n)
{
    if (!u || !o || !o->ioctl || !o->read || (!out && n) || n > (size_t)INT32_MAX) return -2;
    int32_t available = 0;
    if (o->ioctl(o->context, u->fd, VN135_UART_FIONREAD, &available) != 0 || available == 0) return 0;
    /* No clamp to 'available' in the original; callback receives requested n. */
    return o->read(o->context, u->fd, out, (uint32_t)n);
}

int32_t vn135_uart_write_legacy(vn135_uart *u, const vn135_uart_ops *o, const uint8_t *data, size_t n)
{
    if (!u || !o || !o->write || !o->lock || !o->unlock || !o->error_number ||
        !o->sleep_ms || (!data && n) || n > (size_t)INT32_MAX) return -2;
    int32_t result = -1;
    int32_t *error = NULL;
    for (unsigned attempt = 0; attempt < 5; ++attempt) {
        o->lock(o->context);
        result = o->write(o->context, u->fd, data, (uint32_t)n);
        o->unlock(o->context);
        if (result == (int32_t)n) return (int32_t)n;
        if (!error) {
            error = o->error_number(o->context);
            if (!error) return -2; /* New API guard. */
        }
        if (*error != VN135_UART_EAGAIN) return result;
        o->sleep_ms(o->context, 20);
    }
    return result;
}

int32_t vn135_uart_flush(vn135_uart *u, const vn135_uart_ops *o)
{
    if (!u || !o || !o->flush) return -2;
    return o->flush(o->context, u->fd, 2);
}

int vn135_uart_destroy(vn135_uart *u, const vn135_uart_ops *o)
{
    if (!u || !o || !o->release || !o->close || !o->mutex_destroy) return -2;
    if (u->path) { o->release(o->context, u->path); u->path = NULL; }
    if (u->fd >= 0) { (void)o->close(o->context, u->fd); u->fd = -1; }
    /* Guard repeated destruction in the new API, unlike unconditional call
     * in the original. First destruction of an initialized context matches. */
    if (u->mutex_ready) { o->mutex_destroy(o->context); u->mutex_ready = false; }
    u->baud = 0;
    return 0;
}
