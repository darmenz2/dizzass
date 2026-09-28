/* Original libbitmain/src/chip/chip1368.c, e34cc..e35a0.
 * Separate offline translation unit; not the original vendor filename. */
#ifdef VN135_BM1368_PULSE_WIDTH_135
#include "integration/bm1368_pulse_width_135.h"

int32_t vn135_bm1368_pulse_register_135(void *opaque,
    struct vn135_bm1368_frequency_device *device,uint32_t mode,
    const vn135_chip_reference *chip,uint32_t reg,uint32_t value)
{
    const struct vn135_bm1368_pulse_binding *binding=opaque;
    return vn135_bm1368_write_register_135(device,mode,chip,reg,value,
        binding->register_ops,binding->register_context);
}

int32_t vn135_bm1368_set_pulse_width_135(
    struct vn135_bm1368_frequency_device *device,uint32_t pulse_width,
    uint32_t clock_delay,uint32_t ignored_4,
    const struct vn135_bm1368_pulse_ops *ops,void *opaque)
{
    uint32_t word=UINT32_C(0x80008000) |
        ((pulse_width & 3u)<<6) | ((clock_delay & 7u)<<3);
    (void)ignored_4; /* r3 is replaced with register 0x3c before any read. */
    if(!ops->write_config(opaque,device,1,NULL,0x3c,word))return 0;
    if(ops->log)ops->log(opaque,387,device->index+1u);
    if(ops->log)ops->log(opaque,569,device->index+1u);
    return -1;
}
#endif
