/* Offline harness. Compile the REAL root cgminer.c with its main renamed only
 * in this test translation unit. No copied work type, SHA, target or allocator.
 * GPL-3.0-or-later. Never used as a production miner entry point.
 */
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "integration/native_nonce.h"
#include "xminer/recovery/work_rx.h"
#include "xminer/recovery/work_nonce.h"
#include "tests/fixtures/genesis_work.h"
#include <sys/socket.h>

static unsigned dn_assertions, dn_decodes, dn_streams, dn_vectors;
#define DN_CHECK(x) do { ++dn_assertions; if (!(x)) { \
    fprintf(stderr, "native-nonce FAIL %d: %s\n", __LINE__, #x); exit(1); \
} } while (0)

/* Fail closed if these test paths unexpectedly attempt network/device setup. */
int __wrap_socket(int domain, int type, int protocol)
{
    (void)domain; (void)type; (void)protocol;
    fprintf(stderr, "Unexpected socket in offline native test\n"); abort();
}
int __wrap_connect(int fd, const struct sockaddr *address, socklen_t length)
{
    (void)fd; (void)address; (void)length;
    fprintf(stderr, "Unexpected connect in offline native test\n"); abort();
}
int __wrap_libusb_init(libusb_context **context)
{
    (void)context;
    fprintf(stderr, "Unexpected USB initialization in offline native test\n"); abort();
}

static uint32_t dn_rng = UINT32_C(0x154d2026);
static uint32_t dn_random(void)
{
    dn_rng ^= dn_rng << 13; dn_rng ^= dn_rng >> 17; dn_rng ^= dn_rng << 5;
    return dn_rng;
}
static uint32_t dn_le(const unsigned char *p)
{
    return p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}
static void dn_put_le(unsigned char *p, uint32_t value)
{
    unsigned j; for (j = 0; j < 4; ++j) p[j] = (unsigned char)(value >> (8 * j));
}
static void dn_put_be(unsigned char *p, uint32_t value)
{
    unsigned j; for (j = 0; j < 4; ++j) p[j] = (unsigned char)(value >> (24 - 8 * j));
}
static void dn_hex(const unsigned char *p, size_t n)
{
    size_t j; for (j = 0; j < n; ++j) printf("%02x", p[j]);
}
static struct work *dn_work(void)
{
    struct work *w = make_work();
    memcpy(w->data, fixture_words, sizeof(fixture_words));
    memset(w->hash, 0xa5, sizeof(w->hash));
    set_target(w->target, 1.0);
    w->job_id = strdup("offline-fixture-job");
    w->nonce1 = strdup("00112233");
    w->ntime = strdup("495fab29");
    w->coinbase = strdup("offline-owned-string");
    DN_CHECK(w->job_id && w->nonce1 && w->ntime && w->coinbase);
    return w;
}
static struct dizzass_nonce_reply dn_reply(const struct work *w)
{
    struct dizzass_nonce_reply r = {2, 3, 2, 0, 0};
    r.nonce_word = dn_le(w->data + 76);
    return r;
}
static struct dizzass_nonce_match dn_match(const struct work *w)
{
    struct dizzass_nonce_match m = {w, 2, 3, 2, 0};
    m.version_base_word = dn_le(w->data);
    return m;
}

