/* Original 5ac80: typed field projection, not a vendor ABI or device driver. */
#ifndef VN135_CHAIN_RESET_CLEANUP_135_H
#define VN135_CHAIN_RESET_CLEANUP_135_H
#include "integration/general_monitor_135.h"

struct vn135_chain_reset_cleanup_view {
    struct vn135_general_chain *chain;
    struct vn135_general_monitor *backend; /* source chain+1c */
    uint32_t word_80;
    uint8_t statistics_tail_6c[4]; /* source +6c..+6f */
    double time_70, time_78;
};
struct vn135_chain_reset_cleanup_ops {
    const struct vn135_chain_stop_ops *stop;
    double (*now)(void *); /* original 1ed58; called twice */
    /* Original 58700, AFTER unlock. Bind the existing recovered aggregate with
     * a fresh model/array projection. Required, never a successful default.
     * Its own locks/field updates are not replaced by the outer chain lock. */
    void (*aggregate)(void *, struct vn135_route_chain *);
};
/* All reached objects and callbacks are valid, nonaliasing and serialized.
 * Counts are signed and fit their respective arrays; no new guards or retries.
 * Synchronous callbacks may change backend/model/arrays and scalar fields to
 * other valid objects. Chain identity and ops remain stable. Model/chip counts
 * are read after both clock calls; sensor count is fetched separately later.
 * chain.sensor_count and chain.chip_count are NOT these two loop bounds.
 * now supplies finite binary64 values (no arithmetic here). Chip temperature
 * and sensor times are reset as zero bytes, without interpreting old bits.
 * Scratch preserves the existing auxiliary helper's failed-exchange semantics.
 * Unlock status is ignored and aggregation still occurs. No hardware-success
 * return, physical I/O, sensor mutex/reset call, UART flush or epoch boundary.
 */
void vn135_chain_reset_cleanup_135(struct vn135_chain_reset_cleanup_view *,
    const struct vn135_chain_reset_cleanup_ops *, void *, uint8_t reply_scratch[2]);
#endif
