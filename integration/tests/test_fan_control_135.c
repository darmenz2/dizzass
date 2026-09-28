/* Native bounds/semantic tests; all platform effects are RAM callbacks. */
#include "integration/fan_control_135.h"
#include "integration/aml_fans_135.h"
#include <assert.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned assertions,scenarios;
#define CHECK(x) do{++assertions;assert(x);}while(0)
struct harness {
    int init_rc, duty, writes,locks,unlocks,clocks,logs,stops,bridge,fail_alloc;
    int32_t last_duty;
    struct vn135_fan_time times[4];
    struct vn135_fan_control *controller;
    struct vn135_fan_record *owned;
    unsigned record_locks,record_inits,io_open,io_close,io_write;
    uint32_t io_values[16];
};
static int32_t hinit(void *p){return ((struct harness *)p)->init_rc;}
static void hstop(void *p){((struct harness *)p)->stops++;}
static int32_t hget(void *p){return ((struct harness *)p)->duty;}
static int32_t hmutex(void *p,uint32_t u)
{struct harness *h=p;if(u)h->unlocks++;else h->locks++;return -7;}
static int32_t hclock(void *p,struct vn135_fan_time *t)
{struct harness *h=p;unsigned i=(unsigned)h->clocks++;*t=h->times[i<4?i:3];return -5;}
static void hlog(void *p,uint32_t line,int32_t v)
{struct harness *h=p;(void)line;(void)v;h->logs++;}
static uint32_t io_open(void *p,const char *path,const char *mode)
{struct harness *h=p;CHECK(strstr(path,"/sys/class/pwm/pwmchip0/pwm")!=NULL);CHECK(!strcmp(mode,"w"));return ++h->io_open;}
static int32_t io_close(void *p,uint32_t fd)
{struct harness *h=p;CHECK(fd>=1 && fd<=6);h->io_close++;return -1;}
static int32_t io_write(void *p,uint32_t fd,const char *format,uint32_t value)
{struct harness *h=p;CHECK(fd>=1 && fd<=6);CHECK(!strcmp(format,"%u"));CHECK(h->io_write<16);h->io_values[h->io_write++]=value;return -1;}
static const struct vn135_aml_fan_ops amlops={.open=io_open,.close=io_close,.write_uint=io_write,.mutex=hmutex};
static void hset(void *p,int32_t d)
{struct harness *h=p;h->writes++;h->last_duty=d;if(h->bridge)vn135_aml_fans_set_all_135(&amlops,p,d);}
static const struct vn135_fan_control_ops ops={hinit,hstop,hget,hset,hmutex,hclock,hlog};
static struct vn135_fan_control initial(void)
{
    struct vn135_fan_control s;memset(&s,0,sizeof s);s.ceiling=85;
    s.pid=(struct vn135_pid){65,50,43,0,100,1,0xabcdef12,3,.04,.15,7,19};
    s.mode=0;s.last_sample=100;s.manual_duty=47;s.full_duty_since=80;s.initialized=9;return s;
}
static struct harness context(void)
{
    struct harness h;memset(&h,0,sizeof h);h.duty=57;
    h.times[0]=(struct vn135_fan_time){101,500000};h.times[1]=(struct vn135_fan_time){102,250000};
    h.times[2]=h.times[3]=(struct vn135_fan_time){103,0};return h;
}
static struct vn135_fan_record *allocate(void *p,uint32_t n,uint32_t z)
{
    struct harness *h=p;CHECK(z==36);
    if(h->fail_alloc)return NULL;
    h->owned=calloc(n?n:1,sizeof *h->owned);CHECK(h->owned!=NULL);return h->owned;
}
static int32_t record_mutex(void *p,struct vn135_fan_record *r)
{
    struct harness *h=p;CHECK(r->lost==1);CHECK(r->value==0);CHECK(r->index==h->record_locks++);
    memset(r->mutex_storage,0x5a,sizeof r->mutex_storage);return -8;
}
static int32_t controller_init(void *p,int32_t n)
{
    struct harness *h=p;struct vn135_fan_time t={0,0};h->record_inits++;
    return vn135_fan_control_init(h->controller,&ops,h,n,&t);
}
static void init_tests(void)
{
    unsigned ready;int rc;
    for(ready=0;ready<256;ready++)for(rc=-1;rc<=1;rc++){
        struct vn135_fan_control s=initial(),before;struct harness h=context();struct vn135_fan_time t={0,0};
        s.initialized=(uint8_t)ready;before=s;h.init_rc=rc;scenarios++;
        CHECK(vn135_fan_control_init(&s,&ops,&h,90,&t)==(rc?-1:0));
        if(rc)CHECK(!memcmp(&s,&before,sizeof s));
        else{
            CHECK(s.ceiling==90 && s.mode==0 && s.initialized==1);
            CHECK(s.pid.target==65 && s.pid.input==0 && s.pid.output==0 && s.pid.integral==0);
            CHECK(s.pid.direction==1 && s.pid.lower==0 && s.pid.upper==100);
            CHECK(s.pid.previous_error==before.pid.previous_error && s.pid.reserved_2c==before.pid.reserved_2c);
            CHECK(s.full_duty_since==before.full_duty_since && s.manual_duty==before.manual_duty);
            CHECK(s.last_sample==101.5 && h.clocks==1 && h.writes==0);
        }
    }
}
static void modes_tests(void)
{
    uint32_t mode;int vals[]={INT_MIN,-1,0,30,99,100,101,INT_MAX};size_t i;
    for(mode=0;mode<8;mode++)for(i=0;i<sizeof vals/sizeof *vals;i++){
        struct vn135_fan_control s=initial(),before;struct harness h=context();struct vn135_fan_time t={0,0};
        int32_t v=vals[i];scenarios++;s.mode=mode;before=s;
        vn135_fan_control_manual(&s,&ops,&h,v,&t);
        CHECK(s.mode==1 && s.manual_duty==v && h.writes==1 && h.last_duty==v);
        CHECK(!memcmp(&s.pid,&before.pid,sizeof s.pid));CHECK(s.full_duty_since==80 && s.last_sample==101.5);
        CHECK(h.locks==1 && h.unlocks==1);
        s=before;h=context();vn135_fan_control_target(&s,v);
        if(mode)CHECK(!memcmp(&s,&before,sizeof s));else CHECK(s.pid.target==(double)v);
        CHECK(vn135_fan_control_get_target(&s)==(mode?65:v));
        CHECK(vn135_fan_control_mode(&s)==mode);
    }
    for(mode=0;mode<8;mode++){
        struct vn135_fan_control s=initial();struct harness h=context();struct vn135_fan_time t={0,0};
        s.mode=mode;scenarios++;vn135_fan_control_full_mode2(&s,&ops,&h,&t);
        CHECK(s.mode==2 && h.last_duty==100 && h.writes==1 && s.full_duty_since==80);
        vn135_fan_control_full_mode3(&s,&ops,&h,&t);CHECK(s.mode==3 && h.writes==2 && h.last_duty==100);
        vn135_fan_control_shutdown(&ops,&h);CHECK(h.stops==1 && s.mode==3);
    }
}
static void pid_tests(void)
{
    struct vn135_pid s=initial().pid,before;int dir,i;
    s.kp=3;s.ki=.04;s.kd=.15;scenarios++;vn135_pid_step(&s,.5);
    CHECK(fabs(s.output-33.3)<1e-12 && fabs(s.integral-19.3)<1e-12 && s.previous_error==15);
    for(dir=0;dir<=3;dir++)for(i=0;i<100;i++){
        double dt=(double)i/1000.0;s=initial().pid;s.direction=(uint32_t)dir;before=s;scenarios++;
        vn135_pid_step(&s,dt);
        if(i<10)CHECK(!memcmp(&s,&before,sizeof s));else CHECK(s.previous_error==15);
        CHECK(vn135_pid_output(&s)>=0 && vn135_pid_output(&s)<=100);
    }
    s=initial().pid;s.kp=100;s.ki=2;s.kd=0;s.integral=10;scenarios++;vn135_pid_step(&s,1);
    CHECK(s.integral==10);CHECK(s.output<0 && vn135_pid_output(&s)==0);
    before=s;vn135_pid_limits(&s,100,0);CHECK(s.lower==before.lower && s.upper==before.upper);
    vn135_pid_limits(&s,1,.9995);CHECK(s.lower==1 && s.upper==.9995);
}
static void control_tests(void)
{
    struct vn135_fan_control s=initial();struct harness h=context();struct vn135_fan_time t={0,0};
    scenarios++;vn135_fan_control_auto(&s,&ops,&h,55,90,0,100,&t);
    CHECK(s.pid.target==80 && s.pid.kp==3 && s.pid.ki==.04 && s.pid.kd==.15);
    CHECK(s.pid.output==57 && s.mode==0 && h.clocks==0 && h.logs==3);
    h=context();scenarios++;vn135_fan_control_update(&s,&ops,&h,90,&t);
    CHECK(h.writes==1 && h.last_duty==100 && s.full_duty_since==102.25 && s.last_sample==101.5);
    h=context();h.times[0]=(struct vn135_fan_time){112,249999};scenarios++;
    vn135_fan_control_update(&s,&ops,&h,40,&t);CHECK(h.writes==0 && s.pid.input==40);
    h=context();h.times[0]=(struct vn135_fan_time){112,250000};s.mode=1;s.manual_duty=23;scenarios++;
    vn135_fan_control_update(&s,&ops,&h,40,&t);CHECK(h.writes==1 && h.last_duty==23);
    h=context();h.times[0]=(struct vn135_fan_time){80,0};scenarios++;
    vn135_fan_control_update(&s,&ops,&h,90,&t);CHECK(h.writes==0); /* rollback precedes ceiling branch */
}
static void records_tests(void)
{
    unsigned n;int fail,rc;const struct vn135_fan_records_ops ro={allocate,record_mutex,controller_init};
    for(n=0;n<20;n++)for(fail=0;fail<2;fail++)for(rc=-1;rc<=1;rc++){
        struct vn135_fan_control c=initial();struct harness h=context();struct vn135_fan_record old[2];
        struct vn135_fan_records s={(int32_t)n,85,old};h.fail_alloc=fail;h.init_rc=rc;h.controller=&c;scenarios++;
        CHECK(vn135_fan_records_init(&s,&ro,&h)==(fail?-1:0));
        if(fail)CHECK(s.records==NULL && h.record_inits==0 && h.record_locks==0);
        else{CHECK(h.record_inits==1 && h.record_locks==n && s.records==h.owned);CHECK(c.initialized==(rc?9:1));}
        free(h.owned);
    }
}
static void composed_pwm_tests(void)
{
    int values[]={-10,0,30,100,120};unsigned k,j;
    for(k=0;k<sizeof values/sizeof *values;k++){
        struct vn135_fan_control s=initial();struct harness h=context();struct vn135_fan_time t={0,0};
        uint32_t duty=(uint32_t)(values[k]<0?0:values[k]>100?100:values[k])*1000u;
        uint32_t expected[]={0,100000,duty,1,0,100000,duty,1};scenarios++;h.bridge=1;
        vn135_fan_control_manual(&s,&ops,&h,values[k],&t);
        CHECK(h.io_open==6 && h.io_close==6 && h.io_write==8);
        for(j=0;j<8;j++)CHECK(h.io_values[j]==expected[j]);
        CHECK(s.manual_duty==values[k] && h.writes==1);
    }
}
int main(void)
{
    init_tests();modes_tests();pid_tests();control_tests();records_tests();composed_pwm_tests();
    printf("FAN_CONTROL135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no real_threads=no\n",scenarios,assertions);
    return 0;
}
