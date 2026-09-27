/* SPDX-License-Identifier: GPL-3.0-only
 * Original c39a8 / d2144, supplied VNish 1.3.5. Offline field projection. */
#include "integration/chain_work_stop_135.h"
#include <stddef.h>

static void clear_allocation(void **slot,
    const struct vn135_chain_work_stop_ops *ops, void *context)
{
    void *value = *slot;
    if (value) {
        ops->release(context, value);
        *slot = NULL;
    }
}

void vn135_chain_work_stop_135(struct vn135_chain_work_stop_view *view,
    const struct vn135_chain_work_stop_ops *ops, void *context)
{
    int32_t index = *view->index;
    if (index >= 0) {
        int32_t count = ops->count(context);
        if (index < count) {
            if (!view->worker->running)
                return;
            (void)ops->mutex(context, 0x5a6108u, view->queue_mutex);
            *view->head = 0;
            *view->tail = 0;
            (void)ops->mutex(context, 0x5a66c4u, view->queue_mutex);
            uint32_t handle = view->worker->handle;
            view->worker->running = 0;
            (void)ops->cancel(context, handle);
            (void)ops->join(context, view->worker->handle, NULL);
            (void)ops->mutex(context, 0x5a6108u, view->chain_mutex);
            clear_allocation(view->allocation, ops, context);
            (void)ops->mutex(context, 0x5a66c4u, view->chain_mutex);
            ops->uart_destroy(context, *view->uart_method, view->uart);
            return;
        }
        index = *view->index;
    }
    ops->log(context, 0x5e9659u, 0x5e962eu, 0x5e9660u,
        0x2dau, 1u, 0x5e966bu, (uint32_t)index + 1u);
}
