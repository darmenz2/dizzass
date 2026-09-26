/* Original 0x730d8 object construction, not an alternative cgminer core.
 * Projections are for offline recovery; not vendor ABI or production structs.
 */
#ifndef VN135_BACKEND_COLD_135_H
#define VN135_BACKEND_COLD_135_H
#include <stdint.h>
#include <stddef.h>
struct vn135_cold_profile {
    uint32_t chip_selector, capability[4]; /* model +88, +ac..+b8 */
    uint32_t board_word_0; int32_t board_word_10, table_count;
    uint32_t model_word_34; uint8_t model_byte_2c;
};
struct vn135_cold_chip { uint32_t index, word_04; };
struct vn135_cold_backend;
struct vn135_cold_chain {
    uint32_t index; struct vn135_cold_backend *parent;
    struct vn135_cold_chip *chips; void *items;
};
struct vn135_cold_backend {
    struct vn135_cold_profile *model_18, *alias_74;
    void *limits_1c, *alias_78, *records_100;
    struct vn135_cold_chain *chains_230;
    uint32_t word_7c, word_20, targets[7]; uint8_t byte_211;
};
struct vn135_cold_device {
    uintptr_t driver; struct vn135_cold_backend *data;
    uint32_t word_20, word_98;
};
enum vn135_cold_allocation { VN135_C_DEVICE, VN135_C_MODEL, VN135_C_BACKEND,
    VN135_C_CHAINS, VN135_C_RECORDS, VN135_C_CHIPS, VN135_C_ITEMS, VN135_C_LIMITS };
struct vn135_cold_ops {
    /* Allocate ZEROED projected object(s); original_count/size are preserved
     * evidence arguments, not sizeof of these native-pointer projections.
     * DEVICE and BACKEND allocations must succeed: the original does not
     * guard their later dereferences. Other failures are translated literally.
     * Caller tracks/releases all allocations, including original leak paths. */
    void *(*allocate)(void *, enum vn135_cold_allocation, uint32_t, uint32_t);
    int32_t (*load_model)(void *, struct vn135_cold_profile *);
    /* Original scalar calls. opcode identifies a boundary, not a host address. */
    int32_t (*scalar)(void *, uint32_t opcode, uint32_t, uint32_t, uint32_t);
    /* object+offset and optional second pointer represent original arguments;
     * no pointer arithmetic into a differently sized vendor struct is done.
     * For pthread attributes object=NULL denotes explicit caller scratch.
     * a=1 on mutex init requests that same attribute, otherwise attr=NULL.
     * Unknown callee bodies MUST be supplied, not assumed to succeed. */
    int32_t (*object)(void *, uint32_t opcode, void *object, uint32_t offset,
                      void *second, uint32_t a, uint32_t b);
    void (*log)(void *, uint32_t original_line, uint32_t level);
};
enum vn135_cold_boundary {
    VN135_C_RETURNED=0, VN135_C_FATAL_BOUNDARY=1
};
struct vn135_cold_result {
    struct vn135_cold_device *device; struct vn135_cold_profile *model;
    struct vn135_cold_backend *backend; uint32_t fatal_code;
};
/* Boundary result is OUR observation marker. The original function's
 * incidental r0 after its last void/callback call is not made a status code.
 * Fatal boundary stops before 0x72bf4; no delayed process exit on the host.
 * Counts/config remain stable during construction; correct object capacities,
 * required callbacks and exclusive ownership are caller preconditions.
 * Allocator/unknown callee side effects are not silently rolled back.
 */
enum vn135_cold_boundary vn135_backend_construct_135(
    struct vn135_cold_result *, const struct vn135_cold_ops *, void *, uintptr_t driver);
uint32_t vn135_cold_chip_identifier_135(uint32_t selector);
#endif
