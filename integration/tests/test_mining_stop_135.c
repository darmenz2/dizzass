/* Native memory/ordering and parent composition. Hardware and OS are scripted. */
#define main exit_cleanup_fixture_main
#include "test_exit_cleanup_135.c"
#undef main
#include "integration/mining_stop_135.h"
#include "integration/voltage_stop_135.h"
struct mining_children { struct fixture backend; struct vn135_shutdown_thread voltage,rescue; };

struct mining_event { uint32_t op,arg,handle; uint8_t tuning,joinable; };
struct mining_fixture {
    struct mining_children previous;
    uint64_t left;
    struct vn135_mining_stop_state mining;
    uint64_t right;
    struct mining_event trace[64];
    unsigned used,actions;
    int32_t rc;
};
static void mevent(struct mining_fixture *f,uint32_t op,uint32_t arg)
{
    struct vn135_general_monitor *g=&f->previous.backend.general;
    CHECK(f->used<64);
    f->trace[f->used++]=(struct mining_event){op,arg,f->mining.handle_104c,g->tuning,f->mining.byte_104a};
    event(&f->previous.backend,op,arg,0);
}
static void minit(struct mining_fixture *f,uint8_t flag,uint8_t joinable)
{
    struct fixture *b=&f->previous.backend;uint64_t bits=UINT64_C(0x7ff0000000000001);
    memset(f,0,sizeof(*f));init(&f->previous.backend);f->previous.voltage=(struct vn135_shutdown_thread){700,1};f->previous.rescue=(struct vn135_shutdown_thread){500,1};
    f->left=f->right=UINT64_C(0x98765432abcdef01);
    f->mining=(struct vn135_mining_stop_state){&b->handlers,701,joinable,255,255};
    b->general.tuning=flag;b->general.active=255;b->general.sampled_power=0xffffffffu;
    memcpy(&b->general.started_at,&bits,8);b->handlers.warmup_done_22c=255;
}
static void mguards(struct mining_fixture *f)
{CHECK(f->left==UINT64_C(0x98765432abcdef01)&&f->right==f->left);CHECK(f->previous.backend.before==f->previous.backend.after);}
static uint32_t mstep(void *p,uint32_t ep,uint32_t a)
{
    struct mining_fixture *f=p;CHECK(a==0);
    CHECK(ep==0xfe218||ep==0xb8e54||ep==0x65b3c);mevent(f,ep,a);
    if(ep==0x65b3c){
        if(f->actions&8u){f->previous.backend.general.tuning=17;f->mining.byte_104a=19;}
        if(f->actions&32u){f->previous.backend.s.threads[6].running=0;f->previous.rescue.running=0;}
    }
    return (uint32_t)f->rc;
}
static int32_t mdelay(void *p,uint32_t ms)
{
    struct mining_fixture *f=p;CHECK(ms==100);mevent(f,0x10ed2c,ms);
    if(f->actions&1u)f->previous.backend.general.tuning=0;
    if(f->actions&2u)f->previous.backend.general.tuning=255;
    return f->rc;
}
static int32_t mcancel(void *p,uint32_t handle)
{
    struct mining_fixture *f=p;CHECK(handle==701);mevent(f,0x5a4754,handle);
    CHECK(f->previous.backend.general.tuning!=0);
    if(f->actions&4u)f->mining.handle_104c=0x87654321u;
    return f->rc;
}
static int32_t mjoin(void *p,uint32_t handle,uint32_t *out)
{
    struct mining_fixture *f=p;CHECK(!out);mevent(f,0x5a5d2c,handle);
    CHECK(handle==((f->actions&4u)?0x87654321u:701u));
    CHECK(f->previous.backend.general.tuning!=0);
    f->previous.backend.general.tuning=254;f->mining.byte_104a=253;
    return f->rc;
}
static void mlog(void *p,uint32_t line)
{
    struct mining_fixture *f=p;struct fixture *b=&f->previous.backend;uint64_t bits;
    CHECK(line==4825);memcpy(&bits,&b->general.started_at,8);CHECK(bits==0);
    CHECK(!b->general.active&&!b->general.sampled_power&&!b->handlers.warmup_done_22c);
    CHECK(!f->mining.byte_fd0&&!f->mining.byte_fe5);mevent(f,0xfa0c4,line);
    if(f->actions&16u){b->general.active=255;b->handlers.warmup_done_22c=255;}
}
static const struct vn135_shutdown_ops mining_ops={.step=mstep,.delay_ms=mdelay,
    .cancel=mcancel,.join=mjoin,.log=mlog};
