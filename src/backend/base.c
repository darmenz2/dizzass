/* Selected original /tmp/build/src/backend/base.c, VNishNet 1.3.5.
 * Whole entries: 0x6c224 power-on + voltage; 0x6b778 power-off + chain reset.
 * Upper miner startup is NOT reconstructed here. See evidence/README.
 */
#include "integration/gpio_power_135.h"
static void log_line(const struct vn135_backend_power_ops *o,void *p,
                     uint32_t line,uint32_t arg)
{ if(o->log)o->log(p,VN135_GP_BASE,line,arg); }
int vn135_backend_power_start_135(struct vn135_backend_power_state *s,
    const struct vn135_backend_power_ops *o,void *p,uint32_t requested)
{
    log_line(o,p,4997,0);
    if(o->psu_on(p)) {log_line(o,p,5000,0);return -1;}
    log_line(o,p,1973,requested);
    if(o->set_voltage(p,(uint16_t)requested)) {
        log_line(o,p,1976,requested);
        log_line(o,p,5005,0);
        return -1;
    }
    s->byte_ff1=1;
    s->word_20c=requested;
    return 0;
}
int vn135_backend_power_stop_135(struct vn135_backend_power_state *s,
    const struct vn135_backend_power_ops *o,void *p)
{
    int32_t count=o->chain_count(p),i;
    log_line(o,p,5019,0);
    if(o->psu_off(p)) {log_line(o,p,5022,0);return -1;}
    for(i=0;i<count;++i)(void)o->reset_chain(p,(uint32_t)i);
    s->byte_ff1=0;
    s->word_20c=0;
    return 0;
}
static int32_t bits_signed(uint32_t x)
{ return x<=INT32_MAX?(int32_t)x:-1-(int32_t)(UINT32_MAX-x); }
uint32_t vn135_power_caller_value_135(uint32_t base,uint32_t limit,
                                    uint8_t flag,uint32_t selector)
{
    if(!flag && selector==5)base+=1000u;
    return bits_signed(base)<bits_signed(limit)?base:limit;
}
