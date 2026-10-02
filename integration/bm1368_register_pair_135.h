/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_BM1368_REGISTER_PAIR_135_H
#define VN135_BM1368_REGISTER_PAIR_135_H
#include "integration/bm1368_register_write_135.h"
#include "xminer/recovery/reg_cache.h"

struct vn135_bm1368_register_pair_reader_135 {
    int32_t (*read_cached)(void *, int32_t chain, uint32_t reg, uint32_t *output);
    void *context;
};
/* Typed existing COMMON getter 107188/10564c binding, no new cache/GET_STATUS.
 * Its added structural guards and omitted internal diagnostics/access traces
 * remain the existing API boundary; no full nested-effect parity is claimed. */
int32_t vn135_bm1368_register_pair_cache_135(void *, int32_t, uint32_t, uint32_t *);

/* Ordinary e3c04/f3618 projection, constructor+0x94; not vendor/native ABI.
 * Read COMMON registers A8 then18, once each and only after exactly-zero
 * preceding status. Reload signed device index bits for EACH read. Output
 * locals are UNINITIALIZED as in the original: a reader MUST write a valid
 * uint32 word on success and MUST NOT inspect its output before assigning it.
 * Failure output is ignored; any nonzero read returns-1, accessing no writer.
 *
 * Any nonzero flag: a8|0x10f, reg18&~0xf00000. Zero flag: a8&~0xf0,
 * reg18|0xff0f0000. Both words are captured before any write. One existing
 * writer(same device,1,NULL,A8,value); only exactly-zero status permits one
 * writer(same device,1,NULL,18,value). Each nonzero returns-1; both zero->0.
 * No outer log, retry, rollback, wait, ACK or inferred physical mode/preset.
 * A writer error may follow dispatch; first success is not rolled back.
 *
 * Synchronous callbacks return normally; device, callback tables/context
 * identities and reached reader/writer associations remain valid/fixed.
 * Fields/cache contents may mutate at boundaries, but output temporaries and
 * payload pointers are borrowed only during callbacks: no escape or aliases
 * into other local storage. Serialize concurrent effects externally. Writer
 * is required only after both reads succeed. Existing chain cache setter
 * updates the COMMON matched numeric slot in every chip table; coherent
 * layouts are required for interpreting those slots as the same register.
 *
 * Original nonfaulting mapped GOT/global storage and normal ARM arithmetic
 * required. Six same-snapshot x*(x-1) products: one TST has dead flags, five
 * low-bit tests always branch; duplicate transforms/writes/back-edges are
 * dead. Original access traces, faults, races and asynchronous control changes
 * are outside this projection. No production registration or model inference.
 */
int32_t vn135_bm1368_configure_register_pair_135(
    struct vn135_bm1368_frequency_device *, uint32_t,
    const struct vn135_bm1368_register_pair_reader_135 *,
    const struct vn135_bm1368_register_ops *, void *);
#endif
