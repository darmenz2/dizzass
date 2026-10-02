/* SPDX-License-Identifier: GPL-3.0-only
 * Original chip1368.c e35c0/f3354 ordinary ANALOG_MUX_CTRL method.
 * Isolated offline translation unit; not the original vendor filename.
 */
#ifdef VN135_BM1368_ANALOG_MUX_135
#include "integration/bm1368_analog_mux_135.h"

int32_t vn135_bm1368_set_analog_mux_135(
    struct vn135_bm1368_frequency_device *device, uint32_t input,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_analog_mux_log_135 *log)
{
    const uint32_t value = vn135_bm1398_analog_mux_word(input);
    if (vn135_bm1368_write_register_135(device, 1, NULL, 0x54, value,
            writer, write_context) == 0)
        return 0;
    const struct vn135_bm1368_analog_mux_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d - failed to set ANALOG_MUX_CTRL", 425, 1,
        device->index + UINT32_C(1)
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif
