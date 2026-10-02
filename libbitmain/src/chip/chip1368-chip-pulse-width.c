/* SPDX-License-Identifier: GPL-3.0-only
 * Original module /tmp/build/libbitmain/src/chip/chip1368.c, e33e0..e34b8.
 * Separate offline translation unit; not the original vendor filename.
 */
#ifdef VN135_BM1368_CHIP_PULSE_WIDTH_135
#include "integration/bm1368_chip_pulse_width_135.h"

int32_t vn135_bm1368_set_chip_pulse_width_135(
    struct vn135_bm1368_frequency_device *device,
    const vn135_chip_reference *chip, uint32_t pulse_width,
    uint32_t clock_delay, const struct vn135_bm1368_pulse_ops *ops,
    void *opaque)
{
    const uint32_t value = UINT32_C(0x80008000) |
        ((pulse_width & 3u) << 6) | ((clock_delay & 7u) << 3);
    if (ops->write_config(opaque, device, 0, chip, 0x3c, value) == 0)
        return 0;
    ops->log(opaque, 387, device->index + UINT32_C(1));
    ops->log(opaque, 538, device->index + UINT32_C(1));
    return -1;
}
#endif
