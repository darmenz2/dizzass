/* Typed memory and composed teardown checks. No real OS/hardware effects.
 * Reuse the existing exit fixture unchanged; its renamed main is not run. */
#define main exit_cleanup_fixture_main
#include "test_exit_cleanup_135.c"
#undef main
#include "integration/voltage_stop_135.h"

struct voltage_event { uint32_t op,arg,handle; uint8_t flag; };
struct voltage_fixture {
    struct fixture backend; /* First: existing scripted backend callbacks. */
    uint64_t left;
    struct vn135_shutdown_thread voltage;
    uint64_t middle;
    struct vn135_shutdown_thread rescue;
    uint64_t right;
    struct voltage_event trace[24];
    unsigned used,actions;
    uint32_t self;
    int32_t rc;
};
static const struct vn135_shutdown_ops voltage_ops;
static void vevent(struct voltage_fixture *f,uint32_t op,uint32_t arg)
{
    CHECK(f->used<24);
    f->trace[f->used++]=(struct voltage_event){op,arg,f->voltage.handle,f->voltage.running};
    event(&f->backend,0xa608000u+op,arg,0);
}
static uint32_t vself(void *p)
{
    struct voltage_fixture *f=p; unsigned n;
    vevent(f,1,0); CHECK(f->voltage.running==0);
    if(f->actions&8u){
        n=f->used;
        vn135_voltage_controller_stop_135(&f->voltage,&voltage_ops,f);
        CHECK(f->used==n);
    }
    if(f->actions&1u)f->voltage.handle=f->self;
    if(f->actions&16u)f->voltage.handle=777;
    return f->self;
}
static int32_t vdetach(void *p,uint32_t h)
{
    struct voltage_fixture *f=p;vevent(f,2,h);
    if(f->actions&4u)f->voltage.running=255;
    return f->rc;
}
static int32_t vcancel(void *p,uint32_t h)
{
    struct voltage_fixture *f=p;vevent(f,3,h);
    if(f->actions&2u)f->voltage.handle=321;
    return f->rc;
}
static int32_t vjoin(void *p,uint32_t h,uint32_t *out)
{
    struct voltage_fixture *f=p;CHECK(!out);vevent(f,4,h);
    if(f->actions&4u)f->voltage.running=255;
    if(f->actions&32u){
        f->backend.s.threads[6].running=0;
        f->backend.s.threads[6].handle=1234;
        f->rescue.running=0;
    }
    return f->rc;
}
static const struct vn135_shutdown_ops voltage_ops={
    .self=vself,.detach=vdetach,.cancel=vcancel,.join=vjoin
};
static void vinit(struct voltage_fixture *f,uint8_t flag,uint32_t self)
{
    memset(f,0,sizeof(*f));init(&f->backend);
    f->left=f->middle=f->right=UINT64_C(0x51a6f00dcafebeef);
    f->voltage=(struct vn135_shutdown_thread){700,flag};
    f->rescue=(struct vn135_shutdown_thread){500,1};f->self=self;
}
static void vguards(struct voltage_fixture *f)
{
    CHECK(f->left==UINT64_C(0x51a6f00dcafebeef));
    CHECK(f->middle==f->left);CHECK(f->right==f->left);
}
static void vdirect(uint8_t flag,uint32_t self,unsigned actions,int32_t rc)
{
    struct voltage_fixture f;struct vn135_shutdown_state saved;
    uint32_t selected=(actions&16u)?777u:(actions&1u)?self:700u;unsigned n;
    vinit(&f,flag,self);f.actions=actions;f.rc=rc;saved=f.backend.s;
    vn135_voltage_controller_stop_135(&f.voltage,&voltage_ops,&f);vguards(&f);
    CHECK(!memcmp(&saved,&f.backend.s,sizeof(saved)));
    CHECK(f.rescue.handle==500&&f.rescue.running==1);
    if(!flag){CHECK(f.used==0);CHECK(f.voltage.handle==700);CHECK(!f.voltage.running);}
    else{
        CHECK(f.trace[0].op==1&&f.trace[0].flag==0);
        if(self==selected){
            CHECK(f.used==2);CHECK(f.trace[1].op==2);CHECK(f.trace[1].arg==self);
            CHECK(f.voltage.handle==selected);
        }else{
            CHECK(f.used==3);CHECK(f.trace[1].op==3);CHECK(f.trace[1].arg==selected);
            CHECK(f.trace[2].op==4);CHECK(f.trace[2].arg==((actions&2u)?321u:selected));
            CHECK(f.voltage.handle==((actions&2u)?321u:selected));
        }
        CHECK(f.voltage.running==((actions&4u)?255:0));
    }
    if(!(actions&4u)){
        n=f.used;
        vn135_voltage_controller_stop_135(&f.voltage,&voltage_ops,&f);
        CHECK(f.used==n);
    }
    ++scenarios;
}
static uint32_t vstep(void *p,uint32_t ep,uint32_t a)
{
    struct voltage_fixture *f=p;uint32_t rc=step_cb(p,ep,a);
    if(ep==0xa6080){
        CHECK(a==0);vn135_voltage_controller_stop_135(&f->voltage,&voltage_ops,f);
    }else if(ep==0x287a4){
        CHECK(a==0);vn135_rescue_service_stop_135(&f->rescue,&ops,f);
    }
    return rc;
}
static void vteardown(struct voltage_fixture *f,int common)
{
    struct vn135_shutdown_ops bound=ops;bound.step=vstep;
    if(common)vn135_backend_shutdown_135(&f->backend.s,&bound,&power,f,&f->backend.scratch);
    else vn135_backend_before_exit_135(&f->backend.s,&bound,&power,f,&f->backend.scratch);
}
static void vcomposed(uint32_t state,uint8_t flag,uint32_t self,int common,int mutate)
{
    struct voltage_fixture f;int skip=state==4||state==6;
    vinit(&f,flag,self);f.backend.s.state=state;f.rc=-3;f.actions=2u|(mutate?32u:0u);
    vteardown(&f,common);vguards(&f);guards(&f.backend);
    if(skip){
        CHECK(!f.used);CHECK(f.voltage.running==flag);CHECK(f.rescue.running==1);
    }else{
        CHECK(!f.voltage.running);CHECK(f.used==(flag?(self==700?2u:3u):0u));
        CHECK(find(&f.backend,0xa6080)<find(&f.backend,0x663cc));
        if(flag){
            CHECK(find(&f.backend,0xa6080)<find(&f.backend,0xa608001));
            CHECK(find(&f.backend,0xa608001)<find(&f.backend,0x663cc));
        }
        CHECK(f.backend.s.state==(common?6u:4u));
        CHECK(f.backend.s.threads[9].running==(common?0:1));
        if(mutate&&flag&&self!=700){
            CHECK(f.backend.s.threads[6].handle==1234);
            CHECK(!f.rescue.running);
        }else CHECK(f.rescue.running==(common?1:0));
        CHECK(f.voltage.handle==(flag&&self!=700?321u:700u));
    }
    ++scenarios;
}
static void vpolicy_before(void *p)
{
    struct voltage_fixture *f=p;++f->backend.before_calls;
    vteardown(f,0);f->backend.general.state=f->backend.s.state;
}
static void vpolicy_common(void *p)
{
    struct voltage_fixture *f=p;++f->backend.common_calls;
    vteardown(f,1);f->backend.general.state=f->backend.s.state;
}
static void vpolicy(void)
{
    int rc,repeat;const struct vn135_monitor_handler_ops hops={.call=handler_call};
    for(rc=-1;rc<=1;++rc)for(repeat=0;repeat<2;++repeat){
        struct voltage_fixture f;struct vn135_stop_policy_ops bound=policy_ops;
        int flow;vinit(&f,1,999);f.rc=rc;f.backend.off_rc=rc;
        f.backend.policy.retry_limit_88=repeat?2:0;
        bound.before_process_exit=vpolicy_before;bound.shutdown=vpolicy_common;
        flow=vn135_test_stop_chain_composed_135(&f.backend.policy,&bound,&hops,&f);
        vguards(&f);CHECK(!f.voltage.running);CHECK(f.used==3);
        if(repeat){
            CHECK(flow==VN135_STOP_PROCESS_EXIT);
            CHECK(f.backend.handler_counts==1&&f.backend.handler_stops==1);
            CHECK(f.backend.before_calls==1&&f.backend.exit_calls==1);
            CHECK(!f.rescue.running);CHECK(f.backend.general.state==4);
        }else{
            CHECK(flow==VN135_STOP_RETURNED);CHECK(!f.backend.exit_calls);
            CHECK(f.backend.common_calls>=1);CHECK(f.rescue.running==1);
        }
        ++scenarios;
    }
}
int main(void)
{
    unsigned flag,actions,i;int common,mutate;
    static const uint32_t states[]={0,2,3,4,6,0xffffffffu};
    struct vn135_shutdown_thread inactive={123,0};struct vn135_shutdown_ops no_ops={0};
    vn135_voltage_controller_stop_135(&inactive,&no_ops,NULL);
    CHECK(inactive.handle==123);++scenarios;
    for(flag=0;flag<256;++flag){vdirect((uint8_t)flag,700,0,0);vdirect((uint8_t)flag,999,0,-3);}
    for(actions=0;actions<32;++actions){vdirect(1,700,actions,-1);vdirect(1,999,actions,3);}
    for(i=0;i<sizeof(states)/sizeof(states[0]);++i)
        for(flag=0;flag<2;++flag)for(common=0;common<2;++common)for(mutate=0;mutate<2;++mutate){
            vcomposed(states[i],(uint8_t)flag,700,common,mutate);
            vcomposed(states[i],(uint8_t)flag,999,common,mutate);
        }
    vpolicy();
    printf("VOLTAGE_STOP135_NATIVE_PASS scenarios=%lu assertions=%lu real_threads=no voltage_operations=no\n",scenarios,assertions);
    return 0;
}
