/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_COMMON_READ_REGISTER_135_H
#define VN135_COMMON_READ_REGISTER_135_H
#include <stdint.h>
#include "integration/transport_dispatch_135.h"
#include "xminer/recovery/chip1398.h"

/* Explicit host projection of the original device identity and device+0x18
 * word. index is associated with this device, never a parent-chain field.
 * This view is not a vendor/native object layout; do not cast one into it.
 */
struct vn135_common_read_device_135 {
    void *identity;
    const uint32_t *index;
};

/* Original logger call arguments represented as host data, not its ABI.
 * index_bits is device_index+1 modulo 2^32; the original format uses %d.
 * It preserves the argument bits, including values above INT32_MAX. This API
 * does not format text or choose a host printf integer conversion for them.
 */
struct vn135_common_read_diagnostic_135 {
    const char *module;
    const char *source_path;
    const char *function;
    const char *format;
    uint32_t source_line;
    uint32_t severity;
    uint32_t index_bits;
};
struct vn135_common_read_log_135 {
    void (*emit)(void *context,
                 const struct vn135_common_read_diagnostic_135 *diagnostic);
    void *context;
};

/* Ordinary d253c projection; hwscan counterpart ea7e4. The original diagnostic
 * says GET_STATUS; the reused encoder names the matching command READ_REGISTER.
 * Broadcast uses mode BIT ZERO, not mode==1 or generic nonzero. Chip may be
 * NULL (wire address zero); otherwise its wire_address and reg truncate to bytes.
 * The existing encoder supplies CRC5. Pass its five-byte body, excluding its
 * AML prefix, through the existing transport dispatcher exactly once.
 *
 * Send status zero returns zero without reading device->index or log. Every
 * nonzero status reads *device->index AFTER send, reports one failure, and
 * returns -1. The index increment wraps in uint32_t. No send retry, cache,
 * ACK wait, status propagation beyond 0/-1, rollback or readiness claim.
 *
 * Required throughout: stable device view, transport table and callback/context
 * associations; ordinary live storage; and required selected send callback.
 * A non-NULL chip must be readable before dispatch. On a failing send, index
 * must project the valid aligned source device+0x18 word and log/emit must exist.
 * A NULL device identity is only within scope when its selected send accepts it
 * and returns zero; no original NULL-device failure path is synthesized.
 * Pointed-to index/chip fields may change synchronously during callbacks;
 * callback tables/views remain stable except the transport table's documented
 * next-invocation change. Serialize asynchronous/concurrent access externally.
 * Neither callback may retain its borrowed temporary payload/diagnostic object.
 * Diagnostic strings have static host lifetime and model one normal original
 * string-initializer pass with stable resulting data. Original addresses, stack
 * layout, fault/access traces, mutable logger strings, nonlocal returns and
 * races are not reproduced. All stored ARM identities remain noncallable data.
 */
int32_t vn135_common_read_register_135(
    const struct vn135_common_read_device_135 *device, uint32_t mode,
    const vn135_chip_reference *chip, uint32_t reg,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_common_read_log_135 *log);
#endif
