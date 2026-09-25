#ifndef VN135_RECOVERY_WORK_STORAGE_H
#define VN135_RECOVERY_WORK_STORAGE_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
/* New integration API, NOT the native 632-byte vendor work ABI.
 * image preserves opaque bytes; the four KNOWN owned string pointer slots are
 * ALWAYS zero. Their native pointers live in text[]. Other original pointer-like
 * words are opaque cookies: this API never dereferences or owns them.
 * Do not serialize this type, cast it to vendor work or insert it in its queue.
 * Copying opaque bytes does NOT reconstruct the meaning/lifetime of every field.
 * All inputs, outputs, failure masks and mutable storage are distinct accessible
 * objects; caller excludes concurrent use and allocator reentry.
 */
#define VN135_WORK_IMAGE_BYTES 632u
#define VN135_WORK_TEXT_COUNT 4u
enum { VN135_TEXT_18C=0, VN135_TEXT_19C=1, VN135_TEXT_1A8=2, VN135_TEXT_1B0=3 };
enum { VN135_STORAGE_OK=0, VN135_STORAGE_PARTIAL=1,
       VN135_STORAGE_INVALID=-2, VN135_STORAGE_NOMEM=-3 };
typedef struct { const uint8_t *data; size_t size; } vn135_text_view;
typedef struct {
    uint8_t image[VN135_WORK_IMAGE_BYTES];
    char *text[VN135_WORK_TEXT_COUNT];
    size_t text_size[VN135_WORK_TEXT_COUNT];
} vn135_work_storage;
typedef struct {
    void *context;
    void *(*allocate)(void *context,size_t bytes);
    void (*release)(void *context,void *allocation);
} vn135_work_memory;
typedef struct {
    uint64_t difficulty_bits; /* Bit-preserving copy, not validation of difficulty. */
    vn135_text_view text_3d0;
    vn135_text_view text_3ec;
    vn135_text_view text_396;
} vn135_work_metadata_view;
/* Views exclude NUL, have no embedded NUL and refer to accessible bytes.
 * NULL,size=0 is ABSENT; non-NULL,size=0 is an empty string. Metadata requires
 * all three strings present, as the observed original calls strdup unchecked.
 * out must have its three target text fields NULL and all four image pointer
 * slots zero. The fourth native text field is not modified.
 * Attempts all three copies in original order (18c,1a8,19c), even on allocation
 * failure. PARTIAL leaves already allocated strings owned by out. failed_mask
 * bits use the VN135_TEXT_* indices. The new status is NOT a vendor return code.
 */
int vn135_frontend_work_metadata_copy_legacy(vn135_work_storage *out,
    const vn135_work_metadata_view *view,const vn135_work_memory *memory,
    uint32_t *failed_mask);
/* Original 0x2ce84 copy route ONLY with time-roll argument == 0.
 * Fresh id substitutes the original serialized global ID allocator; no global
 * state/locks are reproduced. All nonpointer image bytes are copied verbatim
 * except +0x1bc. Only the four observed strings are deep-copied.
 * out must point to NULL. Allocation of the outer object failing is handled by
 * a NEW guard. String allocation failure preserves the original partial clone
 * and attempts later copies. Input remains immutable. No retain of pool/job.
 */
int vn135_frontend_work_clone_unrolled(const vn135_work_storage *source,
    uint32_t fresh_id,const vn135_work_memory *memory,vn135_work_storage **out,
    uint32_t *failed_mask);
/* Free order from original: 18c,19c,1b0,1a8. clear zeros the whole image after
 * releasing strings and retains the storage object. delete additionally frees
 * the object, then NULLs the caller pointer; the object must be allocated by
 * clone using the SAME allocator. Neither function releases opaque references.
 * All strings must be distinct owned allocations. No concurrent users/reentry.
 * These functions are NOT secure erasure and NOT full job lifetime management.
 */
int vn135_frontend_work_storage_clear(vn135_work_storage *work,
    const vn135_work_memory *memory);
int vn135_frontend_work_storage_delete(vn135_work_storage **work,
    const vn135_work_memory *memory);
/* NEW transactional adapter: destroys a partial legacy clone and does not
 * publish it. This rollback is NOT claimed to exist in the vendor firmware.
 * Atomic here means publication/rollback policy, NOT thread-safe or lock-free. */
int vn135_work_clone_atomic(const vn135_work_storage *source,uint32_t fresh_id,
    const vn135_work_memory *memory,vn135_work_storage **out);
/* Two bounded scalar-write slices. Cookies/word names deliberately retain
 * offsets: they are not native pointers or independently proven field names.
 * image must be accessible, unshared, and not alias the reference counter.
 * Increment of reference_word_98 is modulo 2^32, not proof of refcount semantics.
 */
int vn135_frontend_work_builder_fields(uint8_t image[VN135_WORK_IMAGE_BYTES],
    uint32_t template_cookie,uint32_t global_cookie);
int vn135_frontend_work_wrapper_fields(uint8_t image[VN135_WORK_IMAGE_BYTES],
    uint32_t reference_cookie,uint32_t word_168,uint32_t global_cookie,
    uint32_t *reference_word_98,uint32_t word_160,uint32_t word_254);
#ifdef __cplusplus
}
#endif
#endif
