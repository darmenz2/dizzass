/* SPDX-License-Identifier: GPL-3.0-only
 * Original source: /tmp/build/libbitmain/src/chip/chip1368.c.
 * Deliberate separately gated integration split, not a recovered filename.
 * Manual ordinary-memory control-flow projection; see the pinned evidence.
 */
#ifdef VN135_BM1368_STARTUP_REGISTERS_135
#include "integration/bm1368_startup_registers_135.h"

int32_t vn135_bm1368_startup_cache_read_135(void *cache, int32_t chain,
    uint32_t reg, uint32_t *value)
{
    return vn135_reg_cache_get_chain(cache, chain, reg, value);
}

int32_t vn135_bm1368_startup_register_write_135(void *opaque,
    struct vn135_bm1368_frequency_device *device, uint32_t broadcast,
    const vn135_chip_reference *chip, uint32_t reg, uint32_t value)
{
    const struct vn135_bm1368_startup_write_binding_135 *binding = opaque;
    return vn135_bm1368_write_register_135(device, broadcast, chip, reg, value,
        binding->writer, binding->context);
}

static int32_t startup_signed_index_135(uint32_t bits)
{
    return bits <= INT32_MAX ? (int32_t)bits :
        (int32_t)((int64_t)bits - INT64_C(4294967296));
}

static void startup_diagnostic_135(
    const struct vn135_bm1368_startup_ops_135 *ops,
    const struct vn135_bm1368_frequency_device *device,
    uint32_t line, const char *format)
{
    const struct vn135_bm1368_startup_diagnostic_135 diagnostic = {
        "driver", "/tmp/build/libbitmain/src/chip/chip1368.c", "[redacted]",
        format, line, 1, device->index + UINT32_C(1)
    };
    ops->emit(ops->log_context, &diagnostic);
}

int32_t vn135_bm1368_set_analog_mux_135(
    struct vn135_bm1368_frequency_device *device, uint32_t setting,
    const struct vn135_bm1368_startup_ops_135 *ops)
{
    const uint32_t word = setting & UINT32_C(7);
    if (ops->write_register(ops->write_context, device, 1, NULL, 0x54, word) == 0)
        return 0;
    startup_diagnostic_135(ops, device, 425,
        "chain#%d - failed to set ANALOG_MUX_CTRL");
    return -1;
}

int32_t vn135_bm1368_set_nonce_bin_overflow_135(
    struct vn135_bm1368_frequency_device *device, uint32_t setting,
    const struct vn135_bm1368_startup_ops_135 *ops)
{
    const uint32_t word = (setting ^ UINT32_C(1)) | UINT32_C(0x80008dee);
    if (ops->write_register(ops->write_context, device, 1, NULL, 0x3c, word) == 0)
        return 0;
    startup_diagnostic_135(ops, device, 387,
        "chain#%d - failed to send core command");
    startup_diagnostic_135(ops, device, 593,
        "chain#%d - failed to set NONCE_BIN_OVERFLOW_CTRL");
    return -1;
}

int32_t vn135_bm1368_write_reg68_pattern_135(
    struct vn135_bm1368_frequency_device *device,
    const struct vn135_bm1368_startup_ops_135 *ops)
{
    return ops->write_register(ops->write_context, device, 1, NULL,
        0x68, UINT32_C(0x5aa55aa5));
}

int32_t vn135_bm1368_update_soft_reset_misc_135(
    struct vn135_bm1368_frequency_device *device, uint32_t mode,
    const struct vn135_bm1368_startup_ops_135 *ops)
{
    uint32_t soft = 0, misc = 0;
    if (ops->read_chain(ops->read_context, startup_signed_index_135(device->index),
            0xa8, &soft) != 0)
        return -1;
    if (ops->read_chain(ops->read_context, startup_signed_index_135(device->index),
            0x18, &misc) != 0)
        return -1;
    if (mode != 0) {
        soft |= UINT32_C(0x10f);
        misc &= ~UINT32_C(0x00f00000);
    } else {
        soft &= ~UINT32_C(0xf0);
        misc |= UINT32_C(0xff0f0000);
    }
    if (ops->write_register(ops->write_context, device, 1, NULL, 0xa8, soft) != 0)
        return -1;
    if (ops->write_register(ops->write_context, device, 1, NULL, 0x18, misc) != 0)
        return -1;
    return 0;
}
#endif
