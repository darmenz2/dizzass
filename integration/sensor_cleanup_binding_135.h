/* A-03: typed binding of the EXISTING 58d08 sensor cleanup to shutdown steps.
 * New routing contract, not vendor ABI and not a physical shutdown status. */
#ifndef VN135_SENSOR_CLEANUP_BINDING_135_H
#define VN135_SENSOR_CLEANUP_BINDING_135_H
#include "integration/general_monitor_135.h"
#include "integration/sensor_monitor_135.h"
struct vn135_sensor_cleanup_binding {
    struct vn135_general_monitor *general;
    size_t chain_capacity;
    const struct vn135_temperature_ops *temperature;
    void *context;
};
enum vn135_sensor_cleanup_route {
    VN135_SENSOR_CLEANUP_INVALID = -2,
    VN135_SENSOR_CLEANUP_UNHANDLED = 0,
    VN135_SENSOR_CLEANUP_HANDLED = 1
};
/* source is an identity, never a host address. Unknown sources do not inspect
 * binding and return UNHANDLED. Structural binding failures return INVALID;
 * these guards are NEW API behavior, not inferred branches of original 58d08.
 * A caller must propagate INVALID as an integration error, not ignore it as
 * successful cleanup. HANDLED means only that this void step was dispatched.
 *
 * The current general.model and general.chains correspond to the SAME backend
 * used by the shutdown caller. chain_capacity describes its allocated array.
 * Each present chain with a positive model.sensor_count needs that many live
 * sensors and temperature->mutex_init. Actual allocation extents cannot be
 * checked here; a dishonest capacity/count is outside this contract.
 *
 * The model count is captured for EACH cleanup call, not cached across the
 * parent loop and not taken from route_chain.sensor_count. Existing cleanup
 * and per-sensor reset bodies are reused unchanged. No model count is read for
 * an absent chain. Negative/zero counts do not dereference sensors or ops.
 * Only nonzero-state sensors are reset; sampled_at/local_offset/failures and
 * identity/configuration fields are preserved by the original reset.
 *
 * Objects/operations must remain alive and callbacks must finish. No real
 * threads, locks or hardware are supplied. The old field name mutex_init
 * identifies source call 5a60b8; it is NOT proof of an initialization operation.
 * That original entry reads a word and may call 5a6f38; the adjacent 5a60dc, not
 * 5a60b8, clears 24 bytes. Retain the field for compatibility; do not bind a
 * real initializer based on its name. Synchronization/lifetime needs review.
 * No free, RX drain, sensor I/O, epoch barrier, or power-off is implied. */
enum vn135_sensor_cleanup_route vn135_sensor_cleanup_step_135(
    const struct vn135_sensor_cleanup_binding *, uint32_t source, uint32_t index);
#endif
