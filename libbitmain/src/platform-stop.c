/* Original fe218 and selected platform stop hooks, isolated offline unit.
 * The project filename is not a recovered vendor source path. */
#ifdef VN135_PLATFORM_STOP_135
#include "integration/platform_stop_135.h"

void vn135_platform_stop_dispatch_135(const struct vn135_platform_stop_slot *slot)
{
    slot->invoke(slot->context);
}

void vn135_platform_stop_noop_135(void *context)
{
    (void)context;
}

void vn135_platform_stop_xil_135(void *context)
{
    const struct vn135_xil_stop_binding *binding = context;
    const struct vn135_xil_stop_ops *ops;
    void *opaque;
    uint32_t word;
    if (*binding->skip_654b22 != 0)
        return;
    ops = binding->ops;
    opaque = binding->context;
    word = ops->read_register(opaque, 27u);
    (void)ops->write_register(opaque, 27u, word & ~UINT32_C(0x00400000));
    word = ops->read_flags(opaque);
    (void)ops->write_flags(opaque, word & ~UINT32_C(0x00000040));
}
#endif
