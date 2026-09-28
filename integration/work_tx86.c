/* Packet slice 0xc069c..0xc07e4; see integration/evidence/tx86/origin.json.
 * New typed interface around recovered transformations. GPL-3.0-or-later.
 */
#include "integration/work_tx86.h"
#include <string.h>
uint16_t dizzass_tx86_crc16(const uint8_t *data, size_t size, uint16_t seed)
{
    uint16_t crc = seed;
    size_t i;
    unsigned bit;
    for (i = 0; i < size; ++i) {
        crc ^= (uint16_t)((uint16_t)data[i] << 8);
        for (bit = 0; bit < 8; ++bit)
            crc = (uint16_t)((uint32_t)crc << 1 ^
                ((crc & 0x8000u) ? 0x1021u : 0u));
    }
    return crc;
}
int dizzass_work_tx86_encode(const uint8_t *words, size_t words_size,
    enum dizzass_tx86_layout layout, uint32_t raw_job_id,
    uint8_t *out, size_t capacity)
{
    uint8_t packet[DIZZASS_WORK_TX86_SIZE] = {0};
    size_t i, first;
    uint16_t crc;
    if (!words || !out || words_size != 80u || raw_job_id > 127u)
        return DIZZASS_TX86_INVALID;
    if (layout != DIZZASS_TX86_HEADER_REVERSED && layout != DIZZASS_TX86_NONCE_PREFIX)
        return DIZZASS_TX86_UNSUPPORTED;
    if (capacity < sizeof(packet))
        return DIZZASS_TX86_NO_SPACE;
    packet[0] = 0x55; packet[1] = 0xaa;
    packet[2] = 0x20; packet[3] = (uint8_t)raw_job_id;
    first = layout == DIZZASS_TX86_NONCE_PREFIX ? 8u : 4u;
    memcpy(packet + first, words, 76u);
    /* Original 0x10f64c reverses the WHOLE 80-byte body, not each word. */
    for (i = 0; i < 40u; ++i) {
        uint8_t temp = packet[4u + i];
        packet[4u + i] = packet[83u - i];
        packet[83u - i] = temp;
    }
    crc = dizzass_tx86_crc16(packet + 2, 82u, 0xffffu);
    packet[84] = (uint8_t)(crc >> 8);
    packet[85] = (uint8_t)crc;
    memcpy(out, packet, sizeof(packet));
    return DIZZASS_TX86_OK;
}
