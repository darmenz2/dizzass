/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_RESUME_TEMPERATURE_135_H
#define VN135_RESUME_TEMPERATURE_135_H
#include "integration/backend_resume_135.h"
#include "integration/temperature_start_composition_135.h"
/* Offline composition, not a production device_drv or a vendor pthread ABI.
 * Same logical backend/context throughout; temperature->description is the
 * resume description. All duplicated host projections of chain state, sensor
 * counts and sensor words describe ONE source object at each call boundary.
 * Their synchronization is the caller's responsibility, not an implicit copy.
 * All old original-domain bounds/lifetimes still apply. Required callbacks
 * terminate; log callbacks remain optional. No asynchronous mutation modeled.
 * Only 6ec4c is rebound. Other lifecycle/device operations remain required.
 * Return is the existing resume result, not a readiness status. This adapter
 * never adds rollback/shutdown, starts real threads or manages a registry.
 */
int32_t vn135_resume_temperature_135(struct vn135_resume_state *,
    const struct vn135_resume_ops *,const struct vn135_backend_power_ops *,
    struct vn135_temperature_setup_view *,
    const struct vn135_temperature_start_composition_ops *,void *,uintptr_t *);
#endif
