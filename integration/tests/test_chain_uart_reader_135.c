/* Bounded injected execution; real host allocations, never real OS/device I/O. */
#include "integration/chain_uart_reader_135.h"
#include "xminer/recovery/nonce_fifo.h"
#include "xminer/recovery/uart.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; assert(x); } while(0)
struct world {
    uint64_t before;
    uint32_t model,controller,method,begin,end,stride,count,cap,old_mode;
    uint8_t force,running;
    int32_t index,result,rc;
    unsigned chain_mutex,queue_identity,uart_identity,global_mutex,condition;
    unsigned held,global_held,reads,pushes,signals,exits,modes,waits,wait_goal,delays;
    unsigned threshold,initial_count,expected_pushes,expected_signals;
    bool nested,change_selectors;
    vn135_fifo fifo;
    vn135_uart uart;
    vn135_uart_ops uart_ops;
    uint64_t left;
    struct vn135_chain_uart_reader_scratch scratch;
    uint64_t right;
};
static int32_t mutex(void *ctx,uint32_t entry,void *obj) {
    struct world *w=ctx;
    if(obj==&w->chain_mutex){
        if(entry==0x5a6108){CHECK(!w->held && !w->global_held);w->held=1;}
        else {CHECK(entry==0x5a66c4 && w->held && !w->global_held);w->held=0;}
    } else {
        CHECK(obj==&w->global_mutex && w->held);
        if(entry==0x5a6108){CHECK(!w->global_held);w->global_held=1;}
        else {CHECK(entry==0x5a66c4 && w->global_held);w->global_held=0;}
    }
    return w->rc;
}
static int32_t delay(void *ctx,uint32_t ms) {
    struct world *w=ctx;CHECK(ms==5 && !w->held && !w->global_held);++w->delays;
    if(w->waits<w->wait_goal){
        ++w->waits;w->running=0; /* wait must not acquire a new flag exit */
        if(w->waits==w->wait_goal){w->stride=1;w->end=w->begin+w->cap;}
    }
    return w->rc;
}
static int32_t mode(void *ctx,uint32_t value,uint32_t *old) {
    struct world *w=ctx;CHECK(!w->held);++w->modes;
    if(old){CHECK(old==w->scratch.previous_mode && value==0);*old=w->old_mode;}
    else CHECK(value==1);
    w->old_mode=value;return w->rc;
}
static int32_t format(void *ctx,char *out,uint32_t n,uint32_t fmt,int32_t index) {
    struct world *w=ctx;CHECK(out==w->scratch.name && n==64 && fmt==0x5e973e && index==w->index);
    (void)snprintf(out,n,"test:%d",index);
    if(w->change_selectors){w->model=0;w->controller=0;w->force=1;}
    return w->rc;
}
static int32_t name(void *ctx,uint32_t op,const char *p,uint32_t a,uint32_t b,uint32_t c) {
    struct world *w=ctx;CHECK(op==15 && p==w->scratch.name && !a && !b && !c);
    CHECK(strncmp(p,"test:",5)==0);w->running=0;return w->rc;
}
static int32_t receive(struct world *w,uint8_t *out,uint32_t n) {
    CHECK(out==w->scratch.bytes && n==(w->cap<256?w->cap:256));
    CHECK(!w->held && !w->global_held && w->old_mode==0);
    ++w->reads;CHECK(w->reads<=3);
    if(w->result>0){
        for(int32_t i=0;i<w->result;i++)out[i]=(uint8_t)(i+17*w->reads);
        ++w->expected_pushes;
        uint32_t after=w->nested?w->fifo.count+(uint32_t)w->result:w->count;
        if(w->nested && after>w->cap)after=w->cap;
        w->expected_signals+=after>=w->threshold;
    }
    if(w->reads==3)w->running=0;
    else w->running=255;
    return w->result;
}
static int32_t ioctl_injected(void *ctx,int32_t fd,uint32_t command,void *p) {
    struct world *w=ctx;CHECK(fd==7 && command==VN135_UART_FIONREAD && w->old_mode==0);
    *(int32_t *)p=1;return 0;
}
static int32_t lower_read(void *ctx,int32_t fd,uint8_t *out,uint32_t n) {
    CHECK(fd==7);return receive(ctx,out,n);
}
static int32_t read_uart(void *ctx,uint32_t method,void *obj,uint8_t *out,uint32_t n) {
    struct world *w=ctx;CHECK(method==0x10e938 && obj==&w->uart_identity);
    if(w->nested)return vn135_uart_read(&w->uart,&w->uart_ops,out,n);
    return receive(w,out,n);
}
static uint32_t push(void *ctx,void *obj,const uint8_t *data,uint32_t n) {
    struct world *w=ctx;CHECK(obj==&w->queue_identity && data==w->scratch.bytes && n==(uint32_t)w->result);
    CHECK(w->held && !w->global_held && w->old_mode==1);++w->pushes;
    for(uint32_t i=0;i<n;i++)CHECK(data[i]==(uint8_t)(i+17*w->reads));
    uint32_t done=0;
    if(w->nested){
        for(uint32_t i=0;i<n;i++){
            int r=vn135_fifo_push(&w->fifo,data+i);CHECK(r==0 || r==1);
            if(!r)break;
            ++done;
        }
        CHECK(vn135_fifo_count(&w->fifo,&w->count)==0);
    }
    return done; /* deliberately zero in raw mode, still must count/signal */
}
static int32_t signal_condition(void *ctx,void *obj) {
    struct world *w=ctx;CHECK(obj==&w->condition && w->held && w->global_held);++w->signals;return w->rc;
}
static void exit_thread(void *ctx,uint32_t result) {
    struct world *w=ctx;CHECK(!result && !w->held && !w->global_held && w->running==0);++w->exits;
}
static void *allocate(void *ctx,size_t n) { (void)ctx;void *p=malloc(n);CHECK(p);memset(p,0xab,n);return p; }
static void release(void *ctx,void *p) { (void)ctx;free(p); }
static const struct vn135_chain_uart_reader_ops ops={mutex,delay,mode,format,name,read_uart,push,signal_condition,exit_thread};
static void run(uint32_t model,uint32_t controller,uint8_t force,uint32_t count,
                uint32_t cap,int32_t result,unsigned waits,bool nested,bool changed) {
    struct world w={0};w.before=w.left=w.right=UINT64_C(0xdeadbabe33445566);
    w.model=model;w.controller=controller;w.force=force;w.index=INT32_MIN;
    w.method=0x10e938;w.begin=0x845000;w.end=w.begin+cap;w.stride=1;w.count=count;
    w.cap=cap;w.result=result;w.rc=-17;w.wait_goal=waits;w.nested=nested;w.change_selectors=changed;
    w.old_mode=2;w.threshold=force?9:controller==0 || (model==6 && controller==4)?9:model==7?10:11;
    memset(&w.scratch,0xcd,sizeof(w.scratch));
    vn135_fifo_memory memory={NULL,allocate,release};
    if(nested){
        CHECK(vn135_fifo_init(&w.fifo,cap,1,&memory)==0);
        w.fifo.count=count;w.fifo.read_index=cap-1;w.fifo.write_index=(cap-1+count)%cap;
        w.uart.fd=7;w.uart_ops=(vn135_uart_ops){.context=&w,.ioctl=ioctl_injected,.read=lower_read};
    }
    if(waits)w.stride=0;
    struct vn135_chain_uart_reader_view v={&w.model,&w.controller,&w.force,&w.index,&w.running,&w.method,
        &w.begin,&w.end,&w.stride,&w.count,&w.chain_mutex,&w.queue_identity,&w.uart_identity,&w.global_mutex,&w.condition};
    vn135_chain_uart_reader_135(&v,&ops,&w,&w.scratch);++scenarios;
    CHECK(w.reads==3 && w.pushes==w.expected_pushes && w.signals==w.expected_signals && w.exits==1);
    CHECK(w.modes==7 && w.waits==waits && w.delays==waits+(result<=0?3u:0u));
    CHECK(w.scratch.previous_mode[0]==1 && w.scratch.previous_mode[1]==0xcdcdcdcd);
    CHECK(w.before==UINT64_C(0xdeadbabe33445566) && w.left==w.before && w.right==w.before);
    if(nested){
        uint32_t expected=count+(result>0?3*(uint32_t)result:0);
        if(expected>cap)expected=cap;
        CHECK(w.count==expected);CHECK(vn135_fifo_destroy(&w.fifo,&memory)==0);
    }
}
int main(void) {
    uint32_t models[]={0,6,7,UINT32_MAX},controllers[]={0,1,4};uint8_t forces[]={0,1,255};
    int32_t results[]={INT32_MIN,-1,0,1,9,10,11,255,256};
    for(unsigned m=0;m<4;m++)for(unsigned c=0;c<3;c++)for(unsigned f=0;f<3;f++)
        for(unsigned r=0;r<9;r++)for(unsigned count=8;count<12;count++)
            run(models[m],controllers[c],forces[f],count,2048,results[r],r%3,false,r%2);
    uint32_t caps[]={1,7,11,64,256,2048};
    for(unsigned n=0;n<6;n++)for(unsigned full=0;full<2;full++)for(unsigned waits=0;waits<3;waits++)
        run(7,4,0,full?caps[n]:0,caps[n],(int32_t)(caps[n]<256?caps[n]:256),waits,true,false);
    printf("CHAIN_UART_READER_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);return 0;
}
