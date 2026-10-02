/* Original cgminer b58e4 behavior through named host fields and callbacks.
 * The adjacent initializer names backend/driver.c, but this routine has no
 * direct source reference. Keep this as an explicit integration projection. */
#include "integration/bm1368_group_register_135.h"

static int32_t group_signed_index_135(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

int32_t vn135_bm1368_group_drive_strength_135(void *opaque,
    struct vn135_bm1368_frequency_device *device, vn135_chip_reference *chip,
    uint32_t setting)
{
    const struct vn135_bm1368_group_binding_135 *binding = opaque;
    return vn135_bm1368_set_chip_drive_strength_135(device, chip, setting,
        binding->read, binding->writer, binding->write_context, binding->log);
}

int32_t vn135_bm1368_configure_group_drive_strength_135(
    struct vn135_bm1368_group_chain_135 *chain)
{
    struct vn135_bm1368_group_board_135 *board = chain->owner->board;
    if (board->enabled == 0)
        return 0;
    int32_t group = board->group_count;
    struct vn135_bm1368_group_owner_135 *owner = chain->owner;
    struct vn135_bm1368_frequency_device *device = chain->device;
    vn135_chip_reference chip;
    while (group >= 1) {
        const uint32_t index = board->chips_per_group * (uint32_t)group - UINT32_C(1);
        chip.cache_index = group_signed_index_135(index);
        chip.wire_address = index * board->address_stride;
        vn135_bm1368_group_method_135 method = owner->configure;
        const uint32_t setting = board->drive_strength;
        const int32_t result = method(owner->context, device, &chip, setting);
        --group;
        if (result != 0)
            return -1;
    }
    return 0;
}
