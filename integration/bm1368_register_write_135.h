/* Original e4a74, isolated command/cache transaction. No live transport. */
#ifndef VN135_BM1368_REGISTER_WRITE_135_H
#define VN135_BM1368_REGISTER_WRITE_135_H
#include "integration/bm1368_frequency_135.h"
#include "xminer/recovery/chip1398.h"

/* Reuse the existing device+18 projection and chip index/address pair.
 * Neither type is a vendor ABI. Device and chip storage stays valid across
 * callbacks; their fields may change. The callbacks table itself is stable. */
struct vn135_bm1368_register_ops {
    int32_t (*send_payload)(void *,struct vn135_bm1368_frequency_device *,
        const uint8_t *,size_t); /* d26ac, 9 bytes WITHOUT the AML prefix */
    int32_t (*cache_chain)(void *,int32_t chain,uint32_t reg,uint32_t value);
    int32_t (*cache_chip)(void *,int32_t chain,int32_t chip,
        uint32_t reg,uint32_t value);
    /* fa0c4, severity 1, source line 350, one-based unsigned device index. */
    void (*log)(void *,uint32_t line,uint32_t index);
};
/* Callback adapters: opaque is an existing caller-owned vn135_reg_cache.
 * Its validation/ownership contract and omitted internal diagnostics remain
 * those of the existing API; no new cache or lookup algorithm is introduced. */
int32_t vn135_bm1368_register_cache_chain_135(void *,int32_t,uint32_t,uint32_t);
int32_t vn135_bm1368_register_cache_chip_135(void *,int32_t,int32_t,uint32_t,uint32_t);

/* Recovered ordinary flow. All reached callbacks except log are required.
 * mode==1 selects wire broadcast; ANY nonzero mode selects cache fanout.
 * Wire address/register are truncated to bytes; cache receives the full reg.
 * Chip may be NULL even in unicast: address and cache index then default to 0.
 * Device index and chip cache index are read AFTER successful send. No cache
 * preflight, retry, wait, rollback, mutex or reply/ACK verification is added.
 * Returns 0 only for zero send AND zero cache status, otherwise -1. A cache
 * error occurs after dispatch; -1 must not imply that nothing was sent.
 * Synchronous callbacks may not retain the temporary payload pointer.
 * This offline entry does not enable ASIC access or production linkage. */
int32_t vn135_bm1368_write_register_135(struct vn135_bm1368_frequency_device *,
    uint32_t mode,const vn135_chip_reference *,uint32_t reg,uint32_t value,
    const struct vn135_bm1368_register_ops *,void *);
#endif
