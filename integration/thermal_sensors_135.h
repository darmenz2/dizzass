/* Selected original 1.3.5 temperature procedures; offline typed projections.
 * Not vendor ABI, native cgminer structures, or physical I/O bindings.
 */
#ifndef VN135_THERMAL_SENSORS_135_H
#define VN135_THERMAL_SENSORS_135_H
#include <stddef.h>
#include <stdint.h>
struct vn135_temperature_sensor {
    uint32_t index, address, state, access_kind, role;
    uint8_t device_id, remote_enabled, skip_initial_read, extended, has_previous;
    int32_t sample, corrected, local_offset, remote_offset, failures;
    int32_t previous_sample, previous_corrected;
    double sampled_at, started_at;
};
struct vn135_temperature_ops {
    int32_t (*mutex_init)(void *, struct vn135_temperature_sensor *);
    int32_t (*lock)(void *, struct vn135_temperature_sensor *);
    int32_t (*unlock)(void *, struct vn135_temperature_sensor *);
    double (*now)(void *);
    int32_t (*configure_reading)(void *, struct vn135_temperature_sensor *);
    int32_t (*read_register)(void *, struct vn135_temperature_sensor *, uint32_t, uint8_t *);
    int32_t (*write_register)(void *, struct vn135_temperature_sensor *, uint32_t, uint8_t);
    int32_t (*finish_configuration)(void *, struct vn135_temperature_sensor *);
    int32_t (*delay_ms)(void *, uint32_t);
    void (*log)(void *, uint32_t source_line, uint32_t chain_number,
                uint32_t sensor_number, uint32_t value);
};
/* Mandatory callbacks, initialized finite fields, valid nonaliasing objects.
 * Lifetime is serialized; profiles/counts/identities stay stable. Callbacks
 * modify only their documented output buffers. No asynchronous field mutation.
 * lock/unlock with a NULL sensor identify the bus lock of the local read path.
 * No inferred fail-fast policy or physical success is added. */
void vn135_temperature_reset(struct vn135_temperature_sensor *,
    const struct vn135_temperature_ops *, void *);
int vn135_temperature_accept(struct vn135_temperature_sensor *,
    const struct vn135_temperature_ops *, void *, int32_t sample, int32_t second);
int vn135_temperature_initialize(struct vn135_temperature_sensor *,
    const struct vn135_temperature_ops *, void *, uint32_t chain_index);
int vn135_temperature_fresh(struct vn135_temperature_sensor *,
    const struct vn135_temperature_ops *, void *, double timeout);
struct vn135_temperature_group {
    struct vn135_temperature_sensor *sensors;
    const uint32_t *description_types;
    int32_t count;
    double board_timeout, sensor_timeout;
};
/* The original uses the newest surviving timestamp, not the oldest one. */
int vn135_temperature_group_fresh(const struct vn135_temperature_group *,
    const struct vn135_temperature_ops *, void *);
/* Original per-sensor timeout checks followed by the group freshness check.
 * Emits diagnostics and returns -1; it does not itself stop chains or the PSU. */
int vn135_temperature_check_timeouts(const struct vn135_temperature_group *,
    const struct vn135_temperature_ops *, void *, uint32_t chain_index, uint32_t mode);
/* BOUNDED ORIGINAL PATH ONLY: access_kind==1, remote_enabled==0, stable profile.
 * This is not the entire multi-transport reader. Initial read scratch is zero.
 * The updater return is ignored as in the original caller. */
int vn135_temperature_read_local_path(struct vn135_temperature_sensor *,
    const struct vn135_temperature_ops *, void *);

struct vn135_thermal_chip { uint32_t index; double value; };
struct vn135_thermal_chain {
    uint32_t index;
    int32_t board_temperature, chip_temperature, chip_count;
    const struct vn135_thermal_chip *chips;
};
struct vn135_thermal_limits { int32_t board, chip; };
struct vn135_thermal_trip_ops {
    int32_t (*lock)(void *);
    int32_t (*unlock)(void *);
    uint32_t (*chip_selector)(void *);
    void (*log)(void *, uint32_t source_line, uint32_t chain_number,
                int32_t temperature, uint32_t hottest_chip);
    int32_t (*stop_chain)(void *, int chip_reason);
    int32_t (*full_airflow)(void *);
    int32_t (*event)(void *, uint32_t code, int32_t temperature);
};
/* Complete decision/call order of original chain overheat check. The stop body
 * remains an explicit callee: no voltage disappearance or RX drain is claimed.
 * Positive chip_count requires that many finite initialized chip records. */
int vn135_thermal_check_overheat(const struct vn135_thermal_chain *,
    const struct vn135_thermal_limits *, const struct vn135_thermal_trip_ops *, void *);
#endif
