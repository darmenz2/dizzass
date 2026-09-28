/* Original 0x287a4: stop the rescue-service worker, not the whole service.
 * Offline field/operation projections; never cast these to a vendor ABI. */
#ifndef VN135_RESCUE_STOP_135_H
#define VN135_RESCUE_STOP_135_H
#include "integration/backend_shutdown_135.h"

/* This separate slot projects globals byte 0x68b108 and word 0x68b118.
 * It is NOT a member of backend.threads[10]. Keep its storage/identity stable.
 * Required: valid slot and ops; reached self/detach/cancel/join callbacks must
 * exist and terminate, with serialized field effects. Other ops are unused.
 * Handles are source 32-bit words, not host pthread_t. All operation errors are
 * ignored just as in the original. Return does not prove worker termination.
 * Flag is cleared before self; handle is read after self and again after
 * cancel. Self-detach uses the captured self word; join's result is NULL.
 * No lock, retry, timeout, handle clearing, state write or process exit added.
 * Build with VN135_RESCUE_STOP_135 and VN135_BACKEND_SHUTDOWN_135. */
void vn135_rescue_service_stop_135(struct vn135_shutdown_thread *,
    const struct vn135_shutdown_ops *, void *opaque);

/* Shared offline adapter to the existing, separately compared static helper.
 * Public only to reuse its body across recovered source modules; not a driver
 * registration, production API or default binding of any real thread. */
void vn135_shutdown_thread_stop_135(struct vn135_shutdown_thread *,
    const struct vn135_shutdown_ops *, void *opaque);
#endif
