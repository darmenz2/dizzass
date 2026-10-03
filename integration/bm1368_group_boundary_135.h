/* SPDX-License-Identifier: GPL-3.0-only
 * Typed, offline projection of cgminer e4690 and b5568. NOT an original ABI.
 */
#ifndef VN135_BM1368_GROUP_BOUNDARY_135_H
#define VN135_BM1368_GROUP_BOUNDARY_135_H
#include "integration/bm1368_register_write_135.h"

struct vn135_bm1368_relay_diagnostic_135 {
    const char *component, *source, *function, *format;
    uint32_t line, severity, chain_index, chip_index;
};
struct vn135_bm1368_relay_log_135 {
    void *context;
    void (*emit)(void *, const struct vn135_bm1368_relay_diagnostic_135 *);
};
/* e4690: one unicast reg2c write, value=3|(setting<<16) modulo 2^32.
 * Both device and chip remain live; any nonzero writer result logs their
 * CURRENT indices plus one modulo 2^32, then returns -1. Zero returns zero.
 * The already recovered writer owns send/cache behavior. A failed cache update
 * can follow a successful send. No ACK, retry, timing or hardware is implied.
 * Valid chip/device/writer/log storage and synchronous returning callbacks are
 * required for reached operations. A diagnostic is borrowed until emit returns.
 */
int32_t vn135_bm1368_set_uart_relay_135(
    struct vn135_bm1368_frequency_device *, const vn135_chip_reference *,
    uint32_t setting, const struct vn135_bm1368_register_ops *, void *,
    const struct vn135_bm1368_relay_log_135 *);

struct vn135_bm1368_boundary_board_135 {
    uint32_t address_stride;  /* original board+00 */
    uint32_t chips_per_group; /* original board+14 */
    uint32_t group_count;     /* original board+18, signed at the entry gate */
    uint32_t group_step;      /* original board+34, full word; reread on decrement */
    uint8_t enabled;          /* board+30, entire byte */
    uint8_t offset_enabled;   /* board+38 */
    uint8_t configure_first;  /* board+39 */
    uint8_t configure_last;   /* board+3a */
};
typedef int32_t (*vn135_bm1368_boundary_method_135)(void *,
    struct vn135_bm1368_frequency_device *, vn135_chip_reference *, uint32_t);
struct vn135_bm1368_boundary_owner_135 {
    struct vn135_bm1368_boundary_board_135 *board;
    vn135_bm1368_boundary_method_135 configure; /* original owner+1c0 */
    void *context; /* explicit host association, not original memory */
};
struct vn135_bm1368_boundary_chain_135 {
    struct vn135_bm1368_boundary_owner_135 *owner; /* original chain+1c */
    struct vn135_bm1368_frequency_device *device; /* fixed chain+2b8 association */
};
struct vn135_bm1368_boundary_selector_135 {
    void *context;
    uint32_t (*get)(void *); /* fdfac, NOT fdfbc or the BM1368 chip selector */
};
struct vn135_bm1368_boundary_binding_135 {
    const struct vn135_bm1368_register_ops *writer;
    void *write_context;
    const struct vn135_bm1368_relay_log_135 *log;
};
int32_t vn135_bm1368_boundary_uart_relay_135(void *,
    struct vn135_bm1368_frequency_device *, vn135_chip_reference *, uint32_t);

/* b5568: owner/board identities are captured before selector.get. Disabled
 * skips the selector. Selector==4, signed count<10, or negative wrapped
 * (count-step) skips all methods. Otherwise descend using the step reread
 * after EACH iteration, until the resulting word has its sign bit set.
 * Count/stride/size/flags and owner.configure/context are live where the
 * original reads them. An offset is captured once per iteration and shared
 * by its first/last calls. Any nonzero method status returns -1 immediately.
 * Index and address arithmetic wrap modulo 2^32. Both temporary descriptors
 * are separate and borrowed only during this invocation, never queue entries.
 *
 * Valid stable chain/device/owner/board associations, externally serialized
 * returning callbacks, and a TERMINATING field/status sequence are required.
 * In particular a constant zero step can repeat forever in the original.
 * There is deliberately no invented clamp, default step, automatic retry or
 * success on exhaustion. A normal finite domain is count in [10,INT32_MAX],
 * stable step in [1,INT32_MAX], and synchronous methods. Callbacks may change
 * live board fields or the captured owner's method/context; replaced chain
 * owner and owner.board do not replace the captured identities. Device is a
 * fixed host association corresponding to the original embedded subobject.
 * No threading, allocator, UART access, production registration or full
 * coordinator is provided. The 32-job-slot lifetime policy is untouched.
 */
int32_t vn135_bm1368_configure_group_boundaries_135(
    struct vn135_bm1368_boundary_chain_135 *,
    const struct vn135_bm1368_boundary_selector_135 *);
#endif
