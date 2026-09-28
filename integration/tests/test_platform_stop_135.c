/* Deterministic host effects and composition. No MMIO, pthreads or devices. */
#include "integration/platform_stop_135.h"
#include "integration/mining_stop_135.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint64_t checks, cases;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"check failed line %d: %s\n",__LINE__,#x); exit(1); } } while (0)
struct event { uint32_t op, a, b; };
struct fixture {
    uint32_t left_guard;
    uint8_t skip;
    uint32_t reg, flags, status, used;
    unsigned change_skip, change_flags;
    struct event trace[32];
    uint32_t right_guard;
    struct vn135_platform_stop_slot slot;
};
static void event(struct fixture *f, uint32_t op, uint32_t a, uint32_t b)
{
    CHECK(f->used < 32);
    f->trace[f->used++] = (struct event){op,a,b};
}
static uint32_t read_reg(void *p,uint32_t index)
{
    struct fixture *f=p;event(f,1,index,0);
    if(f->change_skip)f->skip=255;
    return f->reg;
}
static uint32_t write_reg(void *p,uint32_t index,uint32_t value)
{
    struct fixture *f=p;event(f,2,index,value);f->reg=value;
    if(f->change_flags)f->flags=UINT32_C(0x12345678);
    return f->status;
}
static uint32_t read_flags(void *p)
{
    struct fixture *f=p;event(f,3,0,0);return f->flags;
}
static uint32_t write_flags(void *p,uint32_t value)
{
    struct fixture *f=p;event(f,4,value,0);f->flags=value;return f->status;
}
static const struct vn135_xil_stop_ops ops={read_reg,write_reg,read_flags,write_flags};
static void initialize(struct fixture *f)
{
    memset(f,0,sizeof(*f));f->left_guard=0xfeed1234;f->right_guard=0xabcd1234;
}
static void guards(const struct fixture *f)
{
    CHECK(f->left_guard==0xfeed1234);CHECK(f->right_guard==0xabcd1234);
}
static void direct(uint8_t skip,uint32_t reg,uint32_t flags,uint32_t status,unsigned mutate)
{
    struct fixture f;initialize(&f);f.skip=skip;f.reg=reg;f.flags=flags;f.status=status;
    f.change_skip=mutate&1;f.change_flags=mutate&2;
    struct vn135_xil_stop_binding b={&f.skip,skip?NULL:&ops,&f};
    f.slot=(struct vn135_platform_stop_slot){vn135_platform_stop_xil_135,&b};
    vn135_platform_stop_dispatch_135(&f.slot);
    if(skip){CHECK(f.used==0);CHECK(f.reg==reg);CHECK(f.flags==flags);}
    else{
        CHECK(f.used==4);
        CHECK(f.trace[0].op==1 && f.trace[0].a==27);
        CHECK(f.trace[1].op==2 && f.trace[1].a==27);
        CHECK(f.trace[1].b==(reg & UINT32_C(0xffbfffff)));
        CHECK(f.trace[2].op==3);CHECK(f.trace[3].op==4);
        CHECK(f.reg==(reg & UINT32_C(0xffbfffff)));
        CHECK(f.flags==((f.change_flags?UINT32_C(0x12345678):flags)&UINT32_C(0xffffffbf)));
        CHECK(f.skip==(f.change_skip?255:0));
    }
    guards(&f);++cases;
}
static void callback_b(void *p){event(p,12,0,0);}
static void callback_a(void *p)
{
    struct fixture *f=p;event(f,11,0,0);f->slot.invoke=callback_b;
    vn135_platform_stop_dispatch_135(&f->slot);
}
static void reentry(void)
{
    struct fixture f;initialize(&f);f.slot=(struct vn135_platform_stop_slot){callback_a,&f};
    vn135_platform_stop_dispatch_135(&f.slot);vn135_platform_stop_dispatch_135(&f.slot);
    CHECK(f.used==3);CHECK(f.trace[0].op==11);CHECK(f.trace[1].op==12);CHECK(f.trace[2].op==12);
    guards(&f);++cases;
}
static uint32_t mining_step(void *p,uint32_t source,uint32_t arg)
{
    struct fixture *f=p;CHECK(arg==0);event(f,source,0,0);
    if(source==0xfe218)vn135_platform_stop_dispatch_135(&f->slot);
    else CHECK(source==0xb8e54 || source==0x65b3c); /* explicit unexecuted lower boundary */
    return UINT32_MAX;
}
static int32_t delay(void *p,uint32_t ms){event(p,10,ms,0);return -1;}
static int32_t cancel(void *p,uint32_t h){event(p,20,h,0);return -1;}
static int32_t join(void *p,uint32_t h,uint32_t *out){CHECK(!out);event(p,21,h,0);return -1;}
static void log_line(void *p,uint32_t line){event(p,30,line,0);}
static void composition(unsigned no_op,unsigned active,uint8_t skip)
{
    struct fixture f;initialize(&f);f.skip=skip;f.reg=UINT32_MAX;f.flags=UINT32_MAX;
    struct vn135_xil_stop_binding b={&f.skip,skip?NULL:&ops,&f};
    f.slot=(struct vn135_platform_stop_slot){no_op?vn135_platform_stop_noop_135:vn135_platform_stop_xil_135,&b};
    struct vn135_general_monitor general={0};struct vn135_monitor_handlers handlers={0};
    general.active=1;general.tuning=(uint8_t)active;general.started_at=123.25;general.sampled_power=999;
    handlers.general=&general;handlers.warmup_done_22c=1;
    struct vn135_mining_stop_state state={&handlers,123,255,1,1};
    struct vn135_shutdown_ops calls={.delay_ms=delay,.cancel=cancel,.join=join,.step=mining_step,.log=log_line};
    vn135_backend_stop_mining_135(&state,&calls,&f);
    unsigned offset=(!no_op&&!skip)?4:0;
    CHECK(f.used==5+offset+2*active);CHECK(f.trace[0].op==0xfe218);
    CHECK(f.trace[1+offset].op==0xb8e54);CHECK(f.trace[2+offset].op==10 && f.trace[2+offset].a==100);
    CHECK(f.trace[f.used-2].op==0x65b3c);CHECK(f.trace[f.used-1].op==30);
    CHECK(general.started_at==0 && !general.active && !general.sampled_power);
    CHECK(!state.byte_fd0 && !state.byte_fe5 && !handlers.warmup_done_22c);
    CHECK(state.handle_104c==123);CHECK(state.byte_104a==(active?0:255));
    guards(&f);++cases;
}
int main(void)
{
    for(unsigned skip=0;skip<256;++skip)direct((uint8_t)skip,UINT32_MAX,UINT32_MAX,UINT32_MAX,0);
    for(unsigned bit=0;bit<32;++bit)for(unsigned inv=0;inv<2;++inv)for(unsigned mutate=0;mutate<4;++mutate){
        uint32_t v=(UINT32_C(1)<<bit)^(inv?UINT32_MAX:0);direct(0,v,v,v,mutate);
    }
    const uint32_t statuses[]={0,1,UINT32_MAX,0x80000000,0x7fffffff};
    for(unsigned i=0;i<sizeof(statuses)/sizeof(statuses[0]);++i)direct(0,UINT32_MAX,UINT32_MAX,statuses[i],0);
    struct fixture f;initialize(&f);struct fixture before=f;
    vn135_platform_stop_noop_135(&f);CHECK(!memcmp(&before,&f,sizeof f));
    vn135_platform_stop_noop_135(NULL);++cases;reentry();
    for(unsigned no_op=0;no_op<2;++no_op)for(unsigned active=0;active<2;++active)
        for(unsigned skip=0;skip<2;++skip)composition(no_op,active,(uint8_t)skip);
    printf("PLATFORM_STOP135_NATIVE_PASS cases=%" PRIu64 " checks=%" PRIu64 " real_io=no\n",cases,checks);
    return 0;
}
