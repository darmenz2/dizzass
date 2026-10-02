/* SPDX-License-Identifier: GPL-3.0-only
 * Original chip1368.c e3c04/f3618, bounded cached A8/18 transaction.
 * Separate offline translation unit; original method name remains unknown.
 */
#ifdef VN135_BM1368_REGISTER_PAIR_135
#include "integration/bm1368_register_pair_135.h"

int32_t vn135_bm1368_register_pair_cache_135(void *context, int32_t chain,
    uint32_t reg, uint32_t *output)
{
    return vn135_reg_cache_get_chain(context, chain, reg, output);
}

static int32_t signed_index_135(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

int32_t vn135_bm1368_configure_register_pair_135(
    struct vn135_bm1368_frequency_device *device, uint32_t flag,
    const struct vn135_bm1368_register_pair_reader_135 *reader,
    const struct vn135_bm1368_register_ops *writer, void *write_context)
{
    uint32_t a8, reg18;
    if (reader->read_cached(reader->context, signed_index_135(device->index),
            0xa8, &a8) != 0)
        return -1;
    if (reader->read_cached(reader->context, signed_index_135(device->index),
            0x18, &reg18) != 0)
        return -1;
    if (flag != 0) {
        a8 |= UINT32_C(0x10f);
        reg18 &= ~UINT32_C(0xf00000);
    } else {
        a8 &= ~UINT32_C(0xf0);
        reg18 |= UINT32_C(0xff0f0000);
    }
    if (vn135_bm1368_write_register_135(device, 1, NULL, 0xa8, a8,
            writer, write_context) != 0)
        return -1;
    return vn135_bm1368_write_register_135(device, 1, NULL, 0x18, reg18,
            writer, write_context) == 0 ? 0 : -1;
}
#endif
