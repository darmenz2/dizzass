/* GPL-3.0-or-later. Private queue/lifecycle ownership boundary. */
#ifndef DIZZASS_IO_QUEUE_SCOPE_H
#define DIZZASS_IO_QUEUE_SCOPE_H
struct dizzass_io_lifecycle;
/* Internal paired scope, used by queued_work_tx with cancellation DISABLED.
 * Enter before core dequeue; leave exactly once after native completion AND
 * receipt publication, including NULL/stale/rejected work. Enter failure has
 * no accounting effect. No queue/transport locks are held across the scope.
 * This counts ownership only, not native work, submitted shares or wire slots.
 * A valid live lifecycle and external reference exclusion remain mandatory.
 * Not a public producer API: no cross-thread release, reentry or async cancel.
 */
int dizzass_io_queue_enter(struct dizzass_io_lifecycle *);
void dizzass_io_queue_leave(struct dizzass_io_lifecycle *);
#endif
