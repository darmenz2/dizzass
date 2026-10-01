/* Native cgminer job lifetime adapter. GPL-3.0-or-later. */
#include "config.h"
#include "miner.h"
#include "integration/native_jobs.h"
#include "integration/native_submit.h"
#include <math.h>

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

static int jobs_check_locked(struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_job_result *out)
{
    struct dizzass_job_result result = {0};
    struct dizzass_nonce_match match;
    struct job_slot *slot;
    int rc;
    if (!jobs || !reply || !out || out->check.work ||
        reply->slot >= DIZZASS_JOB_SLOTS || reply->variant > 2)
        return DIZZASS_JOBS_INVALID;
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
    return rc;
}

int dizzass_jobs_check(struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_job_result *out)
{
    int rc;
    if (!jobs || !reply || !out || out->check.work ||
        reply->slot >= DIZZASS_JOB_SLOTS || reply->variant > 2)
        return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = jobs_check_locked(jobs, received_epoch, reply, out);
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_capture_reply(struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_job_ticket *out)
{
    int rc;
    struct job_slot *slot;
    struct dizzass_nonce_match match;
    if (!jobs || !reply || !out || out->epoch || out->serial || out->chain_id ||
        out->slot || reply->slot >= DIZZASS_JOB_SLOTS || reply->variant > 2)
        return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = epoch_status(jobs, received_epoch);
    if (rc) goto done;
    if (reply->chain_id != jobs->chain_id) { rc = DIZZASS_JOBS_WRONG_CHAIN; goto done; }
    if (jobs->paused) { rc = DIZZASS_JOBS_PAUSED; goto done; }
    slot = &jobs->slots[reply->slot];
    rc = slot_status(slot);
    if (rc != DIZZASS_JOBS_OK && rc != DIZZASS_JOBS_PENDING) goto done;
    match = (struct dizzass_nonce_match){slot->work, jobs->chain_id, reply->slot,
        slot->variant, slot->version_base_word};
    rc = dizzass_nonce_match_status(&match, reply);
    if (rc) goto done;
    *out = (struct dizzass_job_ticket){jobs->epoch, slot->serial,
        jobs->chain_id, reply->slot};
done:
    jobs_unlock(jobs);
    return rc;
}

int dizzass_jobs_check_captured(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket,
    const struct dizzass_nonce_reply *reply, struct dizzass_job_result *out)
{
    int rc;
    if (!jobs || !reply || !out || out->check.work ||
        reply->slot >= DIZZASS_JOB_SLOTS || reply->variant > 2)
        return DIZZASS_JOBS_INVALID;
    jobs_lock(jobs);
    rc = ticket_status(jobs, ticket);
    if (!rc && reply->chain_id != ticket->chain_id) rc = DIZZASS_JOBS_WRONG_CHAIN;
    if (!rc && reply->slot != ticket->slot) rc = DIZZASS_NONCE_WRONG_SLOT;
    /* Serial validation AND matching share this lock. Never rebind by slot. */
    if (!rc) rc = jobs_check_locked(jobs, ticket->epoch, reply, out);
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

/* A device-wide gate serializes upstream last_nonce/accounting across chains.
 * Kept here to admit from the private registry without exposing slot pointers.
 */
struct dizzass_submitter {
    pthread_mutex_t lock;
    struct thr_info *thr;
    struct cgpu_info *cgpu;
    int thr_id;
    bool stopped;
};

int dizzass_submitter_create(struct thr_info *thr, struct dizzass_submitter **out)
{
    struct dizzass_submitter *gate;
    if (!thr || !thr->cgpu || !thr->cgpu->drv ||
        !thr->cgpu->drv->hw_error || !thr->cgpu->drv->name ||
        thr->id < 0 || !out || *out)
        return DIZZASS_SUBMIT_INVALID;
    gate = calloc(1, sizeof(*gate));
    if (!gate) return DIZZASS_JOBS_NOMEM;
    if (pthread_mutex_init(&gate->lock, NULL)) {
        free(gate);
        return DIZZASS_JOBS_LOCK_ERROR;
    }
    gate->thr = thr;
    gate->cgpu = thr->cgpu;
    gate->thr_id = thr->id;
    *out = gate;
    return 0;
}

int dizzass_submitter_stop(struct dizzass_submitter *gate)
{
    if (!gate) return DIZZASS_SUBMIT_INVALID;
    if (pthread_mutex_lock(&gate->lock)) abort();
    gate->stopped = true;
    if (pthread_mutex_unlock(&gate->lock)) abort();
    return 0;
}

void dizzass_submitter_destroy(struct dizzass_submitter **pointer)
{
    struct dizzass_submitter *gate;
    if (!pointer || !*pointer) return;
    gate = *pointer;
    if (pthread_mutex_destroy(&gate->lock)) abort();
    free(gate);
    *pointer = NULL;
}

static int admit_submission(struct dizzass_submitter *gate,
    struct dizzass_jobs *jobs, uint64_t epoch,
    const struct dizzass_nonce_reply *reply, struct work **copy,
    struct dizzass_job_ticket *ticket)
{
    struct job_slot *slot;
    struct dizzass_nonce_match match;
    const struct work *source;
    int rc;
    jobs_lock(jobs);
    rc = epoch_status(jobs, epoch);
    if (rc) goto done;
    if (reply->chain_id != jobs->chain_id) { rc = DIZZASS_JOBS_WRONG_CHAIN; goto done; }
    if (jobs->paused) { rc = DIZZASS_JOBS_PAUSED; goto done; }
    slot = &jobs->slots[reply->slot];
    rc = slot_status(slot);
    if (rc) goto done;
    source = slot->work;
    match.work = source;
    match.chain_id = jobs->chain_id;
    match.slot = reply->slot;
    match.variant = slot->variant;
    match.version_base_word = slot->version_base_word;
    rc = dizzass_nonce_match_status(&match, reply);
    if (rc) goto done;
    if (source->thr_id != gate->thr_id) { rc = DIZZASS_SUBMIT_WRONG_THREAD; goto done; }
    if (!source->stratum || !source->pool || !source->job_id ||
        !source->nonce1 || !source->ntime ||
        !isfinite(source->work_difficulty) || source->work_difficulty <= 0 ||
        !isfinite(source->device_diff) || source->device_diff <= 0) {
        rc = DIZZASS_SUBMIT_UNSUPPORTED_WORK; goto done;
    }
    *copy = copy_work_noffset((struct work *)source, 0);
    if (!copy_complete(source, *copy)) {
        if (*copy) free_work(*copy);
        rc = DIZZASS_NONCE_PARTIAL_COPY; goto done;
    }
    ticket->epoch = jobs->epoch;
    ticket->serial = slot->serial;
    ticket->chain_id = jobs->chain_id;
    ticket->slot = reply->slot;
done:
    jobs_unlock(jobs);
    return rc;
}

int dizzass_submitter_run(struct dizzass_submitter *gate,
    struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_submit_result *out)
{
    struct dizzass_submit_result result = {0};
    struct work *copy = NULL;
    int rc;
    if (!gate || !jobs || !reply || !out ||
        reply->slot >= DIZZASS_JOB_SLOTS || reply->variant > 2)
        return DIZZASS_SUBMIT_INVALID;
    if (pthread_mutex_lock(&gate->lock)) abort();
    if (gate->stopped) { rc = DIZZASS_SUBMIT_STOPPED; goto done; }
    if (gate->thr->id != gate->thr_id || gate->thr->cgpu != gate->cgpu ||
        !gate->cgpu->drv || !gate->cgpu->drv->hw_error || !gate->cgpu->drv->name) {
        rc = DIZZASS_SUBMIT_WRONG_THREAD; goto done;
    }
    rc = admit_submission(gate, jobs, received_epoch, reply, &copy, &result.ticket);
    if (rc) goto done;
    /* Registry is UNLOCKED. A driver hw_error may pause it without deadlock.
     * The immutable owned copy remains valid even after retire/pause.
     */
    result.native_valid_nonce = submit_nonce(gate->thr, copy, reply->nonce_word);
    result.meets_target = result.native_valid_nonce && fulltest(copy->hash, copy->target);
    free_work(copy);
    *out = result;
done:
    if (pthread_mutex_unlock(&gate->lock)) abort();
    return rc;
}
