/* Original rescue-service stop entry 0x287a4..0x28890.
 * The 26f54 creator references /tmp/build/src/frontend/rescue.c, creates 26fe8,
 * and shares the exact handle/flag globals with 287a4. The worker names itself
 * rescue-service@btm. This module placement follows that verified association;
 * the stop entry itself contains no filename literal. No service main/body or
 * network, pool, devfee, persistence or hardware implementation is added.
 * Evidence: integration/evidence/rescue_stop_135.json.
 */
#ifdef VN135_RESCUE_STOP_135
#ifndef VN135_BACKEND_SHUTDOWN_135
#error "Rescue stop requires the recovered thread helper"
#endif
#include "integration/rescue_stop_135.h"
void vn135_rescue_service_stop_135(struct vn135_shutdown_thread *worker,
    const struct vn135_shutdown_ops *ops, void *opaque)
{
    /* Same ordered operations as the existing backend thread-stop helper.
     * Source opaque tests n*(n-1)&1 are always zero for any 32-bit word;
     * the unchanged ARM body, including those tests, remains the oracle. */
    vn135_shutdown_thread_stop_135(worker, ops, opaque);
}
#endif
