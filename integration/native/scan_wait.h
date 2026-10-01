/* GPL-3.0-or-later. Native scanwork pacing; no measured hashes are invented. */
#ifndef DIZZASS_SCAN_WAIT_H
#define DIZZASS_SCAN_WAIT_H
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
struct thr_info;
struct cgpu_info;
struct dizzass_io_lifecycle;
enum dizzass_scan_reason {
    DIZZASS_SCAN_UNUSED, DIZZASS_SCAN_TICK, DIZZASS_SCAN_STOP,
    DIZZASS_SCAN_IO_FAILURE, DIZZASS_SCAN_WAIT_FAILURE
};
struct dizzass_scan_report {
    enum dizzass_scan_reason reason;
    int status;
    uint64_t calls, wait_calls, ticks, stops, failures, wake_requests;
    bool active, waiting, stop_requested;
};
/* Caller-owned, non-copyable storage. Internal fields are not an editing API.
 * One stable native queue owner. Publish this object as thr->cgpu_data, leaving
 * R12's separate cgpu->device_data queue binding intact. Install dizzass_scanwork
 * and dizzass_scan_stop_wake on the caller's private driver table; expose exactly
 * that thread as cgpu->thr[0], threads=1. Init performs NONE of those assignments.
 */
struct dizzass_scan_wait {
    pthread_mutex_t lock;
    pthread_cond_t cond;
    struct thr_info *thr;
    struct dizzass_io_lifecycle *io;
    unsigned interval_ms;
    bool initialized;
    struct dizzass_scan_report report;
};
/* Fresh unused storage only; failure can modify storage but owns no resources.
 * interval 1..1000ms is SOFTWARE pacing, not ASIC timing or a total stop bound.
 * IO/native identity and strict-CRC choice are established by the caller.
 */
int dizzass_scan_wait_init(struct dizzass_scan_wait *, struct thr_info *,
    struct dizzass_io_lifecycle *, unsigned interval_ms);
int dizzass_scan_wait_snapshot(struct dizzass_scan_wait *, struct dizzass_scan_report *);
/* Exclude all new references and JOIN ALL worker/wake/snapshot callers first.
 * EBUSY while active is a guard, not proof that inactive callers have returned.
 * Does not detach/free native objects or stop IO, hardware, queues or pools.
 */
int dizzass_scan_wait_destroy(struct dizzass_scan_wait *);
/* Real device_drv signatures. A monotonic, fixed-deadline condition wait ends
 * one scan pass. Spurious wakes never reset it. Explicit stop is latched before
 * broadcast; repeated wake requests are harmless. No scan-generated wake tokens.
 * Tick/stop return ZERO hashes, error returns -1 with a diagnostic report. RX
 * uses the existing submitter independently; measured hash accounting is NOT
 * implemented here. No full scheduler/update/flush/restart or slot reclamation.
 *
 * Missing/stopped/finished IO is fail-closed at the pre/post-wait snapshots.
 * An IO-only failure is detected by the next heartbeat, not by an automatic
 * watcher. Use R16 for immediate native+IO stop. Native stop cannot revoke a
 * callback that has already passed its checks. Native get_work starvation uses
 * R13, and paused/native semaphore waits use R14; neither is replaced here.
 *
 * Deferred cancellation is excluded through waiting, bookkeeping and report
 * publication; restoration may prevent return. Bound storage outlives it.
 * No asynchronous cancellation, reentry, concurrent init/destroy, arbitrary
 * pointers, caller-held locks or hotplug. Stable scheduler/driver/thr/IO and
 * initialized native semaphores remain prerequisites for native stop.
 */
int64_t dizzass_scanwork(struct thr_info *);
int dizzass_scan_stop_wake(struct cgpu_info *);
#endif
