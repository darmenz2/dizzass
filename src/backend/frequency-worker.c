/* Extracted from original src/backend/base.c, entry 65fcc..66210.
 * Kept as an isolated translation unit; not linked into production cgminer. */
#ifdef VN135_FREQUENCY_WORKER_135
#include "integration/frequency_worker_135.h"
#include <stdint.h>

static int32_t worker_signed_word(uint32_t word)
{
    return word<=INT32_MAX ? (int32_t)word : (int32_t)((int64_t)word-INT64_C(4294967296));
}

enum vn135_frequency_worker_flow vn135_frequency_fall_worker_135(
    const struct vn135_frequency_fall_argument *argument,
    const struct vn135_frequency_worker_view *view,
    const struct vn135_frequency_worker_ops *ops,void *opaque)
{
    struct vn135_frequency_fall_state *backend=argument->backend;
    struct vn135_general_chain *chain=argument->chain;
    struct vn135_frequency_worker_control *control=view->control;
    int32_t target=backend->config->target_18;
    int32_t frequency=worker_signed_word(chain->thermal.cleared_words[0]);
    uint32_t handle;
    (void)ops->call(opaque,0x5a6b2cu,1,0);
    (void)ops->call(opaque,0x593af8u,15,0);
    /* Same 56fcc predicate used by the existing general/handler projections. */
    if(!chain->thermal.present || (uint32_t)(chain->thermal.state-3u)<=2u)
        goto thread_exit;
    frequency=(frequency/50)*50; /* Signed truncation toward zero, not floor. */
    if(frequency<target)goto thread_exit;
    for(;;){
        if(ops->set_frequency(opaque,chain,control->word_20,control->word_10,
                              (double)frequency)){
            if(ops->log)ops->log(opaque,4444,chain->thermal.index+1u,frequency);
            (void)ops->stop_chain(opaque,&chain->thermal,"Failed to set minimum frequency");
            if(vn135_monitor_chain_decision_135(view->handlers,ops->decisions,opaque)){
                (void)ops->call(opaque,0x49c98u,2010,0);
                if(ops->create_shutdown(opaque,&handle,0x72ba4u,backend)){
                    if(ops->log)ops->log(opaque,6483,0,0);
                    (void)ops->call(opaque,0x6b778u,0,0);
                }
            }
            goto thread_exit;
        }
        (void)ops->call(opaque,0x10ef3cu,100,0);
        if(frequency==target)break;
        frequency=worker_signed_word((uint32_t)frequency-100u);
        if(frequency<=target)frequency=target;
    }
thread_exit:
    (void)ops->call(opaque,0x5a52d0u,0,0);
    return VN135_FREQUENCY_THREAD_EXIT;
}
#endif
