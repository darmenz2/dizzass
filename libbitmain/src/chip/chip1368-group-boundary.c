/* SPDX-License-Identifier: GPL-3.0-only
 * cgminer e4690..e47a0 belongs to original chip/chip1368.c.
 * Separate opt-in TU, like the existing register-write/frequency projections;
 * this filename is an integration split, not a recovered vendor filename.
 */
#ifdef VN135_BM1368_GROUP_BOUNDARY_135
#include "integration/bm1368_group_boundary_135.h"

int32_t vn135_bm1368_set_uart_relay_135(
    struct vn135_bm1368_frequency_device *device,
    const vn135_chip_reference *chip, uint32_t setting,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_relay_log_135 *log)
{
    const uint32_t value = UINT32_C(3) | (setting << 16);
    if (vn135_bm1368_write_register_135(device, 0, chip, 0x2c, value,
            writer, write_context) == 0)
        return 0;
    const struct vn135_bm1368_relay_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d chip#%d - failed to config UART relay", 721, 1,
        device->index + UINT32_C(1),
        (uint32_t)chip->cache_index + UINT32_C(1)
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif
