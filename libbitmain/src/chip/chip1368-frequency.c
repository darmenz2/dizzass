/* SPDX-License-Identifier: GPL-3.0-only
 * Original e249c ordinary body; isolated unit, not a production driver.
 * The vendor source path is libbitmain/src/chip/chip1368.c, not this new name. */
#ifdef VN135_BM1368_FREQUENCY_135
#include "integration/bm1368_frequency_135.h"
#include <stddef.h>

/* Original 56-byte record at 5eb6c0. reserved_16 becomes the VCO mode threshold
 * here; the existing generic PLL search deliberately does not read that field. */
const vn135_pll_limits vn135_bm1368_frequency_limits_135 = {
    25.0,3200.0,2400.0,2000.0,2,250,7,0,2.5
};
int32_t vn135_bm1368_frequency_solve_135(void *opaque,
    const vn135_pll_limits *limits,double requested,vn135_pll_result *result)
{
    (void)opaque;
    return vn135_pll_search_legacy(limits,requested,result);
}
int32_t vn135_bm1368_set_frequency_135(
    struct vn135_bm1368_frequency_device *device,double requested,
    const struct vn135_bm1368_frequency_ops *ops,void *opaque)
{
    const vn135_pll_limits *limits=&vn135_bm1368_frequency_limits_135;
    vn135_pll_result pll;
    uint32_t word;
    if(ops->solve(opaque,limits,requested,&pll)){
        if(ops->log)ops->log(opaque,966,device->index+1u,requested);
        return -1;
    }
    if(pll.vco_mhz<limits->vco_min_mhz || pll.vco_mhz>limits->vco_max_mhz)
        goto failed;
    word=(pll.vco_mhz<limits->reserved_16 ? UINT32_C(0x40000000) : UINT32_C(0x50000000))
        | (((uint32_t)pll.feedback_divider & 4095u)<<16)
        | (((uint32_t)pll.reference_divider & 63u)<<8)
        | ((((uint32_t)pll.post_divider1-1u)&7u)<<4)
        | (((uint32_t)pll.post_divider2-1u)&7u);
    (void)ops->write_config(opaque,device,1,NULL,8,word);
    if(!ops->write_config(opaque,device,1,NULL,8,word))return 0;
failed:
    if(ops->log)ops->log(opaque,972,device->index+1u,requested);
    return -1;
}
#endif
