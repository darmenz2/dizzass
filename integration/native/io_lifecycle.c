/* GPL-3.0-or-later. Compose existing RX/TX/submit, never operate hardware. */
#define _POSIX_C_SOURCE 200809L
#include "integration/native/io_lifecycle.h"
#include "integration/native/io_queue_scope.h"
#include <errno.h>
#include <pthread.h>
#include <stdlib.h>
#include <time.h>

struct dizzass_io_lifecycle {
    pthread_mutex_t lock;
    pthread_cond_t changed;
    struct dizzass_rx_owner *rx;
    struct dizzass_uart_channel *tx;
    struct dizzass_rx_owner_config config;
    struct dizzass_io_report state;
};
static void lock(struct dizzass_io_lifecycle *l)
{ if (pthread_mutex_lock(&l->lock)) abort(); }
static void unlock(struct dizzass_io_lifecycle *l)
{ if (pthread_mutex_unlock(&l->lock)) abort(); }
static int create_lifecycle(const struct dizzass_rx_owner_config *cfg,
    struct dizzass_uart_channel *tx, struct dizzass_io_lifecycle **out, bool require_crc5)
{
    if (!cfg || !tx || !out || *out) return EINVAL;
    struct dizzass_io_lifecycle *l = calloc(1, sizeof *l);
    if (!l) return ENOMEM;
    int e = pthread_mutex_init(&l->lock, NULL);
    if (e) { free(l); return e; }
    pthread_condattr_t a;
    e = pthread_condattr_init(&a);
    if (e) goto mutex_fail;
    e = pthread_condattr_setclock(&a, CLOCK_MONOTONIC);
    if (!e) e = pthread_cond_init(&l->changed, &a);
    int cleanup = pthread_condattr_destroy(&a);
    if (e) goto mutex_fail;
    if (cleanup) { e = cleanup; goto condition_fail; }
    e = require_crc5 ? dizzass_rx_owner_create_crc5(cfg, &l->rx) :
        dizzass_rx_owner_create(cfg, &l->rx);
    if (e) goto condition_fail;
    l->tx = tx; l->config = *cfg; *out = l;
    return 0;
condition_fail:
    (void)pthread_cond_destroy(&l->changed);
mutex_fail:
    (void)pthread_mutex_destroy(&l->lock); free(l); return e;
}
int dizzass_io_create(const struct dizzass_rx_owner_config *cfg,
    struct dizzass_uart_channel *tx, struct dizzass_io_lifecycle **out)
{ return create_lifecycle(cfg, tx, out, false); }
int dizzass_io_create_crc5(const struct dizzass_rx_owner_config *cfg,
    struct dizzass_uart_channel *tx, struct dizzass_io_lifecycle **out)
{ return create_lifecycle(cfg, tx, out, true); }
int dizzass_io_start(struct dizzass_io_lifecycle *l)
{
    if (!l) return EINVAL;
    int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (e) return e;
    lock(l);
    if (l->state.stop_requested) e = ECANCELED;
    else if (l->state.started) e = EALREADY;
    else {
        e = dizzass_rx_owner_start(l->rx);
        if (e) l->state.stop_requested = true;
        else l->state.started = true;
    }
    unlock(l);
    int restore = pthread_setcancelstate(saved, NULL);
    return e ? e : restore;
}
int dizzass_io_request_stop(struct dizzass_io_lifecycle *l)
{
    if (!l) return EINVAL;
    int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (e) return e;
    lock(l); l->state.stop_requested = true; unlock(l);
    e = dizzass_rx_owner_request_stop(l->rx);
    int restore = pthread_setcancelstate(saved, NULL);
    return e ? e : restore;
}
/* Caller holds the queue adapter's cancellation exclusion across this pair.
 * Separate from active_tx: nested io_send_work must not double-count producers.
 */
