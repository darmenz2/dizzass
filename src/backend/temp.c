/* Selected original /tmp/build/src/backend/temp.c, pinned VNishNet 1.3.5.
 * Exact domains and original entry addresses: integration/THERMAL_SENSORS_135_RU.md.
 * No production linking, hardware calls, new sensor policy or rewritten core.
 */
#include "integration/thermal_sensors_135.h"
#include <limits.h>
static int32_t signed_bits(uint32_t u)
{ return u<=INT32_MAX?(int32_t)u:-1-(int32_t)(UINT32_MAX-u); }
static int32_t add32(int32_t a,int32_t b)
{ return signed_bits((uint32_t)a+(uint32_t)b); }
static void report(const struct vn135_temperature_ops *o,void *p,uint32_t line,
                   uint32_t chain,const struct vn135_temperature_sensor *s,uint32_t v)
{ if(o->log)o->log(p,line,chain+1u,s->index+1u,v); }
void vn135_temperature_reset(struct vn135_temperature_sensor *s,
    const struct vn135_temperature_ops *o,void *p)
{
    (void)o->mutex_init(p,s);
    s->remote_offset=0;s->sample=0;s->corrected=0;s->state=0;
    s->previous_sample=0;s->previous_corrected=0;s->started_at=0.0;
    s->extended=0;s->has_previous=0;
}
int vn135_temperature_accept(struct vn135_temperature_sensor *s,
    const struct vn135_temperature_ops *o,void *p,int32_t sample,int32_t second)
{
    int result=0;int32_t offset,value,delta;uint32_t state;
    (void)o->lock(p,s);
    offset=s->remote_enabled?s->remote_offset:s->local_offset;
    state=s->state;
    if(state==1){s->state=2;s->started_at=o->now(p);state=s->state;}
    if(state==3)goto done;
    value=add32(offset,second);
    if(s->access_kind==4 && s->has_previous){
        delta=signed_bits((uint32_t)s->previous_sample-(uint32_t)sample);
        if(delta<0)delta=signed_bits(0u-(uint32_t)delta);
        if(delta>30){result=-1;goto done;}
    }
    if(state-1u<=1u && !s->has_previous){
        s->previous_sample=sample;s->previous_corrected=value;s->has_previous=1;
    }else{s->previous_sample=s->sample;s->previous_corrected=s->corrected;}
    s->sample=sample;s->corrected=value;s->sampled_at=o->now(p);s->failures=0;
done:
    (void)o->unlock(p,s);return result;
}
int vn135_temperature_initialize(struct vn135_temperature_sensor *s,
    const struct vn135_temperature_ops *o,void *p,uint32_t chain)
{
    unsigned attempt;uint8_t correction;
    if(s->access_kind-1u>1u)return -1;
    if(o->configure_reading(p,s)){report(o,p,688,chain,s,0);goto fail;}
    for(attempt=0;attempt<3;++attempt){
        if(!o->read_register(p,s,254,&s->device_id))break;
        (void)o->delay_ms(p,50);
    }
    if(attempt==3){report(o,p,704,chain,s,0);goto fail;}
    if(s->device_id!=26 && s->device_id!=85 && s->device_id!=89){
        report(o,p,83,chain,s,s->device_id);goto config_fail;
    }
    if(s->access_kind==1 && o->write_register(p,s,9,4)){
        report(o,p,94,chain,s,0);goto config_fail;
    }
    if(s->remote_enabled){
        correction=s->device_id==89?244:s->device_id==85?242:s->device_id==26?246:0;
        if(o->write_register(p,s,17,correction)){
            report(o,p,107,chain,s,0);goto config_fail;
        }
    }
    if(s->access_kind==2 && o->finish_configuration(p,s)){
        report(o,p,118,chain,s,0);goto config_fail;
    }
    s->started_at=o->now(p);s->state=1;s->sampled_at=o->now(p);return 0;
config_fail:report(o,p,714,chain,s,0);
fail:s->state=3;return -1;
}
int vn135_temperature_fresh(struct vn135_temperature_sensor *s,
    const struct vn135_temperature_ops *o,void *p,double timeout)
{
    int valid=1;
    (void)o->lock(p,s);
    if(s->access_kind==2){
        if(s->state==3)valid=0;
        else if(o->now(p)-s->sampled_at>timeout){s->state=3;valid=0;}
    }
    (void)o->unlock(p,s);return valid;
}
int vn135_temperature_group_fresh(const struct vn135_temperature_group *g,
    const struct vn135_temperature_ops *o,void *p)
{
    int32_t i;int have=0,blocking=0;double newest=0.0,t;
    for(i=0;i<g->count;++i)if(g->description_types[i]!=2)break;
    if(i==g->count || g->count<1)return 1;
    for(i=0;i<g->count;++i){
        struct vn135_temperature_sensor *s=g->sensors+i;int dead;
        (void)o->lock(p,s);dead=s->state==3;
        if(dead){blocking|=s->role==2;t=0.0;}else t=s->sampled_at;
        (void)o->unlock(p,s);
        if(blocking)break;
        if(!dead){if(!have||t>newest)newest=t;have=1;}
    }
    t=(!have||blocking)?g->board_timeout+1000.0:o->now(p)-newest;
    return t<=g->board_timeout;
}
int vn135_temperature_read_local_path(struct vn135_temperature_sensor *s,
    const struct vn135_temperature_ops *o,void *p)
{
    uint8_t raw=0;int32_t value;
    if(s->state==3)return -1;
    /* Domain contract: access_kind is 1 and remote_enabled is zero. */
    (void)o->lock(p,NULL); /* original chain's bus lock, distinct from sensor */
    if(s->state-1u<=1u && o->read_register(p,s,0,&raw)){
        int32_t old;
        (void)o->lock(p,s);old=s->failures;s->failures=add32(old,1);
        if(old>=2)s->state=3;
        (void)o->unlock(p,s);(void)o->unlock(p,NULL);return -1;
    }
    (void)o->unlock(p,NULL);
    raw=(uint8_t)(raw-64u);value=raw<128?(int32_t)raw:(int32_t)raw-256;
    (void)vn135_temperature_accept(s,o,p,value,value);return 0;
}
