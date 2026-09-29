/* Sent-job bookkeeping around native cgminer work. GPL-3.0-or-later.
 * New integration policy; not recovered VNish ABI and not a hardware sender.
 */
#ifndef DIZZASS_NATIVE_JOBS_H
#define DIZZASS_NATIVE_JOBS_H
#include "integration/native_nonce.h"

#define DIZZASS_JOB_SLOTS 32u
struct dizzass_jobs;

enum dizzass_jobs_status {
    DIZZASS_JOBS_OK = 0,
    DIZZASS_JOBS_INVALID = -100,
    DIZZASS_JOBS_NOMEM = -101,
    DIZZASS_JOBS_LOCK_ERROR = -102,
    DIZZASS_JOBS_WRONG_CHAIN = -103,
    DIZZASS_JOBS_OLD_EPOCH = -104,
    DIZZASS_JOBS_STALE_TICKET = -105,
    DIZZASS_JOBS_BUSY = -106,
    DIZZASS_JOBS_EMPTY = -107,
    DIZZASS_JOBS_PENDING = -108,
    DIZZASS_JOBS_QUARANTINED = -109,
    DIZZASS_JOBS_PAUSED = -110,
    DIZZASS_JOBS_EXHAUSTED = -111
};

enum dizzass_tx_result {
    DIZZASS_TX_WRITTEN = 0, /* Complete transport write, NOT a chip ACK. */
    DIZZASS_TX_NOT_SENT = 1, /* Caller proves NO bytes could reach the device. */
    DIZZASS_TX_UNCERTAIN = 2 /* Partial write, timeout, cancellation in flight. */
};

/* Local token. Neither epoch nor serial exists in the five-bit wire slot.
 * Capture epoch at the RX session boundary, NOT by reading the current epoch
 * after receiving an old reply. Tokens are scoped to one registry lifetime.
 */
struct dizzass_job_ticket {
    uint64_t epoch;
    uint64_t serial;
    uint32_t chain_id;
    uint32_t slot;
};

struct dizzass_job_result {
    struct dizzass_nonce_check check; /* Owned native work, clear explicitly. */
    struct dizzass_job_ticket ticket;
};

/* Create only at a known clean TX/RX boundary. initial_epoch is nonzero and
 * must not be reused for this channel across registry recreation. No I/O here.
 * out must point to NULL. Destroy requires all users to have stopped/joined;
 * repeated destruction is allowed. No concurrent destruction is supported.
 */
int dizzass_jobs_create(uint32_t chain_id, uint64_t initial_epoch,
    struct dizzass_jobs **out);
void dizzass_jobs_destroy(struct dizzass_jobs **jobs);

/* Reserve an UNUSED slot and clone the exact immutable native work encoded
 * for this transmission. Caller retains source until this call returns.
 * The core owns pool lifetime; copying work does NOT reference-count pool.
 * The token must be zero-initialized. Errors leave it and slot state unchanged.
 * Allocation uses native copy_work_noffset/free_work. Core OOM can be fatal;
 * detected partial strdup failures are rolled back. No second work type.
 */
int dizzass_jobs_prepare(struct dizzass_jobs *jobs, uint64_t expected_epoch,
    uint32_t slot, uint32_t variant, uint32_t version_base_word,
    const struct work *source, struct dizzass_job_ticket *out);

/* Complete exactly one preparation using the actual sender's outcome.
 * WRITTEN makes the entry matchable; NOT_SENT frees it for another preparation;
 * UNCERTAIN frees work but quarantines the slot until a proven drained epoch.
 * Duplicate/old completion tokens cannot publish or remove another job.
 */
int dizzass_jobs_finish(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket, enum dizzass_tx_result outcome);

/* Retiring a sent job NEVER makes its wire slot immediately reusable. */
int dizzass_jobs_retire(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket);

/* Stop prepares/lookups and quarantine all used slots, including in-flight
 * preparations. Old completions subsequently fail. Does not stop hardware.
 */
int dizzass_jobs_pause(struct dizzass_jobs *jobs, uint64_t expected_epoch);

/* Caller must FIRST stop the sender/receiver and prove that old chip work,
 * controller queues, UART data and partial RX frames cannot reappear. Flushing
 * a software buffer or waiting an invented timeout is NOT sufficient.
 * This API records that external boundary; it neither performs nor verifies it.
 * Requires a paused registry; epochs strictly increase without wrapping.
 */
int dizzass_jobs_begin_drained_epoch(struct dizzass_jobs *jobs,
    uint64_t expected_epoch, uint64_t next_epoch);

/* Resolve a reply only within its externally captured RX epoch, then run the
 * existing native_nonce adapter while the stored work is protected by a mutex.
 * No reuse of a written slot in an epoch: late old replies cannot be silently
 * attached to a replacement in that same slot. The result is an owned snapshot,
 * not proof that its job remains active after this call. Native stale/submit
 * policy, pool lifetime and submission synchronization are NOT implemented here.
 * out must be zero-initialized/cleared. No deduplication, stats, submit or I/O.
 * Native nonce errors (-1..-6) may be returned; output is unchanged on error.
 */
int dizzass_jobs_check(struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_job_result *out);
void dizzass_job_result_clear(struct dizzass_job_result *result);

/* Snapshot of local liveness ONLY; not an atomic check-and-submit operation. */
int dizzass_jobs_ticket_live(struct dizzass_jobs *jobs,
    const struct dizzass_job_ticket *ticket);

/* Proposed additive early-RX API. Capture the EXACT current ticket while
 * PREPARED or WRITTEN under the registry lock. Validate epoch/chain/format and
 * version without allocating or publishing work. out must be all zero; errors
 * leave it unchanged. received_epoch is captured by the RX session, never read
 * from the latest registry state. A capture is NOT hardware freshness proof.
 * Input objects must be stable/nonoverlapping for the call. Registry lifetime
 * and cancellation exclusion remain the caller's responsibility.
 */
int dizzass_jobs_capture_reply(struct dizzass_jobs *, uint64_t received_epoch,
    const struct dizzass_nonce_reply *, struct dizzass_job_ticket *out);

/* Validate the captured serial/epoch AND check the reply in ONE critical
 * section. PENDING remains pending; a replacement in the same slot cannot be
 * mistaken for the captured job. Success owns native work in out, released by
 * dizzass_job_result_clear. Same output/ownership rules as jobs_check. This is
 * not atomic check-and-submit, duplicate suppression, or pool acceptance.
 */
int dizzass_jobs_check_captured(struct dizzass_jobs *,
    const struct dizzass_job_ticket *, const struct dizzass_nonce_reply *,
    struct dizzass_job_result *out);
/* Read-only availability in one existing registry lifetime/epoch. A set bit
 * denotes SLOT_EMPTY only, not a completed core work or a retired wire job.
 * Does not reserve a slot. All work admissions must have ONE serialized owner;
 * prepare still checks the actual state. PAUSED/old epoch/serial exhaustion
 * return their existing status and leave out unchanged. Capacity zero is OK.
 * Output/lifetime/cancellation rules are those of the other registry queries.
 */
struct dizzass_job_capacity {
    uint64_t epoch;
    uint32_t chain_id;
    uint32_t unused_mask;
};
int dizzass_jobs_capacity(struct dizzass_jobs *, uint64_t expected_epoch,
    struct dizzass_job_capacity *out);

#endif