int dizzass_io_queue_enter(struct dizzass_io_lifecycle *l)
{
    if (!l) return EINVAL;
    int e = 0;
    lock(l);
    if (l->state.stop_requested) e = ECANCELED;
    else if (!l->state.started) e = ENOTCONN;
    else if (dizzass_rx_owner_finished(l->rx)) {
        l->state.stop_requested = true; e = EPIPE;
    } else if (l->state.active_queue == SIZE_MAX) e = EOVERFLOW;
    else ++l->state.active_queue;
    unlock(l);
    return e;
}
void dizzass_io_queue_leave(struct dizzass_io_lifecycle *l)
{
    lock(l);
    if (!l->state.active_queue) abort();
    --l->state.active_queue;
    if (pthread_cond_broadcast(&l->changed)) abort();
    unlock(l);
    /* No reference to l after releasing the scope. */
}
/* saved remains disabled until output AND wrapper accounting are committed. */
static int begin(struct dizzass_io_lifecycle *l, int *saved)
{
    int e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, saved);
    if (e) return e;
    lock(l);
    if (l->state.stop_requested) e = ECANCELED;
    else if (!l->state.started) e = ENOTCONN;
    else if (dizzass_rx_owner_finished(l->rx)) {
        l->state.stop_requested = true; e = EPIPE;
    } else if (l->state.active_tx == SIZE_MAX) e = EOVERFLOW;
    else ++l->state.active_tx;
    unlock(l);
    if (e) (void)pthread_setcancelstate(*saved, NULL);
    return e;
}
static int end(struct dizzass_io_lifecycle *l, int saved)
{
    lock(l);
    if (!l->state.active_tx) abort();
    --l->state.active_tx;
    if (pthread_cond_broadcast(&l->changed)) abort();
    unlock(l);
    /* No reference to l after this point. */
    return pthread_setcancelstate(saved, NULL);
}
int dizzass_io_send_work(struct dizzass_io_lifecycle *l, uint32_t platform,
    uint32_t algorithm, uint32_t slot, uint32_t variant, const struct work *work,
    uint64_t deadline, unsigned budget, struct dizzass_io_work_receipt *out)
{
    if (!l || !work || !out || !budget) return EINVAL;
    int saved, e = begin(l, &saved);
    if (e) return e;
    struct dizzass_io_work_receipt r = {0};
    r.send = dizzass_native_job_channel_send(l->config.jobs, l->tx,
        l->config.received_epoch, platform, algorithm, slot, variant, work, deadline, budget);
    r.notify_status = dizzass_rx_owner_notify(l->rx);
    if (r.notify_status || (r.send.finish_called &&
        (r.send.outcome != DIZZASS_TX_WRITTEN || r.send.finish_status)))
        (void)dizzass_io_request_stop(l);
    *out = r;
    return end(l, saved);
}
int dizzass_io_send_command(struct dizzass_io_lifecycle *l,
    enum dizzass_bm1368_command cmd, uint32_t broadcast, uint32_t address,
    uint32_t reg, uint32_t value, uint64_t deadline, unsigned budget,
    struct dizzass_io_command_receipt *out)
{
    if (!l || !out || !budget) return EINVAL;
    int saved, e = begin(l, &saved);
    if (e) return e;
    struct dizzass_io_command_receipt r = {0};
    r.send = dizzass_channel_bm1368_command(l->tx, cmd, broadcast, address,
        reg, value, deadline, budget);
    r.notify_status = dizzass_rx_owner_notify(l->rx);
    if (r.notify_status || (r.send.channel_called &&
        (r.send.transport.status != DIZZASS_UART_OK ||
         r.send.transport.written != r.send.frame_size || r.send.transport.error)))
        (void)dizzass_io_request_stop(l);
    *out = r;
    return end(l, saved);
}
static int wait_tx(struct dizzass_io_lifecycle *l, uint64_t deadline)
{
    _Static_assert((time_t)-1 < 0, "signed Linux time_t required");
    _Static_assert(sizeof(time_t) == 4 || sizeof(time_t) == 8, "time_t width");
    uint64_t seconds = deadline / 1000;
    int e = 0;
    lock(l);
    while (l->state.active_tx || l->state.active_queue) {
        if (sizeof(time_t) == 4 && seconds > INT32_MAX) { e = EOVERFLOW; break; }
        uint64_t now;
        e = dizzass_uart_posix_now_ms(&now);
        if (e || now >= deadline) { if (!e) e = ETIMEDOUT; break; }
        struct timespec until = {(time_t)seconds, (long)(deadline % 1000) * 1000000L};
        e = pthread_cond_timedwait(&l->changed, &l->lock, &until);
        if (e && e != ETIMEDOUT) break;
        e = 0;
    }
    unlock(l);
    return e;
}
int dizzass_io_stop(struct dizzass_io_lifecycle *l, uint64_t deadline,
    struct dizzass_io_report *out)
{
    if (!l || !out) return EINVAL;
    int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (e) return e;
    struct dizzass_io_report r;
    lock(l); r = l->state; l->state.stop_requested = true; unlock(l);
    r.stop_requested = true;
    if (!r.quiescent) {
        r.rx_wake_status = dizzass_rx_owner_request_stop(l->rx);
        r.initial_tx_stop_status = dizzass_uart_channel_stop(l->tx, 0);
        r.submit_stop_status = dizzass_submitter_stop(l->config.submitter);
        if (r.started && !r.rx_joined) {
            r.rx_join_status = dizzass_rx_owner_join(l->rx, &r.rx);
            if (!r.rx_join_status) r.rx_joined = true;
        }
        r.tx_wait_status = wait_tx(l, deadline);
        r.final_tx_stop_status = dizzass_uart_channel_stop(l->tx, deadline);
        e = r.submit_stop_status ? r.submit_stop_status : r.rx_join_status ?
            r.rx_join_status : r.tx_wait_status ? r.tx_wait_status : r.final_tx_stop_status;
        if (!e) {
            r.pause_status = dizzass_jobs_pause(l->config.jobs, l->config.received_epoch);
            if (!r.pause_status) r.jobs_paused = true;
            e = r.pause_status;
        }
        r.quiescent = !e;
    }
    lock(l); r.active_tx = l->state.active_tx; r.active_queue = l->state.active_queue; r.rx_finished = dizzass_rx_owner_finished(l->rx); l->state = r; *out = r; unlock(l);
    int restore = pthread_setcancelstate(saved, NULL);
    if (restore) { lock(l); l->state.cancel_restore_status = restore;
        out->cancel_restore_status = restore; unlock(l); }
    return e ? e : restore;
}
int dizzass_io_snapshot(struct dizzass_io_lifecycle *l, struct dizzass_io_report *out)
{
    if (!l || !out) return EINVAL;
    lock(l); *out = l->state; out->rx_finished = dizzass_rx_owner_finished(l->rx); unlock(l); return 0;
}
int dizzass_io_destroy(struct dizzass_io_lifecycle **pointer)
{
    if (!pointer || !*pointer) return EINVAL;
    int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (e) return e;
    struct dizzass_io_lifecycle *l = *pointer;
    if (l->state.active_tx || l->state.active_queue || (!l->state.quiescent &&
        (l->state.started || l->state.stop_requested))) e = EBUSY;
    else {
        e = dizzass_rx_owner_destroy(&l->rx);
        if (!l->rx) {
            if (pthread_cond_destroy(&l->changed) || pthread_mutex_destroy(&l->lock)) abort();
            free(l); *pointer = NULL;
        }
    }
    int restore = pthread_setcancelstate(saved, NULL);
    return e ? e : restore;
}
