/* Offline tests of REAL submit_nonce and its REAL native Stratum queue. */
#include "integration/native_submit.h"
#include <math.h>
#include <sched.h>

static unsigned ds_assertions, ds_groups, ds_hw_calls;
static struct dizzass_jobs *ds_pause_in_hw_error;
#define DS_CHECK(x) do { ++ds_assertions; if (!(x)) { \
    fprintf(stderr, "native-submit FAIL %d: %s\n", __LINE__, #x); exit(1); \
} } while (0)

static void ds_hw_error(struct thr_info *thr)
{
    (void)thr;
    ++ds_hw_calls;
    if (ds_pause_in_hw_error && dizzass_jobs_pause(ds_pause_in_hw_error, 701))
        abort();
}

struct ds_env {
    struct pool pool;
    struct cgpu_info cgpu;
    struct device_drv drv;
    struct thr_info thr;
    struct work *source;
    struct dizzass_jobs *jobs;
    struct dizzass_submitter *gate;
    struct dizzass_job_ticket ticket;
    struct dizzass_nonce_reply reply;
};
static void ds_init(struct ds_env *e)
{
    memset(e, 0, sizeof(*e));
    e->drv.name = "offline-native-submit";
    e->drv.hw_error = ds_hw_error;
    e->cgpu.drv = &e->drv;
    e->thr.cgpu = &e->cgpu;
    e->thr.id = 0;
    e->pool.has_stratum = true;
    e->pool.stratum_active = true;
    e->pool.stratum_notify = true;
    e->pool.stratum_q = tq_new();
    e->source = dn_work();
    e->source->pool = &e->pool;
    e->source->stratum = true;
    e->source->thr_id = e->thr.id;
    e->source->work_block = work_block;
    e->source->work_difficulty = 1;
    e->source->device_diff = 1;
    cgtime(&e->source->tv_staged);
    e->reply = dn_reply(e->source);
    DS_CHECK(dizzass_jobs_create(2, 701, &e->jobs) == 0);
    DS_CHECK(dizzass_submitter_create(&e->thr, &e->gate) == 0);
}
static void ds_prepare(struct ds_env *e)
{
    DS_CHECK(dj_prepare(e->jobs, 701, 3, e->source, &e->ticket) == 0);
}
static void ds_written(struct ds_env *e)
{
    ds_prepare(e);
    DS_CHECK(dizzass_jobs_finish(e->jobs, &e->ticket, DIZZASS_TX_WRITTEN) == 0);
}
static bool ds_queue_empty(struct ds_env *e)
{
    bool empty;
    if (!e->pool.stratum_q) return true;
    mutex_lock(&e->pool.stratum_q->mutex);
    empty = list_empty(&e->pool.stratum_q->q);
    mutex_unlock(&e->pool.stratum_q->mutex);
    return empty;
}
static struct work *ds_take(struct ds_env *e)
{
    /* No consumers exist in this harness. Never block on an empty tq_pop. */
    DS_CHECK(!ds_queue_empty(e));
    return tq_pop(e->pool.stratum_q);
}
static void ds_close(struct ds_env *e)
{
    DS_CHECK(dizzass_submitter_stop(e->gate) == 0);
    dizzass_submitter_destroy(&e->gate);
    dizzass_submitter_destroy(&e->gate);
    dizzass_jobs_destroy(&e->jobs);
    if (e->source) free_work(e->source);
    while (!ds_queue_empty(e)) {
        struct work *w = ds_take(e);
        free_work(w);
    }
    tq_free(e->pool.stratum_q);
}
static int ds_run(struct ds_env *e, struct dizzass_submit_result *r)
{
    return dizzass_submitter_run(e->gate, e->jobs, 701, &e->reply, r);
}

