#ifndef VN135_GENERAL_MONITOR_135_H
#define VN135_GENERAL_MONITOR_135_H
#include "integration/thermal_routes_135.h"
#include "integration/fan_control_135.h"

/* Field views of the original miner_ctrl@btm worker, not a runtime ABI. */
struct vn135_general_chain {
    struct vn135_route_chain thermal;
    uint32_t fault_3c, detected_8c;
};
struct vn135_general_model {
    uint32_t kind_34;
    int32_t fan_count_bc, expected_chips_48, sensor_count;
    uint8_t query_fault_87;
};
struct vn135_general_history {
    double chain_check, power_sample, rate_check, fan_adjust, psu_sample;
    int32_t previous_temperature;
};
struct vn135_general_monitor {
    struct vn135_general_model *model;
    struct vn135_general_chain *chains;
    struct vn135_fan_record *fans;
    struct vn135_general_history *history;
    const double *global_rate;
    uint32_t state, mode;
    int32_t target_temperature, required_fans, available_fans;
    int32_t psu_temperature_limit, minimum_rate_percent, tune_percent;
    uint32_t sampled_power;
    double started_at;
    uint8_t running, active, suppress_chain_check, suppress_thermal, boot_flag;
    uint8_t tuning, psu_monitoring, psu_valid;
    int16_t psu_temperatures[3];
};
enum vn135_general_call {
    VN135_G_CANCEL_TYPE=0x5a6b2c, VN135_G_NAME=0x593af8,
    VN135_G_DELAY=0x10ef3c, VN135_G_EXIT=0x5a52d0,
    VN135_G_FANS=0x60730, VN135_G_CHAIN_COUNT=0xfe668,
    VN135_G_PLATFORM=0xfdfbc, VN135_G_LOCK=0x5a6108,
    VN135_G_UNLOCK=0x5a66c4, VN135_G_EVENT=0x49c98,
    VN135_G_STOP=0x5e92c, VN135_G_PRE_STOP=0x5e53c,
    VN135_G_SENSOR_TEST=0x772d8, VN135_G_CHIP_SENSOR_TEST=0x78eb8,
    VN135_G_THERMAL=0x591c8, VN135_G_FULL_FAN=0xf8c70,
    VN135_G_AFTER_STOP=0x60a2c, VN135_G_POWER_STOP=0x6b778,
    VN135_G_CHAIN_CHECK=0x5a3e8, VN135_G_UPDATE=0x60d58,
    VN135_G_CHAIN_POWER=0xb5290, VN135_G_POOL_FLAG=0x8291c,
    VN135_G_FAN_TARGET=0xf91f4, VN135_G_SET_FAN_TARGET=0xf911c,
    VN135_G_PSU_AVAILABLE=0x104a20, VN135_G_MAINTAIN=0x4bc00,
    VN135_G_TUNE_MAINTAIN=0xb9420, VN135_G_STATE_MAINTAIN=0x61ae0,
    VN135_G_POOL_MODE=0x82af0, VN135_G_POOL_UPDATE=0x9bc80,
    VN135_G_RATE_ACTION=0x19660
};
enum vn135_general_lock { VN135_G_BACKEND_LOCK, VN135_G_FAN_LOCK, VN135_G_CHAIN_LOCK };
struct vn135_general_ops {
    /* Scalar lower call. Chain/fan identity is its zero-based array position.
     * LOCK/UNLOCK use a=lock kind, b=index. EVENT uses a=code, b=argument.
     * NAME means the verified literal miner_ctrl@btm. Unused args are zero.
     * Return codes ignored by the original are ignored here as well. */
    int32_t (*call)(void *,uint32_t original_entry,uint32_t a,uint32_t b);
    double (*now)(void *);
    double (*number)(void *,uint32_t original_entry,uint32_t chain);
    int32_t (*collect_temperature)(void *,int32_t *); /* 5db54 */
    int32_t (*read_power)(void *,uint32_t *);         /* 104fe4 */
    int32_t (*read_psu)(void *,uint8_t *,int16_t [3]);/* 104aa0 */
    int32_t (*read_chain_fault)(void *,uint32_t,uint32_t *); /* b4e28 */
    int32_t (*stop_chain)(void *,struct vn135_route_chain *,const char *);
    int32_t (*create_shutdown)(void *,uint32_t scratch_slot,uint32_t entry,uint32_t *);
    void (*log)(void *,uint32_t line,uint32_t level,uint32_t a,uint32_t b,double value,const char *detail);
};
struct vn135_general_scratch { uint32_t handles[3]; };
/* Full control flow of entry 79778. All reachable callbacks are required except
 * log. Descriptors/pointer identities are stable, every positive count fits the
 * arrays. Serialized callbacks may change scalar state at call boundaries.
 * Doubles/intermediate arithmetic are finite binary64, round-to-nearest, no
 * fast-math; performance denominators are nonzero. The first 8 statistics bytes
 * in thermal are the host double view of original chain+40 (little-endian hosts).
 * History models source statics shared across restarts; entry does not reset it.
 * No sleep, cancellation, hardware command or successful device default exists
 * here: OS/device effects belong to explicit bindings. Tests clear running at
 * delay; no iteration limit is inserted into the recovered worker. */
void vn135_general_monitor_135(struct vn135_general_monitor *,
    const struct vn135_general_ops *,void *,struct vn135_general_scratch *);
#endif
