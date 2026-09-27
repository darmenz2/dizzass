/* SPDX-License-Identifier: GPL-3.0-only
 * c33d0 from VNish 1.3.5 /tmp/build/src/backend/work-gen/work-gen.c.
 * Source/control-flow proof: integration/evidence/chain_work_start_135.json.
 * Comparison only; native cgminer and existing FIFO/UART bodies are unchanged.
 */
#include "integration/chain_work_start_135.h"

static void diagnostic(const struct vn135_chain_work_start_ops *o,void *ctx,
                       uint32_t line,uint32_t message,uintptr_t argument)
{
    o->log(ctx,0x5e9659,0x5e962e,0x5e9660,line,1,message,argument);
}

int32_t vn135_chain_work_start_135(const struct vn135_chain_work_start_view *v,
    const struct vn135_chain_work_start_ops *o,void *ctx)
{
    int32_t count=o->count(ctx);
    int32_t index=*v->index;
    if (index<0 || index>=count) {
        diagnostic(o,ctx,0x2b8,0x5e966b,(uint32_t)index+UINT32_C(1));
        return -1;
    }
    if (v->worker->running!=0) return 0;
    (void)o->mutex_init(ctx,v->mutex,0);
    (void)o->queue_init(ctx,v->queue,0x800,1);
    void *path=o->path(ctx,*v->path_method,*v->index);
    *v->device_index=*v->index;
    if (o->open(ctx,*v->open_method,v->uart,path)!=0) {
        diagnostic(o,ctx,0x2c8,0x5e9682,(uintptr_t)path);
        return -1;
    }
    if (o->create(ctx,&v->worker->handle,0,0xc36e8,v->chain)!=0) {
        diagnostic(o,ctx,0x2d0,0x5e96a7,(uint32_t)*v->index+UINT32_C(1));
        return -1;
    }
    return 0;
}
