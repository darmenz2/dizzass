/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_WORK_STOP_135_H
#define VN135_WORK_STOP_135_H
#include "integration/backend_shutdown_135.h"

/* Existing thread projection reused; neither it nor these views are an ABI. */
struct vn135_work_stop_chain {
    const uint8_t *enabled_318;
    void *object; /* identity corresponding to this byte, not a native work */
};
struct vn135_work_stop_view {
    struct vn135_shutdown_thread *producer, *receiver, *sender;
    const struct vn135_work_stop_chain *chains; /* live backend+230 projection */
    uint32_t chain_method;                     /* live backend+200 identity */
};
struct vn135_work_stop_ops {
    int32_t (*chain_count)(void *); /* fe668, no backend argument */
    int32_t (*cancel)(void *, uint32_t handle);
    int32_t (*join)(void *, uint32_t handle, uint32_t *result);
    int32_t (*destroy)(void *, uint32_t entry, uint32_t identity);
    int32_t (*chain)(void *, uint32_t method, void *object);
};
/* Entire c3e18. Required valid nonoverlapping objects/callbacks and stable
 * thread/ops identities. Thread values, chain base/method and enabled bytes may
 * change at serialized callbacks. Each selected chain descriptor pairs the
 * original byte+318 and its object identity; no arbitrary pointer alias model.
 * Every positive count fits every reached chain array; original 800-byte stride
 * and addresses do not wrap. Descriptors/storage remain alive during this call.
 * Negative/zero signed counts skip only traversal, not thread/sync cleanup.
 * Numeric entry/identity tokens are never executed or dereferenced on the host.
 * All external results are ignored as in the source. Return0 is the original
 * value, NOT proof of worker termination or successful destruction/cleanup.
 * No real threads, fallback, retries, rollback, production or hardware I/O. */
int32_t vn135_work_stop_135(struct vn135_work_stop_view *,
    const struct vn135_work_stop_ops *, void *);
#endif
