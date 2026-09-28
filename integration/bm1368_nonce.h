/* New native integration interface, not the vendor ABI. GPL-3.0-or-later. */
#ifndef DIZZASS_BM1368_NONCE_H
#define DIZZASS_BM1368_NONCE_H
#include <stdint.h>

#define DIZZASS_BM1368_SELECTOR UINT32_C(4)
#define DIZZASS_BM1368_MAX_CHAIN_CHIPS UINT32_C(256)
struct dizzass_bm1368_location {
    uint32_t chip;
    uint32_t core;
};
enum dizzass_bm1368_status {
    DIZZASS_BM1368_OK = 0,
    DIZZASS_BM1368_INVALID = -1,
    DIZZASS_BM1368_UNSUPPORTED = -2
};

/* Only the verified BM1368 (selector 4) attribution path. The caller must
 * establish the chip type and retain a coherent count in [1, 256]. This domain
 * is a software contract, not a list of supported physical board layouts.
 * nonce_word is the value returned by dizzass_nonce_decode_payload(); do NOT
 * byte-swap it again. The recovered helpers take this same integer.
 * No I/O, allocation, model detection, CRC or share validation. The output
 * is unchanged on error. A computed location does not authenticate a reply.
 */
int dizzass_bm1368_locate(uint32_t chip_selector, uint32_t chips_per_chain,
    uint32_t nonce_word, struct dizzass_bm1368_location *out);
#endif
