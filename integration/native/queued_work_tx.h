/* GPL-3.0-or-later. Native queued-driver handoff, not a second work queue. */
#ifndef DIZZASS_QUEUED_WORK_TX_H
#define DIZZASS_QUEUED_WORK_TX_H
#include "integration/native/io_lifecycle.h"
struct thr_info;
struct dizzass_queued_tx_plan {
    uint32_t platform, algorithm, slot, variant;
    uint64_t deadline_ms; /* Absolute monotonic TX deadline; never extended. */
    unsigned max_no_progress;
};
struct dizzass_queued_tx_receipt {
    bool dequeued; /* A non-NULL get_queued result; NULL may mean stale discard. */
    uint32_t work_id;
    int work_thr_id;
    int work_status; /* Existing native-submit metadata status, before TX. */
    bool send_called, completed;
    int send_status; /* Return from io_send_work, not its transport outcome. */
    struct dizzass_io_work_receipt send;
};
/* ONE operation for a queued device driver's queue_full callback. The caller
 * supplies the unused slot; no allocator, modulo reuse, queue or worker loop.
 * Current scope is platform2/algorithm0/variant2 (existing fixed TX88 route).
 * Use an already-started CRC5 lifecycle for strict RX. This helper cannot
 * discover whether io/cgpu/thr/jobs/submitter/port denote the same device: the
 * caller establishes that identity and supplies the SAME native thread ID.
 *
 * Native core queue invariants are prerequisites: initialized cgpu->qlock and
 * core scheduler locks, valid owned heap work/pool/job_id, stable pool lifetime.
 * get_queued performs its REAL stale checks, which require those valid objects.
 * This is NOT a validator for arbitrary/corrupt native queue pointers.
 * All arguments/report storage are stable and nonoverlapping for the call.
 * One serialized queue owner calls this helper. No simultaneous queue aging,
 * completion or other consumer may destroy acquired work. Normal core flush of
 * the unqueued pointer remains protected by the original qlock. Do not hold
 * qlock when calling this helper. Do not retain/use its consumed work pointer.
 *
 * Invalid arguments, expired deadline or already-inactive lifecycle leave out
 * and staged work unchanged. A successful preflight is not an admission token:
 * stop may race get_queued. Once acquired, the work is completed EXACTLY ONCE
 * on success AND rejection using real work_completed. The registry's ordinary
 * native copy (if prepared) then owns RX lifetime; never requeue the original.
 * No extra native copy or manual core hashtable edit occurs here.
 *
 * Return0 means receipt published, including no work or a rejected TX. Inspect
 * dequeued/work_status/send_status and ALL nested send outcomes. Nonzero errno
 * is preflight/cancellation-state failure, not a receipt of successful TX.
 * Successful core handoff may discard a stale item and change core discard
 * counters even when dequeued=false. This is unchanged cgminer policy.
 *
 * Deferred cancellation is disabled through get_queued, metadata validation,
 * existing prepare/send/finish/notify, work_completed and report publication.
 * Restoring cancellation may prevent return; out must outlive cancellation.
 * io quiescence alone does NOT prove this outer core queue call has finished;
 * join/exclude ALL callers before freeing cgpu/queues/io/jobs/pools/fd aliases.
 * No async cancellation, callback reentry, automatic retry, slot reclamation,
 * driver registration, hardware initialization/drain or external pool send.
 */
int dizzass_queued_work_send(struct thr_info *, struct dizzass_io_lifecycle *,
    const struct dizzass_queued_tx_plan *, struct dizzass_queued_tx_receipt *out);
#endif
