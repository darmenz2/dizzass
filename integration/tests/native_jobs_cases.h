/* Test-only extension of the native nonce harness. No production entry point. */
#include "integration/native_jobs.h"
#include <stdatomic.h>

static unsigned dj_assertions, dj_groups;
#define DJ_CHECK(x) do { ++dj_assertions; if (!(x)) { \
    fprintf(stderr, "native-jobs FAIL %d: %s\n", __LINE__, #x); exit(1); \
} } while (0)

/* Test-only fault injection for the real native _copy_work strdup calls. */
static _Thread_local int dj_strdup_failure = -1;
char *__real_strdup(const char *s);
char *__wrap_strdup(const char *s)
{
    if (dj_strdup_failure >= 0 && dj_strdup_failure-- == 0)
        return NULL;
    return __real_strdup(s);
}
static bool dj_ticket_equal(struct dizzass_job_ticket a, struct dizzass_job_ticket b)
{
    return a.epoch == b.epoch && a.serial == b.serial &&
        a.chain_id == b.chain_id && a.slot == b.slot;
}
static int dj_prepare(struct dizzass_jobs *jobs, uint64_t epoch, unsigned slot,
    struct work *source, struct dizzass_job_ticket *ticket)
{
    return dizzass_jobs_prepare(jobs, epoch, slot, 2, dn_le(source->data), source, ticket);
}

static void dj_lifetime(void)
{
    struct dizzass_jobs *jobs = NULL;
    struct work *source = dn_work(), before = *source;
    struct pool external_pool = {0};
    struct dizzass_job_ticket ticket = {0}, retry = {0}, changed;
    struct dizzass_nonce_reply reply = dn_reply(source);
    struct dizzass_job_result result = {0};
    source->pool = &external_pool;
    before = *source;
    DJ_CHECK(dizzass_jobs_create(2, 41, &jobs) == 0);
    DJ_CHECK(dj_prepare(jobs, 41, 3, source, &ticket) == 0);
    DJ_CHECK(memcmp(source, &before, sizeof(before)) == 0);
    DJ_CHECK(ticket.epoch == 41 && ticket.serial == 1 && ticket.slot == 3);
    DJ_CHECK(dizzass_jobs_ticket_live(jobs, &ticket) == DIZZASS_JOBS_PENDING);
    DJ_CHECK(dizzass_jobs_check(jobs, 41, &reply, &result) == DIZZASS_JOBS_PENDING);
    DJ_CHECK(!result.check.work);
    changed = ticket; ++changed.serial;
    DJ_CHECK(dizzass_jobs_finish(jobs, &changed, DIZZASS_TX_WRITTEN) == DIZZASS_JOBS_STALE_TICKET);
    DJ_CHECK(dj_prepare(jobs, 41, 3, source, &retry) == DIZZASS_JOBS_BUSY);
    DJ_CHECK(dizzass_jobs_finish(jobs, &ticket, DIZZASS_TX_WRITTEN) == 0);
    DJ_CHECK(dizzass_jobs_finish(jobs, &ticket, DIZZASS_TX_NOT_SENT) == DIZZASS_JOBS_STALE_TICKET);
    DJ_CHECK(dizzass_jobs_ticket_live(jobs, &ticket) == 0);
    /* Later mutation/free of the caller's source must not alter saved work. */
    memset(source->data, 0, sizeof(source->data)); source->job_id[0] = 'X';
    free_work(source);
    DJ_CHECK(dizzass_jobs_check(jobs, 41, &reply, &result) == 0);
    DJ_CHECK(result.check.passes_diff1 && result.check.meets_target);
    DJ_CHECK(memcmp(result.check.work->hash, fixture_hash, 32) == 0);
    DJ_CHECK(strcmp(result.check.work->job_id, "offline-fixture-job") == 0);
    DJ_CHECK(result.check.work->pool == &external_pool);
    DJ_CHECK(dj_ticket_equal(result.ticket, ticket));
    DJ_CHECK(dizzass_jobs_check(jobs, 41, &reply, &result) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_retire(jobs, &ticket) == 0);
    DJ_CHECK(dizzass_jobs_ticket_live(jobs, &ticket) == DIZZASS_JOBS_QUARANTINED);
    DJ_CHECK(memcmp(result.check.work->hash, fixture_hash, 32) == 0);
    dizzass_jobs_destroy(&jobs); dizzass_jobs_destroy(&jobs);
    DJ_CHECK(!jobs && strcmp(result.check.work->ntime, "495fab29") == 0);
    /* Result lifetime is independent of table destruction; pool was NOT copied. */
    dizzass_job_result_clear(&result); dizzass_job_result_clear(&result);
    DJ_CHECK(!result.check.work && !result.ticket.serial && !result.ticket.epoch);
    ++dj_groups;
}

