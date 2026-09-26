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

/* Additional original direct paths of b5f40, access kinds 0 and 3 only. */
#include "integration/thermal_routes_135.h"
int vn135_temperature_read_direct_135(struct vn135_temperature_sensor *s,uint32_t chain,
    const struct vn135_direct_temperature_ops *o,void *p)
{
    uint8_t raw[4]={0,0,0,0};int32_t rc,old,value;uint32_t address,arg;
    const struct vn135_temperature_ops *t=o->temperature;
    if(s->state==3)return -1;
    if(s->remote_enabled){
        if(o->log)o->log(p,VN135_ROUTE_DIRECT_READ,401,NULL,0);
        s->state=3;return -1;
    }
    (void)t->lock(p,NULL);
    if(s->access_kind==0)
        rc=o->read(p,0xfaeec,0x20u|(chain&7u),s->address,0,raw,2);
    else{
        uint32_t platform=o->platform_kind(p);
        address=(chain+s->address)&255u;
        rc=o->read(p,platform?0xfe440:0xfe528,address,0,0,raw,3);
    }
    if(rc){
        if(s->access_kind==0 && o->log){arg=chain+1u;o->log(p,VN135_ROUTE_DIRECT_READ,425,&arg,1);}
        (void)t->lock(p,s);old=s->failures;s->failures=add32(old,1);
        if(old>=2)s->state=3;
        (void)t->unlock(p,s);(void)t->unlock(p,NULL);return -1;
    }
    (void)t->unlock(p,NULL);
    if(s->extended)raw[0]=(uint8_t)(raw[0]-64u);
    value=raw[0]<128?(int32_t)raw[0]:(int32_t)raw[0]-256;
    (void)vn135_temperature_accept(s,t,p,value,value);
    return 0;
}

