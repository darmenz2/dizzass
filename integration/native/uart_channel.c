/* SPDX-License-Identifier: GPL-3.0-only */
#define _POSIX_C_SOURCE 200809L
#include "integration/native/uart_channel.h"
#include <errno.h>
#include <pthread.h>
#include <stdlib.h>
#include <time.h>

struct dizzass_uart_channel {
    pthread_mutex_t mutex;
    pthread_cond_t changed;
    int fd;
    struct dizzass_uart_channel_state state;
    bool condition_destroyed;
};

static struct dizzass_uart_result answer(enum dizzass_uart_status s, int e)
{
    return (struct dizzass_uart_result){s, 0, e};
}

/* Supported Linux time_t widths; reject overflow instead of wrapping waits. */
static int deadline_time(uint64_t ms, struct timespec *out)
{
    _Static_assert((time_t)-1 < 0, "signed Linux time_t required");
    _Static_assert(sizeof(time_t) == 4 || sizeof(time_t) == 8, "time_t width");
    uint64_t seconds = ms / 1000u;
    if (sizeof(time_t) == 4 && seconds > INT32_MAX) return EOVERFLOW;
    out->tv_sec = (time_t)seconds;
    out->tv_nsec = (long)(ms % 1000u) * 1000000L;
    return 0;
}

static int enter(struct dizzass_uart_channel *c, int *saved)
{
    int e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, saved);
    if (e) return e;
    e = pthread_mutex_lock(&c->mutex);
    if (e) (void)pthread_setcancelstate(*saved, NULL);
    return e;
}

static int leave(struct dizzass_uart_channel *c, int saved)
{
    int e = pthread_mutex_unlock(&c->mutex);
    int restore = pthread_setcancelstate(saved, NULL);
    return e ? e : restore;
}

int dizzass_uart_channel_create(struct dizzass_uart_channel **out, int fd)
{
    if (!out || *out || fd < 0) return EINVAL;
    struct dizzass_uart_channel *c = calloc(1, sizeof *c);
    if (!c) return ENOMEM;
    int e = pthread_mutex_init(&c->mutex, NULL);
    if (e) { free(c); return e; }
    pthread_condattr_t attributes;
    e = pthread_condattr_init(&attributes);
    if (e) { (void)pthread_mutex_destroy(&c->mutex); free(c); return e; }
    e = pthread_condattr_setclock(&attributes, CLOCK_MONOTONIC);
    if (!e) e = pthread_cond_init(&c->changed, &attributes);
    int cleanup = pthread_condattr_destroy(&attributes);
    if (e || cleanup) {
        if (!e) (void)pthread_cond_destroy(&c->changed);
        (void)pthread_mutex_destroy(&c->mutex);
        free(c);
        return e ? e : cleanup;
    }
    c->fd = fd;
    *out = c;
    return 0;
}

