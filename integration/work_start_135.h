/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_WORK_START_135_H
#define VN135_WORK_START_135_H
#include <stdint.h>

/* Host field views, not the vendor backend ABI or native pthread_t. */
struct vn135_work_start_view {
    void *backend;
    uint32_t *thread_1060, *thread_1068, *thread_1058;
    const uint32_t *producer_entry; /* live reference slot 5df978 */
    uint32_t attribute_initial;    /* original uninitialized four-byte scratch */
};
struct vn135_work_start_ops {
    int32_t (*attribute)(void *, uint32_t entry, uint32_t *scratch, uint32_t value);
    /* Mutex initialization has attribute=NULL, condition initialization uses
     * the same live scratch as attribute(). Identities are reference addresses. */
    int32_t (*initialize)(void *, uint32_t entry, uint32_t identity, uint32_t *attribute);
    int32_t (*create)(void *, uint32_t field, uint32_t *handle,
                      uint32_t attribute_identity, uint32_t entry, void *backend);
    void (*log)(void *, uint32_t category, uint32_t file, uint32_t function,
                uint32_t line, uint32_t level, uint32_t message);
};
/* Whole original c3b54, through its return. All callbacks and separate objects
 * mandatory/valid; view identities and ops immutable during the call. Handle
 * values and producer entry may change at serialized callbacks. The scratch
 * pointer is borrowed only for this call; nothing may retain it after return.
 * Init/log results do not govern flow. Create returns zero or ANY nonzero
 * int32 error, and may write a handle on either result. Such writes remain.
 * Returns original 0 or -1; does not start workers itself or invent rollback.
 * Worker/address tokens are never called/dereferenced as host addresses.
 * No async races, real pthread/ASIC, production registration or worker lifetime
 * acceptance is implied by reaching return. */
int32_t vn135_work_start_135(const struct vn135_work_start_view *,
    const struct vn135_work_start_ops *, void *);
#endif
