/* SPDX-License-Identifier: GPL-3.0-only */
#define _POSIX_C_SOURCE 200809L
#include "integration/native/uart_posix.h"
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <poll.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

_Static_assert(SSIZE_MAX == PTRDIFF_MAX, "Linux write request/result range matches B-01");
struct tty_context { int fd; };

static int os_error(int error) { return error > 0 ? error : EIO; }

int dizzass_uart_posix_now_ms(uint64_t *out)
{
    struct timespec t;
    if (!out) return EINVAL;
    if (clock_gettime(CLOCK_MONOTONIC, &t) != 0) return os_error(errno);
    if (t.tv_sec < 0 || t.tv_nsec < 0 || t.tv_nsec >= 1000000000L)
        return EOVERFLOW;
    uint64_t fraction = (uint64_t)t.tv_nsec / 1000000u;
    if ((uintmax_t)t.tv_sec > (UINT64_MAX - fraction) / 1000u)
        return EOVERFLOW;
    *out = (uint64_t)t.tv_sec * 1000u + fraction;
    return 0;
}

static int tty_clock(void *context, uint64_t *out)
{
    (void)context;
    return dizzass_uart_posix_now_ms(out);
}

static struct dizzass_uart_attempt tty_write(void *context,
    const uint8_t *data, size_t length)
{
    const struct tty_context *tty = context;
    ssize_t count = write(tty->fd, data, length);
    int error = count < 0 ? os_error(errno) : 0;
    return (struct dizzass_uart_attempt){(ptrdiff_t)count, error};
}

static int tty_wait(void *context, uint64_t deadline)
{
    const struct tty_context *tty = context;
    uint64_t previous = 0;
    for (;;) {
        uint64_t now;
        int error = dizzass_uart_posix_now_ms(&now);
        if (error) return error;
        if (now < previous) return EPROTO;
        previous = now;
        if (now >= deadline) return ETIMEDOUT;
        uint64_t remaining = deadline - now;
        int timeout = remaining > (uint64_t)INT_MAX ? INT_MAX : (int)remaining;
        struct pollfd p = {tty->fd, POLLOUT, 0};
        int ready = poll(&p, 1, timeout);
        if (ready < 0) return os_error(errno);
        if (!ready) continue; /* Re-evaluate deadline, including capped slices. */
        if (ready != 1) return EIO;
        if (p.revents & POLLNVAL) return EBADF;
        if (p.revents & (POLLHUP | POLLERR)) return EIO;
        if (p.revents & POLLOUT) return 0;
        return EIO;
    }
}

static struct dizzass_uart_result invalid(int error)
{
    return (struct dizzass_uart_result){DIZZASS_UART_INVALID_INPUT, 0, error};
}

struct dizzass_uart_result dizzass_uart_posix_write_all(int fd,
    const uint8_t *data, size_t length, uint64_t deadline_ms,
    unsigned max_no_progress)
{
    if (!length) return (struct dizzass_uart_result){DIZZASS_UART_OK, 0, 0};
    if (!data || !max_no_progress) return invalid(EINVAL);
    if (length > (size_t)PTRDIFF_MAX) return invalid(EOVERFLOW);
    int flags = fcntl(fd, F_GETFL);
    if (flags < 0) return invalid(os_error(errno));
    if (!(flags & O_NONBLOCK) || (flags & O_ACCMODE) == O_RDONLY)
        return invalid(EINVAL);
    struct termios attributes;
    if (tcgetattr(fd, &attributes) != 0) return invalid(os_error(errno));
    if (attributes.c_oflag & OPOST) return invalid(EINVAL);
    struct tty_context tty = {fd};
    const struct dizzass_uart_io io = {&tty, tty_write, tty_clock, tty_wait};
    return dizzass_uart_write_all(&io, data, length, deadline_ms, max_no_progress);
}
