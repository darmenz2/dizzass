/* Recovered /tmp/build/libbitmain/src/aml/fan_ctrl.c, VNishNet 1.3.5.
 * Entries: 118444, 1184fc, 1189dc, 118a04, 118cc8, 11910c, 119258.
 * Original effects and errors through explicit OS callbacks; no new policy.
 */
#include "integration/aml_fans_135.h"
#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
static void fan_log(const struct vn135_aml_fan_ops *o, void *p,
                    uint32_t line, uint32_t arg)
{ if (o->log) o->log(p,line,arg); }
static int32_t signed_bits(uint32_t x)
{ return x<=INT32_MAX?(int32_t)x:-1-(int32_t)(UINT32_MAX-x); }
int vn135_aml_fans_initialize_135(struct vn135_aml_fans *s,
    const struct vn135_aml_fan_ops *o, void *p)
{ return o->create_thread(p,&s->thread,0x1184fc,0)?-1:0; }
void vn135_aml_fans_set_channel_135(const struct vn135_aml_fan_ops *o, void *p,
    uint32_t channel, int32_t duty)
{
    char path[256]; uint32_t enable,period,cycle,d;
    (void)snprintf(path,sizeof(path),"/sys/class/pwm/pwmchip0/pwm%" PRId32 "/enable",signed_bits(channel));
    enable=o->open(p,path,"w");
    (void)snprintf(path,sizeof(path),"/sys/class/pwm/pwmchip0/pwm%" PRId32 "/period",signed_bits(channel));
    period=o->open(p,path,"w");
    (void)snprintf(path,sizeof(path),"/sys/class/pwm/pwmchip0/pwm%" PRId32 "/duty_cycle",signed_bits(channel));
    cycle=o->open(p,path,"w");
    if (!enable || !period || !cycle) fan_log(o,p,170,channel);
    else {
        (void)o->mutex(p,0);
        (void)o->write_uint(p,enable,"%u",0);
        (void)o->write_uint(p,period,"%u",100000);
        d=duty<0?0u:duty>=100?100000u:(uint32_t)duty*1000u;
        (void)o->write_uint(p,cycle,"%u",d);
        (void)o->write_uint(p,enable,"%u",1);
        (void)o->mutex(p,1);
    }
    if (enable) (void)o->close(p,enable);
    if (period) (void)o->close(p,period);
    if (cycle) (void)o->close(p,cycle);
}
void vn135_aml_fans_set_all_135(const struct vn135_aml_fan_ops *o,void *p,int32_t duty)
{
    vn135_aml_fans_set_channel_135(o,p,0,duty);
    vn135_aml_fans_set_channel_135(o,p,1,duty);
}
uint32_t vn135_aml_fans_get_duty_135(const struct vn135_aml_fan_ops *o,void *p)
{
    uint32_t a,b,period=0,cycle=0,result=0;
    a=o->open(p,"/sys/class/pwm/pwmchip0/pwm0/period","r");
    b=o->open(p,"/sys/class/pwm/pwmchip0/pwm0/duty_cycle","r");
    if (!a || !b) fan_log(o,p,127,0);
    else {
        int64_t q; int32_t v;
        (void)o->mutex(p,0);
        (void)o->read_uint(p,a,"%u",&period);
        (void)o->read_uint(p,b,"%u",&cycle);
        (void)o->mutex(p,1);
        if (!period) period=100000;
        /* MUL wraps to 32 bits before SIGNED division in the original. */
        q=(int64_t)signed_bits(cycle*100u)/(int64_t)signed_bits(period);
        v=signed_bits((uint32_t)q);
        result=v<0?0u:v>=100?100u:(uint32_t)v;
    }
    if (a) (void)o->close(p,a);
    if (b) (void)o->close(p,b);
    return result;
}
uint32_t vn135_aml_fans_get_rpm_135(const struct vn135_aml_fans *s,
    const struct vn135_aml_fan_ops *o,void *p,uint32_t index)
{
    if (index<4) return s->samples[index].rpm;
    fan_log(o,p,218,index);
    return 0;
}
/* Exact wrapping integer semantics of the original inlined-library atoi.
 * The unsigned accumulator avoids introducing host signed-overflow UB. */
static uint32_t counter_value(const char *text)
{
    const unsigned char *q=(const unsigned char *)text; uint32_t v=0,neg=0;
    while (*q==' ' || (*q>=9 && *q<=13)) ++q;
    if (*q=='-' || *q=='+') {neg=*q=='-';++q;}
    while (*q>='0' && *q<='9') {v=v*10u+(uint32_t)(*q-'0');++q;}
    return neg?0u-v:v;
}
void vn135_aml_fans_rpm_worker_135(struct vn135_aml_fans *s,
    const struct vn135_aml_fan_ops *o,void *p)
{
    static const int irq_labels[4]={27,26,28,29};
    char line[256]={0},pattern[64]={0}; uint32_t f,i;
    (void)o->cancel_state(p,1);
    (void)o->name_thread(p,"fans@btm");
    f=o->open(p,"/proc/interrupts","r");
    if (!f) {
        fan_log(o,p,57,0);
        memset(s->samples,0,sizeof(s->samples));
        o->exit_thread(p,0);
        return;
    }
    s->running=1;
    do {
        (void)o->seek(p,f,0,0);
        while (o->read_line(p,line,sizeof(line),f)) {
            for (i=0;i<4;++i) {
                char *q,*end;uint32_t value,previous,delta;
                (void)snprintf(pattern,sizeof(pattern),"%d:",irq_labels[i]);
                if (!strstr(line,pattern) || !strstr(line,"gpiolib")) continue;
                q=strchr(line,':');
                do {++q;} while (*q==' ');
                end=q+1;
                while (*end!=' ') ++end;
                *end=0;
                value=counter_value(q);
                previous=s->samples[i].previous;
                if (!previous) {s->samples[i].previous=value;previous=value;}
                delta=value-previous;
                s->samples[i].rpm=((delta*15u)<<2)>>1;
                s->samples[i].previous=value;
            }
        }
        (void)o->sleep_ms(p,1000);
    } while (s->running);
    (void)o->close(p,f);
    o->exit_thread(p,0);
}

void vn135_aml_fans_shutdown_135(struct vn135_aml_fans *s,
    const struct vn135_aml_fan_ops *o, void *p)
{
    uint32_t self,worker;
    if (!s->running) return;
    s->running=0;
    self=o->self_thread(p);
    worker=s->thread;
    if (self==worker) { (void)o->detach_thread(p,self); return; }
    (void)o->cancel_thread(p,worker);
    (void)o->join_thread(p,s->thread);
}
