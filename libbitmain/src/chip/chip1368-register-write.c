/* Original libbitmain/src/chip/chip1368.c, e4a74..e4bec.
 * Separate offline translation unit; no default transport or production link. */
#ifdef VN135_BM1368_REGISTER_WRITE_135
#include "integration/bm1368_register_write_135.h"
#include "integration/bm1368_control.h"
#include <stdint.h>

static int32_t register_signed_index(uint32_t word)
{
    return word<=INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word-INT64_C(4294967296));
}

int32_t vn135_bm1368_register_cache_chain_135(void *cache,int32_t chain,
    uint32_t reg,uint32_t value)
{
    return vn135_reg_cache_set_chain(cache,chain,reg,value);
}

int32_t vn135_bm1368_register_cache_chip_135(void *cache,int32_t chain,
    int32_t chip,uint32_t reg,uint32_t value)
{
    return vn135_reg_cache_set_chip(cache,chain,chip,reg,value);
}

int32_t vn135_bm1368_write_register_135(
    struct vn135_bm1368_frequency_device *device,uint32_t mode,
    const vn135_chip_reference *chip,uint32_t reg,uint32_t value,
    const struct vn135_bm1368_register_ops *ops,void *opaque)
{
    uint8_t frame[11];
    size_t written=0;
    int32_t result,chain;
    /* Normalize only encoder inputs, NOT the later cache dispatch selector. */
    if(dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_CONFIG,mode==1u,
        chip ? (chip->wire_address&255u) : 0u,reg&255u,value,
        frame,sizeof frame,&written) || written!=sizeof frame)
        return -1; /* Unreachable for the bounded local encoder arguments. */
    if(ops->send_payload(opaque,device,frame+2,9)){
        if(ops->log)ops->log(opaque,350,device->index+1u);
        return -1;
    }
    chain=register_signed_index(device->index);
    if(mode!=0u)
        result=ops->cache_chain(opaque,chain,reg,value);
    else
        result=ops->cache_chip(opaque,chain,chip ? chip->cache_index : 0,reg,value);
    return result==0 ? 0 : -1;
}
#endif
