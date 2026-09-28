/* Original entry 58d08: conditional reset of one chain's sensor records.
 * Vendor source filename for this helper is not established. This path is a
 * recovery-support location, not a claimed original filename. No hardware I/O. */
#include "integration/sensor_monitor_135.h"
void vn135_temperature_chain_cleanup_135(struct vn135_route_chain *chain,
    int32_t count,const struct vn135_temperature_ops *ops,void *opaque)
{
    int32_t i;
    /* The original resolves the model before checking presence. Its valid
     * immutable sensor count is supplied explicitly by the typed projection. */
    if(!chain->present)return;
    for(i=0;i<count;++i)
        if(chain->sensors[i].state)
            vn135_temperature_reset(&chain->sensors[i],ops,opaque);
}
