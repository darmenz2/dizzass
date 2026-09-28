/* Original a6080: stop the voltage-control worker. Offline projection only. */
#ifndef VN135_VOLTAGE_STOP_135_H
#define VN135_VOLTAGE_STOP_135_H
#include "integration/rescue_stop_135.h"

/* A separate slot projects backend word+0x1024 and byte+0x1028.
 * It is neither rescue's global slot nor any of shutdown_state.threads[10].
 * The adapter owns its binding; do not cast a vendor backend to this type.
 * Required: valid stable storage; reached self/detach/cancel/join callbacks
 * exist, terminate and serialize their effects. Handles are 32-bit source
 * words, not host pthread_t. Other ops fields are unused.
 * Flag clears before self; handle loads after self and after cancel. Errors
 * are ignored, handle is not cleared, no lock/timeout/retry is invented.
 * Return does not certify a real worker has terminated or changed voltage.
 *
 * Build with VN135_VOLTAGE_STOP_135, VN135_BACKEND_SHUTDOWN_135 and
 * VN135_RESCUE_STOP_135. The latter exports the existing shared thread helper;
 * it does not start rescue, bind globals or perform OS operations. */
void vn135_voltage_controller_stop_135(struct vn135_shutdown_thread *,
    const struct vn135_shutdown_ops *, void *opaque);
#endif
