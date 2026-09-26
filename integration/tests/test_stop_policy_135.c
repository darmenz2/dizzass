/* Bounded native tests: no filesystem, process exit, hardware or real threads. */
#include "integration/stop_policy_135.h"
#include "integration/backend_shutdown_135.h"
#include <inttypes.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

static uint64_t assertions, scenarios;
#define CHECK(x) do { ++assertions; if (!(x)) { fprintf(stderr,"line %d: %s\n",__LINE__,#x); exit(1); } } while (0)
struct test {
    uint64_t guard;
    struct vn135_stop_policy state;
    struct vn135_monitor_handlers handlers;
    struct vn135_general_monitor general;
    struct vn135_general_model model;
    struct vn135_general_history history;
    struct vn135_general_chain chains[1];
    struct vn135_general_scratch scratch;
    struct vn135_backend_power_state power;
    struct vn135_handler_profile profiles[2];
    struct vn135_shutdown_state shutdown;
    struct vn135_shutdown_scratch shutdown_scratch;
    const char *top;
    int32_t count, attempts, printed, limit_snapshot, probe_rc, io_rc, psu_rc;
    int32_t *scan_out;
    uint32_t event;
    unsigned read_open, write_open, fill_scan, read_live, write_live;
    unsigned reads, writes, scans, prints, closes, describes, probes, before, exits;
    unsigned stops, events, partial, mutate_limit, mutate_event, mutate_label;
    unsigned actions, retunes, logs[2200], use_shutdown, psu_offs, resets;
    unsigned locks, unlocks, delays, thread_requests, markers, lookup_null, warmup_loops;
    double rate;
    uint64_t tail;
    jmp_buf exit_edge;
};
static void *counter_open(void *p,const char *path,const char *mode)
{
    struct test *t=p;CHECK(!strcmp(path,"/tmp/restart_count"));
    if(!strcmp(mode,"rb")){++t->reads;CHECK(!t->read_live);if(t->read_open){t->read_live=1;return &t->read_live;}}
    else{CHECK(!strcmp(mode,"w"));++t->writes;CHECK(!t->write_live);if(t->write_open){t->write_live=1;return &t->write_live;}}
    return NULL;
}
static int32_t counter_scan(void *p,void *stream,const char *format,int32_t *out)
{
    struct test *t=p;CHECK(stream==&t->read_live&&t->read_live);CHECK(!strcmp(format,"%d"));
    CHECK(*out==0);++t->scans;t->scan_out=out;if(t->fill_scan)*out=t->attempts;return t->io_rc;
}
static int32_t counter_print(void *p,void *stream,const char *format,int32_t value)
{
    struct test *t=p;CHECK(stream==&t->write_live&&t->write_live);CHECK(!strcmp(format,"%d"));
    ++t->prints;t->printed=value;return t->io_rc;
}
static int32_t counter_close(void *p,void *stream)
{
    struct test *t=p;++t->closes;
    if(stream==&t->read_live){CHECK(t->read_live);t->read_live=0;t->scan_out=NULL;}
    else{CHECK(stream==&t->write_live&&t->write_live);t->write_live=0;}
    return t->io_rc;
}
static uint32_t event_code(void *p){return ((struct test*)p)->event;}
static struct vn135_handler_profile *profile(void *p,uint32_t ep,const char *key)
{
    struct test *t=p;if(ep==0x82ee8){CHECK(key==t->state.text_3c);return t->lookup_null?NULL:&t->profiles[0];}
    CHECK(ep==0x82d68&&key==NULL);return t->lookup_null?NULL:&t->profiles[1];
}
static int32_t profile_action(void *p,uint32_t ep,const char *key)
{
    struct test *t=p;
    if(ep==0x4dedc){CHECK(!strcmp(key,t->profiles[0].key));++t->actions;}
    else{CHECK(ep==0x94090);CHECK(!strcmp(key,t->profiles[1].key));++t->retunes;}
    return -7; /* Original policy does not branch on this result. */
}
static int32_t describe(void *p,char *out,size_t n)
{
    struct test *t=p;CHECK(n==512);
    if(!t->describes)for(size_t i=0;i<n;++i)CHECK(out[i]==0);
    else CHECK(!strcmp(out,"initial-event"));
    if(t->describes&&t->partial)out[0]='X';else memcpy(out,"initial-event",14);
    if(t->mutate_limit)t->state.retry_limit_88=-99;
    if(t->mutate_event)t->event=2006;
    ++t->describes;return -8;
}
static int32_t probe(void *p,const char *key,uint32_t out[5])
{
    struct test *t=p;CHECK(!strcmp(key,t->profiles[1].key));++t->probes;
    for(unsigned i=0;i<5;++i){CHECK(out[i]==0);out[i]=UINT32_MAX-i;}
    if(t->mutate_event)t->event=2006;
    if(t->mutate_label)t->profiles[1].label="after probe";
    return t->probe_rc;
}
static void before_exit(void *p){struct test *t=p;++t->before;CHECK(t->exits+1==t->before);}
static void exit_request(void *p,uint32_t status)
{struct test *t=p;CHECK(status==0);CHECK(t->before==t->exits+1);++t->exits;}
static void log_stop(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *detail)
{
    struct test *t=p;CHECK(line<2200);++t->logs[line];CHECK(detail!=NULL);
    switch(line){
    case 2113:CHECK(level==2&&a==0&&b==0);CHECK(!strcmp(detail,"initial-event"));break;
    case 2114:CHECK(level==3&&a==0&&b==0);CHECK(detail==t->profiles[0].label);break;
    case 2123:
        CHECK(level==3);CHECK(b==(uint32_t)t->state.retry_limit_88);
        CHECK(a==(uint32_t)((t->read_open&&t->fill_scan)?t->attempts:0)+1u);
        CHECK(!strcmp(detail,(t->partial&&t->actions)?"Xnitial-event":"initial-event"));break;
    case 2139:
        CHECK(level==1&&a==0&&b==0);CHECK(detail==t->profiles[1].label);
        if(t->mutate_label)t->profiles[1].key="changed-after-log";
        break;
    default:CHECK(!"unexpected log");
    }
}
static int32_t chain_count(void *p){return ((struct test*)p)->count;}
static int32_t psu_off(void *p){struct test *t=p;++t->psu_offs;return t->psu_rc;}
static int32_t reset_chain(void *p,uint32_t i)
{struct test *t=p;CHECK(i<(uint32_t)t->count);++t->resets;return -3;}
static const struct vn135_backend_power_ops power_ops={.psu_off=psu_off,.chain_count=chain_count,.reset_chain=reset_chain};
static int32_t lock(void *p){++((struct test*)p)->locks;return 0;}
static int32_t unlock(void *p){++((struct test*)p)->unlocks;return -1;}
static int32_t delay(void *p,uint32_t ms){++((struct test*)p)->delays;CHECK(ms==100);return -2;}
static uint32_t self(void *p){(void)p;return 7;}
static int32_t detach(void *p,uint32_t handle){CHECK(handle==7);++((struct test*)p)->thread_requests;return -4;}
static uint32_t shutdown_step(void *p,uint32_t ep,uint32_t a)
{(void)p;(void)a;CHECK(ep!=0);return 0; /* Explicit scripted lower effects. */}
static int32_t cleanup(void *p,uint32_t out[2],uint32_t value)
{(void)p;CHECK(value==0);out[0]=11;out[1]=22;return -1;}
static int32_t marker(void *p,const char *path)
{struct test*t=p;CHECK(!strcmp(path,"/tmp/stopped"));++t->markers;return -1;}
static const struct vn135_shutdown_ops shutdown_ops={.trylock=lock,.unlock=unlock,.delay_ms=delay,.self=self,.detach=detach,.step=shutdown_step,.cleanup=cleanup,.mark_stopped=marker};
static void shutdown_call(void *p)
{
    struct test *t=p;++t->stops;
    if(t->use_shutdown){
        /* Explicit test adapter binds source state/running/power to shared views. */
        t->shutdown.state=t->general.state;t->shutdown.power=t->power;
        t->shutdown.threads[6]=(struct vn135_shutdown_thread){7,t->general.running};
        vn135_backend_shutdown_135(&t->shutdown,&shutdown_ops,&power_ops,t,&t->shutdown_scratch);
        t->general.state=t->shutdown.state;t->general.running=t->shutdown.threads[6].running;t->power=t->shutdown.power;
    }
}
static const struct vn135_restart_count_ops counter_ops={counter_open,counter_scan,counter_print,counter_close};
static const struct vn135_stop_policy_ops stop_ops={event_code,profile,profile_action,describe,probe,&counter_ops,before_exit,exit_request,shutdown_call,log_stop};
static int32_t handler_call(void *p,uint32_t ep,uint32_t a,uint32_t b)
{
    struct test *t=p;(void)b;
    if(ep==VN135_H_CHAIN_COUNT)return t->count;
    if(ep==VN135_H_EVENT){CHECK(a==2007);++t->events;t->event=a;return -1;}
    if(ep==VN135_H_STOP){
        if(vn135_stop_policy_135(&t->state,&stop_ops,t)==VN135_STOP_PROCESS_EXIT)longjmp(t->exit_edge,1);
        return 0;
    }
    CHECK(!"unexpected handler operation");return 0;
}
static const struct vn135_monitor_handler_ops handler_ops={.call=handler_call};
static int32_t general_call(void *p,uint32_t ep,uint32_t a,uint32_t b)
{
    struct test *t=p;int32_t result=0;
    if(ep==0x60730&&vn135_monitor_handler_dispatch_135(&t->handlers,&handler_ops,t,ep,&result))return result;
    switch(ep){
    case VN135_G_CHAIN_COUNT:return t->count;
    case VN135_G_PLATFORM:return 4;
    case VN135_G_DELAY:CHECK(a==1000&&b==0);t->general.running=0;++t->warmup_loops;return -1;
    case VN135_G_POOL_FLAG:return 0;
    case VN135_G_UPDATE:case VN135_G_MAINTAIN:case VN135_G_TUNE_MAINTAIN:case VN135_G_STATE_MAINTAIN:
    case VN135_G_CANCEL_TYPE:case VN135_G_NAME:case VN135_G_EXIT:return -1;
    default:fprintf(stderr,"general ep=%x\n",ep);CHECK(!"unexpected operation after terminal stop");return -1;
    }
}
static double now(void *p){(void)p;return 10;}
static const struct vn135_general_ops general_ops={.call=general_call,.now=now};
static enum vn135_stop_flow parent(struct test *t,unsigned general)
{
    if(setjmp(t->exit_edge))return VN135_STOP_PROCESS_EXIT;
    if(general)vn135_general_monitor_135(&t->general,&general_ops,t,&t->scratch);
    else vn135_monitor_check_chains_135(&t->handlers,&handler_ops,t);
    return VN135_STOP_RETURNED;
}
static void init(struct test*t)
{
    memset(t,0,sizeof(*t));t->guard=UINT64_C(0x5e92c5cea85fc54);t->tail=~t->guard;
    t->top="200";t->count=1;t->event=2008;t->read_open=t->write_open=t->fill_scan=1;t->io_rc=-1;
    t->profiles[0]=(struct vn135_handler_profile){"300","Higher"};t->profiles[1]=(struct vn135_handler_profile){"200","Current"};
    t->state=(struct vn135_stop_policy){.handlers=&t->handlers,.top_preset_90=&t->top,.text_3c="300",.word_30=1,.retry_limit_88=2,.raise_failed_c8=1,.retune_104=1};
    t->power=(struct vn135_backend_power_state){1,13000};t->handlers=(struct vn135_monitor_handlers){.general=&t->general,.power=&t->power,.minimum_enabled_b0=1,.minimum_chains_f8=1};
    t->general=(struct vn135_general_monitor){.model=&t->model,.chains=t->chains,.history=&t->history,.global_rate=&t->rate,.state=2,.running=1};
    t->chains[0].thermal.state=3;t->chains[0].thermal.present=1;
}
static void finish(struct test*t)
{
    ++scenarios;CHECK(t->guard==UINT64_C(0x5e92c5cea85fc54)&&t->tail==~t->guard);
    CHECK(!t->read_live&&!t->write_live&&!t->scan_out);CHECK(t->exits==t->before);
    CHECK(t->locks==t->unlocks);
}
int main(void)
{
    static const int32_t values[]={INT_MIN,-1,0,1,2,3,INT_MAX};
    struct test t;
    for(size_t i=0;i<7;++i)for(size_t j=0;j<7;++j)for(unsigned tune=0;tune<2;++tune)for(unsigned event=2007;event<=2008;++event)for(unsigned disabled=0;disabled<2;++disabled){
        init(&t);t.state.retry_limit_88=values[i];t.attempts=values[j];t.state.retune_104=(uint8_t)tune;t.event=event;t.handlers.minimum_enabled_b0=0;if(disabled)t.top="disabled";
        unsigned retry=values[i]>0&&values[j]<values[i];unsigned tried=!retry&&values[i]!=0&&tune&&!disabled;
        unsigned retune=tried&&event==2008;
        CHECK(vn135_stop_policy_135(&t.state,&stop_ops,&t)==(retry||retune?VN135_STOP_PROCESS_EXIT:VN135_STOP_RETURNED));
        CHECK(t.prints==retry&&t.logs[2123]==retry&&t.probes==tried&&t.retunes==retune);CHECK(t.stops==(unsigned)!(retry||retune));finish(&t);
    }
    for(unsigned ro=0;ro<2;++ro)for(unsigned wo=0;wo<2;++wo)for(unsigned fill=0;fill<2;++fill)for(int rc=-2;rc<=1;++rc){
        init(&t);t.handlers.minimum_enabled_b0=0;t.read_open=ro;t.write_open=wo;t.fill_scan=fill;t.io_rc=rc;t.attempts=2;
        unsigned retry=!(ro&&fill);
        CHECK(vn135_stop_policy_135(&t.state,&stop_ops,&t)==VN135_STOP_PROCESS_EXIT);
        CHECK(t.scans==ro&&t.prints==retry*wo&&t.retunes==!retry&&t.closes==ro+retry*wo);finish(&t);
    }
    for(unsigned b=0;b<2;++b)for(unsigned c=0;c<2;++c)for(unsigned word=0;word<3;++word)for(unsigned missing=0;missing<2;++missing){
        init(&t);t.handlers.minimum_enabled_b0=(uint8_t)b;t.state.raise_failed_c8=(uint8_t)c;t.state.word_30=word;t.lookup_null=missing;
        CHECK(vn135_stop_policy_135(&t.state,&stop_ops,&t)==VN135_STOP_PROCESS_EXIT);CHECK(t.actions==(unsigned)(b&&c&&word==1&&!missing));finish(&t);
    }
    for(unsigned mutate=0;mutate<2;++mutate){init(&t);t.partial=1;t.mutate_limit=mutate;CHECK(vn135_stop_policy_135(&t.state,&stop_ops,&t)==VN135_STOP_PROCESS_EXIT);CHECK(t.describes==(mutate?1u:2u));CHECK(t.retunes==mutate);finish(&t);}
    init(&t);t.handlers.minimum_enabled_b0=0;t.mutate_limit=1;CHECK(vn135_stop_policy_135(&t.state,&stop_ops,&t)==VN135_STOP_PROCESS_EXIT);CHECK(t.printed==1&&t.logs[2123]==1&&t.state.retry_limit_88==-99);finish(&t);
    for(int rc=-1;rc<=1;++rc){init(&t);t.attempts=2;t.mutate_event=1;t.mutate_label=1;t.probe_rc=rc;CHECK(vn135_stop_policy_135(&t.state,&stop_ops,&t)==(rc==0?VN135_STOP_PROCESS_EXIT:VN135_STOP_RETURNED));CHECK(t.retunes==(unsigned)(rc==0)&&t.event==2006);finish(&t);}
    for(size_t i=0;i<7;++i){init(&t);vn135_restart_count_store_135(&counter_ops,&t,values[i]);CHECK(t.printed==values[i]&&t.prints==1&&t.closes==1);finish(&t);}
    init(&t);enum vn135_stop_flow flow=VN135_STOP_PROCESS_EXIT;CHECK(!vn135_stop_policy_dispatch_135(&t.state,&stop_ops,&t,0x5f0fc,&flow));CHECK(flow==VN135_STOP_PROCESS_EXIT&&t.reads==0);CHECK(vn135_stop_policy_dispatch_135(&t.state,&stop_ops,&t,0x5e92c,&flow));CHECK(flow==VN135_STOP_PROCESS_EXIT);finish(&t);
    /* Parent -> chain decision -> stop policy -> actual common shutdown and
     * power-stop, versus a nonreturning exit that must unwind the parent. */
    for(unsigned g=0;g<2;++g)for(unsigned retry=0;retry<2;++retry)for(int off=-1;off<=1;++off){
        init(&t);t.handlers.minimum_enabled_b0=0;t.state.retry_limit_88=retry?2:0;t.use_shutdown=1;t.psu_rc=off;
        CHECK(parent(&t,g)==(retry?VN135_STOP_PROCESS_EXIT:VN135_STOP_RETURNED));
        CHECK(t.events==(retry?1u:2u));CHECK(t.stops==(retry?0u:2u));CHECK(t.psu_offs==!retry);
        CHECK(t.resets==(unsigned)(!retry&&off==0));CHECK(t.markers==!retry&&t.thread_requests==!retry);
        if(!retry){CHECK(t.general.state==6&&t.general.running==0);CHECK(t.power.byte_ff1==(uint8_t)(off!=0));CHECK(t.power.word_20c==(off?13000u:0u));}
        else CHECK(t.general.state==2&&t.general.running==1);
        finish(&t);
    }
    printf("STOP_POLICY135_NATIVE_PASS scenarios=%" PRIu64 " assertions=%" PRIu64 " real_io=no real_exit=no hardware=no threads=scripted\n",scenarios,assertions);
    return 0;
}
