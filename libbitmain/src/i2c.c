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

/* Software-I2C slice 0x126e0c..0x1289c4. Original routines are kept separate
 * from the hardware-I2C functions above. No physical GPIO calls are supplied. */
#include "integration/i2c_soft_135.h"

static void soft_log(struct vn135_i2c_soft *s, uint32_t line,
                     uint32_t severity, uint32_t arg)
{
    if (s->ops->log) s->ops->log(s->opaque,line,severity,arg);
}
static void soft_delay(struct vn135_i2c_soft *s)
{
    (void)s->ops->delay_ms(s->opaque,1);
}
static void soft_value(struct vn135_i2c_soft *s, int32_t fd,
                       uint8_t value, uint32_t line)
{
    if (s->ops->write(s->opaque,fd,&value,1)!=1) soft_log(s,line,1,0);
}
static void soft_sda(struct vn135_i2c_soft *s, unsigned high)
{
    soft_value(s,s->sda_value_fd,(uint8_t)(high?'1':'0'),high?192:200);
}
static void soft_scl(struct vn135_i2c_soft *s, unsigned high)
{
    soft_value(s,s->scl_value_fd,(uint8_t)(high?'1':'0'),high?208:216);
}
void vn135_i2c_soft_sda_input(struct vn135_i2c_soft *s)
{
    if (!s->sda_output) return;
    if (s->ops->write(s->opaque,s->sda_direction_fd,(const uint8_t *)"in",2)!=2)
        soft_log(s,174,1,0);
    (void)s->ops->close(s->opaque,s->sda_value_fd);
    s->sda_value_fd=-1;
    s->sda_value_fd=s->ops->open(s->opaque,s->sda_value_path,2);
    if (s->sda_value_fd<0) soft_log(s,181,1,0);
    s->sda_output=0;
}
void vn135_i2c_soft_sda_output(struct vn135_i2c_soft *s)
{
    if (s->sda_output) return;
    if (s->ops->write(s->opaque,s->sda_direction_fd,(const uint8_t *)"out",3)!=3)
        soft_log(s,154,2,0);
    (void)s->ops->close(s->opaque,s->sda_value_fd);
    s->sda_value_fd=-1;
    s->sda_value_fd=s->ops->open(s->opaque,s->sda_value_path,1);
    if (s->sda_value_fd<0) soft_log(s,162,1,0);
    s->sda_output=1;
}
void vn135_i2c_soft_start(struct vn135_i2c_soft *s)
{
    vn135_i2c_soft_sda_output(s);
    soft_sda(s,1);
    soft_scl(s,1);
    soft_delay(s);
    soft_sda(s,0);
    soft_delay(s);
}
void vn135_i2c_soft_stop(struct vn135_i2c_soft *s)
{
    vn135_i2c_soft_sda_output(s);
    soft_scl(s,0);
    soft_delay(s);
    soft_sda(s,0);
    soft_scl(s,1);
    soft_delay(s);
    soft_sda(s,1);
    soft_delay(s);
}
void vn135_i2c_soft_send_bits(struct vn135_i2c_soft *s, uint32_t value)
{
    unsigned mask,attempt,sample;
    uint8_t bit;
    vn135_i2c_soft_sda_output(s);
    for (mask=128;mask;mask>>=1) {
        soft_scl(s,0);
        soft_delay(s);
        soft_sda(s,(value&mask)!=0);
        soft_scl(s,1);
        soft_delay(s);
    }
    /* Four ACK windows, up to six samples each; data bits are NOT resent. */
    for (attempt=0;attempt<4;++attempt) {
        soft_scl(s,0);
        soft_delay(s);
        vn135_i2c_soft_sda_input(s);
        for (sample=0;sample<6;++sample) {
            if (s->ops->read(s->opaque,s->sda_value_fd,&bit,1)!=1) {
                soft_log(s,245,1,0);
                break;
            }
            if (bit=='0') {
                soft_scl(s,1);
                soft_delay(s);
                return;
            }
            soft_scl(s,1);
            soft_delay(s);
            soft_scl(s,0);
            soft_delay(s);
        }
        soft_log(s,279,1,0);
        soft_scl(s,1);
        soft_delay(s);
    }
    soft_log(s,309,1,4);
}
int vn135_i2c_soft_write_byte(struct vn135_i2c_soft *s, uint32_t address,
    uint32_t register_mode, uint32_t reg, uint32_t value)
{
    vn135_i2c_soft_start(s);
    vn135_i2c_soft_send_bits(s,(uint8_t)(address<<1));
    if (register_mode) vn135_i2c_soft_send_bits(s,reg);
    vn135_i2c_soft_send_bits(s,value);
    vn135_i2c_soft_stop(s);
    return 0;
}
uint8_t vn135_i2c_soft_read_byte(struct vn135_i2c_soft *s, uint32_t address,
    uint32_t register_mode, uint32_t reg)
{
    unsigned mask;
    uint8_t value=0,bit;
    vn135_i2c_soft_start(s);
    /* Original sends the READ address first even when a register follows. */
    vn135_i2c_soft_send_bits(s,(uint8_t)((address<<1)|1u));
    if (register_mode) vn135_i2c_soft_send_bits(s,reg);
    vn135_i2c_soft_sda_input(s);
    for (mask=128;mask;mask>>=1) {
        soft_scl(s,0);
        soft_delay(s);
        (void)s->ops->close(s->opaque,s->sda_value_fd);
        /* Unlike direction helpers, original keeps old fd during open. */
        s->sda_value_fd=s->ops->open(s->opaque,s->sda_value_path,0);
        if (s->sda_value_fd<0) {
            soft_scl(s,1);
            value=255;
            goto finish;
        }
        if (s->ops->read(s->opaque,s->sda_value_fd,&bit,1)!=1) {
            soft_log(s,245,1,0);
            soft_scl(s,1);
            value=255;
            goto finish;
        }
        soft_scl(s,1);
        if (bit!='0') value|=(uint8_t)mask;
        soft_delay(s);
    }
    soft_scl(s,0);
    soft_delay(s);
    vn135_i2c_soft_sda_output(s);
    soft_sda(s,1);
    soft_scl(s,1);
finish:
    soft_delay(s);
    vn135_i2c_soft_stop(s);
    return value;
}

