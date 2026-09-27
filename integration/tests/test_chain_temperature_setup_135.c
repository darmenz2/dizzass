/* Deterministic host fixtures, not physical sensors or thread operations. */
#include "integration/chain_temperature_setup_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"CHAINSET_ASSERT line=%d %s\n",__LINE__,#x); exit(1); } } while (0)
struct bank { uint64_t before; struct vn135_temperature_sensor s[4]; uint64_t after; };
struct fixture {
    struct bank bank[2], saved[2];
    struct vn135_general_model model[2];
    struct vn135_general_monitor backend;
    struct vn135_route_chain chain;
    struct vn135_chain_temperature_setup_view view;
    struct vn135_temperature_sensor *captured;
    unsigned calls, logs, slots[8], banks[8], log_states[8];
    int32_t rc;
    unsigned mutation;
    int32_t configure_rc, read_failures, write_rc, finish_rc;
    unsigned reads, writes, delays, times, configurations, finishes;
    uint8_t device_id;
};
static void init(struct fixture *f)
{
    memset(f,0,sizeof(*f));
    for (unsigned b=0;b<2;++b) {
        f->bank[b].before=UINT64_C(0x1122334455667788);
        f->bank[b].after=UINT64_C(0x8877665544332211);
        for (unsigned i=0;i<4;++i) {
            struct vn135_temperature_sensor *s=&f->bank[b].s[i];
            s->index=b*10+i; s->address=76; s->access_kind=1; s->state=2;
            s->role=0; s->device_id=26; s->sample=40; s->corrected=42;
            s->local_offset=2; s->remote_offset=-3; s->failures=7;
            s->previous_sample=38; s->previous_corrected=39;
            s->has_previous=1; s->sampled_at=60; s->started_at=10;
        }
    }
    f->model[0].sensor_count=4; f->model[1].sensor_count=1;
    f->backend.model=&f->model[0];
    f->chain.index=3; f->chain.state=2; f->chain.present=1;
    f->chain.sensor_count=0; /* deliberately NOT the model-derived count */
    f->chain.sensors=f->bank[0].s; f->chain.chip_count=77;
    memset(f->chain.statistics,0x59,sizeof(f->chain.statistics));
    f->view.backend=&f->backend; f->view.chain=&f->chain;
    f->device_id=89;
}
static int32_t initialize_cb(void *opaque,struct vn135_route_chain *c,struct vn135_temperature_sensor *s)
{
    struct fixture *f=opaque; unsigned b,i;
    CHECK(c==&f->chain); CHECK(f->calls<8);
    for(b=0;b<2;++b) for(i=0;i<4;++i) if(s==&f->bank[b].s[i]) goto found;
    CHECK(0); return -99;
found:
    f->captured=s; f->slots[f->calls]=i; f->banks[f->calls]=b; ++f->calls;
    if(f->mutation==1 && f->calls==1) {
        f->chain.sensors=f->bank[1].s; f->model[0].sensor_count=1;
        f->backend.model=&f->model[1]; f->chain.present=0; f->chain.state=3;
    }
    if(f->mutation==4 && f->calls==1) { f->chain.index=UINT32_MAX; s->index=UINT32_MAX; }
    return f->rc;
}
static void log_cb(void *opaque,uint32_t line,uint32_t level,uint32_t chain,uint32_t sensor)
{
    struct fixture *f=opaque;
    CHECK(line==1208 && level==2); CHECK(f->logs<8);
    CHECK(chain==f->chain.index+1u && sensor==f->captured->index+1u);
    f->log_states[f->logs++]=f->captured->state;
    if(f->mutation==2 && f->logs==1) { f->captured->role=2; f->captured->state=99; f->chain.sensors=f->bank[1].s; }
    if(f->mutation==3) f->captured->role=0;
}
static const struct vn135_chain_temperature_setup_ops ops={initialize_cb,log_cb};
static void save(struct fixture *f) { memcpy(f->saved,f->bank,sizeof(f->bank)); }
static void guards(const struct fixture *f)
{
    for(unsigned b=0;b<2;++b) {
        CHECK(f->bank[b].before==UINT64_C(0x1122334455667788));
        CHECK(f->bank[b].after==UINT64_C(0x8877665544332211));
    }
    CHECK(f->chain.chip_count==77);
    for(unsigned i=0;i<sizeof(f->chain.statistics);++i) CHECK(f->chain.statistics[i]==0x59);
}
static void one(uint8_t present,uint32_t state,int32_t count,uint32_t kind,
                uint8_t skip,uint32_t role,uint32_t mode,int32_t rc,int no_log)
{
    struct fixture f; init(&f); f.chain.present=present; f.chain.state=state;
    f.model[0].sensor_count=count; f.rc=rc;
    for(unsigned i=0;i<4;++i) { f.bank[0].s[i].access_kind=kind; f.bank[0].s[i].skip_initial_read=skip; f.bank[0].s[i].role=role; }
    save(&f);
    struct vn135_chain_temperature_setup_ops use=ops; if(no_log) use.log=NULL;
    unsigned reached=0;
    if(present && !(state>=3 && state<=5) && count>0 && kind!=0 && kind!=3 && !(kind==4 && !skip))
        reached=(unsigned)count;
    int terminal=reached && rc && (mode==2 || role==2);
    if(terminal) reached=1;
    CHECK(vn135_chain_temperature_setup_135(&f.view,&use,&f,mode)==(terminal?-1:0));
    CHECK(f.calls==reached && f.logs==(no_log||!rc?0:reached));
    for(unsigned i=0;i<reached;++i) { CHECK(f.slots[i]==i && f.banks[i]==0); if(rc && !no_log) CHECK(f.log_states[i]==2); }
    for(unsigned i=0;i<4;++i) if(rc && i<reached) f.saved[0].s[i].state=3;
    CHECK(memcmp(f.bank,f.saved,sizeof(f.bank))==0); guards(&f); ++cases;
}
static void mutations(void)
{
    struct fixture f;
    init(&f);f.rc=-1;f.mutation=1;save(&f);
    CHECK(vn135_chain_temperature_setup_135(&f.view,&ops,&f,0)==0);
    CHECK(f.calls==4 && f.logs==4 && f.banks[0]==0);
    for(unsigned i=1;i<4;++i) CHECK(f.banks[i]==1 && f.slots[i]==i);
    f.saved[0].s[0].state=3;for(unsigned i=1;i<4;++i)f.saved[1].s[i].state=3;
    CHECK(memcmp(f.bank,f.saved,sizeof(f.bank))==0);guards(&f);++cases;
    init(&f);f.rc=-1;f.mutation=2;
    CHECK(vn135_chain_temperature_setup_135(&f.view,&ops,&f,0)==-1);
    CHECK(f.calls==1 && f.logs==1 && f.log_states[0]==2);
    CHECK(f.bank[0].s[0].state==3 && f.bank[0].s[0].role==2 && f.bank[1].s[0].state==2);guards(&f);++cases;
    init(&f);f.rc=-1;f.mutation=3;
    for(unsigned i=0;i<4;++i)f.bank[0].s[i].role=2;
    CHECK(vn135_chain_temperature_setup_135(&f.view,&ops,&f,0)==0);
    CHECK(f.calls==4 && f.logs==4);guards(&f);++cases;
    init(&f);f.rc=9;f.mutation=4;
    CHECK(vn135_chain_temperature_setup_135(&f.view,&ops,&f,2)==-1);
    CHECK(f.calls==1 && f.logs==1);guards(&f);++cases;
    init(&f);f.rc=-3;
    for(unsigned pass=0;pass<2;++pass) {
        f.calls=f.logs=0;
        CHECK(vn135_chain_temperature_setup_135(&f.view,&ops,&f,0)==0);
        CHECK(f.calls==4 && f.logs==4);
        CHECK(f.log_states[0]==(pass?3u:2u));++cases;
    }
    init(&f);f.backend.model=NULL;f.chain.present=0;
    CHECK(vn135_chain_temperature_setup_135(&f.view,NULL,NULL,2)==0);++cases;
    for(unsigned state=3;state<=5;++state) {
        f.chain.present=1;f.chain.state=state;
        CHECK(vn135_chain_temperature_setup_135(&f.view,NULL,NULL,2)==0);++cases;
    }
    init(&f);f.model[0].sensor_count=0;f.chain.sensors=NULL;
    CHECK(vn135_chain_temperature_setup_135(&f.view,NULL,NULL,2)==0);++cases;
}
static int32_t zero_sensor(void *p,struct vn135_temperature_sensor *s) { (void)p;(void)s;return 0; }
static int32_t configure(void *p,struct vn135_temperature_sensor *s)
{ struct fixture *f=p;(void)s;++f->configurations;return f->configure_rc; }
static int32_t readreg(void *p,struct vn135_temperature_sensor *s,uint32_t r,uint8_t *out)
{ struct fixture *f=p;(void)s;CHECK(r==254);*out=f->device_id;return (int32_t)f->reads++<f->read_failures?-7:0; }
static int32_t writereg(void *p,struct vn135_temperature_sensor *s,uint32_t r,uint8_t val)
{ struct fixture *f=p;(void)s;CHECK((r==9 && val==4)||(r==17 && (val==244||val==242||val==246)));++f->writes;return f->write_rc; }
static int32_t finish(void *p,struct vn135_temperature_sensor *s)
{ struct fixture *f=p;(void)s;++f->finishes;return f->finish_rc; }
static double now(void *p) { struct fixture *f=p;return 100.0+(double)f->times++/8.0; }
static int32_t delay(void *p,uint32_t n) { struct fixture *f=p;CHECK(n==50);++f->delays;return -9; }
static void nested(void)
{
    const unsigned kinds[]={1,2,4,5}; const uint8_t ids[]={0,26,85,89,255};
    for(unsigned k=0;k<4;++k)for(unsigned id=0;id<5;++id)for(int fail=0;fail<4;++fail) {
        struct fixture f;init(&f);f.model[0].sensor_count=1;
        struct vn135_temperature_sensor *s=&f.bank[0].s[0];
        s->access_kind=kinds[k];s->remote_enabled=1;s->skip_initial_read=1;
        f.device_id=ids[id];f.read_failures=fail;
        struct vn135_temperature_ops lower={zero_sensor,zero_sensor,zero_sensor,now,configure,readreg,writereg,finish,delay,NULL};
        struct vn135_chain_sensor_initializer_binding binding={&lower,&f};
        struct vn135_chain_temperature_setup_ops use={vn135_chain_sensor_initialize_existing_135,NULL};
        int bad=kinds[k]>2 || !ids[id] || ids[id]==255 || fail==3;
        CHECK(vn135_chain_temperature_setup_135(&f.view,&use,&binding,2)==(bad?-1:0));
        CHECK(s->state==(bad?3u:1u));
        CHECK(f.reads==(kinds[k]>2?0u:(unsigned)(fail==3?3:fail+1)));
        CHECK(f.delays==(kinds[k]>2?0u:(unsigned)fail));
        CHECK(f.times==(bad?0u:2u));
        if(!bad) { CHECK(s->started_at==100 && s->sampled_at==100.125); CHECK(s->failures==7); }
        guards(&f);++cases;
    }
}
int main(void)
{
    const uint32_t kinds[]={0,1,2,3,4,5,UINT32_MAX};
    const uint32_t modes[]={0,1,2,258,UINT32_MAX};
    const uint32_t roles[]={0,1,2,UINT32_MAX};
    const int32_t returns[]={0,-7,9};
    for(unsigned k=0;k<7;++k)for(unsigned s=0;s<2;++s)for(unsigned r=0;r<4;++r)
        for(unsigned m=0;m<5;++m)for(unsigned rc=0;rc<3;++rc)
            one(1,2,4,kinds[k],s?255:0,roles[r],modes[m],returns[rc],0);
    const uint32_t states[]={0,1,2,3,4,5,6,UINT32_MAX};
    const int32_t counts[]={INT32_MIN,-1,0,1,4};
    for(unsigned p=0;p<3;++p)for(unsigned st=0;st<8;++st)for(unsigned c=0;c<5;++c)
        one(p==0?0:p==1?1:255,states[st],counts[c],1,0,0,0,-1,0);
    one(1,2,4,1,0,0,0,-1,1);
    mutations();nested();
    printf("CHAIN_TEMPERATURE_SETUP135_NATIVE_PASS scenarios=%u checks=%u\n",cases,checks);
    return 0;
}
