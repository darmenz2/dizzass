/* GPL-3.0-or-later. Batch software shutdown; no new owner or hardware I/O. */
#ifndef DIZZASS_IO_STOP_MANY_H
#define DIZZASS_IO_STOP_MANY_H
#include "integration/native/io_lifecycle.h"

/* Software API bound, unrelated to the 32 wire work slots or any board model. */
#define DIZZASS_IO_STOP_MANY_MAX 16u
struct dizzass_io_stop_many_entry {
    int request_status, stop_status;
    struct dizzass_io_report io;
};
struct dizzass_io_stop_many_report {
    size_t count, requested, attempted, quiescent;
    int first_error, cancel_restore_status;
    bool all_quiescent;
    struct dizzass_io_stop_many_entry entries[DIZZASS_IO_STOP_MANY_MAX];
};
/* Controller-only, never from RX/native callbacks or managed TX producers.
 * The caller supplies ALL lifecycles using a device-wide submitter. This API
 * cannot discover missing chains or verify distinct physical ports/registries.
 * It first rejects null/duplicate members and invalid counts without effects.
 * All members are requested to stop BEFORE waiting on any member's submitter,
 * RX join or TX accounting. It then calls every member's stop, even after an
 * error, using one unchanged absolute TX deadline. Fanout is sequential, NOT
 * an atomic multi-port cut: already admitted work can finish during fanout.
 *
 * No allocation, start/restart, close/free, epoch change or hardware commands.
 * Errors do not roll back stop requests. Retry the same set after resolving
 * outstanding TX. Every per-member result is retained; first_error follows
 * request order first, then stop order. all_quiescent requires error-free
 * collection and every child's managed SOFTWARE quiescence. It is NOT ASIC
 * off/drain/slot reuse or release permission for outside references/aliases.
 * Deadlines bound child TX waits only; callbacks, locks, submitter stop and
 * join have no hard total time bound. One externally serialized controller.
 *
 * Inputs, out and borrowed children/contexts must remain valid, nonoverlapping
 * and immutable throughout the call; do not concurrently destroy or individually
 * start/stop/join a member. All other callers must be joined before destruction.
 * Deferred cancellation is excluded through report publication; restoring it
 * may prevent return, so caller-owned report storage must survive cancellation.
 * Async cancellation is unsupported. Invalid input leaves out unchanged.
 */
int dizzass_io_stop_many(struct dizzass_io_lifecycle *const *members,
    size_t count, uint64_t tx_deadline_ms, struct dizzass_io_stop_many_report *out);
#endif