struct dizzass_uart_result dizzass_uart_channel_send(struct dizzass_uart_channel *c,
    const uint8_t *data, size_t length, uint64_t deadline, unsigned budget)
{
    if (!c || (length && (!data || !budget)))
        return answer(DIZZASS_UART_INVALID_INPUT, EINVAL);
    if (length > (size_t)PTRDIFF_MAX)
        return answer(DIZZASS_UART_INVALID_INPUT, EOVERFLOW);
    struct timespec until;
    int e = length ? deadline_time(deadline, &until) : 0;
    if (e) return answer(DIZZASS_UART_INVALID_INPUT, e);
    int saved;
    e = enter(c, &saved);
    if (e) return answer(DIZZASS_UART_WAIT_ERROR, e);
    struct dizzass_uart_result r;
    for (;;) {
        if (c->state.stopped) { r = answer(DIZZASS_UART_CANCELED, ECANCELED); break; }
        if (!length) { r = answer(DIZZASS_UART_OK, 0); break; }
        uint64_t now;
        e = dizzass_uart_posix_now_ms(&now);
        if (e) { r = answer(DIZZASS_UART_CLOCK_ERROR, e); break; }
        if (now >= deadline) { r = answer(DIZZASS_UART_TIMEOUT, ETIMEDOUT); break; }
        if (!c->state.active) {
            c->state.active = true;
            e = pthread_mutex_unlock(&c->mutex);
            if (e) {
                c->state.active = false;
                c->state.stopped = true;
                (void)leave(c, saved);
                return answer(DIZZASS_UART_WAIT_ERROR, e);
            }
            /* Ownership spans the ENTIRE unchanged A-13 call, including poll. */
            r = dizzass_uart_posix_write_all(c->fd, data, length, deadline, budget);
            e = pthread_mutex_lock(&c->mutex);
            if (e) {
                /* Under valid nonrobust-mutex lifetime this cannot fail. Do not
                 * falsely publish quiescence; fd remains borrowed on failure. */
                (void)pthread_setcancelstate(saved, NULL);
                if (r.status == DIZZASS_UART_OK) { r.status = DIZZASS_UART_WAIT_ERROR; r.error = e; }
                return r;
            }
            if (r.status != DIZZASS_UART_OK) c->state.stopped = true;
            c->state.last = r;
            c->state.has_result = true;
            c->state.active = false;
            e = pthread_cond_broadcast(&c->changed);
            if (e) {
                c->state.stopped = true;
                if (r.status == DIZZASS_UART_OK) { r.status = DIZZASS_UART_WAIT_ERROR; r.error = e; }
                c->state.last = r;
            }
            break;
        }
        if (c->state.waiting == SIZE_MAX) { r = answer(DIZZASS_UART_WAIT_ERROR, EOVERFLOW); break; }
        ++c->state.waiting;
        e = pthread_cond_timedwait(&c->changed, &c->mutex, &until);
        --c->state.waiting;
        if (e && e != ETIMEDOUT) { r = answer(DIZZASS_UART_WAIT_ERROR, e); break; }
        /* Recheck STOP, time and active even after timeout or a spurious wake. */
    }
    e = leave(c, saved);
    if (e && r.status == DIZZASS_UART_OK) { r.status = DIZZASS_UART_WAIT_ERROR; r.error = e; }
    return r;
}

int dizzass_uart_channel_stop(struct dizzass_uart_channel *c, uint64_t deadline)
{
    if (!c) return EINVAL;
    int saved, e = enter(c, &saved);
    if (e) return e;
    c->state.stopped = true;
    e = pthread_cond_broadcast(&c->changed);
    struct timespec until;
    if (!e && c->state.active) e = deadline_time(deadline, &until);
    while (!e && c->state.active) {
        uint64_t now;
        e = dizzass_uart_posix_now_ms(&now);
        if (e) break;
        if (now >= deadline) { e = ETIMEDOUT; break; }
        e = pthread_cond_timedwait(&c->changed, &c->mutex, &until);
        if (e == ETIMEDOUT) e = 0; /* Predicate/time must be read again. */
    }
    int cleanup = leave(c, saved);
    return e ? e : cleanup;
}

int dizzass_uart_channel_snapshot(struct dizzass_uart_channel *c,
    struct dizzass_uart_channel_state *out)
{
    if (!c || !out) return EINVAL;
    int saved, e = enter(c, &saved);
    if (e) return e;
    *out = c->state;
    return leave(c, saved);
}

int dizzass_uart_channel_destroy(struct dizzass_uart_channel **pointer)
{
    if (!pointer || !*pointer) return EINVAL;
    /* EXTERNAL reference quiescence is mandatory here, not supplied by stop. */
    struct dizzass_uart_channel *c = *pointer;
    if (!c->state.stopped || c->state.active || c->state.waiting) return EBUSY;
    int e = 0;
    if (!c->condition_destroyed) {
        e = pthread_cond_destroy(&c->changed);
        if (e) return e;
        c->condition_destroyed = true;
    }
    e = pthread_mutex_destroy(&c->mutex);
    if (e) return e;
    free(c);
    *pointer = NULL;
    return 0;
}
