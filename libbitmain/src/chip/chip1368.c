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

#ifdef VN135_BM1368_INITIALIZE_135
#include "integration/bm1368_initialize_135.h"

/* Original e1450: fixed cgminer method identities, in observed store order. */
int32_t vn135_bm1368_initialize_135(
    uint32_t method_words[static VN135_BM1368_METHOD_WORDS_135])
{
    method_words[0xdc / 4] = UINT32_C(0xe4a6c);
    method_words[0xbc / 4] = UINT32_C(0xe49bc);
    method_words[0xc0 / 4] = UINT32_C(0xe49c4);
    method_words[0xc4 / 4] = UINT32_C(0xe49cc);
    method_words[0xc8 / 4] = UINT32_C(0xe49d4);
    method_words[0xcc / 4] = UINT32_C(0xe49dc);
    method_words[0xd0 / 4] = UINT32_C(0xe49e4);
    method_words[0xd4 / 4] = UINT32_C(0xe49ec);
    method_words[0xd8 / 4] = UINT32_C(0xe4a2c);
    method_words[0x9c / 4] = UINT32_C(0xe40e8);
    method_words[0xa0 / 4] = UINT32_C(0xe4198);
    method_words[0xa4 / 4] = UINT32_C(0xe41a0);
    method_words[0xa8 / 4] = UINT32_C(0xe4600);
    method_words[0xac / 4] = UINT32_C(0xe4688);
    method_words[0xb0 / 4] = UINT32_C(0xe4690);
    method_words[0xb4 / 4] = UINT32_C(0xe47b8);
    method_words[0xb8 / 4] = UINT32_C(0xe48fc);
    method_words[0x7c / 4] = UINT32_C(0xe35b4);
    method_words[0x80 / 4] = UINT32_C(0xe35c0);
    method_words[0x84 / 4] = UINT32_C(0xe3728);
    method_words[0x88 / 4] = UINT32_C(0xe3a1c);
    method_words[0x8c / 4] = UINT32_C(0xe3bbc);
    method_words[0x90 / 4] = UINT32_C(0xe3bc4);
    method_words[0x94 / 4] = UINT32_C(0xe3c04);
    method_words[0x98 / 4] = UINT32_C(0xe3dd8);
    method_words[0x5c / 4] = UINT32_C(0xe2e18);
    method_words[0x60 / 4] = UINT32_C(0xe2eb8);
    method_words[0x64 / 4] = UINT32_C(0xe3090);
    method_words[0x68 / 4] = UINT32_C(0xe3098);
    method_words[0x6c / 4] = UINT32_C(0xe3290);
    method_words[0x70 / 4] = UINT32_C(0xe32c0);
    method_words[0x74 / 4] = UINT32_C(0xe33e0);
    method_words[0x78 / 4] = UINT32_C(0xe34cc);
    method_words[0x3c / 4] = UINT32_C(0xe2978);
    method_words[0x40 / 4] = UINT32_C(0xe2980);
    method_words[0x44 / 4] = UINT32_C(0xe2988);
    method_words[0x48 / 4] = UINT32_C(0xe29c8);
    method_words[0x4c / 4] = UINT32_C(0xe2a08);
    method_words[0x50 / 4] = UINT32_C(0xe2a10);
    method_words[0x54 / 4] = UINT32_C(0xe2a18);
    method_words[0x58 / 4] = UINT32_C(0xe2d78);
    method_words[0x1c / 4] = UINT32_C(0xe1818);
    method_words[0x20 / 4] = UINT32_C(0xe1b5c);
    method_words[0x24 / 4] = UINT32_C(0xe1b64);
    method_words[0x28 / 4] = UINT32_C(0xe2130);
    method_words[0x2c / 4] = UINT32_C(0xe2210);
    method_words[0x30 / 4] = UINT32_C(0xe249c);
    method_words[0x34 / 4] = UINT32_C(0xe2808);
    method_words[0x38 / 4] = UINT32_C(0xe2810);
    method_words[0x04 / 4] = UINT32_C(0xe1790);
    method_words[0x08 / 4] = UINT32_C(0xe1798);
    method_words[0x0c / 4] = UINT32_C(0xe17a0);
    method_words[0x10 / 4] = UINT32_C(0xe17a8);
    method_words[0x14 / 4] = UINT32_C(0xe17f0);
    return 0;
}
#endif
