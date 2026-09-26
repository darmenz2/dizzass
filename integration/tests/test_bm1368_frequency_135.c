#include "integration/bm1368_frequency_135.h"
#include "integration/chain_frequency_135.h"
#include "integration/frequency_worker_135.h"
#include "integration/bm1368_control.h"
#include <assert.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

static unsigned checks,cases,compositions;
#define CHECK(x) do { ++checks; assert(x); } while(0)
struct fixture {
    uint64_t guard1;
    struct vn135_bm1368_frequency_device device;
    vn135_pll_result result;
    struct vn135_bm1368_frequency_ops ops;
    uint64_t guard2;
    unsigned solves,writes,logs,real_solver,mutation;
    int32_t solver_rc,write_rc[2];
    uint32_t words[64],lines[16],indices[16];
    double requests[32];
    struct vn135_general_chain chains[3];
    struct vn135_route_chip chips[4];
    struct vn135_chain_frequency_view chainview;
    struct vn135_chain_frequency_methods methods;
    struct vn135_chain_frequency_ops chainops;
    unsigned sets,delays,exits,stops,events,locks,pulses;
    int fail_second,pulse_rc;
};
static int32_t solve(void *p,const vn135_pll_limits *limits,double f,vn135_pll_result *out)
{
    struct fixture *s=p;CHECK(limits==&vn135_bm1368_frequency_limits_135);
    CHECK(s->solves<32);s->requests[s->solves++]=f;
    if(s->mutation)s->device.index=13;
    if(s->real_solver)return vn135_bm1368_frequency_solve_135(p,limits,f,out);
    if(!s->solver_rc)*out=s->result;
    return s->solver_rc;
}
static int32_t write_config(void *p,struct vn135_bm1368_frequency_device *device,
    uint32_t mode,const void *chip,uint32_t reg,uint32_t word)
{
    struct fixture *s=p;CHECK(device==&s->device && mode==1 && !chip && reg==8 && s->writes<64);
    unsigned n=s->writes++;s->words[n]=word;
    if(n%2)CHECK(s->words[n-1]==word);
    if(s->mutation)device->index=(n%2)?UINT32_MAX:19;
    uint8_t packet[11];size_t written=0;
    CHECK(dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_CONFIG,1,0,8,word,packet,sizeof packet,&written)==0);
    CHECK(written==11 && packet[0]==0x55 && packet[1]==0xaa && packet[2]==0x51 && packet[5]==8);
    if(s->fail_second && n==1)return -77;
    return s->write_rc[n%2];
}
static void log_message(void *p,uint32_t line,uint32_t index,double request)
{
    struct fixture *s=p;CHECK(s->logs<16 && (line==966 || line==972));
    CHECK(index==s->device.index+1u && request==s->requests[s->solves-1]);
    s->lines[s->logs]=line;s->indices[s->logs++]=index;
}
static void init(struct fixture *s)
{
    memset(s,0,sizeof *s);s->guard1=UINT64_C(0x13502468deadbeef);s->guard2=~s->guard1;
    s->device.index=42;s->result=(vn135_pll_result){2400.,2,192,4,1,1,0};
    s->ops=(struct vn135_bm1368_frequency_ops){solve,write_config,log_message};
}
static void guards(const struct fixture *s)
{CHECK(s->guard1==UINT64_C(0x13502468deadbeef) && s->guard2==~s->guard1);}
static void direct(void)
{
    const double vcos[]={1999.99,2000.,2399.999,2400.,3200.,3200.001};
    const int32_t returns[]={0,-1,7,INT32_MIN};
    for(unsigned v=0;v<sizeof vcos/sizeof *vcos;++v)
    for(unsigned a=0;a<4;++a)for(unsigned b=0;b<4;++b)for(unsigned bad=0;bad<2;++bad){
        struct fixture s;init(&s);s.result.vco_mhz=vcos[v];s.solver_rc=bad?-5:0;
        s.write_rc[0]=returns[a];s.write_rc[1]=returns[b];s.mutation=1;
        int32_t rc=vn135_bm1368_set_frequency_135(&s.device,600.75,&s.ops,&s);
        int in_range=vcos[v]>=2000. && vcos[v]<=3200.;
        CHECK(rc==(bad || !in_range || returns[b]?-1:0));
        CHECK(s.solves==1 && s.writes==(!bad && in_range?2u:0u));
        CHECK(s.logs==(rc?1u:0u));
        if(s.logs)CHECK(s.lines[0]==(bad?966u:972u));
        if(s.writes)CHECK(s.words[0]==(vcos[v]<2400.?UINT32_C(0x40c00230):UINT32_C(0x50c00230)));
        guards(&s);++cases;
    }
    const struct { int32_t r,f,a,b; uint32_t word; } vectors[]={
        {0,0,0,0,0x50000077},{2,192,4,1,0x50c00230},{63,4095,8,8,0x5fff3f77},
        {64,4096,9,9,0x50000000},{-1,-1,-1,-1,0x5fff3f66}};
    for(unsigned i=0;i<sizeof vectors/sizeof *vectors;++i){
        struct fixture s;init(&s);s.result.reference_divider=vectors[i].r;s.result.feedback_divider=vectors[i].f;
        s.result.post_divider1=vectors[i].a;s.result.post_divider2=vectors[i].b;
        CHECK(vn135_bm1368_set_frequency_135(&s.device,625.,&s.ops,&s)==0);
        CHECK(s.words[0]==vectors[i].word);guards(&s);++cases;
    }
    for(unsigned f=50;f<=1600;f+=25)for(unsigned a=0;a<4;++a)for(unsigned b=0;b<4;++b){
        struct fixture s;init(&s);s.real_solver=1;s.write_rc[0]=returns[a];s.write_rc[1]=returns[b];
        vn135_pll_result r;int calc=vn135_pll_search_legacy(&vn135_bm1368_frequency_limits_135,(double)f,&r);
        int valid=!calc && r.vco_mhz>=2000. && r.vco_mhz<=3200.;
        int status=vn135_bm1368_set_frequency_135(&s.device,(double)f,&s.ops,&s);
        CHECK(status==(!valid || returns[b]?-1:0));CHECK(s.writes==(valid?2u:0u));
        guards(&s);++cases;
    }
    struct fixture s;init(&s);s.solver_rc=-1;s.ops.log=NULL;
    CHECK(vn135_bm1368_set_frequency_135(&s.device,0.,&s.ops,&s)==-1 && s.writes==0);guards(&s);++cases;
}
static int32_t chain_apply(void *p,struct vn135_general_chain *chain,double f)
{
    struct fixture *s=p;CHECK(chain==s->chains);++s->sets;
    return vn135_bm1368_set_frequency_135(&s->device,f,&s->ops,s);
}
static int32_t lock_chain(void *p,struct vn135_general_chain *chain)
{struct fixture *s=p;CHECK(chain==s->chains);++s->locks;return 0;}
static int32_t unlock_chain(void *p,struct vn135_general_chain *chain)
{struct fixture *s=p;CHECK(chain==s->chains && s->locks==s->sets);return 0;}
static uint32_t platform(void *p){(void)p;return 4;}
static int32_t pulse(void *p,struct vn135_general_chain *c,uint32_t b,uint32_t a,uint32_t one)
{
    struct fixture *s=p;CHECK(c==s->chains && b==17 && a==(c->thermal.cleared_words[0]<450?4u:29u) && one==1);
    ++s->pulses;return s->pulse_rc;
}
static int32_t worker_set(void *p,struct vn135_general_chain *c,uint32_t a,uint32_t b,double f)
{struct fixture *s=p;CHECK(c==s->chains);return vn135_chain_set_frequency_135(&s->chainview,a,b,f,&s->chainops,s);}
static int32_t worker_call(void *p,uint32_t entry,uint32_t a,uint32_t b)
{
    struct fixture *s=p;CHECK(b==0);
    switch(entry){
    case 0x5a6b2c:CHECK(a==1);break;
    case 0x593af8:CHECK(a==15);break;
    case 0x10ef3c:CHECK(a==100);++s->delays;break;
    case 0x5a52d0:CHECK(a==0);++s->exits;break;
    case 0x49c98:CHECK(a==2010);++s->events;break;
    case 0x6b778:CHECK(a==0);break;
    default:CHECK(0);
    }return 0;
}
static int32_t stop_chain(void *p,struct vn135_route_chain *c,const char *why)
{struct fixture *s=p;CHECK(c==&s->chains[0].thermal && !strcmp(why,"Failed to set minimum frequency"));++s->stops;c->state=3;return 0;}
static int32_t decide(void *p,uint32_t entry,uint32_t a,uint32_t b)
{(void)p;CHECK(entry==0xfe668 && a==0 && b==0);return 3;}
static int32_t shutdown_request(void *p,uint32_t *h,uint32_t entry,struct vn135_frequency_fall_state *backend)
{(void)p;CHECK(h && backend && entry==0x72ba4);*h=9;return -1;}
static void composed(void)
{
    for(int start=450;start<=900;start+=75)for(int target=300;target<=450;target+=50)
    for(int error=0;error<4;++error){
        struct fixture s;init(&s);s.real_solver=1;
        s.write_rc[0]=error==1?-5:0; /* first write failure must not abort */
        s.fail_second=error==2;s.pulse_rc=error==3?-7:0;
        for(unsigned i=0;i<3;++i){s.chains[i].thermal.present=1;s.chains[i].thermal.state=2;s.chains[i].thermal.index=i;}
        s.chains[0].detected_8c=4;s.chains[0].thermal.chips=s.chips;
        s.chains[0].thermal.cleared_words[0]=(uint32_t)start;
        s.methods=(struct vn135_chain_frequency_methods){chain_apply,pulse};s.chainview=(struct vn135_chain_frequency_view){s.chains,&s.methods};
        s.chainops=(struct vn135_chain_frequency_ops){lock_chain,unlock_chain,platform,NULL};
        struct vn135_general_model model={0};struct vn135_general_monitor general={0};general.model=&model;general.chains=s.chains;
        struct vn135_monitor_handlers handlers={0};handlers.general=&general;handlers.minimum_chains_f8=2;
        struct vn135_frequency_fall_config cfg={100,target};struct vn135_frequency_fall_state fall={&general,&cfg};
        struct vn135_frequency_fall_argument argument={&fall,s.chains};struct vn135_frequency_worker_control control={17,29};
        struct vn135_frequency_worker_view view={&control,&handlers};struct vn135_monitor_handler_ops decisions={0};decisions.call=decide;
        struct vn135_frequency_worker_ops ops={worker_call,worker_set,stop_chain,shutdown_request,NULL,&decisions};
        CHECK(vn135_frequency_fall_worker_135(&argument,&view,&ops,&s)==VN135_FREQUENCY_THREAD_EXIT);
        if(error>=2){
            CHECK(s.sets==1 && s.writes==2 && s.stops==1 && s.events==1 && s.delays==0);
            CHECK(s.locks==(error==3?1u:0u));
            CHECK(s.chains[0].thermal.cleared_words[0]==(uint32_t)(error==3?(start/50)*50:start));
        }else{
            unsigned expected=0;for(int f=(start/50)*50;;){CHECK(s.requests[expected++]==(double)f);if(f==target)break;f-=100;if(f<target)f=target;}
            CHECK(s.writes==2*expected && s.delays==expected && s.sets==expected && s.stops==0);
            for(unsigned i=0;i<4;++i)CHECK(s.chips[i].word_08==(uint32_t)target);
        }
        CHECK(s.exits==1 && s.device.index==42);guards(&s);++compositions;++cases;
    }
}
int main(void)
{
    direct();composed();printf("BM1368_FREQUENCY135_NATIVE_PASS cases=%u assertions=%u worker_chain_pll_compositions=%u hardware=no\n",cases,checks,compositions);return 0;
}
