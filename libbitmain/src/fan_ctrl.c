/* Original /tmp/build/libbitmain/src/fan_ctrl.c, pinned VNishNet 1.3.5.
 * General controller only. Numerical helpers are in support/pid_135.c.
 * Hardware and clock callbacks are required; no new safety or retry policy. */
#include "integration/fan_control_135.h"
#include <limits.h>
#include <math.h>
static int32_t to_signed(uint32_t v)
{ return v<=INT32_MAX?(int32_t)v:-1-(int32_t)(UINT32_MAX-v); }
static int32_t trunc_s32(double v)
{ return v>=INT32_MAX?INT32_MAX:v<=INT32_MIN?INT32_MIN:(int32_t)v; }
static double now(const struct vn135_fan_control_ops *o,void *p,struct vn135_fan_time *t)
{ (void)o->clock(p,t);return (double)t->microseconds/1000000.0+(double)t->seconds; }
static void log_value(const struct vn135_fan_control_ops *o,void *p,uint32_t l,int32_t v)
{ if(o->log)o->log(p,l,v); }
int vn135_fan_control_init(struct vn135_fan_control *s,
    const struct vn135_fan_control_ops *o,void *p,int32_t ceiling,struct vn135_fan_time *t)
{
    if(o->initialize(p))return -1;
    s->ceiling=ceiling;
    vn135_pid_init(&s->pid,3.0,0x1.47ae147ae147bp-6,0x1.1eb851eb851ecp-4);
    vn135_pid_direction(&s->pid,1);vn135_pid_limits(&s->pid,0.0,100.0);
    vn135_pid_target(&s->pid,65.0);s->mode=0;
    s->last_sample=now(o,p,t);s->initialized=1;
    return 0;
}
void vn135_fan_control_auto(struct vn135_fan_control *s,
    const struct vn135_fan_control_ops *o,void *p,int32_t label,int32_t target,
    int32_t lower,int32_t upper,struct vn135_fan_time *t)
{
    (void)o->mutex(p,0);
    if(s->ceiling<=target){
        log_value(o,p,87,target);
        log_value(o,p,88,to_signed((uint32_t)s->ceiling-5u));
        target=to_signed((uint32_t)s->ceiling-5u);
    }
    if(s->mode || target!=trunc_s32(round(s->pid.target)))log_value(o,p,93,label);
    vn135_pid_gains(&s->pid,3.0,0x1.47ae147ae147bp-5,0x1.3333333333333p-3);
    vn135_pid_target(&s->pid,(double)target);
    vn135_pid_limits(&s->pid,(double)lower,(double)upper);
    vn135_pid_seed(&s->pid,(double)o->get_duty(p));
    if(s->mode)s->last_sample=now(o,p,t);
    s->mode=0;(void)o->mutex(p,1);
}
void vn135_fan_control_manual(struct vn135_fan_control *s,
    const struct vn135_fan_control_ops *o,void *p,int32_t value,struct vn135_fan_time *t)
{
    (void)o->mutex(p,0);
    if(s->mode!=1 || s->manual_duty!=value)log_value(o,p,119,value);
    o->set_duty(p,value);s->manual_duty=value;s->mode=1;
    s->last_sample=now(o,p,t);(void)o->mutex(p,1);
}
static void full(struct vn135_fan_control *s,const struct vn135_fan_control_ops *o,
    void *p,struct vn135_fan_time *t,uint32_t mode,uint32_t line)
{
    (void)o->mutex(p,0);
    if(s->mode!=mode)log_value(o,p,line,0);
    o->set_duty(p,100);s->mode=mode;s->last_sample=now(o,p,t);
    (void)o->mutex(p,1);
}
void vn135_fan_control_full_mode2(struct vn135_fan_control *s,
    const struct vn135_fan_control_ops *o,void *p,struct vn135_fan_time *t)
{ full(s,o,p,t,2,140); }
void vn135_fan_control_full_mode3(struct vn135_fan_control *s,
    const struct vn135_fan_control_ops *o,void *p,struct vn135_fan_time *t)
{ full(s,o,p,t,3,160); }
double vn135_fan_control_integral_gap(const struct vn135_fan_control *s)
{
    double v=s->pid.direction==1?s->pid.upper-s->pid.output:s->pid.output;
    return fabs(s->pid.integral-v);
}
void vn135_fan_control_update(struct vn135_fan_control *s,
    const struct vn135_fan_control_ops *o,void *p,int32_t input,struct vn135_fan_time *t)
{
    /* gettimeofday is before lock; the previous sample is read after that call. */
    double current=now(o,p,t),previous=s->last_sample;
    (void)o->mutex(p,0);vn135_pid_input(&s->pid,(double)input);
    if(current-s->full_duty_since>=10.0){
        if(s->ceiling<=input){
            o->set_duty(p,100);vn135_pid_seed(&s->pid,100.0);
            s->full_duty_since=now(o,p,t);
        }else if(s->mode==0){
            vn135_pid_step(&s->pid,current-previous);
            o->set_duty(p,trunc_s32(round(vn135_pid_output(&s->pid))));
        }else if(s->mode==1)o->set_duty(p,s->manual_duty);
        else o->set_duty(p,100);
    }
    s->last_sample=current;(void)o->mutex(p,1);
}
uint32_t vn135_fan_control_mode(const struct vn135_fan_control *s){return s->mode;}
void vn135_fan_control_target(struct vn135_fan_control *s,int32_t value)
{
    if(s->mode)return;
    vn135_pid_target(&s->pid,(double)value);
    vn135_pid_seed(&s->pid,vn135_pid_output(&s->pid));
}
int32_t vn135_fan_control_get_target(const struct vn135_fan_control *s)
{ return s->mode?65:trunc_s32(vn135_pid_get_target(&s->pid)); }
void vn135_fan_control_shutdown(const struct vn135_fan_control_ops *o,void *p)
{ o->shutdown(p); }
