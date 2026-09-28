/* Native cgminer integration, GPL-3.0-or-later. No second work or SHA core. */
#include "config.h"
#include "miner.h"
#include "integration/native_work_tx88.h"
#include <string.h>

int dizzass_native_work_tx88(const struct work *source,
    uint32_t platform_selector, uint32_t algorithm_selector, uint32_t slot,
    uint8_t *out, size_t capacity)
{
    enum dizzass_work_family family;
    int rc;
    if (!source || !out)
        return DIZZASS_TX88_INVALID;
    rc = dizzass_work_route_select(platform_selector, algorithm_selector, &family);
    if (rc)
        return rc;
    if (family != DIZZASS_WORK_SHA256_TX88)
        return DIZZASS_ROUTE_UNSUPPORTED;
    return dizzass_tx88_encode_words(source->data, 80, slot, out, capacity);
}

int dizzass_jobs_prepare_tx88(struct dizzass_jobs *jobs,
    uint64_t expected_epoch, uint32_t platform_selector,
    uint32_t algorithm_selector, uint32_t slot, uint32_t variant,
    const struct work *source, struct dizzass_tx88_prepared *out)
{
    struct dizzass_tx88_prepared prepared = {0};
    uint32_t version_base;
    int rc;
    if (!jobs || !source || !out || out->ticket.epoch || out->ticket.serial ||
        out->ticket.chain_id || out->ticket.slot || variant > 2)
        return DIZZASS_JOBS_INVALID;
    rc = dizzass_native_work_tx88(source, platform_selector, algorithm_selector,
        slot, prepared.packet, sizeof(prepared.packet));
    if (rc)
        return rc;
    version_base = (uint32_t)source->data[0] |
        (uint32_t)source->data[1] << 8 | (uint32_t)source->data[2] << 16 |
        (uint32_t)source->data[3] << 24;
    rc = dizzass_jobs_prepare(jobs, expected_epoch, slot, variant, version_base,
        source, &prepared.ticket);
    if (rc)
        return rc;
    *out = prepared;
    return DIZZASS_JOBS_OK;
}
