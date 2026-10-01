/* SPDX-License-Identifier: GPL-3.0-only
 * Original chip1368.c e32c0 / hwscan f30d4, ordinary SWEEP_CLOCK_CTRL method.
 * Typed synchronous host projection, not the vendor ABI or a native driver. */
#ifndef VN135_BM1368_SWEEP_CLOCK_135_H
#define VN135_BM1368_SWEEP_CLOCK_135_H
#include "integration/bm1368_register_write_135.h"

struct vn135_bm1368_sweep_clock_diagnostic_135 {
    const char *module;
    const char *source;
    const char *function;
    const char *format;
    uint32_t line;
    uint32_t severity;
    uint32_t index_bits; /* Original signed %d argument bits, not formatted here. */
};
struct vn135_bm1368_sweep_clock_log_135 {
    void *context;
    void (*emit)(void *, const struct vn135_bm1368_sweep_clock_diagnostic_135 *);
};

/* Incoming ignored_2 is overwritten before use in both original methods.
 * Only bits 0..1 of field1_2 are used, at output bits 1..2, with fixed bits
 * 0x80008b00. All uint32 inputs are admitted; no range rejection. One actual
 * BM1368 writer call uses the same device, mode 1, NULL chip, register 0x3c.
 * This distinct encoding does not call the different BM1398 sweep helper or
 * substitute for the existing BM1368 pulse-width method on the same register.
 *
 * Device and reached writer callbacks/contexts/storage must remain valid.
 * Callbacks are synchronous and returning; callback tables/context identities
 * stay stable during the call. Device fields may change through other valid
 * mutable references. Existing writer storage and diagnostic boundaries still
 * apply. No invalid pointers, concurrent effects or escaped temporary storage.
 *
 * Writer zero returns 0 without accessing log. Any nonzero result reloads
 * the current device index AFTER the writer returns, increments modulo 2^32,
 * emits the exact line-463 diagnostic and returns -1. The reached log object
 * and emit callback are required. The diagnostic pointer is borrowed only
 * during emit; this typed event is not the original varargs logging ABI.
 * Failure may follow dispatch. No wrapper retry, wait, rollback or second write.
 *
 * This method does not bind numeric constructor identities to host pointers,
 * register a production driver, implement the startup coordinator, provide
 * OS I/O or establish ASIC readiness or final register-value persistence.
 */
int32_t vn135_bm1368_set_sweep_clock_135(
    struct vn135_bm1368_frequency_device *device,
    uint32_t ignored_2, uint32_t field1_2,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_sweep_clock_log_135 *log);
#endif
