/* SPDX-License-Identifier: GPL-3.0-only
 * Allocated host PTYs only. Optional write-size cap stresses segmentation;
 * every return/error still comes from the actual kernel write. */
#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "integration/native/protocol_channel_tx.h"
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <pty.h>
#include <sched.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"PROTOCOL_TX_PTY_ASSERT %d: %s errno=%d\n",__LINE__,#x,errno);exit(1); } } while(0)
static unsigned cases;
static atomic_int observed_fd = -1;
static atomic_uint fragment_cap, eagain_count, shortened;
ssize_t __real_write(int,const void *,size_t);
ssize_t __wrap_write(int fd,const void *data,size_t size)
{
    unsigned cap=atomic_load(&fragment_cap);
    bool observe=fd==atomic_load(&observed_fd);
    size_t request=observe && cap && size>cap ? cap : size;
    ssize_t n=__real_write(fd,data,request);int e=errno;
    if(observe){
        if(n>0 && (size_t)n<size)atomic_fetch_add(&shortened,1);
        if(n<0 && (e==EAGAIN || e==EWOULDBLOCK))atomic_fetch_add(&eagain_count,1);
        if(cap)sched_yield();
    }
    errno=e;return n;
}
static uint64_t now(void) { uint64_t t;CHECK(!dizzass_uart_posix_now_ms(&t));return t; }
static void tick(void) { struct timespec t={0,1000000};(void)nanosleep(&t,NULL); }
static struct dizzass_uart_channel_state state(struct dizzass_uart_channel *c)
{ struct dizzass_uart_channel_state s;CHECK(!dizzass_uart_channel_snapshot(c,&s));return s; }
static struct dizzass_uart_channel *pair(int *m,int *s)
{
    CHECK(!openpty(m,s,NULL,NULL,NULL));struct termios t;CHECK(!tcgetattr(*s,&t));cfmakeraw(&t);CHECK(!tcsetattr(*s,TCSANOW,&t));
    CHECK(!fcntl(*s,F_SETFL,fcntl(*s,F_GETFL)|O_NONBLOCK));CHECK(!fcntl(*m,F_SETFL,fcntl(*m,F_GETFL)|O_NONBLOCK));
    struct dizzass_uart_channel *c=NULL;CHECK(!dizzass_uart_channel_create(&c,*s));
    atomic_store(&observed_fd,*s);atomic_store(&fragment_cap,0);atomic_store(&shortened,0);atomic_store(&eagain_count,0);return c;
}
static void dispose(struct dizzass_uart_channel **c,int m,int s)
{
    CHECK(!dizzass_uart_channel_stop(*c,0));CHECK(!dizzass_uart_channel_destroy(c));
    CHECK(fcntl(s,F_GETFL)>=0);atomic_store(&observed_fd,-1);CHECK(!close(s) && !close(m));
}
static void collect(int fd,uint8_t *data,size_t size)
{
    size_t got=0;uint64_t end=now()+12000;
    while(got<size && now()<end){
        ssize_t n=read(fd,data+got,size-got);if(n>0){got+=(size_t)n;continue;}
        CHECK(n<0 && (errno==EAGAIN || errno==EINTR));struct pollfd p={fd,POLLIN,0};int r=poll(&p,1,10);CHECK(r>=0 || errno==EINTR);
    }
    CHECK(got==size);
}
static void none(int fd) { struct pollfd p={fd,POLLIN,0};CHECK(poll(&p,1,20)==0); }
static void words_for(uint8_t *words,unsigned id)
{ for(unsigned j=0;j<80;++j)words[j]=(uint8_t)(j*13+id*7);words[0]=(uint8_t)id;words[1]=(uint8_t)(id>>8); }
static void success(struct dizzass_protocol_tx_receipt r,size_t length)
{ CHECK(!r.prepare_status && r.channel_called && r.frame_size==length && r.transport.status==DIZZASS_UART_OK && r.transport.written==length && !r.transport.error); }
static void basic_commands(void)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);uint8_t frame[11],got[11];
    for(unsigned cmd=0;cmd<4;++cmd){
        size_t n=0;uint32_t a=cmd?17:0,reg=cmd>=2?8:0,value=cmd==3?0x12345678:0;
        CHECK(!dizzass_bm1368_command_encode((enum dizzass_bm1368_command)cmd,0,a,reg,value,frame,sizeof frame,&n));
        success(dizzass_channel_bm1368_command(c,(enum dizzass_bm1368_command)cmd,0,a,reg,value,now()+2000,100),n);
        collect(m,got,n);CHECK(!memcmp(got,frame,n));none(m);
    }
    dispose(&c,m,s);++cases;
}
struct expected_frame { uint8_t bytes[88];size_t size;bool seen; };
enum { PRODUCERS=4, REPEATS=128, TOTAL=PRODUCERS*REPEATS };
struct producer { struct dizzass_uart_channel *c;unsigned id;uint64_t deadline;pthread_barrier_t *barrier; };
static void *produce(void *arg)
{
    struct producer *p=arg;int e=pthread_barrier_wait(p->barrier);CHECK(!e || e==PTHREAD_BARRIER_SERIAL_THREAD);
    for(unsigned j=0;j<REPEATS;++j){
        unsigned id=p->id*REPEATS+j;
        if(p->id%2){uint8_t w[80];words_for(w,id);success(dizzass_channel_work_tx88(p->c,w,80,2,0,j%32,p->deadline,10000),88);}
        else success(dizzass_channel_bm1368_command(p->c,3,j%2,p->id,8,UINT32_C(0x80000000)|id,p->deadline,10000),11);
    }
    return NULL;
}
static void mixed_frames(unsigned cap)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);atomic_store(&fragment_cap,cap);
    struct expected_frame *frames=calloc(TOTAL,sizeof *frames);uint8_t *received=malloc(TOTAL*88);CHECK(frames && received);
    size_t total=0;
    for(unsigned i=0;i<PRODUCERS;++i)for(unsigned j=0;j<REPEATS;++j){
        unsigned id=i*REPEATS+j;struct expected_frame *f=&frames[id];
        if(i%2){uint8_t w[80];words_for(w,id);CHECK(!dizzass_tx88_encode_words(w,80,j%32,f->bytes,88));f->size=88;}
        else CHECK(!dizzass_bm1368_command_encode(3,j%2,i,8,UINT32_C(0x80000000)|id,f->bytes,88,&f->size));
        total+=f->size;
    }
    pthread_barrier_t barrier;CHECK(!pthread_barrier_init(&barrier,NULL,PRODUCERS+1));
    pthread_t threads[PRODUCERS];struct producer producers[PRODUCERS];
    for(unsigned i=0;i<PRODUCERS;++i){producers[i]=(struct producer){c,i,now()+20000,&barrier};CHECK(!pthread_create(&threads[i],NULL,produce,&producers[i]));}
    int e=pthread_barrier_wait(&barrier);CHECK(!e || e==PTHREAD_BARRIER_SERIAL_THREAD);collect(m,received,total);
    for(unsigned i=0;i<PRODUCERS;++i)CHECK(!pthread_join(threads[i],NULL));
    size_t offset=0;unsigned own_sequence[PRODUCERS]={0};
    for(unsigned k=0;k<TOTAL;++k){
        CHECK(offset+3<=total && received[offset]==0x55 && received[offset+1]==0xaa);
        size_t n=received[offset+2]==0x21?88:11;CHECK(offset+n<=total);
        unsigned match=TOTAL;
        for(unsigned i=0;i<TOTAL;++i)if(!frames[i].seen && frames[i].size==n && !memcmp(received+offset,frames[i].bytes,n)){match=i;break;}
        CHECK(match<TOTAL && match%REPEATS==own_sequence[match/REPEATS]++);frames[match].seen=true;offset+=n;
    }
    CHECK(offset==total);none(m);if(cap)CHECK(atomic_load(&shortened)>0);
    printf("PROTOCOL_TX_PTY_MIXED frames=%u bytes=%zu write_cap=%u shortened=%u eagain=%u\n",TOTAL,total,cap,atomic_load(&shortened),atomic_load(&eagain_count));
    CHECK(!pthread_barrier_destroy(&barrier));free(frames);free(received);dispose(&c,m,s);++cases;
}
struct queued { struct dizzass_uart_channel *c;uint64_t deadline;bool work;struct dizzass_protocol_tx_receipt result; };
static void *queued_send(void *arg)
{
    struct queued *q=arg;uint8_t w[80]={0};
    q->result=q->work?dizzass_channel_work_tx88(q->c,w,80,2,0,0,q->deadline,100):
        dizzass_channel_bm1368_command(q->c,3,1,0,8,0,q->deadline,100);return NULL;
}
struct filler { struct dizzass_uart_channel *c;uint8_t *data;size_t size;uint64_t deadline;struct dizzass_uart_result result; };
static void *fill_queue(void *arg)
{ struct filler *f=arg;f->result=dizzass_uart_channel_send(f->c,f->data,f->size,f->deadline,10000);return NULL; }
static void queue_deadline_stop(void)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);size_t size=1024*1024;
    uint8_t *data=malloc(size),*got=malloc(size);CHECK(data && got);memset(data,0xa7,size);
    struct filler f={c,data,size,now()+1800,{0}};pthread_t owner;CHECK(!pthread_create(&owner,NULL,fill_queue,&f));
    uint64_t end=now()+1000;while((!state(c).active || !atomic_load(&eagain_count)) && now()<end)tick();
    CHECK(state(c).active && atomic_load(&eagain_count));
    struct queued cmd={c,now()+400,false,{0}},work={c,now()+5000,true,{0}};pthread_t t1,t2;
    CHECK(!pthread_create(&t1,NULL,queued_send,&cmd));CHECK(!pthread_create(&t2,NULL,queued_send,&work));
    end=now()+300;while(state(c).waiting<2 && now()<end)tick();CHECK(state(c).waiting==2);
    CHECK(!pthread_join(t1,NULL));CHECK(cmd.result.channel_called && !cmd.result.prepare_status && cmd.result.transport.status==DIZZASS_UART_TIMEOUT && !cmd.result.transport.written);
    CHECK(!state(c).stopped && state(c).active);
    CHECK(dizzass_uart_channel_stop(c,now())==ETIMEDOUT);CHECK(fcntl(s,F_GETFL)>=0);
    CHECK(!pthread_join(t2,NULL));CHECK(work.result.channel_called && !work.result.prepare_status && work.result.transport.status==DIZZASS_UART_CANCELED && !work.result.transport.written);
    CHECK(!pthread_join(owner,NULL));CHECK(!dizzass_uart_channel_stop(c,0));
    CHECK(f.result.status==DIZZASS_UART_TIMEOUT && f.result.written>0 && f.result.written<size);
    collect(m,got,f.result.written);CHECK(!memcmp(data,got,f.result.written));none(m);
    printf("PROTOCOL_TX_PTY_QUEUE filler_prefix=%zu command_timeout=1 work_rejected=1 no_protocol_bytes=1\n",f.result.written);
    free(data);free(got);dispose(&c,m,s);++cases;
}
static void shared_fault(bool first_work)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);struct termios t;CHECK(!tcgetattr(s,&t));t.c_oflag|=OPOST;CHECK(!tcsetattr(s,TCSANOW,&t));
    struct queued q={c,now()+1000,first_work,{0}};queued_send(&q);
    CHECK(!q.result.prepare_status && q.result.channel_called && q.result.transport.status==DIZZASS_UART_INVALID_INPUT && !q.result.transport.written);
    CHECK(state(c).stopped && state(c).has_result);
    q.work=!q.work;queued_send(&q);CHECK(q.result.transport.status==DIZZASS_UART_CANCELED && !q.result.transport.written);none(m);
    struct termios after;CHECK(!tcgetattr(s,&after) && (after.c_oflag&OPOST));dispose(&c,m,s);++cases;
}
int main(void)
{
    alarm(40);basic_commands();mixed_frames(0);mixed_frames(3);queue_deadline_stop();shared_fault(false);shared_fault(true);alarm(0);
    printf("PROTOCOL_TX_PTY_PASS cases=%u physical_uart=0 real_pthreads=1\n",cases);return 0;
}