static void ds_queue_and_dedup(void)
{
    struct ds_env e;
    struct dizzass_submit_result r = {0};
    struct work *queued;
    struct dizzass_job_result snapshot = {0};
    unsigned callbacks = ds_hw_calls;
    int64_t accepted = total_accepted, diff = total_diff1;
    ds_init(&e); ds_written(&e);
    free_work(e.source); /* Registry owns a distinct native copy. */
    DS_CHECK(ds_run(&e, &r) == 0 && r.native_valid_nonce && r.meets_target);
    DS_CHECK(dj_ticket_equal(r.ticket, e.ticket));
    DS_CHECK(e.cgpu.diff1 == 1 && e.pool.diff1 == 1 && total_diff1 == diff + 1);
    DS_CHECK(total_accepted == accepted && e.pool.accepted == 0);
    queued = ds_take(&e);
    DS_CHECK(queued && memcmp(queued->hash, fixture_hash, 32) == 0);
    DS_CHECK(queued->pool == &e.pool && queued->thr_id == e.thr.id);
    DS_CHECK(strcmp(queued->job_id, "offline-fixture-job") == 0);
    DS_CHECK(dizzass_jobs_check(e.jobs, 701, &e.reply, &snapshot) == 0);
    DS_CHECK(queued != snapshot.check.work && queued->job_id != snapshot.check.work->job_id);
    dizzass_job_result_clear(&snapshot);
    DS_CHECK(ds_run(&e, &r) == 0 && !r.native_valid_nonce && !r.meets_target);
    DS_CHECK(ds_queue_empty(&e) && e.cgpu.hw_errors == 1 && ds_hw_calls == callbacks + 1);
    DS_CHECK(e.cgpu.diff1 == 1); /* Duplicate did not count as a second diff1. */
    DS_CHECK(dizzass_jobs_retire(e.jobs, &e.ticket) == 0);
    DS_CHECK(memcmp(queued->hash, fixture_hash, 32) == 0);
    free_work(queued); ds_close(&e); ++ds_groups;
}

static void ds_core_outcomes(void)
{
    struct ds_env e;
    struct dizzass_submit_result r;
    struct work *queued;
    int64_t stale_before;
    unsigned scenario;
    for (scenario = 0; scenario < 7; ++scenario) {
        ds_init(&e);
        if (scenario == 0) memset(e.source->target, 0, 32); /* Above target. */
        if (scenario == 1 || scenario == 2) e.source->work_block = work_block + 1;
        if (scenario == 3) e.source->tv_staged.tv_sec -= 1000; /* Expired. */
        if (scenario == 4) tq_freeze(e.pool.stratum_q);
        if (scenario == 5) { tq_free(e.pool.stratum_q); e.pool.stratum_q = NULL; }
        if (scenario == 6) memcpy(e.source->target, fixture_hash, 32); /* Equality. */
        e.pool.submit_old = scenario == 2;
        stale_before = total_stale;
        ds_written(&e);
        DS_CHECK(ds_run(&e, &r) == 0 && r.native_valid_nonce);
        DS_CHECK(r.meets_target == (scenario != 0));
        DS_CHECK(e.cgpu.diff1 == 1 && e.cgpu.hw_errors == 0);
        DS_CHECK(e.pool.accepted == 0);
        if (scenario == 2 || scenario == 6) {
            queued = ds_take(&e);
            DS_CHECK(queued->stale == (scenario == 2));
            free_work(queued);
        } else DS_CHECK(ds_queue_empty(&e));
        if (scenario == 1 || scenario == 3) {
            DS_CHECK(e.pool.stale_shares == 1 && total_stale == stale_before + 1);
            DS_CHECK(e.pool.diff_stale == 1);
        } else DS_CHECK(total_stale == stale_before);
        ds_close(&e);
    }
    /* Invalid hash then same nonce: preserve upstream last_nonce/HW behavior. */
    ds_init(&e); ds_written(&e); ++e.reply.nonce_word;
    DS_CHECK(ds_run(&e, &r) == 0 && !r.native_valid_nonce);
    DS_CHECK(e.cgpu.last_nonce == e.reply.nonce_word);
    DS_CHECK(ds_run(&e, &r) == 0 && !r.native_valid_nonce);
    DS_CHECK(e.cgpu.hw_errors == 2 && e.cgpu.diff1 == 0 && ds_queue_empty(&e));
    ds_close(&e); ++ds_groups;
}

