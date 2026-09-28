/* Native fixed-work TX88 preparation, GPL-3.0-or-later. No transport. */
#ifndef DIZZASS_NATIVE_WORK_TX88_H
#define DIZZASS_NATIVE_WORK_TX88_H
#include "integration/native_jobs.h"
#include "integration/work_route.h"
#include "integration/work_tx88.h"

struct dizzass_tx88_prepared {
    struct dizzass_job_ticket ticket;
    uint8_t packet[DIZZASS_TX88_SIZE];
};
/* Source must be immutable and retained throughout the call. Output must not
 * overlap source (including its strings), jobs, or any other live object.
 * Only a SHA256 TX88 route is accepted. Does not invent a T21 chip profile,
 * read hwscan JSON, generate work, allocate, submit or touch hardware.
 */
int dizzass_native_work_tx88(const struct work *source,
    uint32_t platform_selector, uint32_t algorithm_selector, uint32_t slot,
    uint8_t *out, size_t capacity);

/* Encode and reserve the exact same immutable native work. The entire ticket
 * must initially be zero; packet bytes need not be. On success the registry
 * entry remains PREPARED, not WRITTEN. No fallible operation follows prepare.
 * On error *out remains unchanged. Errors may come from route/packet/jobs APIs.
 * The native core's allocation failure policy still applies; this is not a
 * replacement allocator. Source ownership and pool lifetime remain native.
 *
 * variant is the caller-confirmed RX layout, not guessed from TX88. This is
 * fixed work only: version_base is the actual LE word at source->data[0..3].
 * No version-rolling mask or hardware capability is inferred. Quarantine,
 * no in-epoch slot reuse, and externally drained epoch requirements remain.
 * After success the actual transport must use dizzass_jobs_finish() with its
 * real outcome. A successful preparation NEVER implies a sent/accepted job.
 */
int dizzass_jobs_prepare_tx88(struct dizzass_jobs *jobs,
    uint64_t expected_epoch, uint32_t platform_selector,
    uint32_t algorithm_selector, uint32_t slot, uint32_t variant,
    const struct work *source, struct dizzass_tx88_prepared *out);
#endif
