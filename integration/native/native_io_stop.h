/* GPL-3.0-or-later. Compose existing native and managed software stops. */
#ifndef DIZZASS_NATIVE_IO_STOP_H
#define DIZZASS_NATIVE_IO_STOP_H
#include "integration/native/io_stop_many.h"
struct cgpu_info;
struct dizzass_native_io_stop_report {
    bool native_called;
    int native_status, first_error, cancel_restore_status;
    bool sequence_complete;
    struct dizzass_io_stop_many_report io;
};
/* ONE externally serialized controller, never an RX, queued producer or driver
 * callback. The caller supplies the COMPLETE set of this cgpu's IO lifecycles
 * and shared submitter users, with a stable initialized native scheduler,
 * driver, published threads and semaphores. This function cannot discover
 * missing members or validate a physical cgpu/IO/port association.
 *
 * Validate the whole non-null/distinct list before effects. Request stop on ALL
 * IO members BEFORE cgminer_request_queued_stop can enter driver wake code;
 * then call the existing full IO stop on EVERY returning member. Native wake
 * errors do not skip IO cleanup. First error follows IO request order, native
 * request, then full IO stop order. The same absolute TX/queue deadline is
 * passed to all children; locks, driver wake, submit and RX join have no hard
 * total wall-time bound. A nonreturning native hook prevents full collection,
 * but all IO stop requests have already been attempted; their statuses
 * remain significant if a request failed before closing admission.
 *
 * Return zero/sequence_complete means this SOFTWARE stop sequence completed
 * without errors, NOT that native workers returned or were joined, or that an
 * ASIC is off/drained. Native stop is one-way; already admitted work can finish.
 * A missing driver wake hook cannot interrupt arbitrary scanwork. Do not
 * release cgpu/pools/queues/IO/fd aliases until ALL external callers are joined
 * or excluded. No close/free, restart, slot release, epoch advance or new work.
 *
 * Arguments and report storage stay alive, immutable/nonoverlapping for the
 * call. Deferred cancellation is disabled through report publication; restoring
 * it may prevent return. The report must outlive controller cancellation.
 * No async cancellation, signal context, reentry or concurrent hotplug/teardown.
 * Invalid arguments leave report and devices unchanged. Other errors retain
 * separate per-member results and do not roll back requests; explicit retry
 * is permitted while every required object remains alive.
 */
int dizzass_native_io_stop(struct cgpu_info *,
    struct dizzass_io_lifecycle *const *members, size_t count,
    uint64_t deadline_ms, struct dizzass_native_io_stop_report *out);
#endif
