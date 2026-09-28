/* A-03 deterministic host-memory tests. No real mutex, threads or I/O. */
#include "integration/sensor_cleanup_binding_135.h"
#include "integration/exit_cleanup_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 3
#define M 5
#define GUARD UINT64_C(0x51a7e57a135cab1e)
static unsigned long checks, scenarios;
#define Q(x) do { ++checks; if (!(x)) { fprintf(stderr,"CLEANUP_ASSERT:%d:%s\n",__LINE__,#x); exit(1); } } while(0)
struct bank { uint64_t before; struct vn135_temperature_sensor s[M]; uint64_t after; };
struct fixture {
    struct vn135_general_monitor g; struct vn135_general_model model;
    struct vn135_general_chain chains[N]; struct bank banks[N][2];
    struct vn135_sensor_cleanup_binding binding; struct vn135_temperature_ops ops;
    unsigned calls; int32_t mutex_rc; unsigned mutate;
    struct vn135_shutdown_state shutdown; struct vn135_shutdown_scratch scratch;
    int32_t chain_count; unsigned cleanup_steps;
};
static void expected_reset(struct vn135_temperature_sensor *s)
{
    s->remote_offset=0; s->sample=0; s->corrected=0; s->state=0;
    s->previous_sample=0; s->previous_corrected=0; s->started_at=0;
    s->extended=0; s->has_previous=0;
}
static int32_t mutex_init(void *p,struct vn135_temperature_sensor *s)
{
    struct fixture *f=p; unsigned c,b,i,found=0;
    for(c=0;c<N;++c)for(b=0;b<2;++b)for(i=0;i<M;++i)found+=(s==&f->banks[c][b].s[i]);
    Q(found==1);Q(s->state!=0);
    if(f->calls++==0){
        if(f->mutate==1)f->model.sensor_count=1;
        if(f->mutate==2)f->chains[0].thermal.present=0;
        if(f->mutate==3)f->chains[0].thermal.sensors=f->banks[0][1].s;
    }
    return f->mutex_rc;
}
static void init(struct fixture *f)
{
    unsigned c,b,i;memset(f,0,sizeof(*f));f->g.model=&f->model;f->g.chains=f->chains;
    f->model.sensor_count=M;f->ops.mutex_init=mutex_init;
    f->binding=(struct vn135_sensor_cleanup_binding){&f->g,N,&f->ops,f};
    for(c=0;c<N;++c){
        struct vn135_route_chain *t=&f->chains[c].thermal;
        t->index=100+c;t->present=1;t->state=4;t->sensor_count=1;t->chip_count=17;
        t->sensors=f->banks[c][0].s;
        for(b=0;b<2;++b){f->banks[c][b].before=f->banks[c][b].after=GUARD;
            for(i=0;i<M;++i){
                struct vn135_temperature_sensor *s=&f->banks[c][b].s[i];
                s->index=50+i;s->address=72+i;s->state=i+1;s->access_kind=i;s->role=i%2;
                s->device_id=26;s->remote_enabled=1;s->skip_initial_read=1;
                s->extended=255;s->has_previous=255;s->sample=50+(int)i;s->corrected=-10-(int)i;
                s->local_offset=-30;s->remote_offset=20;s->failures=99;
                s->previous_sample=-70;s->previous_corrected=90;s->sampled_at=60.25;s->started_at=-100.5;
            }
        }
    }
}
static void guards(const struct fixture *f)
{unsigned c,b;for(c=0;c<N;++c)for(b=0;b<2;++b)Q(f->banks[c][b].before==GUARD&&f->banks[c][b].after==GUARD);}
static void direct(void)
{
    struct fixture f;struct bank want[N][2];unsigned c,i,mask,p,rc,expected;
    const int32_t counts[]={INT32_MIN,-1,0,1,3,5};const uint8_t present[]={0,1,255};
    for(c=0;c<N;++c)for(mask=0;mask<32;++mask)for(p=0;p<3;++p)for(rc=0;rc<2;++rc){
        size_t k=(c+mask+p+rc)%(sizeof(counts)/sizeof(counts[0]));
        init(&f);f.mutex_rc=rc?-22:0;f.model.sensor_count=counts[k];f.chains[c].thermal.present=present[p];
        for(i=0;i<M;++i)f.banks[c][0].s[i].state=(mask>>i)&1?UINT32_MAX:0;
        memcpy(want,f.banks,sizeof(want));expected=0;
        if(present[p])for(i=0;counts[k]>0&&i<(uint32_t)counts[k];++i)if(want[c][0].s[i].state){expected_reset(&want[c][0].s[i]);++expected;}
        Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,c)==VN135_SENSOR_CLEANUP_HANDLED);++scenarios;
        Q(f.calls==expected);Q(!memcmp(want,f.banks,sizeof(want)));guards(&f);
        Q(f.chains[c].thermal.sensor_count==1&&f.chains[c].thermal.chip_count==17&&f.chains[c].thermal.state==4);
        Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,c)==VN135_SENSOR_CLEANUP_HANDLED);++scenarios;
        Q(f.calls==expected);Q(!memcmp(want,f.banks,sizeof(want)));guards(&f);
    }
    for(i=1;i<=3;++i){
        init(&f);f.mutate=i;f.mutex_rc=-1;
        Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==1);++scenarios;Q(f.calls==M);
        if(i==1){Q(f.model.sensor_count==1);Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,1)==1);Q(f.calls==M+1);}
        if(i==2){Q(f.chains[0].thermal.present==0);Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==1);Q(f.calls==M);}
        if(i==3){Q(f.banks[0][0].s[0].state==0);Q(f.banks[0][1].s[0].state==1);
            for(c=1;c<M;++c){Q(f.banks[0][0].s[c].state==c+1);Q(f.banks[0][1].s[c].state==0);}}
        guards(&f);
    }
}
static void invalid(void)
{
    struct fixture f;init(&f);
    Q(vn135_sensor_cleanup_step_135(NULL,0,UINT32_MAX)==0);
    Q(vn135_sensor_cleanup_step_135(NULL,0x58d08,0)==-2);
    Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,N)==-2);
    Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,UINT32_MAX)==-2);
    f.binding.general=NULL;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==-2);f.binding.general=&f.g;
    f.g.model=NULL;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==-2);f.g.model=&f.model;
    f.g.chains=NULL;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==-2);f.g.chains=f.chains;
    f.binding.temperature=NULL;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==-2);
    f.chains[0].thermal.present=0;f.chains[0].thermal.sensors=NULL;f.model.sensor_count=INT32_MAX;
    Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==1);
    f.chains[0].thermal.present=1;f.model.sensor_count=0;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==1);
    f.model.sensor_count=-1;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==1);
    f.model.sensor_count=1;f.binding.temperature=&f.ops;Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==-2);
    f.chains[0].thermal.sensors=f.banks[0][0].s;f.ops.mutex_init=NULL;
    Q(vn135_sensor_cleanup_step_135(&f.binding,0x58d08,0)==-2);Q(f.calls==0);guards(&f);++scenarios;
}
/* All unrelated lower operations are explicitly scripted, not device stubs. */
static int32_t noop(void *p){(void)p;return 0;}
static int32_t delay(void *p,uint32_t x){(void)p;(void)x;return 0;}
static uint32_t self(void *p){(void)p;return 999;}
static int32_t handle(void *p,uint32_t h){(void)p;(void)h;return 0;}
static int32_t join(void *p,uint32_t h,uint32_t *o){(void)p;(void)h;if(o)*o=0;return 0;}
static int32_t text(void *p,const char *s){(void)p;Q(s!=NULL);return 0;}
static uint32_t step(void *p,uint32_t source,uint32_t index)
{
    struct fixture *f=p;
    enum vn135_sensor_cleanup_route r=vn135_sensor_cleanup_step_135(&f->binding,source,index);
    Q(r!=VN135_SENSOR_CLEANUP_INVALID);
    if(r==VN135_SENSOR_CLEANUP_HANDLED){++f->cleanup_steps;return 0;}
    return source==0xfdeb4?1u:0u;
}
static int32_t cleanup(void *p,uint32_t s[2],uint32_t x){(void)p;(void)x;s[0]=s[1]=0;return 0;}
static int32_t voltage(void *p,uint16_t x){(void)p;(void)x;return 0;}
static int32_t count(void *p){return ((struct fixture *)p)->chain_count;}
static void parent(void)
{
    const struct vn135_shutdown_ops ops={.trylock=noop,.unlock=noop,.delay_ms=delay,.self=self,.detach=handle,
        .cancel=handle,.join=join,.set_thread_name=text,.step=step,.cleanup=cleanup,.mark_stopped=text};
    const struct vn135_backend_power_ops power={.psu_on=noop,.psu_off=noop,.set_voltage=voltage,.chain_count=count,.reset_chain=handle};
    struct fixture f;unsigned common,c,n;
    for(common=0;common<2;++common)for(n=0;n<=N;++n){
        init(&f);f.chain_count=(int32_t)n;f.shutdown.state=2;f.shutdown.model_chip_selector=4;
        f.shutdown.power.byte_ff1=1;f.mutex_rc=-22;
        if(common)vn135_backend_shutdown_135(&f.shutdown,&ops,&power,&f,&f.scratch);
        else vn135_backend_before_exit_135(&f.shutdown,&ops,&power,&f,&f.scratch);
        ++scenarios;Q(f.shutdown.state==(common?6u:4u));Q(f.cleanup_steps==n);Q(f.calls==n*M);
        for(c=0;c<N;++c)Q(f.banks[c][0].s[0].state==(c<n?0u:1u));
        guards(&f);
    }
}
int main(void)
{
    direct();invalid();parent();
    printf("SENSOR_CLEANUP_BINDING135_NATIVE_PASS scenarios=%lu assertions=%lu hardware=no mutex=scripted\n",scenarios,checks);
    return 0;
}
