/* Native cgminer job lifetime adapter. GPL-3.0-or-later. */
#include "config.h"
#include "miner.h"
#include "integration/native_jobs.h"

enum slot_state { SLOT_EMPTY, SLOT_PREPARED, SLOT_WRITTEN, SLOT_QUARANTINE };
struct job_slot {
    struct work *work;
    uint64_t serial;
    uint32_t variant;
    uint32_t version_base_word;
    enum slot_state state;
};
struct dizzass_jobs {
    pthread_mutex_t lock;
    uint32_t chain_id;
    uint64_t epoch;
    uint64_t serial;
    bool paused;
    struct job_slot slots[DIZZASS_JOB_SLOTS];
};

static void jobs_lock(struct dizzass_jobs *jobs)
{
    if (pthread_mutex_lock(&jobs->lock))
        abort();
}
static void jobs_unlock(struct dizzass_jobs *jobs)
{
    if (pthread_mutex_unlock(&jobs->lock))
        abort();
}
static void release_slot(struct job_slot *slot, enum slot_state state)
{
    if (slot->work)
        free_work(slot->work);
    slot->state = state;
}
static int epoch_status(const struct dizzass_jobs *jobs, uint64_t epoch)
{
    return epoch == jobs->epoch ? DIZZASS_JOBS_OK : DIZZASS_JOBS_OLD_EPOCH;
}
static int ticket_status(const struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket)
{
    if (!ticket || !ticket->epoch || !ticket->serial ||
        ticket->slot >= DIZZASS_JOB_SLOTS)
        return DIZZASS_JOBS_INVALID;
    if (ticket->chain_id != jobs->chain_id)
        return DIZZASS_JOBS_WRONG_CHAIN;
    if (ticket->epoch != jobs->epoch)
        return DIZZASS_JOBS_OLD_EPOCH;
    if (ticket->serial != jobs->slots[ticket->slot].serial)
        return DIZZASS_JOBS_STALE_TICKET;
    return DIZZASS_JOBS_OK;
}
static int slot_status(const struct job_slot *slot)
{
    switch (slot->state) {
    case SLOT_EMPTY: return DIZZASS_JOBS_EMPTY;
    case SLOT_PREPARED: return DIZZASS_JOBS_PENDING;
    case SLOT_QUARANTINE: return DIZZASS_JOBS_QUARANTINED;
    case SLOT_WRITTEN: return DIZZASS_JOBS_OK;
    }
    abort();
}
static uint32_t work_version(const struct work *work)
{
    const unsigned char *p = work->data;
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 |
           (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}
static bool copy_complete(const struct work *source, const struct work *copy)
{
    return copy && (!source->job_id || copy->job_id) &&
        (!source->nonce1 || copy->nonce1) && (!source->ntime || copy->ntime) &&
        (!source->coinbase || copy->coinbase);
}

int dizzass_jobs_create(uint32_t chain_id, uint64_t initial_epoch,
    struct dizzass_jobs **out)
{
    struct dizzass_jobs *jobs;
    if (!out || *out || !initial_epoch)
        return DIZZASS_JOBS_INVALID;
    jobs = calloc(1, sizeof(*jobs));
    if (!jobs)
        return DIZZASS_JOBS_NOMEM;
    if (pthread_mutex_init(&jobs->lock, NULL)) {
        free(jobs);
        return DIZZASS_JOBS_LOCK_ERROR;
    }
    jobs->chain_id = chain_id;
    jobs->epoch = initial_epoch;
    *out = jobs;
    return DIZZASS_JOBS_OK;
}

void dizzass_jobs_destroy(struct dizzass_jobs **pointer)
{
    unsigned i;
    struct dizzass_jobs *jobs;
    if (!pointer || !*pointer)
        return;
    jobs = *pointer;
    /* Lifetime exclusion is the caller's obligation, as for pthread locks. */
    for (i = 0; i < DIZZASS_JOB_SLOTS; ++i)
        release_slot(&jobs->slots[i], SLOT_EMPTY);
    if (pthread_mutex_destroy(&jobs->lock))
        abort();
    free(jobs);
    *pointer = NULL;
}

int dizzass_jobs_prepare(struct dizzass_jobs *jobs, uint64_t expected_epoch,
    uint32_t slot_number, uint32_t variant, uint32_t version_base_word,
    const struct work *source, struct dizzass_job_ticket *out)
{
    struct work *copy;
    struct job_slot *slot;
    struct dizzass_job_ticket ticket;
    int rc;
    if (!jobs || !source || !out || slot_number >= DIZZASS_JOB_SLOTS ||
        variant > 2 || out->epoch || out->serial || out->chain_id || out->slot)
        return DIZZASS_JOBS_INVALID;
    if (version_base_word & ~work_version(source))
        return DIZZASS_NONCE_WRONG_VERSION;
    jobs_lock(jobs);
    rc = epoch_status(jobs, expected_epoch);
    if (rc) goto done;
    if (jobs->paused) { rc = DIZZASS_JOBS_PAUSED; goto done; }
    slot = &jobs->slots[slot_number];
    if (slot->state == SLOT_QUARANTINE) {
        rc = DIZZASS_JOBS_QUARANTINED; goto done;
    }
    if (slot->state != SLOT_EMPTY) { rc = DIZZASS_JOBS_BUSY; goto done; }
    if (jobs->serial == UINT64_MAX) { rc = DIZZASS_JOBS_EXHAUSTED; goto done; }
    copy = copy_work_noffset((struct work *)source, 0);
    if (!copy_complete(source, copy)) {
        if (copy) free_work(copy);
        rc = DIZZASS_NONCE_PARTIAL_COPY;
        goto done;
    }
    ticket.epoch = jobs->epoch;
    ticket.serial = ++jobs->serial;
    ticket.chain_id = jobs->chain_id;
    ticket.slot = slot_number;
    slot->work = copy;
    slot->serial = ticket.serial;
    slot->variant = variant;
    slot->version_base_word = version_base_word;
    slot->state = SLOT_PREPARED;
    *out = ticket;
    rc = DIZZASS_JOBS_OK;
done:
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_finish(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket, enum dizzass_tx_result outcome)
{
    struct job_slot *slot;
    int rc;
    if (!jobs || (outcome != DIZZASS_TX_WRITTEN &&
        outcome != DIZZASS_TX_NOT_SENT && outcome != DIZZASS_TX_UNCERTAIN))
        return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = ticket_status(jobs, ticket);
    if (rc) goto done;
    if (jobs->paused) { rc = DIZZASS_JOBS_PAUSED; goto done; }
    slot = &jobs->slots[ticket->slot];
    if (slot->state != SLOT_PREPARED) { rc = DIZZASS_JOBS_STALE_TICKET; goto done; }
    if (outcome == DIZZASS_TX_WRITTEN)
        slot->state = SLOT_WRITTEN;
    else
        release_slot(slot, outcome == DIZZASS_TX_NOT_SENT ? SLOT_EMPTY : SLOT_QUARANTINE);
done:
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_retire(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket)
{
    int rc;
    if (!jobs) return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = ticket_status(jobs, ticket);
    if (!rc && jobs->paused) rc = DIZZASS_JOBS_PAUSED;
    if (!rc) rc = slot_status(&jobs->slots[ticket->slot]);
    if (!rc) release_slot(&jobs->slots[ticket->slot], SLOT_QUARANTINE);
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_pause(struct dizzass_jobs *jobs, uint64_t expected_epoch)
{
    unsigned i;
    int rc;
    if (!jobs) return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = epoch_status(jobs, expected_epoch);
    if (!rc) {
        jobs->paused = true;
        for (i = 0; i < DIZZASS_JOB_SLOTS; ++i)
            if (jobs->slots[i].state != SLOT_EMPTY)
                release_slot(&jobs->slots[i], SLOT_QUARANTINE);
    }
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_begin_drained_epoch(struct dizzass_jobs *jobs,
    uint64_t expected_epoch, uint64_t next_epoch)
{
    unsigned i;
    int rc;
    if (!jobs || !next_epoch || next_epoch <= expected_epoch)
        return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = epoch_status(jobs, expected_epoch);
    if (!rc && !jobs->paused) rc = DIZZASS_JOBS_BUSY;
    if (!rc) {
        for (i = 0; i < DIZZASS_JOB_SLOTS; ++i) {
            release_slot(&jobs->slots[i], SLOT_EMPTY);
            jobs->slots[i].serial = 0;
        }
        jobs->epoch = next_epoch;
        jobs->paused = false;
    }
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_check(struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_job_result *out)
{
    struct dizzass_job_result result = {0};
    struct dizzass_nonce_match match;
    struct job_slot *slot;
    int rc;
    if (!jobs || !reply || !out || out->check.work ||
        reply->slot >= DIZZASS_JOB_SLOTS || reply->variant > 2)
        return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = epoch_status(jobs, received_epoch);
    if (rc) goto done;
    if (reply->chain_id != jobs->chain_id) { rc = DIZZASS_JOBS_WRONG_CHAIN; goto done; }
    if (jobs->paused) { rc = DIZZASS_JOBS_PAUSED; goto done; }
    slot = &jobs->slots[reply->slot];
    rc = slot_status(slot);
    if (rc) goto done;
    match.work = slot->work;
    match.chain_id = jobs->chain_id;
    match.slot = reply->slot;
    match.variant = slot->variant;
    match.version_base_word = slot->version_base_word;
    rc = dizzass_nonce_check_matched(&match, reply, &result.check);
    if (rc) goto done;
    result.ticket.epoch = jobs->epoch;
    result.ticket.serial = slot->serial;
    result.ticket.chain_id = jobs->chain_id;
    result.ticket.slot = reply->slot;
    *out = result;
done:
    jobs_unlock(jobs);
    return rc;
}

void dizzass_job_result_clear(struct dizzass_job_result *result)
{
    if (!result) return;
    dizzass_nonce_check_clear(&result->check);
    memset(&result->ticket, 0, sizeof(result->ticket));
}

int dizzass_jobs_ticket_live(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket)
{
    int rc;
    if (!jobs) return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = ticket_status(jobs, ticket);
    if (!rc && jobs->paused) rc = DIZZASS_JOBS_PAUSED;
    if (!rc) rc = slot_status(&jobs->slots[ticket->slot]);
    jobs_unlock(jobs);
    return rc;
}
