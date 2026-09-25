/* Recovered BTM 88-byte work frame, GPL-3.0-or-later.
 * Pure format only; backend selection is checked separately in work_route.
 * No live T21 detection, startup or runtime is implemented here.
 */
#ifndef DIZZASS_WORK_TX88_H
#define DIZZASS_WORK_TX88_H
#include <stddef.h>
#include <stdint.h>
#define DIZZASS_TX88_SIZE 88u
#define DIZZASS_TX88_HEADER_SIZE 80u

enum dizzass_tx88_status {
    DIZZASS_TX88_OK = 0,
    DIZZASS_TX88_INVALID = -300,
    DIZZASS_TX88_CAPACITY = -301
};

/* CRC algorithm observed at 0xf7df4. Polynomial 0x1021, MSB first,
 * caller-supplied initial value, no final XOR. NULL data is valid only at
 * length zero. On error output is unchanged. No table or ELF dependency.
 */
int dizzass_tx88_crc16(const uint8_t *data, size_t size, uint16_t initial,
    uint16_t *out);

/* Input is the 80-byte native cgminer work->data WORD representation, NOT
 * an 80-byte Bitcoin network serialization. This explicit BTM format uses
 * only bytes 0..75; the work's stored nonce is deliberately not transmitted.
 * slot must be 0..31. Byte 3 is the observed literal 0x36, not a derived
 * length. The original caller sends all 88 bytes. No CRC5 is added.
 * Errors do not change output; exactly 88 bytes are written on success.
 * Temporary local assembly makes overlap with the input safe. No allocation,
 * hashing, work mutation, UART, model detection or slot lifecycle is performed.
 */
int dizzass_tx88_encode_words(const uint8_t *header_words, size_t header_size,
    uint32_t slot, uint8_t *out, size_t capacity);
#endif
