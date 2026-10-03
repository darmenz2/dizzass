/* SPDX-License-Identifier: GPL-3.0-only
 * b5568 ordinary callback flow. Original source attribution of this caller
 * is unproved; no driver.c attribution or original-structure cast is made.
 */
#include "integration/bm1368_group_boundary_135.h"

static int32_t boundary_signed_135(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

int32_t vn135_bm1368_boundary_uart_relay_135(void *opaque,
    struct vn135_bm1368_frequency_device *device, vn135_chip_reference *chip,
    uint32_t setting)
{
    const struct vn135_bm1368_boundary_binding_135 *binding = opaque;
    return vn135_bm1368_set_uart_relay_135(device, chip, setting,
        binding->writer, binding->write_context, binding->log);
}

int32_t vn135_bm1368_configure_group_boundaries_135(
    struct vn135_bm1368_boundary_chain_135 *chain,
    const struct vn135_bm1368_boundary_selector_135 *selector)
{
    struct vn135_bm1368_boundary_owner_135 *owner = chain->owner;
    struct vn135_bm1368_boundary_board_135 *board = owner->board;
    struct vn135_bm1368_frequency_device *device = chain->device;
    vn135_chip_reference first, last;
    if (board->enabled == 0)
        return 0;
    if (selector->get(selector->context) == 4)
        return 0;
    const uint32_t count = board->group_count;
    if (boundary_signed_135(count) < 10)
        return 0;
    uint32_t group = count - board->group_step;
    if ((group & UINT32_C(0x80000000)) != 0)
        return 0;
    do {
        const uint32_t setting = board->offset_enabled != 0 ?
            (board->group_count - group) * board->chips_per_group + 14u : 0u;
        if (board->configure_first != 0) {
            const uint32_t index = board->chips_per_group * group;
            first.cache_index = boundary_signed_135(index);
            first.wire_address = index * board->address_stride;
            if (owner->configure(owner->context, device, &first, setting) != 0)
                return -1;
        }
        if (board->configure_last != 0) {
            const uint32_t size = board->chips_per_group;
            const uint32_t index = size * group + size - UINT32_C(1);
            last.cache_index = boundary_signed_135(index);
            last.wire_address = index * board->address_stride;
            if (owner->configure(owner->context, device, &last, setting) != 0)
                return -1;
        }
        group -= board->group_step;
    } while ((group & UINT32_C(0x80000000)) == 0);
    return 0;
}
