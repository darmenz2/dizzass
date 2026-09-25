/* SPDX-License-Identifier: GPL-3.0-only
 * Reconstructed operations from the supplied VNishNet T21 AML 1.3.5 binary.
 * Source-path evidence: /tmp/build/libbitmain/src/chip/chip1398.c.
 * These names and the public API are new. This is a PARTIAL source module.
 * See evidence/verified-slices.json for exact original instruction ranges.
 * Initialization, live I/O and nonce paths are not replaced.
 */
#include "xminer/recovery/chip1398.h"

/* 0x000eb750, payload built at 0xeb760..0xeb7bc: reverse the low 8 bits. */
uint32_t vn135_bm1398_ticket_mask_word(uint32_t input)
{
    uint32_t v = input & UINT32_C(0xff);
    v = ((v & UINT32_C(0x55)) << 1) | ((v >> 1) & UINT32_C(0x55));
    v = ((v & UINT32_C(0x33)) << 2) | ((v >> 2) & UINT32_C(0x33));
    return ((v & UINT32_C(0x0f)) << 4) | (v >> 4);
}

/* 0x000ec9f0; masks at 0xeca40/44, fixed word loaded at 0xeca08/10. */
uint32_t vn135_bm1398_sweep_clock_word(uint32_t field4_5, uint32_t field0_2)
{
    return UINT32_C(0x80008700) | ((field4_5 & 3u) << 4) | (field0_2 & 7u);
}

/* 0x000ecb68 (chip context) and 0x000ecca0 (null chip context).
 * The same bit encoding appears in both functions. Meaning of the individual
 * bit fields beyond their logged register name is not assigned speculatively.
 */
uint32_t vn135_bm1398_clock_delay_word(uint32_t field6_7, uint32_t field4_5, uint32_t field2)
{
    return UINT32_C(0x80008000) | ((field6_7 & 3u) << 6)
        | ((field4_5 & 3u) << 4) | ((field2 & 1u) << 2);
}

/* 0x000ece3c; AND #7 before SET_CONFIG(register 0x54). */
uint32_t vn135_bm1398_analog_mux_word(uint32_t input)
{
    return input & 7u;
}

/* 0x000ecf64; data transform at 0xecfcc..0xecfec after a cache read.
 * The cache read, repeated write, and error handling are outside this helper.
 */
uint32_t vn135_bm1398_misc_control_word(uint32_t old_value, uint32_t active)
{
    return (old_value & UINT32_C(0x0fbfffff))
        | (active ? UINT32_C(0x00400000) : UINT32_C(0xf0000000));
}

/* 0x000ee8e4..0x000ee978: packet construction, including original CRC routine.
 * Downstream framing and hardware transport are deliberately not invoked.
 */
int vn135_bm1398_set_config_packet(uint32_t mode, uint32_t chip_address,
    uint32_t register_address, uint32_t value, uint8_t *out, size_t capacity)
{
    if (out == NULL || capacity < VN135_PACKET_SIZE)
        return VN135_INVALID;
    out[0] = mode == 1u ? UINT8_C(0x51) : UINT8_C(0x41);
    out[1] = UINT8_C(9);
    out[2] = (uint8_t)chip_address;
    out[3] = (uint8_t)register_address;
    out[4] = (uint8_t)(value >> 24);
    out[5] = (uint8_t)(value >> 16);
    out[6] = (uint8_t)(value >> 8);
    out[7] = (uint8_t)value;
    return vn135_crc5_bits(out, 8u, 64u, &out[8]);
}

/* 0xec02c..0xec05c: pack the chosen divider tuple before SET_CONFIG(0x08).
 * Exact masks only; the caller is responsible for valid PLL search results.
 * No conversion from MHz and no physical register write occurs here.
 */
uint32_t vn135_bm1398_pll_parameter_word(uint32_t ref, uint32_t fb,
    uint32_t post1, uint32_t post2)
{
    return UINT32_C(0x40000000) | ((ref & 63u) << 8)
        | ((fb & 4095u) << 16) | ((post1 & 7u) << 4) | (post2 & 7u);
}

/* 56 bytes at 0x5ebea8, referenced by 0xeb8f0 and 0xebd54.
 * This is a PLL-search constraint record, not a safe operating preset. */
const vn135_pll_limits vn135_bm1398_pll_limits = {
    25.0, 3200.0, 2400.0, 2000.0, 2, 250, 7, 0, 2.5
};

/* Complete 0xee8e4..0xeeac4 control flow through injected transport and the
 * recovered register cache. The original diagnostic log is not reproduced.
 */
int vn135_bm1398_set_config(vn135_reg_cache *cache, int32_t chain_index,
    uint32_t mode, const vn135_chip_reference *chip, uint32_t register_address,
    uint32_t value, const vn135_config_sender *sender)
{
    if (!cache || !sender || !sender->send_payload) return -2;
    uint8_t packet[VN135_PACKET_SIZE];
    if (vn135_bm1398_set_config_packet(mode, chip ? chip->wire_address : 0,
            register_address, value, packet, sizeof(packet))) return -2;
    if (sender->send_payload(sender->context, packet, sizeof(packet)) != 0)
        return -1;
    int rc;
    if (mode != 0)
        rc = vn135_reg_cache_set_chain(cache, chain_index, register_address, value);
    else
        rc = vn135_reg_cache_set_chip(cache, chain_index,
            chip ? chip->cache_index : 0, register_address, value);
    return rc == 0 ? 0 : -1;
}

/* Stage 7, original 0xed974..0xed9bc; not the complete chip dispatcher. */
uint32_t vn135_bm1398_core_from_nonce(uint32_t model_id,uint32_t nonce)
{
    if(model_id==0x1398u)return nonce>>24;
    if(model_id==0x1397u)return ((nonce>>21)&0x3feu)|(nonce>>31);
    return 0;
}
