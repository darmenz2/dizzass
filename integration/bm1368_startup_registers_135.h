/* SPDX-License-Identifier: GPL-3.0-only
 * Typed host projections of e35c0/e3098/e3290/e3c04, NOT the vendor ABI.
 */
#ifndef VN135_BM1368_STARTUP_REGISTERS_135_H
#define VN135_BM1368_STARTUP_REGISTERS_135_H
#include "integration/bm1368_register_write_135.h"

struct vn135_bm1368_startup_diagnostic_135 {
    const char *component, *source, *function, *format;
    uint32_t line, severity, chain_index;
};
struct vn135_bm1368_startup_ops_135 {
    int32_t (*read_chain)(void *, int32_t, uint32_t, uint32_t *);
    void *read_context;
    int32_t (*write_register)(void *, struct vn135_bm1368_frequency_device *,
        uint32_t, const vn135_chip_reference *, uint32_t, uint32_t);
    void *write_context;
    void (*emit)(void *, const struct vn135_bm1368_startup_diagnostic_135 *);
    void *log_context;
};
/* Explicit adapters, using the existing cache and writer, not new algorithms.
 * read_context is a live vn135_reg_cache. write_context is this binding. */
struct vn135_bm1368_startup_write_binding_135 {
    const struct vn135_bm1368_register_ops *writer;
    void *context;
};
int32_t vn135_bm1368_startup_cache_read_135(void *, int32_t, uint32_t, uint32_t *);
int32_t vn135_bm1368_startup_register_write_135(void *,
    struct vn135_bm1368_frequency_device *, uint32_t,
    const vn135_chip_reference *, uint32_t, uint32_t);

/* Common contract: valid device and stable ops/storage; every reached callback
 * is required and returns normally. Serialize externally. Callbacks may change
 * device->index and cache state, but not the ops table. They borrow output/event
 * objects only during the call and must not retain their pointers. A successful
 * read fills its output. Device index is NOT the outer coordinator index.
 * Every write is broadcast (1), NULL chip. There is no range validation,
 * timeout, sleep, lock, hardware acknowledgement, rollback or driver binding.
 * Actual writer failure may follow a successful send. Its older diagnostic
 * omissions and cache validation boundaries are not repaired by these wrappers.
 */
/* e35c0: low 3 setting bits -> reg54. Any nonzero write status logs line425
 * using the post-write index, then returns -1; zero returns without logging. */
int32_t vn135_bm1368_set_analog_mux_135(
    struct vn135_bm1368_frequency_device *, uint32_t,
    const struct vn135_bm1368_startup_ops_135 *);
/* e3098: (setting XOR 1) OR 0x80008dee -> reg3c. Setting is the FULL uint32,
 * not a boolean. Nonzero write status emits line387 then line593, with a fresh
 * index before EACH event, and returns -1. */
int32_t vn135_bm1368_set_nonce_bin_overflow_135(
    struct vn135_bm1368_frequency_device *, uint32_t,
    const struct vn135_bm1368_startup_ops_135 *);
/* e3290: one reg68 write of 0x5aa55aa5; forward the exact writer status.
 * No wrapper diagnostic. This numeric name does not infer a hardware effect. */
int32_t vn135_bm1368_write_reg68_pattern_135(
    struct vn135_bm1368_frequency_device *,
    const struct vn135_bm1368_startup_ops_135 *);
/* e3c04: common cache reads a8 then18, each using the current device index.
 * Nonzero mode: a8 |= 0x10f, 18 &= ~0x00f00000.
 * Zero mode: a8 &= ~0xf0, 18 |= 0xff0f0000.
 * Write a8 then18. Stop at ANY nonzero read/write result, return -1; otherwise0.
 * Both computed words survive the first write even if it mutates the cache.
 * No wrapper diagnostics; partial writes are not rolled back. */
int32_t vn135_bm1368_update_soft_reset_misc_135(
    struct vn135_bm1368_frequency_device *, uint32_t,
    const struct vn135_bm1368_startup_ops_135 *);
#endif