/* Whole synchronous reader. Opt-in preserves earlier standalone targets. */
#ifdef VN135_THERMAL_READER_135
#include "integration/thermal_reader_135.h"
static int reader_failed(struct vn135_temperature_sensor *s,
    const struct vn135_temperature_ops *o, void *p)
{
    int32_t old;
    (void)o->lock(p,s);old=s->failures;s->failures=add32(old,1);
    if(old>=2)s->state=3;
    (void)o->unlock(p,s);(void)o->unlock(p,NULL);return -1;
}
static int32_t reader_byte(uint8_t v)
{ return v<128?(int32_t)v:(int32_t)v-256; }
static int32_t reader_mux_write(const struct vn135_reader_ops *o,void *p,
                               uint32_t address,uint8_t *command)
{
    if(o->platform_kind(p))
        return o->transfer(p,0xfe518,address&255u,0,*command,NULL,1);
    return o->transfer(p,0xfe538,address&255u,0,0,command,1);
}
static int32_t reader_mux_read(const struct vn135_reader_ops *o,void *p,
    uint32_t address,uint32_t reg,uint8_t *out,uint32_t alternate_length)
{
    if(o->platform_kind(p))
        return o->transfer(p,0xfe440,address&255u,0,reg,out,alternate_length);
    return o->transfer(p,0xfe528,address&255u,1,reg,out,1);
}
int vn135_temperature_read_135(struct vn135_temperature_sensor *s,
    const struct vn135_reader_context *c,const struct vn135_reader_ops *r,
    void *p,struct vn135_reader_scratch *scratch)
{
    const struct vn135_temperature_ops *o=r->temperature;
    static const char special_model[]="u3s21exph";
    uint8_t raw[4]={0,0,0,0},*b=scratch->bytes;
    int32_t rc=0,local,second,offset;
    unsigned attempt,config_try,shift;
    if(s->state==3)return -1;
    if(s->remote_enabled && s->access_kind!=4){
        if(o->log)o->log(p,401,0,0,0);
        s->state=3;return -1;
    }
    (void)o->lock(p,NULL);
    switch(s->access_kind){
    case 0:
        rc=r->transfer(p,0xfaeec,(c->chain_index&7u)|32u,s->address,0,raw,2);
        if(rc){if(o->log)o->log(p,425,c->chain_index+1u,0,0);
            return reader_failed(s,o,p);}
        break;
    case 1:
        if(s->state-1u<=1u && o->read_register(p,s,0,raw))
            return reader_failed(s,o,p);
        break;
    case 3:
        if(r->platform_kind(p))
            rc=r->transfer(p,0xfe440,(c->chain_index+s->address)&255u,0,0,raw,3);
        else rc=r->transfer(p,0xfe528,(c->chain_index+s->address)&255u,0,0,raw,3);
        if(rc)return reader_failed(s,o,p);
        break;
    case 4:
        shift=s->index&255u;
        for(attempt=0;attempt<3;++attempt){
            if(s->state-1u>1u)break;
            b[1]=0;
            rc=reader_mux_write(r,p,c->mux_address,b+1);
            (void)o->delay_ms(p,20);
            if(rc)continue;
            b[2]=(uint8_t)(shift<32?(1u<<shift):0);
            if(reader_mux_write(r,p,c->mux_address,b+2))goto retry;
            b[3]=0;
            for(config_try=0;config_try<3;++config_try){
                b[4]=0;
                if(r->platform_kind(p))
                    rc=r->transfer(p,0xfe518,s->address&255u,0,9,b+4,2);
                else rc=r->transfer(p,0xfe538,s->address&255u,1,9,b+4,1);
                (void)o->delay_ms(p,20);
                if(rc)continue;
                rc=reader_mux_read(r,p,s->address,3,b+3,2);
                if(!rc && !(b[3]&4u))break;
                (void)o->delay_ms(p,20);
            }
            if(config_try==3)goto retry;
            s->extended=0;
            (void)o->delay_ms(p,150);(void)o->delay_ms(p,20);
            (void)o->delay_ms(p,20);
            if(reader_mux_read(r,p,s->address,0,b+5,3))goto retry;
            (void)o->delay_ms(p,65);raw[0]=b[5];
            if(s->remote_enabled && (c->backend_active ||
               (c->power_marked_on && !r->compare_model(p,c->model_name,special_model)))){
                (void)o->delay_ms(p,20);
                if(reader_mux_read(r,p,s->address,1,b+7,3))goto retry;
                (void)o->delay_ms(p,65);raw[1]=b[7];
            }
            (void)o->delay_ms(p,20);b[0]=0;
            if(reader_mux_write(r,p,c->mux_address,b))goto retry;
            break;
retry:
            (void)o->delay_ms(p,20);
        }
        if(attempt==3)return reader_failed(s,o,p);
        break;
    default:
        report(o,p,474,c->chain_index,s,0);
        (void)o->unlock(p,NULL);return -1;
    }
    (void)o->unlock(p,NULL);
    if(s->access_kind==1 || s->extended)raw[0]=(uint8_t)(raw[0]-64u);
    local=reader_byte(raw[0]);second=local;
    if(s->remote_enabled && c->power_marked_on &&
       !r->compare_model(p,c->model_name,special_model)){
        double result;
        offset=0;(void)r->model_offset(p,c->chain_index+1u,s->index,&offset);
        /* Original VNMLS: rounded product + negated previous accumulator.
         * Finite domain, separate multiply/add; no FMA. */
        result=(double)reader_byte(raw[1])*0x1.2666666666666p+0;
        result=-(double)offset+result;
        if(result>=(double)INT32_MAX)second=INT32_MAX;
        else if(result<=(double)INT32_MIN)second=INT32_MIN;
        else second=(int32_t)result;
    }
    (void)vn135_temperature_accept(s,o,p,local,second);return 0;
}
int vn135_temperature_initialize_direct_135(struct vn135_temperature_sensor *s,
    const struct vn135_reader_context *c,const struct vn135_reader_ops *r,
    void *p,struct vn135_reader_scratch *scratch)
{
    if(s->access_kind!=0 && s->access_kind!=3 &&
       !(s->access_kind==4 && !s->skip_initial_read))return -1;
    s->state=1;s->started_at=r->temperature->now(p);
    if(vn135_temperature_read_135(s,c,r,p,scratch)){s->state=3;return -1;}
    s->state=2;return 0;
}
#endif
