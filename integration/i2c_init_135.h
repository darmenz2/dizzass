/* Original 1.3.5 registration and GPIO initialization projections.
 * NOT a vendor ABI, production driver, or authorization to operate GPIO.
 */
#ifndef VN135_I2C_INIT_135_H
#define VN135_I2C_INIT_135_H
#include "integration/i2c_soft_135.h"
#include "integration/i2c_transport_135.h"

struct vn135_i2c_registration {
    uint32_t kind, index; /* original interface +0x18, +0x1c */
    char *name;           /* original +0x20; overwritten without freeing */
};
struct vn135_i2c_gpio_init {
    struct vn135_i2c_soft soft;
    uint32_t sda_mode, scl_mode; /* original soft +4, +0x214 */
    int32_t sda_pin, scl_pin;    /* original soft +0x208, +0x418 */
    char sda_value[256], sda_direction[256];
    char scl_value[256], scl_direction[256];
};
enum vn135_i2c_init_source {
    VN135_INIT_GENERIC=0, VN135_INIT_AML_PSU=1, VN135_INIT_AML_HW=2
};
enum vn135_i2c_mutex_step {
    VN135_ATTR_INIT=0, VN135_ATTR_SETTYPE=1,
    VN135_MUTEX_INIT=2, VN135_ATTR_DESTROY=3
};
struct vn135_i2c_init_ops {
    struct vn135_i2c_soft_ops io;
    int32_t (*is_exported)(void *, int32_t pin);
    int32_t (*unexport)(void *, int32_t pin);
    int32_t (*set_direction)(void *, int32_t pin, uint32_t mode);
    char *(*duplicate)(void *, const char *);
    /* Attribute storage/mutex internals are outside this translation.
     * Calls occur in original order; only SETTYPE receives type=1. */
    int32_t (*mutex_step)(void *, enum vn135_i2c_mutex_step,
                         struct vn135_i2c_registration *, uint32_t type);
    void (*log)(void *, enum vn135_i2c_init_source, uint32_t original_line);
};
struct vn135_aml_psu_bus {
    struct vn135_i2c_registration registration;
    struct vn135_i2c_gpio_init gpio;
    uint8_t ready; /* separate original AML static flag; not cleared on failure */
};
struct vn135_aml_hw_bus {
    struct vn135_i2c_registration registration;
    struct vn135_i2c_iface hardware;
};
/* Preconditions (not new vendor checks): valid objects and callbacks, valid
 * nonaliasing C strings/buffers, serialized lifetime. Bind gpio.soft.ops to
 * ops.io, gpio.soft.opaque to the same context, and soft.sda_value_path to
 * gpio.sda_value before using the existing byte routines. The initializer
 * does not own/zero the object. String tails and partial state are retained.
 * duplicate allocates a string or returns NULL; caller tracks/frees names.
 * mutex_step and GPIO helpers remain external, even when they return errors.
 * No cleanup-on-error, improved fd policy, or new fallback is introduced.
 */
int vn135_i2c_register_135(struct vn135_i2c_registration *,
    const struct vn135_i2c_init_ops *, void *, uint32_t kind, uint32_t index,
    const char *name);
int vn135_i2c_gpio_initialize_135(struct vn135_i2c_gpio_init *,
    const struct vn135_i2c_init_ops *, void *, int32_t sda_pin, int32_t scl_pin);
/* Original cleanup closes only positive fds and does NOT clear them or
 * unexport lines. Repeated cleanup is not idempotent. */
void vn135_i2c_gpio_close_135(struct vn135_i2c_gpio_init *,
    const struct vn135_i2c_init_ops *, void *);
int vn135_aml_psu_bus_initialize_135(struct vn135_aml_psu_bus *,
    const struct vn135_i2c_init_ops *, void *);
int vn135_aml_hw_bus_initialize_135(struct vn135_aml_hw_bus *,
    const struct vn135_i2c_init_ops *, void *, struct vn135_i2c_transport *);
/* The original AML getters ignore index and return their own singleton,
 * without checking initialization. Explicit state replaces those globals. */
struct vn135_i2c_registration *vn135_aml_psu_bus_get_135(
    struct vn135_aml_psu_bus *, uint32_t index);
struct vn135_i2c_registration *vn135_aml_hw_bus_get_135(
    struct vn135_aml_hw_bus *, uint32_t index);
#endif
