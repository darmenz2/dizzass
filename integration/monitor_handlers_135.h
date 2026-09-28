#ifndef VN135_MONITOR_HANDLERS_135_H
#define VN135_MONITOR_HANDLERS_135_H
#include "integration/general_monitor_135.h"
#include "integration/gpio_power_135.h"
#include <stddef.h>

/* Board config+38+4f is the existing general.model->query_fault_87 byte.
 * Additional field views only. general and power refer to the same logical
 * backend as the preceding ports; these structures are not the vendor ABI. */
struct vn135_handler_profile { const char *key, *label; };
struct vn135_handler_profiles {
    struct vn135_handler_profile *entries;
    int32_t count;
};
struct vn135_monitor_handlers {
    struct vn135_general_monitor *general;
    struct vn135_backend_power_state *power;
    struct vn135_handler_profiles *profiles;
    const char *current_preset_fc8, *minimum_preset_b8;
    int32_t minimum_chains_f8;
    uint8_t partial_chains_105, warmup_e4, warmup_done_22c;
    uint8_t lower_preset_95, minimum_enabled_b0;
};
enum vn135_handler_call {
    VN135_H_CHAIN_COUNT=0xfe668, VN135_H_EVENT=0x49c98,
    VN135_H_STOP=0x5e92c, VN135_H_PLATFORM=0xfdfbc,
    VN135_H_TRYLOCK=0x5a6684, VN135_H_UNLOCK=0x5a66c4,
    VN135_H_DELAY=0x10ef3c, VN135_H_CLEANUP_PUSH=0x5a48a0,
    VN135_H_CLEANUP_POP=0x5a48a8
};
struct vn135_monitor_handler_ops {
    /* Scalar arguments are normalized identities, not host/vendor pointers.
     * TRYLOCK/UNLOCK: a=backend offset 1074, b=0.
     * CLEANUP_PUSH: a=original routine 5cf34, b=0 (same backend).
     * CLEANUP_POP: a=0 (do not execute), b=0. EVENT: a=code, b=0.
     * The 5e92c stop decision remains a binding, not a successful stub. */
    int32_t (*call)(void *,uint32_t entry,uint32_t a,uint32_t b);
    double (*now)(void *);
    /* A successful collector must initialize its output. On failure the
     * original does not inspect that output. */
    int32_t (*collect_temperature)(void *,int32_t *);
    /* 6100c / 61170: r1=0, r2=cached backend power+20c. Bodies not ported here. */
    int32_t (*reset_cores)(void *,uint32_t entry,uint32_t mode,uint32_t voltage);
    int32_t (*set_profile)(void *,const char *key,const char *value); /* 509b4 */
    void (*log)(void *,uint32_t line,uint32_t level,uint32_t a,uint32_t b,
                const char *detail);
};
int32_t vn135_monitor_chain_decision_135(struct vn135_monitor_handlers *,
    const struct vn135_monitor_handler_ops *,void *); /* 60a2c */
void vn135_monitor_check_chains_135(struct vn135_monitor_handlers *,
    const struct vn135_monitor_handler_ops *,void *); /* 60730 */
void vn135_monitor_finish_warmup_135(struct vn135_monitor_handlers *,
    const struct vn135_monitor_handler_ops *,void *); /* 60d58 */
void vn135_monitor_lower_preset_135(struct vn135_monitor_handlers *,
    const struct vn135_monitor_handler_ops *,void *); /* 5e53c */
/* Bind these four entries from an existing general_ops.call implementation.
 * Returns 1 if handled; unknown entries return 0 WITHOUT changing *result.
 * Caller must forward unhandled operations to its existing implementation. */
int vn135_monitor_handler_dispatch_135(struct vn135_monitor_handlers *,
    const struct vn135_monitor_handler_ops *,void *,uint32_t entry,int32_t *result);
/* Valid live views, stable descriptor/pointer identities, positive counts fit
 * allocated arrays; nonnegative bounded profile count; serialized callbacks;
 * finite binary64 clock arithmetic.
 * Preset numbers must be representable by int32_t; numeric conversion is atoi,
 * as in the original, not lexicographic ordering or a new preset ranking.
 * All reached callbacks except log are required. Trylock repeats until success;
 * no new time limit, cancellation check, voltage command or thread is added.
 * OS cleanup registration/execution, config persistence and reset_cores are
 * bindings. This port does not certify them or turn a void handler into an
 * operation reporting hardware success. */
#endif
