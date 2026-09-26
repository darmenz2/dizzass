/* Exact bounded 1.3.5 caller/aggregate projections, not a new safety policy. */
#ifndef VN135_BACKEND_PERIPHERAL_135_H
#define VN135_BACKEND_PERIPHERAL_135_H
#include <stdint.h>
struct vn135_peripheral_chain {
    uint32_t word_20; uint8_t byte_24;
    int32_t word_2ac; uint8_t byte_2b0;
};
struct vn135_peripheral_entry {uint32_t type;uint8_t byte_19;};
struct vn135_peripheral_profile {
    int32_t table_count;const struct vn135_peripheral_entry *entries;
    uint32_t model_bc_08, model_f0_00;
};
struct vn135_peripheral_state {
    uint32_t mode_50, word_6c, word_70;
    struct vn135_peripheral_profile *profile;
    struct vn135_peripheral_chain *chains;
};
struct vn135_peripheral_ops {
    int32_t (*chain_count)(void *);
    int32_t (*lock)(void *,uint32_t chain);
    int32_t (*unlock)(void *,uint32_t chain);
    int32_t (*apply_f8a30)(void *,uint32_t);
    int32_t (*apply_f86a8)(void *,uint32_t,uint32_t,uint32_t,uint32_t);
    void (*log)(void *,uint32_t original_line);
};
/* These aggregate already cached values, not physical sensor reads. No new
 * freshness, validity, locking or range policy is inserted. Required object
 * capacities and callback lifetimes are caller preconditions. Lock/unlock and
 * apply return codes remain ignored, as in the inspected original instructions.
 * Async data races and electrical behavior are outside the verified domain.
 */
int vn135_backend_collect_5db54_135(struct vn135_peripheral_state *,
    const struct vn135_peripheral_ops *,void *,int32_t *out);
int vn135_backend_configure_6c61c_135(struct vn135_peripheral_state *,
    const struct vn135_peripheral_ops *,void *);
#endif
