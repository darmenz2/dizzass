/* Offline translation of e249c; source module libbitmain/src/chip/chip1368.c. */
#ifndef VN135_BM1368_FREQUENCY_135_H
#define VN135_BM1368_FREQUENCY_135_H
#include "xminer/recovery/pll.h"

/* A device subobject at original chain+2b8, NOT a parent general_chain or ABI.
 * Its index is source device+18; do not alias it to parent chain+18. */
struct vn135_bm1368_frequency_device { uint32_t index; };
extern const vn135_pll_limits vn135_bm1368_frequency_limits_135;
struct vn135_bm1368_frequency_ops {
    int32_t (*solve)(void *,const vn135_pll_limits *,double,vn135_pll_result *);
    int32_t (*write_config)(void *,struct vn135_bm1368_frequency_device *,
        uint32_t broadcast,const void *chip,uint32_t reg,uint32_t value);
    /* Both messages use severity 1. line 966 has no PLL-number argument;
     * line 972 has PLL number 0. Index is one-based unsigned. */
    void (*log)(void *,uint32_t line,uint32_t index,double requested);
};
/* Adapter to the EXISTING computational ff288 reconstruction, not a new PLL
 * search. Its original internal diagnostic is omitted by that older API.
 * For compared nested execution: finite requested in [0,1e9], default binary64.
 * This adapter does not perform logging, register access or transport. */
int32_t vn135_bm1368_frequency_solve_135(void *,const vn135_pll_limits *,
    double,vn135_pll_result *);
/* Recovered ordinary body. Required: non-null stable device and ops, both
 * callbacks present, immutable callback table and limits, serialized effects.
 * A successful solve fills all four divisors and a finite VCO. Failure output
 * is not read. Bit packing uses uint32 wrapping/masks without signed UB.
 * Two writes are always made after an accepted tuple, including after the
 * first write fails. ONLY the second result determines 0/-1, with no rollback.
 * e4a74 and actual device effects are explicit boundaries. No success stub,
 * PLL hardware access, production binding or safe operating preset is supplied.
 */
int32_t vn135_bm1368_set_frequency_135(struct vn135_bm1368_frequency_device *,
    double,const struct vn135_bm1368_frequency_ops *,void *);
#endif