static void dj_send_outcomes(void)
{
    struct dizzass_jobs *jobs = NULL;
    struct work *source = dn_work();
    struct dizzass_job_ticket first = {0}, next = {0}, other = {0};
    struct dizzass_nonce_reply reply = dn_reply(source);
    struct dizzass_job_result result = {0};
    DJ_CHECK(dizzass_jobs_create(2, 100, &jobs) == 0);
    DJ_CHECK(dj_prepare(jobs, 100, 3, source, &first) == 0);
    DJ_CHECK(dizzass_jobs_finish(jobs, &first, (enum dizzass_tx_result)9) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_finish(jobs, &first, DIZZASS_TX_NOT_SENT) == 0);
    DJ_CHECK(dizzass_jobs_check(jobs, 100, &reply, &result) == DIZZASS_JOBS_EMPTY);
    DJ_CHECK(dj_prepare(jobs, 100, 3, source, &next) == 0);
    DJ_CHECK(next.serial > first.serial);
    DJ_CHECK(dizzass_jobs_finish(jobs, &first, DIZZASS_TX_WRITTEN) == DIZZASS_JOBS_STALE_TICKET);
    DJ_CHECK(dizzass_jobs_finish(jobs, &next, DIZZASS_TX_UNCERTAIN) == 0);
    DJ_CHECK(dizzass_jobs_check(jobs, 100, &reply, &result) == DIZZASS_JOBS_QUARANTINED);
    DJ_CHECK(dj_prepare(jobs, 100, 3, source, &other) == DIZZASS_JOBS_QUARANTINED);
    DJ_CHECK(!other.serial && !other.epoch);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, 100, 101) == DIZZASS_JOBS_BUSY);
    DJ_CHECK(dizzass_jobs_pause(jobs, 99) == DIZZASS_JOBS_OLD_EPOCH);
    DJ_CHECK(dizzass_jobs_pause(jobs, 100) == 0);
    DJ_CHECK(dizzass_jobs_pause(jobs, 100) == 0);
    DJ_CHECK(dj_prepare(jobs, 100, 4, source, &other) == DIZZASS_JOBS_PAUSED);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, 100, 100) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, 100, 0) == DIZZASS_JOBS_INVALID);
    /* No hardware drain is claimed. This is an explicitly synthetic boundary. */
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, 100, 101) == 0);
    DJ_CHECK(dj_prepare(jobs, 101, 3, source, &other) == 0);
    DJ_CHECK(dizzass_jobs_finish(jobs, &other, DIZZASS_TX_WRITTEN) == 0);
    DJ_CHECK(dizzass_jobs_finish(jobs, &next, DIZZASS_TX_WRITTEN) == DIZZASS_JOBS_OLD_EPOCH);
    DJ_CHECK(dizzass_jobs_retire(jobs, &next) == DIZZASS_JOBS_OLD_EPOCH);
    DJ_CHECK(dizzass_jobs_check(jobs, 100, &reply, &result) == DIZZASS_JOBS_OLD_EPOCH);
    DJ_CHECK(!result.check.work);
    DJ_CHECK(dizzass_jobs_check(jobs, 101, &reply, &result) == 0);
    DJ_CHECK(result.check.meets_target);
    dizzass_job_result_clear(&result);
    DJ_CHECK(dizzass_jobs_pause(jobs, 101) == 0);
    DJ_CHECK(dizzass_jobs_check(jobs, 101, &reply, &result) == DIZZASS_JOBS_PAUSED);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, 101, UINT64_MAX) == 0);
    DJ_CHECK(dizzass_jobs_pause(jobs, UINT64_MAX) == 0);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, UINT64_MAX, 1) == DIZZASS_JOBS_INVALID);
    dizzass_jobs_destroy(&jobs); free_work(source);
    ++dj_groups;
}

