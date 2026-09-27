/* A-01: isolated field views for original b8e54. Not a vendor ABI. */
#ifndef VN135_THROTTLING_RESET_135_H
#define VN135_THROTTLING_RESET_135_H
#include "integration/general_monitor_135.h"

struct vn135_throttling_reset_model {
    /* Stable association with the existing view of the SAME source model. */
    struct vn135_general_model *general;
    uint32_t count_50, count_60;
};
struct vn135_throttling_reset_tables {
    /* Source global 68be68 + 0/4/8/c: nullable arrays of nullable byte buffers.
     * Per-row sizes: model+60*8, model+48*8, model+50*8, model+48.
     * The separate source table+10 is intentionally not part of this view. */
    uint8_t **groups[4];
};
struct vn135_throttling_reset_view {
    struct vn135_throttling_reset_model *model; /* source backend+18 */
    struct vn135_throttling_reset_tables *tables; /* stable global identity */
    void *mutex; /* stable source mutex 612aa0, not the backend mutex */
};
struct vn135_throttling_reset_ops {
    int32_t (*chain_count)(void *); /* fe668; read once, even on skipped platform */
    int32_t (*platform)(void *);    /* fdfbc */
    int32_t (*lock)(void *, void *);   /* 5a6108; result ignored */
    int32_t (*unlock)(void *, void *); /* 5a66c4; result ignored */
    void (*zero)(void *, uint8_t *, uint32_t); /* 5a348c(dst,0,length) */
};
/* Captures model after chain_count but before platform/lock. Each reached row
 * and size is read afresh. Valid stable views/associations and ops are required;
 * reached arrays cover the captured positive chain count, and every reached
 * row covers the uint32_t byte length (shifts wrap as in A32). Nullable rows
 * are skipped. Reached callbacks are mandatory, serialized and terminating.
 * No size validation, lock recovery, allocation/free, I/O or success status
 * is added. This function is NOT production-bound and does not prove hardware
 * stop or thread safety. New view pointers must not be cast from vendor memory.
 */
void vn135_throttling_reset_135(struct vn135_throttling_reset_view *,
    const struct vn135_throttling_reset_ops *, void *);
#endif
