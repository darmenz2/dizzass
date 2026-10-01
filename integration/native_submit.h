/* Native cgminer submission gate. GPL-3.0-or-later. */
#ifndef DIZZASS_NATIVE_SUBMIT_H
#define DIZZASS_NATIVE_SUBMIT_H
#include "integration/native_jobs.h"

struct thr_info;
struct dizzass_submitter;

enum dizzass_submit_status {
    DIZZASS_SUBMIT_INVALID = -200,
    DIZZASS_SUBMIT_STOPPED = -201,
    DIZZASS_SUBMIT_WRONG_THREAD = -202,
    DIZZASS_SUBMIT_UNSUPPORTED_WORK = -203
};

struct dizzass_submit_result {
    struct dizzass_job_ticket ticket;
    bool native_valid_nonce; /* submit_nonce return: diff1 and not last-nonce duplicate. */
    bool meets_target;       /* Meaningful only when native_valid_nonce is true. */
    /* Neither flag means enqueued, transmitted or accepted by a pool. */
};

/* One gate per cgpu, shared by ALL its chain registries and submission threads.
 * Keep thr/cgpu/driver/pools alive; do not also call submit_nonce outside this
 * gate for that cgpu. No ownership/refcount is taken for these native objects.
 * out must point to NULL. No device registration or hardware/network I/O.
 */
int dizzass_submitter_create(struct thr_info *thr, struct dizzass_submitter **out);

/* Permanent stop. Waits for an admitted core call to return; later calls fail.
 * Does NOT cancel shares already queued by cgminer, stop chips or drain UART.
 * Do not call stop/destroy/run recursively from the driver's hw_error callback.
 */
int dizzass_submitter_stop(struct dizzass_submitter *submitter);
/* Only after all callers have stopped/joined. Repeat destruction is allowed. */
void dizzass_submitter_destroy(struct dizzass_submitter **submitter);

/* Admit a reply under the registry lock and own a native work copy; release
 * that lock BEFORE invoking real submit_nonce. Only fixed-version Stratum
 * work is supported. The source must have the gate's thr_id and valid native
 * pool, job_id, nonce1, ntime and positive finite work/device difficulties.
 *
 * pause/retire reject future admissions, but cannot revoke a copy already
 * admitted. To stop dispatch, first stop the gate from a control thread.
 * A hw_error callback MAY pause/retire a registry: its mutex is not held by
 * the core call. It must not re-enter this gate, which remains locked.
 *
 * Core stale/share/accounting policy is reused unchanged. Status 0 means the
 * core was called, including native nonce rejection. Other statuses (also
 * JOBS/NONCE errors) leave out and native share accounting unchanged. Native
 * allocation IDs can advance on a failed clone. No new dedup or SHA engine.
 * The upstream core's own later queued-copy allocation behavior is unchanged.
 */
int dizzass_submitter_run(struct dizzass_submitter *submitter,
    struct dizzass_jobs *jobs, uint64_t received_epoch,
    const struct dizzass_nonce_reply *reply, struct dizzass_submit_result *out);
/* Deferred-RX admission with the EXACT ticket captured at offer time.
 * Serial/epoch/chain/slot validation, work-state checks and native copying
 * share one registry lock. PENDING and stale/replaced tickets never reach
 * submit_nonce. No output/accounting change on an admission error.
 * Same gate, native stale/duplicate/queue semantics and lifetime rules as run.
 * A pause AFTER admission still cannot revoke that owned copy: stop the gate
 * from the control thread first when dispatch exclusion is required.
 * Caller keeps ticket/reply/output stable and nonoverlapping and excludes
 * deferred cancellation until return. No recursive gate calls from hw_error.
 */
int dizzass_submitter_run_captured(struct dizzass_submitter *,
    struct dizzass_jobs *, const struct dizzass_job_ticket *,
    const struct dizzass_nonce_reply *, struct dizzass_submit_result *out);
#endif
