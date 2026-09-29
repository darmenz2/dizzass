/* GPL-3.0-or-later. Backpressure from native slots, not cgpu->queued_count. */
#include "config.h"
#include "miner.h"
#include "integration/native/queue_step.h"
#include <errno.h>

int dizzass_queued_work_step(struct thr_info *thr, struct dizzass_io_lifecycle *io,
    uint64_t deadline, unsigned budget, struct dizzass_queue_step_receipt *out)
{
    if (!thr || !thr->cgpu || !thr->cgpu->drv || thr->id < 0 ||
        !io || !budget || !out) return EINVAL;
    int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (rc) return rc;
    uint64_t now;
    struct dizzass_queue_step_receipt r = {.queue_full = true};
    rc = dizzass_uart_posix_now_ms(&now);
    if (rc) goto done;
    if (now >= deadline) { rc = ETIMEDOUT; goto done; }
    rc = dizzass_io_capacity(io, &r.before);
    if (rc) goto done;
    if (!r.before.unused_mask) { rc = ENOSPC; goto done; }
    for (r.slot = 0; r.slot < DIZZASS_JOB_SLOTS; ++r.slot)
        if (r.before.unused_mask & (UINT32_C(1) << r.slot)) break;
    struct dizzass_queued_tx_plan plan = {2, 0, r.slot, 2, deadline, budget};
    rc = dizzass_queued_work_send(thr, io, &plan, &r.queued);
    if (rc) goto done;
    const struct dizzass_native_job_tx_receipt *tx = &r.queued.send.send;
    if (r.queued.dequeued && r.queued.completed && !r.queued.work_status &&
        r.queued.send_called && !r.queued.send_status && !r.queued.send.notify_status &&
        !tx->entry_error && tx->prepare_called && !tx->prepare_status &&
        tx->channel_called && tx->frame_size == DIZZASS_TX88_SIZE &&
        tx->transport.status == DIZZASS_UART_OK && !tx->transport.error &&
        tx->transport.written == DIZZASS_TX88_SIZE && tx->finish_called &&
        !tx->finish_status && tx->outcome == DIZZASS_TX_WRITTEN && !tx->cancel_restore_error) {
        r.after_checked = true;
        r.after_status = dizzass_io_capacity(io, &r.after);
        r.queue_full = r.after_status != 0 || r.after.unused_mask == 0;
    }
    *out = r;
done:
    {
        int restore = pthread_setcancelstate(saved, NULL);
        return rc ? rc : restore;
    }
}
