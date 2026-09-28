/* Original 1.3.5 entries 0x7409c and 0x7755c. Offline typed projections,
 * not vendor ABI, a second cgminer backend, or a physical device driver.
 */
#ifndef VN135_BACKEND_PREPARE_135_H
#define VN135_BACKEND_PREPARE_135_H
#include <stdint.h>
#include <stddef.h>
struct vn135_prepare_limits {
    uint32_t word_14;
    int32_t lower_30, upper_34, word_3c;
};
struct vn135_prepare_profile {
    int32_t word_1c;
    int32_t fan_count;             /* model +0xbc */
    int32_t fan_word_0c;           /* model +0xbc+0xc */
};
struct vn135_prepare_fan {
    uint8_t byte_1c;
    int32_t word_20;
};
struct vn135_prepare_state {
    struct vn135_prepare_limits *limits;
    struct vn135_prepare_profile *profile;
    struct vn135_prepare_fan *fans; /* original +0x238, 36-byte stride */
    uint32_t word_28, word_2c, word_1070;
    uint8_t byte_24, byte_fe5, byte_104a, byte_85, byte_f4, byte_210;
    uint32_t mode_50;
    int32_t word_68, word_10c, word_23c;
    const char *text_90;
    char *text_fc8;
    uint8_t *platform_byte;        /* original 0x654b24 */
    uint32_t thread_ff4;
};
struct vn135_prepare_scratch { char serial[256]; };
struct vn135_prepare_ops {
    /* Explicit unrecovered callees. Source address is an identifier, NEVER a
     * host address to execute. Backend/subobject is bound by opaque context.
     * 4f2d0/82d60: a=0x50 offset; f8a30/delay: a=value; FE300 and mutex: a=index.
     * 49c98: a=event code, b/c=fan counts only for 2004. Other unused args=0.
     * FE2F0 has no meaningful scalar input. Source incidental r0 is omitted.
     * All operations used by a chosen path are mandatory; no success stubs. */
    int32_t (*step)(void *, uint32_t source, uint32_t a, uint32_t b, uint32_t c);
    int32_t (*stat_path)(void *, const char *);
    char *(*duplicate)(void *, const char *);
    /* Bind this to existing vn135_psu_initialize for a composed PSU test.
     * It remains explicit here to preserve independent test/link boundaries.
     * Original first pointer argument is backend+0x108c. */
    int32_t (*initialize_psu)(void *, int32_t lower, int32_t upper, uint32_t mode);
    void *(*serial_open)(void *, const char *path, const char *mode);
    int32_t (*serial_read)(void *, void *stream, const char *format, char out[256]);
    int32_t (*serial_close)(void *, void *stream);
    int32_t (*thread_create)(void *, uint32_t field, uint32_t entry, uint32_t *handle);
    /* Original line, level, meaningful numeric args and optional string.
     * Formatting, shared log engine and final output are not reconstructed. */
    void (*log)(void *, uint32_t line, uint32_t level, uint32_t a, uint32_t b,
                const char *text);
};
/* Preconditions, not invented vendor checks: valid initialized, nonaliasing
 * objects/callbacks; stable pointer identities; every positive fan_count fits
 * fans. Fan records may change only at synchronous callbacks. Iterations must
 * terminate; no asynchronous races, GPIO effects or worker bodies are modeled.
 * Source counters use 32-bit wrapping; text pointer may become NULL on strdup
 * failure without stopping the caller. The old text_fc8 is NOT freed.
 * A serial_read returning 1 must supply a terminated <=255-byte token, or leave
 * an explicitly initialized valid token in scratch. Scratch models the source
 * stack without introducing uninitialized C reads. Thread handle is a source
 * 32-bit word, not a pthread_t ABI. Callback errors stay errors AS OBSERVED.
 * Return 1 means create_thread returned zero; NOT physical mining acceptance.
 */
int vn135_backend_prepare_135(struct vn135_prepare_state *,
    const struct vn135_prepare_ops *, void *, struct vn135_prepare_scratch *);
/* Whole original fan-poll control flow, not the low-level sensor implementation.
 * The first read is deliberately replaced by the current threshold when it is
 * >= that threshold; otherwise a SECOND FE300 read is used. No filtering added.
 */
void vn135_backend_poll_fans_135(struct vn135_prepare_state *,
    const struct vn135_prepare_ops *, void *);
#endif
