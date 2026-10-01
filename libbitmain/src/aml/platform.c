/* Selected original /tmp/build/libbitmain/src/aml/platform.c, 1.3.5.
 * Reconstructed entries: chain-reset entry and pure UART-path result.
 * NOT full platform initialization; no production driver registration. */
#include "integration/thermal_routes_135.h"
#include "xminer/recovery/aml_platform.h"
static void note(vn135_route_log fn,void *p,enum vn135_route_log_source src,
    uint32_t line,const uint32_t *a,size_t n)
{ if(fn)fn(p,src,line,a,n); }
int32_t vn135_chain_reset_aml_135(uint32_t index,uint32_t asserted,
    const struct vn135_aml_reset_ops *o,void *p)
{
    static const uint32_t pins[3]={454,455,456};
    if(index>=3){note(o->log,p,VN135_ROUTE_AML_RESET,130,&index,1);return -1;}
    return o->gpio_set(p,pins[index],asserted^1u);
}

/* cgminer 0x11c080, decision core 0x11c0c0; hwscan 0x10e220.
 * Preserve the original empty-string result for all unsigned out-of-range IDs.
 * The table length, not a masked index or an assumed valid caller, guards it.
 */
const char *vn135_aml_uart_path_135(uint32_t chain_index)
{
    static const char *const paths[] = {
        "/dev/ttyS3", "/dev/ttyS2", "/dev/ttyS1"
    };
    if (chain_index < sizeof(paths) / sizeof(paths[0]))
        return paths[chain_index];
    return "";
}
