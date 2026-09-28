/* Original pre-exit teardown 5f0fc. The common shutdown field/operation views
 * are reused; this is not its 5fc54 terminal-stopped policy and not vendor ABI. */
#ifndef VN135_EXIT_CLEANUP_135_H
#define VN135_EXIT_CLEANUP_135_H
#include "integration/backend_shutdown_135.h"

/* Build with VN135_EXIT_CLEANUP_135 and VN135_BACKEND_SHUTDOWN_135. Reuses the
 * already compared thread helper and power-stop body, not a second teardown
 * state. Call from the stop policy's before_process_exit binding; the policy
 * must still propagate VN135_STOP_PROCESS_EXIT after this procedure returns.
 *
 * Required: live nonoverlapping views, stable pointer/storage identities,
 * positive counts fit the chain/fan arrays, eventually successful trylock,
 * synchronous serialized callback effects. All reached callbacks except log
 * are mandatory; no default device success is provided. Source thread handles
 * are 32-bit words. scratch->cleanup represents the source's eight stack bytes
 * for its explicit lower cleanup; that callee's memory/lifetime effects remain
 * a binding. No worker join-result storage is used by this function.
 *
 * Stops selected threads in original order with the flag cleared BEFORE self;
 * join re-reads the handle AFTER cancel. Slot 9 (1050) is not touched here.
 * Adds step 287a4; all step identities are data, not host function addresses.
 * The step operation must bind that unrecovered callee explicitly.
 *
 * State 4 is set before teardown, except early exits. No stopped marker is
 * written, no state 6 is synthesized, no exception rollback or lock timeout is
 * added. Errors ignored by the original remain ignored, including PSU-off.
 * Returning is NOT proof that threads died, rails are off or a supervisor will
 * restart anything. This function never exits/restarts a host process itself. */
void vn135_backend_before_exit_135(struct vn135_shutdown_state *,
    const struct vn135_shutdown_ops *, const struct vn135_backend_power_ops *,
    void *opaque, struct vn135_shutdown_scratch *);
#endif
