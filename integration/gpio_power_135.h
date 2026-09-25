/* Selected original VNishNet 1.3.5 GPIO/power paths, not vendor ABI.
 * Required: valid nonaliasing objects, all effect callbacks for the path,
 * serialized lifetime, finite/completing external calls. No hardware binding.
 * Return values are deliberately ignored where the original ignores them.
 */
#ifndef VN135_GPIO_POWER_135_H
#define VN135_GPIO_POWER_135_H
#include <stdint.h>
#include <stddef.h>

enum vn135_gpio_power_source { VN135_GP_GPIO=0, VN135_GP_AML=1, VN135_GP_BASE=2 };
struct vn135_gpio_ops {
    int32_t (*lock)(void *);
    int32_t (*unlock)(void *);
    uintptr_t (*fopen)(void *, const char *path, const char *mode);
    int32_t (*fprintf_number)(void *, uintptr_t, const char *format, uint32_t);
    int32_t (*fputs)(void *, const char *text, uintptr_t);
    int32_t (*fclose)(void *, uintptr_t);
    int32_t (*access)(void *, const char *path, int32_t mode);
    int32_t (*fscanf_char)(void *, uintptr_t, uint8_t *);
    int32_t (*sscanf_uint)(void *, const char *, uint32_t *);
    void (*perror)(void *, const char *);
    /* Selected original line and optional numeric argument, not full logging. */
    void (*log)(void *, enum vn135_gpio_power_source, uint32_t line, uint32_t arg);
};
struct vn135_gpio_io { const struct vn135_gpio_ops *ops; void *opaque; };
/* GPIO uses signed pin in a pathname but unsigned pin in export/unexport.
 * Nonzero direction means out; nonzero value is formatted as decimal 1. */
int vn135_gpio_export_direction_135(const struct vn135_gpio_io *, uint32_t pin, uint32_t direction);
int vn135_gpio_is_exported_135(const struct vn135_gpio_io *, uint32_t pin);
int vn135_gpio_set_value_135(const struct vn135_gpio_io *, uint32_t pin, uint32_t value);
/* Explicit scratch seed represents the original uninitialized stack byte on
 * an unsuccessful fscanf. Initialize it; do not claim an I/O failure is a
 * valid voltage measurement. The original overwrites sscanf's result. */
int vn135_gpio_get_value_135(const struct vn135_gpio_io *, uint32_t pin,
    uint8_t *scratch_char, uint32_t *out);
int vn135_gpio_set_direction_135(const struct vn135_gpio_io *, uint32_t pin, uint32_t direction);
int vn135_gpio_unexport_135(const struct vn135_gpio_io *, uint32_t pin);
/* Snapshot of the original separate AML ready flag. Neither path changes it.
 * on/off call the actual recovered GPIO helper, not a success substitute. */
int vn135_aml_psu_on_135(const struct vn135_gpio_io *, uint8_t ready);
int vn135_aml_psu_off_135(const struct vn135_gpio_io *, uint8_t ready);

struct vn135_backend_power_state {
    uint8_t byte_ff1;        /* original field, not proof of rail power-good */
    uint32_t word_20c;
};
struct vn135_backend_power_ops {
    int32_t (*psu_on)(void *);
    int32_t (*psu_off)(void *);
    /* Original passes backend+0x108c and LOW 16 bits of requested value.
     * Context binds that existing PSU object; no second PSU model here. */
    int32_t (*set_voltage)(void *, uint16_t requested);
    int32_t (*chain_count)(void *);
    int32_t (*reset_chain)(void *, uint32_t index);
    void (*log)(void *, enum vn135_gpio_power_source, uint32_t line, uint32_t arg);
};
/* Whole original entries 0x6c224 and 0x6b778. Not the entire miner startup.
 * A failed voltage setter does NOT call off; old fields remain unchanged.
 * Successful on stores full requested bits, despite passing a 16-bit value.
 * Off obtains count before power-off; resets are attempted only after off=0.
 * Reset returns are ignored. chain_count is signed; valid bounded array needed.
 */
int vn135_backend_power_start_135(struct vn135_backend_power_state *,
    const struct vn135_backend_power_ops *, void *, uint32_t requested);
int vn135_backend_power_stop_135(struct vn135_backend_power_state *,
    const struct vn135_backend_power_ops *, void *);
/* Bounded caller arithmetic 0x7140c..0x71450, NOT another whole recovered
 * function. Unsigned addition wraps first, then signed minimum is selected.
 * Numeric selector 5 is intentionally not assigned a commercial model name. */
uint32_t vn135_power_caller_value_135(uint32_t word_dc, uint32_t limit,
    uint8_t byte_ec, uint32_t selector);
#endif
