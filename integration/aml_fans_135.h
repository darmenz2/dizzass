/* Typed boundaries for the original 1.3.5 AML fan controller.
 * This is a porting/test interface, not the vendor ABI or a live driver.
 */
#ifndef VN135_AML_FANS_135_H
#define VN135_AML_FANS_135_H
#include <stdint.h>
struct vn135_aml_fan_sample { uint32_t rpm, previous; };
struct vn135_aml_fans {
    uint32_t thread;
    uint8_t running;
    struct vn135_aml_fan_sample samples[4];
};
struct vn135_aml_fan_ops {
    uint32_t (*open)(void *, const char *, const char *);
    int32_t (*close)(void *, uint32_t);
    int32_t (*write_uint)(void *, uint32_t, const char *, uint32_t);
    int32_t (*read_uint)(void *, uint32_t, const char *, uint32_t *);
    int32_t (*mutex)(void *, uint32_t unlock);
    int32_t (*create_thread)(void *, uint32_t *, uint32_t entry, uint32_t argument);
    int32_t (*cancel_state)(void *, uint32_t);
    int32_t (*name_thread)(void *, const char *);
    int32_t (*seek)(void *, uint32_t, int32_t, int32_t);
    char *(*read_line)(void *, char *, uint32_t, uint32_t);
    int32_t (*sleep_ms)(void *, uint32_t);
    void (*exit_thread)(void *, uint32_t);
    void (*log)(void *, uint32_t original_line, uint32_t argument);
    uint32_t (*self_thread)(void *);
    int32_t (*detach_thread)(void *, uint32_t);
    int32_t (*cancel_thread)(void *, uint32_t);
    int32_t (*join_thread)(void *, uint32_t);
};
/* All used callbacks/objects must be valid; 32-bit handles are opaque tokens.
 * open returns zero or an owned handle, read_uint has scanf write semantics,
 * read_line has fgets semantics (NUL termination, capacity respected).
 * Matched interrupt lines MUST contain a colon, optional ASCII spaces, a
 * counter token and a following ASCII space within the returned line. This
 * is the original parser's domain: malformed matched lines are not repaired.
 * No untrusted sysfs I/O, actual threads, PWM changes or timing are supplied.
 * Lifetime is serialized. At explicit callback boundaries the harness may
 * change running at sleep and thread during self/cancel; no asynchronous reads.
 * this is NOT a C memory-model solution to the original unsynchronized thread.
 */
int vn135_aml_fans_initialize_135(struct vn135_aml_fans *,
    const struct vn135_aml_fan_ops *, void *);
void vn135_aml_fans_set_channel_135(const struct vn135_aml_fan_ops *, void *,
    uint32_t channel, int32_t duty);
void vn135_aml_fans_set_all_135(const struct vn135_aml_fan_ops *, void *, int32_t);
uint32_t vn135_aml_fans_get_duty_135(const struct vn135_aml_fan_ops *, void *);
uint32_t vn135_aml_fans_get_rpm_135(const struct vn135_aml_fans *,
    const struct vn135_aml_fan_ops *, void *, uint32_t index);
/* Runs original worker control flow until running becomes zero after sleep,
 * or opening interrupts fails. Calls the external pthread_exit boundary, then
 * returns to the harness; no fall-through beyond that nonreturning boundary.
 */
void vn135_aml_fans_rpm_worker_135(struct vn135_aml_fans *,
    const struct vn135_aml_fan_ops *, void *);
/* Original stop: if running is zero, does nothing even with a saved handle.
 * Clears running before self lookup; self-worker detaches, other caller cancels
 * then joins. Handle is reread after cancel. No PWM writes or cache reset.
 * Lifecycle is serialized by the harness; this does not fix source races.
 */
void vn135_aml_fans_shutdown_135(struct vn135_aml_fans *,
    const struct vn135_aml_fan_ops *, void *);
#endif
