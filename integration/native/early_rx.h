/* GPL-3.0-or-later. Bounded decoded-reply inbox; new opt-in native policy. */
#ifndef DIZZASS_EARLY_RX_H
#define DIZZASS_EARLY_RX_H
#include "integration/native_jobs.h"
#include "integration/native_submit.h"
#define DIZZASS_EARLY_RX_MAX_CAPACITY 1024u /* host memory bound, NOT work slots */
enum dizzass_early_rx_status {
    DIZZASS_EARLY_RX_OK = 0, DIZZASS_EARLY_RX_EMPTY = 1,
    DIZZASS_EARLY_RX_WAITING = 2, DIZZASS_EARLY_RX_INVALID = -1100,
    DIZZASS_EARLY_RX_OVERFLOW = -1101, DIZZASS_EARLY_RX_STOPPED = -1102,
    DIZZASS_EARLY_RX_NOMEM = -1103
};
struct dizzass_early_rx;
struct dizzass_early_rx_event {
    struct dizzass_nonce_reply reply;
    struct dizzass_job_ticket captured;
    int job_status; /* zero: native check completed, NOT pool acceptance */
    struct dizzass_job_result result; /* owned native copy on job_status==0 */
};
/* SINGLE externally serialized RX owner. No new thread, mutex, work type,
 * transport or model inference. Submission uses the explicit entry below. TX may use the synchronized jobs
 * registry concurrently. All queue users must finish before destroy; borrowed
 * jobs must outlive the inbox. Never race any inbox method with another.
 * Caller must disable deferred cancellation across take AND result disposal
 * (or provide equivalent cleanup); async cancellation is unsupported.
 * Each inbox binds one caller-confirmed chain/session epoch, not a current-
 * epoch getter. Capacity is explicit 1..1024, unrelated to 32 work slots.
 */
int dizzass_early_rx_create(struct dizzass_jobs *, uint32_t chain_id,
    uint64_t received_epoch, size_t capacity, struct dizzass_early_rx **out);
/* Copy reply+captured ticket; no borrowed packet/work buffers. Wrong/old
 * replies are rejected before capacity admission. No silent eviction: full
 * admission latches OVERFLOW and prevents all later offer/take/dispatch results.
 */
int dizzass_early_rx_offer(struct dizzass_early_rx *, uint64_t received_epoch,
    const struct dizzass_nonce_reply *);
/* Scan at most the bounded queue size, skip PENDING without removing it.
 * Return OK and one settled event (possibly an explicit job rejection).
 * Old serial/epoch and quarantined jobs cannot produce successful work.
 * Partial-copy failure keeps the entry and returns that error for retry.
 * Non-OK return leaves out untouched; out must be zero/cleared. No auto-submit.
 */
int dizzass_early_rx_take(struct dizzass_early_rx *, struct dizzass_early_rx_event *out);
void dizzass_early_rx_event_clear(struct dizzass_early_rx_event *);
size_t dizzass_early_rx_size(const struct dizzass_early_rx *);
/* Permanent admission stop. No restart, epoch advance, physical stop/drain or
 * implicit hardware work retirement. Pending values persist until destroy.
 */
int dizzass_early_rx_stop(struct dizzass_early_rx *);
void dizzass_early_rx_destroy(struct dizzass_early_rx **);
/* Plain-value receipt: no owned work or borrowed RX buffer. */
struct dizzass_early_rx_submission {
    struct dizzass_nonce_reply reply;
    struct dizzass_job_ticket captured;
    int job_status; /* zero iff the existing native submit_nonce was called */
    bool native_called;
    struct dizzass_submit_result result; /* validity != queue/pool acceptance */
};
/* Single-owner alternative to take: scan up to queue size and dispatch ONE
 * settled reply directly through captured-ticket native submission admission.
 * Does not pre-hash with take, rebind by slot, or use a second queue/work type.
 * PENDING is retained/skipped; terminal JOBS/NONCE rejections are returned as
 * events without calling the core. Successful core calls (including rejection
 * or no queue insertion) consume the entry ONCE; never retry by validity flags.
 * Copy failure and other admission errors leave the entry/output untouched.
 * STOPPED/WRONG_THREAD/UNSUPPORTED_WORK are explicit errors, not busy-retry advice.
 * Nonzero return leaves out unchanged. Same owner/lifetime/stop rules as take.
 * Caller MUST exclude deferred cancellation through dispatch and handling its
 * receipt; no asynchronous cancellation or reentrant inbox use is supported.
 * Scan count is bounded, not elapsed time: the gate/native core may block.
 * This is a software RX dispatch step, not a receiver thread or device driver.
 */
int dizzass_early_rx_dispatch(struct dizzass_early_rx *, struct dizzass_submitter *,
    struct dizzass_early_rx_submission *out);
#endif
