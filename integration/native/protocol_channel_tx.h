/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef DIZZASS_PROTOCOL_CHANNEL_TX_H
#define DIZZASS_PROTOCOL_CHANNEL_TX_H
#include "integration/native/uart_channel.h"
#include "integration/bm1368_control.h"
#include "integration/work_route.h"
#include "integration/work_tx88.h"

enum { DIZZASS_PROTOCOL_TX_INVALID = -900 };
struct dizzass_protocol_tx_receipt {
    int prepare_status; /* 0, encoder/route error, or PROTOCOL_TX_INVALID. */
    bool channel_called; /* Entry into A-14, NOT proof of a write syscall. */
    size_t frame_size; /* Complete encoded size; zero on preparation failure. */
    struct dizzass_uart_result transport; /* Meaningful ONLY if channel_called. */
};

/* NEW opt-in integration, NOT vendor ABI or production driver registration.
 * Both operations must use the SAME A-14 gate for every TX path/alias of a port.
 * They build a bounded local frame with the existing encoders and call A-14
 * exactly once. No added prefix, CRC, write loop, resend, cache update or ACK.
 * Preparation failures do not enter the channel or alter its last result.
 * A successful preparation may still get a stopped/expired/failed channel.
 * Exact transport status/written/error is preserved, even full-but-late failure.
 * Kernel byte acceptance does not prove drain, peer reception or ASIC execution.
 *
 * deadline_ms is the caller's absolute CLOCK_MONOTONIC deadline; encoding and
 * queue time do not restart it. A-14 owns stop/cancellation/fd lifetime rules.
 * Its graceful stop may return ETIMEDOUT while fd is still borrowed. Before
 * close/destroy, join all users and coordinate RX/outside access separately.
 * Deferred cancellation can prevent receipt delivery; snapshot is not a
 * per-request receipt. No implicit conversion to native_jobs_finish outcomes.
 */
struct dizzass_protocol_tx_receipt dizzass_channel_bm1368_command(
    struct dizzass_uart_channel *channel, enum dizzass_bm1368_command command,
    uint32_t broadcast, uint32_t address, uint32_t reg, uint32_t value,
    uint64_t deadline_ms, unsigned max_no_progress);

/* header_words is the existing 80-byte native work->data WORD projection, NOT
 * network header serialization. Caller retains readable stable bytes until
 * this call returns. The existing route selector must resolve SHA256_TX88.
 * No model/baud detection, work mutation/copy, job reservation/publication or
 * slot reuse is provided. slot remains 0..31. The caller must retain the exact
 * native work and establish its job/RX lifetime before a production hookup.
 * A stop/control packet is NOT a proven drain allowing a new slot epoch.
 */
struct dizzass_protocol_tx_receipt dizzass_channel_work_tx88(
    struct dizzass_uart_channel *channel, const uint8_t *header_words,
    size_t header_size, uint32_t platform_selector, uint32_t algorithm_selector,
    uint32_t slot, uint64_t deadline_ms, unsigned max_no_progress);
#endif
