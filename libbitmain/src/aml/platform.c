/* Selected original /tmp/build/libbitmain/src/aml/platform.c, 1.3.5.
 * Original chain-reset entry only, NOT full platform initialization. */
#include "integration/thermal_routes_135.h"
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
