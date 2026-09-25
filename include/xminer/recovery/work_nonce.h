/* SPDX-License-Identifier: GPL-3.0-only
 * New integration API for original work-gen RX nonce preparation.
 * No hardware, queue send, full hash/target verification, or pool submission.
 */
#ifndef VN135_WORK_NONCE_H
#define VN135_WORK_NONCE_H
#include "xminer/recovery/work_rx.h"
#ifdef __cplusplus
extern "C" {
#endif
#define VN135_WORK_JOB_SNAPSHOT_SIZE 168u
#define VN135_NONCE_CANDIDATE_DEFINED_SIZE 68u
#define VN135_ORIGINAL_NONCE_QUEUE_ELEMENT_SIZE 72u
/* Snapshot starts at 0x653460 + slot * 168 in the supplied ELF's memory layout.
 * Caller supplies a consistent immutable copy; pointer fields are not followed.
 * This is not a definition of the complete original job struct or lifecycle.
 */
typedef struct { uint8_t bytes[VN135_WORK_JOB_SNAPSHOT_SIZE]; } vn135_work_job_snapshot;
/* 68 bytes explicitly written on the recovered producer path. The original
 * queue is configured for 72 bytes at 0xfa5c4. The final four bytes are NOT
 * written by this slice; padding is a hypothesis, not a recovered semantic.
 * This compact structure MUST NOT be copied as a 72-byte vendor queue element.
 * Use the new typed API; no binary drop-in ABI compatibility is claimed. */
typedef struct {
    uint32_t chain_id,chip_id,core_id;
    uint32_t job_word_a4;    /* Copied raw job word; semantic name unproven. */
    uint32_t job_slot,version_word;
    uint32_t job_word_70,job_word_74; /* Stage9 caller/wrapper proves low/high coinbase counter.
                                   * Names retained for existing source API compatibility. */
    uint32_t nonce;
    uint32_t midstate[8];   /* Numeric SHA-256 state after exactly one block. */
} vn135_nonce_candidate;
typedef struct {
    vn135_nonce_candidate candidate;
    uint8_t compression_block[64]; /* Additional evidence output, not vendor queue ABI. */
} vn135_work_nonce_result;
typedef struct {
    void *context;
    uint32_t (*chip_from_nonce)(void *context,uint32_t nonce);
    uint32_t (*core_from_nonce)(void *context,uint32_t nonce);
} vn135_nonce_attribution;
enum { VN135_NONCE_PREPARED=0,VN135_NONCE_NO_JOB=1,
       VN135_NONCE_INVALID=-2,VN135_NONCE_LOOKUP_FAILED=-3 };
/* Original 0xc4518..0xc4578 transformation: variant <2 uses sentinel 0xffff,
 * not zero. variant=2 uses payload[6..7] in big-endian order. NOT a pool mask.
 */
int vn135_work_nonce_version_bits(uint32_t variant,const uint8_t *payload,
                                 size_t size,uint32_t *out);
/* Compute the 68 explicitly populated bytes at the queue boundary (0xc4480..0xc46fc).
 * Job selection/generation validity and nonce-frame classification are the
 * caller's responsibility. chip/core mapping remain injected operations.
 * Both are called once, chip first. Sentinel IDs are preserved, NOT validated.
 * On invalid arguments no callback runs and output stays unchanged.
 * Input/output/context objects must not overlap. No automatic I/O or retries.
 */
int vn135_work_nonce_prepare(uint32_t chip_selector,uint32_t variant,uint32_t chain,
    const uint8_t *payload,size_t size,const vn135_work_job_snapshot *job,
    const vn135_nonce_attribution *attribution,vn135_work_nonce_result *out);
/* Optional new adapter, NOT original runtime job-table code.
 * lookup must return 1 and a consistent snapshot, 0 for unavailable, or <0 for
 * failure. No retry, allocation, or generation guess. The 5-bit slot cannot
 * prove freshness: the caller must manage job reuse/invalidation separately.
 */
typedef struct {
    void *context;
    int (*read_snapshot)(void *context,uint32_t slot,vn135_work_job_snapshot *out);
} vn135_work_job_reader;
int vn135_work_nonce_from_rx(const vn135_work_rx_policy *policy,
    const vn135_work_rx_message *message,const vn135_work_job_reader *reader,
    const vn135_nonce_attribution *attribution,vn135_work_nonce_result *out);
#ifdef __cplusplus
}
#endif
#endif
