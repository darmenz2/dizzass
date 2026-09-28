/* SPDX-License-Identifier: GPL-3.0-only */
/* New opt-in byte transport policy; NOT recovered VNish behavior. */
#ifndef DIZZASS_UART_SAFE_H
#define DIZZASS_UART_SAFE_H
#include <stddef.h>
#include <stdint.h>

struct dizzass_uart_attempt {
    ptrdiff_t count; /* 0..requested, or exactly -1 with a positive errno. */
    int error;      /* Captured by write before other calls; ignored if count >= 0. */
};
struct dizzass_uart_io {
    void *context;
    struct dizzass_uart_attempt (*write)(void *, const uint8_t *, size_t);
    /* Monotonic milliseconds, in the SAME epoch as deadline_ms. Return 0 and
     * fill now_ms, or return a positive errno directly (not ambient errno). */
    int (*clock)(void *, uint64_t *now_ms);
    /* Wait for write readiness until this unchanged absolute deadline. Return
     * 0=ready, EINTR=interrupted, ETIMEDOUT=expired, ECANCELED=canceled, or another
     * positive errno=failure. Must wait/yield, not implement a polling spin. */
    int (*wait)(void *, uint64_t deadline_ms);
};
enum dizzass_uart_status {
    DIZZASS_UART_OK,
    DIZZASS_UART_INVALID_INPUT,
    DIZZASS_UART_INVALID_CALLBACK,
    DIZZASS_UART_WRITE_ERROR,
    DIZZASS_UART_WAIT_ERROR,
    DIZZASS_UART_CLOCK_ERROR,
    DIZZASS_UART_TIMEOUT,
    DIZZASS_UART_CANCELED,
    DIZZASS_UART_NO_PROGRESS
};
struct dizzass_uart_result {
    enum dizzass_uart_status status;
    size_t written;
    int error;
};

/* Write only the remaining suffix, never retransmit an accepted prefix.
 *
 * Nonempty input requires data, all three callbacks, max_no_progress > 0, and
 * length <= PTRDIFF_MAX. The caller supplies a readable length-byte object;
 * its actual allocation size cannot be validated here. Empty input succeeds
 * without examining data, io, budget or clock. No size/deadline addition is
 * performed. Equality with deadline is expired, including UINT64_MAX.
 *
 * After each positive write, written advances even if the following clock
 * check fails/expires. Clock is checked initially, after positive/retryable/zero
 * writes and after successful/interrupted waits. A fully accepted but late
 * frame returns TIMEOUT with written == length. Fatal/invalid/canceled callback
 * results take precedence over a further clock check. Backward time fails with
 * CLOCK_ERROR/EPROTO; callbacks returning negative errno fail INVALID_CALLBACK.
 *
 * EINTR retries the suffix after checking time. EAGAIN/EWOULDBLOCK and zero
 * writes wait for readiness. Each no-progress write (zero/EINTR/EAGAIN) and
 * interrupted wait consumes one consecutive no-progress unit. A positive write
 * alone resets this count. Reaching max_no_progress stops BEFORE another wait
 * or write, even if the injected clock never advances. Ready waits do not reset
 * the count. TIMEOUT has precedence over budget exhaustion at a checkpoint.
 *
 * error is the captured errno of the terminating callback, or EINVAL/EOVERFLOW
 * for input, EPROTO for invalid callbacks/time, ETIMEDOUT for deadline expiry.
 * NO_PROGRESS carries the last retry error (zero for a zero write); success has
 * error=0. ECANCELED from ANY callback returns CANCELED with confirmed progress.
 * Invalid write counts preserve only previously confirmed progress: actual
 * effects of a broken callback cannot be inferred. Never automatically resend
 * a failed frame, even when written is zero. No resync, framing or CRC is added.
 *
 * Caller MUST own the channel exclusively for the ENTIRE call, including all
 * waits, and keep buffer, callbacks and context stable/alive until return. This
 * module adds no per-attempt locks: separate callers must not interleave frames.
 * All callbacks must be nonblocking/bounded with respect to the deadline; this
 * routine cannot interrupt a stuck callback. Cancellation is cooperative via
 * ECANCELED, not thread cancellation. No OS/device/network defaults are supplied.
 * A byte count confirms acceptance by write, not UART drain or an ASIC ACK. */
struct dizzass_uart_result dizzass_uart_write_all(const struct dizzass_uart_io *io,
    const uint8_t *data, size_t length, uint64_t deadline_ms,
    unsigned max_no_progress);
#endif
