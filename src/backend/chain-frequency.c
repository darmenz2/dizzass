/* Original src/backend/chain.c, 57a10..57d34. Separate offline translation
 * unit in this project; not a claim about the original vendor filename. */
#ifdef VN135_CHAIN_FREQUENCY_135
#include "integration/chain_frequency_135.h"
#include <limits.h>
#include <string.h>

_Static_assert(sizeof(double)==8,"binary64 field projection required");
static int32_t frequency_signed(uint32_t x)
{
    return x<=INT32_MAX ? (int32_t)x : (int32_t)((int64_t)x-INT64_C(4294967296));
}
static int32_t frequency_truncate(double x)
{
    /* Finite-domain VCVT.s32.f64: truncate with signed saturation. */
    if(x>=2147483647.0)return INT32_MAX;
    if(x<=-2147483648.0)return INT32_MIN;
    return (int32_t)x;
}
int32_t vn135_chain_set_frequency_135(struct vn135_chain_frequency_view *view,
    uint32_t word_20,uint32_t word_10,double frequency,
    const struct vn135_chain_frequency_ops *ops,void *opaque)
{
    struct vn135_general_chain *chain=view->chain;
    struct vn135_chain_frequency_methods *methods=view->methods;
    struct vn135_route_chain *c=&chain->thermal;
    int32_t count,i,minimum=0,maximum=0;
    double sum=0.0,mean=0.0;
    uint64_t bits;
    if(!c->present || (uint32_t)(c->state-3u)<3u)return 0;
    if(methods->set_all(opaque,chain,frequency)){
        if(ops->log)ops->log(opaque,1060,c->index+1u,frequency);
        return -1;
    }
    (void)ops->lock(opaque,chain);
    count=frequency_signed(chain->detected_8c);
    if(count>0){
        int32_t cached=frequency_truncate(frequency);
        for(i=0;i<count;++i)c->chips[i].word_08=(uint32_t)cached;
        minimum=maximum=frequency_signed(c->chips[0].word_08);
        sum=(double)minimum;
        for(i=1;i<count;++i){
            int32_t value=frequency_signed(c->chips[i].word_08);
            if(value<minimum)minimum=value;
            if(value>maximum)maximum=value;
            sum+=(double)value;
        }
        mean=sum/(double)count;
    }
    c->cleared_words[0]=(uint32_t)minimum;
    c->cleared_words[3]=(uint32_t)maximum;
    memcpy(&bits,&mean,sizeof bits);
    c->cleared_words[1]=(uint32_t)bits;
    c->cleared_words[2]=(uint32_t)(bits>>32);
    (void)ops->unlock(opaque,chain);
    /* The method owner is captured BEFORE platform(), its slot AFTER it. */
    methods=view->methods;
    if(ops->platform(opaque)!=4u)return 0;
    if(frequency_signed(c->cleared_words[0])<450)word_20=4u;
    if(methods->pulse_width(opaque,chain,word_10,word_20,1u)){
        if(ops->log)ops->log(opaque,1074,c->index+1u,0.0);
        return -1;
    }
    return 0;
}
#endif
