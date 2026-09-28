/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_TEMPERATURE_START_COMPOSITION_135_H
#define VN135_TEMPERATURE_START_COMPOSITION_135_H
#include "integration/temperature_setup_135.h"
#include "integration/chain_temperature_setup_135.h"
#include "integration/chip_sensor_check_135.h"

/* Offline composition of three explicitly pinned pending PRs. Not a driver ABI.
 * The descriptor view and general.model project the SAME logical source model:
 * table_count == sensor_count, types/roles fit all positive sensor counts.
 * Stable backend/view/ops/object identities and serialized bounded callbacks.
 * Keep existing initializer's narrower contract (stable sensor descriptors/index,
 * callbacks modify only documented outputs). No live object mutation/concurrency.
 * Reached callbacks are required except the two log hooks. Numeric handler keys
 * stay opaque. stop/key/register remain external; no registry or success fallback.
 * Returns the ORIGINAL coordinator result; zero is NOT physical sensor readiness.
 */
struct vn135_temperature_start_composition_ops {
    const struct vn135_monitor_handler_ops *handlers;
    const struct vn135_temperature_ops *temperature;
    int32_t (*stop_chain)(void *,struct vn135_route_chain *,const char *);
    uint32_t (*reply_key)(void *);
    void (*register_reply)(void *,uint32_t,struct vn135_general_monitor *,uint32_t);
};
int32_t vn135_temperature_start_composition_135(
    struct vn135_temperature_setup_view *,
    const struct vn135_temperature_start_composition_ops *,void *);
#endif
