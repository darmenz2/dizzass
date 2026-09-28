/* Original 58b50 coordinator; field projections, not the vendor ABI. */
#ifndef VN135_CHAIN_TEMPERATURE_SETUP_135_H
#define VN135_CHAIN_TEMPERATURE_SETUP_135_H
#include "integration/general_monitor_135.h"

struct vn135_chain_temperature_setup_view {
    struct vn135_general_monitor *backend;
    struct vn135_route_chain *chain;
};
struct vn135_chain_temperature_setup_ops {
    /* Original b7798. Required on reached paths; no success default. */
    int32_t (*initialize)(void *, struct vn135_route_chain *,
                          struct vn135_temperature_sensor *);
    void (*log)(void *, uint32_t line, uint32_t severity,
                uint32_t chain_number, uint32_t sensor_number);
};
/* Valid stable view/backend/chain identities. The entry model is resolved before
 * presence/state gates, but may be NULL when a gate prevents its dereference.
 * Each positive captured model->sensor_count fits every reached sensor bank.
 * Callbacks are bounded/sequential, and may replace chain->sensors, model or
 * scalar fields; captured sensor objects must remain alive through the call.
 * Later iterations reread the sensor bank; the current sensor stays captured.
 * log may be NULL; other callbacks are required only when reached.
 * Returns -1 only for an initialization error followed by mode==2 or role==2.
 * Other initialization failures can be logged/marked and still return zero.
 * No rollback, live synchronization, hardware success or production binding. */
int vn135_chain_temperature_setup_135(struct vn135_chain_temperature_setup_view *,
    const struct vn135_chain_temperature_setup_ops *, void *, uint32_t mode);

struct vn135_chain_sensor_initializer_binding {
    const struct vn135_temperature_ops *temperature;
    void *context;
};
/* Optional typed adapter for initialize above: reuses existing b7798 code.
 * Its narrower existing contract still applies: chain index, descriptors,
 * sensor identity and callback table remain stable; callbacks modify only
 * their documented outputs. This is not the different b5d90 direct reader. */
int32_t vn135_chain_sensor_initialize_existing_135(void *,
    struct vn135_route_chain *, struct vn135_temperature_sensor *);
#endif
