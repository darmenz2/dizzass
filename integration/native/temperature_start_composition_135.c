/* SPDX-License-Identifier: GPL-3.0-only */
/* Adapter only. Algorithms remain the exact pinned A-07/A-08/A-10 code. */
#include "integration/temperature_start_composition_135.h"
struct binding {
    struct vn135_temperature_setup_view *view;
    const struct vn135_temperature_start_composition_ops *ops;
    void *context;
};
static int32_t scalar(void *p,uint32_t entry,uint32_t a,uint32_t b)
{
    struct binding *s=p;
    return s->ops->handlers->call(s->context,entry,a,b);
}
static void diagnostic(void *p,uint32_t line,uint32_t level,uint32_t a,
                       uint32_t b,const char *detail)
{
    struct binding *s=p;
    if(s->ops->handlers->log)
        s->ops->handlers->log(s->context,line,level,a,b,detail);
}
static void chain_log(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b)
{ diagnostic(p,line,level,a,b,NULL); }
static int32_t sensor_init(void *p,struct vn135_route_chain *chain,
                           struct vn135_temperature_sensor *sensor)
{
    struct binding *s=p;
    struct vn135_chain_sensor_initializer_binding b={s->ops->temperature,s->context};
    return vn135_chain_sensor_initialize_existing_135(&b,chain,sensor);
}
static int32_t chain_init(void *p,struct vn135_route_chain *chain,uint32_t mode)
{
    struct binding *s=p;
    struct vn135_chain_temperature_setup_view view={s->view->backend->general,chain};
    const struct vn135_chain_temperature_setup_ops ops={sensor_init,chain_log};
    return vn135_chain_temperature_setup_135(&view,&ops,p,mode);
}
static int32_t stop_chain(void *p,struct vn135_route_chain *chain,const char *reason)
{
    struct binding *s=p;
    return s->ops->stop_chain(s->context,chain,reason);
}
static uint32_t key(void *p)
{
    struct binding *s=p;
    return s->ops->reply_key(s->context);
}
static void register_reply(void *p,uint32_t k,struct vn135_general_monitor *g,uint32_t h)
{
    struct binding *s=p;
    s->ops->register_reply(s->context,k,g,h);
}
static int32_t count(void *p) { return scalar(p,VN135_H_CHAIN_COUNT,0,0); }
static int32_t chip_check(void *p,struct vn135_general_monitor *g)
{ return vn135_backend_has_chip_sensor_135(g,count,p); }
int32_t vn135_temperature_start_composition_135(struct vn135_temperature_setup_view *v,
    const struct vn135_temperature_start_composition_ops *o,void *context)
{
    struct binding binding={v,o,context};
    const struct vn135_monitor_handler_ops handlers={.call=scalar,.log=diagnostic};
    const struct vn135_temperature_setup_ops ops={&handlers,chain_init,stop_chain,
                                                key,register_reply,chip_check};
    return vn135_backend_temperature_setup_135(v,&ops,&binding);
}
