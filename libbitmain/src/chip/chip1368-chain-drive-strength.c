/* SPDX-License-Identifier: GPL-3.0-only
 * Original chip1368.c e3a1c/f34fc ordinary chain drive-strength method.
 * Separate offline translation unit, not original vendor filename.
 */
#ifdef VN135_BM1368_CHAIN_DRIVE_STRENGTH_135
#include "integration/bm1368_chain_drive_strength_135.h"

int32_t vn135_bm1368_chain_drive_strength_cache_135(void *context, int32_t chain,
    uint32_t reg, uint32_t *output)
{
    return vn135_reg_cache_get_chain(context, chain, reg, output);
}

static int32_t signed_index_135(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

int32_t vn135_bm1368_set_chain_drive_strength_135(
    struct vn135_bm1368_frequency_device *device, uint32_t input,
    const struct vn135_bm1368_chain_drive_strength_reader_135 *reader,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_drive_strength_log_135 *log)
{
    uint32_t value = 0;
    if (reader->read_cached(reader->context, signed_index_135(device->index),
            0x58, &value) != 0) {
        const struct vn135_bm1368_drive_strength_diagnostic_135 diagnostic = {
            "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
            "Failed to read cached driver strenght register", 635, 1, 0, 0
        };
        log->emit(log->context, &diagnostic);
        return -1;
    }
    value = (value & ~UINT32_C(0xf000)) | ((input & 15u) << 12);
    if (vn135_bm1368_write_register_135(device, 1, NULL, 0x58, value,
            writer, write_context) == 0)
        return 0;
    const struct vn135_bm1368_drive_strength_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        "chain#%d - failed to config drive strength", 645, 1, 1,
        device->index + UINT32_C(1)
    };
    log->emit(log->context, &diagnostic);
    return -1;
}
#endif
