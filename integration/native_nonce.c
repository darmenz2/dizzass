/* Native cgminer adapter, GPL-3.0-or-later.
 * Hardware-only decoding is ported from the separately retained Stage 6/7
 * work-gen slices (0xc4480..0xc46fc). Everything concerning work ownership,
 * hashing and target comparison is delegated to the existing cgminer core.
 */
#include "config.h"
#include "miner.h"
#include "integration/native_nonce.h"

static uint32_t read_le_word(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

int dizzass_nonce_decode_payload(uint32_t chip_selector, uint32_t variant,
    uint32_t chain_id, const uint8_t *payload, size_t size,
    struct dizzass_nonce_reply *out)
{
    struct dizzass_nonce_reply r;
    uint32_t raw, v;
    size_t off;

    if (!payload || !out || variant > 2 || size != 7u + variant)
        return DIZZASS_NONCE_INVALID;
    if (!(payload[size - 1] & 0x80u))
        return DIZZASS_NONCE_INVALID;
    raw = payload[variant == 1 ? 6 : 5];
    if ((chip_selector | 1u) == 5u)
        raw = (variant == 2 ? (uint32_t)payload[4] << 7 :
               UINT32_C(0xffffff80)) | (raw >> 1);
    v = variant == 2 ? ((uint32_t)payload[6] << 8) | payload[7] : 0xffffu;
    off = variant == 1 ? 1u : 0u;
    r.chain_id = chain_id;
    r.slot = (raw >> 3) & 31u;
    r.variant = variant;
    r.nonce_word = ((uint32_t)payload[off] << 24) |
                   ((uint32_t)payload[off + 1] << 16) |
                   ((uint32_t)payload[off + 2] << 8) | payload[off + 3];
    r.version_bits = (v >> 11) | ((v & 7u) << 21) | ((v & 0x7f8u) << 5);
    *out = r;
    return DIZZASS_NONCE_OK;
}

int dizzass_nonce_check_matched(const struct dizzass_nonce_match *match,
    const struct dizzass_nonce_reply *reply, struct dizzass_nonce_check *out)
{
    struct dizzass_nonce_check result = {0};
    const struct work *source;

    if (!match || !reply || !out || !match->work || out->work ||
        match->slot > 31 || reply->slot > 31 ||
        match->variant > 2 || reply->variant > 2)
        return DIZZASS_NONCE_INVALID;
    if (reply->chain_id != match->chain_id)
        return DIZZASS_NONCE_WRONG_CHAIN;
    if (reply->slot != match->slot)
        return DIZZASS_NONCE_WRONG_SLOT;
    if (reply->variant != match->variant)
        return DIZZASS_NONCE_WRONG_FORMAT;
    source = match->work;
    if ((match->version_base_word | reply->version_bits) !=
        read_le_word(source->data))
        return DIZZASS_NONCE_WRONG_VERSION;

    result.work = copy_work_noffset((struct work *)source, 0);
    if (!result.work)
        return DIZZASS_NONCE_PARTIAL_COPY;
    if ((source->job_id && !result.work->job_id) ||
        (source->nonce1 && !result.work->nonce1) ||
        (source->ntime && !result.work->ntime) ||
        (source->coinbase && !result.work->coinbase)) {
        free_work(result.work);
        return DIZZASS_NONCE_PARTIAL_COPY;
    }
    result.passes_diff1 = test_nonce(result.work, reply->nonce_word);
    result.meets_target = fulltest(result.work->hash, result.work->target);
    *out = result;
    return DIZZASS_NONCE_OK;
}

void dizzass_nonce_check_clear(struct dizzass_nonce_check *result)
{
    if (!result)
        return;
    if (result->work)
        free_work(result->work);
    result->passes_diff1 = false;
    result->meets_target = false;
}
