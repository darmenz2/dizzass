/* Host-only byte/canary checks; no hardware, clock or live thread calls. */
#include "integration/chain_reset_cleanup_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"CHAIN_RESET_CLEANUP_ASSERT line=%d %s\n",__LINE__,#x); exit(1); } } while (0)
enum { CAP=4, RESET=1, DELAY, LOG, EXCHANGE, LOCK, UNLOCK, NOW, AGGREGATE };
struct guarded { uint8_t before[8]; struct vn135_route_chip chips[CAP]; uint8_t after[8]; };
struct sensor_bank { uint8_t before[8]; struct vn135_temperature_sensor records[CAP]; uint8_t after[8]; };
struct fixture {
    struct vn135_general_chain chain;
    struct vn135_general_monitor backend;
    struct vn135_general_model models[2];
    struct vn135_chain_reset_cleanup_view view;
    struct guarded banks[2];
    struct sensor_bank sensors[2];
    unsigned events[32], used, exchanges, delay500, logs, fail, mutation, clocks;
};
static void event(struct fixture *f,unsigned kind)
{ CHECK(f->used<32); f->events[f->used++]=kind; }
static int32_t reset(void *p,uint32_t index,uint32_t asserted)
{
    struct fixture *f=p; CHECK(index==f->chain.thermal.index && asserted==1);event(f,RESET);return -11;
}
static int32_t delay(void *p,uint32_t entry,uint32_t ms)
{
    struct fixture *f=p;event(f,DELAY);
    CHECK((entry==0x10ed2c && ms==100) || (entry==0x10ef3c && ms==500));
    if(ms==500) ++f->delay500;
    return -12;
}
static int32_t exchange(void *p,uint32_t index,uint32_t address,const uint8_t *tx,
    uint32_t size,uint8_t *rx,uint32_t capacity)
{
    static const uint8_t expected[]={0x55,0xaa,5,0x15,0,0,0x1a};
    struct fixture *f=p;event(f,EXCHANGE);++f->exchanges;
    CHECK(index==f->chain.thermal.index && address==(0x20u|(index&7u)));
    CHECK(size==7 && capacity==2 && memcmp(tx,expected,7)==0);
    rx[0]=f->fail?0:0x15;rx[1]=f->fail?0:1;return -13;
}
static int32_t indicator(void *p,uint32_t v)
{ (void)p;(void)v;CHECK(0);return 0; }
static int32_t lock(void *p,struct vn135_route_chain *chain)
{
    struct fixture *f=p;CHECK(chain==&f->chain.thermal);event(f,LOCK);
    if(f->mutation==1){f->backend.model=&f->models[1];chain->chips=f->banks[1].chips;chain->state=4;}
    return -14;
}
static int32_t unlock(void *p,struct vn135_route_chain *chain)
{ struct fixture *f=p;CHECK(chain==&f->chain.thermal);event(f,UNLOCK);return -27; }
static void log_line(void *p,enum vn135_route_log_source source,uint32_t line,
    const uint32_t *args,size_t n)
{
    struct fixture *f=p;event(f,LOG);++f->logs;
    CHECK(args[0]==f->chain.thermal.index+1u);
    CHECK((source==VN135_ROUTE_CHAIN_STOP && n==1 && (line==1840 || line==1843)) ||
          (source==VN135_ROUTE_AUX_STOP && n==4 && line==395));
}
static double now(void *p)
{
    struct fixture *f=p;event(f,NOW);
    CHECK(f->chain.detected_8c==0 && f->view.word_80==0);
    if(!f->clocks) CHECK(f->view.time_70==-17.25 && f->view.time_78==73.5);
    else CHECK(f->view.time_70==101.25 && f->view.time_78==73.5);
    if(f->mutation==2 && f->clocks==1){
        f->backend.model=&f->models[1]; f->chain.thermal.sensors=f->sensors[1].records;
        f->chain.thermal.chips=f->banks[1].chips; f->chain.thermal.state=5;
    }
    return f->clocks++ ? -3.75 : 101.25;
}
static void aggregate(void *p,struct vn135_route_chain *chain)
{
    struct fixture *f=p;CHECK(chain==&f->chain.thermal);
    CHECK(f->used>0 && f->events[f->used-1]==UNLOCK);event(f,AGGREGATE);
}
static const struct vn135_chain_stop_ops stop_ops={reset,delay,exchange,indicator,lock,unlock,log_line};
static const struct vn135_chain_reset_cleanup_ops ops={&stop_ops,now,aggregate};
static void init(struct fixture *f,uint32_t state,int count,unsigned flag,unsigned present,unsigned aux)
{
    memset(f,0,sizeof(*f));memset(&f->chain,0xa6,sizeof(f->chain));
    memset(f->banks,0xb7,sizeof(f->banks));
    f->chain.thermal.index=0xffffffffu;f->chain.thermal.state=state;
    f->chain.thermal.present=(uint8_t)present;f->chain.thermal.auxiliary_enabled=(uint8_t)aux;
    f->chain.thermal.extra_stop_enabled=0;f->chain.thermal.chip_count=0;
    f->chain.thermal.chips=f->banks[0].chips;
    f->models[0].expected_chips_48=count;f->models[0].query_fault_87=(uint8_t)flag;
    f->models[1].expected_chips_48=1;f->backend.model=&f->models[0];
    f->view=(struct vn135_chain_reset_cleanup_view){&f->chain,&f->backend,0x81828384,{1,2,3,4},-17.25,73.5};
    memset(f->sensors,0xc8,sizeof(f->sensors));
    f->chain.thermal.sensors=f->sensors[0].records;
    f->chain.thermal.sensor_count=0;
    f->models[0].sensor_count=3; f->models[1].sensor_count=1;
    for(unsigned b=0;b<2;++b)for(unsigned i=0;i<CAP;++i){
        f->sensors[b].records[i].access_kind=i;
        f->sensors[b].records[i].skip_initial_read=1;
    }
}
static void run(uint32_t state,int count,unsigned flag,unsigned present,unsigned aux,unsigned fail,unsigned mutation,uint32_t kind,unsigned skip,int sensors)
{
    struct fixture f;init(&f,state,count,flag,present,aux);f.fail=fail;f.mutation=mutation;
    f.models[0].sensor_count=sensors;
    for(unsigned b=0;b<2;++b)for(unsigned i=0;i<CAP;++i){
        f.sensors[b].records[i].access_kind=kind;
        f.sensors[b].records[i].skip_initial_read=(uint8_t)skip;
    }
    struct vn135_general_chain expected=f.chain;
    struct guarded banks[2];
    struct sensor_bank saved_sensors[2];
    memcpy(banks,f.banks,sizeof(banks));memcpy(saved_sensors,f.sensors,sizeof(saved_sensors));
    unsigned bank=mutation?1:0;int limit=mutation?1:count;
    if(mutation){
        expected.thermal.chips=f.banks[1].chips;expected.thermal.state=mutation==1?4:5;
        if(mutation==2)expected.thermal.sensors=f.sensors[1].records;
    }
    else if(state<3 || state>5)expected.thermal.state=2;
    memset(expected.thermal.cleared_words,0,sizeof(expected.thermal.cleared_words));
    expected.thermal.auxiliary_enabled=0;
    memset(expected.thermal.statistics,0,sizeof(expected.thermal.statistics));
    for(int i=0;i<limit;++i){
        banks[bank].chips[i].word_08=0;banks[bank].chips[i].valid=0;
        memset(&banks[bank].chips[i].temperature,0,8);
        memset(banks[bank].chips[i].statistics,0,44);
    }
    expected.detected_8c=0;
    unsigned sb=mutation==2?1:0;int sn=mutation?1:sensors;
    if(kind!=0 && kind!=3 && (kind!=4 || skip))for(int i=0;i<sn;++i){
        struct vn135_temperature_sensor *v=&saved_sensors[sb].records[i];
        v->state=v->sample=v->corrected=v->remote_offset=v->failures=0;
        v->extended=v->has_previous=0;v->previous_sample=v->previous_corrected=0;
        memset(&v->sampled_at,0,8);memset(&v->started_at,0,8);
    }
    uint8_t rx[2]={0x31,0x32};
    vn135_chain_reset_cleanup_135(&f.view,&ops,&f,rx);
    CHECK(memcmp(&expected,&f.chain,sizeof(expected))==0);
    CHECK(memcmp(banks,f.banks,sizeof(banks))==0);
    CHECK(f.view.word_80==0);
    CHECK(memcmp(saved_sensors,f.sensors,sizeof(saved_sensors))==0);
    CHECK(f.clocks==2 && f.view.time_70==101.25 && f.view.time_78==-3.75);
    for(unsigned i=0;i<4;++i)CHECK(f.view.statistics_tail_6c[i]==0);
    CHECK(f.events[0]==RESET && f.events[1]==DELAY);
    CHECK(f.events[f.used-5]==LOCK && f.events[f.used-4]==NOW && f.events[f.used-3]==NOW && f.events[f.used-2]==UNLOCK && f.events[f.used-1]==AGGREGATE);
    unsigned engaged=flag && present, exchanged=engaged && aux;
    CHECK(f.exchanges==(exchanged?(fail?3u:1u):0u));
    CHECK(f.delay500==(exchanged && fail?3u:0u));
    CHECK(f.logs==(engaged?1u:0u)+(exchanged && fail?4u:0u));
    ++cases;
}
int main(void)
{
    static const uint32_t states[]={0,1,2,3,4,5,6,0x80000000,0xffffffff};
    for(unsigned s=0;s<sizeof(states)/sizeof(states[0]);++s)
        for(int n=-1;n<=CAP;++n)for(unsigned flag=0;flag<2;++flag)
            for(unsigned present=0;present<2;++present)for(unsigned aux=0;aux<2;++aux)
                for(unsigned fail=0;fail<2;++fail)run(states[s],n,flag,present,aux,fail,0,1,1,3);
    run(0,3,1,1,1,1,1,1,1,4);run(0,3,1,1,1,1,2,1,1,4);
    static const uint32_t kinds[]={0,1,2,3,4,5,255,0xffffffff};
    for(unsigned k=0;k<sizeof(kinds)/sizeof(kinds[0]);++k)
        for(unsigned skip=0;skip<256;++skip)for(int n=-1;n<=CAP;++n)
            run(0,0,0,0,0,0,0,kinds[k],skip,n);
    printf("CHAIN_RESET_CLEANUP135_NATIVE_PASS cases=%u checks=%u hardware_io=0\n",cases,checks);
    return 0;
}
