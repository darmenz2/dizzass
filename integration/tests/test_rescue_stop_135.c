/* Reuse the existing offline backend fixture, without altering its tests.
 * The renamed prior main is not executed by this target. */
#define main exit_cleanup_fixture_main
#include "test_exit_cleanup_135.c"
#undef main
#include "integration/rescue_stop_135.h"

struct rescue_event { uint32_t op,argument,handle;uint8_t flag; };
struct rescue_fixture {
    struct fixture backend; /* Required first: existing backend callbacks. */
    uint64_t left;
    struct vn135_shutdown_thread rescue;
    uint64_t right;
    struct rescue_event trace[24];unsigned used,actions;
    uint32_t self;int32_t rc;
};
static const struct vn135_shutdown_ops rescue_ops;
static void rescue_event(struct rescue_fixture *f,uint32_t op,uint32_t arg)
{
    CHECK(f->used<24);
    f->trace[f->used++]=(struct rescue_event){op,arg,f->rescue.handle,f->rescue.running};
    event(&f->backend,0x287a400u+op,arg,0);
}
static uint32_t rescue_self(void *p)
{
    struct rescue_fixture *f=p;unsigned n;
    rescue_event(f,1,0);CHECK(f->rescue.running==0);
    if(f->actions&8u){
        n=f->used;vn135_rescue_service_stop_135(&f->rescue,&rescue_ops,f);CHECK(f->used==n);
    }
    if(f->actions&1u)f->rescue.handle=f->self;
    return f->self;
}
static int32_t rescue_detach(void *p,uint32_t h)
{
    struct rescue_fixture *f=p;rescue_event(f,2,h);
    if(f->actions&4u)f->rescue.running=255;
    return f->rc;
}
static int32_t rescue_cancel(void *p,uint32_t h)
{
    struct rescue_fixture *f=p;rescue_event(f,3,h);
    if(f->actions&2u)f->rescue.handle=321;
    return f->rc;
}
static int32_t rescue_join(void *p,uint32_t h,uint32_t *out)
{
    struct rescue_fixture *f=p;CHECK(!out);rescue_event(f,4,h);
    if(f->actions&4u)f->rescue.running=255;
    return f->rc;
}
static const struct vn135_shutdown_ops rescue_ops={
    .self=rescue_self,.detach=rescue_detach,.cancel=rescue_cancel,.join=rescue_join
};
static void rescue_init(struct rescue_fixture *f,uint8_t flag,uint32_t self)
{
    memset(f,0,sizeof(*f));init(&f->backend);f->left=f->right=UINT64_C(0x567812349abcdeff);
    f->rescue=(struct vn135_shutdown_thread){500,flag};f->self=self;
}
static void rescue_guards(struct rescue_fixture *f)
{ CHECK(f->left==UINT64_C(0x567812349abcdeff));CHECK(f->right==f->left); }
static void direct(uint8_t flag,uint32_t self,unsigned actions,int32_t rc)
{
    struct rescue_fixture f;uint32_t selected=(actions&1u)?self:500u;unsigned n;
    rescue_init(&f,flag,self);f.actions=actions;f.rc=rc;
    vn135_rescue_service_stop_135(&f.rescue,&rescue_ops,&f);rescue_guards(&f);
    if(!flag){CHECK(f.used==0);CHECK(f.rescue.handle==500);CHECK(f.rescue.running==0);}
    else{
        CHECK(f.trace[0].op==1&&f.trace[0].flag==0);
        if(self==selected){CHECK(f.used==2);CHECK(f.trace[1].op==2);CHECK(f.trace[1].argument==self);}
        else{
            CHECK(f.used==3);CHECK(f.trace[1].op==3);CHECK(f.trace[1].argument==selected);
            CHECK(f.trace[2].op==4);CHECK(f.trace[2].argument==((actions&2u)?321u:selected));
        }
        CHECK(f.rescue.running==((actions&4u)?255:0));
    }
    CHECK(f.backend.s.state==2);CHECK(f.backend.s.threads[0].running==1);
    if(!(actions&4u)){
        n=f.used;vn135_rescue_service_stop_135(&f.rescue,&rescue_ops,&f);CHECK(f.used==n);
    }
    ++scenarios;
}
static uint32_t rescue_step(void *p,uint32_t ep,uint32_t a)
{
    struct rescue_fixture *f=p;uint32_t rc=step_cb(p,ep,a);
    if(ep==0x287a4){CHECK(a==0);vn135_rescue_service_stop_135(&f->rescue,&rescue_ops,f);}
    return rc;
}
static void composed(uint32_t state,uint8_t flag,uint32_t self)
{
    struct rescue_fixture f;struct vn135_shutdown_ops bound=ops;int skipped;
    rescue_init(&f,flag,self);f.backend.s.state=state;bound.step=rescue_step;
    f.rc=-3;f.actions=2;skipped=state==4||state==6;
    vn135_backend_before_exit_135(&f.backend.s,&bound,&power,&f,&f.backend.scratch);
    rescue_guards(&f);guards(&f.backend);
    if(skipped){CHECK(f.used==0);CHECK(f.rescue.running==flag);}
    else{
        CHECK(f.rescue.running==0);CHECK(f.used==(flag?(self==500?2u:3u):0u));
        CHECK(find(&f.backend,0x663cc)<find(&f.backend,0x287a4));
        CHECK(find(&f.backend,0x287a4)<find(&f.backend,0xfe668));
        if(flag){CHECK(find(&f.backend,0x287a4)<find(&f.backend,0x287a401));
                 CHECK(find(&f.backend,0x287a401)<find(&f.backend,0xfe668));}
        CHECK(f.backend.s.threads[9].running==1); /* Global is not backend slot 9. */
    }
    ++scenarios;
}
int main(void)
{
    unsigned flag,actions,i;static const uint32_t states[]={0,2,3,4,6,0xffffffffu};
    struct vn135_shutdown_thread inactive={123,0};struct vn135_shutdown_ops no_ops={0};
    vn135_rescue_service_stop_135(&inactive,&no_ops,NULL);CHECK(inactive.handle==123);++scenarios;
    for(flag=0;flag<256;++flag){direct((uint8_t)flag,500,0,0);direct((uint8_t)flag,999,0,-3);}
    for(actions=0;actions<16;++actions){direct(1,500,actions,-1);direct(1,999,actions,3);}
    for(i=0;i<sizeof(states)/sizeof(states[0]);++i)
        for(flag=0;flag<2;++flag){composed(states[i],(uint8_t)flag,500);composed(states[i],(uint8_t)flag,999);}
    printf("RESCUE_STOP135_NATIVE_PASS scenarios=%lu assertions=%lu real_threads=no hardware=no\n",scenarios,assertions);
    return 0;
}
