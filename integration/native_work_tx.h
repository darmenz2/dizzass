#ifndef DIZZASS_NATIVE_WORK_TX_H
#define DIZZASS_NATIVE_WORK_TX_H
#include "integration/work_tx86.h"
struct work;
/* Read-only projection of a retained immutable native work into an offline
 * packet. Caller must keep work stable and out disjoint from its storage.
 * Does not send, register the job, assign a slot, select a T21 model, alter
 * version/time, or use its old nonce/hash. No second work/pool or SHA engine.
 * A protocol binding must establish that this packet layout is appropriate
 * and how raw_job_id maps to RX BEFORE connecting this to native_jobs.
 */
int dizzass_native_work_tx86(const struct work *work,
    enum dizzass_tx86_layout layout, uint32_t raw_job_id,
    uint8_t *out, size_t capacity);
#endif
