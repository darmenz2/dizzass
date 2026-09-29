/* GPL-3.0-or-later. One bounded fill step, no queue or scheduler of its own. */
#ifndef DIZZASS_QUEUE_STEP_H
#define DIZZASS_QUEUE_STEP_H
#include "integration/native/queued_work_tx.h"
struct dizzass_queue_step_receipt {
    uint32_t slot;
    struct dizzass_job_capacity before, after;
    bool after_checked;
    int after_status;
    bool queue_full; /* Conservative: end the caller's current fill pass. */
    struct dizzass_queued_tx_receipt queued;
};
/* Select the lowest unused slot from the bound native registry BEFORE calling
 * the existing queued_work_send. Fixed route2/algorithm0/variant2, same as R09.
 * No slot: ENOSPC, no core dequeue, and out unchanged. Invalid/inactive/expired
 * calls likewise preserve staged work and out. Other failures may be existing
 * JOBS statuses. Return0 publishes a receipt: inspect ALL nested outcomes.
 * queue_full=false ONLY after a complete successful transport/finish/notify
 * AND a subsequent snapshot showing spare capacity in an active lifecycle.
 * Empty/stale core handoff and every send/metadata failure end this fill pass,
 * even with capacity, avoiding an immediate retry loop. A driver must treat
 * nonzero return as full/error too; never read unchanged out as a new receipt.
 *
 * Capacity is NOT a reservation. ONE serialized work producer must cover this
 * step and all direct prepares/sends for these jobs. Control stop may race;
 * existing R10 queue admission and A16 prepare remain authoritative. A caller
 * violating serialization can consume/complete a work that loses the slot race;
 * the old ticket is never overwritten. Core completion never frees a wire slot.
 * No automatic modulo reuse, drain, fresh epoch, hardware ACK or pool acceptance.
 *
 * Reuses R10 queue accounting through native completion. Deferred cancellation
 * is disabled through this outer receipt publication. All arguments/output are
 * stable and nonoverlapping; out must survive cancellation. External caller
 * references must still be joined before destroying IO/native queue/pool/gates,
 * including during the advisory pre/post checks outside the inner queue scope.
 * No async cancel, callback reentry, new work ownership or device_drv registration.
 */
int dizzass_queued_work_step(struct thr_info *, struct dizzass_io_lifecycle *,
    uint64_t deadline_ms, unsigned max_no_progress,
    struct dizzass_queue_step_receipt *out);
#endif
