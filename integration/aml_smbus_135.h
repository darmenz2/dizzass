/* Original AML SMBus transfer bodies. Typed OS boundary, not vendor ABI.
 * See TRANSPORT_MONITOR_135_RU.md for the verified input domain and external effects. */
#ifndef VN135_AML_SMBUS_135_H
#define VN135_AML_SMBUS_135_H
#include "integration/i2c_transport_135.h"

/* The original select timeout has two signed 64-bit fields. This is NOT a
 * cast to the host's struct timeval. select can overwrite these fields. */
struct vn135_smbus_timeout { int64_t seconds, microseconds; };
struct vn135_smbus_ops {
    int32_t (*lock)(void *, struct vn135_i2c_iface *);
    int32_t (*unlock)(void *, struct vn135_i2c_iface *);
    int32_t (*set_address)(void *, int32_t fd, uint32_t address);
    /* Exactly one of the source read/write sets is non-NULL. The bitmap has
     * 32 little-endian uint32 words (1024 descriptor bits), all other sets NULL.
     * read_direction=1 chooses readfds; 0 chooses writefds. */
    int32_t (*select_ready)(void *, int32_t nfds, uint32_t read_direction,
                           uint32_t bitmap[32], struct vn135_smbus_timeout *);
    /* protocol is the Linux I2C_SMBUS transaction selector, NOT byte length.
     * rw=0 writes, rw=1 reads; command is truncated to its low byte. data is
     * forwarded unchanged. Capacity is a PRECONDITION of the selected protocol,
     * never inferred from the selector. A send-byte operation may use NULL.
     * The original ioctl descriptor is local; callbacks may alter data but
     * must not retain data or descriptor pointers beyond this synchronous call. */
    int32_t (*transfer)(void *, int32_t fd, uint8_t rw, uint8_t command,
                        uint32_t protocol, void *data);
    int32_t (*sleep_us)(void *, uint32_t);
    int32_t (*get_errno)(void *);
    const char *(*error_text)(void *, int32_t);
    /* Original line and meaningful numeric args. Formatting/log engine external. */
    void (*log)(void *, uint32_t line, int64_t first, uint32_t second,
                const char *text);
};
/* Preconditions, NOT invented original checks: live nonaliasing iface/data,
 * 0 <= iface->fd < 1024, stable descriptor and callbacks, protocol-appropriate
 * buffer capacity; synchronous callbacks, finite eventual return. No opening,
 * closing/reopening a singleton, syscall execution, or physical-device proof.
 * Lock/unlock/sleep errors are ignored. Failure of the SMBus ioctl increments
 * the retry counter TWICE; persistent transfer failure makes only 3 transfers,
 * whereas persistent address failure or select timeout makes 5 attempts.
 * select -1 terminates immediately; other negative returns retain source tests.
 * Data possibly changed by a failed ioctl is not restored or zeroed. */
int vn135_aml_smbus_read_135(struct vn135_i2c_iface *, uint32_t address,
    uint32_t command, void *data, uint32_t protocol,
    const struct vn135_smbus_ops *, void *);
int vn135_aml_smbus_write_135(struct vn135_i2c_iface *, uint32_t address,
    uint32_t command, void *data, uint32_t protocol,
    const struct vn135_smbus_ops *, void *);
#endif
