/* GPL-3.0-or-later. Adapt the existing one-step sender to native fill_queue. */
#include "config.h"
#include "miner.h"
#include "integration/native/queue_callback.h"
#include <errno.h>

int dizzass_queue_callback_init(struct dizzass_queue_callback *b,
    struct thr_info *thr, struct dizzass_io_lifecycle *io,
    uint64_t timeout_ms, unsigned budget)
{
    if (!b || !thr || !thr->cgpu || !thr->cgpu->drv || thr->id < 0 ||
        !io || !timeout_ms || !budget) return EINVAL;
    *b = (struct dizzass_queue_callback){.thr=thr, .io=io,
        .timeout_ms=timeout_ms, .max_no_progress=budget,
        .last={.status=ENODATA, .queue_full=true}};
    return 0;
}

bool dizzass_queue_full(struct cgpu_info *cgpu)
{
    if (!cgpu || !cgpu->device_data) return true;
    struct dizzass_queue_callback *b = cgpu->device_data;
    struct dizzass_queue_callback_result r = {.queue_full=true};
    int saved;
    r.status = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (r.status) { b->last = r; return true; }
    if (!b->thr || b->thr->cgpu != cgpu || b->thr->id < 0 || !cgpu->drv ||
        cgpu->drv->queue_full != dizzass_queue_full || !b->io ||
        !b->timeout_ms || !b->max_no_progress) {
        r.status = EINVAL;
    } else {
        uint64_t now;
        r.status = dizzass_uart_posix_now_ms(&now);
        if (!r.status && b->timeout_ms > UINT64_MAX - now) r.status = EOVERFLOW;
        if (!r.status) {
            r.deadline_ms = now + b->timeout_ms;
            r.step_called = true;
            r.status = dizzass_queued_work_step(b->thr, b->io, r.deadline_ms,
                b->max_no_progress, &r.step);
            r.receipt_valid = r.status == 0;
            if (r.receipt_valid) r.queue_full = r.step.queue_full;
        }
    }
    b->last = r;
    int restore = pthread_setcancelstate(saved, NULL);
    if (restore) { b->last.cancel_restore_status = restore; b->last.queue_full = true; }
    return b->last.queue_full;
}
