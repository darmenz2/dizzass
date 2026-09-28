/* SPDX-License-Identifier: GPL-3.0-only
 * Original VNish 1.3.5 c4054, isolated from production. */
#include "integration/work_rx_worker_135.h"

int vn135_work_rx_worker_135(const struct vn135_rx_worker_view *view,
    const struct vn135_rx_worker_ops *ops,void *opaque)
{
    struct vn135_rx_backend *backend=view->backend;
    uint8_t header=view->initial_scratch.header_byte;
    uint32_t old_cancel=view->initial_scratch.cancel_old;
    uint32_t count=ops->scalar(opaque,0xfe668u);
    uint32_t first_selector=ops->scalar(opaque,0xfdfbcu);
    uint32_t board=ops->scalar(opaque,0xfdfacu);
    uint32_t initial_mode=ops->scalar(opaque,0xfe0b0u);
    uint32_t slot_selector=ops->scalar(opaque,0xfdfbcu);
    vn135_work_rx_policy initial;
    vn135_nonce_attribution attribution={opaque,ops->chip,ops->core};
    (void)vn135_work_rx_policy_init(&initial,board,first_selector,initial_mode);
    (void)ops->cancel(opaque,1,NULL);
    (void)ops->name(opaque,15,0x5e9749u);
    backend->running=1;
    for(;;){
        uint32_t i;
        int progress=0;
        for(i=0;count<UINT32_C(0x80000000) && i<count;++i){
            struct vn135_rx_chain *chain=&backend->chains[i];
            uint8_t frame[VN135_WORK_RX_MAX_FRAME]={0xaa,0x55};
            uint32_t mode;
            vn135_work_rx_policy policy;
            vn135_work_rx_message message;
            if(!chain->enabled)continue;
            mode=ops->scalar(opaque,0xfe0b0u);
            (void)ops->sync(opaque,0x5a6108u,chain->mutex);
            if(ops->available(opaque,chain->fifo)<initial.frame_size){
                (void)ops->sync(opaque,0x5a66c4u,chain->mutex);
                continue;
            }
            (void)ops->byte(opaque,chain->fifo,&header);
            if(header!=0xaa)goto consumed;
            (void)ops->byte(opaque,chain->fifo,&header);
            if(header!=0x55)goto consumed;
            (void)vn135_work_rx_policy_init(&policy,board,first_selector,mode);
            (void)ops->payload(opaque,chain->fifo,frame+2,policy.payload_size);
            (void)vn135_work_rx_next(&policy,chain->chain->index,frame,policy.frame_size,&message);
            if(message.kind==VN135_RX_NONCE_RAW){
                uint32_t slot;
                vn135_work_nonce_result result;
                (void)vn135_work_rx_job_slot(slot_selector,initial.variant,
                    message.payload,message.payload_size,&slot);
                (void)vn135_work_nonce_prepare(slot_selector,initial.variant,
                    message.chain_id,message.payload,message.payload_size,
                    &view->slots[slot],&attribution,&result);
                (void)ops->nonce(opaque,&result.candidate);
            }else{
                uint32_t filtered=ops->scalar(opaque,0xd2a84u);
                if(message.register_address!=filtered){
                    message.kind=VN135_RX_REGISTER;
                    (void)ops->register_reply(opaque,&message);
                }
            }
consumed:
            (void)ops->sync(opaque,0x5a66c4u,chain->mutex);
            progress=1;
        }
        if(!progress){
            (void)ops->sync(opaque,0x5a6108u,(void *)(uintptr_t)0x653410u);
            (void)ops->cancel(opaque,0,&old_cancel);
            (void)ops->wait(opaque,0x653428u,0x653410u);
            (void)ops->cancel(opaque,old_cancel,NULL);
            (void)ops->sync(opaque,0x5a66c4u,(void *)(uintptr_t)0x653410u);
        }
        if(!backend->running)return 0;
    }
}