static void ds_admission_guards(void)
{
    struct ds_env e;
    struct dizzass_submit_result r, before;
    struct dizzass_nonce_reply changed;
    int failure;
    unsigned which;
    ds_init(&e); memset(&r, 0x5a, sizeof(r)); before = r;
    DS_CHECK(ds_run(&e, &r) == DIZZASS_JOBS_EMPTY);
    ds_prepare(&e);
    DS_CHECK(ds_run(&e, &r) == DIZZASS_JOBS_PENDING);
    DS_CHECK(dizzass_jobs_finish(e.jobs, &e.ticket, DIZZASS_TX_WRITTEN) == 0);
    DS_CHECK(dizzass_submitter_run(e.gate, e.jobs, 700, &e.reply, &r) == DIZZASS_JOBS_OLD_EPOCH);
    changed = e.reply; changed.chain_id++;
    DS_CHECK(dizzass_submitter_run(e.gate, e.jobs, 701, &changed, &r) == DIZZASS_JOBS_WRONG_CHAIN);
    changed = e.reply; changed.version_bits = 1;
    DS_CHECK(dizzass_submitter_run(e.gate, e.jobs, 701, &changed, &r) == DIZZASS_NONCE_WRONG_VERSION);
    changed = e.reply; changed.variant = 1;
    DS_CHECK(dizzass_submitter_run(e.gate, e.jobs, 701, &changed, &r) == DIZZASS_NONCE_WRONG_FORMAT);
    changed = e.reply; changed.slot = 32;
    DS_CHECK(dizzass_submitter_run(e.gate, e.jobs, 701, &changed, &r) == DIZZASS_SUBMIT_INVALID);
    for (failure = 0; failure < 4; ++failure) {
        dj_strdup_failure = failure;
        DS_CHECK(ds_run(&e, &r) == DIZZASS_NONCE_PARTIAL_COPY);
        dj_strdup_failure = -1;
        DS_CHECK(dizzass_jobs_ticket_live(e.jobs, &e.ticket) == 0);
    }
    e.thr.id = 1;
    DS_CHECK(ds_run(&e, &r) == DIZZASS_SUBMIT_WRONG_THREAD);
    e.thr.id = 0;
    DS_CHECK(dizzass_jobs_pause(e.jobs, 701) == 0);
    DS_CHECK(ds_run(&e, &r) == DIZZASS_JOBS_PAUSED);
    DS_CHECK(dizzass_submitter_stop(e.gate) == 0);
    DS_CHECK(ds_run(&e, &r) == DIZZASS_SUBMIT_STOPPED);
    DS_CHECK(memcmp(&r, &before, sizeof(r)) == 0);
    DS_CHECK(e.cgpu.last_nonce == 0 && e.cgpu.hw_errors == 0 && e.pool.diff1 == 0);
    ds_close(&e);
    for (which = 0; which < 8; ++which) {
        ds_init(&e);
        if (which == 0) e.source->stratum = false;
        if (which == 1) e.source->pool = NULL;
        if (which == 2) { free(e.source->job_id); e.source->job_id = NULL; }
        if (which == 3) { free(e.source->ntime); e.source->ntime = NULL; }
        if (which == 4) e.source->device_diff = 0;
        if (which == 5) e.source->work_difficulty = NAN;
        if (which == 6) e.source->thr_id = 77;
        if (which == 7) { free(e.source->nonce1); e.source->nonce1 = NULL; }
        ds_written(&e);
        DS_CHECK(ds_run(&e, &r) == (which == 6 ? DIZZASS_SUBMIT_WRONG_THREAD : DIZZASS_SUBMIT_UNSUPPORTED_WORK));
        DS_CHECK(e.cgpu.diff1 == 0 && e.cgpu.hw_errors == 0 && ds_queue_empty(&e));
        ds_close(&e);
    }
    ++ds_groups;
}

