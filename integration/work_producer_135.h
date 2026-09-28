/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_WORK_PRODUCER_135_H
#define VN135_WORK_PRODUCER_135_H
#include "xminer/recovery/work_nonce.h"

/* Field projections of the already captured 104-byte worker-local template.
 * These are not its ABI, native cgminer work/pool, or a new runtime job model. */
struct vn135_producer_template {
    uint32_t key;                 /* original local +0 */
    uint8_t header_words[44];     /* original +08..+33, retained byte fields */
    const uint8_t *coinbase;      /* +48 */
    uint32_t coinbase_size;       /* +4c */
    uint32_t counter_offset;      /* +40 */
    uint32_t counter_size;        /* +44, valid domain 0..8 */
    const uint8_t *branches;      /* +50, flat 32-byte rows */
    uint32_t branch_count_bits;   /* +54, signed original word */
};
struct vn135_producer_ring { uint32_t head,tail; vn135_work_job_snapshot *rows; };
struct vn135_producer_view {
    const struct vn135_producer_template *job;
    struct vn135_producer_ring *ring; /* 768 accessible rows */
    uint64_t *counter;               /* worker-local copy, not template counter */
    void *backend;                   /* identity passed to original 5ccf4 */
};
struct vn135_producer_ops {
    uint32_t (*count)(void *,void *backend); /* signed result bits of 5ccf4 */
    int32_t (*sync)(void *,uint32_t entry,uint32_t mutex_identity);
    uint8_t *(*allocate)(void *,uint32_t size); /* 5940ec, successful allocation */
    void (*release)(void *,uint8_t *);         /* 593c8c */
};
/* Bounded c2498 batch: c2970 through c2e80, NOT the whole worker.
 * All objects/callbacks valid and nonoverlapping, callback serialization only.
 * Input template and its arrays, view identities and counter are immutable to
 * callbacks. Dimensions fit input buffers; counter_size<=8; offset+size fits
 * coinbase. Input pointers are accessible even at zero size. Positive signed
 * branch count fits a flat array without 32-bit size/address wrap. Allocation returns
 * distinct accessible memory, even for size zero, and release owns it.
 * Ring head/tail/rows may change at callbacks; row storage itself is stable.
 * Ring indices outside 0..767 are handled only by the observed full/guard paths;
 * no address-wrap/corrupt-pointer execution is modeled. Callbacks must terminate
 * the batch (a large count plus continuous draining is otherwise unbounded).
 * No allocation-failure policy, original template acquisition, wait/start/exit,
 * native production registration, thread safety, freshness or hardware I/O.
 * No new success/status code: void marks only reaching the slice endpoint. */
void vn135_work_producer_batch_135(const struct vn135_producer_view *,
    const struct vn135_producer_ops *,void *);
#endif