static void dj_guards_and_capacity(void)
{
    struct dizzass_jobs *jobs = NULL, *other_chain = NULL;
    struct work *source = dn_work();
    struct dizzass_job_ticket tickets[32] = {{0}}, extra = {0}, bad;
    struct dizzass_job_result result = {0};
    struct dizzass_nonce_reply reply = dn_reply(source), bad_reply;
    unsigned i;
    uint32_t before_allocations;
    DJ_CHECK(dizzass_jobs_create(2, 0, &jobs) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(!jobs);
    DJ_CHECK(dizzass_jobs_create(2, 1, NULL) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_create(2, 1, &jobs) == 0);
    DJ_CHECK(dizzass_jobs_create(2, 1, &jobs) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_create(7, 1, &other_chain) == 0);
    DJ_CHECK(dj_prepare(jobs, 1, 32, source, &extra) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_prepare(jobs, 1, 3, 3, 0, source, &extra) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dj_prepare(jobs, 2, 3, source, &extra) == DIZZASS_JOBS_OLD_EPOCH);
    DJ_CHECK(dizzass_jobs_prepare(jobs, 1, 3, 2, ~dn_le(source->data), source, &extra) == DIZZASS_NONCE_WRONG_VERSION);
    for (i = 0; i < 32; ++i) {
        DJ_CHECK(dj_prepare(jobs, 1, i, source, &tickets[i]) == 0);
        DJ_CHECK(dizzass_jobs_finish(jobs, &tickets[i], DIZZASS_TX_WRITTEN) == 0);
    }
    before_allocations = total_work;
    DJ_CHECK(dj_prepare(jobs, 1, 3, source, &extra) == DIZZASS_JOBS_BUSY);
    DJ_CHECK(total_work == before_allocations && !extra.epoch);
    bad = tickets[3]; bad.chain_id = 7;
    DJ_CHECK(dizzass_jobs_retire(jobs, &bad) == DIZZASS_JOBS_WRONG_CHAIN);
    DJ_CHECK(dizzass_jobs_finish(other_chain, &tickets[3], DIZZASS_TX_WRITTEN) == DIZZASS_JOBS_WRONG_CHAIN);
    DJ_CHECK(dizzass_jobs_check(other_chain, 1, &reply, &result) == DIZZASS_JOBS_WRONG_CHAIN);
    bad_reply = reply; bad_reply.variant = 1;
    DJ_CHECK(dizzass_jobs_check(jobs, 1, &bad_reply, &result) == DIZZASS_NONCE_WRONG_FORMAT);
    bad_reply = reply; bad_reply.version_bits = 1;
    DJ_CHECK(dizzass_jobs_check(jobs, 1, &bad_reply, &result) == DIZZASS_NONCE_WRONG_VERSION);
    DJ_CHECK(total_work == before_allocations && !result.check.work);
    for (i = 0; i < 32; ++i) {
        reply.slot = i;
        DJ_CHECK(dizzass_jobs_check(jobs, 1, &reply, &result) == 0);
        DJ_CHECK(result.check.passes_diff1 && result.check.meets_target);
        DJ_CHECK(dj_ticket_equal(result.ticket, tickets[i]));
        dizzass_job_result_clear(&result);
        DJ_CHECK(dizzass_jobs_retire(jobs, &tickets[i]) == 0);
        DJ_CHECK(dj_prepare(jobs, 1, i, source, &extra) == DIZZASS_JOBS_QUARANTINED);
    }
    DJ_CHECK(dizzass_jobs_pause(jobs, 1) == 0);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(jobs, 1, 2) == 0);
    DJ_CHECK(dj_prepare(jobs, 2, 3, source, &extra) == 0);
    DJ_CHECK(dizzass_jobs_pause(jobs, 2) == 0); /* Cancel a PREPARED entry too. */
    DJ_CHECK(dizzass_jobs_finish(jobs, &extra, DIZZASS_TX_WRITTEN) == DIZZASS_JOBS_PAUSED);
    DJ_CHECK(dizzass_jobs_ticket_live(NULL, &extra) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_finish(jobs, NULL, DIZZASS_TX_WRITTEN) == DIZZASS_JOBS_INVALID);
    DJ_CHECK(dizzass_jobs_retire(jobs, NULL) == DIZZASS_JOBS_INVALID);
    dizzass_job_result_clear(NULL); dizzass_jobs_destroy(NULL);
    dizzass_jobs_destroy(&jobs); dizzass_jobs_destroy(&other_chain); free_work(source);
    ++dj_groups;
}

