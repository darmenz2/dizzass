/* GPL-3.0-or-later. Software lifecycle composition; NOT a hardware driver. */
#ifndef DIZZASS_IO_LIFECYCLE_H
#define DIZZASS_IO_LIFECYCLE_H
#include "integration/native/rx_owner.h"
#include "integration/native/native_job_channel_tx.h"
#include "integration/native/protocol_channel_tx.h"

struct dizzass_io_lifecycle;
struct dizzass_io_work_receipt {
    struct dizzass_native_job_tx_receipt send;
    int notify_status;
};
struct dizzass_io_command_receipt {
    struct dizzass_protocol_tx_receipt send;
    int notify_status;
};
struct dizzass_io_report {
    bool started, stop_requested, quiescent, rx_finished, rx_joined, jobs_paused;
    size_t active_tx; /* Whole wrapper operations, including finish/notify. */
    int rx_wake_status, initial_tx_stop_status, submit_stop_status;
    int rx_join_status, tx_wait_status, final_tx_stop_status, pause_status;
    int cancel_restore_status;
    struct dizzass_rx_owner_report rx;
};
/* Borrow ONE chain's existing jobs and TX gate, and a device-wide submitter.
 * Creates/owns only a R-04 RX owner and wrapper bookkeeping. cfg jobs, fd,
 * chain/epoch and channel MUST denote the same externally established session.
 * Existing APIs cannot verify that association. Submitter stop affects ALL
 * chains sharing it: coordinate that device-wide policy outside this object.
 * No additional work/pool/registry, device open/config/close or epoch reset.
 * Objects/pools/callback context/fd aliases outlive stop and all joined users.
 * All command/work TX for this channel MUST use these wrappers; no bypass.
 */
int dizzass_io_create(const struct dizzass_rx_owner_config *,
    struct dizzass_uart_channel *, struct dizzass_io_lifecycle **out);
/* Same lifecycle/ownership, but RX requires the existing chip4/variant2 CRC5
 * contract via rx_owner_create_crc5. Unsupported profiles fail, not downgrade.
 * Report.rx exposes strict mode and rejected-frame counters after stop/join.
 * This does not verify physical identity, configure hardware or add an ACK.
 */
int dizzass_io_create_crc5(const struct dizzass_rx_owner_config *,
    struct dizzass_uart_channel *, struct dizzass_io_lifecycle **out);
/* One serialized controller calls start/stop/destroy. No restart after start
 * failure, requested stop or RX exit. Failed start must be stopped/destroyed.
 */
int dizzass_io_start(struct dizzass_io_lifecycle *);
/* Concurrent producers. Return 0 means A-15/A-16 invoked, NOT transport success.
 * Inspect nested receipt. Admission errors leave out unchanged. Source strings
 * stay immutable/alive throughout the call. Deferred cancellation is disabled
 * through native prepare/send/finish, progress notification, output and active
 * count cleanup; restoration may prevent return delivery. Caller owns cleanup
 * of its source/receipt. Async cancellation and reentry are unsupported.
 */
int dizzass_io_send_work(struct dizzass_io_lifecycle *, uint32_t platform,
    uint32_t algorithm, uint32_t slot, uint32_t variant, const struct work *,
    uint64_t deadline_ms, unsigned budget, struct dizzass_io_work_receipt *out);
int dizzass_io_send_command(struct dizzass_io_lifecycle *,
    enum dizzass_bm1368_command, uint32_t broadcast, uint32_t address,
    uint32_t reg, uint32_t value, uint64_t deadline_ms, unsigned budget,
    struct dizzass_io_command_receipt *out);
/* May be called by producers/callback: closes NEW wrapper admission and wakes
 * RX. Does not wait for admitted TX/submit, stop the shared submitter, close
 * the UART gate or prove physical stop. Wake error leaves the latch set.
 */
int dizzass_io_request_stop(struct dizzass_io_lifecycle *);
/* Controller-only, NEVER from callback/producer. Closes UART admission, stops
 * shared submitter, joins RX, waits for all admitted wrapper operations, stops
 * UART again, then pauses jobs. Timeout never pauses/reuses live TX slots.
 * tx_deadline_ms bounds TX wait ONLY; RX join/submitter/native locks/callbacks
 * may block: this is NOT a total wall-time or hardware shutdown deadline.
 * Retry with a later deadline after timeout. Full report stored before restoring
 * cancellation; snapshot/repeated stop can recover it if caller was cancelled.
 * quiescent is SOFTWARE I/O only for these managed paths, not absence of outside
 * aliases/references, physical ACK/drain/off, fresh epoch or reusable slots.
 */
int dizzass_io_stop(struct dizzass_io_lifecycle *, uint64_t tx_deadline_ms,
    struct dizzass_io_report *out);
/* Snapshot also samples RX completion so the controller can collect an I/O
 * failure without issuing another TX. It does not perform shutdown itself. */
int dizzass_io_snapshot(struct dizzass_io_lifecycle *, struct dizzass_io_report *out);
/* First prevent new references and join ALL callers/notifiers. Only after
 * successful software quiescence, or unused create. Destroys owned RX/eventfd
 * and bookkeeping ONLY. Borrowed fd/jobs/channel/submitter remain caller-owned.
 * No reentrant callback except request_stop/snapshot, no destruction races.
 */
int dizzass_io_destroy(struct dizzass_io_lifecycle **);
#endif
