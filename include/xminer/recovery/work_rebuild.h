/* SPDX-License-Identifier: GPL-3.0-only
 * New normalized APIs for bounded original work materialization. These are
 * NOT the vendor's work/pool ABI and do not register a runtime mining driver.
 */
#ifndef VN135_RECOVERY_WORK_REBUILD_H
#define VN135_RECOVERY_WORK_REBUILD_H
#include <stddef.h>
#include <stdint.h>
#include "xminer/recovery/work_nonce.h"
#include "xminer/recovery/nonce_verify.h"
#ifdef __cplusplus
extern "C" {
#endif
#define VN135_WORK_PREFIX_BYTES 112u

/* New one-shot support, compared with original SHA 0x108f38. Original length
 * argument is uint32_t; larger messages are deliberately rejected. NULL data
 * is allowed ONLY with size zero. Output may overlap input: all input is read
 * before writing the 32-byte digest. No heap, I/O or global mutable state. */
int vn135_sha256_bytes(const uint8_t *data,size_t size,uint8_t digest[32]);
int vn135_sha256d_bytes(const uint8_t *data,size_t size,uint8_t digest[32]);

/* Coherent caller-owned view of fields read by 0x30550..0x30a6c.
 * See evidence/stage9/ for original offsets. Not a full original structure.
 * The caller supplies accessible arrays and exclusive access; mutable objects,
 * inputs and output MUST NOT overlap. This function implements no rwlock.
 * merkle_branches is a flat array of merkle_count consecutive 32-byte hashes.
 * counter_size <=8 is an explicit valid-domain restriction of the new API;
 * original code can read beyond its 8-byte temporary if given bad dimensions.
 */
typedef struct {
    uint8_t header_words_le[112]; /* word-swapped representation, not wire bytes */
    uint8_t *coinbase;
    size_t coinbase_size;
    size_t counter_offset;
    uint32_t counter_size;
    uint64_t counter;
    const uint8_t *merkle_branches;
    size_t merkle_count;
} vn135_work_template;

typedef struct {
    uint8_t header_words_le[112];
    uint8_t merkle_root[32]; /* raw SHA digest; not reversed display hex */
    uint64_t counter_used;
    uint32_t counter_size;
} vn135_rebuilt_header;

/* Original bounded prefix: patch low counter bytes into coinbase, advance full
 * uint64 counter modulo 2^64, SHA256d coinbase, SHA256d(root||branch) in order,
 * copy 112 template bytes and replace words at offsets 36..67 with root.
 * Returns 0 or -2. Invalid arguments do not mutate any object. Original locking,
 * string duplication, target-from-difficulty and later metadata are excluded.
 * Output is 112 meaningful bytes, NOT a complete 632-byte original work. */
int vn135_frontend_rebuild_prefix(vn135_work_template *job,vn135_rebuilt_header *out);

/* Read-only saved-template view. The caller must already have selected and
 * pinned the correct job. A matching 5-bit slot or scalar key is NOT freshness.
 * Pointers are normal validated caller-owned arrays, not pointers read from ELF.
 */
typedef struct {
    uint8_t header_words_le[112];
    const uint8_t *coinbase;
    size_t coinbase_size;
    size_t counter_offset;
    uint32_t counter_size;
    const uint8_t *merkle_branches;
    size_t merkle_count;
} vn135_rebuild_snapshot;

/* New isolated binding of the proved consumer argument mapping and core prefix.
 * candidate words +0x18/+0x1c become the uint64 coinbase counter; +0x14 becomes
 * the first work word after two REV operations in caller/wrapper.
 * Copies coinbase into caller scratch; never mutates the shared saved template.
 * Scratch must be at least coinbase_size, and disjoint from all input/output.
 * Returns 0, -2 invalid input, or -3 insufficient scratch. On failure, no writes.
 * Does not consume candidate.midstate as proof or implement pool reference life.
 */
int vn135_rebuild_from_candidate(const vn135_nonce_candidate *candidate,
    const vn135_rebuild_snapshot *snapshot,uint8_t *scratch,size_t scratch_size,
    vn135_rebuilt_header *out);

typedef struct {
    vn135_rebuilt_header rebuilt;
    vn135_verify_work work;
    int prefilter_result;
    uint32_t hash_computed;
    uint32_t target_checked;
    uint32_t meets_target;
} vn135_rebuild_check;

/* New offline composition, NOT the complete original consumer:
 * rebuild -> recovered scalar duplicate/high-word prefilter -> target check.
 * target is explicitly supplied; difficulty->target is not fabricated.
 * last_nonce obeys original prefilter semantics and stays changed after hash
 * rejection. Returns 0 for a completed computation, NOT for accepted work.
 * Duplicate: hash_computed=0, digest remains zero, target_checked=0.
 * No global dedup, job freshness, queue ownership, submission, device or network.
 */
int vn135_candidate_verify_snapshot(const vn135_nonce_candidate *candidate,
    const vn135_rebuild_snapshot *snapshot,uint8_t *scratch,size_t scratch_size,
    const uint8_t target_le[32],uint32_t *last_nonce,uint32_t selector,
    vn135_rebuild_check *out);
#ifdef __cplusplus
}
#endif
#endif