static void dj_allocation_failures(void)
{
    struct dizzass_jobs *jobs = NULL;
    struct work *source = dn_work();
    struct dizzass_job_ticket ticket = {0}, before;
    struct dizzass_nonce_reply reply = dn_reply(source);
    struct dizzass_job_result result = {0}, untouched = {0};
    int failure;
    DJ_CHECK(dizzass_jobs_create(2, 3, &jobs) == 0);
    for (failure = 0; failure < 4; ++failure) {
        before = ticket;
        dj_strdup_failure = failure;
        DJ_CHECK(dj_prepare(jobs, 3, 3, source, &ticket) == DIZZASS_NONCE_PARTIAL_COPY);
        dj_strdup_failure = -1;
        DJ_CHECK(dj_ticket_equal(ticket, before));
        DJ_CHECK(dizzass_jobs_check(jobs, 3, &reply, &result) == DIZZASS_JOBS_EMPTY);
    }
    DJ_CHECK(dj_prepare(jobs, 3, 3, source, &ticket) == 0);
    DJ_CHECK(ticket.serial == 1); /* Failed preparations didn't publish a token. */
    DJ_CHECK(dizzass_jobs_finish(jobs, &ticket, DIZZASS_TX_WRITTEN) == 0);
    for (failure = 0; failure < 4; ++failure) {
        dj_strdup_failure = failure;
        DJ_CHECK(dizzass_jobs_check(jobs, 3, &reply, &result) == DIZZASS_NONCE_PARTIAL_COPY);
        dj_strdup_failure = -1;
        DJ_CHECK(memcmp(&result, &untouched, sizeof(result)) == 0);
        DJ_CHECK(dizzass_jobs_ticket_live(jobs, &ticket) == 0);
    }
    DJ_CHECK(dizzass_jobs_check(jobs, 3, &reply, &result) == 0);
    DJ_CHECK(result.check.passes_diff1 && result.check.meets_target);
    dizzass_job_result_clear(&result); dizzass_jobs_destroy(&jobs); free_work(source);
    ++dj_groups;
}

