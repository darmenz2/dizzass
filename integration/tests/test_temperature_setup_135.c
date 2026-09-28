/* Host RAM effects only: no sensor, registry, OS thread or device binding. */
#include "integration/temperature_setup_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned scenarios, checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"SETUP135_ASSERT %d: %s\n",__LINE__,#x); exit(1); } } while (0)
enum event { COUNT=1, INIT, LOG, STOP, KEY, REGISTER, CHIP_CHECK };
struct record { unsigned kind; uint32_t a,b; };
struct fixture {
    unsigned guard0;
    struct vn135_general_model model;
    struct vn135_general_monitor general;
    struct vn135_general_chain chains[3], alternate[3];
    struct vn135_monitor_handlers handlers;
    struct vn135_resume_description description, alternate_description;
    uint32_t types[6], roles[6], alternate_types[6], alternate_roles[6];
    struct vn135_temperature_setup_view view;
    struct vn135_monitor_handler_ops h;
    struct vn135_temperature_setup_ops ops;
    int32_t counts[8], init_rc, chip_rc;
    unsigned used, ncount, ninit, nstop, nkey, nregister, ncheck;
    unsigned effect;
    uint32_t key;
    struct vn135_route_chain *first_chain, *stopped_chain;
    struct record trace[96];
    unsigned resume_stage, resume_create, resume_unlock, resume_bad_setup;
    unsigned guard1;
};
static void event(struct fixture *f,unsigned kind,uint32_t a,uint32_t b)
{ CHECK(f->used<96); f->trace[f->used++]=(struct record){kind,a,b}; }
static int32_t count(void *p,uint32_t entry,uint32_t a,uint32_t b)
{
    struct fixture *f=p;CHECK(entry==0xfe668 && a==0 && b==0);
    unsigned i=f->ncount++;event(f,COUNT,i,0);return f->counts[i<8?i:7];
}
static void log_call(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *text)
{
    struct fixture *f=p;CHECK(level==1 && text==NULL);CHECK(line==1811||line==445||line==451);
    event(f,LOG,line,a);(void)b;
    if (f->effect==1 && line==1811) f->general.suppress_thermal=0;
}
static int32_t initialize(void *p,struct vn135_route_chain *chain,uint32_t mode)
{
    struct fixture *f=p;
    CHECK(mode==f->general.mode);event(f,INIT,chain->index,mode);++f->ninit;
    if (f->ninit==1) f->first_chain=chain;
    if (f->effect==2 && f->ninit==1) f->general.chains=f->alternate;
    if (f->effect==3 && f->ninit==1) {
        f->view.description=&f->alternate_description;f->view.roles=f->alternate_roles;
    }
    return f->init_rc;
}
static int32_t stop_chain(void *p,struct vn135_route_chain *chain,const char *reason)
{
    struct fixture *f=p;CHECK(strcmp(reason,"Failed to init temp sensors")==0);
    event(f,STOP,chain->index,0);++f->nstop;
    if (f->nstop==1) f->stopped_chain=chain;
    return -123; /* Explicit failure script; original ignores this result. */
}
static uint32_t key(void *p)
{ struct fixture *f=p;event(f,KEY,0,0);++f->nkey;return f->key; }
static void register_reply(void *p,uint32_t k,struct vn135_general_monitor *g,uint32_t handler)
{
    struct fixture *f=p;CHECK(k==f->key && g==&f->general && handler==0x78aa4);
    event(f,REGISTER,k,handler);++f->nregister;
    if (f->effect==4) f->roles[0]=0;
}
static int32_t chip_check(void *p,struct vn135_general_monitor *g)
{
    struct fixture *f=p;CHECK(g==&f->general);event(f,CHIP_CHECK,0,0);++f->ncheck;return f->chip_rc;
}
static void init(struct fixture *f)
{
    memset(f,0,sizeof(*f));f->guard0=0x193bad84;f->guard1=0x8021fecd;
    f->general.model=&f->model;f->general.chains=f->chains;f->general.mode=2;
    f->handlers.general=&f->general;f->handlers.minimum_chains_f8=0;
    f->description.table_types=f->types;f->description.table_count=1;
    f->alternate_description.table_types=f->alternate_types;f->alternate_description.table_count=1;
    f->view=(struct vn135_temperature_setup_view){&f->handlers,&f->description,f->roles};
    f->h.call=count;f->h.log=log_call;
    f->ops=(struct vn135_temperature_setup_ops){&f->h,initialize,stop_chain,key,register_reply,chip_check};
    f->types[0]=2;f->roles[0]=2;f->key=0x44;f->chip_rc=1;
    for (unsigned i=0;i<8;++i) f->counts[i]=3;
    for (unsigned i=0;i<3;++i) {
        f->chains[i].thermal.index=i+10;f->chains[i].thermal.present=1;f->chains[i].thermal.state=2;
        f->alternate[i].thermal.index=i+110;f->alternate[i].thermal.present=1;f->alternate[i].thermal.state=2;
        memset(f->chains[i].thermal.reason,0x51,sizeof(f->chains[i].thermal.reason));
    }
}
static int32_t run(struct fixture *f)
{
    int32_t result=vn135_backend_temperature_setup_135(&f->view,&f->ops,f);
    CHECK(f->guard0==0x193bad84 && f->guard1==0x8021fecd);
    CHECK(f->used>0 && f->trace[0].kind==COUNT);++scenarios;return result;
}
static void sweep(void)
{
    const uint32_t kinds[]={0,1,2,3,4,0xffffffff};
    const uint32_t states[]={0,2,3,4,5,6,0xffffffff};
    for (unsigned k=0;k<6;++k) for (unsigned role=0;role<4;++role)
    for (int n=0;n<=3;++n) for (unsigned st=0;st<7;++st)
    for (unsigned present=0;present<2;++present) {
        struct fixture f;struct vn135_general_chain before[3];init(&f);
        f.types[0]=kinds[k];f.roles[0]=role;f.init_rc=(k+role+st)%2?-1:0;
        f.general.suppress_thermal=(uint8_t)((k+role)%2);
        for (unsigned i=0;i<8;++i) f.counts[i]=n;
        for (unsigned i=0;i<3;++i) { f.chains[i].thermal.state=states[st];f.chains[i].thermal.present=(uint8_t)present; }
        memcpy(before,f.chains,sizeof before);
        int applies=kinds[k]==1||kinds[k]==2;
        int alive=n>0 && present && states[st]-3u>2u;
        int bad=n>0 && (states[st]==3||states[st]==5);
        CHECK(run(&f)==(!applies?0:bad||!alive?-1:0));
        CHECK(f.ninit==(applies?(unsigned)n:0));
        CHECK(f.nstop==(applies && f.init_rc && !f.general.suppress_thermal?(unsigned)n:0));
        CHECK(f.nregister==(unsigned)(applies && kinds[k]==2));CHECK(f.nkey==f.nregister);
        CHECK(f.ncheck==(unsigned)(applies && role==2));
        CHECK(memcmp(before,f.chains,sizeof before)==0);
        if (!applies) CHECK(f.used==1 && f.ncount==1);
    }
}
static void boundaries(void)
{
    struct fixture f;
    for (unsigned i=0;i<3;++i) { init(&f);f.description.table_count=i==0?INT32_MIN:i==1?-1:0;
        f.view.roles=NULL;CHECK(run(&f)==0);CHECK(f.used==1); }
    for (int n=-1;n<=0;++n) { init(&f);for (unsigned i=0;i<8;++i) f.counts[i]=n;
        CHECK(run(&f)==-1);CHECK(!f.ninit && f.nregister==1); }
    init(&f);f.effect=1;f.general.suppress_thermal=1;f.init_rc=-1;CHECK(run(&f)==0);CHECK(f.nstop==3);
    init(&f);f.effect=2;f.init_rc=-1;CHECK(run(&f)==0);CHECK(f.first_chain==f.stopped_chain);
    CHECK(f.first_chain==&f.chains[0].thermal);CHECK(f.general.chains==f.alternate);
    init(&f);f.effect=3;f.alternate_types[0]=1;f.alternate_roles[0]=0;
    CHECK(run(&f)==0);CHECK(!f.nregister && !f.ncheck);
    init(&f);f.effect=4;f.chip_rc=0;CHECK(run(&f)==0);CHECK(f.nregister==1 && !f.ncheck);
    init(&f);f.chip_rc=0;CHECK(run(&f)==-1);CHECK(f.ncount==1);
    init(&f);f.roles[0]=0;f.counts[4]=0;CHECK(run(&f)==-1);CHECK(f.ncount==5);
    for (unsigned i=0;i<3;++i) { init(&f);f.key=i==0?0:i==1?256:UINT32_MAX;CHECK(run(&f)==0);CHECK(f.nregister==1); }
    init(&f);f.init_rc=1;f.h.log=NULL;CHECK(run(&f)==0);CHECK(f.nstop==3);
    init(&f);CHECK(run(&f)==0);unsigned first=f.nregister;CHECK(run(&f)==0);CHECK(f.nregister==first+1);
}
/* A bounded native resume composition: setup failure must stop the parent
 * before thread creation. Accepted setup reaches the first create, which this
 * fixture deliberately rejects. No full runtime/ARM parent composition claim. */
