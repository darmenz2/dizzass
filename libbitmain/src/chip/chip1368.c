/* BM1368 nonce attribution: valid-domain behavior of ARM helpers e4600/e4688.
 * The original file path is decoded by constructor e5408..e54cc. Only these
 * helpers are reconstructed here, not the full chip driver. GPL-3.0-or-later.
 */
#include "integration/bm1368_nonce.h"

int dizzass_bm1368_locate(uint32_t chip_selector, uint32_t chips_per_chain,
    uint32_t nonce_word, struct dizzass_bm1368_location *out)
{
    struct dizzass_bm1368_location result;
    uint32_t field;

    if (!out || chips_per_chain == 0 ||
        chips_per_chain > DIZZASS_BM1368_MAX_CHAIN_CHIPS)
        return DIZZASS_BM1368_INVALID;
    if (chip_selector != DIZZASS_BM1368_SELECTOR)
        return DIZZASS_BM1368_UNSUPPORTED;

    field = (nonce_word >> 9) & UINT32_C(0xffff);
    result.chip = ((field * chips_per_chain) >> 16) & UINT32_C(0xff);
    result.core = nonce_word >> 25;
    *out = result;
    return DIZZASS_BM1368_OK;
}
