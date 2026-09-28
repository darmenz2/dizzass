/* SPDX-License-Identifier: GPL-3.0-only */
/* Typed forwarding only; all algorithms remain the unchanged linked functions. */
#include "integration/resume_temperature_135.h"
struct binding {
    const struct vn135_resume_ops *resume;
    const struct vn135_backend_power_ops *power;
    struct vn135_temperature_setup_view *temperature;
    const struct vn135_temperature_start_composition_ops *temperature_ops;
    void *context;
};
static int32_t step(void *p,enum vn135_resume_step e,uint32_t a,uint32_t b,uint32_t c)
{
    struct binding *s=p;
    if(e==VN135_R_CONFIG_6EC4C)
        return vn135_temperature_start_composition_135(s->temperature,s->temperature_ops,s->context);
    return s->resume->step(s->context,e,a,b,c);
}
static int32_t create(void *p,uint32_t off,uint32_t entry,uintptr_t *handle)
{ struct binding *s=p;return s->resume->thread_create(s->context,off,entry,handle); }
static int32_t join(void *p,uintptr_t handle,uintptr_t *result)
{ struct binding *s=p;return s->resume->thread_join(s->context,handle,result); }
static char *duplicate(void *p,const char *text)
{ struct binding *s=p;return s->resume->duplicate(s->context,text); }
static void release(void *p,char *text)
{ struct binding *s=p;s->resume->release(s->context,text); }
static double now(void *p)
{ struct binding *s=p;return s->resume->timestamp(s->context); }
static void log_resume(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b)
{ struct binding *s=p;if(s->resume->log)s->resume->log(s->context,line,level,a,b); }
static int32_t on(void *p)
{ struct binding *s=p;return s->power->psu_on(s->context); }
static int32_t off(void *p)
{ struct binding *s=p;return s->power->psu_off(s->context); }
static int32_t voltage(void *p,uint16_t v)
{ struct binding *s=p;return s->power->set_voltage(s->context,v); }
static int32_t count(void *p)
{ struct binding *s=p;return s->power->chain_count(s->context); }
static int32_t reset(void *p,uint32_t i)
{ struct binding *s=p;return s->power->reset_chain(s->context,i); }
static void log_power(void *p,enum vn135_gpio_power_source source,uint32_t line,uint32_t a)
{ struct binding *s=p;if(s->power->log)s->power->log(s->context,source,line,a); }
int32_t vn135_resume_temperature_135(struct vn135_resume_state *r,
    const struct vn135_resume_ops *o,const struct vn135_backend_power_ops *pw,
    struct vn135_temperature_setup_view *v,
    const struct vn135_temperature_start_composition_ops *to,void *context,uintptr_t *scratch)
{
    struct binding s={o,pw,v,to,context};
    const struct vn135_resume_ops ro={step,create,join,duplicate,release,now,log_resume};
    const struct vn135_backend_power_ops po={on,off,voltage,count,reset,log_power};
    return vn135_backend_resume_135(r,&ro,&po,&s,scratch);
}