static void dj_rx_frames(void)
{
    size_t fragment;
    for (fragment = 1; fragment <= 11; ++fragment) {
        struct work *source = dn_work();
        struct dizzass_jobs *jobs = NULL;
        struct dizzass_job_ticket ticket = {0};
        struct dizzass_job_result result = {0};
        struct dizzass_nonce_reply reply;
        vn135_work_rx_stream stream; vn135_work_rx_message message;
        unsigned char frame[11] = {0xaa,0x55,0,0,0,0,0,24,0,0,0x80};
        size_t pos = 0;
        DJ_CHECK(dizzass_jobs_create(2, 9, &jobs) == 0);
        DJ_CHECK(dj_prepare(jobs, 9, 3, source, &ticket) == 0);
        DJ_CHECK(dizzass_jobs_finish(jobs, &ticket, DIZZASS_TX_WRITTEN) == 0);
        free_work(source);
        dn_put_be(frame + 2, dn_le(fixture_words + 76));
        DJ_CHECK(vn135_work_rx_stream_init(&stream, 2, 1, 6, 0) == 0);
        while (pos < sizeof(frame)) {
            size_t amount = sizeof(frame) - pos, used = 0;
            int rc;
            if (amount > fragment) amount = fragment;
            rc = vn135_work_rx_stream_feed(&stream, frame + pos, amount, &used, &message);
            DJ_CHECK(used > 0 && used <= amount); pos += used;
            DJ_CHECK(rc == (pos == sizeof(frame) ? VN135_RX_NONCE_RAW : VN135_RX_NEED_MORE));
        }
        DJ_CHECK(dizzass_nonce_decode_payload(6, 2, message.chain_id,
            message.payload, message.payload_size, &reply) == 0);
        DJ_CHECK(dizzass_jobs_check(jobs, 9, &reply, &result) == 0);
        DJ_CHECK(result.check.passes_diff1 && result.check.meets_target);
        DJ_CHECK(memcmp(result.check.work->hash, fixture_hash, 32) == 0);
        DJ_CHECK(dj_ticket_equal(result.ticket, ticket));
        dizzass_job_result_clear(&result); dizzass_jobs_destroy(&jobs);
    }
    ++dj_groups;
}

