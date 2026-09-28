/* Native work is owned and formed by upstream cgminer. GPL-3.0-or-later. */
#include "config.h"
#include "miner.h"
#include "integration/native_work_tx.h"
int dizzass_native_work_tx86(const struct work *work,
    enum dizzass_tx86_layout layout, uint32_t raw_job_id,
    uint8_t *out, size_t capacity)
{
    if (!work)
        return DIZZASS_TX86_INVALID;
    return dizzass_work_tx86_encode(work->data, 80u, layout, raw_job_id, out, capacity);
}
