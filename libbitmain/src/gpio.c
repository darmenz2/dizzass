/* Selected original /tmp/build/libbitmain/src/gpio.c, VNishNet 1.3.5.
 * 0x1248e4, 0x124b5c, 0x124ba4, 0x124d64, 0x124f70, 0x1251b8.
 * Preserve stdio call order and ignored errors. No physical GPIO access.
 */
#include "integration/gpio_power_135.h"
#include <inttypes.h>
#include <stdio.h>

static int32_t signed_pin(uint32_t x)
{ return x <= INT32_MAX ? (int32_t)x : -1 - (int32_t)(UINT32_MAX-x); }
static void path_for(char path[256], uint32_t pin, const char *suffix)
{ (void)snprintf(path,256,"/sys/class/gpio/gpio%" PRId32 "%s",signed_pin(pin),suffix); }
static int opened_error(const struct vn135_gpio_io *g, uint32_t line, uint32_t arg)
{
    (void)g->ops->unlock(g->opaque);
    if(g->ops->log)g->ops->log(g->opaque,VN135_GP_GPIO,line,arg);
    g->ops->perror(g->opaque,"fopen");
    return -1;
}
int vn135_gpio_export_direction_135(const struct vn135_gpio_io *g,
    uint32_t pin, uint32_t direction)
{
    uintptr_t f; char path[256];
    (void)g->ops->lock(g->opaque);
    f=g->ops->fopen(g->opaque,"/sys/class/gpio/export","w");
    if(!f)return opened_error(g,24,0);
    (void)g->ops->fprintf_number(g->opaque,f,"%u",pin);
    (void)g->ops->fclose(g->opaque,f);
    path_for(path,pin,"/direction");
    f=g->ops->fopen(g->opaque,path,"w");
    if(!f)return opened_error(g,36,0);
    (void)g->ops->fputs(g->opaque,direction?"out":"in",f);
    (void)g->ops->fclose(g->opaque,f);
    (void)g->ops->unlock(g->opaque);
    return 0;
}
int vn135_gpio_is_exported_135(const struct vn135_gpio_io *g,uint32_t pin)
{
    char path[256]; path_for(path,pin,"");
    return g->ops->access(g->opaque,path,0)==0;
}
int vn135_gpio_set_value_135(const struct vn135_gpio_io *g,uint32_t pin,uint32_t value)
{
    uintptr_t f; char path[256];
    (void)g->ops->lock(g->opaque);
    path_for(path,pin,"/value");
    f=g->ops->fopen(g->opaque,path,"w");
    if(!f)return opened_error(g,72,pin);
    (void)g->ops->fprintf_number(g->opaque,f,"%d",value?1u:0u);
    (void)g->ops->fclose(g->opaque,f);
    (void)g->ops->unlock(g->opaque);
    return 0;
}
int vn135_gpio_get_value_135(const struct vn135_gpio_io *g,uint32_t pin,
    uint8_t *scratch,uint32_t *out)
{
    uintptr_t f; char path[256],token[2];
    (void)g->ops->lock(g->opaque);
    path_for(path,pin,"/value");
    f=g->ops->fopen(g->opaque,path,"r");
    if(!f)return opened_error(g,95,0);
    (void)g->ops->fscanf_char(g->opaque,f,scratch);
    token[0]=(char)*scratch; token[1]='\0';
    (void)g->ops->sscanf_uint(g->opaque,token,out);
    *out=*scratch!=(uint8_t)'0';
    (void)g->ops->fclose(g->opaque,f);
    (void)g->ops->unlock(g->opaque);
    return 0;
}
int vn135_gpio_set_direction_135(const struct vn135_gpio_io *g,uint32_t pin,uint32_t direction)
{
    uintptr_t f; char path[256];
    (void)g->ops->lock(g->opaque);
    path_for(path,pin,"/direction");
    f=g->ops->fopen(g->opaque,path,"w");
    if(!f)return opened_error(g,136,0);
    (void)g->ops->fputs(g->opaque,direction?"out":"in",f);
    (void)g->ops->fclose(g->opaque,f);
    (void)g->ops->unlock(g->opaque);
    return 0;
}
int vn135_gpio_unexport_135(const struct vn135_gpio_io *g,uint32_t pin)
{
    uintptr_t f;
    (void)g->ops->lock(g->opaque);
    f=g->ops->fopen(g->opaque,"/sys/class/gpio/unexport","w");
    if(!f)return opened_error(g,160,0);
    (void)g->ops->fprintf_number(g->opaque,f,"%u",pin);
    (void)g->ops->fclose(g->opaque,f);
    (void)g->ops->unlock(g->opaque);
    return 0;
}
