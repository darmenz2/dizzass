/* Selected original PSU setup paths, VNishNet 1.3.5. GPL-3.0-or-later.
 * A typed porting boundary, NOT the original vendor ABI or a device driver.
 */
#ifndef VN135_PSU_SETUP_H
#define VN135_PSU_SETUP_H
#include "integration/psu_protocol_135.h"
#define VN135_PSU_CAL_POINTS 15u
struct vn135_psu_calibration {
    int32_t lower;                 /* source global +0x14 */
    int32_t upper;                 /* source global +0x18 */
    uint8_t enabled;               /* source global +0x10 */
    uint32_t count;                /* source global +0x30 */
    double x[VN135_PSU_CAL_POINTS];/* source global +0x38 */
    double y[VN135_PSU_CAL_POINTS];/* source global +0xb0 */
};
/* All pointers refer to initialized, nonoverlapping objects. RX scratch is
 * supplied explicitly instead of reconstructing indeterminate stack bytes.
 * Finite binary64, default nearest/even; no fast-math or contraction.
 * For setters with enabled calibration: count < 2 OR count in [2,15], all
 * knots finite, a selected segment in [0,count-2], and its denominator nonzero.
 * For knots_voltage the caller supplies capacity for n doubles. Other tables
 * are outside this recovered numeric domain, not silently 'fixed'.
 * No function enables power, opens a bus, changes masks or clears a session.
 */
int vn135_psu_knots_voltage(const struct vn135_psu_calibration *,double *,int32_t);
int vn135_psu_knots_raw(double *,uint32_t);
/* Full payload transforms; NOT the whole EEPROM/calibration-fetch procedure.
 * A needs >=33 bytes, B >=34. Sentinel 0x80 ends the signed-delta sequence.
 * count is written even on failure; untouched table tails are retained.
 */
int vn135_psu_load_calibration_a(const struct vn135_psu_protocol *,
    struct vn135_psu_calibration *,const uint8_t payload[33]);
int vn135_psu_load_calibration_b(struct vn135_psu_calibration *,
    const uint8_t payload[34]);
/* Exact observed model-family predicate, not a model-name mapping. */
int vn135_psu_model_family(uint16_t model);
/* Original identification slice from 0x10100c to the supported-model boundary
 * 0x1015b4, or the original error return. Bus selection/mutex initialization
 * and later revision/serial/calibration steps are NOT included. Protocol must
 * already hold the interface/address; the initializer previously set addr=16.
 * Return +1 is OUR continuation marker, not the original initializer's return.
 * A failed first exchange toggles checksum_mode, preserving all side effects.
 */
#define VN135_PSU_IDENTIFIED_CONTINUE 1
int vn135_psu_identify_prefix(struct vn135_psu_protocol *,uint8_t scratch[8]);
/* Whole original setting procedures and selector, using the recovered
 * exchange functions. success means software reply validation only.
 */
int vn135_psu_set_voltage_raw(struct vn135_psu_protocol *,
    const struct vn135_psu_calibration *,uint32_t request,uint8_t scratch[8]);
int vn135_psu_set_voltage_float(struct vn135_psu_protocol *,
    const struct vn135_psu_calibration *,uint32_t request,uint8_t scratch[10]);
int vn135_psu_set_voltage(struct vn135_psu_protocol *,
    const struct vn135_psu_calibration *,uint32_t request,uint8_t scratch[10]);
/* Data at source +0x1d (17 characters and NUL), +0x128 and +0x00. */
struct vn135_psu_identity {
    uint32_t initial_word;
    uint32_t date_word;
    char serial[18];
};
struct vn135_psu_init_ops {
    /* Typed substitute for the external platform interface lookup (argument 0).
     * Return the original interface +0x18 bus selector, NOT an invented ACK. */
    uint32_t (*select_bus_kind)(void *,uint32_t);
    int (*mutex_init)(void *);
};
struct vn135_psu_init_scratch {
    uint8_t response[40];
    uint8_t auxiliary[14];
};
uint16_t vn135_psu_calibration_crc(const uint8_t *,uint32_t,uint16_t);
int vn135_psu_decode_serial(struct vn135_psu_identity *,const uint8_t data[12]);
uint32_t vn135_psu_decode_date(uint16_t packed);
int32_t vn135_psu_read_extended(struct vn135_psu_protocol *,uint8_t scratch[14]);
/* Complete control flow of 0x100fc4, through explicit external bus/mutex ops.
 * Both scratch arrays must be initialized. Initial state and unmodified tails
 * are preserved just as in the original. The routine can return zero with
 * calibration disabled; zero is NOT hardware-ready or verified rail voltage.
 */
int vn135_psu_initialize(struct vn135_psu_protocol *,
    struct vn135_psu_calibration *,struct vn135_psu_identity *,
    int32_t lower,int32_t upper,uint32_t initial_mode,
    const struct vn135_psu_init_ops *,struct vn135_psu_init_scratch *);
#endif
