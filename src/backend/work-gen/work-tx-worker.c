/* SPDX-License-Identifier: GPL-3.0-only
 * VNish 1.3.5 c4b18, with 10f544 restricted to the caller's int32 interval.
 * Isolated field projection; not linked into production. */
#include "integration/work_tx_worker_135.h"
#include "integration/work_tx88.h"
#include <string.h>

void vn135_tx_add_interval_135(struct vn135_tx_time *time,int32_t milliseconds)
{
    int64_t interval=milliseconds;
    uint32_t ns=time->nanoseconds_bits+
        (uint32_t)((interval*INT64_C(1000000))%INT64_C(1000000000));
    time->seconds_bits+=(uint64_t)(interval/1000);
    if(ns<UINT32_C(0x80000000) && ns>=UINT32_C(1000000000)){
        ++time->seconds_bits;
        ns-=UINT32_C(1000000000);
    }else if(ns>=UINT32_C(0x80000000)){
        --time->seconds_bits;
        ns+=UINT32_C(1000000000);
    }
    time->nanoseconds_bits=ns;
}

enum vn135_tx_worker_flow vn135_work_tx_worker_135(
    const struct vn135_tx_worker_view *view,
    const struct vn135_tx_worker_ops *ops,void *opaque)
{
    struct vn135_tx_backend *backend=view->backend;
    struct vn135_tx_ring *ring=view->ring;
    struct vn135_tx_slots *slots=view->slots;
    int32_t count=ops->call(opaque,0xfe668u,0,0);
    struct vn135_tx_time time={0,0,0};
    (void)ops->call(opaque,0x5a6b2cu,1,0);
    (void)ops->call(opaque,0x593af8u,15,0x5e977du);
    backend->running=1;
    do{
        int32_t i,interval;
        (void)ops->clock(opaque,1,&time);
        interval=ops->call(opaque,0xfedc4u,0,0);
        vn135_tx_add_interval_135(&time,interval);
        (void)ops->call(opaque,0x5a6108u,0x633ba8u,0);
        (void)ops->wait(opaque,0x633bc0u,0x633ba8u,&time);
        (void)ops->call(opaque,0x5a66c4u,0x633ba8u,0);
        for(i=0;i<count;++i){
            struct vn135_tx_chain *chain=&backend->chains[i];
            void *uart=chain->uart;
            uint32_t head,tail,slot,next;
            uint16_t crc;
            uint8_t frame[88]={0};
            vn135_work_job_snapshot *row;
            if(!chain->state->present || (uint32_t)(chain->state->state-3u)<=2u)
                continue;
            (void)ops->call(opaque,0x5a6108u,0x633bf0u,0);
            head=ring->head;
            tail=ring->tail;
            (void)ops->call(opaque,0x5a66c4u,0x633bf0u,0);
            if(head==tail)break;
            (void)ops->call(opaque,0x5a6108u,0x633bf0u,0);
            tail=ring->tail;
            (void)ops->call(opaque,0x5a66c4u,0x633bf0u,0);
            if((tail>>8)>2u)break;
            slot=slots->next;
            row=&slots->rows[slot];
            memcpy(row,&ring->rows[tail],sizeof(*row));
            next=slots->next+1u;
            slots->next=next>31u ? 0u : next;
            (void)ops->call(opaque,0x5a6108u,0x633bf0u,0);
            next=ring->tail+1u;
            ring->tail=(next>>8)>2u ? 0u : next;
            (void)ops->call(opaque,0x5a66c4u,0x633bf0u,0);
            frame[0]=0x55;frame[1]=0xaa;frame[2]=0x21;frame[3]=0x36;
            frame[4]=(uint8_t)(slot<<3);frame[5]=1;
            memcpy(frame+10,row->bytes+64,12);
            memcpy(frame+22,row->bytes,64);
            /* Reuse recovered CRC. Source computes it twice over the same
             * 84 bytes; no state change or callback occurs between them. */
            (void)dizzass_tx88_crc16(frame+2,84,UINT16_C(0xffff),&crc);
            frame[87]=(uint8_t)crc;
            (void)dizzass_tx88_crc16(frame+2,84,UINT16_C(0xffff),&crc);
            frame[86]=(uint8_t)(crc>>8);
            (void)ops->write(opaque,uart,frame,sizeof(frame));
        }
    }while(backend->running);
    (void)ops->call(opaque,0x5a52d0u,0,0);
    return VN135_TX_THREAD_EXIT;
}
