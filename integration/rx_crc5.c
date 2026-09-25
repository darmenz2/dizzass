#include "integration/rx_crc5.h"
#include "xminer/recovery/chip1398.h"
int dizzass_bm1368_reply_crc5(uint32_t chip, uint32_t variant,
    const uint8_t *payload, size_t size)
{
    uint8_t remainder;
    if (!payload || size != 9) return DIZZASS_RX_CRC_INVALID;
    if (chip != 4 || variant != 2) return DIZZASS_RX_CRC_UNSUPPORTED;
    if (vn135_crc5_bits(payload, size, 72, &remainder))
        return DIZZASS_RX_CRC_INVALID;
    return remainder ? DIZZASS_RX_CRC_MISMATCH : DIZZASS_RX_CRC_OK;
}
