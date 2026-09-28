/* Deterministic host tests; no OS/device/thread callbacks. */
#include "integration/chip_sensor_check_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned scenarios, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"CHIPSENSE_ASSERT line %d: %s\n",__LINE__,#x); exit(1); } } while (0)
struct fields {
    uint64_t first;
    struct vn135_general_monitor general;
    struct vn135_general_model model[2];
    struct vn135_general_chain chains[2][3];
    struct vn135_temperature_sensor sensors[2][3][4];
    uint64_t last;
};
struct fixture {
    struct fields data, expected;
    int32_t chain_count;
    int mutation;
    unsigned count_calls, predicate_calls, creates, events, power_calls;
    int other_sensor;
    struct vn135_general_history history;
    struct vn135_fan_record fans[4];
    double rate;
};
static void init(struct fixture *f)
{
    memset(f,0,sizeof(*f));
    f->data.first=UINT64_C(0xdeadfeed1234abcd);f->data.last=~f->data.first;
    f->chain_count=3;
    f->data.general.model=&f->data.model[0];
    f->data.general.chains=f->data.chains[0];
    f->data.model[0].sensor_count=4;f->data.model[1].sensor_count=1;
    for (unsigned b=0;b<2;++b) for(unsigned c=0;c<3;++c) {
        struct vn135_route_chain *chain=&f->data.chains[b][c].thermal;
        chain->index=c+10;chain->present=1;chain->state=2;
        chain->sensors=f->data.sensors[b][c];chain->sensor_count=0;
        for(unsigned j=0;j<4;++j) {
            struct vn135_temperature_sensor *s=&f->data.sensors[b][c][j];
            s->index=100+j;s->state=3;s->access_kind=2;s->role=2;
            s->sample=-100;s->corrected=4567;s->failures=99;
            s->sampled_at=-1000;s->local_offset=123;s->remote_offset=-3;
        }
    }
}
static int32_t count(void *p)
{
    struct fixture *f=p;++f->count_calls;
    if(f->mutation==1)f->data.model[0].sensor_count=0;
    if(f->mutation==2)f->data.model[0].sensor_count=4;
    if(f->mutation==3){f->data.general.model=&f->data.model[1];f->data.general.chains=f->data.chains[1];}
    if(f->mutation==4)f->data.chains[0][0].thermal.present=0;
    if(f->mutation==5)f->data.sensors[0][0][0].state=3;
    memcpy(&f->expected,&f->data,sizeof(f->data));
    return f->chain_count;
}
static void run(struct fixture *f,int expected)
{
    unsigned calls=f->count_calls;
    int got=vn135_backend_has_chip_sensor_135(&f->data.general,count,f);
    CHECK(got==expected);CHECK(f->count_calls==calls+1);
    CHECK(memcmp(&f->data,&f->expected,sizeof(f->data))==0);
    CHECK(f->data.first==UINT64_C(0xdeadfeed1234abcd)&&f->data.last==~f->data.first);
    ++scenarios;
}
static void exhaustive_fields(void)
{
    const uint32_t kinds[]={0,1,2,3,4,0x101,0x102,UINT32_MAX};
    const uint32_t roles[]={0,1,2,3,0x102,UINT32_MAX};
    const uint32_t states[]={0,1,2,3,4,0x10003,UINT32_MAX};
    for(size_t k=0;k<sizeof(kinds)/sizeof(*kinds);++k)
    for(size_t r=0;r<sizeof(roles)/sizeof(*roles);++r)
    for(size_t s=0;s<sizeof(states)/sizeof(*states);++s) {
        struct fixture f;init(&f);
        f.data.sensors[0][0][0].access_kind=kinds[k];
        f.data.sensors[0][0][0].role=roles[r];
        f.data.sensors[0][0][0].state=states[s];
        run(&f,(kinds[k]==1||kinds[k]==2)&&roles[r]==2&&states[s]!=3);
    }
    const uint32_t chain_states[]={0,1,2,3,4,5,6,0x80000000,UINT32_MAX};
    const uint8_t present[]={0,1,2,255};
    for(size_t s=0;s<sizeof(chain_states)/sizeof(*chain_states);++s)
    for(size_t p=0;p<sizeof(present)/sizeof(*present);++p) {
        struct fixture f;init(&f);f.data.sensors[0][0][0].state=0;
        f.data.chains[0][0].thermal.state=chain_states[s];
        f.data.chains[0][0].thermal.present=present[p];
        run(&f,present[p]!=0&&!(chain_states[s]==3||chain_states[s]==4||chain_states[s]==5));
    }
}
static void counts_and_mutations(void)
{
    const int32_t nc[]={INT32_MIN,-1,0,1,2,3};
    const int32_t ns[]={INT32_MIN,-1,0,1,2,3,4};
    for(size_t a=0;a<sizeof(nc)/sizeof(*nc);++a)
    for(size_t b=0;b<sizeof(ns)/sizeof(*ns);++b) {
        struct fixture f;init(&f);f.chain_count=nc[a];f.data.model[0].sensor_count=ns[b];
        f.data.sensors[0][2][3].state=0;
        run(&f,nc[a]==3&&ns[b]==4);
    }
    for(unsigned c=0;c<3;++c)for(unsigned j=0;j<4;++j){
        struct fixture f;init(&f);f.data.sensors[0][c][j].state=0;run(&f,1);
        f.data.sensors[0][c][j].state=3;run(&f,0); /* Repeated calls are live. */
    }
    struct fixture f;
    init(&f);f.data.sensors[0][0][3].state=0;f.mutation=1;run(&f,1);run(&f,0);
    init(&f);f.data.sensors[0][0][0].state=0;f.data.model[0].sensor_count=0;f.mutation=2;run(&f,0);run(&f,1);
    init(&f);f.data.sensors[1][2][3].state=0;f.mutation=3;run(&f,1);run(&f,0);
    init(&f);f.data.sensors[0][0][0].state=0;f.mutation=4;run(&f,0);
    init(&f);f.data.sensors[0][0][0].state=0;f.mutation=5;run(&f,0);
    init(&f);f.chain_count=0;f.data.general.chains=NULL;run(&f,0);
    init(&f);f.data.model[0].sensor_count=0;
    for(unsigned i=0;i<3;++i)f.data.chains[0][i].thermal.sensors=NULL;
    run(&f,0);
    init(&f);for(unsigned i=0;i<3;++i){f.data.chains[0][i].thermal.present=0;f.data.chains[0][i].thermal.sensors=NULL;}
    run(&f,0);
}
/* Actual existing general-monitor C body, not a newly invented caller. */
static int32_t parent_call(void *p,uint32_t op,uint32_t a,uint32_t b)
{
    struct fixture *f=p;(void)b;
    switch(op){
    case VN135_G_CHAIN_COUNT:return count(p);
    case VN135_G_CHIP_SENSOR_TEST:++f->predicate_calls;return vn135_backend_has_chip_sensor_135(&f->data.general,count,p);
    case VN135_G_SENSOR_TEST:return f->other_sensor;
    case VN135_G_EVENT:if(a==2006)++f->events;return 0;
    case VN135_G_POWER_STOP:++f->power_calls;return 0;
    case VN135_G_FAN_TARGET:return 70;
    case VN135_G_DELAY:f->data.general.running=0;return 0;
    default:return 0;
    }
}
static double now(void *p){(void)p;return 105.0;}
static double number(void *p,uint32_t op,uint32_t c){(void)p;(void)op;(void)c;return 100.0;}
static int32_t collect(void *p,int32_t *v){(void)p;*v=60;return 0;}
static int32_t power(void *p,uint32_t *v){(void)p;*v=0;return 0;}
static int32_t psu(void *p,uint8_t *v,int16_t t[3]){(void)p;*v=0;memset(t,0,3*sizeof(*t));return 0;}
static int32_t fault(void *p,uint32_t c,uint32_t *v){(void)p;(void)c;*v=0;return 0;}
static int32_t stop(void *p,struct vn135_route_chain *c,const char *s){(void)p;(void)c;(void)s;return 0;}
static int32_t create(void *p,uint32_t slot,uint32_t entry,uint32_t *handle)
{struct fixture *f=p;CHECK(slot==1&&entry==0x72ba4);(void)handle;++f->creates;return -1;}
static void parents(void)
{
    const struct vn135_general_ops ops={parent_call,now,number,collect,power,psu,fault,stop,create,NULL};
    for(unsigned active=0;active<2;++active)for(unsigned other=0;other<2;++other)
    for(unsigned kind=0;kind<5;++kind)for(unsigned match=0;match<2;++match){
        struct fixture f;struct vn135_general_scratch scratch={{17,29,41}};init(&f);
        f.history=(struct vn135_general_history){100,100,100,100,100,60};
        struct vn135_general_monitor *g=&f.data.general;
        g->history=&f.history;g->fans=f.fans;g->global_rate=&f.rate;
        g->state=active?2:0;g->suppress_thermal=1;g->target_temperature=70;
        g->required_fans=0;g->available_fans=0;g->started_at=100;
        f.other_sensor=(int)other;
        f.data.sensors[0][0][0].access_kind=kind;
        f.data.sensors[0][0][0].state=match?0:3;
        unsigned trip=active&&!other&&!(match&&(kind==1||kind==2||kind==4));
        vn135_general_monitor_135(g,&ops,&f,&scratch);
        CHECK(f.predicate_calls==(active&&!other));CHECK(f.events==trip);
        CHECK(f.creates==trip&&f.power_calls==trip);CHECK(!g->running);
        CHECK(f.data.sensors[0][0][0].state==(match?0u:3u));
        CHECK(f.data.first==UINT64_C(0xdeadfeed1234abcd)&&f.data.last==~f.data.first);
        ++scenarios;
    }
}
int main(void)
{
    exhaustive_fields();counts_and_mutations();parents();
    printf("CHIP_SENSOR_CHECK135_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);
    return 0;
}
