/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_BM1368_CHAIN_DRIVE_STRENGTH_135_H
#define VN135_BM1368_CHAIN_DRIVE_STRENGTH_135_H
#include "integration/bm1368_drive_strength_135.h"

struct vn135_bm1368_chain_drive_strength_reader_135 {
    int32_t (*read_cached)(void *, int32_t chain, uint32_t reg, uint32_t *output);
    void *context;
};
/* Typed binding to existing COMMON getter 107188/10564c. No chip lookup or
 * function-pointer cast. Existing omitted nested diagnostics/access traces
 * and added structural guards remain that getter's explicit boundary. */
int32_t vn135_bm1368_chain_drive_strength_cache_135(void *, int32_t,
                                                  uint32_t, uint32_t *);

/* Ordinary e3a1c/f34fc projection, constructor +0x88; not vendor/native ABI.
 * Read COMMON cache once with signed device index bits, reg0x58 and borrowed
 * zero-initialized output. Any nonzero result: one line635 severity1 log
 * without index, return-1, do not inspect output or access writer. Success:
 * (cached & ~0xf000) | ((input & 15)<<12), one existing BM1368 writer call
 * (same device,1,NULL,0x58,value). Exactly-zero writer result returns0 with
 * no log access; otherwise reload device index AFTER writer, increment with
 * uint32 wrap, emit line645 severity1 indexed failure, return-1.
 *
 * Device, reader and reached writer/log associations, storage and code remain
 * valid across synchronous returning callbacks. Callback tables/context
 * identities stay fixed; fields may mutate at boundaries. Output, packet and
 * diagnostic pointers are borrowed only during callbacks: no escaped
 * temporaries or aliases into other local storage. Serialize concurrent
 * effects externally. Failure needs log/emit, read success needs writer.
 * Original initialized nonfaulting GOT/global/string storage and normal ARM
 * arithmetic are required. Two same-snapshot x*(x-1) products always have even
 * low bit: duplicate read-failure logger/back-edge are dead. Original access
 * traces, faults, races, string mutation and variadic formatting internals
 * are not projected. The existing chain setter uses the COMMON matched slot
 * for all chip tables; fixtures use coherent table layouts.
 *
 * No retry, ACK, rollback, model/preset inference or production registration.
 * Writer error may follow dispatch. Original read-format typo is preserved.
 */
int32_t vn135_bm1368_set_chain_drive_strength_135(
    struct vn135_bm1368_frequency_device *, uint32_t,
    const struct vn135_bm1368_chain_drive_strength_reader_135 *,
    const struct vn135_bm1368_register_ops *, void *,
    const struct vn135_bm1368_drive_strength_log_135 *);
#endif
