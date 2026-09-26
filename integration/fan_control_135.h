/* Original-domain projections for 1.3.5 fan control. No physical I/O binding.
 * These are porting types, not the vendor ABI or a registered cgminer driver. */
#ifndef VN135_FAN_CONTROL_135_H
#define VN135_FAN_CONTROL_135_H
#include <stdint.h>
struct vn135_pid {
    double target, input, output, lower, upper;
    uint32_t direction, reserved_2c;
    double kp, ki, kd, previous_error, integral;
};
void vn135_pid_init(struct vn135_pid *, double, double, double);
void vn135_pid_gains(struct vn135_pid *, double, double, double);
void vn135_pid_limits(struct vn135_pid *, double, double);
void vn135_pid_target(struct vn135_pid *, double);
double vn135_pid_get_target(const struct vn135_pid *);
void vn135_pid_direction(struct vn135_pid *, uint32_t);
void vn135_pid_input(struct vn135_pid *, double);
void vn135_pid_seed(struct vn135_pid *, double);
void vn135_pid_step(struct vn135_pid *, double);
double vn135_pid_output(const struct vn135_pid *);
struct vn135_fan_control {
    int32_t ceiling;
    struct vn135_pid pid;
    uint32_t mode;
    double last_sample;
    int32_t manual_duty;
    double full_duty_since;
    uint8_t initialized;
};
struct vn135_fan_time { int64_t seconds, microseconds; };
struct vn135_fan_control_ops {
    int32_t (*initialize)(void *);
    void (*shutdown)(void *);
    int32_t (*get_duty)(void *);
    void (*set_duty)(void *, int32_t);
    int32_t (*mutex)(void *, uint32_t unlock);
    /* Scratch is explicit and initialized by caller; original ignores rc. */
    int32_t (*clock)(void *, struct vn135_fan_time *);
    void (*log)(void *, uint32_t source_line, int32_t value);
};
/* Finite IEEE binary64, nearest/even, no fast-math or contraction. Valid,
 * initialized, nonaliasing objects and all callbacks used by each path.
 * No async mutation: original locking/races are NOT repaired here. Time scratch
 * models known old bytes if clock fails, not uninitialized C reads. Success
 * only reproduces software returns, not working cooling or sensor freshness. */
int vn135_fan_control_init(struct vn135_fan_control *,
    const struct vn135_fan_control_ops *,void *,int32_t,struct vn135_fan_time *);
void vn135_fan_control_auto(struct vn135_fan_control *,
    const struct vn135_fan_control_ops *,void *,int32_t label,int32_t target,
    int32_t lower,int32_t upper,struct vn135_fan_time *);
void vn135_fan_control_manual(struct vn135_fan_control *,
    const struct vn135_fan_control_ops *,void *,int32_t,struct vn135_fan_time *);
/* Separate source modes; both request 100, they are not mapped to marketing names. */
void vn135_fan_control_full_mode2(struct vn135_fan_control *,
    const struct vn135_fan_control_ops *,void *,struct vn135_fan_time *);
void vn135_fan_control_full_mode3(struct vn135_fan_control *,
    const struct vn135_fan_control_ops *,void *,struct vn135_fan_time *);
double vn135_fan_control_integral_gap(const struct vn135_fan_control *);
void vn135_fan_control_update(struct vn135_fan_control *,
    const struct vn135_fan_control_ops *,void *,int32_t input,struct vn135_fan_time *);
uint32_t vn135_fan_control_mode(const struct vn135_fan_control *);
void vn135_fan_control_target(struct vn135_fan_control *,int32_t);
int32_t vn135_fan_control_get_target(const struct vn135_fan_control *);
void vn135_fan_control_shutdown(const struct vn135_fan_control_ops *,void *);
struct vn135_fan_record {
    uint8_t mutex_storage[24];
    uint32_t index;
    uint8_t lost, reserved[3];
    int32_t value;
};
struct vn135_fan_records {
    int32_t configured_count, ceiling;
    struct vn135_fan_record *records;
};
struct vn135_fan_records_ops {
    struct vn135_fan_record *(*allocate)(void *,uint32_t count,uint32_t source_size);
    int32_t (*mutex_init)(void *,struct vn135_fan_record *);
    int32_t (*controller_init)(void *,int32_t ceiling);
};
/* Count >=0, fits allocation. allocate models calloc and returns zeroed records
 * or NULL; caller owns all allocations including overwritten old pointers.
 * Count/pointer may change only synchronously and must retain sufficient capacity.
 * Mutex failures and controller-init failure are ignored AS IN ORIGINAL. */
int vn135_fan_records_init(struct vn135_fan_records *,
    const struct vn135_fan_records_ops *,void *);
#endif
