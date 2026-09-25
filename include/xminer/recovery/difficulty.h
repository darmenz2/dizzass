/* SPDX-License-Identifier: GPL-3.0-only
 * New normalized API, not the original work/pool ABI. No miner registration.
 */
#ifndef VN135_RECOVERY_DIFFICULTY_H
#define VN135_RECOVERY_DIFFICULTY_H
#include <stdint.h>
#include "xminer/recovery/work_rebuild.h"
#ifdef __cplusplus
extern "C" {
#endif
#define VN135_DIFFICULTY_RANGE (-4)

/* Original 0x2fe60 arithmetic, default binary64 round-to-nearest/even required.
 * selector==1 selects the literal at 0x30048; all others select 0x30040.
 * Selectors are numeric, NOT claimed T21/algorithm names.
 * +/-0 difficulty is replaced by 1, as in the original. Finite positive inputs
 * are accepted only if the initial quotient is < 2^256. A larger value or
 * overflow returns -4 instead of reproducing out-of-range conversions. NaN,
 * infinities and negative inputs return -2. These are new API restrictions.
 * All errors leave output unchanged. Output is 32 little-endian target bytes.
 * Floating-point rounding is preserved; this is NOT exact rational division.
 * No pool/difficulty policy, target validity, freshness or acceptance claim.
 */
int vn135_frontend_target_from_difficulty(double difficulty,uint32_t selector,
    uint8_t target_le[32]);

/* Original arithmetic slice 0x31070..0x31100, not the entire accounting routine.
 * Four uint64 limbs are converted and added in original order (2,3,1,0).
 * All-zero target uses denominator 1, as in original; NOT a consensus rule.
 * Arbitrary 32-byte target accepted; returns 0, or -2 for NULL. Output unchanged
 * on error. Default binary64 round-to-nearest/even required. No heap or I/O.
 */
int vn135_frontend_difficulty_from_target(const uint8_t target_le[32],
    uint32_t selector,double *difficulty);

typedef struct {
    uint32_t midstate[8]; /* numeric state words, not a full digest */
    uint8_t target_le[32];
} vn135_work_math;

/* Original math slice 0x30c9c..0x30d90: swap the first 64 work bytes within words,
 * run one SHA compression and derive target from difficulty. 112 source bytes
 * are required by the surrounding recovered prefix; only the first 64 are read
 * here. Does NOT populate the rest of the 632-byte original work or own refs.
 * Inputs and output must not overlap. Errors leave output unchanged.
 */
int vn135_frontend_work_math(const uint8_t words112[112],double difficulty,
    uint32_t selector,vn135_work_math *out);

typedef struct {
    vn135_rebuild_check checked;
    uint8_t target_le[32];
} vn135_difficulty_check;

/* New OFFLINE adapter, not the original queue consumer. Derive target then
 * run Stage9 snapshot verification. Caller must supply a coherent, pinned job
 * and its matching difficulty. No network, accepted-share or freshness check.
 * On duplicate the target is derived but target_checked is still false.
 * Invalid difficulty rejected BEFORE touching scratch/output/last_nonce.
 * Other input/alias/scratch contracts are the same as Stage9.
 */
int vn135_candidate_verify_difficulty(const vn135_nonce_candidate *candidate,
    const vn135_rebuild_snapshot *snapshot,uint8_t *scratch,size_t scratch_size,
    double difficulty,uint32_t *last_nonce,uint32_t selector,
    vn135_difficulty_check *out);
#ifdef __cplusplus
}
#endif
#endif
