/* Original 1.3.5 entries: chip lookup, gated acceptance and aggregation.
 * Source filenames for these bodies are not yet established. This support
 * path is explicit, not a purported vendor filename. See evidence and tests.
 * All external effects require callbacks. No production linking. */
#include "integration/thermal_routes_135.h"
#include <limits.h>
#include <string.h>
static int32_t as_signed(uint32_t u)
{ return u<=INT32_MAX?(int32_t)u:-1-(int32_t)(UINT32_MAX-u); }
static int32_t wrap_add(int32_t a,int32_t b)
{ return as_signed((uint32_t)a+(uint32_t)b); }
static int32_t truncate_s32(double v)
{
    if(v>=(double)INT32_MAX)return INT32_MAX;
    if(v<=(double)INT32_MIN)return INT32_MIN;
    return (int32_t)v;
}
int32_t vn135_temperature_lookup_chip_135(const struct vn135_route_chain *c,uint32_t address)
{
    int32_t i;
    for(i=0;i<c->sensor_count;++i)
        if(c->sensors[i].access_kind-1u<=1u && c->sensor_chip_addresses[i]==address)
            return i;
    return -1; /* explicit projection of the original NULL return */
}
void vn135_temperature_accept_chip_135(struct vn135_route_chain *c,int32_t index,
    int32_t local,int32_t remote,const struct vn135_reply_ops *o,void *p)
{
    if(!c->present || c->state-3u<3u || index<0 || index>=c->sensor_count)return;
    (void)vn135_temperature_accept(c->sensors+index,o->temperature,p,local,remote);
}
void vn135_temperature_aggregate_135(struct vn135_route_chain *c,
    const struct vn135_reply_ops *o,void *p)
{
    int32_t i,n=0,lo=INT32_MAX,hi=INT32_MIN,rlo=INT32_MAX,rhi=INT32_MIN;
    int32_t sum=0,rsum=0,avg=0,ravg=0;uint8_t valid;
    if(!c->present || c->state-3u<3u)return;
    for(i=0;i<c->sensor_count;++i){
        struct vn135_temperature_sensor *s=c->sensors+i;
        (void)o->temperature->lock(p,s);
        if(s->state==2){
            int32_t a=s->sample,b=s->corrected;
            ++n;sum=wrap_add(sum,a);rsum=wrap_add(rsum,b);
            if(a<lo)lo=a;
            if(a>hi)hi=a;
            if(b<rlo)rlo=b;
            if(b>rhi)rhi=b;
        }
        (void)o->temperature->unlock(p,s);
    }
    valid=(uint8_t)(n!=0);
    if(n){avg=sum/n;ravg=rsum/n;}else{lo=hi=rlo=rhi=0;}
    if(!c->suppress_chip_samples && o->chip_samples_supported(p)){
        double total=0.0;int32_t count=0,mn=INT32_MAX,mx=INT32_MIN;
        for(i=0;i<c->chip_count;++i)if(c->chips[i].valid){
            double v=c->chips[i].temperature;
            mx=truncate_s32(v<(double)mx?(double)mx:v);
            mn=truncate_s32(v>(double)mn?(double)mn:v);
            total=total+v;++count;
        }
        if(count){rlo=mn;rhi=mx;ravg=truncate_s32(total/(double)count);}
    }
    (void)o->chain_lock(p,c);
    c->local[0]=lo;c->local[1]=avg;c->local[2]=hi;
    c->remote[0]=rlo;c->remote[1]=ravg;c->remote[2]=rhi;
    c->local_valid=valid;c->remote_valid=valid;
    memset(c->local_tail,0,3);memset(c->remote_tail,0,3);
    (void)o->chain_unlock(p,c);
}
