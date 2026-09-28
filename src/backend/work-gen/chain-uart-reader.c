/* SPDX-License-Identifier: GPL-3.0-only
 * Original c36e8 in /tmp/build/src/backend/work-gen/work-gen.c, plus5b150.
 * Evidence: integration/evidence/chain_uart_reader_135.json. Offline only.
 */
#include "integration/chain_uart_reader_135.h"
#include "xminer/recovery/work_rx.h"

uint32_t vn135_chain_uart_wait_capacity_135(const struct vn135_chain_uart_reader_view *v,
    const struct vn135_chain_uart_reader_ops *o,void *ctx)
{
    for (;;) {
        (void)o->mutex(ctx,0x5a6108,v->mutex);
        uint32_t stride=*v->queue_stride;
        uint32_t capacity=stride?(*v->queue_end-*v->queue_begin)/stride:0;
        (void)o->mutex(ctx,0x5a66c4,v->mutex);
        if (capacity!=0) return capacity;
        (void)o->delay_ms(ctx,5);
    }
}

void vn135_chain_uart_reader_135(const struct vn135_chain_uart_reader_view *v,
    const struct vn135_chain_uart_reader_ops *o,void *ctx,struct vn135_chain_uart_reader_scratch *s)
{
    uint32_t model=*v->model,controller=*v->controller;
    vn135_work_rx_policy policy;
    (void)vn135_work_rx_policy_init(&policy,controller,model,*v->force_nine);
    uint32_t threshold=policy.frame_size;
    (void)o->mode(ctx,1,0);
    (void)o->format(ctx,s->name,64,0x5e973e,*v->index);
    (void)o->name(ctx,15,s->name,0,0,0);
    *v->running=1;
    do {
        uint32_t amount=vn135_chain_uart_wait_capacity_135(v,o,ctx);
        (void)o->mode(ctx,0,&s->previous_mode[0]);
        if (amount>=256) amount=256;
        int32_t received=o->read(ctx,*v->read_method,v->uart,s->bytes,amount);
        (void)o->mode(ctx,s->previous_mode[0],0);
        if (received<=0) {
            (void)o->delay_ms(ctx,5);
        } else {
            (void)o->mutex(ctx,0x5a6108,v->mutex);
            (void)o->push(ctx,v->queue,s->bytes,(uint32_t)received);
            uint32_t count=*v->queue_count;
            if (count>=threshold) {
                (void)o->mutex(ctx,0x5a6108,v->condition_mutex);
                (void)o->signal(ctx,v->condition);
                (void)o->mutex(ctx,0x5a66c4,v->condition_mutex);
            }
            (void)o->mutex(ctx,0x5a66c4,v->mutex);
        }
    } while (*v->running!=0);
    o->exit_thread(ctx,0);
}
