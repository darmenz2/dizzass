/* Native memory/ordering and C-to-C stop-policy/parent composition. No threads,
 * hardware, files or process exit. Unknown lower calls fail the fixture. */
#include "integration/exit_cleanup_135.h"
#include "integration/stop_policy_135.h"
#include <assert.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long assertions, scenarios;
#define CHECK(v) do { ++assertions; if (!(v)) { \
    fprintf(stderr,"check failed line %d: %s\n",__LINE__,#v); abort(); } } while (0)
struct event { uint32_t op,a,b,state; };
struct fixture {
    uint64_t before;
    struct vn135_shutdown_state s;
    uint64_t after;
    struct { uint64_t before; int32_t readings[12]; uint64_t after; } fans;
    struct vn135_shutdown_scratch scratch;
    struct event events[300];size_t event_count;
    uint32_t self,platform,special,ready;
    int32_t off_rc,effect_rc,counts[3],attempts;
    unsigned tries,lock_failures,count_calls,self_calls,cancel_calls,join_calls,detach_calls;
    unsigned reset_calls,off_calls,marker_calls,before_calls,common_calls,exit_calls;
    unsigned handler_counts,handler_stops,write_calls;
    int mutate_self,mutate_cancel,slot,write_cleanup;
    struct vn135_general_monitor general;
    struct vn135_general_model model;
    struct vn135_general_chain chains[3];
    struct vn135_monitor_handlers handlers;
    struct vn135_stop_policy policy;
    const char *top;
};
static struct fixture *F(void *p) { return p; }
static void event(struct fixture *f,uint32_t op,uint32_t a,uint32_t b)
{
    CHECK(f->event_count<300);
    f->events[f->event_count++]=(struct event){op,a,b,f->s.state};
}
static int32_t lock_cb(void *p)
{ struct fixture *f=F(p);event(f,0x5a6684,0,0);return f->tries++<f->lock_failures?16:0; }
static int32_t unlock_cb(void *p)
{ struct fixture *f=F(p);event(f,0x5a66c4,0,0);return f->effect_rc; }
static int32_t delay_cb(void *p,uint32_t ms)
{ struct fixture *f=F(p);CHECK(ms==100);event(f,0x10ef3c,ms,0);return f->effect_rc; }
static uint32_t self_cb(void *p)
{
    struct fixture *f=F(p);++f->self_calls;event(f,0x5a6b20,0,0);
    if(f->slot>=0)CHECK(f->s.threads[f->slot].running==0);
    if(f->mutate_self)f->s.threads[f->slot].handle=f->self;
    return f->self;
}
static int32_t detach_cb(void *p,uint32_t h)
{ struct fixture *f=F(p);CHECK(h==f->self);++f->detach_calls;event(f,0x5a5bb0,h,0);return f->effect_rc; }
static int32_t cancel_cb(void *p,uint32_t h)
{
    struct fixture *f=F(p);CHECK(h!=f->self);++f->cancel_calls;event(f,0x5a4754,h,0);
    if(f->mutate_cancel)f->s.threads[f->slot].handle=0x87654321u;
    return f->effect_rc;
}
static int32_t join_cb(void *p,uint32_t h,uint32_t *result)
{
    struct fixture *f=F(p);++f->join_calls;event(f,0x5a5d2c,h,result?1:0);
    if(f->mutate_cancel)CHECK(h==0x87654321u);
    if(result)*result=0xcafebabe;
    return f->effect_rc;
}
static int32_t name_cb(void *p,const char *s)
{ (void)p;(void)s;CHECK(0);return -1; }
static int32_t mark_cb(void *p,const char *s)
{
    struct fixture *f=F(p);++f->marker_calls;
    CHECK(!strcmp(s,f->s.persistent_marker?"/config/stopped":"/tmp/stopped"));
    event(f,0x10ee90,0,0);return f->effect_rc;
}
static void log_cb(void *p,uint32_t line)
{ CHECK(line==6420||line==6504);event(F(p),0xfa0c4,line,0); }
static uint32_t step_cb(void *p,uint32_t ep,uint32_t a)
{
    struct fixture *f=F(p);event(f,ep,a,0);
    switch(ep){
    case 0xfdeb4:CHECK(a==0);return f->ready;
    case 0x8291c:CHECK(a==0);return f->special;
    case 0xfdfbc:CHECK(a==0);return f->platform;
    case 0x19c:CHECK(a==0);return 0xdecaf;
    case 0xf98b8:CHECK(a==1||a==2);break;
    case 0xf9840:CHECK(a==0);break;
    case 0x58d08:case 0x5a9fc:case 0x5ac80:CHECK(a<6);break;
    case 0x860b8:case 0xa6080:case 0x663cc:case 0x287a4:
    case 0x1082b4:case 0x2f6ec:CHECK(a==0);break;
    default:CHECK(0);
    }
    return (uint32_t)f->effect_rc;
}
static int32_t cleanup_cb(void *p,uint32_t scratch[2],uint32_t v)
{
    struct fixture *f=F(p);CHECK(scratch==f->scratch.cleanup);CHECK(v==0xdecaf);
    event(f,0x108b40,v,0);
    if(f->write_cleanup){scratch[0]=123;scratch[1]=456;}
    return f->effect_rc;
}
static int32_t unused(void *p){(void)p;CHECK(0);return -1;}
static int32_t unused_voltage(void *p,uint16_t v){(void)p;(void)v;CHECK(0);return -1;}
static int32_t off_cb(void *p)
{struct fixture *f=F(p);++f->off_calls;event(f,0x102b04,0,0);return f->off_rc;}
static int32_t count_cb(void *p)
{
    struct fixture *f=F(p);unsigned n=f->count_calls++;CHECK(n<3);
    event(f,0xfe668,n,0);return f->counts[n];
}
static int32_t reset_cb(void *p,uint32_t i)
{struct fixture *f=F(p);CHECK(i<6);++f->reset_calls;event(f,0x55370,i,0);return f->effect_rc;}
static void power_log(void *p,enum vn135_gpio_power_source src,uint32_t line,uint32_t a)
{CHECK(src==VN135_GP_BASE);CHECK(line==5019||line==5022);CHECK(!a);event(F(p),0xfa0c4,line,a);}
static const struct vn135_shutdown_ops ops={lock_cb,unlock_cb,delay_cb,self_cb,detach_cb,
    cancel_cb,join_cb,name_cb,step_cb,cleanup_cb,mark_cb,log_cb};
static const struct vn135_backend_power_ops power={unused,off_cb,unused_voltage,count_cb,reset_cb,power_log};
static void init(struct fixture *f)
{
    unsigned i;memset(f,0,sizeof(*f));f->before=f->after=UINT64_C(0xd1a6f10a0b1ec7ed);
    f->fans.before=f->fans.after=f->before;f->slot=-1;
    f->s.state=2;f->s.model_chip_selector=4;f->s.persistent_marker=1;
    f->s.board_byte_4f=1;f->s.byte_fe6=255;f->s.word_fe8=77;f->s.word_fec=88;
    f->s.power=(struct vn135_backend_power_state){1,13500};
    f->s.fan_count=4;f->s.fan_readings=f->fans.readings;
    for(i=0;i<12;++i)f->fans.readings[i]=(int32_t)i*37-111;
    for(i=0;i<10;++i)f->s.threads[i]=(struct vn135_shutdown_thread){100+i,1};
    f->scratch=(struct vn135_shutdown_scratch){{0x12345678,0xaabbccdd},0xdeadbeef};
    f->self=999;f->ready=1;f->counts[0]=3;f->counts[1]=3;f->counts[2]=3;
    f->write_cleanup=1;
    f->general.model=&f->model;f->general.chains=f->chains;
    f->general.state=2;f->general.running=1;f->model.query_fault_87=1;
    f->handlers.general=&f->general;f->handlers.power=&f->s.power;f->handlers.minimum_chains_f8=1;
    f->top="disabled";
    f->policy=(struct vn135_stop_policy){.handlers=&f->handlers,.top_preset_90=&f->top,.retry_limit_88=2};
    for(i=0;i<3;++i){f->chains[i].thermal.state=3;f->chains[i].thermal.present=1;}
}
static void guards(struct fixture *f)
{
    CHECK(f->before==UINT64_C(0xd1a6f10a0b1ec7ed));CHECK(f->after==f->before);
    CHECK(f->fans.before==f->before);CHECK(f->fans.after==f->before);
    CHECK(f->event_count>0);CHECK(f->events[f->event_count-1].op==0x5a66c4);
}
static size_t find(struct fixture *f,uint32_t op)
{size_t i;for(i=0;i<f->event_count;++i)if(f->events[i].op==op)return i;return f->event_count;}
static void direct_tests(void)
{
    struct fixture f;unsigned mask,i,n,slot,mode,board;int self_mode,err;
    for(mask=0;mask<1024;++mask){
        init(&f);n=0;
        for(i=0;i<10;++i){f.s.threads[i].running=(mask>>i)&1;if(i<9)n+=f.s.threads[i].running;}
        vn135_backend_before_exit_135(&f.s,&ops,&power,&f,&f.scratch);++scenarios;
        guards(&f);CHECK(f.s.state==4);CHECK(f.marker_calls==0);
        CHECK(f.self_calls==n&&f.cancel_calls==n&&f.join_calls==n&&f.detach_calls==0);
        for(i=0;i<9;++i)CHECK(f.s.threads[i].running==0);
        CHECK(f.s.threads[9].running==((mask>>9)&1));CHECK(f.s.threads[9].handle==109);
        CHECK(f.s.power.byte_ff1==0&&f.s.power.word_20c==0);CHECK(f.reset_calls==3);
        CHECK(f.s.byte_fe6==0&&f.s.word_fe8==0&&f.s.word_fec==0);
        CHECK(find(&f,0xa6080)<find(&f,0x663cc));CHECK(find(&f,0x663cc)<find(&f,0x287a4));
        CHECK(find(&f,0x287a4)<find(&f,0x58d08));CHECK(find(&f,0x58d08)<find(&f,0x19c));
        CHECK(find(&f,0x19c)<find(&f,0x108b40));CHECK(find(&f,0x108b40)<find(&f,0x5a9fc));
        CHECK(find(&f,0x5a9fc)<find(&f,0x102b04));CHECK(find(&f,0x102b04)<find(&f,0xf98b8));
        CHECK(f.events[find(&f,0x8291c)].state==4);CHECK(f.events[find(&f,0xf98b8)].a==2);
        CHECK(f.scratch.cleanup[0]==123&&f.scratch.cleanup[1]==456);CHECK(f.scratch.join_result==0xdeadbeef);
        for(i=0;i<12;++i)CHECK(f.fans.readings[i]==(i<4?0:(int32_t)i*37-111));
    }
    for(slot=0;slot<9;++slot)for(self_mode=0;self_mode<3;++self_mode)for(err=-1;err<=1;++err){
        init(&f);for(i=0;i<10;++i)f.s.threads[i].running=0;
        f.slot=(int)slot;f.s.threads[slot].running=255;f.effect_rc=err;
        f.self=self_mode==1?100+slot:999;f.mutate_self=self_mode==2;f.mutate_cancel=self_mode==0;
        vn135_backend_before_exit_135(&f.s,&ops,&power,&f,&f.scratch);++scenarios;guards(&f);
        CHECK(f.self_calls==1);CHECK(f.cancel_calls==(self_mode==0));CHECK(f.join_calls==(self_mode==0));
        CHECK(f.detach_calls==(self_mode!=0));CHECK(f.scratch.join_result==0xdeadbeef);
    }
    for(mode=0;mode<4;++mode)for(board=0;board<2;++board)for(err=-1;err<=1;++err){
        init(&f);f.s.mode=mode;f.s.board_byte_4f=(uint8_t)board;f.off_rc=err;
        f.write_cleanup=0;f.counts[0]=1;f.counts[1]=2;f.counts[2]=4;
        vn135_backend_before_exit_135(&f.s,&ops,&power,&f,&f.scratch);++scenarios;guards(&f);
        CHECK(f.s.state==4&&f.marker_calls==0);CHECK(f.count_calls==(board?3:2));
        CHECK(f.s.byte_fe6==(board?0:255));CHECK(f.s.word_fe8==(board?0:77));CHECK(f.s.word_fec==(board?0:88));
        CHECK(f.reset_calls==(err?0:board?4:2));CHECK(f.s.power.byte_ff1==(err?1:0));
        CHECK(f.s.power.word_20c==(err?13500:0));CHECK(f.events[find(&f,0xf98b8)].a==2);
        CHECK(f.scratch.cleanup[0]==0x12345678&&f.scratch.cleanup[1]==0xaabbccdd);
        for(i=0;i<12;++i)CHECK(f.fans.readings[i]==((i<4&&mode!=2)?0:(int32_t)i*37-111));
    }
    for(i=0;i<8;++i){
        uint32_t initial=i;init(&f);f.s.state=initial;f.ready=0;f.lock_failures=2;
        vn135_backend_before_exit_135(&f.s,&ops,&power,&f,&f.scratch);++scenarios;guards(&f);
        CHECK(f.tries==3);CHECK(f.marker_calls==0);
        CHECK(f.s.state==((initial==0||initial==4||initial==6)?initial:4));
        CHECK(f.off_calls==((initial==0||initial==4||initial==6)?0:1));
    }
    init(&f);f.s.model_chip_selector=6;f.platform=1;f.s.fan_readings=NULL;
    vn135_backend_before_exit_135(&f.s,&ops,&power,&f,&f.scratch);++scenarios;guards(&f);
    CHECK(f.s.threads[0].running==1&&f.s.threads[1].running==1);CHECK(f.self_calls==7);
}
static uint32_t policy_event(void *p){event(F(p),0x49e94,2007,0);return 2007;}
static void *counter_open(void *p,const char *path,const char *mode)
{CHECK(!strcmp(path,"/tmp/restart_count"));event(F(p),0x59e5b0,0,0);return !strcmp(mode,"rb")?(void *)1:(void *)2;}
static int32_t counter_scan(void *p,void *s,const char *fmt,int32_t *out)
{CHECK(s==(void *)1);CHECK(!strcmp(fmt,"%d"));*out=F(p)->attempts;return 1;}
static int32_t counter_print(void *p,void *s,const char *fmt,int32_t v)
{CHECK(s==(void *)2);CHECK(!strcmp(fmt,"%d"));++F(p)->write_calls;F(p)->attempts=v;return 1;}
static int32_t counter_close(void *p,void *s){(void)p;CHECK(s==(void *)1||s==(void *)2);return 0;}
static int32_t describe(void *p,char *out,size_t n)
{(void)p;CHECK(n==512);memcpy(out,"event",6);return 0;}
static void policy_before(void *p)
{
    struct fixture *f=F(p);++f->before_calls;
    vn135_backend_before_exit_135(&f->s,&ops,&power,f,&f->scratch);
    f->general.state=f->s.state;
}
static void policy_common(void *p)
{
    struct fixture *f=F(p);++f->common_calls;
    vn135_backend_shutdown_135(&f->s,&ops,&power,f,&f->scratch);
    f->general.state=f->s.state;
}
static void policy_exit(void *p,uint32_t status)
{struct fixture *f=F(p);CHECK(status==0);CHECK(f->before_calls==1);++f->exit_calls;}
static const struct vn135_restart_count_ops counter={counter_open,counter_scan,counter_print,counter_close};
static const struct vn135_stop_policy_ops policy_ops={.event_code=policy_event,.describe_event=describe,
    .counter=&counter,.before_process_exit=policy_before,.request_process_exit=policy_exit,.shutdown=policy_common};
static int32_t handler_call(void *p,uint32_t ep,uint32_t a,uint32_t b)
{
    struct fixture *f=F(p);CHECK(b==0);
    if(ep==VN135_H_CHAIN_COUNT){CHECK(a==0);++f->handler_counts;return 3;}
    CHECK(ep==VN135_H_EVENT&&a==2007);++f->handler_stops;return 0;
}
int vn135_test_stop_chain_composed_135(struct vn135_stop_policy *,const struct vn135_stop_policy_ops *,
    const struct vn135_monitor_handler_ops *,void *);
static void composed_tests(void)
{
    struct fixture f;int off;enum vn135_stop_flow flow;
    const struct vn135_monitor_handler_ops hops={.call=handler_call};
    for(off=-1;off<=1;++off){
        init(&f);f.off_rc=off;flow=vn135_stop_policy_135(&f.policy,&policy_ops,&f);++scenarios;
        CHECK(flow==VN135_STOP_PROCESS_EXIT);CHECK(f.before_calls==1&&f.common_calls==0&&f.exit_calls==1);
        CHECK(f.attempts==1&&f.write_calls==1);CHECK(f.marker_calls==0&&f.s.state==4);
        CHECK(f.s.power.byte_ff1==(off?1:0));CHECK(f.s.threads[9].running==1);
        init(&f);f.off_rc=off;
        CHECK(vn135_test_stop_chain_composed_135(&f.policy,&policy_ops,&hops,&f)==VN135_STOP_PROCESS_EXIT);++scenarios;
        CHECK(f.handler_counts==1&&f.handler_stops==1);CHECK(f.before_calls==1&&f.exit_calls==1);
        CHECK(f.general.state==4);CHECK(f.marker_calls==0);
        init(&f);f.off_rc=off;f.policy.retry_limit_88=0;
        flow=vn135_stop_policy_135(&f.policy,&policy_ops,&f);++scenarios;
        CHECK(flow==VN135_STOP_RETURNED);CHECK(f.before_calls==0&&f.common_calls==1&&f.exit_calls==0);
        CHECK(f.s.state==6&&f.marker_calls==1);CHECK(f.s.threads[9].running==0);
    }
}
int main(void)
{
    direct_tests();composed_tests();
    printf("EXIT_CLEANUP135_NATIVE_PASS scenarios=%lu assertions=%lu hardware=no threads=scripted process_exit=no\n",scenarios,assertions);
    return 0;
}
