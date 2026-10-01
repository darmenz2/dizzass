/* GPL-3.0-or-later. No hardware I/O; native work stays in native_jobs. */
#include "integration/native/early_rx.h"
#include <stdlib.h>
#include <string.h>
struct early_entry {
    struct dizzass_nonce_reply reply;
    struct dizzass_job_ticket ticket;
};
struct dizzass_early_rx {
    struct dizzass_jobs *jobs;
    uint32_t chain;
    uint64_t epoch;
    size_t count, capacity;
    int stopped;
    struct early_entry entries[];
};
int dizzass_early_rx_create(struct dizzass_jobs *jobs, uint32_t chain,
    uint64_t epoch, size_t capacity, struct dizzass_early_rx **out)
{
    if (!jobs || !epoch || !out || *out || !capacity ||
        capacity > DIZZASS_EARLY_RX_MAX_CAPACITY)
        return DIZZASS_EARLY_RX_INVALID;
    struct dizzass_early_rx *q = calloc(1, sizeof *q + capacity * sizeof q->entries[0]);
    if (!q) return DIZZASS_EARLY_RX_NOMEM;
    q->jobs = jobs; q->chain = chain; q->epoch = epoch; q->capacity = capacity;
    *out = q;
    return 0;
}
int dizzass_early_rx_offer(struct dizzass_early_rx *q, uint64_t epoch,
    const struct dizzass_nonce_reply *reply)
{
    struct dizzass_job_ticket ticket = {0};
    if (!q || !reply) return DIZZASS_EARLY_RX_INVALID;
    if (q->stopped) return q->stopped;
    if (epoch != q->epoch) return DIZZASS_JOBS_OLD_EPOCH;
    if (reply->chain_id != q->chain) return DIZZASS_JOBS_WRONG_CHAIN;
    int rc = dizzass_jobs_capture_reply(q->jobs, epoch, reply, &ticket);
    if (rc) return rc;
    if (q->count == q->capacity) {
        q->stopped = DIZZASS_EARLY_RX_OVERFLOW;
        return q->stopped;
    }
    q->entries[q->count++] = (struct early_entry){*reply, ticket};
    return 0;
}
static int terminal_rejection(int rc)
{
    return rc == DIZZASS_JOBS_WRONG_CHAIN || rc == DIZZASS_JOBS_OLD_EPOCH ||
        rc == DIZZASS_JOBS_STALE_TICKET || rc == DIZZASS_JOBS_EMPTY ||
        rc == DIZZASS_JOBS_QUARANTINED || rc == DIZZASS_JOBS_PAUSED ||
        rc == DIZZASS_NONCE_WRONG_SLOT || rc == DIZZASS_NONCE_WRONG_FORMAT ||
        rc == DIZZASS_NONCE_WRONG_VERSION;
}
static void remove_entry(struct dizzass_early_rx *q, size_t i)
{
    --q->count;
    memmove(&q->entries[i], &q->entries[i+1],
        (q->count - i) * sizeof q->entries[0]);
    memset(&q->entries[q->count], 0, sizeof q->entries[0]);
}
int dizzass_early_rx_take(struct dizzass_early_rx *q, struct dizzass_early_rx_event *out)
{
    if (!q || !out || out->result.check.work) return DIZZASS_EARLY_RX_INVALID;
    if (q->stopped) return q->stopped;
    if (!q->count) return DIZZASS_EARLY_RX_EMPTY;
    for (size_t i = 0; i < q->count; ++i) {
        struct dizzass_early_rx_event event = {0};
        event.reply = q->entries[i].reply; event.captured = q->entries[i].ticket;
        int rc = dizzass_jobs_check_captured(q->jobs, &event.captured,
            &event.reply, &event.result);
        if (rc == DIZZASS_JOBS_PENDING) continue;
        /* Unknown/recoverable errors are never silently consumed. */
        if (rc && !terminal_rejection(rc)) return rc;
        event.job_status = rc;
        remove_entry(q, i);
        *out = event;
        return 0;
    }
    return DIZZASS_EARLY_RX_WAITING;
}
void dizzass_early_rx_event_clear(struct dizzass_early_rx_event *event)
{
    if (!event) return;
    dizzass_job_result_clear(&event->result);
    memset(event, 0, sizeof *event);
}
size_t dizzass_early_rx_size(const struct dizzass_early_rx *q)
{
    return q ? q->count : 0;
}
int dizzass_early_rx_stop(struct dizzass_early_rx *q)
{
    if (!q) return DIZZASS_EARLY_RX_INVALID;
    if (!q->stopped) q->stopped = DIZZASS_EARLY_RX_STOPPED;
    return 0;
}
void dizzass_early_rx_destroy(struct dizzass_early_rx **pointer)
{
    if (!pointer || !*pointer) return;
    free(*pointer); *pointer = NULL;
}

int dizzass_early_rx_dispatch(struct dizzass_early_rx *q,
    struct dizzass_submitter *submitter, struct dizzass_early_rx_submission *out)
{
    if (!q || !submitter || !out) return DIZZASS_EARLY_RX_INVALID;
    if (q->stopped) return q->stopped;
    if (!q->count) return DIZZASS_EARLY_RX_EMPTY;
    for (size_t i = 0; i < q->count; ++i) {
        struct dizzass_early_rx_submission event = {0};
        event.reply = q->entries[i].reply;
        event.captured = q->entries[i].ticket;
        int rc = dizzass_submitter_run_captured(submitter, q->jobs,
            &event.captured, &event.reply, &event.result);
        if (rc == DIZZASS_JOBS_PENDING) continue;
        if (rc && !terminal_rejection(rc)) return rc;
        event.job_status = rc;
        event.native_called = rc == 0;
        remove_entry(q, i);
        *out = event;
        return 0;
    }
    return DIZZASS_EARLY_RX_WAITING;
}
