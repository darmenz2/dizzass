/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_RECOVERY_CHIP1398_H
#define VN135_RECOVERY_CHIP1398_H
#include <stdint.h>
#include <stddef.h>
#include "xminer/recovery/pll.h"
#include "xminer/recovery/reg_cache.h"
#ifdef __cplusplus
extern "C" {
#endif
/* New integration API. It is not a recovered vendor header or ABI. */
enum { VN135_PACKET_SIZE = 9, VN135_OK = 0, VN135_INVALID = -1 };
uint32_t vn135_bm1398_ticket_mask_word(uint32_t input);
uint32_t vn135_bm1398_sweep_clock_word(uint32_t field4_5, uint32_t field0_2);
uint32_t vn135_bm1398_clock_delay_word(uint32_t field6_7, uint32_t field4_5, uint32_t field2);
uint32_t vn135_bm1398_analog_mux_word(uint32_t input);
uint32_t vn135_bm1398_misc_control_word(uint32_t old_value, uint32_t active);
int vn135_crc5_bits(const uint8_t *data, size_t bytes, size_t bits, uint8_t *out);
/* Encodes the 9-byte payload handed to 0xd26ac. NOT a complete UART frame.
 * mode==1 selects 0x51; other mode values select 0x41, as in the original.
 * chip_address and register_address are intentionally truncated to 8 bits.
 * No cache updates, I/O, CRC validation of replies, or mining occurs here.
 */
int vn135_bm1398_set_config_packet(uint32_t mode, uint32_t chip_address,
    uint32_t register_address, uint32_t value, uint8_t *out, size_t capacity);
/* Original 0xed974..0xed9bc: explicit model getter instead of global state.
 * model_id is compared literally with 0x1397/0x1398, NOT the 0..7 selector.
 * All other IDs return zero as in the original, not a validated core index. */
uint32_t vn135_bm1398_core_from_nonce(uint32_t model_id,uint32_t nonce);
/* Original table at 0x5ebea8; module association only, NOT a T21 profile. */
extern const vn135_pll_limits vn135_bm1398_pll_limits;
uint32_t vn135_bm1398_pll_parameter_word(uint32_t reference_divider, uint32_t feedback_divider,
    uint32_t post_divider1, uint32_t post_divider2);

/* Recovered 0xee8e4 command/cache transaction. No default/live transport.
 * The callback sees the 9-byte payload; 0 means successful dispatch, any
 * nonzero value means failure. A successful write is NOT a chip acknowledgement.
 * Wire header tests mode==1, but cache fanout tests mode!=0 (original behavior).
 * The original routine sends BEFORE validating the cache index/register.
 * Therefore -1 may follow a successful dispatch; it must NOT trigger an
 * automatic retry. Preflight any live-hardware request outside this API.
 */
typedef struct { int32_t cache_index; uint32_t wire_address; } vn135_chip_reference;
typedef struct {
    void *context;
    int (*send_payload)(void *context, const uint8_t *payload, size_t size);
} vn135_config_sender;
int vn135_bm1398_set_config(vn135_reg_cache *cache, int32_t chain_index,
    uint32_t mode, const vn135_chip_reference *chip, uint32_t register_address,
    uint32_t value, const vn135_config_sender *sender);
#ifdef __cplusplus
}
#endif
#endif
