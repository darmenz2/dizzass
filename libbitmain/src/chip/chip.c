/* SPDX-License-Identifier: GPL-3.0-only
 * Original /tmp/build/libbitmain/src/chip/chip.c, common method d253c.
 * Bounded host projection; no production driver or default I/O operations. */
#ifdef VN135_COMMON_READ_REGISTER_135
#include "integration/common_read_register_135.h"
#include "integration/bm1368_control.h"

int32_t vn135_common_read_register_135(
    const struct vn135_common_read_device_135 *device, uint32_t mode,
    const vn135_chip_reference *chip, uint32_t reg,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_common_read_log_135 *log)
{
    uint8_t frame[7];
    size_t written = 0;
    if (dizzass_bm1368_command_encode(DIZZASS_BM1368_READ_REGISTER, mode & 1u,
            chip ? chip->wire_address & 255u : 0u, reg & 255u, 0,
            frame, sizeof frame, &written) || written != sizeof frame)
        return -1; /* Unreachable for these bounded arguments to the pinned encoder. */
    if (vn135_transport_send_135(transport, device->identity, frame + 2, 5) == 0)
        return 0;
    const struct vn135_common_read_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip.c", "[redacted]",
        "chain#%d - failed to send GET_STATUS command", 103, 1,
        *device->index + UINT32_C(1)
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif
