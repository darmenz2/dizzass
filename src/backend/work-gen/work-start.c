/* SPDX-License-Identifier: GPL-3.0-only
 * Original c3b54, supplied VNish 1.3.5. External effects stay callbacks. */
#include "integration/work_start_135.h"
#include <stddef.h>

static void start_log(const struct vn135_work_start_ops *ops, void *context,
                      uint32_t line, uint32_t message)
{
    ops->log(context, 0x5e9659u, 0x5e962eu, 0x5e9660u, line, 1u, message);
}

int32_t vn135_work_start_135(const struct vn135_work_start_view *view,
    const struct vn135_work_start_ops *ops, void *context)
{
    uint32_t attribute = view->attribute_initial;
    (void)ops->attribute(context, 0x5a50e8u, &attribute, 0u);
    (void)ops->attribute(context, 0x5a50f8u, &attribute, 1u);
    (void)ops->initialize(context, 0x5a60dcu, 0x633af0u, NULL);
    (void)ops->initialize(context, 0x5a4a08u, 0x633b08u, &attribute);
    (void)ops->initialize(context, 0x5a60dcu, 0x633ba8u, NULL);
    (void)ops->initialize(context, 0x5a4a08u, 0x633bc0u, &attribute);
    (void)ops->attribute(context, 0x5a50e0u, &attribute, 0u);
    if (ops->create(context, 0x1060u, view->thread_1060, 0u, 0xc4054u, view->backend)) {
        start_log(ops, context, 0x31du, 0x5e96d3u);
        return -1;
    }
    if (ops->create(context, 0x1068u, view->thread_1068, 0u, *view->producer_entry, view->backend)) {
        start_log(ops, context, 0x308u, 0x5e9758u);
        start_log(ops, context, 0x322u, 0x5e96fdu);
        return -1;
    }
    if (ops->create(context, 0x1058u, view->thread_1058, 0u, 0xc4b18u, view->backend)) {
        start_log(ops, context, 0x291u, 0x5e971du);
        start_log(ops, context, 0x327u, 0x5e971du);
        return -1;
    }
    return 0;
}
