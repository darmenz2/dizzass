#ifndef VN135_RECOVERY_WORK_TIME_H
#define VN135_RECOVERY_WORK_TIME_H
#include "xminer/recovery/work_storage.h"
#ifdef __cplusplus
extern "C" {
#endif
/* Stage12 fixed-width integration API. The original general hex helpers accept
 * different lengths; only their four-byte time use is reconstructed here.
 * All pointers must reference accessible, nonoverlapping objects. decode8 reads
 * exactly eight bytes (no terminator required), accepts ASCII 0-9/a-f/A-F, and
 * leaves *value unchanged on invalid input. encode8 writes eight lowercase hex
 * characters and NUL. Invalid input rejection is NEW, not the original partial
 * write behavior of 0x107b0. These functions do not validate pool time policy. */
int vn135_work_time_decode8(const uint8_t hex[8],uint32_t *value);
int vn135_work_time_encode8(uint32_t value,char hex[9]);
/* Original clone at 0x2ce84, time branch included on the valid-input domain.
 * delta is the raw 32-bit addend; addition wraps modulo 2^32. It is NOT permission
 * to roll pool time by that amount. fresh_id replaces the global ID allocator.
 * With delta==0 this is exactly the previous unrolled API. With delta!=0:
 * - image[0x44..0x47] is a big-endian time value and receives delta;
 * - present text[VN135_TEXT_19C] MUST contain exactly eight valid hex digits;
 *   its independent value receives delta and is rendered in lowercase;
 * - an absent time string stays absent. No equality check is implied between
 *   the header's time and the string. No wall clock, time bounds, target or
 *   hash refresh, job lifetime check, work submission or last_nonce reset.
 * String copy order stays 18c,1a8,19c,1b0; the rolled 19c allocation is 12 zeroed
 * bytes (original calloc extent), logical text size 8. Other strings use size+1.
 * Original unchecked NULL from time-encoder calloc is NOT reproduced: failure
 * produces PARTIAL with bit 19c and later copies proceed (NEW guarded policy).
 * Source/normalized-pointer/ownership requirements are in work_storage.h.
 * Invalid time rejects BEFORE allocations and leaves output/failure mask intact.
 * This API is NOT vendor binary ABI and not a complete roll-work scheduler. */
int vn135_frontend_work_clone_time_legacy(const vn135_work_storage *source,
    uint32_t fresh_id,uint32_t delta,const vn135_work_memory *memory,
    vn135_work_storage **out,uint32_t *failed_mask);
/* NEW all-or-nothing publication policy. A failed partial copy is freed; output
 * remains NULL. Not hardware atomicity, thread safety or vendor rollback logic. */
int vn135_work_clone_time_atomic(const vn135_work_storage *source,
    uint32_t fresh_id,uint32_t delta,const vn135_work_memory *memory,
    vn135_work_storage **out);
#ifdef __cplusplus
}
#endif
#endif
