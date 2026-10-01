/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_TRANSPORT_INITIALIZE_135_H
#define VN135_TRANSPORT_INITIALIZE_135_H
#include <stdint.h>

/* Bounded projection of cgminer d21dc..d24ec, not the vendor/native ABI.
 * Method words are original cgminer uint32_t address IDENTITIES, never callable
 * host pointers. No original instruction or selected constructor runs here.
 * Source table offsets are +0x18 in shared transport, +0x00 in caller output.
 * Expose each as an aligned writable uint32_t; do not cast a native cgminer
 * object or an entire vendor memory image to this new view.
 */
struct vn135_transport_initialize_view_135 {
    uint32_t *shared_send_method;
    uint32_t *common_method;
    void *chip_methods;
};

struct vn135_transport_initialize_ops_135 {
    /* REQUIRED selected-constructor boundary. Receives one of the eight
     * original entry identities and the unchanged caller output identity.
     * It is not a successful constructor substitute. Its full signed status
     * and any pointed-to mutations survive unchanged; effects are caller-owned.
     */
    int32_t (*initialize)(void *context, uint32_t original_entry,
                          void *chip_methods);
};

/* Platform and chip bounds are unsigned. Platform >4 returns -1 without
 * dereferencing v/o. For a valid platform, publish shared send and common
 * callback BEFORE rejecting chip >7 with -1 (no o dereference in that case).
 * Otherwise call the selected initializer exactly once and return its status.
 * Subtype only affects platform 0: zero versus any nonzero word.
 *
 * Valid-platform domain: stable v, aligned writable uint32_t slots,
 * correct common-slot/output association and initialized caller-owned storage.
 * chip_methods is non-NULL and denotes the same output base as common_method.
 * Valid-chip domain additionally requires stable o and a non-NULL initializer;
 * chip_methods is passed unchanged. The selected constructor's own size and
 * additional memory requirements remain its responsibility.
 * The two slots may be the SAME uint32_t object (common store wins); no partial
 * overlap or overlap with v/o. Identities/views stay fixed through return.
 * Callbacks may mutate pointed-to state synchronously; no rollback follows.
 * Serialize ALL users of the shared method slot. No atomic/concurrent/fault,
 * invalid aliasing, async-signal, cancellation or nonlocal-return equivalence is
 * claimed.
 * No allocation, fd/termios operation, device registration or implicit defaults.
 */
int32_t vn135_transport_initialize_135(uint32_t platform, uint32_t chip,
    uint32_t subtype, const struct vn135_transport_initialize_view_135 *v,
    const struct vn135_transport_initialize_ops_135 *o, void *context);
#endif
