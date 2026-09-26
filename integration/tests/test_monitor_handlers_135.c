/* Bounded native composition, no device I/O or real thread operations. */
#include "integration/monitor_handlers_135.h"
#include "integration/backend_peripheral_135.h"
#include <inttypes.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static uint64_t scenarios,assertions;
#define CHECK(x) do { ++assertions; if(!(x)){fprintf(stderr,"line %d: %s\n",__LINE__,#x);exit(1);} } while(0)
struct event { uint32_t op,a,b; };
struct test {
    uint64_t first;
    struct vn135_monitor_handlers handlers;
    struct vn135_general_monitor general;
    struct vn135_general_model model;
    struct vn135_general_history history;
    struct vn135_general_chain chains[3];
    struct vn135_temperature_sensor sensors[3][2];
    struct vn135_fan_record fans[2];
    struct vn135_backend_power_state power;
    struct vn135_handler_profile profiles[4];
    struct vn135_handler_profiles table;
    struct vn135_general_scratch scratch;
    struct vn135_peripheral_chain cached[3];
    struct event events[2048];
    uint32_t logs[6500];
    size_t n;
    double now,rate;
    int32_t count,platform,reset_rc,collect_rc,collected;
    unsigned lock_failures,locks,pushed,resets,stops,sets,delays;
    unsigned create_fail,creates,poweroffs,chainresets,thermal_trip;
    unsigned stop_mutates,compose_collector,cached_locks,cached_unlocks;
    uint64_t last;
};
static void record(struct test *t,uint32_t op,uint32_t a,uint32_t b)
{ CHECK(t->n<2048);t->events[t->n++]=(struct event){op,a,b}; }
static int32_t lower(void *p,uint32_t op,uint32_t a,uint32_t b)
{
    struct test *t=p;record(t,op,a,b);
    switch(op){
    case VN135_H_CHAIN_COUNT:return t->count;
    case VN135_H_PLATFORM:return t->platform;
    case VN135_H_EVENT:CHECK(a==2007&&b==0);return -7;
    case VN135_H_STOP:
        ++t->stops;
        if(t->stop_mutates){t->general.running=0;t->general.state=6;}
        return -9; /* Explicit scripted 5e92c, not a recovered stop body. */
    case VN135_H_TRYLOCK:CHECK(a==0x1074&&b==0);return t->locks++<t->lock_failures?16:0;
    case VN135_H_DELAY:CHECK(a==10&&b==0);++t->delays;return -10;
    case VN135_H_CLEANUP_PUSH:CHECK(a==0x5cf34&&b==0);CHECK(t->pushed==0);t->pushed=1;return -11;
    case VN135_H_CLEANUP_POP:CHECK(a==0&&b==0);CHECK(t->pushed==1);t->pushed=0;return -12;
    case VN135_H_UNLOCK:CHECK(a==0x1074&&b==0);CHECK(t->pushed==0);return -13;
    default:CHECK(!"unexpected lower callback");return -1;
    }
}
static double clock_now(void *p){return ((struct test *)p)->now;}
static int32_t cached_count(void *p){return ((struct test *)p)->count;}
static int32_t cached_lock(void *p,uint32_t i)
{struct test *t=p;CHECK(i<3);++t->cached_locks;return 0;}
static int32_t cached_unlock(void *p,uint32_t i)
{struct test *t=p;CHECK(i<3);++t->cached_unlocks;return 0;}
static int32_t collect(void *p,int32_t *out)
{
    struct test *t=p;record(t,0x5db54,0,0);
    /* Do not read *out: the original warmup collector's output starts unset. */
    if(t->compose_collector){
        const struct vn135_peripheral_ops o={.chain_count=cached_count,.lock=cached_lock,.unlock=cached_unlock};
        struct vn135_peripheral_state s={.chains=t->cached};
        for(int i=0;i<3;++i){t->cached[i].word_20=t->chains[i].thermal.state;t->cached[i].byte_24=t->chains[i].thermal.present;}
        return vn135_backend_collect_5db54_135(&s,&o,p,out);
    }
    if(!t->collect_rc)*out=t->collected;
    return t->collect_rc;
}
static int32_t reset(void *p,uint32_t entry,uint32_t mode,uint32_t voltage)
{
    struct test *t=p;CHECK(entry==0x6100c||entry==0x61170);CHECK(mode==0);CHECK(voltage==t->power.word_20c);
    CHECK(t->pushed==1);CHECK(t->handlers.warmup_done_22c==0);record(t,entry,mode,voltage);++t->resets;
    return t->reset_rc;
}
static int32_t set_profile(void *p,const char *key,const char *value)
{
    struct test *t=p;CHECK(strcmp(key,"autotune-profile")==0);CHECK(value==t->profiles[1].key);++t->sets;
    record(t,0x509b4,0,0);
    t->profiles[1].label="Label after write";return -1;
}
static void handler_log(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *detail)
{
    struct test *t=p;CHECK(line<6500);CHECK(level>=1&&level<=3);++t->logs[line];record(t,0xfa0c4,line,level);
    if(line==451){CHECK((int32_t)a<=3);CHECK((int32_t)b==t->handlers.minimum_chains_f8);}
    if(line==2067)CHECK(strcmp(detail,"Label after write")==0);
    else if(line==2084||line==2065)CHECK(detail==t->profiles[1].label);
    else CHECK(!detail);
}
static const struct vn135_monitor_handler_ops handlers_ops={lower,clock_now,collect,reset,set_profile,handler_log};
static int32_t psu_off(void *p){++((struct test *)p)->poweroffs;return 0;}
static int32_t reset_chain(void *p,uint32_t i)
{struct test *t=p;CHECK(i<(uint32_t)t->count);++t->chainresets;return 0;}
static int32_t general_call(void *p,uint32_t op,uint32_t a,uint32_t b)
{
    struct test *t=p;int32_t result=0x2468;
    if(vn135_monitor_handler_dispatch_135(&t->handlers,&handlers_ops,p,op,&result))return result;
    CHECK(result==0x2468);record(t,op,a,b);
    switch(op){
    case VN135_G_CHAIN_COUNT:return t->count;
    case VN135_G_PLATFORM:return t->platform;
    case VN135_G_DELAY:CHECK(a==1000&&b==0);t->general.running=0;return -1;
    case VN135_G_THERMAL:return (int32_t)t->thermal_trip;
    case VN135_G_FAN_TARGET:return t->general.target_temperature;
    case VN135_G_CHAIN_POWER:return 1200;
    case VN135_G_STOP:++t->stops;return -1;
    case VN135_G_POWER_STOP:{
        const struct vn135_backend_power_ops o={.psu_off=psu_off,.chain_count=cached_count,.reset_chain=reset_chain};
        return vn135_backend_power_stop_135(&t->power,&o,p);
    }
    case VN135_G_SENSOR_TEST:case VN135_G_CHIP_SENSOR_TEST:case VN135_G_CHAIN_CHECK:
    case VN135_G_POOL_FLAG:case VN135_G_POOL_MODE:case VN135_G_PSU_AVAILABLE:return 0;
    case VN135_G_CANCEL_TYPE:case VN135_G_NAME:case VN135_G_EXIT:
    case VN135_G_LOCK:case VN135_G_UNLOCK:case VN135_G_EVENT:
    case VN135_G_FULL_FAN:case VN135_G_SET_FAN_TARGET:case VN135_G_MAINTAIN:
    case VN135_G_TUNE_MAINTAIN:case VN135_G_STATE_MAINTAIN:case VN135_G_POOL_UPDATE:
    case VN135_G_RATE_ACTION:return -1; /* Specified ignored-result fixtures. */
    default:CHECK(!"unexpected general callback");return -1;
    }
}
static double number(void *p,uint32_t e,uint32_t i)
{(void)p;CHECK(i<3);CHECK(e==0x59810||e==0xf8df0);return e==0x59810?100.0:0.0;}
static int32_t read_power(void *p,uint32_t *out){(void)p;*out=3400;return -1;}
static int32_t read_psu(void *p,uint8_t *v,int16_t out[3]){(void)p;(void)v;(void)out;return -1;}
static int32_t read_fault(void *p,uint32_t i,uint32_t *out){struct test *t=p;CHECK(i<3);CHECK(out==&t->chains[i].fault_3c);return -1;}
static int32_t stop_chain(void *p,struct vn135_route_chain *c,const char *reason)
{(void)p;CHECK(reason&&*reason);c->state=3;return -1;}
static int32_t create_shutdown(void *p,uint32_t slot,uint32_t e,uint32_t *out)
{struct test *t=p;CHECK(slot<3&&e==0x72ba4);CHECK(out==&t->scratch.handles[slot]);++t->creates;return t->create_fail?-1:0;}
static void general_log(void *p,uint32_t l,uint32_t lev,uint32_t a,uint32_t b,double v,const char *s)
{struct test *t=p;(void)a;(void)b;(void)v;(void)s;CHECK(l<6500&&lev>=1&&lev<=3);++t->logs[l];}
static const struct vn135_general_ops general_ops={general_call,clock_now,number,collect,read_power,read_psu,read_fault,stop_chain,create_shutdown,general_log};
static void init(struct test *t)
{
    memset(t,0,sizeof(*t));t->first=UINT64_C(0x6b7786073060d58);t->last=~t->first;
    t->count=3;t->platform=4;t->collected=70;t->now=100;t->power=(struct vn135_backend_power_state){1,13500};
    t->model=(struct vn135_general_model){2,2,88,2,0};
    t->history=(struct vn135_general_history){100,100,100,100,100,60};
    t->general=(struct vn135_general_monitor){.model=&t->model,.chains=t->chains,.fans=t->fans,.history=&t->history,.global_rate=&t->rate,.state=2,.target_temperature=70,.required_fans=2,.available_fans=2,.psu_temperature_limit=100,.tune_percent=100,.running=1,.active=1};
    t->profiles[0]=(struct vn135_handler_profile){"100","Low"};t->profiles[1]=(struct vn135_handler_profile){"200","Medium"};
    t->profiles[2]=(struct vn135_handler_profile){"300","High"};t->profiles[3]=(struct vn135_handler_profile){"400","Top"};
    t->table=(struct vn135_handler_profiles){t->profiles,4};
    t->handlers=(struct vn135_monitor_handlers){.general=&t->general,.power=&t->power,.profiles=&t->table,.current_preset_fc8="300",.minimum_preset_b8="100",.minimum_chains_f8=2,.warmup_e4=1,.lower_preset_95=1};
    for(int i=0;i<3;++i){
        t->chains[i].thermal.index=(uint32_t)i;t->chains[i].thermal.state=2;t->chains[i].thermal.present=1;t->chains[i].detected_8c=88;
        t->chains[i].thermal.sensors=t->sensors[i];double rate=100;memcpy(t->chains[i].thermal.statistics,&rate,8);
        for(int j=0;j<2;++j){t->sensors[i][j].access_kind=4;t->sensors[i][j].role=2;t->sensors[i][j].state=2;}
        t->cached[i].word_2ac=60+i*10;t->cached[i].byte_2b0=1;
    }
}
static void finish(struct test *t)
{++scenarios;CHECK(t->first==UINT64_C(0x6b7786073060d58));CHECK(t->last==~t->first);CHECK(t->pushed==0);CHECK(t->cached_locks==t->cached_unlocks);}
static unsigned event_count(struct test *t,uint32_t op,uint32_t a)
{unsigned n=0;for(size_t i=0;i<t->n;++i)if(t->events[i].op==op&&t->events[i].a==a)++n;return n;}
int main(void)
{
    struct test t;int32_t result;
    for(unsigned state=0;state<8;++state)for(int count=0;count<=3;++count)for(int min=0;min<=4;++min)for(unsigned flag=0;flag<2;++flag)for(unsigned present=0;present<2;++present){
        init(&t);t.count=count;t.handlers.minimum_chains_f8=min;t.model.query_fault_87=(uint8_t)flag;
        for(int i=0;i<3;++i){t.chains[i].thermal.state=state;t.chains[i].thermal.present=(uint8_t)present;}
        int active=(present&&(state<3||state>5))?count:0;
        int bad=(!flag&&count&&(state==3||state==5));
        CHECK(vn135_monitor_chain_decision_135(&t.handlers,&handlers_ops,&t)==((bad||active<min)?-1:0));
        CHECK(t.logs[445]==(unsigned)(bad!=0));CHECK(t.logs[451]==(unsigned)(!bad&&active<min));finish(&t);
    }
    for(unsigned mutate=0;mutate<2;++mutate){
        init(&t);t.count=0;t.stop_mutates=mutate;vn135_monitor_check_chains_135(&t.handlers,&handlers_ops,&t);
        CHECK(t.stops==2);CHECK(t.logs[2167]==1&&t.logs[2173]==1);CHECK(event_count(&t,VN135_H_EVENT,2007)==2);finish(&t);
    }
    for(unsigned failures=0;failures<5;++failures)for(int rc=-1;rc<=1;++rc){
        init(&t);t.lock_failures=failures;t.reset_rc=rc;vn135_monitor_finish_warmup_135(&t.handlers,&handlers_ops,&t);
        CHECK(t.resets==1&&t.locks==failures+1&&t.delays==failures);CHECK(t.handlers.warmup_done_22c==1);CHECK(t.logs[2740]==(unsigned)(rc!=0));
        vn135_monitor_finish_warmup_135(&t.handlers,&handlers_ops,&t);CHECK(t.resets==1);finish(&t);
    }
    for(int count=0;count<=3;++count)for(unsigned valid=0;valid<8;++valid)for(int target=60;target<=90;target+=10){
        init(&t);t.compose_collector=1;t.count=count;t.general.target_temperature=target;int max=INT_MIN,found=0;
        for(int i=0;i<3;++i){t.cached[i].byte_2b0=(uint8_t)((valid>>i)&1);if(i<count&&t.cached[i].byte_2b0){max=t.cached[i].word_2ac;found=1;}}
        vn135_monitor_finish_warmup_135(&t.handlers,&handlers_ops,&t);CHECK(t.resets==(unsigned)(found&&max>=target));CHECK(t.handlers.warmup_done_22c==(uint8_t)(found&&max>=target));finish(&t);
    }
    init(&t);t.collect_rc=-1;vn135_monitor_finish_warmup_135(&t.handlers,&handlers_ops,&t);CHECK(t.resets==0&&t.handlers.warmup_done_22c==0);finish(&t);
    init(&t);t.handlers.warmup_done_22c=19;t.general.active=0;vn135_monitor_finish_warmup_135(&t.handlers,&handlers_ops,&t);CHECK(t.handlers.warmup_done_22c==19);finish(&t);
    for(int minimum=0;minimum<=3;++minimum){
        init(&t);t.handlers.minimum_enabled_b0=1;t.handlers.minimum_preset_b8=t.profiles[minimum].key;
        vn135_monitor_lower_preset_135(&t.handlers,&handlers_ops,&t);CHECK(t.sets==(unsigned)(minimum<=1));CHECK(t.logs[2067]==t.sets);finish(&t);
    }
    init(&t);result=0x2345;CHECK(!vn135_monitor_handler_dispatch_135(&t.handlers,&handlers_ops,&t,0x5e92c,&result));CHECK(result==0x2345&&t.n==0);finish(&t);
    /* Real general worker -> real handlers -> real cached collector. */
    init(&t);t.compose_collector=1;vn135_general_monitor_135(&t.general,&general_ops,&t,&t.scratch);
    CHECK(t.resets==1&&t.stops==0&&t.sets==0);CHECK(t.general.running==0&&t.handlers.warmup_done_22c==1);finish(&t);
    /* Stop mutation does not suppress the second 60730 report; upper then sees
     * the changed fields instead of continuing normal thermal checks. */
    init(&t);t.count=0;t.stop_mutates=1;vn135_general_monitor_135(&t.general,&general_ops,&t,&t.scratch);
    CHECK(t.stops==2&&t.logs[2173]==1);CHECK(t.creates==0&&t.resets==0);finish(&t);
    /* Lost-temperature chain -> 60a2c -> failed shutdown create -> recovered
     * power-stop, with separately scripted PSU/reset callbacks. */
    for(unsigned fail=0;fail<2;++fail){
        init(&t);t.thermal_trip=1;t.create_fail=fail;t.handlers.warmup_e4=0;
        vn135_general_monitor_135(&t.general,&general_ops,&t,&t.scratch);
        CHECK(t.chains[0].thermal.state==3);CHECK(t.logs[445]==1);CHECK(t.creates==1);
        CHECK(event_count(&t,VN135_G_EVENT,2006)==1);CHECK(t.poweroffs==fail&&t.chainresets==fail*3);
        CHECK(t.power.byte_ff1==(uint8_t)!fail);CHECK(t.power.word_20c==(fail?0u:13500u));finish(&t);
    }
    /* Chip break -> table predecessor handler -> scripted 5e92c. */
    init(&t);t.platform=0;t.chains[0].detected_8c=87;vn135_general_monitor_135(&t.general,&general_ops,&t,&t.scratch);
    CHECK(t.sets==1&&t.stops==1&&t.logs[2067]==1);CHECK(event_count(&t,VN135_G_EVENT,2008)==1);finish(&t);
    printf("MONITOR_HANDLERS135_NATIVE_PASS scenarios=%" PRIu64 " assertions=%" PRIu64 " general_worker=yes cached_collector=yes power_stop=yes physical_io=no real_threads=no\n",scenarios,assertions);
    return 0;
}
