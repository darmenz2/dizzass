/* Original 5a9fc..5ac44, source literal /tmp/build/src/backend/chain.c.
 * This separate project filename is not claimed as the vendor filename. */
#ifdef VN135_CHAIN_CLEANUP_135
#include "integration/chain_cleanup_135.h"
#include <string.h>
_Static_assert(sizeof(((struct vn135_route_chip *)0)->temperature) == 8,
    "the existing temperature projection must preserve eight source bytes");

int32_t vn135_chain_cleanup_135(struct vn135_chain_cleanup_view *view,
    const struct vn135_chain_stop_ops *ops, void *opaque, uint8_t reply[2])
{
    struct vn135_route_chain *chain = &view->chain->thermal;
    struct vn135_general_model *model;
    (void)ops->reset_line(opaque, chain->index, 1);
    (void)ops->delay_ms(opaque, 0x10ed2c, 100);
    if (view->backend->model->query_fault_87 && chain->present) {
        uint32_t number = chain->index + 1u;
        if (ops->log)
            ops->log(opaque, VN135_ROUTE_CHAIN_STOP, 1840, &number, 1);
        if (vn135_chain_auxiliary_stop_135(chain, ops, opaque, reply)) {
            number = chain->index + 1u;
            if (ops->log)
                ops->log(opaque, VN135_ROUTE_CHAIN_STOP, 1843, &number, 1);
        }
    }
    (void)ops->lock(opaque, chain);
    view->word_80 = 0;
    memset(chain->cleared_words, 0, sizeof(chain->cleared_words));
    chain->auxiliary_enabled = 0;
    memset(chain->statistics, 0, sizeof(chain->statistics));
    memset(view->statistics_tail_6c, 0, sizeof(view->statistics_tail_6c));
    if ((uint32_t)(chain->state - 3u) >= 3u)
        chain->state = 2;
    model = view->backend->model;
    for (int32_t i = 0; i < model->expected_chips_48; ++i) {
        struct vn135_route_chip *chip = &chain->chips[i];
        memset(&chip->temperature, 0, sizeof(chip->temperature));
        chip->valid = 0;
        chip->word_08 = 0;
        memset(chip->statistics, 0, sizeof(chip->statistics));
    }
    return ops->unlock(opaque, chain);
}
#endif
