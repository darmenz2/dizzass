/* GPL-3.0-or-later. Reuse core queue ownership and the existing managed TX. */
#include "config.h"
#include "miner.h"
#include "integration/native/queued_work_tx.h"
#include <errno.h>
#include <math.h>

int dizzass_queued_work_send(struct thr_info *thr, struct dizzass_io_lifecycle *io,
    const struct dizzass_queued_tx_plan *p, struct dizzass_queued_tx_receipt *out)
{
    if (!thr || !thr->cgpu || !thr->cgpu->drv || thr->id < 0 || !io || !p || !out ||
        p->platform != 2 || p->algorithm != 0 || p->variant != 2 ||
        p->slot >= DIZZASS_JOB_SLOTS || !p->max_no_progress)
        return EINVAL;
    int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (rc) return rc;
    struct dizzass_io_report state;
    uint64_t now;
    rc = dizzass_io_snapshot(io, &state);
    if (rc) goto done;
    if (state.stop_requested || state.quiescent || state.rx_finished) {
        rc = ECANCELED; goto done;
    }
    if (!state.started) { rc = ENOTCONN; goto done; }
    rc = dizzass_uart_posix_now_ms(&now);
    if (rc) goto done;
    if (now >= p->deadline_ms) { rc = ETIMEDOUT; goto done; }

    struct dizzass_queued_tx_receipt r = {0};
    struct work *work = get_queued(thr->cgpu);
    if (work) {
        r.dequeued = true; r.work_id = work->id; r.work_thr_id = work->thr_id;
        if (work->thr_id != thr->id) r.work_status = DIZZASS_SUBMIT_WRONG_THREAD;
        else if (!work->stratum || !work->pool || !work->job_id ||
            !work->nonce1 || !work->ntime ||
            !isfinite(work->work_difficulty) || work->work_difficulty <= 0 ||
            !isfinite(work->device_diff) || work->device_diff <= 0)
            r.work_status = DIZZASS_SUBMIT_UNSUPPORTED_WORK;
        else {
            r.send_called = true;
            r.send_status = dizzass_io_send_work(io, p->platform, p->algorithm,
                p->slot, p->variant, work, p->deadline_ms, p->max_no_progress, &r.send);
        }
        work_completed(thr->cgpu, work);
        r.completed = true;
    }
    *out = r;
done:
    {
        int restore = pthread_setcancelstate(saved, NULL);
        return rc ? rc : restore;
    }
}
