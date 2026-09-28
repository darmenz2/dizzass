/* SPDX-License-Identifier: GPL-3.0-only */
#include "integration/native/protocol_channel_tx.h"

static struct dizzass_protocol_tx_receipt rejected(int error)
{
    return (struct dizzass_protocol_tx_receipt){
        .prepare_status = error,
        .transport = {DIZZASS_UART_INVALID_INPUT, 0, 0}
    };
}

static struct dizzass_protocol_tx_receipt transmit(
    struct dizzass_uart_channel *channel, const uint8_t *frame, size_t length,
    uint64_t deadline, unsigned budget)
{
    struct dizzass_protocol_tx_receipt r = {
        .prepare_status = 0, .channel_called = true, .frame_size = length
    };
    r.transport = dizzass_uart_channel_send(channel, frame, length, deadline, budget);
    return r;
}

struct dizzass_protocol_tx_receipt dizzass_channel_bm1368_command(
    struct dizzass_uart_channel *channel, enum dizzass_bm1368_command command,
    uint32_t broadcast, uint32_t address, uint32_t reg, uint32_t value,
    uint64_t deadline_ms, unsigned max_no_progress)
{
    uint8_t frame[11];
    size_t length = 0;
    if (!channel || !max_no_progress) return rejected(DIZZASS_PROTOCOL_TX_INVALID);
    int e = dizzass_bm1368_command_encode(command, broadcast, address, reg, value,
        frame, sizeof frame, &length);
    if (e) return rejected(e);
    return transmit(channel, frame, length, deadline_ms, max_no_progress);
}

struct dizzass_protocol_tx_receipt dizzass_channel_work_tx88(
    struct dizzass_uart_channel *channel, const uint8_t *header_words,
    size_t header_size, uint32_t platform_selector, uint32_t algorithm_selector,
    uint32_t slot, uint64_t deadline_ms, unsigned max_no_progress)
{
    uint8_t frame[DIZZASS_TX88_SIZE];
    enum dizzass_work_family family;
    if (!channel || !max_no_progress) return rejected(DIZZASS_PROTOCOL_TX_INVALID);
    int e = dizzass_work_route_select(platform_selector, algorithm_selector, &family);
    if (e) return rejected(e);
    if (family != DIZZASS_WORK_SHA256_TX88) return rejected(DIZZASS_ROUTE_UNSUPPORTED);
    e = dizzass_tx88_encode_words(header_words, header_size, slot, frame, sizeof frame);
    if (e) return rejected(e);
    return transmit(channel, frame, sizeof frame, deadline_ms, max_no_progress);
}