/* Original registration 0x125a28, GPIO init 0x126084 and close 0x126d14. */
#include "integration/i2c_init_135.h"
#include <inttypes.h>
#include <stdio.h>

static int init_error(const struct vn135_i2c_init_ops *o, void *p, uint32_t line)
{
    if (o->log) o->log(p,VN135_INIT_GENERIC,line);
    return -1;
}
int vn135_i2c_register_135(struct vn135_i2c_registration *s,
    const struct vn135_i2c_init_ops *o, void *p, uint32_t kind, uint32_t index,
    const char *name)
{
    s->kind=kind;
    s->index=index;
    s->name=o->duplicate(p,name);
    if (!s->name) return init_error(o,p,25);
    (void)o->mutex_step(p,VN135_ATTR_INIT,s,0);
    (void)o->mutex_step(p,VN135_ATTR_SETTYPE,s,1);
    (void)o->mutex_step(p,VN135_MUTEX_INIT,s,0);
    (void)o->mutex_step(p,VN135_ATTR_DESTROY,s,0);
    return 0;
}
int vn135_i2c_gpio_initialize_135(struct vn135_i2c_gpio_init *s,
    const struct vn135_i2c_init_ops *o, void *p, int32_t sda, int32_t scl)
{
    char number[256]={0};
    int32_t fd;
    uint32_t n;
    (void)snprintf(s->sda_direction,256,"/sys/class/gpio/gpio%" PRId32 "/direction",sda);
    (void)snprintf(s->sda_value,256,"/sys/class/gpio/gpio%" PRId32 "/value",sda);
    (void)snprintf(s->scl_direction,256,"/sys/class/gpio/gpio%" PRId32 "/direction",scl);
    (void)snprintf(s->scl_value,256,"/sys/class/gpio/gpio%" PRId32 "/value",scl);
    s->sda_pin=sda; s->scl_pin=scl;
    s->sda_mode=1; s->scl_mode=1;
    if (o->is_exported(p,sda)) (void)o->unexport(p,sda);
    if (o->is_exported(p,scl)) (void)o->unexport(p,scl);
    fd=o->io.open(p,"/sys/class/gpio/export",1);
    if (fd==-1) return init_error(o,p,40);
    (void)snprintf(number,256,"%" PRId32,sda);
    n=(uint32_t)strlen(number);
    if ((uint32_t)o->io.write(p,fd,(const uint8_t *)number,n)!=n)
        return init_error(o,p,48);
    (void)o->io.close(p,fd);
    fd=o->io.open(p,s->sda_direction,1);
    if (fd==-1) return init_error(o,p,58);
    if (o->io.write(p,fd,(const uint8_t *)"out",3)!=3)
        return init_error(o,p,63);
    (void)o->io.close(p,fd);
    fd=o->io.open(p,"/sys/class/gpio/export",1);
    if (fd==-1) return init_error(o,p,73);
    (void)snprintf(number,256,"%" PRId32,scl);
    n=(uint32_t)strlen(number);
    if ((uint32_t)o->io.write(p,fd,(const uint8_t *)number,n)!=n)
        return init_error(o,p,81);
    (void)o->io.close(p,fd);
    fd=o->io.open(p,s->scl_direction,1);
    if (fd==-1) return init_error(o,p,91);
    if (o->io.write(p,fd,(const uint8_t *)"out",3)!=3)
        return init_error(o,p,96);
    (void)o->io.close(p,fd);
    s->soft.sda_output=1;
    if (s->soft.scl_value_fd>=1) (void)o->io.close(p,s->soft.scl_value_fd);
    s->soft.scl_value_fd=o->io.open(p,s->scl_value,1);
    if (s->soft.scl_value_fd<0) return init_error(o,p,111);
    if (s->soft.sda_value_fd>=1) (void)o->io.close(p,s->soft.sda_value_fd);
    s->soft.sda_value_fd=o->io.open(p,s->sda_value,1);
    if (s->soft.sda_value_fd<0) return init_error(o,p,120);
    if (s->soft.sda_direction_fd>=1) (void)o->io.close(p,s->soft.sda_direction_fd);
    s->soft.sda_direction_fd=o->io.open(p,s->sda_direction,1);
    if (s->soft.sda_direction_fd<0) return init_error(o,p,129);
    return 0;
}
void vn135_i2c_gpio_close_135(struct vn135_i2c_gpio_init *s,
    const struct vn135_i2c_init_ops *o, void *p)
{
    if (s->soft.scl_value_fd>=1) (void)o->io.close(p,s->soft.scl_value_fd);
    if (s->soft.sda_value_fd>=1) (void)o->io.close(p,s->soft.sda_value_fd);
    if (s->soft.sda_direction_fd>=1) (void)o->io.close(p,s->soft.sda_direction_fd);
}
