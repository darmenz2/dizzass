/* Recovered work-packet encoding boundary. GPL-3.0-or-later. */
#ifndef DIZZASS_WORK_TX86_H
#define DIZZASS_WORK_TX86_H
#include <stddef.h>
#include <stdint.h>
#define DIZZASS_WORK_TX86_SIZE 86u
/* Explicit layouts, NOT model IDs or proof of a T21 dispatch. The second
 * layout is the selector == 7 branch of the original 0xc0018 sender. */
enum dizzass_tx86_layout {
    DIZZASS_TX86_HEADER_REVERSED = 0,
    DIZZASS_TX86_NONCE_PREFIX = 7
};
enum dizzass_tx86_status {
    DIZZASS_TX86_OK = 0,
    DIZZASS_TX86_INVALID = -300,
    DIZZASS_TX86_UNSUPPORTED = -301,
    DIZZASS_TX86_NO_SPACE = -302
};
/* Internal packet CRC: data must be readable for size bytes. NULL is allowed
 * only for size == 0. Non-reflected polynomial 0x1021, no final XOR. */
uint16_t dizzass_tx86_crc16(const uint8_t *data, size_t size, uint16_t seed);
/* words is exactly 80 bytes in native cgminer work->data word convention,
 * NOT the serialized Bitcoin header. Nonce bytes 76..79 are ignored and the
 * packet's starting nonce is zero, as in the original slice.
 * raw_job_id is the actual transmitted byte, 0..127, NOT a five-bit RX slot.
 * The original wraps high-bit IDs to 1; this API rejects them instead.
 * No slot allocation, version rolling, I/O, model selection or queue mutation.
 * Output is unchanged on error; on success exactly 86 bytes are written.
 * Input/output overlap is supported by a temporary packet.
 */
int dizzass_work_tx86_encode(const uint8_t *words, size_t words_size,
    enum dizzass_tx86_layout layout, uint32_t raw_job_id,
    uint8_t *out, size_t capacity);
#endif
