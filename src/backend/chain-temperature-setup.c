/* Original 58b50..58cec; source literal /tmp/build/src/backend/chain.c.
 * Separate project translation unit, not a claimed vendor filename. */
#ifdef VN135_CHAIN_TEMPERATURE_SETUP_135
#include "integration/chain_temperature_setup_135.h"

int vn135_chain_temperature_setup_135(struct vn135_chain_temperature_setup_view *view,
    const struct vn135_chain_temperature_setup_ops *ops, void *opaque, uint32_t mode)
{
    const struct vn135_general_model *model = view->backend->model;
    struct vn135_route_chain *chain = view->chain;
    int32_t count, i;
    if (!chain->present || (uint32_t)(chain->state - 3u) < 3u)
        return 0;
    count = model->sensor_count;
    for (i = 0; i < count; ++i) {
        struct vn135_temperature_sensor *sensor = &chain->sensors[i];
        uint32_t kind = sensor->access_kind;
        if (kind == 0u || kind == 3u || (kind == 4u && !sensor->skip_initial_read))
            continue;
        if (!ops->initialize(opaque, chain, sensor))
            continue;
        if (ops->log)
            ops->log(opaque, 1208, 2, chain->index + 1u, sensor->index + 1u);
        sensor->state = 3;
        if (mode == 2u || sensor->role == 2u)
            return -1;
    }
    return 0;
}

int32_t vn135_chain_sensor_initialize_existing_135(void *opaque,
    struct vn135_route_chain *chain, struct vn135_temperature_sensor *sensor)
{
    const struct vn135_chain_sensor_initializer_binding *binding = opaque;
    return vn135_temperature_initialize(sensor, binding->temperature,
                                        binding->context, chain->index);
}
#endif
