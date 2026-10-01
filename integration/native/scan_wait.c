/* GPL-3.0-or-later. Reuse the native queued loop and managed IO snapshots. */
#include "config.h"
#include "miner.h"
#include "integration/native/scan_wait.h"
#include "integration/native/io_lifecycle.h"
#include <errno.h>

int dizzass_scan_wait_init(struct dizzass_scan_wait *s, struct thr_info *thr,
    struct dizzass_io_lifecycle *io, unsigned interval_ms)
{
    if (!s || !thr || !thr->cgpu || !thr->cgpu->drv || !io ||
        !interval_ms || interval_ms > 1000) return EINVAL;
    s->initialized = false;
    pthread_condattr_t attr;
    int rc = pthread_condattr_init(&attr);
    if (rc) return rc;
    rc = pthread_condattr_setclock(&attr, CLOCK_MONOTONIC);
    if (rc) { pthread_condattr_destroy(&attr); return rc; }
    rc = pthread_mutex_init(&s->lock, NULL);
    if (rc) { pthread_condattr_destroy(&attr); return rc; }
    rc = pthread_cond_init(&s->cond, &attr);
    pthread_condattr_destroy(&attr);
    if (rc) { pthread_mutex_destroy(&s->lock); return rc; }
    s->thr = thr; s->io = io; s->interval_ms = interval_ms;
    s->report = (struct dizzass_scan_report){0};
    s->initialized = true;
    return 0;
}

int dizzass_scan_wait_snapshot(struct dizzass_scan_wait *s,
    struct dizzass_scan_report *out)
{
    if (!s || !out || !s->initialized) return EINVAL;
    int rc = pthread_mutex_lock(&s->lock);
    if (rc) return rc;
    *out = s->report;
    return pthread_mutex_unlock(&s->lock);
}

int dizzass_scan_wait_destroy(struct dizzass_scan_wait *s)
{
    if (!s || !s->initialized) return EINVAL;
    int rc = pthread_mutex_lock(&s->lock);
    if (rc) return rc;
    bool busy = s->report.active;
    rc = pthread_mutex_unlock(&s->lock);
    if (rc || busy) return rc ? rc : EBUSY;
    rc = pthread_cond_destroy(&s->cond);
    if (rc) return rc;
    rc = pthread_mutex_destroy(&s->lock);
    if (!rc) s->initialized = false;
    return rc;
}

static struct dizzass_scan_wait *binding(struct thr_info *thr)
{
    if (!thr || !thr->cgpu || !thr->cgpu_data) return NULL;
    struct cgpu_info *g = thr->cgpu;
    struct dizzass_scan_wait *s = thr->cgpu_data;
    if (!s->initialized || s->thr != thr || !s->io || !g->drv ||
        g->threads != 1 || !g->thr || g->thr[0] != thr ||
        g->drv->scanwork != dizzass_scanwork ||
        g->drv->queued_stop_wake != dizzass_scan_stop_wake) return NULL;
    return s;
}

int dizzass_scan_stop_wake(struct cgpu_info *g)
{
    if (!g || g->threads != 1 || !g->thr || !g->thr[0] ||
        g->thr[0]->cgpu != g) return EINVAL;
    struct dizzass_scan_wait *s = binding(g->thr[0]);
    if (!s) return EINVAL;
    int rc = pthread_mutex_lock(&s->lock);
    if (rc) return rc;
    s->report.stop_requested = true;
    ++s->report.wake_requests;
    rc = pthread_cond_broadcast(&s->cond);
    int unlock = pthread_mutex_unlock(&s->lock);
    return rc ? rc : unlock;
}

static int io_active(struct dizzass_scan_wait *s)
{
    struct dizzass_io_report r;
    int rc = dizzass_io_snapshot(s->io, &r);
    if (rc) return rc;
    if (!r.started) return ENOTCONN;
    if (r.stop_requested || r.quiescent || r.rx_finished) return ECANCELED;
    return 0;
}

int64_t dizzass_scanwork(struct thr_info *thr)
{
    struct dizzass_scan_wait *s = binding(thr);
    if (!s) return -1;
    int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (rc) return -1;
    enum dizzass_scan_reason reason = DIZZASS_SCAN_TICK;
    rc = pthread_mutex_lock(&s->lock);
    if (rc) goto restore;
    if (s->report.active) {
        pthread_mutex_unlock(&s->lock); rc = EBUSY; goto restore;
    }
    s->report.active = true; ++s->report.calls;
    bool stop = s->report.stop_requested;
    pthread_mutex_unlock(&s->lock);
    if (stop || cgminer_queued_stopped(thr->cgpu)) {
        reason = DIZZASS_SCAN_STOP; goto publish;
    }
    rc = io_active(s);
    if (rc) { reason = DIZZASS_SCAN_IO_FAILURE; goto publish; }
    uint64_t now, end;
    rc = dizzass_uart_posix_now_ms(&now);
    if (!rc && now > UINT64_MAX - s->interval_ms) rc = EOVERFLOW;
    if (rc) { reason = DIZZASS_SCAN_WAIT_FAILURE; goto publish; }
    end = now + s->interval_ms;
    struct timespec deadline = {.tv_sec = (time_t)(end / 1000),
        .tv_nsec = (long)(end % 1000) * 1000000L};
    if (deadline.tv_sec < 0 || (uint64_t)deadline.tv_sec != end / 1000) {
        rc = EOVERFLOW; reason = DIZZASS_SCAN_WAIT_FAILURE; goto publish;
    }
    rc = pthread_mutex_lock(&s->lock);
    if (rc) goto restore; /* Broken synchronization object: fail closed. */
    while (!s->report.stop_requested) {
        s->report.waiting = true; ++s->report.wait_calls;
        rc = pthread_cond_timedwait(&s->cond, &s->lock, &deadline);
        s->report.waiting = false;
        if (rc == ETIMEDOUT) { rc = 0; break; }
        if (rc) { reason = DIZZASS_SCAN_WAIT_FAILURE; break; }
    }
    if (!rc && s->report.stop_requested) reason = DIZZASS_SCAN_STOP;
    pthread_mutex_unlock(&s->lock);
    if (!rc && reason == DIZZASS_SCAN_TICK) {
        if (cgminer_queued_stopped(thr->cgpu)) reason = DIZZASS_SCAN_STOP;
        else if ((rc = io_active(s))) reason = DIZZASS_SCAN_IO_FAILURE;
    }
publish:
    {
        int lock = pthread_mutex_lock(&s->lock);
        if (lock) { rc = lock; goto restore; }
        if (!rc && s->report.stop_requested) reason = DIZZASS_SCAN_STOP;
        s->report.reason = reason; s->report.status = rc;
        if (rc) ++s->report.failures;
        else if (reason == DIZZASS_SCAN_STOP) ++s->report.stops;
        else ++s->report.ticks;
        s->report.active = false;
        pthread_mutex_unlock(&s->lock);
    }
restore:
    {
        int restored = pthread_setcancelstate(saved, NULL);
        return rc || restored ? -1 : 0; /* Waiting never measures any hashes. */
    }
}
