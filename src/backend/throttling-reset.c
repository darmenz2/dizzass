/* Original b8e54..b9094: reset four global per-chain table families.
 * Associated with throttling.c through the shared allocator and mutex;
 * this is a new project filename, not a recovered vendor filename. */
#ifdef VN135_THROTTLING_RESET_135
#include "integration/throttling_reset_135.h"

void vn135_throttling_reset_135(struct vn135_throttling_reset_view *view,
    const struct vn135_throttling_reset_ops *ops, void *opaque)
{
    int32_t count = ops->chain_count(opaque);
    struct vn135_throttling_reset_model *model = view->model;
    int32_t platform = ops->platform(opaque);
    if (platform != 7 && platform != 4)
        return;

    (void)ops->lock(opaque, view->mutex);
    for (int32_t i = 0; i < count; ++i) {
        for (unsigned group = 0; group < 4; ++group) {
            uint8_t **rows = view->tables->groups[group];
            if (rows && rows[i]) {
                uint8_t *row = rows[i];
                uint32_t length;
                switch (group) {
                case 0: length = model->count_60 << 3; break;
                case 1:
                    length = (uint32_t)model->general->expected_chips_48 << 3;
                    break;
                case 2: length = model->count_50 << 3; break;
                default:
                    length = (uint32_t)model->general->expected_chips_48;
                    break;
                }
                ops->zero(opaque, row, length);
            }
        }
    }
    (void)ops->unlock(opaque, view->mutex);
}
#endif