static void dn_decoder_cases(void)
{
    unsigned chip, variant, i, j;
    for (chip = 0; chip < 9; ++chip) for (variant = 0; variant < 3; ++variant)
        for (i = 0; i < 100; ++i) {
            unsigned char p[9]; uint32_t slot = 99, bits = 0;
            struct dizzass_nonce_reply got;
            for (j = 0; j < sizeof(p); ++j) p[j] = (unsigned char)dn_random();
            p[6 + variant] |= 0x80;
            DN_CHECK(dizzass_nonce_decode_payload(chip, variant, 7, p, 7 + variant, &got) == 0);
            DN_CHECK(vn135_work_rx_job_slot(chip, variant, p, 7 + variant, &slot) == 0);
            DN_CHECK(vn135_work_nonce_version_bits(variant, p, 7 + variant, &bits) == 0);
            DN_CHECK(got.chain_id == 7 && got.slot == slot && got.version_bits == bits);
            j = variant == 1 ? 1 : 0;
            DN_CHECK(got.nonce_word == ((uint32_t)p[j] << 24 | (uint32_t)p[j+1] << 16 |
                                       (uint32_t)p[j+2] << 8 | p[j+3]));
            ++dn_decodes;
        }
    {
        struct dizzass_nonce_reply result, before;
        unsigned char p[9] = {0};
        memset(&result, 0xa5, sizeof(result)); before = result;
        DN_CHECK(dizzass_nonce_decode_payload(6, 2, 0, p, 9, &result) == DIZZASS_NONCE_INVALID);
        DN_CHECK(memcmp(&result, &before, sizeof(result)) == 0);
        p[8] = 0x80;
        for (j = 0; j < 12; ++j) if (j != 9) {
            DN_CHECK(dizzass_nonce_decode_payload(6, 2, 0, p, j, &result) == DIZZASS_NONCE_INVALID);
            DN_CHECK(memcmp(&result, &before, sizeof(result)) == 0);
        }
        DN_CHECK(dizzass_nonce_decode_payload(6, 3, 0, p, 9, &result) == DIZZASS_NONCE_INVALID);
        DN_CHECK(dizzass_nonce_decode_payload(6, 2, 0, NULL, 9, &result) == DIZZASS_NONCE_INVALID);
        DN_CHECK(dizzass_nonce_decode_payload(6, 2, 0, p, 9, NULL) == DIZZASS_NONCE_INVALID);
    }
}

static void dn_stream_cases(void)
{
    size_t fragment;
    for (fragment = 1; fragment <= 11; ++fragment) {
        struct work *source = dn_work(), before = *source;
        struct dizzass_nonce_match match = dn_match(source);
        struct dizzass_nonce_reply reply;
        struct dizzass_nonce_check result = {0};
        vn135_work_rx_stream stream; vn135_work_rx_message message;
        unsigned char frame[11] = {0xaa,0x55,0,0,0,0,0,24,0,0,0x80};
        size_t pos = 0;
        dn_put_be(frame + 2, dn_le(fixture_words + 76));
        DN_CHECK(vn135_work_rx_stream_init(&stream, 2, 1, 6, 0) == 0);
        while (pos < sizeof(frame)) {
            size_t amount = sizeof(frame) - pos, used = 99; int rc;
            if (amount > fragment) amount = fragment;
            rc = vn135_work_rx_stream_feed(&stream, frame + pos, amount, &used, &message);
            DN_CHECK(used > 0 && used <= amount); pos += used;
            if (pos < sizeof(frame)) DN_CHECK(rc == VN135_RX_NEED_MORE);
            else DN_CHECK(rc == VN135_RX_NONCE_RAW);
        }
        DN_CHECK(dizzass_nonce_decode_payload(stream.policy.chip_selector, stream.policy.variant,
            message.chain_id, message.payload, message.payload_size, &reply) == 0);
        DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0);
        DN_CHECK(result.work && result.work != source && result.passes_diff1 && result.meets_target);
        DN_CHECK(memcmp(result.work->hash, fixture_hash, 32) == 0);
        DN_CHECK(memcmp(source, &before, sizeof(*source)) == 0);
        DN_CHECK(result.work->id != source->id);
        DN_CHECK(result.work->job_id != source->job_id && strcmp(result.work->job_id, source->job_id) == 0);
        DN_CHECK(result.work->nonce1 != source->nonce1 && strcmp(result.work->nonce1, source->nonce1) == 0);
        DN_CHECK(result.work->ntime != source->ntime && strcmp(result.work->ntime, source->ntime) == 0);
        DN_CHECK(result.work->coinbase != source->coinbase && strcmp(result.work->coinbase, source->coinbase) == 0);
        free_work(source);
        DN_CHECK(strcmp(result.work->job_id, "offline-fixture-job") == 0);
        dizzass_nonce_check_clear(&result); dizzass_nonce_check_clear(&result);
        DN_CHECK(!result.work && !result.passes_diff1 && !result.meets_target);
        ++dn_streams;
    }
}

