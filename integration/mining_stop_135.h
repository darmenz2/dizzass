/* Original 663cc: mining stop/reset caller; isolated typed field views. */
#ifndef VN135_MINING_STOP_135_H
#define VN135_MINING_STOP_135_H
#include "integration/monitor_handlers_135.h"
#include "integration/backend_shutdown_135.h"

/* Reuse general.started_at (+28/+2c), active (+24), tuning (+1049),
 * sampled_power (+1070), and handlers.warmup_done_22c. The three additional
 * bytes and handle have no independent duplicate in those existing views.
 * The 104c slot belongs to worker 4cda0, not the voltage/rescue/ten shutdown
 * slots. This is NOT a vendor layout or a native pthread_t. */
struct vn135_mining_stop_state {
    struct vn135_monitor_handlers *handlers;
    uint32_t handle_104c;
    uint8_t byte_104a, byte_fd0, byte_fe5;
};
/* Uses shutdown_ops.step for fe218, b8e54 and 65b3c, argument zero denotes
 * the implicit context (backend for b8e54/65b3c); bodies remain bindings.
 * delay_ms(100) denotes original 10ed2c, NOT the separate 10ef3c routine.
 * cancel and join are required only when general.tuning is nonzero AFTER
 * the lower calls and delay. join receives NULL. self/detach/trylock are unused.
 * log, when provided, receives line 4825: severity 3, status, Mining stopped.
 * Valid stable objects, sequential completing callbacks, 8-byte IEEE binary64
 * started_at. Arbitrary bits in that field are cleared without FP evaluation.
 * No default I/O success, actual pthread operation, lock or timeout is added.
 * Does not return hardware success, set backend state, clear a thread handle,
 * exit the process, or certify stop completion. */
void vn135_backend_stop_mining_135(struct vn135_mining_stop_state *,
    const struct vn135_shutdown_ops *, void *);
#endif
