/* SPDX-License-Identifier: GPL-3.0-only
 * New integration helper, not an original vendor header name or ABI.
 */
#ifndef VN135_SHA256_MIDSTATE_H
#define VN135_SHA256_MIDSTATE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
/* Standard SHA-256 compression over exactly one 64-byte block. No padding.
 * State words are numeric uint32_t, not serialized digest bytes.
 * Invalid NULL inputs return -2 without changing the output/state.
 * Input block and output/state must not overlap.
 */
int vn135_sha256_compress_block(uint32_t state[8], const uint8_t block[64]);
int vn135_sha256_midstate64(const uint8_t block[64], uint32_t out[8]);
#ifdef __cplusplus
}
#endif
#endif
