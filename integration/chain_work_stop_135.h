/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_CHAIN_WORK_STOP_135_H
#define VN135_CHAIN_WORK_STOP_135_H
#include "integration/backend_shutdown_135.h"
/* Host field projections, NOT vendor ABI or native work/uart objects. */
struct vn135_chain_work_stop_view {
    int32_t *index;
    struct vn135_shutdown_thread *worker;
    uint32_t *head, *tail;
    void **allocation;
    const uint32_t *uart_method; /* live feeec slot654c1c identity */
    void *queue_mutex, *chain_mutex, *uart;
};
struct vn135_chain_work_stop_ops {
    int32_t (*count)(void *);
    int32_t (*mutex)(void *, uint32_t entry, void *identity);
    int32_t (*cancel)(void *, uint32_t handle);
    int32_t (*join)(void *, uint32_t handle, uint32_t *result);
    void (*release)(void *, void *allocation);
    void (*uart_destroy)(void *, uint32_t method, void *uart);
    void (*log)(void *, uint32_t prefix, uint32_t source, uint32_t group,
        uint32_t line, uint32_t severity, uint32_t message, uint32_t index_plus_one);
};
/* Entire c39a8 with nested d2144 and live feeec dispatch. Void: original caller
 * ignores incidental r0; no success result invented. Required valid distinct
 * fields/objects, stable view/ops members and serialized bounded callbacks.
 * All field pointers, object identities and callback pointers stay fixed;
 * callbacks may change pointed-to values. Storage remains alive throughout.
 * queue_mutex identifies original633bf0; chain_mutex/uart identify chain+2e0/
 * +2b8; allocation projects chain+2f8. Numeric methods are data, never executed.
 * No guessed mapping from an arbitrary native cgminer work/pool/uart object.
 * UART target body remains explicit. Existing uart_destroy has a narrower
 * fd/mutex domain; it is not an automatic fallback for this interface.
 * No OS, ASIC or asynchronous cancellation guarantee; errors stay ignored. */
void vn135_chain_work_stop_135(struct vn135_chain_work_stop_view *,
    const struct vn135_chain_work_stop_ops *, void *);
#endif
