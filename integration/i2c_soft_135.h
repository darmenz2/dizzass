/* Observed software-I2C routines from VNishNet 1.3.5. GPL-3.0-or-later.
 * This typed boundary is not the original ABI and does not open hardware.
 */
#ifndef VN135_I2C_SOFT_135_H
#define VN135_I2C_SOFT_135_H
#include <stdint.h>

struct vn135_i2c_soft_ops {
    int32_t (*write)(void *, int32_t, const uint8_t *, uint32_t);
    int32_t (*read)(void *, int32_t, uint8_t *, uint32_t);
    int32_t (*open)(void *, const char *, uint32_t);
    int32_t (*close)(void *, int32_t);
    int32_t (*delay_ms)(void *, uint32_t);
    /* Original source line, numeric severity, and argument (line 309: 4).
     * Message formatting and the final logging sink are not reconstructed. */
    void (*log)(void *, uint32_t, uint32_t, uint32_t);
};
struct vn135_i2c_soft {
    /* Offsets relative to the ORIGINAL interface object, not this C type. */
    uint8_t sda_output;       /* +0x24; any nonzero value means output */
    int32_t sda_value_fd;     /* +0x230 */
    int32_t sda_direction_fd; /* +0x234 */
    int32_t scl_value_fd;     /* +0x440 */
    const char *sda_value_path; /* original inline string at +0x2c */
    const struct vn135_i2c_soft_ops *ops;
    void *opaque;
};
/* Preconditions, NOT added runtime policy: valid state/path/mandatory callbacks;
 * read returning 1 initializes its byte; callbacks do not mutate state or path;
 * one serialized lifetime. Numeric inputs follow the original uint32_t domain.
 * External errors continue exactly where the original continues. No locks,
 * retries or safety claims are added. No working-device acceptance implied.
 * The first five helpers expose side effects only: their incidental ARM r0
 * values are not consumed by the original byte wrappers or promised here. */
void vn135_i2c_soft_sda_input(struct vn135_i2c_soft *);
void vn135_i2c_soft_sda_output(struct vn135_i2c_soft *);
void vn135_i2c_soft_start(struct vn135_i2c_soft *);
void vn135_i2c_soft_stop(struct vn135_i2c_soft *);
void vn135_i2c_soft_send_bits(struct vn135_i2c_soft *, uint32_t value);
int vn135_i2c_soft_write_byte(struct vn135_i2c_soft *, uint32_t address,
    uint32_t register_mode, uint32_t reg, uint32_t value);
uint8_t vn135_i2c_soft_read_byte(struct vn135_i2c_soft *, uint32_t address,
    uint32_t register_mode, uint32_t reg);
#endif