static void ds_rx_queue(void)
{
    size_t fragment;
    for (fragment = 1; fragment <= 11; ++fragment) {
        struct ds_env e;
        struct dizzass_submit_result r;
        vn135_work_rx_stream stream;
        vn135_work_rx_message message;
        unsigned char frame[11] = {0xaa,0x55,0,0,0,0,0,24,0,0,0x80};
        size_t pos = 0;
        struct work *queued;
        ds_init(&e); ds_written(&e);
        dn_put_be(frame + 2, e.reply.nonce_word);
        DS_CHECK(vn135_work_rx_stream_init(&stream, 2, 1, 6, 0) == 0);
        while (pos < sizeof(frame)) {
            size_t amount = sizeof(frame) - pos, used;
            int rc;
            if (amount > fragment) amount = fragment;
            rc = vn135_work_rx_stream_feed(&stream, frame + pos, amount, &used, &message);
            DS_CHECK(used > 0 && used <= amount); pos += used;
            DS_CHECK(rc == (pos == sizeof(frame) ? VN135_RX_NONCE_RAW : VN135_RX_NEED_MORE));
        }
        DS_CHECK(dizzass_nonce_decode_payload(6, 2, message.chain_id,
            message.payload, message.payload_size, &e.reply) == 0);
        DS_CHECK(ds_run(&e, &r) == 0 && r.native_valid_nonce && r.meets_target);
        queued = ds_take(&e);
        DS_CHECK(memcmp(queued->hash, fixture_hash, 32) == 0);
        free_work(queued); ds_close(&e);
    }
    ++ds_groups;
}

struct ds_thread_arg {
    struct dizzass_submitter *gate;
    struct dizzass_jobs *jobs;
    struct dizzass_nonce_reply reply;
    unsigned valid, invalid;
    int rc;
};
static void *ds_many(void *p)
{
    struct ds_thread_arg *arg = p;
    unsigned i;
    for (i = 0; i < 16; ++i) {
        struct dizzass_submit_result r;
        arg->rc = dizzass_submitter_run(arg->gate, arg->jobs, 701, &arg->reply, &r);
        if (arg->rc) break;
        if (r.native_valid_nonce) ++arg->valid; else ++arg->invalid;
    }
    return NULL;
}
static void ds_cross_chain_threads(void)
{
    struct ds_env e;
    struct dizzass_jobs *other = NULL;
    struct dizzass_job_ticket t = {0};
    struct ds_thread_arg args[4] = {{0}};
    pthread_t threads[4];
    unsigned i, valid = 0, invalid = 0;
    struct work *queued;
    ds_init(&e); ds_written(&e);
    DS_CHECK(dizzass_jobs_create(3, 701, &other) == 0);
    DS_CHECK(dj_prepare(other, 701, 3, e.source, &t) == 0);
    DS_CHECK(dizzass_jobs_finish(other, &t, DIZZASS_TX_WRITTEN) == 0);
    for (i = 0; i < 4; ++i) {
        args[i].gate = e.gate; args[i].jobs = i & 1 ? other : e.jobs;
        args[i].reply = e.reply; args[i].reply.chain_id = i & 1 ? 3 : 2;
        DS_CHECK(pthread_create(&threads[i], NULL, ds_many, &args[i]) == 0);
    }
    for (i = 0; i < 4; ++i) {
        DS_CHECK(pthread_join(threads[i], NULL) == 0 && args[i].rc == 0);
        valid += args[i].valid; invalid += args[i].invalid;
    }
    DS_CHECK(valid == 1 && invalid == 63 && e.cgpu.hw_errors == 63);
    DS_CHECK(e.cgpu.diff1 == 1 && e.pool.diff1 == 1);
    queued = ds_take(&e); free_work(queued); DS_CHECK(ds_queue_empty(&e));
    dizzass_jobs_destroy(&other); ds_close(&e);
    printf("NATIVE_SUBMIT_THREADS calls=64 chains=2 valid=%u rejected=%u\n", valid, invalid);
    ++ds_groups;
}

