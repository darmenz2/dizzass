/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef DIZZASS_UART_CHANNEL_H
#define DIZZASS_UART_CHANNEL_H
#include "integration/native/uart_posix.h"
#include <stdbool.h>

/* NEW opt-in host/POSIX TX lifetime policy, not recovered vendor behavior. */
struct dizzass_uart_channel;
struct dizzass_uart_channel_state {
    bool stopped;
    bool active;
    size_t waiting;
    bool has_result;
    struct dizzass_uart_result last; /* Last completed LOWER call, not queue refusals. */
};

/* Allocate a gate borrowing fd; fd>=0. No open/dup/close/termios operations.
 * *out must be NULL; it remains NULL on failure. Returns 0 or positive errno.
 * Successful allocation does NOT validate the device; A-13 validates on send.
 * Caller must route ALL TX for this fd/aliases through this one channel, and
 * retain fd identity/config until stop returns 0. Outside writes, multiple gates
 * for one device, RX lifetime, reconfiguration and descriptor aliases are not
 * controlled by this module. Buffer remains caller-owned through send return.
 */
int dizzass_uart_channel_create(struct dizzass_uart_channel **out, int fd);

/* At most one nonempty whole-frame A-13 call at a time. Waiting for the gate
 * consumes the SAME absolute CLOCK_MONOTONIC deadline as transmission. No FIFO
 * fairness or hard realtime guarantee. Spurious wakes recheck state and time.
 * Stop has priority over empty success/time checks once locked. Empty open calls
 * succeed without I/O and do not update last. Local invalid/queue failures have
 * written=0 and do not latch a fault. ANY non-OK LOWER result permanently stops
 * this gate, including timeout with full/zero acceptance. No resend or recovery
 * is attempted. Exact lower status/written/error is retained in last.
 *
 * Deferred pthread cancellation is DISABLED across admission, wait and active
 * I/O, and restored only after gate bookkeeping and unlock. Pending cancellation
 * can then prevent delivery of the return value: consult last after joining.
 * Do not use pthread_cancel as frame abort/retry. Async cancellation, signal
 * handler use, fork during activity and reentrant use are unsupported.
 */
struct dizzass_uart_result dizzass_uart_channel_send(struct dizzass_uart_channel *,
    const uint8_t *, size_t, uint64_t deadline_ms, unsigned max_no_progress);

/* Permanently stop new/queued sends, then wait for current A-13 to return.
 * GRACEFUL, not immediate cancellation: the active frame keeps its original
 * deadline. 0 proves no active TX and no future TX through this gate; caller may
 * release fd only after coordinating any OUTSIDE users. ETIMEDOUT leaves gate
 * stopped but fd STILL borrowed; call stop again after the active call ends.
 * No close, flush, tcdrain, physical off or ASIC ACK. Stop is idempotent. If
 * already idle, succeeds even for deadline 0. Does not wait for rejected callers
 * to return or discard their object references; destruction is separate.
 */
int dizzass_uart_channel_stop(struct dizzass_uart_channel *, uint64_t deadline_ms);
int dizzass_uart_channel_snapshot(struct dizzass_uart_channel *,
    struct dizzass_uart_channel_state *);

/* Caller must first prevent NEW references, stop successfully and join ALL
 * users (including waiters, stop/snapshot callers). Never race destruction with
 * an API entry. Returns EBUSY for open/active/waiting state, or positive errno.
 * On success frees the gate and sets *channel=NULL; fd is NEVER closed here.
 * Unexpected pthread-destroy error permits only destroy retry, not API reuse.
 */
int dizzass_uart_channel_destroy(struct dizzass_uart_channel **channel);
#endif
