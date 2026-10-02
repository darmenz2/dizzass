/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_BM1368_DRIVE_STRENGTH_135_H
#define VN135_BM1368_DRIVE_STRENGTH_135_H
#include "integration/bm1368_register_write_135.h"
#include "xminer/recovery/reg_cache.h"

struct vn135_bm1368_drive_strength_reader_135 {
    int32_t (*read_cached)(void *, int32_t chain, int32_t chip,
                           uint32_t reg, uint32_t *output);
    void *context;
};
/* Typed binding to the existing 1079f0 cache projection, no wire GET_STATUS,
 * new cache or function-pointer cast. Its omitted internal diagnostics and
 * added structural guards remain the existing getter's explicit boundary. */
int32_t vn135_bm1368_drive_strength_cache_135(void *, int32_t, int32_t,
                                            uint32_t, uint32_t *);

struct vn135_bm1368_drive_strength_diagnostic_135 {
    const char *module, *source, *function, *format;
    uint32_t line, severity, has_index, index_bits;
};
struct vn135_bm1368_drive_strength_log_135 {
    void *context;
    void (*emit)(void *, const struct vn135_bm1368_drive_strength_diagnostic_135 *);
};

/* Ordinary e3728/f33ec projection, constructor +0x84, not vendor/native ABI.
 * Device and readable non-NULL chip are required. First invoke the reader
 * once with signed device index bits, chip cache_index, reg0x58 and a borrowed
 * zero-initialized output. Any nonzero result emits line609 without index,
 * returns -1 and never accesses writer. Output is not inspected on failure.
 * On success: (cached & ~0xf000) | ((input & 15)<<12), one actual existing
 * BM1368 writer(device,0,same chip,0x58,value). Exactly-zero result returns0
 * without accessing log. Otherwise reload index AFTER writer, increment with
 * uint32 wrap, emit one line619 severity1 indexed failure, return-1.
 *
 * Device/chip identities, reader and reached writer/log associations, storage
 * and callback code stay valid across synchronous returning calls. Callback
 * tables/context identities remain fixed; fields may mutate at boundaries.
 * Output/payload/diagnostic pointers are borrowed only during the callback;
 * no aliasing into other local storage or escaped temporary data. Serialize
 * concurrent effects externally. Failure requires log/emit, successful cached
 * read requires writer. Original initialization, valid GOT/global/string
 * storage and normal ARM arithmetic required. Seven same-snapshot x*(x-1)
 * products have an even low bit; duplicate read/logs and back-edges are dead.
 * Original nonfaulting GOT/global/access traces, dynamic string changes,
 * faults, races and variadic formatting internals are not projected.
 *
 * No retry, wait, ACK, rollback, second write, model identification, safe drive
 * preset or production registration. A writer error may follow dispatch.
 */
int32_t vn135_bm1368_set_chip_drive_strength_135(
    struct vn135_bm1368_frequency_device *, const vn135_chip_reference *, uint32_t,
    const struct vn135_bm1368_drive_strength_reader_135 *,
    const struct vn135_bm1368_register_ops *, void *,
    const struct vn135_bm1368_drive_strength_log_135 *);
#endif
