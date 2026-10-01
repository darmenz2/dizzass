/* SPDX-License-Identifier: GPL-3.0-only
 * Original chip1368.c e1b64 / hwscan f2214, ordinary reset-cores flow.
 * Explicit host callback projection, not an ARM ABI or production driver. */
#ifndef VN135_BM1368_RESET_135_H
#define VN135_BM1368_RESET_135_H
#include "integration/bm1368_frequency_135.h"
#include "xminer/recovery/chip1398.h"

struct vn135_bm1368_reset_diagnostic_135 {
    const char *module;
    const char *source;
    const char *function;
    const char *format;
    uint32_t line;
    uint32_t severity;
    uint32_t has_index;
    uint32_t index_bits; /* Original signed %d argument bits; not formatted here. */
};

struct vn135_bm1368_reset_ops_135 {
    int32_t (*read_cached)(void *, int32_t chain, int32_t chip,
        uint32_t reg, uint32_t *output);
    void *read_context;
    int32_t (*write_register)(void *, struct vn135_bm1368_frequency_device *,
        uint32_t mode, const vn135_chip_reference *, uint32_t reg, uint32_t value);
    void *write_context;
    int32_t (*wait_ms)(void *, uint32_t milliseconds);
    void *wait_context;
    void (*emit)(void *, const struct vn135_bm1368_reset_diagnostic_135 *);
    void *log_context;
};

/* All reached callbacks, device, chip and ops are required and remain valid.
 * The callback table and context identities are stable. Calls are synchronous,
 * serialized and returning. Callbacks may mutate device/chip fields through
 * other valid mutable references, but must not retain or access temporary
 * output/diagnostic pointers outside that callback. No asynchronous mutation,
 * aliasing into this function's locals or malformed pointers are supported.
 *
 * Device/chip types project original device+0x18 and chip+0/+4 fields. They
 * are not vendor layouts. Cache reads reload current signed chain/chip indices;
 * writes pass the same identities, mode 0 and the observed register/value.
 * Each indexed error reloads device index and adds one with uint32 wrap.
 * Cache errors have no index argument (has_index=0, index_bits=0 in this API).
 * emit receives the original strings, line and severity, not original varargs.
 *
 * fast accepts every word: zero selects 5 ms, nonzero selects 1 ms. The fourth
 * original scalar is unused; clock and pulse use only their low 3/2 bits.
 * Conditional failures skip only the original local operations. All five
 * waits are invoked; their return values and selected write results are ignored.
 * Returns 0 on normal completion even after errors. This does not mean device
 * readiness, successful reset, an ACK, or that no command was sent on error.
 *
 * This entry does not call or alter the separate fail-fast adapter. It supplies
 * no I/O, real waits, allocation, locking, retry, rollback or native binding.
 * The existing cache and register writer can be bound through typed callbacks;
 * their independent validation and lower diagnostic limits remain unchanged.
 */
int32_t vn135_bm1368_reset_cores_135(
    struct vn135_bm1368_frequency_device *device,
    const vn135_chip_reference *chip, uint32_t fast, uint32_t unused,
    uint32_t clock, uint32_t pulse, const struct vn135_bm1368_reset_ops_135 *ops);
#endif
