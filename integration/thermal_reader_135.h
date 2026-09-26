/* Complete original synchronous reader b5f40 and direct initializer b5d90.
 * Offline field projections, not vendor ABI or a physical driver. */
#ifndef VN135_THERMAL_READER_135_H
#define VN135_THERMAL_READER_135_H
#include "integration/thermal_sensors_135.h"
struct vn135_reader_context {
    uint32_t chain_index, mux_address;
    uint8_t backend_active, power_marked_on;
    const char *model_name;
};
struct vn135_reader_scratch {
    /* Exact contiguous source scratch fp-37..fp-28. Initialize explicitly.
     * Adjacent source scratch fields are preserved; no arbitrary read size is safe. */
    uint8_t bytes[10];
};
struct vn135_reader_ops {
    const struct vn135_temperature_ops *temperature;
    uint32_t (*platform_kind)(void *);
    /* Original transport identity and scalar arguments, never host addresses.
     * fe440/fe518: mode=0; final scalar is SMBus PROTOCOL, not byte length:
     * 1=BYTE, 2=BYTE_DATA (one byte), 3=WORD_DATA (two bytes).
     * A fe518 BYTE write carries its value in reg and uses a NULL buffer.
     * fe528/fe538: final scalar is an actual raw block length; mode selects
     * whether a register byte is used. faeec: board-route contract remains
     * separately bounded. No production syscall or vendor pointer ABI here.
     * Full read may change protocol-appropriate bytes; earlier isolated tests
     * wrote only the first meaningful byte. Composed SMBus tests cover both
     * bytes of WORD_DATA within explicitly available scratch capacity. */
    int32_t (*transfer)(void *, uint32_t entry, uint32_t address,
        uint32_t mode, uint32_t reg, uint8_t *buffer, uint32_t length);
    int32_t (*compare_model)(void *, const char *actual, const char *expected);
    /* Original table lookup and signed per-sensor field. Returns 0 if absent;
     * nonzero supplies offset. Not a new calibration model. */
    int32_t (*model_offset)(void *, uint32_t chain_number, uint32_t sensor_index,
                            int32_t *offset);
};
/* Objects/descriptions/identities remain valid and stable. Calls are serialized;
 * read transfers may change the protocol-appropriate output bytes; No real threads,
 * clock exceptions, electrical guarantees or slot freshness claims.
 * Original remote flag is rejected for every access kind except 4.
 * Kind 2 intentionally remains unsupported by this synchronous function:
 * its asynchronous request machinery is a separate original path.
 * All callbacks reached by the selected original path are required. */
int vn135_temperature_read_135(struct vn135_temperature_sensor *,
    const struct vn135_reader_context *, const struct vn135_reader_ops *,
    void *, struct vn135_reader_scratch *);
int vn135_temperature_initialize_direct_135(struct vn135_temperature_sensor *,
    const struct vn135_reader_context *, const struct vn135_reader_ops *,
    void *, struct vn135_reader_scratch *);
#endif
