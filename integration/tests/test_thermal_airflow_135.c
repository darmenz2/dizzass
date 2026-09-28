/* Composed C regression: original overheat decision -> original emergency fan
 * controller -> original AML PWM setter. Only external effects are scripted.
 * This is not a differential execution of that entire original call chain. */
#include "integration/thermal_sensors_135.h"
#include "integration/fan_control_135.h"
#include "integration/aml_fans_135.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
static unsigned checks, scenarios;
#define CHECK(x) do { ++checks; assert(x); } while (0)
struct context {
    struct vn135_fan_control fan;
    struct vn135_fan_time scratch;
    unsigned open_count, close_count, write_count;
    unsigned fail_open, fail_write, stop_count, event_count, full_count;
    int stop_failure, expected_reason;
    unsigned phase;
};
static uint32_t file_open(void *p,const char *path,const char *mode)
{
    struct context *c=p;unsigned n=++c->open_count;char expected[100];
    static const char *const attrs[]={"enable","period","duty_cycle"};
    CHECK(n<=6 && c->phase==2 && !strcmp(mode,"w"));
    (void)snprintf(expected,sizeof expected,"/sys/class/pwm/pwmchip0/pwm%u/%s",(n-1)/3,attrs[(n-1)%3]);
    CHECK(!strcmp(path,expected));return n==c->fail_open?0:n;
}
static int32_t file_close(void *p,uint32_t handle)
{
    struct context *c=p;CHECK(handle>=1&&handle<=6&&handle!=c->fail_open);
    ++c->close_count;return -8;
}
static int32_t write_uint(void *p,uint32_t handle,const char *fmt,uint32_t value)
{
    struct context *c=p;
    static const unsigned attr[]={1,2,3,1},values[]={0,100000,100000,1};
    unsigned i=c->write_count++;
    CHECK(c->phase==2 && !strcmp(fmt,"%u"));
    CHECK((handle-1)%3+1==attr[i%4] && value==values[i%4]);
    return c->write_count==c->fail_write?-9:1;
}
static int32_t mutex(void *p,uint32_t unlock){(void)p;(void)unlock;return -3;}
static const struct vn135_aml_fan_ops aml_ops={
    .open=file_open,.close=file_close,.write_uint=write_uint,.mutex=mutex
};
static void set_duty(void *p,int32_t duty)
{
    CHECK(duty==100);vn135_aml_fans_set_all_135(&aml_ops,p,duty);
}
static int32_t clock_now(void *p,struct vn135_fan_time *out)
{
    struct context *c=p;CHECK(c->phase==2);out->seconds=123;out->microseconds=500000;return 0;
}
static const struct vn135_fan_control_ops fan_ops={.set_duty=set_duty,.mutex=mutex,.clock=clock_now};
static int32_t chain_mutex(void *p){(void)p;return -2;}
static uint32_t selector(void *p){(void)p;return 4;}
static int32_t stop_chain(void *p,int reason)
{
    struct context *c=p;CHECK(c->phase==0&&reason==c->expected_reason);
    c->phase=1;++c->stop_count;return c->stop_failure?-1:0;
}
static int32_t full_airflow(void *p)
{
    struct context *c=p;CHECK(c->phase==1);c->phase=2;++c->full_count;
    vn135_fan_control_full_mode3(&c->fan,&fan_ops,p,&c->scratch);
    CHECK(c->fan.mode==3&&c->fan.last_sample==123.5);c->phase=3;return -7;
}
static int32_t record_event(void *p,uint32_t code,int32_t temperature)
{
    struct context *c=p;CHECK(c->phase==3);
    CHECK(code==(unsigned)(c->expected_reason?3003:3002));
    CHECK(temperature==(c->expected_reason?91:71));c->phase=4;++c->event_count;return -1;
}
static const struct vn135_thermal_trip_ops trip_ops={
    .lock=chain_mutex,.unlock=chain_mutex,.chip_selector=selector,
    .stop_chain=stop_chain,.full_airflow=full_airflow,.event=record_event
};
int main(void)
{
    const struct vn135_thermal_limits limits={70,90}; /* synthetic test data */
    struct vn135_thermal_chip chips[2]={{0,80},{1,91}};
    unsigned reason,stop_failed,open_failed,write_failed;
    for(reason=0;reason<2;++reason)for(stop_failed=0;stop_failed<2;++stop_failed)
    for(open_failed=0;open_failed<=6;++open_failed)for(write_failed=0;write_failed<=8;++write_failed){
        struct context c={0};struct vn135_thermal_chain ch={0,reason?69:71,91,2,chips};
        c.expected_reason=(int)reason;c.stop_failure=(int)stop_failed;
        c.fail_open=open_failed;c.fail_write=write_failed;c.fan.mode=1;
        CHECK(vn135_thermal_check_overheat(&ch,&limits,&trip_ops,&c)==-1);
        CHECK(c.stop_count==1&&c.full_count==1&&c.event_count==1&&c.phase==4);
        CHECK(c.open_count==6&&c.close_count==(open_failed?5u:6u));
        CHECK(c.write_count==(open_failed?4u:8u));++scenarios;
    }
    {struct context c={0};struct vn135_thermal_chain ch={0,69,89,2,chips};
     CHECK(vn135_thermal_check_overheat(&ch,&limits,&trip_ops,&c)==0);
     CHECK(!c.phase&&!c.open_count&&!c.stop_count&&!c.full_count&&!c.event_count);++scenarios;}
    printf("THERMAL135_AIRFLOW_PASS scenarios=%u assertions=%u physical_io=no\n",scenarios,checks);
    return 0;
}
