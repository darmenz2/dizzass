/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_BM1368_ADDRESS_COMMANDS_135_H
#define VN135_BM1368_ADDRESS_COMMANDS_135_H
#include "integration/common_read_register_135.h"

/* Original logger arguments represented as data, not its variadic ARM ABI.
 * index_bits is the late device index plus one modulo 2^32 (%d in source).
 * SET_ADDRESS carries the full late wire_address word for %02x: the minimum
 * display width does not truncate that argument to a byte. INACTIVE has no
 * address argument, represented by has_wire_address=0 and wire_address_bits=0.
 */
struct vn135_bm1368_address_diagnostic_135 {
    const char *module;
    const char *source_path;
    const char *function;
    const char *format;
    uint32_t source_line;
    uint32_t severity;
    uint32_t index_bits;
    uint32_t has_wire_address;
    uint32_t wire_address_bits;
};
struct vn135_bm1368_address_log_135 {
    void (*emit)(void *context,
                 const struct vn135_bm1368_address_diagnostic_135 *diagnostic);
    void *context;
};

/* Ordinary original e47b8/f3bcc and e48fc/f3c74 projections. Reuse the existing
 * common-read device view: identity is forwarded unchanged; index points to
 * the source device+0x18 word, not the enclosing chain's independent index.
 * This does not make that view or vn135_chip_reference a vendor/native layout.
 *
 * Each wrapper encodes one command through the existing encoder/CRC and sends
 * its five-byte body through the actual dispatcher once. SET_ADDRESS requires
 * a readable chip and captures low8(wire_address) before send. Cache index is
 * unused. Exactly-zero send status returns zero without reading index or log.
 * Every nonzero status reloads *index after send, emits one failure and returns
 * -1. SET_ADDRESS also reloads the full wire_address after send for that log.
 * Existing lower UART whole-frame replay is distinct from wrapper invocation.
 *
 * Required: stable device view and callback/context associations, live selected
 * transport, and ordinary returning callbacks. Chip/index values may change
 * synchronously during callbacks; required objects must remain live and valid.
 * On failure index and log/emit must exist. A NULL opaque identity is in scope
 * only when the selected send accepts it and succeeds; this API invents no
 * original NULL-device failure behavior. Diagnostic-only inputs may be NULL
 * on success. Transport changes for its next call follow its existing contract.
 * Serialize concurrent access externally. Borrowed temporary body/diagnostic
 * objects must not be retained. Strings model one completed original initializer
 * pass. Fault/access traces, mutable strings, races and nonlocal returns are
 * excluded. The encoder's argument/length guard is unreachable for these fixed
 * bounded arguments; it is not a recovered original error branch.
 *
 * No address computation, software-chip mutation, cache update, ACK, rollback,
 * queue drain, power control or production binding is supplied. The original
 * coordinator ignores these statuses in its inline addressing phase; this
 * pair does not implement that coordinator or impose fail-fast behavior on it.
 */
int32_t vn135_bm1368_inactivate_135(
    const struct vn135_common_read_device_135 *device,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_bm1368_address_log_135 *log);
int32_t vn135_bm1368_assign_address_135(
    const struct vn135_common_read_device_135 *device,
    const vn135_chip_reference *chip,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_bm1368_address_log_135 *log);
#endif
