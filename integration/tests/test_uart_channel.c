/* SPDX-License-Identifier: GPL-3.0-only
 * Actual pthread synchronization, controlled WHOLE A-13 call. No OS UART I/O. */
#define _POSIX_C_SOURCE 200809L
#include "integration/native/uart_channel.h"
#include <errno.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr,"UART_CHANNEL_ASSERT %d: %s\n",__LINE__,#x); exit(1); } } while(0)
static unsigned cases;
static pthread_mutex_t fm = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t fc = PTHREAD_COND_INITIALIZER;
static bool blocked, entered, released;
static unsigned calls, concurrent, maximum;
static struct dizzass_uart_result scripted;
static int expected_fd;
static const uint8_t *expected_data;
static size_t expected_length;
static unsigned expected_budget;
static uint64_t expected_deadline;
static _Thread_local int clock_error;
static atomic_int cond_failure, wait_failure, spurious;
int __real_dizzass_uart_posix_now_ms(uint64_t *);
int __real_pthread_condattr_setclock(pthread_condattr_t *, clockid_t);
int __real_pthread_cond_init(pthread_cond_t *, const pthread_condattr_t *);
int __real_pthread_cond_timedwait(pthread_cond_t *, pthread_mutex_t *, const struct timespec *);
int __wrap_dizzass_uart_posix_now_ms(uint64_t *out)
{ return clock_error ? clock_error : __real_dizzass_uart_posix_now_ms(out); }
int __wrap_pthread_condattr_setclock(pthread_condattr_t *a, clockid_t k)
{ CHECK(k == CLOCK_MONOTONIC); return __real_pthread_condattr_setclock(a,k); }
int __wrap_pthread_cond_init(pthread_cond_t *c, const pthread_condattr_t *a)
{ return atomic_load(&cond_failure) ? EAGAIN : __real_pthread_cond_init(c,a); }
int __wrap_pthread_cond_timedwait(pthread_cond_t *c, pthread_mutex_t *m, const struct timespec *t)
{
    if (atomic_exchange(&wait_failure,0)) return EINVAL;
    if (atomic_load(&spurious)>0) { atomic_fetch_sub(&spurious,1); return 0; }
    return __real_pthread_cond_timedwait(c,m,t);
}
static uint64_t now(void) { uint64_t v; CHECK(__real_dizzass_uart_posix_now_ms(&v)==0); return v; }
struct dizzass_uart_result __wrap_dizzass_uart_posix_write_all(int fd,
    const uint8_t *data,size_t length,uint64_t deadline,unsigned budget)
{
    int previous; CHECK(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&previous)==0);
    CHECK(previous==PTHREAD_CANCEL_DISABLE); /* Ownership cannot be canceled. */
    CHECK(pthread_mutex_lock(&fm)==0);
    CHECK(fd==expected_fd && length==expected_length && budget==expected_budget);
    CHECK(!expected_data || data==expected_data);
    CHECK(!expected_deadline || deadline==expected_deadline);
    ++calls; ++concurrent; if(concurrent>maximum) maximum=concurrent;
    CHECK(maximum==1);
    entered=true; CHECK(pthread_cond_broadcast(&fc)==0);
    while(blocked && !released) CHECK(pthread_cond_wait(&fc,&fm)==0);
    struct dizzass_uart_result r=scripted;
    --concurrent; CHECK(pthread_mutex_unlock(&fm)==0);
    CHECK(pthread_setcancelstate(previous,NULL)==0);
    return r;
}
static void setup(bool hold,enum dizzass_uart_status s,size_t n,int e)
{
    blocked=hold;entered=released=false;calls=concurrent=maximum=0;
    scripted=(struct dizzass_uart_result){s,n,e};expected_fd=73;
    expected_data=NULL;expected_length=16;expected_budget=321;expected_deadline=0;
    atomic_store(&cond_failure,0);atomic_store(&wait_failure,0);atomic_store(&spurious,0);
}
static void wait_entered(void)
{ CHECK(pthread_mutex_lock(&fm)==0);while(!entered) CHECK(pthread_cond_wait(&fc,&fm)==0);CHECK(pthread_mutex_unlock(&fm)==0); }
static void release(void)
{ CHECK(pthread_mutex_lock(&fm)==0);released=true;CHECK(pthread_cond_broadcast(&fc)==0);CHECK(pthread_mutex_unlock(&fm)==0); }
static struct dizzass_uart_channel *create(void)
{ struct dizzass_uart_channel *c=NULL;CHECK(dizzass_uart_channel_create(&c,73)==0 && c);return c; }
static struct dizzass_uart_channel_state state(struct dizzass_uart_channel *c)
{ struct dizzass_uart_channel_state s;CHECK(dizzass_uart_channel_snapshot(c,&s)==0);return s; }
static void waiting(struct dizzass_uart_channel *c,size_t n)
{ uint64_t end=now()+3000;while(state(c).waiting<n && now()<end){struct timespec t={0,1000000};nanosleep(&t,NULL);}CHECK(state(c).waiting>=n); }
static void stopped(struct dizzass_uart_channel *c)
{ uint64_t end=now()+3000;while(!state(c).stopped && now()<end){struct timespec t={0,1000000};nanosleep(&t,NULL);}CHECK(state(c).stopped); }
static void dispose(struct dizzass_uart_channel **c)
{ CHECK(dizzass_uart_channel_stop(*c,0)==0);CHECK(dizzass_uart_channel_destroy(c)==0 && !*c); }
static uint8_t bytes[16];
struct task { struct dizzass_uart_channel *c;uint64_t deadline;struct dizzass_uart_result r;int stop_result;bool cancel_point; };
static void *sender(void *p)
{ struct task *t=p;t->r=dizzass_uart_channel_send(t->c,bytes,16,t->deadline,321);if(t->cancel_point)pthread_testcancel();return NULL; }
static void *stopper(void *p)
{ struct task *t=p;t->stop_result=dizzass_uart_channel_stop(t->c,t->deadline);return NULL; }
static pthread_t start(struct task *t,void *(*fn)(void *))
{ pthread_t id;CHECK(pthread_create(&id,NULL,fn,t)==0);return id; }
static void join(pthread_t id) { void *v;CHECK(pthread_join(id,&v)==0 && v==NULL); }
static void same(struct dizzass_uart_result a,struct dizzass_uart_result b)
{ CHECK(a.status==b.status && a.written==b.written && a.error==b.error); }
static void input(void)
{
    setup(false,DIZZASS_UART_OK,16,0);struct dizzass_uart_channel *c=NULL;
    CHECK(dizzass_uart_channel_create(NULL,73)==EINVAL);
    CHECK(dizzass_uart_channel_create(&c,-1)==EINVAL && !c);
    atomic_store(&cond_failure,1);CHECK(dizzass_uart_channel_create(&c,73)==EAGAIN && !c);atomic_store(&cond_failure,0);
    c=create();CHECK(dizzass_uart_channel_create(&c,73)==EINVAL);
    CHECK(dizzass_uart_channel_destroy(&c)==EBUSY);
    CHECK(dizzass_uart_channel_send(NULL,bytes,16,now()+100,321).error==EINVAL);
    CHECK(dizzass_uart_channel_send(c,NULL,1,now()+100,321).error==EINVAL);
    CHECK(dizzass_uart_channel_send(c,bytes,1,now()+100,0).error==EINVAL);
    CHECK(dizzass_uart_channel_send(c,bytes,SIZE_MAX,now()+100,321).error==EOVERFLOW);
    CHECK(dizzass_uart_channel_send(c,NULL,0,0,0).status==DIZZASS_UART_OK);
    CHECK(dizzass_uart_channel_send(c,bytes,16,now(),321).status==DIZZASS_UART_TIMEOUT);
    clock_error=EIO;CHECK(dizzass_uart_channel_send(c,bytes,16,now()+100,321).status==DIZZASS_UART_CLOCK_ERROR);clock_error=0;
    CHECK(!state(c).has_result && !state(c).stopped && !calls);
    CHECK(dizzass_uart_channel_stop(NULL,0)==EINVAL);
    CHECK(dizzass_uart_channel_snapshot(c,NULL)==EINVAL);
    CHECK(dizzass_uart_channel_stop(c,0)==0);
    CHECK(dizzass_uart_channel_send(c,NULL,0,0,0).status==DIZZASS_UART_CANCELED);
    CHECK(!calls);dispose(&c);CHECK(dizzass_uart_channel_destroy(&c)==EINVAL);++cases;
}
static void results(void)
{
    for(int s=DIZZASS_UART_OK;s<=DIZZASS_UART_NO_PROGRESS;++s) for(unsigned p=0;p<3;++p){
        size_t accepted=s==DIZZASS_UART_OK?16:(p==0?0:(p==1?3:16));
        setup(false,(enum dizzass_uart_status)s,accepted,s==DIZZASS_UART_OK?0:EIO);
        struct dizzass_uart_channel *c=create();expected_data=bytes;expected_deadline=now()+2000;
        struct dizzass_uart_result r=dizzass_uart_channel_send(c,bytes,16,expected_deadline,321);
        same(r,scripted);struct dizzass_uart_channel_state a=state(c);
        CHECK(a.has_result && !a.active && a.stopped==(s!=DIZZASS_UART_OK));same(a.last,r);
        if(s!=DIZZASS_UART_OK){CHECK(dizzass_uart_channel_send(c,bytes,16,expected_deadline,321).status==DIZZASS_UART_CANCELED);CHECK(calls==1);same(state(c).last,r);}
        dispose(&c);++cases;
    }
}
static void stop_queue(bool fault)
{
    setup(true,fault?DIZZASS_UART_WRITE_ERROR:DIZZASS_UART_OK,fault?3:16,fault?EIO:0);
    struct dizzass_uart_channel *c=create();struct task a={.c=c,.deadline=now()+4000},b=a;
    pthread_t ta=start(&a,sender);wait_entered();pthread_t tb=start(&b,sender);waiting(c,1);
    if(!fault){CHECK(dizzass_uart_channel_stop(c,now())==ETIMEDOUT);join(tb);CHECK(b.r.status==DIZZASS_UART_CANCELED);CHECK(state(c).active && state(c).stopped);}
    release();join(ta);if(fault)join(tb);
    same(a.r,scripted);CHECK(b.r.status==DIZZASS_UART_CANCELED && b.r.written==0);
    CHECK(calls==1 && !state(c).active);same(state(c).last,a.r);dispose(&c);++cases;
}
static void queue_timeout_and_error(void)
{
    setup(true,DIZZASS_UART_OK,16,0);struct dizzass_uart_channel *c=create();
    struct task a={.c=c,.deadline=now()+4000},b={.c=c,.deadline=now()+50};
    pthread_t ta=start(&a,sender);wait_entered();atomic_store(&spurious,3);
    pthread_t tb=start(&b,sender);join(tb);CHECK(b.r.status==DIZZASS_UART_TIMEOUT && !b.r.written);
    CHECK(!state(c).stopped && !state(c).waiting && state(c).active);
    atomic_store(&wait_failure,1);b.deadline=now()+1000;tb=start(&b,sender);join(tb);
    CHECK(b.r.status==DIZZASS_UART_WAIT_ERROR && b.r.error==EINVAL && !state(c).waiting);
    clock_error=EIO;CHECK(dizzass_uart_channel_stop(c,now()+1000)==EIO);clock_error=0;
    CHECK(state(c).stopped && state(c).active);release();join(ta);CHECK(calls==1);dispose(&c);++cases;
}
static void serialization(void)
{
    setup(true,DIZZASS_UART_OK,16,0);struct dizzass_uart_channel *c=create();
    enum{N=8};struct task tasks[N];pthread_t ts[N];
    expected_deadline=now()+4000;
    for(unsigned i=0;i<N;++i){tasks[i]=(struct task){.c=c,.deadline=expected_deadline};ts[i]=start(&tasks[i],sender);}
    wait_entered();waiting(c,N-1);release();for(unsigned i=0;i<N;++i){join(ts[i]);same(tasks[i].r,scripted);}
    CHECK(calls==N && maximum==1 && !state(c).waiting && !state(c).stopped);dispose(&c);++cases;
}
static void multiple_stoppers(void)
{
    setup(true,DIZZASS_UART_OK,16,0);struct dizzass_uart_channel *c=create();
    struct task a={.c=c,.deadline=now()+4000},s1=a,s2=a;
    pthread_t ta=start(&a,sender);wait_entered();pthread_t t1=start(&s1,stopper),t2=start(&s2,stopper);stopped(c);
    CHECK(dizzass_uart_channel_send(c,bytes,16,a.deadline,321).status==DIZZASS_UART_CANCELED);
    release();join(ta);join(t1);join(t2);CHECK(!s1.stop_result && !s2.stop_result && calls==1);dispose(&c);++cases;
}
static void deferred_cancel(bool owner)
{
    setup(true,DIZZASS_UART_OK,16,0);struct dizzass_uart_channel *c=create();
    struct task a={.c=c,.deadline=now()+4000,.cancel_point=owner},b={.c=c,.deadline=a.deadline,.cancel_point=!owner};
    pthread_t ta=start(&a,sender);wait_entered();pthread_t tb=start(&b,sender);waiting(c,1);
    CHECK(pthread_cancel(owner?ta:tb)==0);CHECK(dizzass_uart_channel_stop(c,now())==ETIMEDOUT);release();
    void *v;CHECK(pthread_join(owner?ta:tb,&v)==0 && v==PTHREAD_CANCELED);join(owner?tb:ta);
    CHECK(calls==1 && state(c).has_result && !state(c).active && !state(c).waiting);same(state(c).last,scripted);
    int prior;CHECK(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&prior)==0);CHECK(prior==PTHREAD_CANCEL_ENABLE);CHECK(pthread_setcancelstate(prior,NULL)==0);
    dispose(&c);++cases;
}
int main(void)
{
    alarm(20);input();results();stop_queue(false);stop_queue(true);queue_timeout_and_error();serialization();multiple_stoppers();deferred_cancel(true);deferred_cancel(false);alarm(0);
    printf("UART_CHANNEL_CONTROL_PASS cases=%u actual_pthreads=1 lower_frame_scripted=1\n",cases);return 0;
}
