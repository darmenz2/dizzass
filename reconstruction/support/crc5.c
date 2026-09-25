/* SPDX-License-Identifier: GPL-3.0-only
 * Helper recovered from 0x000f7f10..0x000f803c.
 * Original source filename for this helper is UNKNOWN; this is a new path.
 * Polynomial x^5+x^2+1, initial register 0x1f, MSB-first, no final XOR.
 */
#include "xminer/recovery/chip1398.h"
int vn135_crc5_bits(const uint8_t *data, size_t bytes, size_t bits, uint8_t *out)
{
    uint8_t crc = UINT8_C(0x1f);
    if (out == NULL || (bits != 0 && data == NULL))
        return VN135_INVALID;
    if (bits / 8u > bytes || (bits / 8u == bytes && bits % 8u != 0))
        return VN135_INVALID;
    for (size_t i = 0; i < bits; ++i) {
        unsigned bit = (data[i / 8u] >> (7u - (i % 8u))) & 1u;
        unsigned feedback = ((unsigned)crc >> 4) ^ bit;
        crc = (uint8_t)(((unsigned)crc << 1) & 0x1fu);
        if (feedback & 1u)
            crc ^= UINT8_C(5);
    }
    *out = crc;
    return VN135_OK;
}
