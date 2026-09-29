/* GPL-3.0-or-later. Opt-in Linux RX ownership, not a registered ASIC driver. */
#ifndef DIZZASS_RX_OWNER_H
#define DIZZASS_RX_OWNER_H
#include "integration/native/early_rx.h"
#include "xminer/recovery/work_rx.h"
#include <stdbool.h>

struct dizzass_rx_owner;
enum dizzass_rx_event_kind {
    DIZZASS_RX_QUEUED = 1, DIZZASS_RX_REJECTED,
    DIZZASS_RX_DISPATCHED, DIZZASS_RX_REGISTER, DIZZASS_RX_INTEGRITY_REJECTED
};
struct dizzass_rx_event {
    enum dizzass_rx_event_kind kind;
    uint64_t epoch;
    int status;
    struct dizzass_nonce_reply reply;
    vn135_work_rx_message message; /* REGISTER/FILTERED or untrusted CRC diagnostic. */
    struct dizzass_early_rx_submission submission;
    bool integrity_verified; /* True only after the strict CRC gate, NOT an ACK. */
};
struct dizzass_rx_owner_config {
    int fd; /* Borrow readable O_NONBLOCK raw TTY, VMIN=1, VTIME=0. */
    uint32_t chain_id, board_selector, chip_selector, special_mode;
    uint64_t received_epoch; /* Established at a clean EXTERNAL session boundary. */
    size_t inbox_capacity;
    unsigned poll_ms; /* 1..1000, host scheduling only, NOT a hardware timeout. */
    struct dizzass_jobs *jobs;
    struct dizzass_submitter *submitter;
    void *context;
    /* Worker-thread callback; plain-value event valid only during this call.
     * Copy it to retain it. Return 0, or a nonzero reason to stop. Bounded and
     * nonreentrant. May notify/request_stop, NOT start/join/destroy this owner
     * or change cancellation state, fd/config, borrowed objects or inbox.
     * REGISTER must be handled explicitly, not mistaken for an ASIC ACK.
     */
    int (*event)(void *, const struct dizzass_rx_event *);
};
enum dizzass_rx_exit {
    DIZZASS_RX_STOP_REQUEST = 0, DIZZASS_RX_IO_ERROR, DIZZASS_RX_PARSE_ERROR,
    DIZZASS_RX_INBOX_ERROR, DIZZASS_RX_CALLBACK_ERROR, DIZZASS_RX_INTERNAL_ERROR
};
struct dizzass_rx_owner_report {
    enum dizzass_rx_exit reason;
    int detail; /* errno or exact parser/inbox/callback error, depending on reason */
    uint64_t bytes_read, nonce_frames, register_frames, noise_bytes;
    uint64_t offered, rejected, dispatched, copy_retries, callback_calls;
    uint64_t poll_calls, read_calls, wake_reads;
    size_t pending_replies, partial_frame_bytes, unprocessed_batch_bytes;
    uint64_t crc_checked, crc_rejected; /* Complete framed payloads, not noise. */
    bool crc5_required; /* Distinguishes strict owner from legacy unchecked path. */
};
/* All lifecycle calls are serialized by ONE controller; no concurrent start,
 * join or destroy. Only notify/request_stop/finished may run concurrently with
 * the worker or controller (never destroy). Objects, fd identity/flags/termios
 * and aliases must remain stable until join. ALL RX must use this one owner.
 * Borrowed jobs/submitter/pool/context outlive join; TX ownership is separate.
 * No device open/dup/close, baud selection, flushing, epoch advance or ACK.
 * Unknown selectors rejected; accepted selectors are raw parser selectors,
 * not proof of a T21/chip identity. Original parser does not validate CRC.
 */
int dizzass_rx_owner_create(const struct dizzass_rx_owner_config *,
    struct dizzass_rx_owner **out);
/* Explicit strict mode on the SAME owner. Existing BM1368 CRC5 contract only:
 * chip selector4, variant2, nine-byte payload, special_mode0. Unsupported
 * profiles fail before fd checks/allocation; no fallback to unchecked mode.
 * Bad CRC consumes the framed payload and emits INTEGRITY_REJECTED with raw
 * diagnostic message, without nonce decode, inbox offer or submit. The callback
 * may request stop; otherwise the next frame is processed. Not byte-loss resync,
 * authentication, chip detection, freshness or hardware-tested protocol proof.
 * Legacy create above retains unchecked behavior for other profiles/old tests.
 */
int dizzass_rx_owner_create_crc5(const struct dizzass_rx_owner_config *,
    struct dizzass_rx_owner **out);
int dizzass_rx_owner_start(struct dizzass_rx_owner *);
/* notify after TX finish/registry progress: replay pending replies even with
 * no new UART data. Periodic poll also retries. A coalesced wake is not a receipt.
 */
int dizzass_rx_owner_notify(struct dizzass_rx_owner *);
/* Cooperative request; does NOT wait or abort an admitted submit/callback.
 * A wake error is returned but the atomic stop request remains set.
 */
int dizzass_rx_owner_request_stop(struct dizzass_rx_owner *);
bool dizzass_rx_owner_finished(const struct dizzass_rx_owner *);
/* Blocking join, no hard real-time bound: native locks/callbacks may block.
 * Disables controller cancellation until join bookkeeping/output are complete.
 * finished alone is NOT join. Report only read after successful join; repeats
 * return the same report. Success means RX ended, NOT TX quiescence/power off,
 * hardware drain, revocation of already queued shares or safe slot reuse.
 */
int dizzass_rx_owner_join(struct dizzass_rx_owner *, struct dizzass_rx_owner_report *);
/* Exclude all references first; EBUSY before join of any started thread.
 * Unstarted owner can be destroyed. Frees queued values/partial bytes without
 * further dispatch; report preserves their counts. Never closes borrowed fd.
 * No restart: a new owner requires a separately established clean session.
 */
int dizzass_rx_owner_destroy(struct dizzass_rx_owner **);
#endif
