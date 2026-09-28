/* SPDX-License-Identifier: GPL-3.0-only
 * Real Linux pthread/PTY transfers. No physical UART paths; no scripted I/O. */
#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "integration/native/uart_channel.h"
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <pty.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>
#define CHECK(x) do { if(!(x)){fprintf(stderr,"UART_CHANNEL_PTY_ASSERT %d: %s errno=%d\n",__LINE__,#x,errno);exit(1);} } while(0)
static unsigned cases;
static atomic_int observed_fd;
static atomic_uint shorts, agains;
ssize_t __real_write(int,const void *,size_t);
ssize_t __wrap_write(int fd,const void *data,size_t n)
{
    ssize_t r=__real_write(fd,data,n);int e=errno;
    if(fd==atomic_load(&observed_fd)){
        if(r>0 && (size_t)r<n)atomic_fetch_add(&shorts,1);
        if(r<0 && (e==EAGAIN || e==EWOULDBLOCK))atomic_fetch_add(&agains,1);
    }
    errno=e;return r;
}
static uint64_t now(void){uint64_t t;CHECK(!dizzass_uart_posix_now_ms(&t));return t;}
static void pause_ms(void){struct timespec t={0,1000000};nanosleep(&t,NULL);}
static struct dizzass_uart_channel_state state(struct dizzass_uart_channel *c)
{struct dizzass_uart_channel_state s;CHECK(!dizzass_uart_channel_snapshot(c,&s));return s;}
static void until_busy(struct dizzass_uart_channel *c)
{uint64_t end=now()+4000;while((!state(c).active || !atomic_load(&agains)) && now()<end)pause_ms();CHECK(state(c).active && atomic_load(&agains)>0);}
static void until_stopped(struct dizzass_uart_channel *c)
{uint64_t end=now()+4000;while(!state(c).stopped && now()<end)pause_ms();CHECK(state(c).stopped);}
static void until_waiting(struct dizzass_uart_channel *c)
{uint64_t end=now()+4000;while(!state(c).waiting && now()<end)pause_ms();CHECK(state(c).waiting>0);}
static struct dizzass_uart_channel *pair(int *m,int *s)
{
    CHECK(!openpty(m,s,NULL,NULL,NULL));struct termios t;CHECK(!tcgetattr(*s,&t));cfmakeraw(&t);CHECK(!tcsetattr(*s,TCSANOW,&t));
    CHECK(!fcntl(*m,F_SETFL,fcntl(*m,F_GETFL)|O_NONBLOCK));CHECK(!fcntl(*s,F_SETFL,fcntl(*s,F_GETFL)|O_NONBLOCK));
    struct dizzass_uart_channel *c=NULL;CHECK(!dizzass_uart_channel_create(&c,*s));
    atomic_store(&observed_fd,*s);atomic_store(&shorts,0);atomic_store(&agains,0);return c;
}
static void dispose(struct dizzass_uart_channel **c,int m,int s)
{CHECK(!dizzass_uart_channel_stop(*c,0));CHECK(!dizzass_uart_channel_destroy(c));CHECK(fcntl(s,F_GETFL)>=0);atomic_store(&observed_fd,-1);CHECK(!close(s) && !close(m));}
static void none(int fd)
{struct pollfd p={fd,POLLIN,0};CHECK(poll(&p,1,15)==0);}
static void collect(int fd,uint8_t *data,size_t length)
{
    size_t got=0;uint64_t end=now()+5000;
    while(got<length && now()<end){ssize_t n=read(fd,data+got,length-got);if(n>0){got+=(size_t)n;continue;}CHECK(n<0 && (errno==EAGAIN || errno==EINTR));struct pollfd p={fd,POLLIN,0};int r=poll(&p,1,10);CHECK(r>=0 || errno==EINTR);}
    CHECK(got==length);
}
struct writer {struct dizzass_uart_channel *c;uint8_t *data;size_t length;uint64_t deadline;pthread_barrier_t *barrier;struct dizzass_uart_result r;bool cancel_point;};
static void *send_frame(void *arg)
{struct writer *w=arg;if(w->barrier){int e=pthread_barrier_wait(w->barrier);CHECK(!e || e==PTHREAD_BARRIER_SERIAL_THREAD);}w->r=dizzass_uart_channel_send(w->c,w->data,w->length,w->deadline,10000);if(w->cancel_point)pthread_testcancel();return NULL;}
struct stopping {struct dizzass_uart_channel *c;int result;uint64_t deadline;};
static void *stop_frame(void *arg){struct stopping *s=arg;s->result=dizzass_uart_channel_stop(s->c,s->deadline);return NULL;}
static pthread_t launch(void *(*fn)(void *),void *p){pthread_t t;CHECK(!pthread_create(&t,NULL,fn,p));return t;}
static void join(pthread_t t){void *v;CHECK(!pthread_join(t,&v) && v==NULL);}
static void fill(uint8_t *p,size_t length,unsigned id){for(size_t j=0;j<length;++j)p[j]=(uint8_t)((j*13u+(j>>8u)*7u)^id);}
static void serialized_frames(void)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);enum{N=4};size_t length=262144,total=N*length;
    uint8_t *frames=malloc(total),*received=malloc(total);CHECK(frames && received);
    pthread_barrier_t barrier;CHECK(!pthread_barrier_init(&barrier,NULL,N+1));struct writer w[N];pthread_t ts[N];
    for(unsigned i=0;i<N;++i){fill(frames+i*length,length,i+1);w[i]=(struct writer){.c=c,.data=frames+i*length,.length=length,.deadline=now()+10000,.barrier=&barrier};ts[i]=launch(send_frame,&w[i]);}
    int e=pthread_barrier_wait(&barrier);CHECK(!e || e==PTHREAD_BARRIER_SERIAL_THREAD);collect(m,received,total);
    for(unsigned i=0;i<N;++i){join(ts[i]);CHECK(w[i].r.status==DIZZASS_UART_OK && w[i].r.written==length);}
    unsigned seen=0;for(unsigned i=0;i<N;++i){unsigned id=received[i*length];CHECK(id>=1 && id<=N && !(seen&(1u<<id)));seen|=1u<<id;CHECK(!memcmp(received+i*length,frames+(id-1)*length,length));}
    CHECK(atomic_load(&shorts)>0);none(m);CHECK(!pthread_barrier_destroy(&barrier));printf("UART_CHANNEL_PTY_SERIAL bytes=%zu complete_frames=%d\n",total,N);free(frames);free(received);dispose(&c,m,s);++cases;
}
static void graceful_finish(void)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);size_t length=524288;uint8_t *data=malloc(length),*got=malloc(length);CHECK(data && got);fill(data,length,11);
    struct writer w={.c=c,.data=data,.length=length,.deadline=now()+8000};pthread_t tw=launch(send_frame,&w);until_busy(c);
    struct writer q=w;pthread_t tq=launch(send_frame,&q);until_waiting(c);
    struct stopping stop={c,-1,now()+8000};pthread_t st=launch(stop_frame,&stop);until_stopped(c);
    join(tq);CHECK(q.r.status==DIZZASS_UART_CANCELED && !q.r.written);
    collect(m,got,length);join(tw);join(st);CHECK(!stop.result && w.r.status==DIZZASS_UART_OK && w.r.written==length);CHECK(!memcmp(data,got,length));none(m);
    struct dizzass_uart_channel_state a=state(c);CHECK(a.stopped && !a.active && a.last.written==length);
    printf("UART_CHANNEL_PTY_GRACEFUL bytes=%zu queued_rejected=1\n",length);free(data);free(got);dispose(&c,m,s);++cases;
}
static void timeout_and_reuse(bool cancel)
{
    int m,s;struct dizzass_uart_channel *c=pair(&m,&s);size_t length=1048576;uint8_t *data=malloc(length),*got=malloc(length);CHECK(data && got);fill(data,length,37);
    struct writer w={.c=c,.data=data,.length=length,.deadline=now()+600,.cancel_point=cancel};pthread_t tw=launch(send_frame,&w);until_busy(c);
    struct writer q=w;q.cancel_point=false;pthread_t tq=launch(send_frame,&q);until_waiting(c);
    CHECK(dizzass_uart_channel_stop(c,now())==ETIMEDOUT);CHECK(fcntl(s,F_GETFL)>=0 && state(c).active);
    if(cancel)CHECK(!pthread_cancel(tw));
    join(tq);CHECK(q.r.status==DIZZASS_UART_CANCELED && !q.r.written);
    if(cancel){void *v;CHECK(!pthread_join(tw,&v) && v==PTHREAD_CANCELED);}else join(tw);
    CHECK(!dizzass_uart_channel_stop(c,0));struct dizzass_uart_channel_state a=state(c);
    CHECK(a.has_result && !a.active && a.last.status==DIZZASS_UART_TIMEOUT && a.last.error==ETIMEDOUT && a.last.written>0 && a.last.written<length);
    collect(m,got,a.last.written);CHECK(!memcmp(data,got,a.last.written));none(m);
    /* Quiescent stopped gate cannot touch a descriptor NUMBER reused later. */
    int m2,s2;CHECK(!openpty(&m2,&s2,NULL,NULL,NULL));CHECK(!close(s));CHECK(dup2(s2,s)==s);CHECK(!close(s2));
    struct dizzass_uart_result r=dizzass_uart_channel_send(c,data,16,now()+1000,12);CHECK(r.status==DIZZASS_UART_CANCELED && !r.written);none(m2);
    CHECK(!dizzass_uart_channel_destroy(&c));CHECK(fcntl(s,F_GETFL)>=0);CHECK(!close(s) && !close(m2) && !close(m));atomic_store(&observed_fd,-1);
    printf("UART_CHANNEL_PTY_STOP prefix=%zu canceled_owner=%d fd_reuse_no_io=1\n",a.last.written,cancel);free(data);free(got);++cases;
}
static void independent_gates(void)
{
    int a,b,x,y;struct dizzass_uart_channel *one=pair(&a,&b),*two=pair(&x,&y);CHECK(!dizzass_uart_channel_stop(one,0));uint8_t p[16],got[16];fill(p,16,99);
    struct dizzass_uart_result r=dizzass_uart_channel_send(two,p,16,now()+1000,10);CHECK(r.status==DIZZASS_UART_OK && r.written==16);collect(x,got,16);CHECK(!memcmp(p,got,16));none(a);dispose(&one,a,b);dispose(&two,x,y);++cases;
}
int main(void){alarm(30);serialized_frames();graceful_finish();timeout_and_reuse(false);timeout_and_reuse(true);independent_gates();alarm(0);printf("UART_CHANNEL_PTY_PASS cases=%u real_pthreads=1 physical_uart=0\n",cases);return 0;}
