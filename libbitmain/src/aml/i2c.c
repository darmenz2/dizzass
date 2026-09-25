/* Selected original /tmp/build/libbitmain/src/aml/i2c.c procedures, 1.3.5.
 * 0x11a6b0: block read; 0x11ab24: block write. Not the full AML I2C module.
 * Preserve whole-transfer retries, singleton reopen and ignored returns.
 */
#include "integration/i2c_transport_135.h"
#include <string.h>

static void emit(struct vn135_i2c_transport *t,uint32_t line,
                 uint32_t a,uint32_t b,uint32_t c,const char *text)
{
    if(t->ops->log)t->ops->log(t->opaque,VN135_I2C_AML,line,a,b,c,text);
}
static int restart(struct vn135_i2c_transport *t,uint32_t caller_line)
{
    int rc;
    (void)t->ops->lock(t->opaque,t->global);
    (void)vn135_i2c_hw_close(t,t->global);
    rc=vn135_i2c_hw_open(t,t->global,"/dev/i2c-1");
    if(rc)emit(t,49,0,0,0,NULL);
    (void)t->ops->unlock(t->opaque,t->global);
    if(rc)emit(t,caller_line,0,0,0,NULL);
    return rc;
}
int vn135_aml_i2c_read_block(struct vn135_i2c_transport *t,struct vn135_i2c_iface *iface,
    uint32_t address,uint32_t mode,uint32_t reg,uint8_t *data,uint32_t len)
{
    uint8_t low_reg=(uint8_t)reg;
    unsigned attempt;
    int32_t error;
    if(restart(t,207))return -1;
    (void)t->ops->lock(t->opaque,iface);
    for(attempt=0;attempt<5;++attempt) {
        if(t->ops->ioctl(t->opaque,iface->fd,0x703,address)==-1) {
            error=t->ops->get_errno(t->opaque);
            emit(t,215,address,(uint32_t)error,0,NULL);
        } else if(mode && t->ops->write(t->opaque,iface->fd,&low_reg,1)!=1) {
            const char *text;
            error=t->ops->get_errno(t->opaque);
            text=t->ops->error_text(t->opaque,error);
            emit(t,224,reg,(uint32_t)error,address,text);
        } else if((uint32_t)t->ops->read(t->opaque,iface->fd,data,len)==len) {
            (void)t->ops->unlock(t->opaque,iface);
            return 0;
        } else {
            error=t->ops->get_errno(t->opaque);
            emit(t,232,(uint32_t)error,0,0,NULL);
        }
        (void)t->ops->sleep_us(t->opaque,50000);
    }
    emit(t,242,5,address,0,NULL);
    (void)t->ops->unlock(t->opaque,iface);
    return -1;
}
int vn135_aml_i2c_write_block(struct vn135_i2c_transport *t,struct vn135_i2c_iface *iface,
    uint32_t address,uint32_t mode,uint32_t reg,const uint8_t *data,uint32_t len)
{
    uint8_t *allocated=NULL;
    const uint8_t *tx=data;
    uint32_t size=len;
    unsigned attempt;
    int rc=-1;
    if(restart(t,262))return -1;
    if(mode) {
        size=len+1;
        allocated=t->ops->calloc(t->opaque,size,1);
        if(!allocated){emit(t,271,0,0,0,NULL);return -1;}
        allocated[0]=(uint8_t)reg;
        memcpy(allocated+1,data,len);
        tx=allocated;
    }
    (void)t->ops->lock(t->opaque,iface);
    for(attempt=0;attempt<5;++attempt) {
        if(t->ops->ioctl(t->opaque,iface->fd,0x703,address)==-1) {
            int32_t error=t->ops->get_errno(t->opaque);
            const char *text=t->ops->error_text(t->opaque,error);
            emit(t,284,reg,(uint32_t)error,address,text);
        } else if((uint32_t)t->ops->write(t->opaque,iface->fd,tx,size)==size) {
            rc=0;
            break;
        } else emit(t,295,0,0,0,NULL);
        (void)t->ops->sleep_us(t->opaque,50000);
    }
    if(rc)emit(t,301,5,address,0,NULL);
    (void)t->ops->unlock(t->opaque,iface);
    if(allocated)t->ops->free(t->opaque,allocated);
    return rc;
}
