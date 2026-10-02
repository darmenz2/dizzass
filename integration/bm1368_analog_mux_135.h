/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_BM1368_ANALOG_MUX_135_H
#define VN135_BM1368_ANALOG_MUX_135_H
#include "integration/bm1368_register_write_135.h"

/* Typed event, not the original ARM variadic logging ABI. */
struct vn135_bm1368_analog_mux_diagnostic_135 {
    const char *module;
    const char *source;
    const char *function;
    const char *format;
    uint32_t line, severity, index_bits;
};
struct vn135_bm1368_analog_mux_log_135 {
    void *context;
    void (*emit)(void *, const struct vn135_bm1368_analog_mux_diagnostic_135 *);
};

/* Ordinary e35c0/f3354 projection. Reuses only the reviewed low-three-bit
 * computational helper and actual BM1368 writer, not a BM1398 driver.
 * All uint32 inputs accepted. One broadcast write: device,1,NULL,0x54,input&7.
 * Zero returns 0 without accessing log. Any nonzero writer status reloads
 * device->index after the writer, adds one modulo 2^32, emits exactly one
 * line-425 severity-1 failure diagnostic, returns -1. No wrapper retry,
 * delay, cache preflight, ACK, rollback or second write.
 *
 * Device, writer/context and reached callbacks/storage stay valid throughout
 * synchronous returning calls; callback identities remain fixed. Fields may
 * change at callback boundaries. The failure log/emit must be valid; the
 * borrowed event cannot escape emit. Concurrent effects require external
 * serialization. The original initializer must have completed, its strings
 * and GOT/global storage must be valid, and normal ARM arithmetic applies.
 * Three x*(x-1) parity predicates cannot reach the duplicate logger or loop.
 * This effect projection omits those nonfaulting .bss/GOT reads, formatting
 * internals and access traces; it is not a complete original ABI recovery.
 *
 * No production registration, model dispatch or T21 runtime proof supplied.
 * Failure after dispatch must not be interpreted as no transmitted command.
 */
int32_t vn135_bm1368_set_analog_mux_135(
    struct vn135_bm1368_frequency_device *device, uint32_t input,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_analog_mux_log_135 *log);
#endif
