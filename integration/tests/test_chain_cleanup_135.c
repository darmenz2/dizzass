/* Host-only byte/canary checks; no hardware, clock or live thread calls. */
#include "integration/chain_cleanup_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"CHAIN_CLEANUP_ASSERT line=%d %s\n",__LINE__,#x); exit(1); } } while (0)
enum { CAP=4, RESET=1, DELAY, LOG, EXCHANGE, LOCK, UNLOCK };
struct guarded { uint8_t before[8]; struct vn135_route_chip chips[CAP]; uint8_t after[8]; };
struct fixture {
    struct vn135_general_chain chain;
    struct vn135_general_monitor backend;
    struct vn135_general_model models[2];
    struct vn135_chain_cleanup_view view;
    struct guarded banks[2];
    unsigned events[32], used, exchanges, delay500, logs, fail, mutation;
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
    if(f->mutation){f->backend.model=&f->models[1];chain->chips=f->banks[1].chips;chain->state=4;}
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
static const struct vn135_chain_stop_ops ops={reset,delay,exchange,indicator,lock,unlock,log_line};
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
    f->view=(struct vn135_chain_cleanup_view){&f->chain,&f->backend,0x81828384,{1,2,3,4}};
}
static void run(uint32_t state,int count,unsigned flag,unsigned present,unsigned aux,unsigned fail,unsigned mutation)
{
    struct fixture f;init(&f,state,count,flag,present,aux);f.fail=fail;f.mutation=mutation;
    struct vn135_general_chain expected=f.chain;
    struct guarded banks[2];memcpy(banks,f.banks,sizeof(banks));
    unsigned bank=mutation?1:0;int limit=mutation?1:count;
    if(mutation){expected.thermal.chips=f.banks[1].chips;expected.thermal.state=4;}
    else if(state<3 || state>5)expected.thermal.state=2;
    memset(expected.thermal.cleared_words,0,sizeof(expected.thermal.cleared_words));
    expected.thermal.auxiliary_enabled=0;
    memset(expected.thermal.statistics,0,sizeof(expected.thermal.statistics));
    for(int i=0;i<limit;++i){
        banks[bank].chips[i].word_08=0;banks[bank].chips[i].valid=0;
        memset(&banks[bank].chips[i].temperature,0,8);
        memset(banks[bank].chips[i].statistics,0,44);
    }
    uint8_t rx[2]={0x31,0x32};
    CHECK(vn135_chain_cleanup_135(&f.view,&ops,&f,rx)==-27);
    CHECK(memcmp(&expected,&f.chain,sizeof(expected))==0);
    CHECK(memcmp(banks,f.banks,sizeof(banks))==0);
    CHECK(f.view.word_80==0);
    for(unsigned i=0;i<4;++i)CHECK(f.view.statistics_tail_6c[i]==0);
    CHECK(f.events[0]==RESET && f.events[1]==DELAY);
    CHECK(f.events[f.used-2]==LOCK && f.events[f.used-1]==UNLOCK);
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
                for(unsigned fail=0;fail<2;++fail)run(states[s],n,flag,present,aux,fail,0);
    run(0,3,1,1,1,1,1);
    printf("CHAIN_CLEANUP135_NATIVE_PASS cases=%u checks=%u hardware_io=0\n",cases,checks);
    return 0;
}
