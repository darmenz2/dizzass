/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef DIZZASS_NATIVE_JOB_CHANNEL_TX_H
#define DIZZASS_NATIVE_JOB_CHANNEL_TX_H
#include "integration/native_work_tx88.h"
#include "integration/native/uart_channel.h"

/* NEW one-call binding; no second session, work type, allocator or encoder. */
struct dizzass_native_job_tx_receipt {
    int entry_error;                 /* Positive errno before preparation. */
    bool prepare_called;
    int prepare_status;              /* Meaningful only if prepare_called. */
    struct dizzass_job_ticket ticket; /* Nonzero after successful reserve. */
    bool channel_called;             /* NOT evidence of a write syscall. */
    size_t frame_size;
    struct dizzass_uart_result transport; /* Only if channel_called. */
    bool finish_called;
    enum dizzass_tx_result outcome;   /* Only if finish_called; NOT ACK. */
    int finish_status;               /* Only if finish_called. */
    bool stop_called;
    int stop_status;                 /* Gate stop, NOT electrical off. */
    int cancel_restore_error;
};

/* Reuse dizzass_jobs_prepare_tx88, then send its exact prepared bytes ONCE
 * through the SAME A-14 gate used by A-15 commands. Finish once after reserve.
 * No second encode, retry, slot allocation/retirement or epoch advance.
 * Only OK + full frame + error0 is WRITTEN. EVERY other result after gate entry
 * is UNCERTAIN, including zero-byte refusal and full-but-late timeout. A-14
 * does not expose lower admission: zero is not a proof permitting NOT_SENT.
 * This intentionally sacrifices capacity on harmless queue refusals. Uncertain
 * outcome or finish failure also requests permanent gate stop with deadline0.
 * ETIMEDOUT there may mean another active frame STILL borrows fd: do not close.
 * Completion and stop results never replace the exact transport result.
 *
 * Source/strings remain immutable and alive through this call. Pool lifetime
 * stays with native core; copy_work does not retain pool. jobs/channel MUST
 * represent the same externally confirmed chain/session. No identity discovery.
 * Coordinate all TX, pause/epoch/destroy, RX and submit with existing contracts.
 * RX can see PREPARED until finish: defer/serialize reply processing across that
 * window. This helper does not solve early replies, drain or stale submission.
 *
 * Deferred cancellation is disabled across prepare/send/finish/stop bookkeeping,
 * restored afterwards. Pending cancellation can prevent receipt delivery;
 * caller cleanup owns source/buffers. Async cancellation, signal use, reentry
 * and concurrent destruction are unsupported. Channel-last is not a request
 * receipt. No production registration, ASIC ACK or pool acceptance is implied.
 */
struct dizzass_native_job_tx_receipt dizzass_native_job_channel_send(
    struct dizzass_jobs *jobs, struct dizzass_uart_channel *channel,
    uint64_t expected_epoch, uint32_t platform_selector,
    uint32_t algorithm_selector, uint32_t slot, uint32_t variant,
    const struct work *source, uint64_t deadline_ms, unsigned max_no_progress);
#endif
