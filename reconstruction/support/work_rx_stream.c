/* New bounded integration adapter, NOT recovered original source. */
#include "xminer/recovery/work_rx.h"
int vn135_work_rx_stream_init(vn135_work_rx_stream *s, uint32_t chain,
                             uint32_t board, uint32_t chip, uint32_t special)
{
    vn135_work_rx_stream fresh = {0};
    if (!s) return VN135_RX_INVALID;
    (void)vn135_work_rx_policy_init(&fresh.policy, board, chip, special);
    fresh.chain_id = chain;
    *s = fresh;
    return 0;
}
int vn135_work_rx_stream_feed(vn135_work_rx_stream *s,
                             const uint8_t *input, size_t size,
                             size_t *consumed, vn135_work_rx_message *out)
{
    vn135_work_rx_policy expected;
    vn135_work_rx_message message;
    size_t take;
    int rc;
    if (!s || !consumed || !out || (!input && size)) return VN135_RX_INVALID;
    (void)vn135_work_rx_policy_init(&expected, s->policy.board_selector,
                                  s->policy.chip_selector, s->policy.special_mode);
    if (s->policy.variant != expected.variant ||
        s->policy.frame_size != expected.frame_size ||
        s->policy.payload_size != expected.payload_size ||
        s->used >= expected.frame_size)
        return VN135_RX_INVALID;
    take = expected.frame_size - s->used;
    if (take > size) take = size;
    for (size_t i = 0; i < take; ++i) s->pending[s->used + i] = input[i];
    s->used += (uint32_t)take;
    rc = vn135_work_rx_next(&s->policy, s->chain_id, s->pending, s->used, &message);
    /* The validated state guarantees the next parser call cannot fail. */
    if (rc < 0) return rc;
    for (uint32_t i = message.consumed; i < s->used; ++i)
        s->pending[i - message.consumed] = s->pending[i];
    s->used -= message.consumed;
    for (uint32_t i = s->used; i < VN135_WORK_RX_MAX_FRAME; ++i) s->pending[i] = 0;
    *consumed = take;
    *out = message;
    return rc;
}
