/* Native invariants and composition of recovered monitor/collector/fan methods.
 * OS/device callbacks below are test scripts. No production binding is supplied. */
#include "integration/general_monitor_135.h"
#include "integration/backend_peripheral_135.h"
#include <inttypes.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static uint64_t assertions,scenarios;
#define CHECK(x) do { ++assertions; if(!(x)){fprintf(stderr,"general135:%d: %s\n",__LINE__,#x);abort();} } while(0)
struct event { uint32_t op,a,b; };
struct test {
    uint64_t guard_first;
    struct vn135_general_model model;
    struct vn135_general_history history;
    struct vn135_general_chain chains[3];
    struct vn135_temperature_sensor sensors[3][4];
    struct vn135_fan_record fans[4];
    struct vn135_general_monitor state;
    struct vn135_general_scratch scratch;
    struct vn135_fan_control controller;
    struct vn135_peripheral_chain cached[3];
    double global,now,step;
    int count,laps,delays,platform,thermal,afterstop,create_rc,available,chain_check;
    int collected,collect_rc,compose,write_outputs,shutdown_changes_state;
    uint32_t chain_power,power,creates[3],fault_calls,power_calls,psu_calls;
    uint32_t stop_calls,full_calls,abort_calls,fan_sets,logs[7000];
    struct event events[1024];
    size_t n;
    uint64_t guard_last;
};
static int32_t dispatch(void *p,uint32_t op,uint32_t a,uint32_t b)
{
    struct test *t=p;
    CHECK(t->n<1024);t->events[t->n++]=(struct event){op,a,b};
    switch(op){
    case VN135_G_CANCEL_TYPE:CHECK(a==1&&b==0);return -11;
    case VN135_G_NAME:return -12;
    case VN135_G_CHAIN_COUNT:return t->count;
    case VN135_G_PLATFORM:return t->platform;
    case VN135_G_DELAY:
        CHECK(a==1000);CHECK(++t->delays<=t->laps);
        if(t->delays==t->laps)t->state.running=0;
        t->now+=t->step;return -1;
    case VN135_G_EXIT:CHECK(t->state.running==0);return 0;
    case VN135_G_THERMAL:CHECK(a<3);return t->thermal;
    case VN135_G_AFTER_STOP:return t->afterstop;
    case VN135_G_FULL_FAN:++t->full_calls;return -1;
    case VN135_G_POWER_STOP:++t->abort_calls;return -1;
    case VN135_G_CHAIN_CHECK:CHECK(a<3);return t->chain_check;
    case VN135_G_CHAIN_POWER:CHECK(a<3);return (int32_t)t->chain_power;
    case VN135_G_FAN_TARGET:return vn135_fan_control_get_target(&t->controller);
    case VN135_G_SET_FAN_TARGET:++t->fan_sets;vn135_fan_control_target(&t->controller,(int32_t)a);return -1;
    case VN135_G_PSU_AVAILABLE:return t->available;
    case VN135_G_LOCK:case VN135_G_UNLOCK:CHECK(a<=2&&b<4);return -1;
    default:return 0;
    }
}
static double clock_now(void *p){return ((struct test *)p)->now;}
static double number(void *p,uint32_t entry,uint32_t index)
{
    struct test *t=p;CHECK(index<3);
    CHECK(entry==0x59810 || entry==0xf8df0);
    return entry==0x59810?100.0:vn135_fan_control_integral_gap(&t->controller);
}
static int32_t cached_count(void *p){return ((struct test *)p)->count;}
static int32_t cached_lock(void *p,uint32_t i){return dispatch(p,VN135_G_LOCK,2,i);}
static int32_t cached_unlock(void *p,uint32_t i){return dispatch(p,VN135_G_UNLOCK,2,i);}
static int32_t collect(void *p,int32_t *out)
{
    struct test *t=p;CHECK(*out==0);
    if(t->compose){
        struct vn135_peripheral_state s={0};
        const struct vn135_peripheral_ops o={.chain_count=cached_count,.lock=cached_lock,.unlock=cached_unlock};
        for(int i=0;i<3;++i){t->cached[i].word_20=t->chains[i].thermal.state;t->cached[i].byte_24=t->chains[i].thermal.present;}
        s.chains=t->cached;
        return vn135_backend_collect_5db54_135(&s,&o,p,out);
    }
    if(t->write_outputs)*out=t->collected;
    return t->collect_rc;
}
static int32_t power(void *p,uint32_t *out)
{ struct test *t=p;CHECK(*out==0);++t->power_calls;if(t->write_outputs)*out=t->power;return -1; }
static int32_t psu(void *p,uint8_t *valid,int16_t temperatures[3])
{
    struct test *t=p;++t->psu_calls;
    if(t->write_outputs){*valid=7;temperatures[0]=100;temperatures[1]=110;temperatures[2]=120;}
    return -1;
}
static int32_t fault(void *p,uint32_t index,uint32_t *out)
{struct test *t=p;CHECK(index<3);CHECK(out==&t->chains[index].fault_3c);++t->fault_calls;if(t->write_outputs)*out=0xaabb;return -1;}
static int32_t stop_chain(void *p,struct vn135_route_chain *c,const char *reason)
{
    struct test *t=p;CHECK(c==&t->chains[0].thermal||c==&t->chains[1].thermal||c==&t->chains[2].thermal);
    CHECK(reason&&*reason);++t->stop_calls;return -1;
}
static int32_t create(void *p,uint32_t slot,uint32_t entry,uint32_t *out)
{
    struct test *t=p;CHECK(slot<3);CHECK(entry==0x72ba4);CHECK(out==&t->scratch.handles[slot]);++t->creates[slot];
    if(t->write_outputs)*out=0x1234;
    if(t->shutdown_changes_state){t->state.state=6;t->state.running=0;}
    return t->create_rc;
}
static void log_event(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b,double value,const char *detail)
{
    struct test *t=p;(void)a;(void)b;(void)value;CHECK(line<7000);CHECK(level>=1&&level<=3);++t->logs[line];
    if(line==2565)CHECK(detail && strstr(detail,"Chain break detected (")==detail);
    else CHECK(detail==NULL);
}
static const struct vn135_general_ops ops={dispatch,clock_now,number,collect,power,psu,fault,stop_chain,create,log_event};
static void init(struct test *t)
{
    memset(t,0,sizeof(*t));t->guard_first=UINT64_C(0x123456789abcdef0);t->guard_last=~t->guard_first;
    t->model=(struct vn135_general_model){2,2,88,2,0};
    t->history=(struct vn135_general_history){100,100,100,100,100,60};
    t->state.model=&t->model;t->state.history=&t->history;t->state.chains=t->chains;t->state.fans=t->fans;t->state.global_rate=&t->global;
    t->state.state=2;t->state.active=1;t->state.target_temperature=70;t->state.required_fans=2;t->state.available_fans=2;
    t->state.psu_temperature_limit=100;t->state.tune_percent=100;t->state.sampled_power=0x8765;
    t->now=105;t->count=2;t->laps=1;t->collected=60;t->chain_power=1200;t->power=3456;t->write_outputs=1;
    t->controller.pid.target=70;t->controller.pid.output=50;t->controller.pid.integral=50;
    t->controller.pid.upper=100;t->controller.pid.direction=1;
    for(int i=0;i<3;++i){
        struct vn135_route_chain *c=&t->chains[i].thermal;c->index=(uint32_t)i;c->state=2;c->present=1;c->sensors=t->sensors[i];
        double measured=100;memcpy(c->statistics,&measured,8);t->chains[i].detected_8c=88;t->scratch.handles[i]=(uint32_t)i+12;
        t->cached[i].word_2ac=40+i*10;t->cached[i].byte_2b0=1;
        for(int j=0;j<4;++j){t->sensors[i][j].access_kind=4;t->sensors[i][j].role=2;t->sensors[i][j].state=2;}
    }
    for(int i=0;i<4;++i)t->fans[i].index=(uint32_t)i;
}
static size_t count_event(const struct test *t,uint32_t op,uint32_t a)
{size_t n=0;for(size_t i=0;i<t->n;++i)if(t->events[i].op==op&&t->events[i].a==a)++n;return n;}
static void run(struct test *t)
{
    ++scenarios;vn135_general_monitor_135(&t->state,&ops,t,&t->scratch);
    CHECK(t->guard_first==UINT64_C(0x123456789abcdef0));CHECK(t->guard_last==~t->guard_first);
    CHECK(t->events[0].op==VN135_G_CANCEL_TYPE);CHECK(t->events[1].op==VN135_G_NAME);
    CHECK(t->events[t->n-1].op==VN135_G_EXIT);CHECK(t->state.running==0);
    CHECK(count_event(t,VN135_G_MAINTAIN,0)==(size_t)t->delays);
    CHECK(count_event(t,VN135_G_TUNE_MAINTAIN,0)==(size_t)t->delays);
    CHECK(count_event(t,VN135_G_STATE_MAINTAIN,0)==(size_t)t->delays);
}
int main(void)
{
    struct test t;init(&t);run(&t);CHECK(t.state.sampled_power==2400);CHECK(t.history.power_sample==105);
    CHECK(t.history.fan_adjust==105);CHECK(!t.creates[0]&&!t.creates[1]&&!t.creates[2]);
    const int16_t temperatures[][3]={{-32768,-1,0},{0,1,2},{99,100,101},{32767,-32768,50}};
    const int limits[]={-1,0,50,100,32767};
    for(unsigned mask=0;mask<16;++mask)for(unsigned v=0;v<4;++v)for(unsigned l=0;l<5;++l)for(int rc=0;rc<2;++rc){
        init(&t);t.state.psu_monitoring=1;t.state.psu_valid=(uint8_t)mask;memcpy(t.state.psu_temperatures,temperatures[v],6);
        t.state.psu_temperature_limit=limits[l];t.create_rc=rc?-1:0;int max=0;
        for(int j=0;j<3;++j)if((mask&(1u<<j))&&temperatures[v][j]>max)max=temperatures[v][j];
        unsigned trip=(mask&7u)&&max>=limits[l];run(&t);
        CHECK(t.creates[2]==trip);CHECK(t.abort_calls==trip*(unsigned)rc);CHECK(t.logs[2894]==trip);CHECK(t.logs[2895]==trip);
        CHECK(t.logs[6483]==trip*(unsigned)rc);CHECK(count_event(&t,VN135_G_EVENT,3005)==trip);
        CHECK(t.state.sampled_power==3456);CHECK(t.power_calls==1);
    }
    for(int n=0;n<=3;++n)for(unsigned state=0;state<8;++state)for(int query=0;query<2;++query){
        init(&t);t.count=n;t.model.query_fault_87=(uint8_t)query;
        for(int i=0;i<3;++i){t.chains[i].thermal.state=state;t.chains[i].detected_8c=87;}
        unsigned live=state<3||state>5;run(&t);
        CHECK(count_event(&t,VN135_G_EVENT,2008)==live*(unsigned)n);
        CHECK(t.stop_calls==live*(unsigned)(n*query));CHECK(t.fault_calls==t.stop_calls);
    }
    for(int sensor_state=0;sensor_state<4;++sensor_state)for(int n=0;n<=3;++n){
        init(&t);t.count=n;t.state.suppress_thermal=1;
        for(int i=0;i<3;++i)for(int j=0;j<4;++j)t.sensors[i][j].state=(uint32_t)sensor_state;
        run(&t);CHECK(t.creates[1]==(unsigned)(sensor_state==3||!n));
    }
    for(int after=0;after<2;++after)for(int rc=0;rc<2;++rc){
        init(&t);t.thermal=1;t.afterstop=after;t.create_rc=rc?-1:0;run(&t);
        CHECK(t.stop_calls==(unsigned)(after?1:2));CHECK(t.full_calls==t.stop_calls);CHECK(t.creates[0]==(unsigned)after);CHECK(t.abort_calls==(unsigned)(after*rc));
    }
    init(&t);t.chain_power=UINT32_MAX;t.count=3;run(&t);CHECK(t.state.sampled_power==UINT32_MAX-2);
    init(&t);t.state.psu_monitoring=1;t.write_outputs=0;run(&t);CHECK(t.state.sampled_power==0);CHECK(t.power_calls==1);
    init(&t);t.available=1;t.laps=2;t.state.psu_monitoring=1;run(&t);CHECK(t.psu_calls==1);CHECK(t.creates[2]==1);
    init(&t);t.state.psu_monitoring=1;t.state.psu_valid=7;t.state.psu_temperatures[0]=120;t.shutdown_changes_state=1;run(&t);CHECK(t.creates[2]==1);CHECK(t.state.state==6);CHECK(t.power_calls==0);
    /* Cached collector + real recovered controller target/seed operations. */
    const int valid_patterns[]={0,1,2,3,7};
    for(int mode=0;mode<4;++mode)for(int target=40;target<=80;target+=20)for(int v=0;v<5;++v){
        init(&t);t.compose=1;t.controller.mode=(uint32_t)mode;t.controller.pid.target=50;t.state.target_temperature=target;t.collected=-123;t.history.previous_temperature=50;
        for(int i=0;i<3;++i)t.cached[i].byte_2b0=(uint8_t)((valid_patterns[v]>>i)&1);
        int before=vn135_fan_control_get_target(&t.controller);run(&t);
        CHECK(t.controller.mode==(uint32_t)mode);
        if(mode)CHECK(t.controller.pid.target==50);
        if(before!=target&&! (valid_patterns[v]&3))CHECK(t.logs[2654]==1);
        if(!mode && before==50 && target==80 && (valid_patterns[v]&2)){
            CHECK(t.fan_sets==1);CHECK(t.controller.pid.target==60);CHECK(t.controller.pid.integral==50);CHECK(t.history.previous_temperature==50);
        }
    }
    printf("GENERAL_MONITOR135_NATIVE_PASS scenarios=%" PRIu64 " assertions=%" PRIu64 " physical_io=no real_threads=no composed_cached_collector_and_fan=yes\n",scenarios,assertions);
    return 0;
}
