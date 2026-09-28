/* SPDX-License-Identifier: GPL-3.0-only */
#include "integration/chain_work_stop_135.h"
#include "xminer/recovery/uart.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static uint64_t checks,cases;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"line%d: %s\n",__LINE__,#x); abort(); } } while (0)
struct guarded { uint32_t before[4]; struct vn135_shutdown_thread thread; uint32_t after[4]; };
struct state {
    struct guarded guard;
    struct vn135_chain_work_stop_view view;
    int32_t index,initial,count;
    uint32_t head,tail,method,handle;
    void *allocation;
    unsigned mode,step,free_calls,uart_frees,closes,uart_mutex,logs,getters;
    int queue_id,chain_id,uart_id,replacement;
    uint8_t flag;
    bool occupied,selected,nested;
    vn135_uart uart;
};
static int32_t count(void *p)
{
    struct state *s=p; CHECK(s->initial>=0 && ++s->getters==1 && s->step==0);
    if (s->mode&1) s->index=INT32_MIN;
    return s->count;
}
static int32_t mutex(void *p,uint32_t entry,void *object)
{
    struct state *s=p; CHECK(s->selected);
    if (s->step==0) {
        CHECK(entry==0x5a6108 && object==&s->queue_id);
        CHECK(s->head==27 && s->tail==19 && s->guard.thread.running==s->flag);
        s->head=0xffffffff; s->tail=0x80000000;
    } else if (s->step==1) {
        CHECK(entry==0x5a66c4 && object==&s->queue_id && s->head==0 && s->tail==0);
        CHECK(s->guard.thread.running==s->flag);
        if (s->mode&2) { s->guard.thread.running=0; s->guard.thread.handle=0xdeadbeef; }
    } else if (s->step==4) {
        CHECK(entry==0x5a6108 && object==&s->chain_id && s->guard.thread.running==255);
    } else {
        CHECK(s->step==5 && entry==0x5a66c4 && object==&s->chain_id);
        CHECK(s->allocation==NULL && s->free_calls==(unsigned)s->occupied);
        if (s->mode&4) s->method=0x116f00;
        s->allocation=&s->replacement; /* later writes must survive */
    }
    ++s->step; return -17;
}
static int32_t cancel(void *p,uint32_t h)
{
    struct state *s=p; CHECK(s->step++==2 && s->guard.thread.running==0);
    CHECK(h==((s->mode&2) ? 0xdeadbeefu : s->handle));
    s->guard.thread.handle=0xfafababa; s->guard.thread.running=255;
    return INT32_MIN;
}
static int32_t join(void *p,uint32_t h,uint32_t *r)
{
    struct state *s=p; CHECK(s->step++==3 && h==0xfafababa && r==NULL && s->guard.thread.running==255);
    return 3;
}
static void release(void *p,void *allocation)
{
    struct state *s=p; CHECK(s->step==5 && ++s->free_calls==1 && allocation==s->allocation);
    for (unsigned i=0;i<31;++i) CHECK(((uint8_t *)allocation)[i]==0x9b);
    free(allocation); s->allocation=&s->replacement;
}
static void uart_release(void *p,void *allocation)
{
    struct state *s=p; CHECK(s->step==7 && ++s->uart_frees==1 && allocation==s->uart.path);
    free(allocation);
}
static int32_t uart_close(void *p,int32_t fd)
{
    struct state *s=p; CHECK(s->step==7 && ++s->closes==1 && fd==5 && s->uart.path==NULL);
    return -7;
}
static void uart_destroy_mutex(void *p)
{
    struct state *s=p; CHECK(s->step==7 && ++s->uart_mutex==1 && s->uart.fd==-1);
}
static void uart(void *p,uint32_t method,void *object)
{
    struct state *s=p; CHECK(s->step++==6 && object==&s->uart_id);
    CHECK(method==((s->mode&4) ? 0x116f00u : 0x10e9a0u));
    CHECK(s->guard.thread.running==255 && s->allocation==&s->replacement);
    if (s->nested) {
        CHECK(method==0x10e9a0);
        vn135_uart_ops ops={0}; ops.context=s; ops.release=uart_release; ops.close=uart_close; ops.mutex_destroy=uart_destroy_mutex;
        CHECK(vn135_uart_destroy(&s->uart,&ops)==0);
        CHECK(s->uart_frees==1 && s->closes==1 && s->uart_mutex==1 && !s->uart.mutex_ready && s->uart.baud==0);
    }
}
static void log_message(void *p,uint32_t prefix,uint32_t source,uint32_t group,uint32_t line,uint32_t severity,uint32_t message,uint32_t number)
{
    struct state *s=p; CHECK(!s->selected && ++s->logs==1 && s->step==0);
    CHECK(prefix==0x5e9659 && source==0x5e962e && group==0x5e9660 && line==0x2da && severity==1 && message==0x5e966b);
    CHECK(number==(uint32_t)(s->initial<0 ? s->initial : s->index)+1u);
    CHECK(s->head==27 && s->tail==19 && s->guard.thread.running==s->flag);
}
static void run(int32_t index,int32_t total,uint8_t flag,unsigned mode,bool occupied)
{
    struct state s; memset(&s,0,sizeof(s)); memset(&s.guard,0xa5,sizeof(s.guard));
    s.index=s.initial=index; s.count=total; s.flag=flag; s.mode=mode; s.head=27; s.tail=19;
    s.handle=(mode&1) ? 0 : UINT32_MAX; s.guard.thread.handle=s.handle; s.guard.thread.running=flag;
    s.method=0x10e9a0; s.occupied=occupied;
    s.selected=index>=0 && index<total && flag!=0; s.nested=s.selected && !(mode&4);
    if (occupied) { s.allocation=malloc(31); CHECK(s.allocation!=NULL); memset(s.allocation,0x9b,31); }
    void *initial_allocation=s.allocation;
    if (s.nested) { s.uart=(vn135_uart){malloc(7),5,115200,true}; CHECK(s.uart.path!=NULL); }
    s.view=(struct vn135_chain_work_stop_view){&s.index,&s.guard.thread,&s.head,&s.tail,&s.allocation,&s.method,&s.queue_id,&s.chain_id,&s.uart_id};
    const struct vn135_chain_work_stop_ops ops={count,mutex,cancel,join,release,uart,log_message};
    vn135_chain_work_stop_135(&s.view,&ops,&s);
    CHECK(s.getters==(unsigned)(index>=0));
    bool invalid=index<0 || index>=total;
    CHECK(s.logs==(unsigned)invalid && s.step==(s.selected ? 7u : 0u));
    if (!s.selected) { CHECK(s.allocation==initial_allocation && s.guard.thread.handle==s.handle && s.guard.thread.running==flag); free(initial_allocation); }
    else CHECK(s.guard.thread.handle==0xfafababa && s.guard.thread.running==255 && s.free_calls==(unsigned)occupied);
    for (unsigned i=0;i<4;++i) CHECK(s.guard.before[i]==0xa5a5a5a5u && s.guard.after[i]==0xa5a5a5a5u);
    ++cases;
}
int main(void)
{
    const int32_t values[]={INT32_MIN,-1,0,1,3,INT32_MAX}; const uint8_t flags[]={0,1,2,128,255};
    for (unsigned a=0;a<6;++a) for (unsigned b=0;b<6;++b) for (unsigned c=0;c<5;++c)
        for (unsigned mode=0;mode<8;++mode) for (unsigned ptr=0;ptr<2;++ptr) run(values[a],values[b],flags[c],mode,ptr!=0);
    printf("CHAIN_WORK_STOP_NATIVE_PASS cases=%" PRIu64 " checks=%" PRIu64 "\n",cases,checks);return 0;
}
