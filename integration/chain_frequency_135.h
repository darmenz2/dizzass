#ifndef VN135_CHAIN_FREQUENCY_135_H
#define VN135_CHAIN_FREQUENCY_135_H
#include "integration/general_monitor_135.h"

/* Typed projections of backend method slots 140/188, NOT a vendor ABI.
 * 'chain' denotes the device subobject at original chain+2b8 for these two
 * calls. The binding resolves that identity; no raw ARM address is executed. */
struct vn135_chain_frequency_methods {
    int32_t (*set_all)(void *,struct vn135_general_chain *,double);
    int32_t (*pulse_width)(void *,struct vn135_general_chain *,uint32_t,
                           uint32_t,uint32_t);
};
struct vn135_chain_frequency_view {
    struct vn135_general_chain *chain;
    struct vn135_chain_frequency_methods *methods; /* source chain+1c */
};
struct vn135_chain_frequency_ops {
    int32_t (*lock)(void *,struct vn135_general_chain *);   /* 5a6108 */
    int32_t (*unlock)(void *,struct vn135_general_chain *); /* 5a66c4 */
    uint32_t (*platform)(void *);                         /* fdfbc */
    /* line 1060: frequency argument; line 1074: frequency is absent, passed 0.
     * Both original messages have severity 1. Index is one-based uint32. */
    void (*log)(void *,uint32_t line,uint32_t index,double frequency);
};
/* Original 57a10. Only finite binary64 input; nonnegative detected_8c bounded
 * by the chip array. detected_8c is the count for this view of source +8c;
 * thermal.chip_count is NOT a second count consulted by this function.
 * Cache: chip.word_08; min=cleared_words[0], mean IEEE bits=[1,2], max=[3].
 * Valid stable separate objects, serialized terminating callbacks, and default
 * floating rounding are required. No physical PLL, real locks or fallback
 * success callbacks supplied. Old core and existing chain-stop are untouched.
 * Returns 0 for skipped/inactive and both-success paths, -1 on either device
 * callback error. A pulse error occurs AFTER cache commit; no rollback exists.
 */
int32_t vn135_chain_set_frequency_135(struct vn135_chain_frequency_view *,
    uint32_t word_20,uint32_t word_10,double frequency,
    const struct vn135_chain_frequency_ops *,void *);
#endif
