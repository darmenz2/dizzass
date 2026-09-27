/* Offline c33d0 projection. ARM identities are data, never host entry points. */
#ifndef VN135_CHAIN_WORK_START_135_H
#define VN135_CHAIN_WORK_START_135_H
#include <stdint.h>
#include "integration/backend_shutdown_135.h"
struct vn135_chain_work_start_view {
    int32_t *index;        /* chain+18 */
    int32_t *device_index; /* chain+2d0 */
    struct vn135_shutdown_thread *worker; /* handle314, byte318 */
    const uint32_t *path_method; /* live BSS654b4c, fef3c */
    const uint32_t *open_method; /* live BSS654c18, fee4c */
    void *chain, *mutex, *queue, *uart; /* +0,+2e0,+2f8,+2b8 identities */
};
struct vn135_chain_work_start_ops {
    int32_t (*count)(void *);
    int32_t (*mutex_init)(void *,void *object,uint32_t attributes);
    int32_t (*queue_init)(void *,void *object,uint32_t capacity,uint32_t stride);
    void *(*path)(void *,uint32_t method,int32_t index);
    int32_t (*open)(void *,uint32_t method,void *uart,void *path);
    int32_t (*create)(void *,uint32_t *handle,uint32_t attributes,
                      uint32_t entry,void *argument);
    void (*log)(void *,uint32_t prefix,uint32_t source,uint32_t group,
                uint32_t line,uint32_t severity,uint32_t message,uintptr_t argument);
};
/* Valid nonaliasing fields, complete callbacks, serialized invocation required.
 * ALL view field pointers, object identities and callback identities remain fixed.
 * Callbacks may synchronously change pointed-to values, including method slots.
 * No native ABI casts, OS operations, production defaults or async safety claim.
 * Init returns ignored, open/create nonzero => -1, no rollback. Handle writes
 * persist on failure; success does not set running or prove hardware readiness.
 * Path identity may be NULL and is retained across open and its diagnostic.
 * d19b0 and selected path/UART bodies are mandatory explicit boundaries, not
 * automatic uses of helpers whose object guards/diagnostics differ. */
int32_t vn135_chain_work_start_135(const struct vn135_chain_work_start_view *,
    const struct vn135_chain_work_start_ops *,void *context);
#endif
