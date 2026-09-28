/* Host allocations and typed callback boundaries; never pthread/device calls. */
#include "integration/chain_work_start_135.h"
#include "xminer/recovery/nonce_fifo.h"
#include "xminer/recovery/uart.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; assert(x); } while (0)
enum { COUNT=1,MUTEX,QUEUE,PATH,OPEN,CREATE,LOG };
struct world {
    uint64_t before;
    int32_t index,device_index,count,init_rc,open_rc,create_rc;
    struct vn135_shutdown_thread worker;
    uint32_t path_method,open_method,handle_out;
    unsigned mutation,events[12],n,line;
    uintptr_t log_arg;
    bool nested,null_path;
    char path[32];
    unsigned mutex_identity,queue_identity,uart_identity,ioctls,allocations,frees;
    vn135_fifo fifo;
    vn135_uart uart;
    vn135_fifo_memory memory;
    vn135_uart_ops uart_ops;
    uint64_t after;
};
static void event(struct world *w,unsigned e) { CHECK(w->n<12);w->events[w->n++]=e; }
static int32_t count(void *c) {
    struct world *w=c;event(w,COUNT);
    if(w->mutation==1)w->index=-1;
    if(w->mutation==2)w->index=0;
    if(w->mutation==3)w->worker.running=255;
    return w->count;
}
static int32_t mutex_init(void *c,void *obj,uint32_t attr) {
    struct world *w=c;event(w,MUTEX);CHECK(obj==&w->mutex_identity && !attr);
    if(w->mutation==4)w->index=7;
    return w->init_rc;
}
static void *allocate(void *c,size_t bytes) {
    struct world *w=c;CHECK(bytes==0x800);++w->allocations;
    void *p=malloc(bytes);CHECK(p);return p;
}
static void release(void *c,void *p) { struct world *w=c;CHECK(p);++w->frees;free(p); }
static int32_t queue_init(void *c,void *obj,uint32_t cap,uint32_t stride) {
    struct world *w=c;event(w,QUEUE);CHECK(obj==&w->queue_identity && cap==0x800 && stride==1);
    if(w->mutation==5)w->path_method=0x115d10;
    if(w->nested)CHECK(vn135_fifo_init(&w->fifo,cap,stride,&w->memory)==0);
    return w->init_rc;
}
static void *path(void *c,uint32_t method,int32_t index) {
    struct world *w=c;event(w,PATH);CHECK(method==w->path_method && index==w->index);
    if(w->mutation==6){w->index=INT32_MAX;w->open_method=0x116dd8;}
    return w->null_path?NULL:w->path;
}
static int32_t lower_open(void *c,const char *p,uint32_t flags) {
    struct world *w=c;CHECK(p==w->path && flags==0x902);return 7;
}
static char *duplicate(void *c,const char *p) {
    struct world *w=c;CHECK(p==w->path);size_t n=strlen(p)+1;
    char *out=malloc(n);CHECK(out);memcpy(out,p,n);++w->allocations;return out;
}
static int32_t lower_init(void *c) { struct world *w=c;return w->init_rc; }
static int32_t ioctl_injected(void *c,int32_t fd,uint32_t request,void *data) {
    struct world *w=c;CHECK(fd==7);vn135_uart_attributes *a=data;
    CHECK(request==((w->ioctls&1)?VN135_UART_TCSETS2:VN135_UART_TCGETS2));
    if(!(w->ioctls&1))memset(a,0xff,sizeof(*a));
    if(w->ioctls==1){CHECK(a->control_chars[5]==0 && a->control_chars[6]==7);CHECK(a->input_flags==0xfffffa14);}
    if(w->ioctls==3)CHECK(a->input_speed==115200 && a->output_speed==115200);
    ++w->ioctls;return 0;
}
static int32_t lower_close(void *c,int32_t fd) { (void)c;CHECK(fd==7);return 0; }
static void lower_destroy(void *c) { (void)c; }
static int32_t open_uart(void *c,uint32_t method,void *obj,void *p) {
    struct world *w=c;event(w,OPEN);
    CHECK(method==w->open_method && obj==&w->uart_identity && p==(w->null_path?NULL:w->path));
    CHECK(w->device_index==w->index);
    if(w->mutation==7){w->index=-1;w->worker.running=128;}
    if(w->nested){CHECK(method==0x10e0c8);CHECK(vn135_uart_open(&w->uart,&w->uart_ops,p)==0);}
    return w->open_rc;
}
static int32_t create(void *c,uint32_t *h,uint32_t attr,uint32_t entry,void *arg) {
    struct world *w=c;event(w,CREATE);
    CHECK(h==&w->worker.handle && attr==0 && entry==0xc36e8 && arg==w);
    if(w->mutation==8)w->index=INT32_MAX;
    *h=w->handle_out;return w->create_rc;
}
static void log_event(void *c,uint32_t prefix,uint32_t source,uint32_t group,
    uint32_t line,uint32_t severity,uint32_t message,uintptr_t arg) {
    struct world *w=c;event(w,LOG);CHECK(prefix==0x5e9659 && source==0x5e962e && group==0x5e9660 && severity==1);
    CHECK(message==(line==0x2b8?0x5e966b:line==0x2c8?0x5e9682:0x5e96a7));
    w->line=line;w->log_arg=arg;
}
static const struct vn135_chain_work_start_ops ops={count,mutex_init,queue_init,path,open_uart,create,log_event};
static void run(int32_t index,int32_t count_value,uint8_t flag,int32_t init,
                int32_t opened,int32_t created,unsigned mutation,bool nested,bool null_path) {
    struct world w={0};w.before=w.after=UINT64_C(0x91abcdef77112233);
    w.index=index;w.device_index=99;w.count=count_value;w.worker.handle=22;w.worker.running=flag;
    w.init_rc=init;w.open_rc=opened;w.create_rc=created;w.mutation=mutation;w.nested=nested;w.null_path=null_path;
    w.path_method=0x10cf84;w.open_method=0x10e0c8;w.handle_out=0xffffffff;
    memcpy(w.path,"injected-uart-identity",23);w.uart.fd=-1;
    w.memory=(vn135_fifo_memory){&w,allocate,release};
    w.uart_ops=(vn135_uart_ops){.context=&w,.open=lower_open,.duplicate=duplicate,.release=release,
        .ioctl=ioctl_injected,.close=lower_close,.mutex_init=lower_init,.mutex_destroy=lower_destroy};
    struct vn135_chain_work_start_view v={&w.index,&w.device_index,&w.worker,&w.path_method,&w.open_method,&w,&w.mutex_identity,&w.queue_identity,&w.uart_identity};
    int32_t rc=vn135_chain_work_start_135(&v,&ops,&w);++scenarios;
    int32_t validated=mutation==1?-1:mutation==2?0:index;
    bool invalid=validated<0 || validated>=count_value;
    bool skipped=!invalid && (flag!=0 || mutation==3);
    if(invalid){CHECK(rc==-1 && w.n==2 && w.events[1]==LOG && w.line==0x2b8);CHECK(w.log_arg==(uint32_t)validated+UINT32_C(1));}
    else if(skipped)CHECK(rc==0 && w.n==1);
    else {
        unsigned expected[]={COUNT,MUTEX,QUEUE,PATH,OPEN,opened?LOG:CREATE,LOG};
        CHECK(w.n==(opened?6u:created?7u:6u));CHECK(!memcmp(expected,w.events,w.n*sizeof(*expected)));
        CHECK(rc==((opened||created)?-1:0));
        CHECK(w.device_index==(mutation==6?INT32_MAX:mutation==4?7:validated));
        CHECK(w.worker.running==(mutation==7?128:0));
        CHECK(w.worker.handle==(opened?22:0xffffffff));
        if(opened){CHECK(w.line==0x2c8);CHECK(w.log_arg==(uintptr_t)(null_path?NULL:w.path));}
        else if(created){CHECK(w.line==0x2d0);CHECK(w.log_arg==(uint32_t)w.index+UINT32_C(1));}
    }
    if(invalid||skipped){CHECK(w.device_index==99 && w.worker.handle==22);CHECK(!w.allocations);}
    if(nested && !invalid && !skipped){
        CHECK(w.fifo.capacity==0x800 && w.fifo.element_size==1 && w.fifo.count==0);
        CHECK(w.fifo.read_index==0 && w.fifo.write_index==0 && w.fifo.storage);
        CHECK(w.uart.fd==7 && w.uart.baud==115200 && w.uart.mutex_ready && w.ioctls==4);
        CHECK(w.allocations==2 && w.frees==0); /* coordinator never rolls back */
        uint8_t byte=0x5a,out=0;CHECK(vn135_fifo_push(&w.fifo,&byte)==1);CHECK(vn135_fifo_pop(&w.fifo,&out)==1 && out==byte);
        CHECK(vn135_fifo_destroy(&w.fifo,&w.memory)==0);CHECK(vn135_uart_destroy(&w.uart,&w.uart_ops)==0);
        CHECK(w.frees==w.allocations);
    }
    CHECK(w.before==UINT64_C(0x91abcdef77112233) && w.after==w.before);
}
int main(void) {
    int32_t indices[]={INT32_MIN,-1,0,1,INT32_MAX},counts[]={-1,0,1,3,INT32_MAX};
    int32_t errors[]={0,-1,1,INT32_MIN,INT32_MAX};uint8_t flags[]={0,1,128,255};
    for(unsigned i=0;i<5;i++)for(unsigned c=0;c<5;c++)for(unsigned f=0;f<4;f++)
        for(unsigned m=0;m<9;m++)for(unsigned e=0;e<5;e++)
            run(indices[i],counts[c],flags[f],-17,errors[e],errors[(e+1)%5],m,false,e%2);
    for(unsigned m=0;m<9;m++)for(unsigned o=0;o<5;o++)for(unsigned c=0;c<5;c++)
        run(0,3,0,errors[c],errors[o],errors[c],m,false,c%2);
    for(unsigned o=0;o<5;o++)for(unsigned c=0;c<5;c++)
        run(0,3,0,errors[c],errors[o],errors[c],0,true,false);
    printf("CHAIN_WORK_START_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);return 0;
}