static int32_t resume_step(void *p,enum vn135_resume_step e,uint32_t a,uint32_t b,uint32_t c)
{
    struct fixture *f=p;(void)a;(void)b;(void)c;
    if (e==VN135_R_CHAIN_COUNT) return 3;
    if (e==VN135_R_POOL_CHECK) return 1;
    if (e==VN135_R_CONFIG_6EC4C) { ++f->resume_stage;return run(f); }
    if (e==VN135_R_UNLOCK) ++f->resume_unlock;
    return 0; /* Other earlier source calls: explicit fixed fixture outcome. */
}
static int32_t resume_create(void *p,uint32_t off,uint32_t entry,uintptr_t *out)
{
    struct fixture *f=p;(void)out;CHECK(off==0x1044 && entry==0x790c0);++f->resume_create;return 11;
}
static int32_t power_on(void *p) { (void)p;return 0; }
static int32_t voltage(void *p,uint16_t v) { (void)p;CHECK(v==12000);return 0; }
static void resume_log(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b)
{ struct fixture *f=p;(void)level;(void)a;(void)b;if (line==6184) ++f->resume_bad_setup; }
static void parent_composition(void)
{
    for (int failure=0;failure<2;++failure) {
        struct fixture f;init(&f);f.chip_rc=failure?0:1;
        struct vn135_resume_state s={0};struct vn135_resume_ops o={0};
        struct vn135_backend_power_ops power={0};uintptr_t scratch=0;uint8_t platform=0;
        s.description=&f.description;s.word_20=5;s.word_dc=12000;s.limit_34=15000;s.platform_byte=&platform;
        o.step=resume_step;o.thread_create=resume_create;o.log=resume_log;
        power.psu_on=power_on;power.set_voltage=voltage;
        CHECK(vn135_backend_resume_135(&s,&o,&power,&f,&scratch)==-1);
        CHECK(f.resume_stage==1 && f.resume_unlock==1);
        CHECK(f.resume_create==(unsigned)!failure);CHECK(f.resume_bad_setup==(unsigned)failure);
        CHECK(s.power.byte_ff1==1); /* No invented rollback after the failure. */
    }
}
int main(void)
{
    sweep();boundaries();parent_composition();
    printf("TEMPERATURE_SETUP135_NATIVE_PASS scenarios=%u checks=%u parent_compositions=2\n",scenarios,checks);
    return 0;
}
