/* Bounded protocol reconstruction, GPL-3.0-or-later.
 * Original evidence: c29b4..c2a6c (prefix byte ordering),
 * c4dfc..c4ea8 (frame through UART-call boundary), f7df4 (CRC16).
 * Native work/Stratum/SHA/target logic remains in upstream cgminer.
 */
#include "integration/work_tx88.h"
#include <string.h>

int dizzass_tx88_crc16(const uint8_t *data, size_t size, uint16_t initial,
    uint16_t *out)
{
    uint16_t crc = initial;
    size_t i;
    unsigned bit;
    if (!out || (!data && size))
        return DIZZASS_TX88_INVALID;
    for (i = 0; i < size; ++i) {
        crc ^= (uint16_t)((uint16_t)data[i] << 8);
        for (bit = 0; bit < 8; ++bit)
            crc = (uint16_t)(((uint32_t)crc << 1) ^
                ((crc & 0x8000u) ? 0x1021u : 0u));
    }
    *out = crc;
    return DIZZASS_TX88_OK;
}

int dizzass_tx88_encode_words(const uint8_t *header_words, size_t header_size,
    uint32_t slot, uint8_t *out, size_t capacity)
{
    uint8_t frame[DIZZASS_TX88_SIZE] = {0};
    uint16_t crc;
    size_t i;
    if (!header_words || !out || header_size != DIZZASS_TX88_HEADER_SIZE || slot > 31u)
        return DIZZASS_TX88_INVALID;
    if (capacity < sizeof(frame))
        return DIZZASS_TX88_CAPACITY;
    frame[0] = 0x55;
    frame[1] = 0xaa;
    frame[2] = 0x21;
    frame[3] = 0x36;
    frame[4] = (uint8_t)(slot << 3);
    frame[5] = 1;
    /* Original row reverses 64 and 12 bytes separately, then its formatter
     * emits the 12-byte tail before the 64-byte prefix: reverse all 76. */
    for (i = 0; i < 76; ++i)
        frame[10 + i] = header_words[75 - i];
    (void)dizzass_tx88_crc16(frame + 2, 84, UINT16_C(0xffff), &crc);
    frame[86] = (uint8_t)(crc >> 8);
    frame[87] = (uint8_t)crc;
    memcpy(out, frame, sizeof(frame));
    return DIZZASS_TX88_OK;
}
