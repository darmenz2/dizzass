/* A-03 binding only. The original 58d08 and b71a8 bodies already exist. */
#ifdef VN135_SENSOR_CLEANUP_BINDING_135
#include "integration/sensor_cleanup_binding_135.h"
enum vn135_sensor_cleanup_route vn135_sensor_cleanup_step_135(
    const struct vn135_sensor_cleanup_binding *binding,
    uint32_t source, uint32_t index)
{
    struct vn135_route_chain *chain;
    const struct vn135_general_model *model;
    int32_t count;
    if (source != 0x58d08u)
        return VN135_SENSOR_CLEANUP_UNHANDLED;
    if (!binding || !binding->general || !binding->general->chains ||
        !binding->general->model || index >= binding->chain_capacity)
        return VN135_SENSOR_CLEANUP_INVALID;
    chain = &binding->general->chains[index].thermal;
    model = binding->general->model;
    if (!chain->present)
        return VN135_SENSOR_CLEANUP_HANDLED;
    count = model->sensor_count;
    if (count > 0 && (!chain->sensors || !binding->temperature ||
                     !binding->temperature->mutex_init))
        return VN135_SENSOR_CLEANUP_INVALID;
    vn135_temperature_chain_cleanup_135(chain, count,
        binding->temperature, binding->context);
    return VN135_SENSOR_CLEANUP_HANDLED;
}
#endif
