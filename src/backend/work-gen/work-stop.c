/* SPDX-License-Identifier: GPL-3.0-only
 * Original c3e18 stop coordinator, supplied VNish 1.3.5. */
#include "integration/work_stop_135.h"
#include <stddef.h>

static void stop_thread(struct vn135_shutdown_thread *thread,
    const struct vn135_work_stop_ops *ops, void *context)
{
    if (thread->running) {
        uint32_t handle = thread->handle;
        thread->running = 0;
        (void)ops->cancel(context, handle);
        (void)ops->join(context, thread->handle, NULL);
    }
}

int32_t vn135_work_stop_135(struct vn135_work_stop_view *view,
    const struct vn135_work_stop_ops *ops, void *context)
{
    int32_t count = ops->chain_count(context);
    stop_thread(view->producer, ops, context);
    stop_thread(view->receiver, ops, context);
    stop_thread(view->sender, ops, context);
    (void)ops->destroy(context, 0x5a4954u, 0x633bc0u);
    (void)ops->destroy(context, 0x5a60b8u, 0x633ba8u);
    (void)ops->destroy(context, 0x5a4954u, 0x633b08u);
    (void)ops->destroy(context, 0x5a60b8u, 0x633af0u);
    if (count > 0) {
        for (uint32_t i = 0; i < (uint32_t)count; ++i) {
            const struct vn135_work_stop_chain *chain = &view->chains[i];
            if (*chain->enabled_318)
                (void)ops->chain(context, view->chain_method, chain->object);
        }
    }
    return 0;
}
