/* GPL-3.0-or-later. Native queue_full callback; not a registered device driver. */
#ifndef DIZZASS_QUEUE_CALLBACK_H
#define DIZZASS_QUEUE_CALLBACK_H
#include "integration/native/queue_step.h"
struct cgpu_info;
struct dizzass_queue_callback_result {
    int status, cancel_restore_status;
    bool step_called, receipt_valid, queue_full;
    uint64_t deadline_ms;
    struct dizzass_queue_step_receipt step;
};
/* The driver explicitly sets cgpu->device_data to this live, initialized type
 * and drv->queue_full to dizzass_queue_full. No pointer discovery or arbitrary
 * device_data validation is possible. Do not overwrite another driver's data.
 * One serialized callback owner; configuration is immutable while in use.
 * Read last only on that owner or after synchronization/join, not concurrently.
 */
struct dizzass_queue_callback {
    struct thr_info *thr;
    struct dizzass_io_lifecycle *io;
    uint64_t timeout_ms;
    unsigned max_no_progress;
    struct dizzass_queue_callback_result last;
};
/* Initializes caller storage only: no allocation, device_data/driver assignment,
 * thread, device registration, queue creation, hardware access or RX startup.
 * Invalid arguments leave storage unchanged. Use a private driver object with
 * appropriate min_diff/max_diff and already established native/IO identity.
 */
int dizzass_queue_callback_init(struct dizzass_queue_callback *, struct thr_info *,
    struct dizzass_io_lifecycle *, uint64_t timeout_ms, unsigned max_no_progress);
/* Exact native device_drv.queue_full signature. True ends THIS fill_queue pass
 * on any error or a conservative step result. False ONLY follows a published
 * successful step which permits continuation. It is not a hardware-full flag.
 * A fresh overflow-checked absolute monotonic deadline is computed per callback,
 * not per complete fill pass; no total scheduler/shutdown deadline is promised.
 * Inspect last.receipt_valid before reading last.step; nonzero errors do not
 * reuse the preceding receipt. Cancellation is disabled through publication;
 * restoration may prevent return. Binding/report memory outlives cancellation.
 *
 * get_work/hash_pop remain the real upstream functions. fill_queue may call
 * blocking get_work BEFORE this callback when unqueued_work is NULL. A lifecycle
 * stop cannot wake that upstream wait through this callback. Ending one fill
 * pass also does not provide paced scanwork: the integrating driver still needs
 * its scheduler/wait/shutdown path. No automatic retry, slot retirement, drain,
 * epoch change or network sender. Capacity remains advisory (one work owner).
 * Native completion and managed quiescence do not erase caller references:
 * join/exclude ALL owners before detaching/freeing binding, cgpu, pools or IO.
 * Async cancellation, callback reentry and concurrent detach are unsupported.
 */
bool dizzass_queue_full(struct cgpu_info *);
#endif
