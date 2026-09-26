/* Original a6080..a6190: voltage-control worker stop.
 * a20a0 creates a2218 using backend+1024; the worker checks byte+1028 and
 * names itself volt_ctrl@btm. Its full filename literal decodes to
 * /tmp/build/src/backend/volt-ctrl.c. Evidence: voltage_stop_135.json.
 * Only stop is recovered, NOT the live voltage-control loop or its creator.
 */
#ifdef VN135_VOLTAGE_STOP_135
#if !defined(VN135_RESCUE_STOP_135) || !defined(VN135_BACKEND_SHUTDOWN_135)
#error "Voltage stop requires the existing shared shutdown thread helper"
#endif
#include "integration/voltage_stop_135.h"

void vn135_voltage_controller_stop_135(struct vn135_shutdown_thread *worker,
    const struct vn135_shutdown_ops *ops, void *opaque)
{
    /* Same ordered observable effects as shutdown_thread_135. Original
     * opaque n*(n-1)&1 branches cannot become true for any 32-bit n.
     * The independent oracle still executes the unchanged ARM instructions. */
    vn135_shutdown_thread_stop_135(worker, ops, opaque);
}
#endif
