/* SPDX-License-Identifier: GPL-3.0-only */
/* Native composition checks. All device/OS operations are deterministic scripts. */
#include "integration/temperature_start_composition_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"TC135_ASSERT %d %s\n",__LINE__,#x);exit(1);} } while(0)
struct guarded_sensor { unsigned before; struct vn135_temperature_sensor s[4]; unsigned after; };
struct fixture {
    struct vn135_general_model model;
    struct vn135_general_monitor general;
    struct vn135_general_chain chains[3];
    struct guarded_sensor banks[3];
    struct vn135_monitor_handlers handlers;
    struct vn135_resume_description description;
    uint32_t types[4],roles[4];
    struct vn135_temperature_setup_view view;
    unsigned mask,configured,reads,writes,finishes,stops,registered,key_calls,counts,logs,times;
    double time;
};
static unsigned sensor_id(struct fixture *f,struct vn135_temperature_sensor *s)
{
    for(unsigned c=0;c<3;++c)if(s==&f->banks[c].s[0])return c;
    CHECK(0);return 0;
}
static int32_t call(void *p,uint32_t e,uint32_t a,uint32_t b)
{
    struct fixture *f=p;CHECK(e==VN135_H_CHAIN_COUNT && a==0 && b==0);++f->counts;return 3;
}
static int32_t configure(void *p,struct vn135_temperature_sensor *s)
{
    struct fixture *f=p;unsigned c=sensor_id(f,s);++f->configured;
    return (f->mask&(1u<<c))?-7:0;
}
static int32_t read_register(void *p,struct vn135_temperature_sensor *s,uint32_t r,uint8_t *out)
{
    struct fixture *f=p;(void)sensor_id(f,s);CHECK(r==254);++f->reads;*out=89;return 0;
}
static int32_t write_register(void *p,struct vn135_temperature_sensor *s,uint32_t r,uint8_t v)
{
    struct fixture *f=p;(void)sensor_id(f,s);CHECK((r==9&&v==4)||(r==17&&v==244));++f->writes;return 0;
}
static int32_t finish(void *p,struct vn135_temperature_sensor *s)
{
    struct fixture *f=p;CHECK(s->access_kind==2);(void)sensor_id(f,s);++f->finishes;return 0;
}
static double now(void *p)
{
    struct fixture *f=p;++f->times;f->time+=0.125;return f->time;
}
static int32_t stop(void *p,struct vn135_route_chain *chain,const char *reason)
{
    struct fixture *f=p;CHECK(!strcmp(reason,"Failed to init temp sensors"));
    CHECK(chain==&f->chains[0].thermal || chain==&f->chains[1].thermal || chain==&f->chains[2].thermal);
    ++f->stops;chain->state=3;return -19; /* Ignored by the source coordinator. */
}
static uint32_t key(void *p){struct fixture *f=p;++f->key_calls;return 0xfedcba98u;}
static void registration(void *p,uint32_t k,struct vn135_general_monitor *g,uint32_t h)
{
    struct fixture *f=p;CHECK(k==0xfedcba98u && g==&f->general && h==0x78aa4);++f->registered;
}
static void outer_log(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *detail)
{
    struct fixture *f=p;CHECK(detail==NULL);CHECK(line==1208 || line==1811 || line==445 || line==451);
    CHECK(level==(line==1208?2u:1u));(void)a;(void)b;++f->logs;
}
static void inner_log(void *p,uint32_t line,uint32_t chain,uint32_t sensor,uint32_t v)
{
    struct fixture *f=p;CHECK(line==688 && chain>=11 && chain<=13 && sensor==1 && v==0);++f->logs;
}
static void init(struct fixture *f,unsigned kind,unsigned role)
{
    memset(f,0,sizeof(*f));f->model.sensor_count=1;
    f->general.model=&f->model;f->general.chains=f->chains;
    f->handlers.general=&f->general;f->handlers.minimum_chains_f8=1;
    f->types[0]=kind;f->roles[0]=role;
    f->description.table_count=1;f->description.table_types=f->types;
    f->view=(struct vn135_temperature_setup_view){&f->handlers,&f->description,f->roles};
    f->time=100;
    for(unsigned c=0;c<3;++c){
        f->banks[c].before=0x12345678;f->banks[c].after=0x98765432;
        f->chains[c].thermal.index=c+10;f->chains[c].thermal.state=2;f->chains[c].thermal.present=1;
        f->chains[c].thermal.sensors=f->banks[c].s;f->chains[c].thermal.sensor_count=99;
        for(unsigned s=0;s<4;++s){
            struct vn135_temperature_sensor *t=&f->banks[c].s[s];
            t->index=s;t->access_kind=kind;t->role=role;t->remote_enabled=1;
            t->local_offset=7;t->remote_offset=-3;t->sample=51;t->corrected=54;t->sampled_at=40;t->started_at=30;
        }
    }
}
static int32_t run(struct fixture *f,int logging)
{
    struct vn135_monitor_handler_ops handlers={.call=call,.log=logging?outer_log:NULL};
    struct vn135_temperature_ops temperature={.now=now,.configure_reading=configure,
        .read_register=read_register,.write_register=write_register,.finish_configuration=finish,
        .log=logging?inner_log:NULL};
    struct vn135_temperature_start_composition_ops ops={&handlers,&temperature,stop,key,registration};
    return vn135_temperature_start_composition_135(&f->view,&ops,f);
}
static void fault_matrix(void)
{
    for(unsigned kind=1;kind<=2;++kind)for(unsigned role=0;role<=2;role+=2)
    for(unsigned mode_i=0;mode_i<3;++mode_i)for(unsigned suppress=0;suppress<2;++suppress)
    for(unsigned partial=0;partial<2;++partial)for(unsigned mask=0;mask<8;++mask)
    for(unsigned logging=0;logging<2;++logging){
        struct fixture f;init(&f,kind,role);f.mask=mask;
        unsigned mode=(unsigned[]){0,2,258}[mode_i];f.general.mode=mode;f.general.suppress_thermal=(uint8_t)suppress;f.handlers.partial_chains_105=(uint8_t)partial;
        struct guarded_sensor before[3];memcpy(before,f.banks,sizeof(before));
        unsigned failed=0;for(unsigned c=0;c<3;++c)failed+=(mask>>c)&1u;
        unsigned stopped=(!suppress && (role==2 || mode==2))?failed:0;
        int good=!(role==2 && failed==3) && !(stopped && !partial) && stopped<3;
        CHECK(run(&f,(int)logging)==(good?0:-1));
        CHECK(f.configured==3 && f.stops==stopped && f.reads==3-failed);
        CHECK(f.times==2*(3-failed));CHECK(f.registered==(kind==2) && f.key_calls==(kind==2));
        CHECK(f.finishes==(kind==2?3-failed:0));
        CHECK(f.writes==(kind==1?2:1)*(3-failed));
        for(unsigned c=0;c<3;++c){
            struct vn135_temperature_sensor *s=&f.banks[c].s[0];int bad=(int)((mask>>c)&1u);
            CHECK(s->state==(bad?3u:1u));CHECK(s->local_offset==7 && s->remote_offset==-3 && s->sample==51 && s->corrected==54);
            CHECK(f.chains[c].thermal.sensor_count==99);
            CHECK(f.banks[c].before==before[c].before && f.banks[c].after==before[c].after);
            CHECK(!memcmp(&f.banks[c].s[1],&before[c].s[1],sizeof(before[c].s)-sizeof(before[c].s[0])));
            if(bad)CHECK(s->started_at==30 && s->sampled_at==40);
            else CHECK(s->sampled_at-s->started_at==0.125);
        }
        ++scenarios;
    }
}
static void gates(void)
{
    for(unsigned kind=0;kind<=4;++kind){
        struct fixture f;init(&f,kind,2);
        for(unsigned c=0;c<3;++c)f.chains[c].thermal.present=0;
        int32_t rc=run(&f,1);
        CHECK(rc==((kind==1||kind==2)?-1:0));CHECK(f.configured==0 && f.times==0);
        CHECK(f.registered==(kind==2));++scenarios;
    }
    for(int n=-1;n<=0;++n){
        struct fixture f;init(&f,2,2);f.model.sensor_count=n;f.description.table_count=n;
        CHECK(run(&f,1)==0);CHECK(f.counts==1 && f.configured==0 && f.registered==0);++scenarios;
    }
}
int main(void)
{
    fault_matrix();gates();printf("TEMPERATURE_START_COMPOSITION135_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);return 0;
}