static void dn_match_guards(void)
{
    struct work *source = dn_work(), before = *source;
    struct dizzass_nonce_match match = dn_match(source), changed_match;
    struct dizzass_nonce_reply reply = dn_reply(source), changed;
    struct dizzass_nonce_check result = {0};
    uint32_t count = total_work;
    changed = reply; ++changed.chain_id;
    DN_CHECK(dizzass_nonce_check_matched(&match, &changed, &result) == DIZZASS_NONCE_WRONG_CHAIN);
    changed = reply; ++changed.slot;
    DN_CHECK(dizzass_nonce_check_matched(&match, &changed, &result) == DIZZASS_NONCE_WRONG_SLOT);
    changed = reply; changed.variant = 1;
    DN_CHECK(dizzass_nonce_check_matched(&match, &changed, &result) == DIZZASS_NONCE_WRONG_FORMAT);
    changed = reply; changed.version_bits = 1;
    DN_CHECK(dizzass_nonce_check_matched(&match, &changed, &result) == DIZZASS_NONCE_WRONG_VERSION);
    changed_match = match; changed_match.version_base_word ^= 0x100;
    DN_CHECK(dizzass_nonce_check_matched(&changed_match, &reply, &result) == DIZZASS_NONCE_WRONG_VERSION);
    changed = reply; changed.slot = 32;
    DN_CHECK(dizzass_nonce_check_matched(&match, &changed, &result) == DIZZASS_NONCE_INVALID);
    DN_CHECK(dizzass_nonce_check_matched(NULL, &reply, &result) == DIZZASS_NONCE_INVALID);
    DN_CHECK(dizzass_nonce_check_matched(&match, NULL, &result) == DIZZASS_NONCE_INVALID);
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, NULL) == DIZZASS_NONCE_INVALID);
    DN_CHECK(total_work == count && !result.work);
    DN_CHECK(memcmp(source, &before, sizeof(*source)) == 0);
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0);
    count = total_work;
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == DIZZASS_NONCE_INVALID);
    DN_CHECK(total_work == count); dizzass_nonce_check_clear(&result);
    memcpy(source->target, fixture_hash, 32); /* Equality is allowed by fulltest. */
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0 && result.meets_target);
    dizzass_nonce_check_clear(&result);
    memset(source->target, 0, 32);
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0 && result.passes_diff1 && !result.meets_target);
    dizzass_nonce_check_clear(&result);
    memset(source->target, 0xff, 32); ++reply.nonce_word;
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0 && !result.passes_diff1 && result.meets_target);
    dizzass_nonce_check_clear(&result);
    /* This boundary intentionally does not pretend to implement deduplication. */
    DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0);
    dizzass_nonce_check_clear(&result); dizzass_nonce_check_clear(NULL); free_work(source);
}

static void dn_hash_vectors(void)
{
    unsigned i, j;
    for (i = 0; i < 128; ++i) {
        struct work *source = dn_work();
        struct dizzass_nonce_match match;
        struct dizzass_nonce_reply reply;
        struct dizzass_nonce_check result = {0};
        unsigned char serial[80];
        for (j = 0; j < 80; ++j) source->data[j] = (unsigned char)dn_random();
        for (j = 0; j < 32; ++j) source->target[j] = (unsigned char)dn_random();
        match = dn_match(source); reply = dn_reply(source);
        reply.nonce_word = dn_random();
        DN_CHECK(dizzass_nonce_check_matched(&match, &reply, &result) == 0);
        /* Formatting only. Hash is the actual native test_nonce result. */
        for (j = 0; j < 80; ++j) serial[j] = result.work->data[(j & ~3u) + (3u - (j & 3u))];
        printf("VECTOR "); dn_hex(serial, 80); printf(" "); dn_hex(result.work->hash, 32);
        printf(" "); dn_hex(result.work->target, 32);
        printf(" %d %d\n", result.passes_diff1, result.meets_target);
        dizzass_nonce_check_clear(&result); free_work(source); ++dn_vectors;
    }
}

#ifdef DIZZASS_TEST_NATIVE_JOBS
#include "integration/tests/native_jobs_cases.h"
#endif

int main(void)
{
    /* Core startup is not called. Initialize the native locks used by helpers. */
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug = false; opt_quiet = true; opt_realquiet = true;
    dn_decoder_cases(); dn_stream_cases(); dn_match_guards(); dn_hash_vectors();
#ifdef DIZZASS_TEST_NATIVE_JOBS
    dj_all();
#endif
    printf("NATIVE_NONCE_PASS decodes=%u streams=%u vectors=%u assertions=%u\n",
        dn_decodes, dn_streams, dn_vectors, dn_assertions);
    return 0;
}
