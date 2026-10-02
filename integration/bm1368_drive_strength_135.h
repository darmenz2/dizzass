/* Original e3728/e3a1c, chip/common cached register-0x58 configuration.
 * Typed synchronous host projection, not a vendor ABI or production binding. */
#ifndef VN135_BM1368_DRIVE_STRENGTH_135_H
#define VN135_BM1368_DRIVE_STRENGTH_135_H
#include "integration/bm1368_register_write_135.h"

struct vn135_bm1368_drive_strength_read_135 {
    void *context;
    int32_t (*chain)(void *, int32_t, uint32_t, uint32_t *);
    int32_t (*chip)(void *, int32_t, int32_t, uint32_t, uint32_t *);
};
struct vn135_bm1368_drive_strength_diagnostic_135 {
    const char *module, *source_path, *function, *format;
    uint32_t source_line, severity, has_index, index_bits;
};
struct vn135_bm1368_drive_strength_log_135 {
    void *context;
    void (*emit)(void *, const struct vn135_bm1368_drive_strength_diagnostic_135 *);
};

/* Explicit adapters to the existing caller-owned vn135_reg_cache getters.
 * Their structural guards and omitted internal diagnostics remain unchanged. */
int32_t vn135_bm1368_drive_strength_cache_chain_135(
    void *, int32_t, uint32_t, uint32_t *);
int32_t vn135_bm1368_drive_strength_cache_chip_135(
    void *, int32_t, int32_t, uint32_t, uint32_t *);

/* The local cached word starts at zero. Exact-zero read status reaches one
 * existing register writer call; every nonzero read emits one diagnostic and
 * returns -1 without writing. Replace only bits 12..15 with setting's low4.
 * Common uses mode1/NULL; chip uses mode0/the SAME live chip pointer. The
 * existing writer observes wire fields before send and cache indices after
 * send. Read callbacks may change these live fields; setting is passed by
 * value. Writer failure emits one wrapper diagnostic using the then-current
 * device index+1 (uint32 wrap). Read-failure diagnostics have no index field.
 * Exact-zero read and writer results yield zero; otherwise return -1.
 *
 * Required: live device, read view and reached callback; chip mode also needs
 * its live chip descriptor. Reached writer operations retain their existing
 * contract. Log/emit are required only on a wrapper failure. Views, contexts
 * and callback-table associations stay stable during the call; callbacks
 * return synchronously, may mutate valid pointed-to device/chip/cache fields,
 * and must not retain temporary output/payload/diagnostic pointers. No races,
 * raw-stack observation, invalid-pointer or nonreturning-callee claim.
 * A writer failure may occur after send: no retry, rollback or ACK is added.
 * These functions add no physical I/O or native driver registration. */
int32_t vn135_bm1368_set_chain_drive_strength_135(
    struct vn135_bm1368_frequency_device *, uint32_t setting,
    const struct vn135_bm1368_drive_strength_read_135 *,
    const struct vn135_bm1368_register_ops *, void *write_context,
    const struct vn135_bm1368_drive_strength_log_135 *);
int32_t vn135_bm1368_set_chip_drive_strength_135(
    struct vn135_bm1368_frequency_device *, const vn135_chip_reference *,
    uint32_t setting, const struct vn135_bm1368_drive_strength_read_135 *,
    const struct vn135_bm1368_register_ops *, void *write_context,
    const struct vn135_bm1368_drive_strength_log_135 *);
#endif
