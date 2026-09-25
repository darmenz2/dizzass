/* Selected procedures from /tmp/build/libbitmain/src/i2c.c, VNishNet 1.3.5.
 * 0x125c64: close; 0x125cf4: open. Remaining module is not reconstructed.
 * External operations are explicit callbacks. No native hardware I/O here.
 */
#include "integration/i2c_transport_135.h"
#include <string.h>

int vn135_i2c_hw_close(struct vn135_i2c_transport *t, struct vn135_i2c_iface *iface)
{
    (void)t->ops->close(t->opaque,iface->fd);
    iface->fd=-1;
    return 0;
}
int vn135_i2c_hw_open(struct vn135_i2c_transport *t, struct vn135_i2c_iface *iface,
                       const char *path)
{
    if(!strcmp(path,"/dev/")) {
        iface->fd=-1;
        return 0;
    }
    iface->fd=t->ops->open(t->opaque,path,0x802);
    if(iface->fd<0) {
        if(t->ops->log)t->ops->log(t->opaque,VN135_I2C_GENERIC,67,0,0,0,path);
        return -1;
    }
    return 0;
}
