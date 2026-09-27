/* SPDX-License-Identifier: GPL-3.0-only */
#include "integration/native/uart_safe.h"
#include <errno.h>

static struct dizzass_uart_result result(enum dizzass_uart_status status,
    size_t written, int error)
{
    return (struct dizzass_uart_result){status, written, error};
}

static struct dizzass_uart_result callback_error(enum dizzass_uart_status status,
    size_t written, int error)
{
    if (error <= 0)
        return result(DIZZASS_UART_INVALID_CALLBACK, written, EPROTO);
    return result(error == ECANCELED ? DIZZASS_UART_CANCELED : status, written, error);
}

static struct dizzass_uart_result checkpoint(const struct dizzass_uart_io *io,
    uint64_t deadline, uint64_t *last, size_t written)
{
    uint64_t now = 0;
    int error = io->clock(io->context, &now);
    if (error)
        return callback_error(DIZZASS_UART_CLOCK_ERROR, written, error);
    if (now < *last)
        return result(DIZZASS_UART_CLOCK_ERROR, written, EPROTO);
    *last = now;
    return result(now >= deadline ? DIZZASS_UART_TIMEOUT : DIZZASS_UART_OK,
        written, now >= deadline ? ETIMEDOUT : 0);
}

struct dizzass_uart_result dizzass_uart_write_all(const struct dizzass_uart_io *io,
    const uint8_t *data, size_t length, uint64_t deadline_ms,
    unsigned max_no_progress)
{
    struct dizzass_uart_result check;
    uint64_t last = 0;
    size_t written = 0;
    unsigned idle = 0;
    if (!length)
        return result(DIZZASS_UART_OK, 0, 0);
    if (!data || !io || !io->write || !io->clock || !io->wait || !max_no_progress)
        return result(DIZZASS_UART_INVALID_INPUT, 0, EINVAL);
    if (length > (size_t)PTRDIFF_MAX)
        return result(DIZZASS_UART_INVALID_INPUT, 0, EOVERFLOW);
    check = checkpoint(io, deadline_ms, &last, written);
    if (check.status != DIZZASS_UART_OK)
        return check;
    for (;;) {
        size_t remaining = length - written;
        struct dizzass_uart_attempt attempt = io->write(io->context,
            data + written, remaining);
        int error = 0;
        if (attempt.count < -1 || (attempt.count >= 0 && (size_t)attempt.count > remaining))
            return result(DIZZASS_UART_INVALID_CALLBACK, written, EPROTO);
        if (attempt.count > 0) {
            written += (size_t)attempt.count;
            idle = 0;
            check = checkpoint(io, deadline_ms, &last, written);
            if (check.status != DIZZASS_UART_OK)
                return check;
            if (written == length)
                return result(DIZZASS_UART_OK, written, 0);
            continue;
        }
        if (attempt.count == -1) {
            error = attempt.error;
            if (error != EINTR && error != EAGAIN && error != EWOULDBLOCK)
                return callback_error(DIZZASS_UART_WRITE_ERROR, written, error);
        }
        check = checkpoint(io, deadline_ms, &last, written);
        if (check.status != DIZZASS_UART_OK)
            return check;
        if (++idle >= max_no_progress)
            return result(DIZZASS_UART_NO_PROGRESS, written, error);
        if (error == EINTR)
            continue;
        for (;;) {
            error = io->wait(io->context, deadline_ms);
            if (error && error != EINTR)
                return callback_error(error == ETIMEDOUT ? DIZZASS_UART_TIMEOUT :
                    DIZZASS_UART_WAIT_ERROR, written, error);
            check = checkpoint(io, deadline_ms, &last, written);
            if (check.status != DIZZASS_UART_OK)
                return check;
            if (!error)
                break;
            if (++idle >= max_no_progress)
                return result(DIZZASS_UART_NO_PROGRESS, written, EINTR);
        }
    }
}
