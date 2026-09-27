/* SPDX-License-Identifier: GPL-3.0-only */
/* Original 78eb8..790b4. Project filename; no filename literal in this body. */
#ifdef VN135_CHIP_SENSOR_CHECK_135
#include "integration/chip_sensor_check_135.h"

int32_t vn135_backend_has_chip_sensor_135(struct vn135_general_monitor *general,
    int32_t (*chain_count)(void *), void *context)
{
    const int32_t sensors = general->model->sensor_count;
    const int32_t chains = chain_count(context);
    for (int32_t i = 0; i < chains; ++i) {
        const struct vn135_route_chain *chain = &general->chains[i].thermal;
        /* Same two-field 56fcc predicate as the file-local general_alive.
         * Do not change base.c or widen its public interface merely to export it. */
        if (!chain->present || (chain->state - 3u) <= 2u || sensors < 1)
            continue;
        const struct vn135_temperature_sensor *bank = chain->sensors;
        for (int32_t j = 0; j < sensors; ++j) {
            const struct vn135_temperature_sensor *sensor = &bank[j];
            if ((sensor->access_kind - 1u) <= 1u && sensor->role == 2u &&
                sensor->state != 3u)
                return 1;
        }
    }
    return 0;
}
#endif
