#ifndef VN135_RECOVERY_NONCE_VERIFY_H
#define VN135_RECOVERY_NONCE_VERIFY_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
/* New integration types, NOT the original work/thread/pool ABI.
 * Inputs are fixed-size accessible byte arrays. Unless stated otherwise,
 * mutable objects and callback-owned state must not overlap. Callers serialize
 * access. No function below sends a share or proves job freshness. */
#define VN135_VERIFY_HEADER_BYTES 80u
#define VN135_VERIFY_DIGEST_BYTES 32u
#define VN135_RECENT_JOB_COUNT 3u

typedef struct {
    uint8_t header_words_le[80]; /* Each word reversed relative to wire header. */
    uint8_t digest[32];          /* Raw SHA digest, not reversed display hex. */
} vn135_verify_work;

typedef void (*vn135_work_hash_fn)(void *context,
    const uint8_t header_words_le[80], uint8_t digest[32]);

enum vn135_prefilter_result {
    VN135_PREFILTER_CONTINUE = 0, /* Only the recovered prefix passed. */
    VN135_PREFILTER_DUPLICATE = 1,
    VN135_PREFILTER_HIGH_WORD = 2,
    VN135_VERIFY_INVALID = -2
};

/* Independent fixed-length support implementation, checked against original
 * SHA functions and Python hashlib. Input is SERIALIZED header bytes. */
int vn135_sha256d_header80(const uint8_t header[80], uint8_t digest[32]);
/* Original 0x2d994: reverse each source word, SHA256 twice.
 * Only the 80-byte header and 32-byte digest are exposed, not a 632-byte work ABI.
 * Header and digest MAY overlap: input is consumed before output is written. */
int vn135_frontend_hash_words80(const uint8_t header_words_le[80], uint8_t digest[32]);
/* Original 0x10c1c: little-endian 256-bit unsigned hash <= target; equality passes.
 * Returns 1/0, or -2 for NULL. An all-zero target is not rejected artificially. */
int vn135_target256_check_le(const uint8_t hash[32], const uint8_t target[32]);
/* Prefix 0x32f60..0x330a4. A scalar last_nonce has NO validity bit/job identifier:
 * if equal, reject without hash or mutation. Otherwise save last_nonce, write
 * nonce little-endian at header+76, invoke hash exactly once, check high word.
 * Numeric selector==1 permits high word <=0xffff, every other value permits 0.
 * Selector names/algorithm binding NOT established. Callback cannot report error,
 * as in observed boundary; production errors need a separate policy.
 * Diagnostics and the two getter calls are not part of the normalized API. */
int vn135_frontend_nonce_prefilter(vn135_verify_work *work, uint32_t *last_nonce,
    uint32_t nonce, uint32_t selector, vn135_work_hash_fn hash, void *context);
/* New explicitly selected SHA256d binding, NOT a proven T21 runtime dispatch. */
int vn135_frontend_sha256d_prefilter(vn135_verify_work *work, uint32_t *last_nonce,
    uint32_t nonce, uint32_t selector);

/* Consumer slice 0x74de4..0x74e7c/0x74f14: normalized stable three-record window.
 * The first matching key is decisive EVEN if that record is unusable.
 * Word_1fc is raw observed data, not an invented freshness/generation field.
 * Caller supplies an immutable, coherent snapshot; reference is an opaque token.
 * The injectable boundary represents original 0x34d54. Its list-membership
 * computation is also reconstructed below for a coherent reference-list snapshot. */
typedef struct {
    uint32_t key;
    void *reference;
    uint32_t word_1fc;
} vn135_recent_job_record;
typedef int (*vn135_job_reject_fn)(void *context, void *reference);
enum vn135_job_match_result {
    VN135_JOB_SELECTED = 0,
    VN135_JOB_NOT_FOUND = 1,
    VN135_JOB_NULL_REFERENCE = 2,
    VN135_JOB_REJECTED = 3,
    VN135_JOB_STATUS_ZERO = 4
};
/* selected_index remains unchanged on failure. No fallback to a later match. */
int vn135_recent_job_select(const vn135_recent_job_record records[3], uint32_t key,
    vn135_job_reject_fn reject, void *context, size_t *selected_index);
/* Original 0x34d54 normalized to a coherent caller-owned list. Original lock/
 * unlock wrap this lookup; this API requires external synchronization instead.
 * Returns 1 when absent, 0 when present, -2 for NULL list with positive count.
 * A signed count <=0 returns absent, as in the original. No pointee is read.
 * With positive count the caller provides at least count accessible entries. */
int vn135_reference_absent(void *const *references, int32_t count, void *reference);
/* New binding of recovered selection to recovered membership, same stable
 * snapshot precondition; no job generation, timeouts or reference ownership. */
int vn135_recent_job_select_registered(const vn135_recent_job_record records[3],
    uint32_t key, void *const *references, int32_t count, size_t *selected_index);
#ifdef __cplusplus
}
#endif
#endif
