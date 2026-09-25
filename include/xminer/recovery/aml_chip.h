/* SPDX-License-Identifier: GPL-3.0-only
 * New integration surface for recovered libbitmain/src/aml/chip.c behavior.
 * No device discovery/open, default write operations, or live hardware access.
 */
#ifndef VN135_RECOVERY_AML_CHIP_H
#define VN135_RECOVERY_AML_CHIP_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    void *context;
    void *(*allocate)(void *context, size_t size);
    void (*release)(void *context, void *ptr);
    void (*lock)(void *context);
    void (*unlock)(void *context);
    /* Called ONCE by this AML layer and returns the helper's signed count.
     * The original target is UART helper 0x10e6c0, which CAN internally retry
     * whole buffers. A direct write-once adapter is a different lower-layer
     * policy. See vn135_uart_write_legacy and Stage 5 composition tests. */
    int32_t (*write)(void *context, void *uart, const uint8_t *bytes, uint32_t size);
} vn135_aml_transport;

/* Pure memory framing; 55 AA prefix, no extra CRC beyond caller payload.
 * New capacity/pointer guards return -2. No bytes changed on failure.
 * Buffers must not overlap (same contract as the original memcpy).
 */
int vn135_aml_frame_command(const uint8_t *payload, size_t length,
    uint8_t *out, size_t capacity);
/* Reconstructed observable flow of 0x117f7c with external operations injected.
 * 0 on exact-length write; -1 on missing uart, allocation failure, short/error
 * write; -2 on invalid API inputs. One helper invocation, always unlock/free afterward.
 * Original diagnostic logging is outside this API.
 * If write calls a locking UART helper, do not reuse its nonrecursive mutex
 * as this outer layer's lock; the original uses two distinct mutexes.
 */
int vn135_aml_send_command(void *uart, const vn135_aml_transport *transport,
    const uint8_t *payload, size_t length);
/* 0x118180: model lookup is supplied as an explicit input, not reimplemented.
 * Returns original integer mask, no GPIO or UART operations.
 */
uint32_t vn135_aml_chain_mask(int32_t index, uint32_t mode, uint32_t chip_type);
#ifdef __cplusplus
}
#endif
#endif
