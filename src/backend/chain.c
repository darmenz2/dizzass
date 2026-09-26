/* Selected original /tmp/build/src/backend/chain.c, VNishNet 1.3.5.
 * Source path verified at the logging call sites; not the entire driver. */
#include "integration/thermal_routes_135.h"
#include <string.h>
static void note(vn135_route_log fn,void *p,enum vn135_route_log_source src,
    uint32_t line,const uint32_t *a,size_t n)
{ if(fn)fn(p,src,line,a,n); }
int vn135_chain_auxiliary_stop_135(struct vn135_route_chain *c,
    const struct vn135_chain_stop_ops *o,void *p,uint8_t rx[2])
{
    static const uint8_t tx[7]={0x55,0xaa,5,0x15,0,0,0x1a};
    uint32_t attempt,args[4];
    if(!c->auxiliary_enabled)return 0;
    for(attempt=1;attempt<=3;++attempt){
        (void)o->exchange(p,c->index,0x20u|(c->index&7u),tx,7,rx,2);
        if(rx[0]==0x15 && rx[1]==1){c->auxiliary_enabled=0;return 0;}
        args[0]=c->index+1u;args[1]=attempt;args[2]=rx[0];args[3]=rx[1];
        note(o->log,p,VN135_ROUTE_AUX_STOP,395,args,4);
        (void)o->delay_ms(p,0x10ef3c,500);
    }
    return -1;
}
int32_t vn135_chain_stop_135(struct vn135_route_chain *c,const char *reason,
    const struct vn135_chain_stop_ops *o,void *p,uint8_t rx[2])
{
    int32_t i;size_t n;uint32_t arg;
    (void)o->reset_line(p,c->index,1);
    (void)o->delay_ms(p,0x10ed2c,100);
    if(c->extra_stop_enabled && c->present){
        arg=c->index+1u;note(o->log,p,VN135_ROUTE_CHAIN_STOP,1840,&arg,1);
        if(vn135_chain_auxiliary_stop_135(c,o,p,rx)){
            arg=c->index+1u;note(o->log,p,VN135_ROUTE_CHAIN_STOP,1843,&arg,1);
        }
    }
    (void)o->indicator(p,0);(void)o->lock(p,c);
    memset(c->cleared_words,0,sizeof c->cleared_words);c->auxiliary_enabled=0;
    memset(c->statistics,0,sizeof c->statistics);c->state=3;
    for(i=0;i<c->chip_count;++i){
        c->chips[i].temperature=0.0;c->chips[i].valid=0;c->chips[i].word_08=0;
        memset(c->chips[i].statistics,0,sizeof c->chips[i].statistics);
    }
    c->local_valid=0;c->remote_valid=0;
    n=strlen(reason);if(n>511)n=511;
    memcpy(c->reason,reason,n);c->reason[n]='\0';
    return o->unlock(p,c);
}
