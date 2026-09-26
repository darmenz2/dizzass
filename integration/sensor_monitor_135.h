/* Original synchronous temperature monitor. Offline typed field projections. */
#ifndef VN135_SENSOR_MONITOR_135_H
#define VN135_SENSOR_MONITOR_135_H
#include "integration/thermal_routes_135.h"
struct vn135_sensor_monitor {
    uint32_t state, mode;
    uint8_t running, suppress_fault_stop;
    int32_t sensor_count;
    struct vn135_route_chain *chains;
    /* Source static timestamp retained across worker restarts. */
    double last_chip_poll;
};
struct vn135_sensor_monitor_ops {
    int32_t (*chain_count)(void *);
    int32_t (*set_cancel_type)(void *, uint32_t);
    int32_t (*set_name)(void *, const char *);
    double (*now)(void *);
    int32_t (*delay_ms)(void *, uint32_t);
    /* Bind reader to the existing synchronous temperature reader. No hardware
     * success defaults. Sensor/chain state may change at these call boundaries. */
    int32_t (*read_sensor)(void *,struct vn135_route_chain *,struct vn135_temperature_sensor *);
    void (*aggregate)(void *,struct vn135_route_chain *);
    int32_t (*overheat)(void *,struct vn135_route_chain *);
    int32_t (*stop_chain)(void *,struct vn135_route_chain *,const char *);
    int32_t (*after_chain_stop)(void *); /* original remaining-backend decision */
    int32_t (*refresh_chip_temperatures)(void *,struct vn135_route_chain *);
    void (*before_timed_abort)(void *);
    int32_t (*event)(void *,uint32_t);
    int32_t (*create_shutdown)(void *,uint32_t entry,uint32_t *handle);
    int32_t (*power_stop)(void *);
    void (*worker_exit)(void *,uint32_t);
    void (*log)(void *,uint32_t line,uint32_t chain_number,uint32_t sensor_number,int32_t failures);
};
/* Valid stable pointer identities, finite times, serialized calls. The initial
 * sensor_count and initial chain_count are cached exactly as in the source and
 * must fit every allocated array. Descriptors/counts remain stable in a run.
 * Callbacks may synchronously change state/running and sensor state/failures.
 * The worker has no invented iteration bound; tests clear running at delay.
 * It always begins one iteration after setting running=1. Stopped state 4 is
 * tested only after finding an eligible sensor, not as an unconditional gate.
 * last_chip_poll is not reset at entry. These are not OS-thread/voltage proofs. */
void vn135_temperature_monitor_135(struct vn135_sensor_monitor *,
    const struct vn135_sensor_monitor_ops *,void *,uint32_t *thread_scratch);
void vn135_temperature_monitor_abort_135(const struct vn135_sensor_monitor_ops *,
    void *,uint32_t *thread_scratch);
/* Original per-chain sensor cleanup (58d08). Count is the cached model count,
 * not necessarily route_chain.sensor_count. Reset preserves sampled_at,
 * local_offset and failures exactly as the existing original reset does.
 * This does not free the array, drain responses or deassert board power. */
void vn135_temperature_chain_cleanup_135(struct vn135_route_chain *,int32_t count,
    const struct vn135_temperature_ops *,void *);
#endif
