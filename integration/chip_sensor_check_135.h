/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_CHIP_SENSOR_CHECK_135_H
#define VN135_CHIP_SENSOR_CHECK_135_H
#include "integration/general_monitor_135.h"

/* Original 78eb8: existential availability, NOT measurement/health/safety.
 * Returns exactly 1 if a usable chain has any kind 1/2, role 2 sensor whose
 * state is not 3; otherwise 0. In particular state 0 is NOT rejected.
 * The model sensor count is captured BEFORE the single fe668 callback. Chain
 * banks are read afterwards. No cached chain.sensor_count or chip_count is used.
 *
 * Requires a valid general/model and count callback. Each positive chain count
 * fits general.chains; every reached positive sensor count fits that chain's
 * sensor array. count may replace the model/chain bank and scalar contents,
 * but captured objects remain alive; after count returns, all reads are stable
 * and serialized. No locks, device calls, writes, new defaults or ABI overlay.
 * Unknown/corrupt pointers/counts and real concurrent mutation are not supported.
 *
 * Bind from general_ops.call for VN135_G_CHIP_SENSOR_TEST, forwarding count to
 * the same caller's VN135_G_CHAIN_COUNT. Example in the composed tests. No new
 * automatic driver registration or fallback for other call identities is added.
 */
int32_t vn135_backend_has_chip_sensor_135(struct vn135_general_monitor *general,
    int32_t (*chain_count)(void *), void *context);
#endif
