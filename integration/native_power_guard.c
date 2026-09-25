#include "config.h"
#include "miner.h"
#include "integration/native_power_guard.h"
#include "integration/native_tx_channel.h"
#include <pthread.h>
#include <stdlib.h>
struct native_shutdown {
    struct dizzass_tx_channel *const *channels;
    dizzass_power_gpio_fn write;
    void *context;
};
static int stop_channel(void *ptr,uint32_t chain)
{
    struct native_shutdown *s=ptr;
    return s->channels[chain]?dizzass_tx_channel_stop(s->channels[chain]):0;
}
static int write_pin(void *ptr,const struct dizzass_gpio_request *r)
{
    struct native_shutdown *s=ptr;
    return s->write?s->write(s->context,r):DIZZASS_POWER_NOT_READY;
}
int dizzass_native_aml_quench(struct dizzass_tx_channel *const channels[3],
    dizzass_power_gpio_fn gpio_write,void *context,struct dizzass_shutdown_receipt *out)
{
    struct native_shutdown state={channels,gpio_write,context};
    struct dizzass_shutdown_ops ops={&state,stop_channel,write_pin};
    int old,rc;
    if(!channels||!out) return DIZZASS_POWER_INVALID;
    /* Cancellation cannot leave us between software stop and the cutoff
     * requests. A failing request does not skip remaining hardware actions.
     */
    if(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old)) abort();
    rc=dizzass_aml_quench(2,&ops,out);
    if(pthread_setcancelstate(old,NULL)) abort();
    return rc;
}
int dizzass_native_aml_check(struct dizzass_tx_channel *const channels[3],
    const struct dizzass_thermal_sample *sample,const struct dizzass_thermal_limits *limits,
    uint64_t epoch,uint64_t now,dizzass_power_gpio_fn write,void *context,
    struct dizzass_native_trip_receipt *out)
{
    struct dizzass_native_trip_receipt r={0}; int rc;
    if(!channels||!out) return DIZZASS_POWER_INVALID;
    r.reason=dizzass_thermal_sample_check(sample,limits,epoch,now);
    if(!r.reason) {*out=r;return 0;}
    rc=dizzass_native_aml_quench(channels,write,context,&r.shutdown);
    *out=r;return rc?rc:(r.reason<0?r.reason:1);
}
