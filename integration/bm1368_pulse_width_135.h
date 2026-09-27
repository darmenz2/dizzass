/* Original e34cc, an isolated pulse/clock-delay register transaction. */
#ifndef VN135_BM1368_PULSE_WIDTH_135_H
#define VN135_BM1368_PULSE_WIDTH_135_H
#include "integration/bm1368_register_write_135.h"

struct vn135_bm1368_pulse_ops {
    int32_t (*write_config)(void *,struct vn135_bm1368_frequency_device *,
        uint32_t mode,const vn135_chip_reference *,uint32_t reg,uint32_t value);
    /* Original severity 1, lines 387 and 569, each with a freshly read
     * one-based unsigned device index. The second log is not deduplicated. */
    void (*log)(void *,uint32_t line,uint32_t index);
};
struct vn135_bm1368_pulse_binding {
    const struct vn135_bm1368_register_ops *register_ops;
    void *register_context;
};
/* Explicit adapter to the ALREADY recovered e4a74; no replacement encoder,
 * cache, retry, transport or hardware success stub. opaque is a stable binding. */
int32_t vn135_bm1368_pulse_register_135(void *,
    struct vn135_bm1368_frequency_device *,uint32_t,const vn135_chip_reference *,
    uint32_t,uint32_t);

/* e34cc takes the low 2 bits of pulse_width and low 3 bits of clock_delay.
 * The original fourth ARM argument is overwritten before use; ignored_4 is
 * retained to make the parent method contract explicit. No range rejection.
 * One broadcast write of 0x3c, NULL chip; any nonzero result produces both
 * diagnostics then -1. No rollback, delay, cached read or second write.
 * Valid stable device/ops and reached write callback required; log optional.
 * Callbacks terminate and run sequentially; fields may change on their
 * boundaries. No concurrent device effects or production linkage supplied. */
int32_t vn135_bm1368_set_pulse_width_135(struct vn135_bm1368_frequency_device *,
    uint32_t pulse_width,uint32_t clock_delay,uint32_t ignored_4,
    const struct vn135_bm1368_pulse_ops *,void *);
#endif
