/* SPDX-License-Identifier: GPL-3.0-only */
/* All effects are scripts. No pthread, device, pool, filesystem or power I/O. */
#include "integration/resume_temperature_135.h"
#include "integration/backend_shutdown_135.h"
#include "integration/tests/resume_temperature_fixture_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if(!(x)){fprintf(stderr,"RT135_ASSERT line=%d %s\n",__LINE__,#x);exit(2);} } while(0)
struct fixture {
    uint32_t magic;
    const struct rt_case *p;
    struct rt_result *out;
    struct vn135_resume_state r;
    struct vn135_resume_description d;
    struct vn135_resume_chain rc[RT_NC];
    struct vn135_resume_item items[RT_NC][RT_NS];
    struct vn135_general_model model;
    struct vn135_general_monitor g;
    struct vn135_general_chain chains[RT_NC];
    struct vn135_temperature_sensor sensors[RT_NC][RT_NS];
    struct vn135_monitor_handlers h;
    struct vn135_temperature_setup_view view;
    struct vn135_shutdown_state shutdown;
    uint32_t types[RT_NS],roles[RT_NS];
    uint8_t platform;
    char old_text[16],new_text[16];
    uint32_t registered,creates,ticks;
    uintptr_t scratch;
};
static struct fixture *ctx(void *p)
{ struct fixture *f=p;CHECK(f && f->magic==0x135a12);return f; }
static void ev(struct fixture *f,uint32_t e,uint32_t a,uint32_t b,uint32_t c,uint32_t d,uint32_t v)
{
    CHECK(f->out->event_count<RT_EVENTS);
    uint32_t *row=f->out->events[f->out->event_count++];
    row[0]=e;row[1]=a;row[2]=b;row[3]=c;row[4]=d;row[5]=v;
}
static void sync_general(struct fixture *f)
{
    f->g.state=f->r.word_20;f->g.active=f->r.byte_24;f->g.started_at=f->r.double_28;
    for(unsigned c=0;c<RT_NC;++c){
        f->chains[c].thermal.state=f->rc[c].word_20;
        f->chains[c].thermal.present=f->rc[c].byte_24;
        for(unsigned s=0;s<RT_NS;++s)f->items[c][s].word_3c=(uint32_t)f->sensors[c][s].sample;
    }
}
static int32_t count(void *p)
{ struct fixture *f=ctx(p);sync_general(f);ev(f,E_COUNT,0,0,0,0,0);return f->p->count; }
static int32_t scalar(void *p,uint32_t e,uint32_t a,uint32_t b)
{ CHECK(e==0xfe668 && !a && !b);return count(p); }
static uint32_t sensor_id(struct fixture *f,struct vn135_temperature_sensor *s)
{
    for(unsigned c=0;c<RT_NC;++c)for(unsigned j=0;j<RT_NS;++j)
        if(s==&f->sensors[c][j])return c*RT_NS+j;
    CHECK(0);return 0;
}
static int bad(struct fixture *f,uint32_t id,unsigned kind)
{ return (f->p->fault_mask&(1u<<id)) && f->p->fault_kind==kind; }
static int32_t config(void *p,struct vn135_temperature_sensor *s)
{ struct fixture *f=ctx(p);uint32_t i=sensor_id(f,s);ev(f,E_CONFIG,i,0,0,0,0);return bad(f,i,1)?-7:0; }
static int32_t read_sensor(void *p,struct vn135_temperature_sensor *s,uint32_t reg,uint8_t *out)
{ struct fixture *f=ctx(p);uint32_t i=sensor_id(f,s);ev(f,E_READ,i,reg,0,0,0);*out=bad(f,i,3)?0:89;return bad(f,i,2)?-1:0; }
static int32_t write_sensor(void *p,struct vn135_temperature_sensor *s,uint32_t reg,uint8_t v)
{ struct fixture *f=ctx(p);uint32_t i=sensor_id(f,s);ev(f,E_WRITE,i,reg,v,0,0);return bad(f,i,4)?-5:0; }
static int32_t finish(void *p,struct vn135_temperature_sensor *s)
{ struct fixture *f=ctx(p);uint32_t i=sensor_id(f,s);ev(f,E_FINISH,i,0,0,0,0);return bad(f,i,5)?-6:0; }
static double now(void *p)
{ struct fixture *f=ctx(p);double v=100.0+0.125*f->ticks++;uint64_t bits;memcpy(&bits,&v,8);ev(f,E_TIME,(uint32_t)bits,(uint32_t)(bits>>32),0,0,0);return v; }
static int32_t delay(void *p,uint32_t v)
{ struct fixture *f=ctx(p);ev(f,E_STEP,0x10ef3c,v,0,0,0);return 0; }
static void log_resume(void *p,uint32_t l,uint32_t level,uint32_t a,uint32_t b)
{ struct fixture *f=ctx(p);ev(f,E_LOG,l,level,a,b,0); }
static void log_handler(void *p,uint32_t l,uint32_t level,uint32_t a,uint32_t b,const char *detail)
{ CHECK(!detail);log_resume(p,l,level,a,b); }
static void log_sensor(void *p,uint32_t l,uint32_t c,uint32_t s,uint32_t v)
{ struct fixture *f=ctx(p);ev(f,E_SENSOR_LOG,l,c,s,v,0); }
static int32_t stop_chain(void *p,struct vn135_route_chain *c,const char *reason)
{
    struct fixture *f=ctx(p);CHECK(!strcmp(reason,"Failed to init temp sensors"));
    for(unsigned i=0;i<RT_NC;++i)if(c==&f->chains[i].thermal){
        ev(f,E_STOP,i,0,0,0,0);c->state=3;f->rc[i].word_20=3;return -19;
    }
    CHECK(0);return 0;
}
static uint32_t key(void *p)
{ struct fixture *f=ctx(p);ev(f,E_STEP,0x19c,0,0,0,0);return f->p->key; }
static void reg(void *p,uint32_t k,struct vn135_general_monitor *g,uint32_t h)
{ struct fixture *f=ctx(p);CHECK(g==&f->g);ev(f,E_REGISTER,k,1,h,0,0);f->registered=1; }
static int32_t step(void *p,enum vn135_resume_step e,uint32_t a,uint32_t b,uint32_t c)
{
    struct fixture *f=ctx(p);sync_general(f);
    if(e==VN135_R_CHAIN_COUNT)return count(p);
    if(e==VN135_R_FINISH_60A2C){
        const struct vn135_monitor_handler_ops h={.call=scalar,.log=f->p->no_log?NULL:log_handler};
        return vn135_monitor_chain_decision_135(&f->h,&h,f);
    }
    /* An unbound temperature step is explicitly unsupported, never success.
     * This also makes a wrong-boundary mutant a trace/result mismatch. */
    if(e==VN135_R_CONFIG_6EC4C){ev(f,E_STEP,(uint32_t)e,a,b,c,0);return -38;}
    ev(f,E_STEP,(uint32_t)e,a,b,c,0);
    if((uint32_t)e==f->p->fail_step)return f->p->fail_rc;
    switch(e){
    case VN135_R_MODE_82D60:return (int32_t)f->p->mode;
    case VN135_R_PLATFORM_KIND:return (int32_t)f->p->platform;
    case VN135_R_POOL_CHECK:return 1;
    case VN135_R_CHECK_B86D0:case VN135_R_APPLY_4F0A0:case VN135_R_REFRESH_B9148:
    case VN135_R_TRYLOCK:case VN135_R_UNLOCK:case VN135_R_RANDOM:case VN135_R_DELAY:
    case VN135_R_PLATFORM_FE190:case VN135_R_PREPARE_106E58:case VN135_R_CHECK_66504:
    case VN135_R_CHAIN_6C61C:case VN135_R_CHAIN_6C89C:case VN135_R_TYPE4_6E31C:
    case VN135_R_CONFIG_6E734:case VN135_R_CONFIG_6F1CC:case VN135_R_CONFIG_6F550:
    case VN135_R_CONFIG_6F6F4:case VN135_R_CONFIG_6709C:case VN135_R_CONFIG_66244:
    case VN135_R_CONFIG_6F8AC:case VN135_R_CONFIG_6FAE8:case VN135_R_REPORT_F8C70:
    case VN135_R_START_644A8:case VN135_R_RECOVERY_6BB70:case VN135_R_EVENT_49C98:
    case VN135_R_STOP_5E92C:case VN135_R_CHAIN_55400:case VN135_R_CONFIG_A20A0:
    case VN135_R_FINISH_5DE64:case VN135_R_FINISH_60A2C:case VN135_R_FLAG_8291C:
    case VN135_R_SET_829E8:return 0; /* Explicit scenario effects, not device defaults. */
    default:CHECK(0);return 0;
    }
}
static unsigned slot(uint32_t off)
{ switch(off){case 0x1044:return 0;case 0x1014:return 1;case 0x101c:return 4;default:CHECK(0);return 0;} }
static int32_t create(void *p,uint32_t off,uint32_t entry,uintptr_t *out)
{
    struct fixture *f=ctx(p);unsigned i=slot(off);ev(f,E_CREATE,off,entry,0,0,0);
    int32_t rc=(++f->creates==(uint32_t)f->p->create_fail)?f->p->create_rc:0;
    if(!rc||f->p->error_write)*out=0x60000000u+off;
    if(!rc && f->p->scheduled)f->shutdown.threads[i].running=1;
    return rc;
}
static int32_t join_resume(void *p,uintptr_t h,uintptr_t *out)
{ struct fixture *f=ctx(p);ev(f,E_JOIN,(uint32_t)h,!!out,0,0,0);if(out&&f->p->join_writes)*out=f->p->join_value;return f->p->join_rc; }
static char *duplicate(void *p,const char *s)
{ struct fixture *f=ctx(p);ev(f,E_DUP,s==f->new_text?2:1,0,0,0,0);return f->new_text; }
static void release(void *p,char *s)
{ struct fixture *f=ctx(p);ev(f,E_FREE,s==f->new_text?2:1,0,0,0,0); }
static int32_t on(void *p){struct fixture *f=ctx(p);ev(f,E_ON,0,0,0,0,0);return f->p->on_rc;}
static int32_t off(void *p){struct fixture *f=ctx(p);ev(f,E_OFF,0,0,0,0,0);return f->p->off_rc;}
static int32_t voltage(void *p,uint16_t v){struct fixture *f=ctx(p);ev(f,E_VOLT,v,0,0,0,0);return f->p->voltage_rc;}
static int32_t reset(void *p,uint32_t i){struct fixture *f=ctx(p);ev(f,E_RESET,i,0,0,0,0);return -7;}
static void log_power(void *p,enum vn135_gpio_power_source source,uint32_t l,uint32_t a)
{ struct fixture *f=ctx(p);CHECK(source==VN135_GP_BASE);ev(f,E_POWER_LOG,l,a,0,0,0); }
static uint32_t shutdown_step(void *p,uint32_t e,uint32_t a)
{
    struct fixture *f=ctx(p);if(e==0x19c)return key(p);ev(f,E_STEP,e,a,0,0,0);
    switch(e){
    case 0xfdeb4:return 1;case 0xfdfbc:return f->p->platform;
    case 0x8291c:case 0x860b8:case 0xa6080:case 0x663cc:case 0x58d08:
    case 0x5a9fc:case 0x5ac80:case 0x1082b4:case 0x2f6ec:case 0xf98b8:case 0xf9840:return 0;
    default:CHECK(0);return 0;
    }
}
static int32_t lock_stop(void *p){struct fixture *f=ctx(p);ev(f,E_STEP,0x5a6684,0,0,0,0);return 0;}
static int32_t unlock_stop(void *p){struct fixture *f=ctx(p);ev(f,E_STEP,0x5a66c4,0,0,0,0);return 0;}
static uint32_t self(void *p){struct fixture *f=ctx(p);ev(f,E_SELF,0,0,0,0,0);return f->p->self_handle;}
static int32_t detach(void *p,uint32_t h){struct fixture *f=ctx(p);ev(f,E_DETACH,h,0,0,0,0);return -3;}
static int32_t cancel(void *p,uint32_t h){struct fixture *f=ctx(p);ev(f,E_CANCEL,h,0,0,0,0);return -5;}
static int32_t join_stop(void *p,uint32_t h,uint32_t *out)
{ struct fixture *f=ctx(p);ev(f,E_JOIN,h,!!out,0,0,0);if(out&&f->p->join_writes)*out=f->p->join_value;return f->p->join_rc; }
static int32_t remove_request(void *p,uint32_t scratch[2],uint32_t k)
{ struct fixture *f=ctx(p);(void)scratch;ev(f,E_REGISTER,k,0,0,0,0);f->registered=0;return 0; }
static int32_t marker(void *p,const char *path)
{ struct fixture *f=ctx(p);CHECK(!strcmp(path,"/tmp/stopped"));ev(f,E_MARK,0,0,0,0,0);return -1; }
static void log_stop(void *p,uint32_t l){log_resume(p,l,3,0,0);}
static void to_stop(struct fixture *f)
{
    f->shutdown.state=f->r.word_20;f->shutdown.mode=f->g.mode;
    f->shutdown.model_chip_selector=f->d.chip_selector;
    f->shutdown.power=f->r.power;
    f->shutdown.threads[0].handle=(uint32_t)f->r.thread_1044;
    f->shutdown.threads[1].handle=(uint32_t)f->r.thread_1014;
    f->shutdown.threads[4].handle=(uint32_t)f->r.thread_101c;
    f->shutdown.threads[9].handle=(uint32_t)f->r.thread_1050;
    f->shutdown.threads[9].running=f->r.byte_1054;
}
static void from_stop(struct fixture *f)
{
    f->r.word_20=f->shutdown.state;f->r.power=f->shutdown.power;
    f->r.thread_1044=f->shutdown.threads[0].handle;f->r.thread_1014=f->shutdown.threads[1].handle;
    f->r.thread_101c=f->shutdown.threads[4].handle;f->r.thread_1050=f->shutdown.threads[9].handle;
    f->r.byte_1054=f->shutdown.threads[9].running;
}
static void snap(struct fixture *f,unsigned phase)
{
    uint32_t *q=f->out->snapshot[phase];unsigned n=0;uint64_t bits;
#define W(x) do {CHECK(n<RT_SNAP);q[n++]=(uint32_t)(x);} while(0)
#define D(x) do {double v_=(x);memcpy(&bits,&v_,8);W(bits);W(bits>>32);} while(0)
    to_stop(f);
    W(f->r.word_20);W(f->r.byte_24);W(f->r.power.byte_ff1);W(f->r.power.word_20c);W(f->platform);D(f->r.double_28);
    W(f->r.text_fc8==NULL?0:f->r.text_fc8==f->new_text?2:1);W(f->scratch);
    W(f->shutdown.byte_fe6);W(f->shutdown.word_fe8);W(f->shutdown.word_fec);W(f->registered);
    for(unsigned i=0;i<10;++i){W(f->shutdown.threads[i].handle);W(f->shutdown.threads[i].running);}
    for(unsigned c=0;c<RT_NC;++c){W(f->rc[c].word_20);W(f->rc[c].byte_24);
        for(unsigned j=0;j<RT_NS;++j){struct vn135_temperature_sensor *s=&f->sensors[c][j];
            W(s->index);W(s->address);W(s->state);W(s->access_kind);W(s->role);W(s->device_id);W(s->remote_enabled);W(s->skip_initial_read);W(s->extended);W(s->has_previous);
            W(s->sample);W(s->corrected);W(s->local_offset);W(s->remote_offset);W(s->failures);W(s->previous_sample);W(s->previous_corrected);D(s->sampled_at);D(s->started_at);W(f->items[c][j].word_44);
        }
    }
    f->out->length[phase]=n;f->out->phase_events[phase]=f->out->event_count;
#undef W
#undef D
}
void rt135_default(struct rt_case *p)
{
    memset(p,0,sizeof(*p));p->state=5;p->selector=4;p->kind=2;p->role=2;p->sensors=1;p->count=3;
    p->fault_kind=1;p->minimum=1;p->create_rc=-11;p->scheduled=1;p->followup=1;p->repeat_stop=1;
    p->join_writes=1;p->self_handle=999;p->key=0x44;p->present_mask=7;p->chain_state=2;
}
int rt135_run(const struct rt_case *p,struct rt_result *out)
{
    CHECK(p->sensors<=RT_NS && p->count<=RT_NC);memset(out,0,sizeof(*out));
    struct fixture f;memset(&f,0,sizeof(f));f.magic=0x135a12;f.p=p;f.out=out;
    f.d=(struct vn135_resume_description){3,108,p->sensors,f.types,p->selector,0x44332211};
    f.r.description=&f.d;f.r.chains=f.rc;f.r.word_20=p->state;f.r.word_dc=12000;f.r.limit_34=15000;
    f.r.platform_byte=&f.platform;f.platform=0xa5;f.r.double_28=-99.25;
    f.r.thread_1044=0x20202020;f.r.thread_101c=0x30303030;f.r.thread_1014=0x40404040;f.r.thread_1050=0x10101010;
    f.r.byte_1054=(uint8_t)p->join_flag;f.scratch=p->join_seed;
    strcpy(f.old_text,"old");strcpy(f.new_text,"new");f.r.text_90=f.new_text;f.r.text_fc8=f.old_text;
    f.model.sensor_count=p->sensors;f.model.query_fault_87=(uint8_t)p->board_flag;
    f.g.model=&f.model;f.g.chains=f.chains;f.g.mode=p->mode;f.g.suppress_thermal=(uint8_t)p->suppress;
    f.h.general=&f.g;f.h.power=&f.r.power;f.h.minimum_chains_f8=p->minimum;f.h.partial_chains_105=(uint8_t)p->partial;
    f.view=(struct vn135_temperature_setup_view){&f.h,&f.d,f.roles};
    f.shutdown.byte_fe6=1;f.shutdown.word_fe8=77;f.shutdown.word_fec=88;f.shutdown.board_byte_4f=(uint8_t)p->board_flag;
    for(unsigned j=0;j<RT_NS;++j){f.types[j]=p->kind;f.roles[j]=p->role;}
    for(unsigned c=0;c<RT_NC;++c){
        f.rc[c]=(struct vn135_resume_chain){p->chain_state,(uint8_t)((p->present_mask>>c)&1u),f.items[c]};
        f.chains[c].thermal.index=c+10;f.chains[c].thermal.sensors=f.sensors[c];f.chains[c].thermal.sensor_count=99;
        for(unsigned j=0;j<RT_NS;++j){struct vn135_temperature_sensor *s=&f.sensors[c][j];
            s->index=j;s->address=76;s->state=0;s->access_kind=p->kind;s->role=p->role;
            s->device_id=26;s->remote_enabled=1;s->skip_initial_read=1;s->has_previous=1;
            s->sample=50;s->corrected=54;s->local_offset=4;s->remote_offset=-3;s->failures=1;
            s->previous_sample=49;s->previous_corrected=53;s->sampled_at=80;s->started_at=50;
            f.items[c][j]=(struct vn135_resume_item){50,0x87650000u+c*10+j};
        }
    }
    sync_general(&f);
    const struct vn135_monitor_handler_ops ho={.call=scalar,.log=p->no_log?NULL:log_handler};
    const struct vn135_temperature_ops to={.now=now,.configure_reading=config,.read_register=read_sensor,.write_register=write_sensor,.finish_configuration=finish,.delay_ms=delay,.log=p->no_log?NULL:log_sensor};
    const struct vn135_temperature_start_composition_ops tc={&ho,&to,stop_chain,key,reg};
    const struct vn135_resume_ops ro={step,create,join_resume,duplicate,release,now,p->no_log?NULL:log_resume};
    const struct vn135_backend_power_ops po={on,off,voltage,count,reset,p->no_log?NULL:log_power};
    out->resume_rc=vn135_resume_temperature_135(&f.r,&ro,&po,&f.view,&tc,&f,&f.scratch);
    snap(&f,0);
    if(p->followup){
        const struct vn135_shutdown_ops so={.trylock=lock_stop,.unlock=unlock_stop,.delay_ms=delay,.self=self,.detach=detach,.cancel=cancel,.join=join_stop,.step=shutdown_step,.cleanup=remove_request,.mark_stopped=marker,.log=p->no_log?NULL:log_stop};
        struct vn135_shutdown_scratch scratch={{0,0},0};
        vn135_backend_shutdown_135(&f.shutdown,&so,&po,&f,&scratch);from_stop(&f);snap(&f,1);
        if(p->repeat_stop){vn135_backend_shutdown_135(&f.shutdown,&so,&po,&f,&scratch);from_stop(&f);snap(&f,2);}
    }
    return 0;
}
#ifndef RT135_LIBRARY
int main(void)
{
    struct rt_case p;struct rt_result out;unsigned n=0;
    for(unsigned mode=0;mode<3;++mode)for(unsigned mask=0;mask<8;++mask)
    for(int fail=0;fail<4;++fail)for(unsigned follow=0;follow<2;++follow){
        rt135_default(&p);p.mode=(uint32_t[]){0,2,258}[mode];p.fault_mask=(mask&1u)|((mask&2u)<<1)|((mask&4u)<<2);
        p.create_fail=fail;p.followup=follow;CHECK(rt135_run(&p,&out)==0);
        if(mask){CHECK(out.resume_rc==-1);for(unsigned i=0;i<out.phase_events[0];++i)CHECK(out.events[i][0]!=E_CREATE);}
        else if(fail)CHECK(out.resume_rc==-1);
        else CHECK(out.resume_rc==0 && out.snapshot[0][1]==1);
        CHECK(out.snapshot[0][2]==1); /* Resume does not add power-off on failure. */
        if(follow){CHECK(out.snapshot[1][0]==6 && out.snapshot[1][2]==0);CHECK(out.phase_events[2]-out.phase_events[1]==2);CHECK(!memcmp(out.snapshot[1],out.snapshot[2],RT_SNAP*sizeof(uint32_t)));}
        ++n;
    }
    rt135_default(&p);p.off_rc=-8;CHECK(!rt135_run(&p,&out));CHECK(out.snapshot[1][0]==6 && out.snapshot[1][2]==1);++n;
    for(unsigned writes=0;writes<2;++writes)for(int join_error=-1;join_error<=0;++join_error){
        rt135_default(&p);p.join_flag=1;p.join_seed=9;p.join_writes=writes;p.join_rc=join_error;
        CHECK(!rt135_run(&p,&out));CHECK(out.resume_rc==(writes?0:-1));
        CHECK(out.snapshot[0][2]==writes && out.snapshot[0][8]==(writes?0u:9u));++n;
    }
    for(unsigned which=0;which<2;++which){
        rt135_default(&p);if(which)p.voltage_rc=-1;else p.on_rc=-1;
        CHECK(!rt135_run(&p,&out));CHECK(out.resume_rc==-1 && out.snapshot[0][2]==0);++n;
    }
    rt135_default(&p);p.kind=0;p.present_mask=0;p.no_log=1;
    CHECK(!rt135_run(&p,&out));CHECK(out.resume_rc==0 && out.snapshot[0][1]==0);++n;
    printf("RESUME_TEMPERATURE135_NATIVE_PASS scenarios=%u\n",n);return 0;
}
#endif
