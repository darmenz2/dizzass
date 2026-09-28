/* Reconstructed 5ac80..5b11c, original /tmp/build/src/backend/chain.c.
 * Source path verified at 5ae78/5aee8. No production binding. */
#include "integration/chain_reset_cleanup_135.h"
#include <string.h>

void vn135_chain_reset_cleanup_135(struct vn135_chain_reset_cleanup_view *view,
    const struct vn135_chain_reset_cleanup_ops *ops, void *opaque, uint8_t rx[2])
{
    struct vn135_route_chain *chain = &view->chain->thermal;
    const struct vn135_chain_stop_ops *stop = ops->stop;
    struct vn135_general_model *model;
    int32_t i, sensor_count;
    uint32_t argument;

    (void)stop->reset_line(opaque, chain->index, 1);
    (void)stop->delay_ms(opaque, 0x10ed2c, 100);
    if (view->backend->model->query_fault_87 && chain->present) {
        argument = chain->index + 1u;
        if (stop->log) stop->log(opaque, VN135_ROUTE_CHAIN_STOP, 1840, &argument, 1);
        if (vn135_chain_auxiliary_stop_135(chain, stop, opaque, rx)) {
            argument = chain->index + 1u;
            if (stop->log) stop->log(opaque, VN135_ROUTE_CHAIN_STOP, 1843, &argument, 1);
        }
    }
    (void)stop->lock(opaque, chain);
    view->chain->detected_8c = 0;
    chain->auxiliary_enabled = 0;
    view->word_80 = 0;
    memset(chain->cleared_words, 0, sizeof(chain->cleared_words));
    memset(chain->statistics, 0, sizeof(chain->statistics));
    memset(view->statistics_tail_6c, 0, sizeof(view->statistics_tail_6c));
    view->time_70 = ops->now(opaque);
    view->time_78 = ops->now(opaque);
    if ((uint32_t)(chain->state - 3u) >= 3u) chain->state = 2;
    model = view->backend->model;
    for (i = 0; i < model->expected_chips_48; ++i) {
        struct vn135_route_chip *chip = &chain->chips[i];
        memset(&chip->temperature, 0, sizeof(chip->temperature));
        chip->valid = 0;
        chip->word_08 = 0;
        memset(chip->statistics, 0, sizeof(chip->statistics));
    }
    sensor_count = view->backend->model->sensor_count;
    for (i = 0; i < sensor_count; ++i) {
        struct vn135_temperature_sensor *sensor = &chain->sensors[i];
        if (sensor->access_kind == 0 || sensor->access_kind == 3 ||
            (sensor->access_kind == 4 && !sensor->skip_initial_read)) continue;
        sensor->previous_corrected = 0;
        memset(&sensor->sampled_at, 0, sizeof(sensor->sampled_at));
        sensor->failures = 0;
        sensor->sample = 0;
        sensor->corrected = 0;
        sensor->state = 0;
        sensor->remote_offset = 0;
        memset(&sensor->started_at, 0, sizeof(sensor->started_at));
        sensor->previous_sample = 0;
        sensor->extended = 0;
        sensor->has_previous = 0;
    }
    (void)stop->unlock(opaque, chain);
    ops->aggregate(opaque, chain);
}
