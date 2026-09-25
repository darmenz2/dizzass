/* Typed boundary for selected original VNishNet 1.3.5 I2C procedures.
 * This is NOT the vendor ABI or a registered physical device driver.
 */
#ifndef VN135_I2C_TRANSPORT_H
#define VN135_I2C_TRANSPORT_H
#include <stdint.h>

/* Only the observed descriptor field (original iface +0x24) is represented.
 * Interface object identity also identifies the mutex to external callbacks. */
struct vn135_i2c_iface { int32_t fd; };
enum vn135_i2c_log_source { VN135_I2C_GENERIC=0, VN135_I2C_AML=1 };
struct vn135_i2c_ops {
    int32_t (*lock)(void *, struct vn135_i2c_iface *);
    int32_t (*unlock)(void *, struct vn135_i2c_iface *);
    int32_t (*open)(void *, const char *, uint32_t);
    int32_t (*close)(void *, int32_t);
    int32_t (*ioctl)(void *, int32_t, uint32_t, uint32_t);
    int32_t (*write)(void *, int32_t, const uint8_t *, uint32_t);
    int32_t (*read)(void *, int32_t, uint8_t *, uint32_t);
    int32_t (*sleep_us)(void *, uint32_t);
    int32_t (*get_errno)(void *);
    const char *(*error_text)(void *, int32_t);
    void *(*calloc)(void *, uint32_t, uint32_t);
    void (*free)(void *, void *);
    /* Source, original line, numeric args in original order, optional text.
     * Formatting, category and logging transport are not reconstructed. */
    void (*log)(void *, enum vn135_i2c_log_source, uint32_t,
                uint32_t, uint32_t, uint32_t, const char *);
};
struct vn135_i2c_transport {
    struct vn135_i2c_iface *global; /* AML singleton, distinct from call argument */
    const struct vn135_i2c_ops *ops;
    void *opaque;
};
/* Required preconditions, NOT new original checks: nonnull objects, mandatory
 * callbacks for the chosen path, accessible buffers for every declared size,
 * nonoverlapping input/output and state; len <= INT32_MAX-1. Callbacks return
 * finite 32-bit results, cannot mutate iface/state except explicit read data.
 * calloc returns NULL or a zeroed allocation of the requested size. Caller
 * serializes lifetime. Lock/close/sleep failures are ignored AS IN ORIGINAL.
 * No host /dev operations, voltage changes, or hardware acceptance implied. */
int vn135_i2c_hw_close(struct vn135_i2c_transport *, struct vn135_i2c_iface *);
int vn135_i2c_hw_open(struct vn135_i2c_transport *, struct vn135_i2c_iface *, const char *);
int vn135_aml_i2c_read_block(struct vn135_i2c_transport *, struct vn135_i2c_iface *,
    uint32_t address, uint32_t register_mode, uint32_t reg, uint8_t *, uint32_t len);
int vn135_aml_i2c_write_block(struct vn135_i2c_transport *, struct vn135_i2c_iface *,
    uint32_t address, uint32_t register_mode, uint32_t reg, const uint8_t *, uint32_t len);
#endif
