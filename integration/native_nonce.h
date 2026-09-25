/* Native cgminer boundary for decoded ASIC replies. GPL-3.0-or-later.
 * New integration API, NOT the vendor work/queue ABI or a registered T21 driver.
 */
#ifndef DIZZASS_NATIVE_NONCE_H
#define DIZZASS_NATIVE_NONCE_H
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

struct work;

enum dizzass_nonce_status {
    DIZZASS_NONCE_OK = 0, /* calculation completed, NOT pool acceptance */
    DIZZASS_NONCE_INVALID = -1,
    DIZZASS_NONCE_WRONG_CHAIN = -2,
    DIZZASS_NONCE_WRONG_SLOT = -3,
    DIZZASS_NONCE_WRONG_FORMAT = -4,
    DIZZASS_NONCE_WRONG_VERSION = -5,
    DIZZASS_NONCE_PARTIAL_COPY = -6
};

struct dizzass_nonce_reply {
    uint32_t chain_id;
    uint32_t slot;             /* Five-bit wire index, NOT a generation. */
    uint32_t variant;          /* 0/1/2 are wire formats, not model names. */
    uint32_t nonce_word;       /* Value expected by native test_nonce(). */
    uint32_t version_bits;     /* Vendor bit permutation, not a pool mask. */
};

/* The caller has already resolved and retained the exact immutable native work.
 * A matching slot alone does NOT establish this relationship. Pool/template
 * lifetimes and synchronization remain the caller's responsibility.
 * version_base_word is the actual OR-base used by the hardware job encoder,
 * in the recovered vendor word convention (LE read of native work->data[0..3]).
 * Do not guess it from an RX slot or an unrelated currently active pool job.
 */
struct dizzass_nonce_match {
    const struct work *work;
    uint32_t chain_id;
    uint32_t slot;
    uint32_t variant;
    uint32_t version_base_word;
};

struct dizzass_nonce_check {
    struct work *work;         /* Owned native copy; release with clear(). */
    bool passes_diff1;
    bool meets_target;
    /* Neither flag establishes freshness, duplicate status or pool acceptance. */
};

/* Decode ONLY an already framed, ordinary NONCE payload (7/8/9 bytes).
 * Not a byte-stream synchronizer; no preamble, CRC check, model dispatch or I/O.
 * The caller must exclude the special register-only mode before this call.
 * On error the output is unchanged. Inputs and output must not overlap.
 */
int dizzass_nonce_decode_payload(uint32_t chip_selector, uint32_t variant,
    uint32_t chain_id, const uint8_t *payload, size_t size,
    struct dizzass_nonce_reply *out);

/* Check a reply against the caller's matched work; never alter its header,
 * version, strings or hash. This fixed-work boundary does NOT reconstruct a
 * different version. A version mismatch is rejected before allocating anything.
 * Uses REAL copy_work_noffset(), test_nonce(), fulltest(), free_work().
 * Initialize out to zero. A non-empty result is rejected, not overwritten.
 * Native allocation helpers may terminate on OOM; this is not a recoverable
 * allocator wrapper. Detected partial strdup failures are cleaned up.
 * No submission, device accounting, last_nonce mutation or freshness policy.
 */
int dizzass_nonce_check_matched(const struct dizzass_nonce_match *match,
    const struct dizzass_nonce_reply *reply, struct dizzass_nonce_check *out);
void dizzass_nonce_check_clear(struct dizzass_nonce_check *result);
#endif
