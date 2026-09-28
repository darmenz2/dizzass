/* Native and composed C tests. All GPIO/I2C/PWM/clock/thread effects use RAM.
 * Composition reuses the existing sample updater, thermal trip, GPIO helper,
 * fan controller and AML PWM setter. It is not a hardware test. */
#include "integration/thermal_routes_135.h"
#include "integration/gpio_power_135.h"
#include "integration/fan_control_135.h"
#include "integration/aml_fans_135.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
static unsigned assertions,scenarios;
#define CHECK(x) do {++assertions;assert(x);} while(0)
struct test {
    uint64_t canary_a;
    struct vn135_route_chain c;
    struct vn135_temperature_sensor sensors[3];
    struct vn135_route_chip chips[3];
    uint32_t addresses[3],types[3];
    uint64_t canary_b;
    unsigned writes,reads,gpio_calls,exchanges,delays,indicators,trip_calls;
    unsigned stops,full_calls,events,actions,creates,off_calls,logs;
    unsigned fan_opens,fan_writes,fan_closes;
    unsigned fail_fan_open,fail_fan_write;
    int gpio_open_fail,gpio_write_fail,exchange_success,exchange_rc,leave_response;
    int direct_rc,overheat_rc,create_rc,unlock_rc,composed;
    uint32_t selector,platform,raw,last_pin,last_value;
    unsigned stage;
    double clock;
    struct vn135_fan_control fan;
    struct vn135_fan_time fan_scratch;
};
static void initialize(struct test *t)
{
    unsigned i;memset(t,0,sizeof *t);t->canary_a=UINT64_C(0x12345678abcdef01);
    t->canary_b=UINT64_C(0xfedcba9876543210);t->exchange_success=1;t->clock=100.0;
    t->selector=2;t->raw=89;t->c.index=0;t->c.state=2;t->c.present=1;
    t->c.auxiliary_enabled=1;t->c.extra_stop_enabled=1;t->c.suppress_chip_samples=1;
    t->c.sensor_count=3;t->c.chip_count=3;t->c.sensors=t->sensors;
    t->c.sensor_chip_addresses=t->addresses;t->c.chips=t->chips;
    for(i=0;i<3;++i){
        t->types[i]=2;t->addresses[i]=(i+1)*16;t->sensors[i].index=i;
        t->sensors[i].state=2;t->sensors[i].access_kind=2;t->sensors[i].remote_enabled=1;
        t->sensors[i].sample=20;t->sensors[i].corrected=20;
        t->sensors[i].sampled_at=50.0;t->sensors[i].has_previous=1;
        t->chips[i].index=i+7;t->chips[i].word_08=999;t->chips[i].valid=1;
        t->chips[i].temperature=80.25+(double)i;memset(t->chips[i].statistics,0x66,44);
    }
    memset(t->c.statistics,0x55,44);memset(t->c.cleared_words,0x77,sizeof t->c.cleared_words);
    memset(t->c.reason,'x',512);t->c.local[2]=60;t->c.remote[2]=70;
    t->c.local_valid=1;t->c.remote_valid=1;t->fan.mode=1;
}
static void check_canaries(const struct test *t)
{
    CHECK(t->canary_a==UINT64_C(0x12345678abcdef01));
    CHECK(t->canary_b==UINT64_C(0xfedcba9876543210));
}
static int32_t sensor_lock(void *p,struct vn135_temperature_sensor *s)
{(void)p;(void)s;return -3;}
static double now(void *p){struct test *t=p;t->clock+=0.125;return t->clock;}
static const struct vn135_temperature_ops sensor_ops={.lock=sensor_lock,.unlock=sensor_lock,.now=now};
static void route_log(void *p,enum vn135_route_log_source src,uint32_t line,const uint32_t *a,size_t n)
{struct test *t=p;(void)src;(void)line;CHECK(!n||a);++t->logs;}
static int32_t mutex0(void *p){(void)p;return -2;}
static uintptr_t gpio_open(void *p,const char *path,const char *mode)
{
    struct test *t=p;char expected[96];
    (void)snprintf(expected,sizeof expected,"/sys/class/gpio/gpio%u/value",t->last_pin);
    CHECK(!strcmp(path,expected)&&!strcmp(mode,"w"));return t->gpio_open_fail?0:42;
}
static int32_t gpio_number(void *p,uintptr_t h,const char *fmt,uint32_t v)
{struct test *t=p;CHECK(h==42&&!strcmp(fmt,"%d"));CHECK(v==(t->last_value!=0));++t->writes;return t->gpio_write_fail?-1:1;}
static int32_t gpio_close(void *p,uintptr_t h){(void)p;CHECK(h==42);return -4;}
static void gpio_error(void *p,const char *s){(void)p;(void)s;}
static const struct vn135_gpio_ops gpio_ops={.lock=mutex0,.unlock=mutex0,.fopen=gpio_open,.fprintf_number=gpio_number,.fclose=gpio_close,.perror=gpio_error};
static int32_t set_gpio(void *p,uint32_t pin,uint32_t value)
{
    struct test *t=p;struct vn135_gpio_io io={&gpio_ops,p};
    t->last_pin=pin;t->last_value=value;++t->gpio_calls;
    return vn135_gpio_set_value_135(&io,pin,value);
}
static const struct vn135_aml_reset_ops reset_ops={set_gpio,route_log};
static int32_t reset_line(void *p,uint32_t i,uint32_t v)
{return vn135_chain_reset_aml_135(i,v,&reset_ops,p);}
static int32_t delay_ms(void *p,uint32_t entry,uint32_t ms)
{struct test *t=p;CHECK((entry==0x10ed2c&&ms==100)||(entry==0x10ef3c&&ms==500));++t->delays;return -5;}
static int32_t exchange(void *p,uint32_t chain,uint32_t addr,const uint8_t *tx,uint32_t tn,uint8_t *rx,uint32_t rn)
{
    struct test *t=p;const uint8_t expected[]={0x55,0xaa,5,0x15,0,0,0x1a};
    CHECK(chain==t->c.index&&addr==(0x20u|(chain&7u)));CHECK(tn==7&&rn==2&&!memcmp(tx,expected,7));
    ++t->exchanges;
    if(!t->leave_response){rx[0]=0x15;rx[1]=(uint8_t)(t->exchange_success>0 && t->exchanges==(unsigned)t->exchange_success);}
    return t->exchange_rc;
}
static int32_t indicator(void *p,uint32_t v){struct test *t=p;CHECK(v==0);++t->indicators;return -4;}
static int32_t chain_lock(void *p,struct vn135_route_chain *c){struct test *t=p;CHECK(c==&t->c);return -3;}
static int32_t chain_unlock(void *p,struct vn135_route_chain *c){struct test *t=p;CHECK(c==&t->c);return t->unlock_rc;}
static const struct vn135_chain_stop_ops stop_ops={reset_line,delay_ms,exchange,indicator,chain_lock,chain_unlock,route_log};
static int32_t count(void *p){(void)p;return 1;}
static int32_t supported(void *p){struct test *t=p;return t->selector==4||t->selector==7;}
static uint32_t selector(void *p){return ((struct test*)p)->selector;}
static uint32_t fan_open(void *p,const char *path,const char *mode)
{
    struct test *t=p;char expected[96];const char *attrs[]={"enable","period","duty_cycle"};
    unsigned i=t->fan_opens++;
    CHECK(t->stage==1);CHECK(!strcmp(mode,"w"));
    (void)snprintf(expected,sizeof expected,"/sys/class/pwm/pwmchip0/pwm%u/%s",(i/3)%2,attrs[i%3]);
    CHECK(!strcmp(path,expected));return i+1==t->fail_fan_open?0:i+1;
}
static int32_t fan_write(void *p,uint32_t h,const char *fmt,uint32_t v)
{
    struct test *t=p;unsigned j=t->fan_writes++;const unsigned expected[]={0,100000,100000,1};
    CHECK(t->stage==1&&h>0&&!strcmp(fmt,"%u"));CHECK(v==expected[j%4]);
    return j+1==t->fail_fan_write?-1:1;
}
static int32_t fan_close(void *p,uint32_t h){struct test *t=p;CHECK(h>0);++t->fan_closes;return -2;}
static int32_t fan_mutex(void *p,uint32_t n){(void)p;(void)n;return -1;}
static const struct vn135_aml_fan_ops fan_aml_ops={.open=fan_open,.close=fan_close,.write_uint=fan_write,.mutex=fan_mutex};
static void full_duty(void *p,int32_t value){CHECK(value==100);vn135_aml_fans_set_all_135(&fan_aml_ops,p,value);}
static int32_t fan_clock(void *p,struct vn135_fan_time *out){(void)p;out->seconds=123;out->microseconds=250000;return 0;}
static const struct vn135_fan_control_ops fan_ops={.set_duty=full_duty,.mutex=fan_mutex,.clock=fan_clock};
static int32_t trip_stop(void *p,int reason)
{
    struct test *t=p;uint8_t scratch[2]={0,0};CHECK(t->stage==0);++t->stops;
    CHECK(vn135_chain_stop_135(&t->c,reason?"chip overheat":"board overheat",&stop_ops,p,scratch)==t->unlock_rc);
    CHECK(t->c.state==3);t->stage=1;return -1;
}
static int32_t full(void *p)
{struct test *t=p;CHECK(t->stage==1);++t->full_calls;vn135_fan_control_full_mode3(&t->fan,&fan_ops,p,&t->fan_scratch);t->stage=2;return -1;}
static int32_t event(void *p,uint32_t code,int32_t temp)
{struct test *t=p;CHECK(t->stage==2&&temp>=70&&(code==3002||code==3003));++t->events;t->stage=3;return -1;}
static const struct vn135_thermal_trip_ops trip_ops={.lock=mutex0,.unlock=mutex0,.chip_selector=selector,.stop_chain=trip_stop,.full_airflow=full,.event=event};
static int32_t overheat(void *p,struct vn135_route_chain *c)
{
    struct test *t=p;struct vn135_thermal_chip chips[3];struct vn135_thermal_limits limits={70,90};
    struct vn135_thermal_chain view={c->index,c->local[2],c->remote[2],c->chip_count,chips};int i;
    ++t->trip_calls;
    if(!t->composed)return t->overheat_rc;
    for(i=0;i<c->chip_count;++i){chips[i].index=c->chips[i].index;chips[i].value=c->chips[i].temperature;}
    return vn135_thermal_check_overheat(&view,&limits,&trip_ops,p);
}
static int32_t action(void *p,struct vn135_route_chain *c){struct test *t=p;CHECK(c==&t->c);++t->actions;return -1;}
static int32_t create(void *p,uint32_t entry,uint32_t *handle){struct test *t=p;CHECK(entry==0x72ba4);*handle=77;++t->creates;return t->create_rc;}
static int32_t power_stop(void *p){++((struct test*)p)->off_calls;return -9;}
static const struct vn135_reply_ops reply_ops={&sensor_ops,count,supported,chain_lock,chain_unlock,overheat,action,create,power_stop,route_log};
static uint32_t platform(void *p){return ((struct test*)p)->platform;}
static int32_t read_direct(void *p,uint32_t e,uint32_t a,uint32_t b,uint32_t reg,uint8_t *out,uint32_t n)
{
    struct test *t=p;(void)a;(void)b;CHECK(reg==0);CHECK((e==0xfaeec&&n==2)||((e==0xfe440||e==0xfe528)&&n==3));
    memset(out,(int)(t->raw&255u),n);++t->reads;return t->direct_rc;
}
static const struct vn135_direct_temperature_ops direct_ops={&sensor_ops,platform,read_direct,route_log};
static int reply(struct test *t,uint32_t payload)
{
    struct vn135_temperature_reply r={0,32,payload};
    struct vn135_reply_profile profile={3,t->types};uint32_t h=0;
    return vn135_temperature_reply_135(&profile,&t->c,&r,&reply_ops,t,&h);
}
int main(void)
{
    unsigned idx,v,kind,ext,raw,success,fail,op,wp;
    for(idx=0;idx<5;++idx)for(v=0;v<4;++v){
        struct test t;initialize(&t);
        CHECK(vn135_chain_reset_aml_135(idx,v,&reset_ops,&t)==(idx<3?0:-1));
        CHECK(t.gpio_calls==(idx<3));if(idx<3){CHECK(t.last_pin==454+idx);CHECK(t.last_value==(v^1u));}
        check_canaries(&t);++scenarios;
    }
    for(success=0;success<=3;++success)for(fail=0;fail<4;++fail){
        struct test t;uint8_t rx[2]={0,0};initialize(&t);t.exchange_success=(int)success;t.exchange_rc=fail?-1:0;
        t.gpio_open_fail=(fail&1)!=0;t.gpio_write_fail=(fail&2)!=0;t.unlock_rc=-11;
        CHECK(vn135_chain_stop_135(&t.c,"temperature fault",&stop_ops,&t,rx)==-11);
        CHECK(t.c.state==3&&!t.c.local_valid&&!t.c.remote_valid&&!t.c.auxiliary_enabled);
        CHECK(t.c.local[2]==60&&t.c.remote[2]==70&&t.sensors[0].sampled_at==50.0);
        CHECK(!strcmp(t.c.reason,"temperature fault")&&t.c.reason[100]=='x');
        CHECK(t.exchanges==(success?success:3));CHECK(t.indicators==1);
        for(idx=0;idx<3;++idx){CHECK(t.chips[idx].temperature==0.0);CHECK(t.chips[idx].index==idx+7);CHECK(!t.chips[idx].valid&&!t.chips[idx].word_08);}
        check_canaries(&t);++scenarios;
    }
    {struct test t;uint8_t rx[2]={21,1};initialize(&t);t.leave_response=1;t.exchange_rc=-1;
     CHECK(!vn135_chain_auxiliary_stop_135(&t.c,&stop_ops,&t,rx));CHECK(t.exchanges==1&&!t.delays&&!t.c.auxiliary_enabled);++scenarios;}
    for(kind=0;kind<2;++kind)for(ext=0;ext<2;++ext)for(raw=0;raw<256;++raw){
        struct test t;int expected;initialize(&t);t.raw=raw;t.sensors[0].access_kind=kind?3:0;t.sensors[0].remote_enabled=0;t.sensors[0].extended=(uint8_t)ext;
        CHECK(!vn135_temperature_read_direct_135(t.sensors,0,&direct_ops,&t));
        expected=(int)((raw-(ext?64u:0u))&255u);if(expected>=128)expected-=256;
        CHECK(t.sensors[0].sample==expected&&t.sensors[0].corrected==expected&&t.reads==1);check_canaries(&t);++scenarios;
    }
    for(raw=0;raw<256;++raw)for(ext=0;ext<2;++ext){
        struct test t;initialize(&t);t.sensors[1].remote_enabled=(uint8_t)ext;
        CHECK(!reply(&t,(60u<<16)|(raw<<8)|85u));
        CHECK(t.sensors[1].sample==((!ext||raw==1)?60:20));
        CHECK(t.trip_calls==((!ext||raw==1)?1u:0u));check_canaries(&t);++scenarios;
    }
    for(fail=0;fail<4;++fail){
        struct test t;char why[780];uint8_t rx[2]={0,0};initialize(&t);memset(why,'z',779);why[779]=0;
        t.c.sensor_count=0;t.c.chip_count=0;t.c.extra_stop_enabled=0;t.unlock_rc=(int)fail;
        CHECK(vn135_chain_stop_135(&t.c,why,&stop_ops,&t,rx)==(int)fail);CHECK(strlen(t.c.reason)==511&&!t.exchanges);check_canaries(&t);++scenarios;
    }
    /* A stopped chain rejects the sample, but the original caller still checks
     * OLD cached temperatures. No invented complete-discard claim. */
    for(kind=0;kind<2;++kind)for(fail=0;fail<2;++fail)for(op=0;op<=6;++op)for(wp=0;wp<=8;++wp){
        struct test t;double sampled;initialize(&t);t.composed=1;t.create_rc=fail?-1:0;t.fail_fan_open=op;t.fail_fan_write=wp;
        t.gpio_open_fail=(int)fail;t.gpio_write_fail=(int)fail;t.exchange_rc=-1;
        CHECK(!reply(&t,((kind?69u:71u)<<16)|(1u<<8)|91u));sampled=t.sensors[1].sampled_at;
        CHECK(t.stops==1&&t.full_calls==1&&t.events==1&&t.stage==3&&t.c.state==3);
        CHECK(t.creates==1&&t.off_calls==fail);CHECK(t.fan_opens==6&&t.fan_writes==(op?4u:8u));
        CHECK(t.sensors[1].sample==(kind?69:71)&&t.c.remote[2]==91);
        check_canaries(&t);++scenarios;
        if(!op&&!wp&&!fail){
            t.stage=0;CHECK(!reply(&t,(30u<<16)|(1u<<8)|40u));
            CHECK(t.stops==2&&t.sensors[1].sampled_at==sampled);CHECK(t.sensors[1].sample==(kind?69:71));++scenarios;
        }
    }
    printf("THERMAL_ROUTES135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no real_threads=no\n",scenarios,assertions);
    return 0;
}
