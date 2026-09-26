#include "integration/chain_frequency_135.h"
#include "integration/frequency_worker_135.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>

static unsigned scenarios,checks;
#define CHECK(x) do { ++checks; assert(x); } while(0)
struct fixture {
    uint64_t before;
    struct vn135_general_chain chains[3];
    struct vn135_route_chip chips[8];
    uint64_t after;
    struct vn135_chain_frequency_view view;
    struct vn135_chain_frequency_methods methods;
    struct vn135_chain_frequency_ops ops;
    unsigned applies,locks,unlocks,platforms,pulses,logs;
    int fail_apply,fail_pulse;
    unsigned platform,mutate_count;
    uint32_t pulse_a,pulse_b;
    double seen[32];
    unsigned delays,exits,stops,events,power_off;
};
static int32_t truncate_frequency(double f)
{
    if(f>=2147483647.0)return INT32_MAX;
    if(f<=-2147483648.0)return INT32_MIN;
    return (int32_t)f;
}
static double mean(const struct vn135_route_chain *c)
{
    uint64_t bits=c->cleared_words[1]|((uint64_t)c->cleared_words[2]<<32);
    double result;memcpy(&result,&bits,sizeof result);return result;
}
static int32_t apply(void *p,struct vn135_general_chain *c,double f)
{
    struct fixture *s=p;CHECK(c==&s->chains[0] && s->applies<32);
    s->seen[s->applies++]=f;
    return s->fail_apply && s->applies==(unsigned)s->fail_apply ? -77 : 0;
}
static int32_t lock(void *p,struct vn135_general_chain *c)
{
    struct fixture *s=p;CHECK(c==&s->chains[0]);++s->locks;
    if(s->mutate_count)c->detected_8c=5;
    return -3; /* Deliberately ignored in original. */
}
static int32_t unlock(void *p,struct vn135_general_chain *c)
{
    struct fixture *s=p;CHECK(c==&s->chains[0]);++s->unlocks;
    CHECK(s->unlocks==s->locks);return -4;
}
static uint32_t platform(void *p)
{struct fixture *s=p;++s->platforms;CHECK(s->unlocks==s->locks);return s->platform;}
static int32_t pulse(void *p,struct vn135_general_chain *c,uint32_t b,uint32_t a,uint32_t one)
{
    struct fixture *s=p;CHECK(c==&s->chains[0] && one==1 && s->platform==4);
    s->pulse_a=a;s->pulse_b=b;++s->pulses;return s->fail_pulse ? -9 : 0;
}
static void log_message(void *p,uint32_t line,uint32_t index,double frequency)
{
    struct fixture *s=p;CHECK(index==s->chains[0].thermal.index+1u);++s->logs;
    CHECK(line==1060 || line==1074);
    if(line==1060)CHECK(frequency==s->seen[s->applies-1]);else CHECK(frequency==0.0);
}
static void init(struct fixture *s,unsigned n,unsigned kind)
{
    memset(s,0,sizeof *s);s->before=UINT64_C(0x1122334455667788);s->after=~s->before;
    s->platform=kind;s->methods=(struct vn135_chain_frequency_methods){apply,pulse};
    s->ops=(struct vn135_chain_frequency_ops){lock,unlock,platform,log_message};
    s->view=(struct vn135_chain_frequency_view){&s->chains[0],&s->methods};
    for(unsigned i=0;i<3;++i){s->chains[i].thermal.state=2;s->chains[i].thermal.present=1;s->chains[i].thermal.index=i;}
    s->chains[0].detected_8c=n;s->chains[0].thermal.chip_count=123; /* Not consulted by this view. */
    s->chains[0].thermal.chips=s->chips;
    for(unsigned i=0;i<8;++i){s->chips[i].word_08=77+i;s->chips[i].index=100+i;s->chips[i].valid=1;s->chips[i].temperature=55.0;}
    for(unsigned i=0;i<4;++i)s->chains[0].thermal.cleared_words[i]=0x31313131;
}
static void guards(struct fixture *s)
{
    CHECK(s->before==UINT64_C(0x1122334455667788) && s->after==~s->before);
    CHECK(s->chains[0].thermal.chip_count==123);
    for(unsigned i=0;i<8;++i)CHECK(s->chips[i].index==100+i && s->chips[i].valid==1 && s->chips[i].temperature==55.0);
}
static void direct_tests(void)
{
    const double frequencies[]={-1e30,-2147483649.0,-2147483648.0,-.9,-0.0,0.0,.9,449.9,450.0,635.75,2147483647.9,1e30};
    struct fixture s;
    for(unsigned fi=0;fi<sizeof frequencies/sizeof *frequencies;++fi)
    for(unsigned n=0;n<=8;++n)for(unsigned kind=0;kind<=5;++kind)
    for(int error=0;error<3;++error){
        double f=frequencies[fi];init(&s,n,kind);s.fail_apply=error==1;s.fail_pulse=error==2;
        int32_t r=vn135_chain_set_frequency_135(&s.view,29,17,f,&s.ops,&s);
        CHECK(s.applies==1 && s.seen[0]==f);
        if(error==1){CHECK(r==-1 && s.locks==0 && s.pulses==0 && s.logs==1);
            for(unsigned i=0;i<4;++i)CHECK(s.chains[0].thermal.cleared_words[i]==0x31313131);
        }else{
            int32_t cached=n?truncate_frequency(f):0;
            CHECK(s.locks==1 && s.unlocks==1 && s.platforms==1);
            CHECK(s.chains[0].thermal.cleared_words[0]==(uint32_t)cached && s.chains[0].thermal.cleared_words[3]==(uint32_t)cached);
            CHECK(mean(&s.chains[0].thermal)==(double)cached);
            CHECK(r==(kind==4 && error==2 ? -1 : 0));
            if(kind==4)CHECK(s.pulses==1 && s.pulse_a==(cached<450?4u:29u) && s.pulse_b==17);
            else CHECK(s.pulses==0);
        }
        for(unsigned i=0;i<8;++i)CHECK(s.chips[i].word_08==((error!=1 && i<n)?(uint32_t)truncate_frequency(f):77+i));
        guards(&s);++scenarios;
    }
    for(unsigned present=0;present<256;++present)for(unsigned state=0;state<8;++state){
        init(&s,2,4);s.chains[0].thermal.present=(uint8_t)present;s.chains[0].thermal.state=state;
        CHECK(vn135_chain_set_frequency_135(&s.view,1,2,500,&s.ops,&s)==0);
        CHECK(s.applies==((present && (uint32_t)(state-3u)>=3u)?1u:0u));guards(&s);++scenarios;
    }
    init(&s,2,4);s.mutate_count=1;
    CHECK(vn135_chain_set_frequency_135(&s.view,29,17,600.75,&s.ops,&s)==0);
    for(unsigned i=0;i<8;++i)CHECK(s.chips[i].word_08==(i<5?600:77+i));
    guards(&s);++scenarios;
}
static int32_t worker_call(void *p,uint32_t entry,uint32_t a,uint32_t b)
{
    struct fixture *s=p;CHECK(b==0);
    switch(entry){
    case 0x5a6b2c:CHECK(a==1);break;
    case 0x593af8:CHECK(a==15);break;
    case 0x10ef3c:CHECK(a==100);++s->delays;break;
    case 0x5a52d0:CHECK(a==0);++s->exits;break;
    case 0x49c98:CHECK(a==2010);++s->events;break;
    case 0x6b778:CHECK(a==0);++s->power_off;break;
    default:CHECK(0);
    }
    return -1;
}
static int32_t worker_set(void *p,struct vn135_general_chain *chain,uint32_t a,uint32_t b,double f)
{
    struct fixture *s=p;CHECK(chain==s->view.chain);
    return vn135_chain_set_frequency_135(&s->view,a,b,f,&s->ops,s);
}
static int32_t worker_stop(void *p,struct vn135_route_chain *chain,const char *why)
{
    struct fixture *s=p;CHECK(chain==&s->chains[0].thermal && strcmp(why,"Failed to set minimum frequency")==0);
    ++s->stops;chain->state=3;return -1;
}
static int32_t create_shutdown(void *p,uint32_t *h,uint32_t entry,struct vn135_frequency_fall_state *backend)
{ (void)p;CHECK(entry==0x72ba4 && backend!=NULL);*h=555;return -1; }
static int32_t decision(void *p,uint32_t entry,uint32_t a,uint32_t b)
{ (void)p;CHECK(entry==0xfe668 && a==0 && b==0);return 3; }
static void composed_tests(void)
{
    for(int start=400;start<=900;start+=37)for(int target=300;target<=650;target+=100)
    for(int error=0;error<3;++error){
        struct fixture s;init(&s,3,4);s.fail_apply=error==1;s.fail_pulse=error==2;
        s.chains[0].thermal.cleared_words[0]=(uint32_t)start;
        struct vn135_general_model model={0};
        struct vn135_general_monitor general={0};general.chains=s.chains;general.model=&model;
        struct vn135_monitor_handlers handlers={0};handlers.general=&general;handlers.minimum_chains_f8=2;
        struct vn135_frequency_fall_config cfg={100,target};
        struct vn135_frequency_fall_state fall={&general,&cfg};
        struct vn135_frequency_fall_argument argument={&fall,&s.chains[0]};
        struct vn135_frequency_worker_control control={17,29};
        struct vn135_frequency_worker_view view={&control,&handlers};
        struct vn135_monitor_handler_ops decisions={0};decisions.call=decision;
        struct vn135_frequency_worker_ops ops={worker_call,worker_set,worker_stop,create_shutdown,NULL,&decisions};
        CHECK(vn135_frequency_fall_worker_135(&argument,&view,&ops,&s)==VN135_FREQUENCY_THREAD_EXIT);
        int first=(start/50)*50;unsigned expected=0;
        if(first>=target){
            if(error){CHECK(s.stops==1 && s.events==1 && s.power_off==1 && s.delays==0);expected=1;}
            else {for(int f=first;;){CHECK(s.seen[expected++]==f);if(f==target)break;f-=100;if(f<target)f=target;}
                CHECK(s.delays==expected && s.chains[0].thermal.cleared_words[0]==(uint32_t)target);}
        }
        CHECK(s.applies==expected && s.exits==1);guards(&s);++scenarios;
    }
}
int main(void)
{
    direct_tests();composed_tests();
    printf("CHAIN_FREQUENCY135_NATIVE_PASS scenarios=%u assertions=%u hardware=no threads=scripted\n",scenarios,checks);
    return 0;
}
