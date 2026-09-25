#ifndef VN135_RECOVERY_WORK_FRESHNESS_H
#define VN135_RECOVERY_WORK_FRESHNESS_H
#include <stddef.h>
#include <stdint.h>
#include "work_storage.h"
#ifdef __cplusplus
extern "C" {
#endif
/* New snapshot API, NOT vendor ABI and NOT a live pool/job registry.
 * Snapshots and text views must remain coherent and immutable throughout the
 * call. No pointer cookie is dereferenced; caller owns/retains real pool/job.
 * Text views exclude the NUL. NULL+0 means absent, non-NULL+0 means empty.
 * Nonempty views must be accessible and must contain no embedded NUL.
 * No network or current-clock reads, mutexes, allocation or share submission.
 */
enum { VN135_FRESHNESS_OK=0, VN135_FRESHNESS_INVALID=-2 };
enum { VN135_WORK_CURRENT=0, VN135_WORK_BLOCK_CHANGED=1,
       VN135_WORK_STRATUM_INACTIVE=2, VN135_WORK_JOB_CHANGED=3,
       VN135_WORK_EXPIRED=4 };
typedef struct {
    uint32_t word_1fc;
    uint8_t byte_3fc, byte_3fe, byte_209, byte_1ea;
} vn135_pool_gate_snapshot;
typedef struct {
    uint32_t work_block, current_work_block;
    int32_t rolltime;
    uint8_t share, pool_byte_3fc, pool_byte_3fe;
    /* Original signed 64-bit seconds represented as bits to preserve the
     * original modulo-2^64 subtraction without signed C overflow. No usec.
     * now_bits must represent the same time sample as the original caller. */
    uint64_t staged_seconds_bits, now_seconds_bits;
    vn135_text_view work_job_id, pool_job_id;
} vn135_work_freshness_snapshot;
typedef struct {
    int32_t stale, reason;
    uint32_t job_ids_compared, time_compared;
    double expiry_seconds, age_seconds;
} vn135_work_freshness_result;
/* Predicate reconstructed from 0x2a560. Raw field names intentionally retained.
 * Return status is new. A zero status does NOT mean a pool is usable: read out.
 * Input/output objects must not overlap. */
int vn135_pool_unusable_legacy(const vn135_pool_gate_snapshot *pool,int *out);
/* 0x32040 on valid snapshots and successful original synchronization.
 * Default expiry 600; signed rolltime >60 selects rolltime; equality expires.
 * share!=0 skips active/job-id checks, NOT work_block or expiry checks.
 * Missing either job-id skips string comparison (preserved original behavior).
 * Result reason/flags are new diagnostics, not vendor return values.
 * Default nearest-even FP rounding is a precondition; no flags/mode changes.
 * Validation happens before writing result; invalid leaves it untouched.
 * CURRENT is only this predicate's result, NOT proof of full job lifetime,
 * clean_jobs/session freshness, valid nonce, target success or accepted share.
 */
int vn135_frontend_work_stale_legacy(const vn135_work_freshness_snapshot *snapshot,
    vn135_work_freshness_result *out);
/* NEW adapter extracting known words from normalized Stage11 storage. It reads
 * no native pointer slots. Caller supplies coherent pool/current-block/time.
 * No retain/release; no live original lock implementation. */
int vn135_work_storage_stale_snapshot(const vn135_work_storage *work,
    uint32_t current_work_block,uint8_t share,uint8_t pool_byte_3fc,
    uint8_t pool_byte_3fe,vn135_text_view pool_job_id,uint64_t now_seconds_bits,
    vn135_work_freshness_result *out);
#ifdef __cplusplus
}
#endif
#endif
