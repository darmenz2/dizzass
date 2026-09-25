/* BM1368 reply integrity gate. GPL-3.0-or-later. */
#ifndef DIZZASS_RX_CRC5_H
#define DIZZASS_RX_CRC5_H
#include <stddef.h>
#include <stdint.h>
enum dizzass_rx_crc_status {
    DIZZASS_RX_CRC_OK=0, DIZZASS_RX_CRC_INVALID=-800,
    DIZZASS_RX_CRC_UNSUPPORTED=-801, DIZZASS_RX_CRC_MISMATCH=-802
};
/* Already framed payload WITHOUT AA55. Only BM1368 selector 4, variant 2,
 * nine bytes. Uses the retained vendor CRC5 polynomial over all 72 bits,
 * including the response-kind bit; a correct complete payload has residue 0.
 * New receive policy, NOT a recovered SHA256d RX check. A valid CRC does not
 * authenticate a reply, establish its generation, or validate its nonce.
 */
int dizzass_bm1368_reply_crc5(uint32_t chip, uint32_t variant,
    const uint8_t *payload, size_t size);
#endif
