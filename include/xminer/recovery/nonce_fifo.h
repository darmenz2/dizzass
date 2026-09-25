/* SPDX-License-Identifier: GPL-3.0-only
 * Recovered FIFO/nonce-queue algorithms, with a new portable context/API.
 * NOT vendor binary ABI. Source filenames of these original routines are unknown.
 */
#ifndef VN135_NONCE_FIFO_H
#define VN135_NONCE_FIFO_H
#include <stddef.h>
#include <stdint.h>
#include "xminer/recovery/work_nonce.h"
#ifdef __cplusplus
extern "C" {
#endif
#define VN135_NONCE_FIFO_CAPACITY 4096u
#define VN135_NONCE_FIFO_RECORD_SIZE 72u

enum { VN135_FIFO_OK=0, VN135_FIFO_TRANSFERRED=1,
       VN135_FIFO_INVALID=-2, VN135_FIFO_NOMEM=-3, VN135_FIFO_SYNC_ERROR=-4 };
typedef struct {
    void *context;
    void *(*allocate)(void *context,size_t bytes);
    void (*release)(void *context,void *allocation);
} vn135_fifo_memory;
/* Offsets are element indices, not original ARM pointer slots. No internal lock.
 * Allocate/init only a zeroed or destroyed context; no shallow copy of an owner.
 * All memory must be accessible, nonoverlapping and from one allocator pair.
 */
typedef struct {
    uint8_t *storage;
    uint32_t capacity,element_size,count,write_index,read_index;
} vn135_fifo;
int vn135_fifo_init(vn135_fifo *,uint32_t capacity,uint32_t element_size,const vn135_fifo_memory *);
int vn135_fifo_push(vn135_fifo *,const void *element);
/* NULL output discards one element. Empty leaves output unchanged. */
int vn135_fifo_pop(vn135_fifo *,void *element);
int vn135_fifo_is_full(const vn135_fifo *);
int vn135_fifo_is_empty(const vn135_fifo *);
int vn135_fifo_count(const vn135_fifo *,uint32_t *out);
/* Reset keeps allocation bytes and dimensions. Destroy clears storage ONLY;
 * numeric cursors/count/dimensions remain as in the original destructor.
 * Operations requiring storage reject the destroyed context; init can reuse it.
 */
int vn135_fifo_reset(vn135_fifo *);
int vn135_fifo_destroy(vn135_fifo *,const vn135_fifo_memory *);

/* External synchronization: initialize/destroy require quiescent exclusive access.
 * The SAME mutex and allocator must be used for the entire queue lifetime.
 * Operations invoke lock/unlock around the original queue mutation/query.
 * Callback failures are new guards, not original checked error paths.
 * An unlock error can occur AFTER mutation; NEVER blindly retry that operation.
 */
typedef struct {
    void *context;
    int (*initialize)(void *context);
    int (*lock)(void *context);
    int (*unlock)(void *context);
    int (*destroy)(void *context);
} vn135_fifo_sync;
typedef struct { uint8_t bytes[VN135_NONCE_FIFO_RECORD_SIZE]; } vn135_nonce_record72;
typedef struct {
    vn135_fifo ring;
    uint32_t push_word; /* Original +1 word, wrapping u32. Reset/init do not zero it. */
    uint32_t ready;     /* New lifetime guard, not an original field. */
} vn135_nonce_fifo;
/* Initializer allocates 4096 * 72 bytes. Added rollback on malloc failure. */
int vn135_nonce_fifo_init(vn135_nonce_fifo *,const vn135_fifo_memory *,const vn135_fifo_sync *);
/* Full: discard OLDEST, then insert new record. dropped_oldest is optional.
 * All 72 bytes are copied verbatim, including the opaque final four bytes.
 * New status reports diagnostics; original push return was mutex-unlock's return.
 */
int vn135_nonce_fifo_push(vn135_nonce_fifo *,const vn135_nonce_record72 *,const vn135_fifo_sync *,uint32_t *dropped_oldest);
int vn135_nonce_fifo_pop(vn135_nonce_fifo *,vn135_nonce_record72 *,const vn135_fifo_sync *);
int vn135_nonce_fifo_is_empty(vn135_nonce_fifo *,const vn135_fifo_sync *);
int vn135_nonce_fifo_is_full(vn135_nonce_fifo *,const vn135_fifo_sync *);
int vn135_nonce_fifo_reset(vn135_nonce_fifo *,const vn135_fifo_sync *);
int vn135_nonce_fifo_destroy(vn135_nonce_fifo *,const vn135_fifo_memory *,const vn135_fifo_sync *);

/* New explicit bridge, not a recovered vendor constructor or semantic trailer.
 * 17 numeric u32 fields -> 68 LE bytes + FOUR CALLER-SUPPLIED OPAQUE BYTES.
 * Never read 72 bytes through a 68-byte candidate. Do not guess a generation ID.
 * No CRC/nonce/target/ownership/freshness validation. Separate accessible buffers.
 */
int vn135_nonce_record_pack(const vn135_nonce_candidate *,const uint8_t opaque_tail[4],vn135_nonce_record72 *);
int vn135_nonce_record_unpack(const vn135_nonce_record72 *,vn135_nonce_candidate *,uint8_t opaque_tail[4]);
#ifdef __cplusplus
}
#endif
#endif