/* Test-only deterministic pause inside the REAL queue boundary, not a success stub. */
static pthread_mutex_t ds_hook_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t ds_hook_cond = PTHREAD_COND_INITIALIZER;
static bool ds_hook_enabled, ds_hook_entered, ds_hook_release;
bool __real_tq_push(struct thread_q *q, void *data);
bool __wrap_tq_push(struct thread_q *q, void *data)
{
    mutex_lock(&ds_hook_lock);
    if (ds_hook_enabled) {
        ds_hook_entered = true;
        pthread_cond_broadcast(&ds_hook_cond);
        while (!ds_hook_release) pthread_cond_wait(&ds_hook_cond, &ds_hook_lock);
    }
    mutex_unlock(&ds_hook_lock);
    return __real_tq_push(q, data);
}
struct ds_stop_arg { struct dizzass_submitter *gate; atomic_bool entered, done; int rc; };
static void *ds_stop_thread(void *p)
{
    struct ds_stop_arg *a = p;
    atomic_store(&a->entered, true);
    a->rc = dizzass_submitter_stop(a->gate);
    atomic_store(&a->done, true);
    return NULL;
}
static void *ds_one(void *p)
{
    struct ds_thread_arg *a = p;
    struct dizzass_submit_result r;
    a->rc = dizzass_submitter_run(a->gate, a->jobs, 701, &a->reply, &r);
    a->valid = a->rc == 0 && r.native_valid_nonce;
    return NULL;
}
static void ds_stop_and_reentry(void)
{
    struct ds_env e;
    struct ds_thread_arg a = {0};
    struct ds_stop_arg stop;
    struct dizzass_submit_result r;
    struct work *queued;
    pthread_t sender, stopper;
    ds_init(&e); ds_written(&e);
    a.gate = e.gate; a.jobs = e.jobs; a.reply = e.reply;
    memset(&stop, 0, sizeof(stop)); stop.gate = e.gate;
    atomic_init(&stop.entered, false); atomic_init(&stop.done, false);
    mutex_lock(&ds_hook_lock);
    ds_hook_enabled = true; ds_hook_entered = ds_hook_release = false;
    mutex_unlock(&ds_hook_lock);
    DS_CHECK(pthread_create(&sender, NULL, ds_one, &a) == 0);
    mutex_lock(&ds_hook_lock);
    while (!ds_hook_entered) pthread_cond_wait(&ds_hook_cond, &ds_hook_lock);
    mutex_unlock(&ds_hook_lock);
    /* Admission already happened. Registry can pause while the owned copy lives. */
    DS_CHECK(dizzass_jobs_pause(e.jobs, 701) == 0);
    DS_CHECK(pthread_create(&stopper, NULL, ds_stop_thread, &stop) == 0);
    while (!atomic_load(&stop.entered)) sched_yield();
    DS_CHECK(!atomic_load(&stop.done));
    mutex_lock(&ds_hook_lock); ds_hook_release = true;
    pthread_cond_broadcast(&ds_hook_cond); mutex_unlock(&ds_hook_lock);
    DS_CHECK(pthread_join(sender, NULL) == 0 && a.rc == 0 && a.valid == 1);
    DS_CHECK(pthread_join(stopper, NULL) == 0 && stop.rc == 0 && atomic_load(&stop.done));
    mutex_lock(&ds_hook_lock); ds_hook_enabled = false; mutex_unlock(&ds_hook_lock);
    DS_CHECK(ds_run(&e, &r) == DIZZASS_SUBMIT_STOPPED);
    queued = ds_take(&e); DS_CHECK(memcmp(queued->hash, fixture_hash, 32) == 0);
    free_work(queued); ds_close(&e);
    ds_init(&e); ds_written(&e); ++e.reply.nonce_word;
    ds_pause_in_hw_error = e.jobs;
    DS_CHECK(ds_run(&e, &r) == 0 && !r.native_valid_nonce);
    ds_pause_in_hw_error = NULL;
    DS_CHECK(ds_run(&e, &r) == DIZZASS_JOBS_PAUSED);
    DS_CHECK(ds_queue_empty(&e)); ds_close(&e);
    ++ds_groups;
}

static void ds_all(void)
{
    /* No miner/network startup. Native queue consumer is only this harness. */
    bool saved_stale = opt_submit_stale;
    opt_submit_stale = false;
    ds_queue_and_dedup(); ds_core_outcomes(); ds_admission_guards();
    ds_rx_queue(); ds_cross_chain_threads(); ds_stop_and_reentry();
    opt_submit_stale = saved_stale;
    printf("NATIVE_SUBMIT_PASS groups=%u rx_fragments=11 assertions=%u\n", ds_groups, ds_assertions);
}
