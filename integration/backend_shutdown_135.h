/* Original common shutdown 5fc54 and detached failure worker 72ba4.
 * Typed offline state; no physical thread or hardware implementation. */
#ifndef VN135_BACKEND_SHUTDOWN_135_H
#define VN135_BACKEND_SHUTDOWN_135_H
#include "integration/gpio_power_135.h"
struct vn135_shutdown_thread { uint32_t handle; uint8_t running; };
/* Slot order preserves source fields:
 * 1044,1014,100c,0ffc,101c,1004,102c,0ff4,103c,1050.
 * The last slot is joined only; the others self-detach or cancel then join. */
struct vn135_shutdown_state {
    uint32_t state,mode,model_chip_selector;
    uint8_t persistent_marker,byte_fe6,board_byte_4f;
    uint32_t word_fe8,word_fec;
    struct vn135_shutdown_thread threads[10];
    struct vn135_backend_power_state power;
    int32_t fan_count;
    int32_t *fan_readings;
};
struct vn135_shutdown_scratch { uint32_t cleanup[2],join_result; };
struct vn135_shutdown_ops {
    int32_t (*trylock)(void *);
    int32_t (*unlock)(void *);
    int32_t (*delay_ms)(void *,uint32_t);
    uint32_t (*self)(void *);
    int32_t (*detach)(void *,uint32_t);
    int32_t (*cancel)(void *,uint32_t);
    int32_t (*join)(void *,uint32_t,uint32_t *result);
    int32_t (*set_thread_name)(void *,const char *);
    /* Unrecovered callees by source identity, NOT executable addresses.
     * 19c denotes the indirect backend callback. Its return is an opaque word.
     * Meaningful args only. 58d08/5a9fc/5ac80 receive chain index.
     * Never supply a production callback that simply pretends hardware success. */
    uint32_t (*step)(void *,uint32_t source,uint32_t argument);
    int32_t (*cleanup)(void *,uint32_t scratch[2],uint32_t value);
    int32_t (*mark_stopped)(void *,const char *path);
    void (*log)(void *,uint32_t line);
};
/* Preconditions: valid nonaliasing objects and callbacks; described arrays
 * fit every count; callbacks terminate and lock acquisition eventually succeeds.
 * No invented lock timeout, rollback, cache flush or stronger success result.
 * Synchronous callbacks can update thread handles at self/cancel boundaries.
 * Cancellation/join are requests, not proof that a real worker has terminated.
 * Common shutdown ignores power_stop failure and still stores source state 6.
 * Inspected callers do not use the common procedure's return register; this
 * projection is void. No synthetic success or electrical-off status is added. */
void vn135_backend_shutdown_135(struct vn135_shutdown_state *,
    const struct vn135_shutdown_ops *,const struct vn135_backend_power_ops *,
    void *,struct vn135_shutdown_scratch *);
int vn135_backend_shutdown_worker_135(struct vn135_shutdown_state *,
    const struct vn135_shutdown_ops *,const struct vn135_backend_power_ops *,
    void *,struct vn135_shutdown_scratch *);
#endif