struct dj_thread_context {
    struct dizzass_jobs *jobs;
    atomic_uint_fast64_t epoch;
    pthread_barrier_t barrier;
};
struct dj_reader {
    struct dj_thread_context *context;
    struct dizzass_nonce_reply reply;
    unsigned successes, rejected, failures;
};
static void *dj_read_thread(void *arg)
{
    struct dj_reader *reader = arg;
    unsigned i;
    struct dizzass_job_result held = {0};
    int barrier_rc;
    if (dizzass_jobs_check(reader->context->jobs, 1000, &reader->reply, &held) != 0)
        ++reader->failures;
    barrier_rc = pthread_barrier_wait(&reader->context->barrier);
    if (barrier_rc != 0 && barrier_rc != PTHREAD_BARRIER_SERIAL_THREAD)
        ++reader->failures;
    barrier_rc = pthread_barrier_wait(&reader->context->barrier);
    if (barrier_rc != 0 && barrier_rc != PTHREAD_BARRIER_SERIAL_THREAD)
        ++reader->failures;
    /* Main has freed the registry copy and changed epoch while we held this. */
    if (!held.check.work || memcmp(held.check.work->hash, fixture_hash, 32) ||
        strcmp(held.check.work->job_id, "offline-fixture-job") || held.ticket.epoch != 1000)
        ++reader->failures;
    dizzass_job_result_clear(&held);
    for (i = 0; i < 1000; ++i) {
        struct dizzass_job_result result = {0};
        uint64_t epoch = atomic_load(&reader->context->epoch);
        int rc = dizzass_jobs_check(reader->context->jobs, epoch, &reader->reply, &result);
        if (rc == 0) {
            if (!result.check.work || !result.check.passes_diff1 || !result.check.meets_target ||
                memcmp(result.check.work->hash, fixture_hash, 32) ||
                strcmp(result.check.work->job_id, "offline-fixture-job") ||
                result.ticket.epoch != epoch || !result.ticket.serial)
                ++reader->failures;
            ++reader->successes;
        } else if (rc == DIZZASS_JOBS_PAUSED || rc == DIZZASS_JOBS_OLD_EPOCH ||
                   rc == DIZZASS_JOBS_EMPTY || rc == DIZZASS_JOBS_PENDING) {
            if (result.check.work || result.ticket.serial) ++reader->failures;
            ++reader->rejected;
        } else ++reader->failures;
        dizzass_job_result_clear(&result);
    }
    return NULL;
}
static void dj_concurrent_snapshots(void)
{
    struct work *source = dn_work();
    struct dj_thread_context context = {0};
    struct dj_reader readers[4] = {{0}};
    pthread_t threads[4];
    struct dizzass_job_ticket ticket = {0};
    unsigned i, successes = 0, rejected = 0;
    uint64_t epoch;
    int barrier_rc;
    atomic_init(&context.epoch, 1000);
    DJ_CHECK(dizzass_jobs_create(2, 1000, &context.jobs) == 0);
    DJ_CHECK(dj_prepare(context.jobs, 1000, 3, source, &ticket) == 0);
    DJ_CHECK(dizzass_jobs_finish(context.jobs, &ticket, DIZZASS_TX_WRITTEN) == 0);
    DJ_CHECK(pthread_barrier_init(&context.barrier, NULL, 5) == 0);
    for (i = 0; i < 4; ++i) {
        readers[i].context = &context; readers[i].reply = dn_reply(source);
        DJ_CHECK(pthread_create(&threads[i], NULL, dj_read_thread, &readers[i]) == 0);
    }
    barrier_rc = pthread_barrier_wait(&context.barrier);
    DJ_CHECK(barrier_rc == 0 || barrier_rc == PTHREAD_BARRIER_SERIAL_THREAD);
    DJ_CHECK(dizzass_jobs_pause(context.jobs, 1000) == 0);
    DJ_CHECK(dizzass_jobs_begin_drained_epoch(context.jobs, 1000, 1001) == 0);
    atomic_store(&context.epoch, 1001);
    memset(&ticket, 0, sizeof(ticket));
    DJ_CHECK(dj_prepare(context.jobs, 1001, 3, source, &ticket) == 0);
    DJ_CHECK(dizzass_jobs_finish(context.jobs, &ticket, DIZZASS_TX_WRITTEN) == 0);
    barrier_rc = pthread_barrier_wait(&context.barrier);
    DJ_CHECK(barrier_rc == 0 || barrier_rc == PTHREAD_BARRIER_SERIAL_THREAD);
    for (epoch = 1001; epoch < 1200; ++epoch) {
        DJ_CHECK(dizzass_jobs_pause(context.jobs, epoch) == 0);
        /* Synthetic epoch transition; this test has NO transport or ASIC. */
        DJ_CHECK(dizzass_jobs_begin_drained_epoch(context.jobs, epoch, epoch + 1) == 0);
        atomic_store(&context.epoch, epoch + 1);
        memset(&ticket, 0, sizeof(ticket));
        DJ_CHECK(dj_prepare(context.jobs, epoch + 1, 3, source, &ticket) == 0);
        DJ_CHECK(dizzass_jobs_finish(context.jobs, &ticket, DIZZASS_TX_WRITTEN) == 0);
    }
    for (i = 0; i < 4; ++i) {
        DJ_CHECK(pthread_join(threads[i], NULL) == 0);
        DJ_CHECK(readers[i].failures == 0);
        DJ_CHECK(readers[i].successes + readers[i].rejected == 1000);
        successes += readers[i].successes; rejected += readers[i].rejected;
    }
    DJ_CHECK(pthread_barrier_destroy(&context.barrier) == 0);
    printf("NATIVE_JOBS_THREADS reads=4000 transitions=200 snapshots=%u rejected=%u\n", successes, rejected);
    dizzass_jobs_destroy(&context.jobs); free_work(source);
    ++dj_groups;
}

static void dj_all(void)
{
    dj_lifetime(); dj_send_outcomes(); dj_guards_and_capacity();
    dj_allocation_failures(); dj_rx_frames(); dj_concurrent_snapshots();
    printf("NATIVE_JOBS_PASS groups=%u assertions=%u\n", dj_groups, dj_assertions);
}
