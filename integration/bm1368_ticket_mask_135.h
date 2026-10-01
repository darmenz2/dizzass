/* SPDX-License-Identifier: GPL-3.0-only
 * Original chip1368.c e2130 / hwscan f264c, ordinary TICKET_MASK method.
 * Explicit host projection, not a vendor ABI or production driver binding. */
#ifndef VN135_BM1368_TICKET_MASK_135_H
#define VN135_BM1368_TICKET_MASK_135_H
#include "integration/bm1368_register_write_135.h"

struct vn135_bm1368_ticket_mask_diagnostic_135 {
    const char *module;
    const char *source;
    const char *function;
    const char *format;
    uint32_t line;
    uint32_t severity;
    uint32_t index_bits; /* Original signed %d argument bits, not formatted here. */
};
struct vn135_bm1368_ticket_mask_log_135 {
    void *context;
    void (*emit)(void *, const struct vn135_bm1368_ticket_mask_diagnostic_135 *);
};

/* Reverse only the low eight bits of mask through the existing pure helper,
 * then call the real BM1368 writer once with mode 1, NULL chip and reg 0x14.
 * Higher input bits are ignored. No wait, retry, extra cache read or second
 * wrapper write is added. Existing lower send/cache behavior remains intact.
 *
 * Device and all reached writer callbacks/contexts must remain valid. Callbacks
 * are synchronous and returning; the writer and log tables/context identities
 * stay stable during this call. Device fields may change through other valid
 * mutable references. The existing writer's storage/temporary-buffer rules and
 * diagnostic limitations also apply. No invalid pointers, asynchronous access
 * or aliasing into temporary storage are supported.
 *
 * Zero writer status returns 0 without accessing log. On nonzero status,
 * reload the current device index AFTER the writer returns, increment its bits
 * modulo 2^32, emit the exact line-507 diagnostic once, then return -1.
 * The reached log object and emit callback are required. The diagnostic pointer
 * is borrowed only during emit; the strings/argument bits are a typed event,
 * not the original varargs logger ABI. A failure can follow packet dispatch.
 *
 * The caller supplies writer operations explicitly. This method does not bind
 * numeric constructor identities to host pointers, apply a model/profile,
 * register a native driver, provide OS I/O, or establish ASIC readiness.
 */
int32_t vn135_bm1368_set_ticket_mask_135(
    struct vn135_bm1368_frequency_device *device, uint32_t mask,
    const struct vn135_bm1368_register_ops *writer, void *write_context,
    const struct vn135_bm1368_ticket_mask_log_135 *log);
#endif
