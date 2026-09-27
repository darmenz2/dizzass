/* Original 6ec4c coordinator. Offline views, not a vendor ABI or driver. */
#ifndef VN135_TEMPERATURE_SETUP_135_H
#define VN135_TEMPERATURE_SETUP_135_H
#include "integration/monitor_handlers_135.h"
#include "integration/backend_resume_135.h"

struct vn135_temperature_setup_view {
    struct vn135_monitor_handlers *backend;
    /* Existing description count/types project config+38 -> table+18/entries.
     * roles supplies entry+4, missing from the existing resume description.
     * Both refer to the current logical backend model, not sensor state. */
    const struct vn135_resume_description *description;
    const uint32_t *roles;
};
struct vn135_temperature_setup_ops {
    const struct vn135_monitor_handler_ops *handlers;
    /* Original 58b50. This callee, including sensor I/O, remains explicit. */
    int32_t (*initialize_chain)(void *, struct vn135_route_chain *, uint32_t mode);
    /* Original 56d18: may bind existing vn135_chain_stop_135. */
    int32_t (*stop_chain)(void *, struct vn135_route_chain *, const char *reason);
    uint32_t (*reply_key)(void *); /* Current backend+19c; no guessed default. */
    /* Observed 108b40 call. The unused returned pair is intentionally omitted
     * from this typed interface. handler_identity=78aa4 is NOT a host address.
     * Registry implementation, lifetime/drain and invocation are not provided. */
    void (*register_reply)(void *, uint32_t key,
                           struct vn135_general_monitor *, uint32_t handler_identity);
    int32_t (*check_chip_sensors)(void *, struct vn135_general_monitor *); /* 78eb8 */
};
/* Requires live, valid views and all reached callbacks, except handlers->log.
 * Each positive chain count and descriptor count fits its allocated arrays.
 * Initial count is cached for initialization. Later model scans/counts are
 * independent. Callback effects are serialized; they may replace description,
 * roles and chain-array selections, preserving the lifetime of captured objects.
 * backend/general identity and ops remain stable throughout the call.
 * Mode and suppress_thermal reuse existing general fields +50 and +f6.
 * The existing 60a2c C implementation is called directly, not replaced by a
 * success stub. A return of zero is a control result, not hardware acceptance;
 * the no-applicable-descriptor path returns zero even with no usable chains.
 * No new synchronization, sensor command, callback registry or production link. */
int32_t vn135_backend_temperature_setup_135(struct vn135_temperature_setup_view *,
    const struct vn135_temperature_setup_ops *, void *);
#endif
