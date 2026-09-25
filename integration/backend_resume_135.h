/* Control-flow translation of original 1.3.5 entry 0x70e30.
 * Typed projections, NOT the vendor ABI, a second mining core, or a driver.
 */
#ifndef VN135_BACKEND_RESUME_135_H
#define VN135_BACKEND_RESUME_135_H
#include "integration/gpio_power_135.h"

struct vn135_resume_item { uint32_t word_3c, word_44; };
struct vn135_resume_chain {
    uint32_t word_20;
    uint8_t byte_24;
    struct vn135_resume_item *items; /* original chain+0x290, 128-byte stride */
};
struct vn135_resume_description {
    uint32_t word_10; /* original model+0x10, used in diagnostic */
    uint32_t board_word_10; /* original model+0x38+0x10 */
    int32_t table_count; /* original board+0x20 -> table+0x18 */
    const uint32_t *table_types; /* first word of each 28-byte table entry */
    uint32_t chip_selector, chip_word_2c; /* original model+0x88 */
};
struct vn135_resume_state {
    struct vn135_backend_power_state power;
    struct vn135_resume_description *description;
    struct vn135_resume_chain *chains;
    uint32_t word_20, word_dc, limit_34;
    int32_t word_d4;
    uint8_t byte_24, byte_85, byte_ec, byte_1054;
    uint8_t *platform_byte; /* original 0xfe114 stores at 0x654b24 */
    double double_28;
    const char *text_90;
    char *text_fc8;
    uintptr_t thread_1050, thread_1044, thread_101c, thread_1014;
};
/* Values identify source callees; they are NOT addresses to call on the host.
 * Unresolved operations are explicitly supplied, never successful defaults.
 * Context binds the original backend/subobject implicit in each operation.
 */
enum vn135_resume_step {
    VN135_R_CHAIN_COUNT=0xfe668,
    VN135_R_MODE_82D60=0x82d60,
    VN135_R_CHECK_B86D0=0xb86d0,
    VN135_R_APPLY_4F0A0=0x4f0a0,
    VN135_R_REFRESH_B9148=0xb9148,
    VN135_R_POOL_CHECK=0x34920,
    VN135_R_TRYLOCK=0x5a6684,
    VN135_R_UNLOCK=0x5a66c4,
    VN135_R_RANDOM=0x59c09c,
    VN135_R_DELAY=0x10ef3c,
    VN135_R_PLATFORM_FE190=0xfe190,
    VN135_R_PREPARE_106E58=0x106e58,
    VN135_R_CHECK_66504=0x66504,
    VN135_R_CHAIN_6C61C=0x6c61c,
    VN135_R_CHAIN_6C89C=0x6c89c,
    VN135_R_TYPE4_6E31C=0x6e31c,
    VN135_R_CONFIG_6E734=0x6e734,
    VN135_R_CONFIG_6EC4C=0x6ec4c,
    VN135_R_PLATFORM_KIND=0xfdfbc,
    VN135_R_CONFIG_6F1CC=0x6f1cc,
    VN135_R_CONFIG_6F550=0x6f550,
    VN135_R_CONFIG_6F6F4=0x6f6f4,
    VN135_R_CONFIG_6709C=0x6709c,
    VN135_R_CONFIG_66244=0x66244,
    VN135_R_CONFIG_6F8AC=0x6f8ac,
    VN135_R_CONFIG_6FAE8=0x6fae8,
    VN135_R_REPORT_F8C70=0xf8c70,
    VN135_R_START_644A8=0x644a8,
    VN135_R_RECOVERY_6BB70=0x6bb70,
    VN135_R_EVENT_49C98=0x49c98,
    VN135_R_STOP_5E92C=0x5e92c,
    VN135_R_CHAIN_55400=0x55400,
    VN135_R_CONFIG_A20A0=0xa20a0,
    VN135_R_FINISH_5DE64=0x5de64,
    VN135_R_FINISH_60A2C=0x60a2c,
    VN135_R_FLAG_8291C=0x8291c,
    VN135_R_SET_829E8=0x829e8
};
struct vn135_resume_ops {
    int32_t (*step)(void *, enum vn135_resume_step, uint32_t, uint32_t, uint32_t);
    int32_t (*thread_create)(void *, uint32_t field_offset,
                              uint32_t original_entry, uintptr_t *handle);
    int32_t (*thread_join)(void *, uintptr_t handle, uintptr_t *result);
    char *(*duplicate)(void *, const char *);
    void (*release)(void *, char *);
    double (*timestamp)(void *);
    /* Original source line, severity, and up to two numeric arguments.
     * Text formatting and output transport are not reconstructed. */
    void (*log)(void *, uint32_t line, uint32_t severity, uint32_t, uint32_t);
};
/* Required original-domain preconditions, not new vendor validation:
 * - Valid, nonoverlapping projections/callbacks, stable object identities.
 * - Each positive CHAIN_COUNT fits chains; each positive table_count fits
 *   table_types and every accessed chain's items. Other scalar values retain
 *   their exact width. Caller serializes the object's lifetime.
 * - Callbacks may update projected scalar state at the observed boundary;
 *   no asynchronous changes during this call are modeled here.
 * - join_scratch is explicitly initialized to represent the source's stack
 *   bytes when join fails to write its result. This is NOT a backend field.
 * - text pointers follow the supplied allocation/lifetime contract. Thread
 *   callbacks do not stand for successful physical startup or real threads.
 * - Handles and join scratch represent original 32-bit words. A random
 *   callback that changes word_d4 must leave it positive before remainder.
 * - No callback may silently stand in for an unimplemented device operation.
 * Entry return 0 includes some failure-handling paths AS IN ORIGINAL; it is
 * not an assertion that mining has started. Failure after ON does not add OFF.
 * Cold initialization 0x730d8 and callee bodies are not reconstructed by this
 * caller translation. Production cgminer is not linked with this module.
 */
int vn135_backend_resume_135(struct vn135_resume_state *,
    const struct vn135_resume_ops *, const struct vn135_backend_power_ops *,
    void *opaque, uintptr_t *join_scratch);
#endif