static void mdirect(uint8_t flag,uint8_t joinable,unsigned actions,int32_t rc)
{
    struct mining_fixture f;struct vn135_general_monitor expected_g;
    struct vn135_monitor_handlers expected_h;struct vn135_mining_stop_state expected_s;
    struct vn135_shutdown_state saved;unsigned n,active=(actions&2u)?1u:(actions&1u)?0u:flag;
    minit(&f,flag,joinable);f.actions=actions;f.rc=rc;
    expected_g=f.previous.backend.general;expected_h=f.previous.backend.handlers;expected_s=f.mining;
    saved=f.previous.backend.s;
    vn135_backend_stop_mining_135(&f.mining,&mining_ops,&f);mguards(&f);
    CHECK(f.used==(active?7u:5u));CHECK(f.trace[0].op==0xfe218);
    CHECK(f.trace[1].op==0xb8e54);CHECK(f.trace[2].op==0x10ed2c);
    n=3;
    if(active){CHECK(f.trace[n++].op==0x5a4754);CHECK(f.trace[n++].op==0x5a5d2c);}
    CHECK(f.trace[n].op==0x65b3c);
    CHECK(f.trace[n].tuning==0);CHECK(f.trace[n].joinable==(active?0:joinable));
    CHECK(f.trace[n+1].op==0xfa0c4);
    memset(&expected_g.started_at,0,8);expected_g.sampled_power=0;
    expected_g.active=(actions&16u)?255:0;expected_g.tuning=(actions&8u)?17:0;
    expected_h.warmup_done_22c=(actions&16u)?255:0;
    expected_s.byte_fd0=0;expected_s.byte_fe5=0;
    expected_s.handle_104c=(active&&(actions&4u))?0x87654321u:701u;
    expected_s.byte_104a=(actions&8u)?19:active?0:joinable;
    CHECK(!memcmp(&expected_g,&f.previous.backend.general,sizeof(expected_g)));
    CHECK(!memcmp(&expected_h,&f.previous.backend.handlers,sizeof(expected_h)));
    CHECK(!memcmp(&expected_s,&f.mining,sizeof(expected_s)));
    CHECK(!memcmp(&saved,&f.previous.backend.s,sizeof(saved)));
    CHECK(f.previous.rescue.running==1&&f.previous.voltage.running==1);
    ++scenarios;
}
static uint32_t parent_step(void *p,uint32_t ep,uint32_t a)
{
    struct mining_fixture *f=p;uint32_t rc=step_cb(p,ep,a);
    if(ep==0xa6080)vn135_voltage_controller_stop_135(&f->previous.voltage,&ops,f);
    if(ep==0x287a4)vn135_rescue_service_stop_135(&f->previous.rescue,&ops,f);
    if(ep==0x663cc){CHECK(a==0);vn135_backend_stop_mining_135(&f->mining,&mining_ops,f);}
    return rc;
}
static void mteardown(struct mining_fixture *f,int common)
{
    struct fixture *b=&f->previous.backend;struct vn135_shutdown_ops bound=ops;
    bound.step=parent_step;
    if(common)vn135_backend_shutdown_135(&b->s,&bound,&power,f,&b->scratch);
    else vn135_backend_before_exit_135(&b->s,&bound,&power,f,&b->scratch);
}
static void mcomposed(uint32_t state,uint8_t flag,int common,int change)
{
    struct mining_fixture f;struct fixture *b=&f.previous.backend;
    int skipped=(state==4||state==6);
    minit(&f,flag,99);f.rc=-3;f.actions=change?32u:0;b->s.state=state;
    mteardown(&f,common);mguards(&f);guards(b);
    if(skipped){CHECK(!f.used);CHECK(b->general.tuning==flag);CHECK(f.mining.byte_104a==99);}
    else{
        CHECK(f.used==(flag?7u:5u));CHECK(!b->general.tuning);
        CHECK(find(b,0xa6080)<find(b,0x663cc));CHECK(find(b,0x663cc)<find(b,0xfe218));
        CHECK(find(b,0xfe218)<find(b,0x65b3c));CHECK(!b->general.active);
        if(!common)CHECK(find(b,0x65b3c)<find(b,0x287a4));
        CHECK(b->s.state==(common?6u:4u));
        if(change){CHECK(!b->s.threads[6].running);CHECK(!f.previous.rescue.running);}
    }
    ++scenarios;
}
static void mpolicy_before(void *p)
{struct mining_fixture *f=p;++f->previous.backend.before_calls;mteardown(f,0);f->previous.backend.general.state=f->previous.backend.s.state;}
static void mpolicy_common(void *p)
{struct mining_fixture *f=p;++f->previous.backend.common_calls;mteardown(f,1);f->previous.backend.general.state=f->previous.backend.s.state;}
static void mpolicy(void)
{
    int retry,rc;const struct vn135_monitor_handler_ops hops={.call=handler_call};
    for(retry=0;retry<2;++retry)for(rc=-1;rc<=1;++rc){
        struct mining_fixture f;struct fixture *b=&f.previous.backend;
        struct vn135_stop_policy_ops bound=policy_ops;int flow;
        minit(&f,1,1);f.rc=rc;b->off_rc=rc;b->policy.retry_limit_88=retry?2:0;
        bound.before_process_exit=mpolicy_before;bound.shutdown=mpolicy_common;
        flow=vn135_test_stop_chain_composed_135(&b->policy,&bound,&hops,&f);
        CHECK(f.used==7);CHECK(!b->general.tuning&&!b->general.active);
        if(retry){CHECK(flow==VN135_STOP_PROCESS_EXIT);CHECK(b->handler_counts==1);CHECK(b->exit_calls==1);}
        else{CHECK(flow==VN135_STOP_RETURNED);CHECK(!b->exit_calls);}
        mguards(&f);++scenarios;
    }
}
int main(void)
{
    unsigned flag,j,a,i;int common,change;
    const uint32_t states[]={0,2,3,4,6,0xffffffffu};
    for(flag=0;flag<256;++flag)for(j=0;j<2;++j)mdirect((uint8_t)flag,j?255:0,0,-3);
    for(a=0;a<32;++a){mdirect(0,19,a,3);mdirect(255,19,a,-1);}
    for(i=0;i<6;++i)for(flag=0;flag<2;++flag)for(common=0;common<2;++common)for(change=0;change<2;++change)
        mcomposed(states[i],(uint8_t)flag,common,change);
    mpolicy();
    printf("MINING_STOP135_NATIVE_PASS scenarios=%lu assertions=%lu hardware=no real_threads=no\n",scenarios,assertions);
    return 0;
}
