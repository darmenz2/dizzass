/* SPDX-License-Identifier: GPL-3.0-only
 * Partial reconstruction from /tmp/build/libbitmain/src/aml/chip.c.
 * 0x117f7c: framed command allocation, serialization, one UART-helper call, cleanup.
 * 0x118180: mask calculation with the chip lookup factored into an input.
 * Diagnostics and GPIO effects not restored here. The helper at 0x10e6c0
 * is recovered separately in uart.c; it may issue multiple OS writes.
 */
#include "xminer/recovery/aml_chip.h"
#include <limits.h>

int vn135_aml_frame_command(const uint8_t *payload, size_t length,
    uint8_t *out, size_t capacity)
{
    if (!out || (!payload && length) || length > (size_t)INT32_MAX - 2
        || capacity < length + 2) return -2;
    out[0] = 0x55;
    out[1] = 0xaa;
    for (size_t i = 0; i < length; ++i) out[i + 2] = payload[i];
    return 0;
}

int vn135_aml_send_command(void *uart, const vn135_aml_transport *t,
    const uint8_t *payload, size_t length)
{
    if (!uart) return -1;
    if (!t || !t->allocate || !t->release || !t->lock || !t->unlock || !t->write
        || (!payload && length) || length > (size_t)INT32_MAX - 2) return -2;
    uint32_t total = (uint32_t)length + 2u;
    uint8_t *frame = t->allocate(t->context, total);
    if (!frame) return -1;
    (void)vn135_aml_frame_command(payload, length, frame, total);
    t->lock(t->context);
    int32_t written = t->write(t->context, uart, frame, total);
    t->unlock(t->context);
    t->release(t->context, frame);
    return written == (int32_t)total ? 0 : -1;
}

uint32_t vn135_aml_chain_mask(int32_t index, uint32_t mode, uint32_t chip_type)
{
    if (chip_type == UINT32_C(0x1489)) return 1;
    if (mode) {
        /* A32 register LSL uses low 8 shift bits, returns zero for >=32. */
        uint32_t shift = (uint32_t)index & 255u;
        return shift < 32u ? UINT32_C(1) << shift : 0;
    }
    if (chip_type == UINT32_C(0x1398) && index > 2) return 8;
    if (index > 1) return 4;
    return index == 1 ? 2u : 1u;
}
