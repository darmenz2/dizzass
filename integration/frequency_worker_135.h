#ifndef VN135_FREQUENCY_WORKER_135_H
#define VN135_FREQUENCY_WORKER_135_H
#include "integration/frequency_fall_135.h"
#include "integration/monitor_handlers_135.h"

/* Extra view of model+88. These are raw argument words, not guessed units. */
struct vn135_frequency_worker_control { uint32_t word_10, word_20; };
struct vn135_frequency_worker_view {
    struct vn135_frequency_worker_control *control;
    struct vn135_monitor_handlers *handlers;
};
struct vn135_frequency_worker_ops {
    /* Normalized scalar boundaries: cancel-type(1,0), name(15,0), delay(100,0),
     * event(2010,0), power-stop(0,0), thread-exit(0,0). NAME identifies the
     * verified fall_freq@btm string. No real OS/hardware defaults are supplied. */
    int32_t (*call)(void *,uint32_t entry,uint32_t a,uint32_t b);
    /* 57a10: chain in r0, word_20 in r1, word_10 in r2, frequency in d0. */
    int32_t (*set_frequency)(void *,struct vn135_general_chain *,
                            uint32_t word_20,uint32_t word_10,double frequency);
    /* 56d18: explicit binding; may call existing vn135_chain_stop_135. */
    int32_t (*stop_chain)(void *,struct vn135_route_chain *,const char *reason);
    /* 5a55cc: NULL attributes, entry 72ba4, captured backend argument.
     * The output is write-only scratch and not consumed by this worker. */
    int32_t (*create_shutdown)(void *,uint32_t *handle,uint32_t entry,
                              struct vn135_frequency_fall_state *backend);
    void (*log)(void *,uint32_t line,uint32_t chain_plus_one,int32_t frequency);
    const struct vn135_monitor_handler_ops *decisions;
};
enum vn135_frequency_worker_flow { VN135_FREQUENCY_THREAD_EXIT = 1 };
/* Captures argument pointers, control pointer, target and initial frequency
 * before the first callback. handlers->general and argument->backend->general
 * must identify the SAME logical backend. Valid, stable objects/arrays and
 * terminating serialized callbacks required. All reached callbacks except log
 * are mandatory. No vendor ABI, real thread, PLL, timeout or production binding.
 * The return is a terminal-flow marker, NOT the original pthread result or
 * hardware success. A live adapter must not continue the worker after it.
 * The parent still frees arguments on partial-create failure without joining;
 * this function does not repair that lifetime problem. */
enum vn135_frequency_worker_flow vn135_frequency_fall_worker_135(
    const struct vn135_frequency_fall_argument *,
    const struct vn135_frequency_worker_view *,
    const struct vn135_frequency_worker_ops *,void *);
#endif
