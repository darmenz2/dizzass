/* A-01 host-only test: real bounded byte clearing, no devices or live threads. */
#include "integration/throttling_reset_135.h"
#include "integration/mining_stop_135.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned tests;
static uint64_t checks;
#define CHECK(expr) do { ++checks; if (!(expr)) { \
    fprintf(stderr,"check failed at %d: %s\n",__LINE__,#expr); exit(1); } } while(0)
enum { N = 3, BYTES = 64, COUNT = 1, PLATFORM, LOCK, ZERO, UNLOCK };
struct guarded_row { uint8_t before[8], data[BYTES], after[8]; };
struct event { unsigned kind, row; uint32_t length; };
struct fixture {
    struct vn135_general_model general[2];
    struct vn135_throttling_reset_model model[2];
    struct vn135_throttling_reset_tables tables;
    struct vn135_throttling_reset_view view;
    struct vn135_throttling_reset_ops ops;
    struct guarded_row buffers[4][N];
    uint8_t *rows[4][N];
    int count, platform, lock_result;
    unsigned mutex, mutation, zeros;
    struct event events[32];
    unsigned used;
    struct vn135_general_monitor monitor;
    struct vn135_monitor_handlers handlers;
    struct vn135_mining_stop_state mining;
    unsigned parent_order[16], parent_used;
    uint32_t joined;
};
static void event(struct fixture *f,unsigned kind,unsigned row,uint32_t length)
{
    CHECK(f->used < 32);
    f->events[f->used++] = (struct event){kind,row,length};
}
static int32_t count(void *p)
{
    struct fixture *f=p; event(f,COUNT,0,0);
    if(f->mutation==1) f->view.model=&f->model[1];
    return f->count;
}
static int32_t platform(void *p)
{
    struct fixture *f=p; event(f,PLATFORM,0,0);
    if(f->mutation==2) f->view.model=&f->model[1];
    return f->platform;
}
static int32_t lock(void *p,void *token)
{
    struct fixture *f=p; CHECK(token==&f->mutex);event(f,LOCK,0,0);
    if(f->mutation==3) f->view.model=&f->model[1];
    return f->lock_result;
}
static int32_t unlock(void *p,void *token)
{
    struct fixture *f=p; CHECK(token==&f->mutex);event(f,UNLOCK,0,0);
    return -5; /* Original tail-return is not a hardware-success contract. */
}
static void zero(void *p,uint8_t *data,uint32_t length)
{
    struct fixture *f=p; unsigned row=99;
    for(unsigned g=0;g<4;++g) for(unsigned i=0;i<N;++i)
        if(data==f->buffers[g][i].data) row=g*N+i;
    CHECK(row!=99);CHECK(length<=BYTES);event(f,ZERO,row,length);
    memset(data,0,length);++f->zeros;
    if(f->mutation==4 && f->zeros==1) f->general[0].expected_chips_48=1;
    if(f->mutation==5 && f->zeros==1) f->tables.groups[1]=NULL;
    if(f->mutation==6 && f->zeros==1) f->mining.handle_104c=0x81234567u;
}
static void init(struct fixture *f,int count_value,int platform_value,unsigned groups,unsigned holes)
{
    memset(f,0,sizeof(*f));f->count=count_value;f->platform=platform_value;
    f->general[0].expected_chips_48=3;f->general[1].expected_chips_48=1;
    f->model[0]=(struct vn135_throttling_reset_model){&f->general[0],2,4};
    f->model[1]=(struct vn135_throttling_reset_model){&f->general[1],1,2};
    f->view=(struct vn135_throttling_reset_view){&f->model[0],&f->tables,&f->mutex};
    f->ops=(struct vn135_throttling_reset_ops){count,platform,lock,unlock,zero};
    for(unsigned g=0;g<4;++g) {
        f->tables.groups[g]=(groups&(1u<<g)) ? NULL : f->rows[g];
        for(unsigned i=0;i<N;++i){
            memset(&f->buffers[g][i],(int)(0x30+g*N+i),sizeof(struct guarded_row));
            f->rows[g][i]=(holes&(1u<<i)) ? NULL : f->buffers[g][i].data;
        }
    }
    f->monitor.state=2;f->monitor.active=1;f->monitor.tuning=1;
    f->handlers.general=&f->monitor;f->handlers.warmup_done_22c=1;
    f->mining.handlers=&f->handlers;f->mining.handle_104c=123;
    f->mining.byte_104a=f->mining.byte_fd0=f->mining.byte_fe5=1;
}
static void expect_event(struct fixture *f,unsigned *pos,unsigned kind,unsigned row,uint32_t length)
{
    CHECK(*pos < f->used);
    struct event *e=&f->events[(*pos)++];
    CHECK(e->kind==kind);CHECK(e->row==row);CHECK(e->length==length);
}
static void ordinary(int count_value,int platform_value,unsigned groups,unsigned holes,int empty)
{
    struct fixture f;init(&f,count_value,platform_value,groups,holes);
    if(empty){f.general[0].expected_chips_48=0;f.model[0].count_50=f.model[0].count_60=0;}
    uint32_t sizes[4]={empty?0u:32u,empty?0u:24u,empty?0u:16u,empty?0u:3u};
    struct vn135_throttling_reset_tables before=f.tables;
    struct vn135_general_model model_before[2];memcpy(model_before,f.general,sizeof(model_before));
    vn135_throttling_reset_135(&f.view,&f.ops,&f);
    int active=platform_value==4 || platform_value==7;unsigned pos=0;
    expect_event(&f,&pos,COUNT,0,0);expect_event(&f,&pos,PLATFORM,0,0);
    if(active) {
        expect_event(&f,&pos,LOCK,0,0);
        for(int i=0;i<count_value;++i) for(unsigned g=0;g<4;++g)
            if(!(groups&(1u<<g)) && !(holes&(1u<<i))) expect_event(&f,&pos,ZERO,g*N+(unsigned)i,sizes[g]);
        expect_event(&f,&pos,UNLOCK,0,0);
    }
    CHECK(pos==f.used);
    for(unsigned g=0;g<4;++g) for(unsigned i=0;i<N;++i) {
        unsigned fill=0x30+g*N+i;
        for(unsigned j=0;j<8;++j){CHECK(f.buffers[g][i].before[j]==fill);CHECK(f.buffers[g][i].after[j]==fill);}
        for(unsigned j=0;j<BYTES;++j){
            int cleared=active && (int)i<count_value && !(groups&(1u<<g)) && !(holes&(1u<<i)) && j<sizes[g];
            CHECK(f.buffers[g][i].data[j]==(cleared?0u:fill));
        }
    }
    CHECK(memcmp(&before,&f.tables,sizeof(before))==0);
    CHECK(memcmp(model_before,f.general,sizeof(model_before))==0);
    ++tests;
}
static uint32_t step(void *p,uint32_t ep,uint32_t arg)
{
    struct fixture *f=p;CHECK(arg==0);CHECK(f->parent_used<16);
    f->parent_order[f->parent_used++]=ep;
    if(ep==0xb8e54u) vn135_throttling_reset_135(&f->view,&f->ops,f);
    else CHECK(ep==0xfe218u || ep==0x65b3cu);
    return 0xaabbccdd; /* Ignored by the original caller, not success. */
}
static int32_t delay(void *p,uint32_t ms)
{
    struct fixture *f=p;CHECK(ms==100);f->parent_order[f->parent_used++]=1;return -1;
}
static int32_t cancel(void *p,uint32_t handle)
{
    struct fixture *f=p;CHECK(handle==0x81234567u);f->mining.handle_104c=789;
    f->parent_order[f->parent_used++]=2;return -1;
}
static int32_t join(void *p,uint32_t handle,uint32_t *out)
{
    struct fixture *f=p;CHECK(out==NULL);f->joined=handle;
    f->parent_order[f->parent_used++]=3;return -2;
}
static void log_line(void *p,uint32_t line)
{
    struct fixture *f=p;CHECK(line==4825);CHECK(f->monitor.active==0);
    f->parent_order[f->parent_used++]=4;
}
int main(void)
{
    static const int platforms[]={0,1,2,3,4,7,8,-1};
    for(unsigned p=0;p<sizeof(platforms)/sizeof(platforms[0]);++p)
        for(int n=-1;n<=N;++n) for(unsigned g=0;g<16;++g) for(unsigned holes=0;holes<8;++holes)
            ordinary(n,platforms[p],g,holes,0);
    for(unsigned g=0;g<16;++g) ordinary(3,4,g,0,1);
    for(unsigned mutation=1;mutation<=5;++mutation){
        struct fixture f;init(&f,2,4,0,0);f.mutation=mutation;f.lock_result=-1;
        vn135_throttling_reset_135(&f.view,&f.ops,&f);
        CHECK(f.events[3].length==(mutation==1?16u:32u));
        CHECK(f.events[f.used-1].kind==UNLOCK);
        if(mutation==4) CHECK(f.events[4].length==8);
        if(mutation==5){CHECK(f.zeros==6);CHECK(f.events[4].row==6);}
        ++tests;
    }
    {
        struct fixture f;init(&f,1,2,0,0);
        f.view.model=NULL;f.view.tables=NULL;f.ops.lock=NULL;f.ops.unlock=NULL;f.ops.zero=NULL;
        vn135_throttling_reset_135(&f.view,&f.ops,&f);CHECK(f.used==2);++tests;
    }
    {
        struct fixture f;init(&f,0,4,0,0);f.view.model=NULL;f.view.tables=NULL;f.ops.zero=NULL;
        vn135_throttling_reset_135(&f.view,&f.ops,&f);CHECK(f.used==4);++tests;
    }
    {
        struct fixture f;init(&f,1,4,8,0);
        f.general[0].expected_chips_48=0x20000001;
        f.model[0].count_50=0x40000001;f.model[0].count_60=0x80000001;
        vn135_throttling_reset_135(&f.view,&f.ops,&f);
        for(unsigned i=3;i<6;++i) CHECK(f.events[i].length==8);
        ++tests;
    }
    {
        struct fixture f;init(&f,2,4,0,0);f.mutation=6;
        struct vn135_shutdown_ops ops={0};ops.step=step;ops.delay_ms=delay;
        ops.cancel=cancel;ops.join=join;ops.log=log_line;
        vn135_backend_stop_mining_135(&f.mining,&ops,&f);
        static const unsigned sequence[]={0xfe218,0xb8e54,1,2,3,0x65b3c,4};
        CHECK(f.parent_used==sizeof(sequence)/sizeof(sequence[0]));
        CHECK(memcmp(sequence,f.parent_order,sizeof(sequence))==0);
        CHECK(f.joined==789);CHECK(f.monitor.state==2);CHECK(f.monitor.tuning==0);
        CHECK(f.mining.byte_104a==0);CHECK(f.handlers.warmup_done_22c==0);CHECK(f.zeros==8);
        ++tests;
    }
    printf("THROTTLING_RESET135_NATIVE_PASS cases=%u checks=%" PRIu64 "\n",tests,checks);
    return 0;
}
