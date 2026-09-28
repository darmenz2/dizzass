/* Typed boundary for selected original 1.3.5 PSU procedures; NOT vendor ABI.
 * See integration/PSU_PROTOCOL_135_RU.md for scope and original addresses.
 */
#ifndef VN135_PSU_PROTOCOL_H
#define VN135_PSU_PROTOCOL_H
#include <stddef.h>
#include <stdint.h>

/* Fields from the original global PSU state. Unproven meanings keep offsets.
 * This structure is a value projection, never cast over firmware memory. */
struct vn135_psu_voltage_state {
    uint16_t model;              /* original +0x04 */
    uint32_t word_08;
    uint8_t byte_1c;
    uint8_t byte_130;
    uint16_t word_132;
};
/* All callbacks used by the selected path are required and must return.
 * Callback return codes are intentionally ignored where the original ignores
 * them. No real device adapter is registered by this reconstruction. */
struct vn135_psu_ops {
    int (*lock)(void *);
    int (*unlock)(void *);
    int (*write_block)(void *, uint8_t, uint32_t, uint8_t,
                       const uint8_t *, uint32_t);
    int (*read_block)(void *, uint8_t, uint32_t, uint8_t,
                      uint8_t *, uint32_t);
    int (*write_byte)(void *, uint8_t, uint32_t, uint8_t, uint32_t);
    int (*read_byte)(void *, uint8_t, uint32_t, uint8_t);
    int (*delay_ms)(void *, uint32_t);
    /* Optional diagnostic sink: original source line, values or dump bytes.
     * Formatting/log transport is not reproduced. Sink must not mutate inputs. */
    void (*log)(void *, unsigned, uint32_t, uint32_t,
                const uint8_t *, uint32_t);
};
struct vn135_psu_protocol {
    uint32_t checksum_mode;      /* original global +0x0c */
    uint32_t bus_kind;           /* original iface +0x18: 0=block, 1=byte */
    uint8_t address;             /* original device +0x1c; byte path only */
    struct vn135_psu_voltage_state voltage;
    const struct vn135_psu_ops *ops;
    void *opaque;
};
/* Raw translations, not hardened public parsers. Preconditions: non-null
 * pointers, request storage >=4 bytes, 4<=response_size<=257, full readable /
 * writable storage for every declared size, no request/response overlap.
 * Transfers additionally need 4<=request_size<=257. Caller serializes state.
 * Validator deliberately ignores request_size, like original r1.
 * Invalid preconditions are NOT an original validation policy. */
int vn135_psu_response_check(struct vn135_psu_protocol *,
    const uint8_t *, uint32_t, const uint8_t *, uint32_t);
int vn135_psu_exchange_block(struct vn135_psu_protocol *,
    const uint8_t *, uint32_t, uint8_t *, uint32_t);
int vn135_psu_exchange_bytes(struct vn135_psu_protocol *,
    const uint8_t *, uint32_t, uint8_t *, uint32_t);
/* All integer field patterns are supported. IEEE binary64, nearest/even,
 * separate subtraction then division, no fast-math. Unknown selection returns
 * 0.0 exactly as the original; that is not a valid-measurement indicator. */
double vn135_psu_decode_voltage(const struct vn135_psu_voltage_state *, int32_t);
/* Original command 0x03 -> 8-byte reply -> conversion -> signed integer *1000.
 * raw_reply is caller-owned scratch preserving original no-preclear behavior;
 * initialize it before first use. A failed transfer leaves output untouched.
 * Success means only original software predicates passed, not live voltage. */
int vn135_psu_read_voltage(struct vn135_psu_protocol *, uint8_t raw_reply[8],
                          int32_t *output);
#endif
