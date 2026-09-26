/* Original 65b3c: dispatch per-chain frequency reduction during mining stop.
 * Offline projections only; no production thread or frequency commands. */
#ifndef VN135_FREQUENCY_FALL_135_H
#define VN135_FREQUENCY_FALL_135_H
#include "integration/general_monitor_135.h"

/* Original model+cc, offsets 0c and 18; not a binary-compatible layout. */
struct vn135_frequency_fall_config { int32_t floor_0c, target_18; };
struct vn135_frequency_fall_state {
    struct vn135_general_monitor *general;
    struct vn135_frequency_fall_config *config;
};
struct vn135_frequency_fall_argument {
    struct vn135_frequency_fall_state *backend;
    struct vn135_general_chain *chain;
};
enum vn135_frequency_fall_allocation { VN135_FALL_ARGUMENTS, VN135_FALL_HANDLES };
struct vn135_frequency_fall_ops {
    int32_t (*chain_count)(void *); /* fe668; each original call is retained */
    /* 593bb4: count is the original uint32 bits; source_stride is 8 or 4.
     * Return zeroed HOST arrays (argument records or uint32_t handles), not
     * source-layout byte buffers. The adapter must translate host sizes and
     * preserve original allocation failure/overflow behavior. Zero count may
     * yield either NULL or a releasable non-NULL pointer. */
    void *(*allocate)(void *,enum vn135_frequency_fall_allocation,
                      uint32_t count,uint32_t source_stride);
    void (*release)(void *,enum vn135_frequency_fall_allocation,void *); /* 593c8c */
    /* 5a55cc: original worker 65fcc, NULL attributes, output handle and argument
     * identity preserved. The worker BODY remains an explicit boundary. */
    int32_t (*create)(void *,uint32_t *handle,uint32_t entry,
                     struct vn135_frequency_fall_argument *);
    int32_t (*join)(void *,uint32_t handle,uint32_t *result); /* NULL result */
    void (*log)(void *,uint32_t line,uint32_t level,int32_t value);
};
/* Existing chain.thermal.cleared_words[0] is source chain+28, interpreted as
 * signed frequency bits; state/present reuse the original 56fcc predicate.
 * All reached callbacks except log are mandatory. Every positive count fits
 * the corresponding allocated arrays. Descriptor/pointer identities and
 * allocated memory remain valid during each synchronous callback. No real
 * concurrent worker execution is supplied. A failed create causes immediate
 * release of BOTH arrays with NO joins of earlier successful creates, exactly
 * as observed; binding this to real workers requires a separate lifetime review.
 * Return is original control status, not proof of frequency or physical stop.
 */
int32_t vn135_backend_fall_frequency_135(struct vn135_frequency_fall_state *,
    const struct vn135_frequency_fall_ops *,void *);
#endif
