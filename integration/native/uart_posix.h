/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef DIZZASS_UART_POSIX_H
#define DIZZASS_UART_POSIX_H
#include "integration/native/uart_safe.h"

/* NEW Linux/POSIX binding, not a recovered vendor routine. No implicit I/O.
 * Return 0 and monotonic milliseconds, or positive errno without changing out.
 * Use this same epoch for deadline_ms. Addition of a duration is caller-owned
 * and must be checked for uint64_t overflow. Milliseconds truncate nanoseconds.
 */
int dizzass_uart_posix_now_ms(uint64_t *out);

/* Explicit opt-in on an ALREADY OPEN writable O_NONBLOCK tty, OPOST disabled.
 * Empty input inherits B-01's no-operation success, even for fd=-1. Nonempty
 * invalid data/budget/size and fd/termios admission fail INVALID_INPUT, written=0.
 * No open, close, flush, flag/config/baud mutation, allocation or locks. Caller
 * owns the descriptor AND every alias exclusively for the whole frame; buffer,
 * fd identity, status flags and tty settings must remain valid/stable throughout.
 * Admission is a check, not synchronization or proof of raw 8-bit baud settings.
 *
 * Reuses unchanged B-01 write-all: partial progress is retained, suffix only,
 * one absolute deadline, no automatic frame retry. Deadline includes time spent
 * in admission but cannot interrupt a syscall/driver/scheduler. No hard realtime
 * guarantee. Calls are not pthread-cancellation-safe; no cancellation fd/handler
 * or OS-thread ownership is supplied here. EINTR is retried by B-01's budget.
 *
 * poll uses positive INT_MAX-capped slices, rechecking the ORIGINAL deadline
 * after a zero result; slices are not deadline expiry by themselves. POLLNVAL
 * maps to EBADF; HUP/ERR (even with OUT) and unexpected events map to EIO.
 * poll/inner-clock errors are WAIT_ERROR, except ETIMEDOUT/CANCELED per B-01.
 * Initial/post-write clock errors are CLOCK_ERROR. Admission errors have priority
 * over checking the clock. Fatal write/wait results retain B-01 precedence.
 *
 * written means accepted by write(), NOT drained onto a wire, received by peer
 * or acknowledged by ASIC. TIMEOUT may have written==length. Non-OK MUST NOT
 * cause a caller to resend the frame automatically, even with written==0.
 * No production driver or protocol registration is performed by this module.
 */
struct dizzass_uart_result dizzass_uart_posix_write_all(int fd,
    const uint8_t *data, size_t length, uint64_t deadline_ms,
    unsigned max_no_progress);
#endif
