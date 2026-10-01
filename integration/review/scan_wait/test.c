/* GPL-3.0-or-later. Real native loop, managed I/O and paced scanwork callbacks. */
#define R12_CALLBACK_EMBED
#define __wrap_pthread_cond_timedwait inherited_wait17
#include "integration/review/queue_callback/test.c"
#undef __wrap_pthread_cond_timedwait
#include "integration/native/scan_wait.h"
#include "integration/native/native_io_stop.h"
#include <limits.h>

static unsigned cases17;
static _Atomic unsigned checks17, wait_entries17, broadcasts17, sem_entries17, enables17;
#define C17(x) do { atomic_fetch_add(&checks17,1); if (!(x)) { fprintf(stderr,"R17_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while (0)
static struct dizzass_scan_wait *watch17;
static pthread_mutex_t gate17=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t gate_cond17=PTHREAD_COND_INITIALIZER;
static bool hold17, entered17, release17;
static unsigned spurious17;
static int wait_error17;
static uint64_t deadline_call17;
static struct timespec first_deadline17;

int __real_pthread_cond_broadcast(pthread_cond_t *);
int __wrap_pthread_cond_broadcast(pthread_cond_t *c)
{
    if (watch17 && c==&watch17->cond) atomic_fetch_add(&broadcasts17,1);
    return __real_pthread_cond_broadcast(c);
}
int __wrap_pthread_cond_timedwait(pthread_cond_t *c,pthread_mutex_t *m,const struct timespec *d)
{
    if (!watch17 || c!=&watch17->cond) return inherited_wait17(c,m,d);
    C17(m==&watch17->lock);
    int saved;C17(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0);
    C17(saved==PTHREAD_CANCEL_DISABLE);
    if (deadline_call17!=watch17->report.calls) {
        deadline_call17=watch17->report.calls;first_deadline17=*d;
    } else C17(d->tv_sec==first_deadline17.tv_sec && d->tv_nsec==first_deadline17.tv_nsec);
    atomic_fetch_add(&wait_entries17,1);
    C17(pthread_mutex_lock(&gate17)==0);entered17=true;
    C17(pthread_cond_broadcast(&gate_cond17)==0);
    while (hold17 && !release17) C17(pthread_cond_wait(&gate_cond17,&gate17)==0);
    C17(pthread_mutex_unlock(&gate17)==0);
    if (wait_error17) return wait_error17; /* Fault with mutex still held. */
    if (spurious17) { --spurious17;return 0; } /* Permitted spurious return. */
    return __real_pthread_cond_timedwait(c,m,d); /* Actual kernel wait. */
}
void __real__cgsem_wait(cgsem_t *,const char *,const char *,const int);
void __wrap__cgsem_wait(cgsem_t *s,const char *file,const char *fn,const int line)
{
    if (watch17 && s==&watch17->thr->sem) atomic_fetch_add(&sem_entries17,1);
    __real__cgsem_wait(s,file,fn,line);
}
static void no_enable17(struct thr_info *t) { (void)t;atomic_fetch_add(&enables17,1); }
static void no_update17(struct cgpu_info *g) { (void)g; }
struct env17 {struct env12 native;struct dizzass_scan_wait scan;struct thr_info *published[1];};
static struct cgpu_info *gpu17(struct env17 *e) {return &e->native.q.e.cgpu;}
static struct thr_info *thr17(struct env17 *e) {return &e->native.q.e.thr;}
static struct dizzass_scan_report report17(struct env17 *e)
{struct dizzass_scan_report r;C17(dizzass_scan_wait_snapshot(&e->scan,&r)==0);return r;}
static void open17(struct env17 *e,unsigned interval,bool start)
{
    memset(e,0,sizeof *e);open12(&e->native,start);
    struct cgpu_info *g=gpu17(e);struct thr_info *t=thr17(e);
    e->published[0]=t;g->thr=e->published;g->threads=1;g->deven=DEV_ENABLED;
    cgsem_init(&t->sem);t->pause=false;t->work_update=false;
    C17(dizzass_scan_wait_init(&e->scan,t,e->native.q.io,interval)==0);
    t->cgpu_data=&e->scan;
    g->drv->scanwork=dizzass_scanwork;g->drv->queued_stop_wake=dizzass_scan_stop_wake;
    g->drv->thread_enable=no_enable17;g->drv->update_work=no_update17;
    watch17=&e->scan;hold17=entered17=release17=false;spurious17=0;wait_error17=0;deadline_call17=0;
    atomic_store(&wait_entries17,0);atomic_store(&broadcasts17,0);
    atomic_store(&sem_entries17,0);atomic_store(&enables17,0);
}
static void close17(struct env17 *e)
{
    /* Every native scan/queue/controller thread has been joined first. */
    C17(dizzass_scan_wait_destroy(&e->scan)==0);watch17=NULL;
    thr17(e)->cgpu_data=NULL;gpu17(e)->thr=NULL;gpu17(e)->threads=0;
    cgsem_destroy(&thr17(e)->sem);close12(&e->native);
}
static void tick17(void) {struct timespec t={0,1000000};nanosleep(&t,NULL);}
static void until17(_Atomic unsigned *p,unsigned n)
{uint64_t end=r01_now()+3000;while(atomic_load(p)<n){C17(r01_now()<end);tick17();}}
struct worker17 {struct thr_info *thr;bool native;int64_t result;_Atomic unsigned done;};
static void *worker17(void *arg)
{
    struct worker17 *w=arg;
    if (w->native) hash_queued_work(w->thr); else w->result=dizzass_scanwork(w->thr);
    atomic_store(&w->done,1);pthread_testcancel();return NULL;
}
static void join17(pthread_t p,struct worker17 *w)
{until17(&w->done,1);C17(pthread_join(p,NULL)==0);}
static void wait_active17(struct env17 *e)
{uint64_t end=r01_now()+3000;while(!report17(e).waiting){C17(r01_now()<end);tick17();}}
static void stop17(struct env17 *e)
{
    struct dizzass_native_io_stop_report r;struct dizzass_io_lifecycle *v[]={e->native.q.io};
    C17(dizzass_native_io_stop(gpu17(e),v,1,r01_now()+2000,&r)==0);
    C17(r.sequence_complete && !r.native_status && r.io.all_quiescent);
}
static void guards17(void)
{
    struct env17 e;open17(&e,20,true);struct dizzass_scan_wait unused={0};
    C17(dizzass_scan_wait_init(NULL,thr17(&e),e.native.q.io,20)==EINVAL);
    C17(dizzass_scan_wait_init(&unused,NULL,e.native.q.io,20)==EINVAL);
    C17(dizzass_scan_wait_init(&unused,thr17(&e),NULL,20)==EINVAL);
    C17(dizzass_scan_wait_init(&unused,thr17(&e),e.native.q.io,0)==EINVAL);
    C17(dizzass_scan_wait_init(&unused,thr17(&e),e.native.q.io,1001)==EINVAL);
    struct dizzass_scan_report r;C17(dizzass_scan_wait_snapshot(&unused,&r)==EINVAL);
    C17(dizzass_scan_wait_snapshot(&e.scan,NULL)==EINVAL);
    C17(dizzass_scan_wait_destroy(&unused)==EINVAL);
    C17(!unused.initialized && !report17(&e).calls);close17(&e);++cases17;
}
static void binding17(void)
{
    struct env17 e;open17(&e,20,true);struct thr_info *t=thr17(&e);struct cgpu_info *g=gpu17(&e);
    C17(dizzass_scanwork(NULL)==-1 && dizzass_scan_stop_wake(NULL)==EINVAL);
    t->cgpu_data=NULL;C17(dizzass_scanwork(t)==-1 && dizzass_scan_stop_wake(g)==EINVAL);t->cgpu_data=&e.scan;
    g->threads=2;C17(dizzass_scanwork(t)==-1 && dizzass_scan_stop_wake(g)==EINVAL);g->threads=1;
    e.published[0]=NULL;C17(dizzass_scanwork(t)==-1 && dizzass_scan_stop_wake(g)==EINVAL);e.published[0]=t;
    e.scan.thr=NULL;C17(dizzass_scanwork(t)==-1);e.scan.thr=t;
    g->drv->queued_stop_wake=NULL;C17(dizzass_scanwork(t)==-1);g->drv->queued_stop_wake=dizzass_scan_stop_wake;
    C17(!report17(&e).calls && !atomic_load(&wait_entries17));close17(&e);++cases17;
}
static void period17(unsigned ms)
{
    struct env17 e;open17(&e,ms,true);uint64_t start=r01_now();
    int64_t hashes=dizzass_scanwork(thr17(&e));uint64_t elapsed=r01_now()-start;
    struct dizzass_scan_report r=report17(&e);
    C17(hashes==0 && r.reason==DIZZASS_SCAN_TICK && r.ticks==1);
    C17(r.wait_calls>=1 && elapsed+2>=ms && !r.active && !r.waiting && !r.failures);
    C17(!atomic_load(&get_calls) && !atomic_load(&complete_calls));close17(&e);++cases17;
}
static void prestop17(bool native)
{
    struct env17 e;open17(&e,1000,true);
    C17((native?cgminer_request_queued_stop(gpu17(&e)):dizzass_scan_stop_wake(gpu17(&e)))==0);
    C17(dizzass_scanwork(thr17(&e))==0);struct dizzass_scan_report r=report17(&e);
    C17(r.reason==DIZZASS_SCAN_STOP && r.stops==1 && !r.wait_calls && !r.ticks);
    for(unsigned i=0;i<4;++i)C17(dizzass_scan_stop_wake(gpu17(&e))==0);
    C17(report17(&e).wake_requests==5);close17(&e);++cases17;
}
static void spurious_case17(void)
{
    struct env17 e;open17(&e,30,true);spurious17=8;uint64_t start=r01_now();
    C17(dizzass_scanwork(thr17(&e))==0);struct dizzass_scan_report r=report17(&e);
    C17(!spurious17 && r.wait_calls==9 && r.ticks==1 && r01_now()-start+2>=30);
    close17(&e);++cases17;
}
static void stop_wait17(bool cancel,bool busy)
{
    struct env17 e;open17(&e,1000,true);struct worker17 w={.thr=thr17(&e)};pthread_t p;
    C17(pthread_create(&p,NULL,worker17,&w)==0);wait_active17(&e);
    if(busy){C17(dizzass_scan_wait_destroy(&e.scan)==EBUSY);C17(dizzass_scanwork(thr17(&e))==-1);C17(report17(&e).active);}
    if(cancel)C17(pthread_cancel(p)==0);
    unsigned old=atomic_load(&broadcasts17);C17(cgminer_request_queued_stop(gpu17(&e))==0);
    C17(atomic_load(&broadcasts17)>old);
    if(cancel){void *result;C17(pthread_join(p,&result)==0 && result==PTHREAD_CANCELED);}
    else join17(p,&w);
    struct dizzass_scan_report r=report17(&e);
    C17(!r.active && !r.waiting && r.reason==DIZZASS_SCAN_STOP && r.stops==1 && !r.ticks);
    close17(&e);++cases17;
}
struct request17 {struct cgpu_info *g;int result;_Atomic unsigned done;};
static void *request17(void *arg)
{struct request17 *r=arg;r->result=cgminer_request_queued_stop(r->g);atomic_store(&r->done,1);return NULL;}
static void prewait17(void)
{
    for(unsigned i=0;i<16;++i){struct env17 e;open17(&e,1000,true);hold17=true;
        struct worker17 w={.thr=thr17(&e)};pthread_t p,q;C17(pthread_create(&p,NULL,worker17,&w)==0);
        C17(pthread_mutex_lock(&gate17)==0);while(!entered17)C17(pthread_cond_wait(&gate_cond17,&gate17)==0);
        C17(pthread_mutex_unlock(&gate17)==0);
        struct request17 r={.g=gpu17(&e)};C17(pthread_create(&q,NULL,request17,&r)==0);
        uint64_t end=r01_now()+2000;while(!cgminer_queued_stopped(gpu17(&e))){C17(r01_now()<end);tick17();}
        C17(!atomic_load(&r.done)); /* Wake waits for the scan mutex, not lost. */
        C17(pthread_mutex_lock(&gate17)==0);release17=true;C17(pthread_cond_broadcast(&gate_cond17)==0);C17(pthread_mutex_unlock(&gate17)==0);
        C17(pthread_join(q,NULL)==0 && !r.result);join17(p,&w);
        C17(report17(&e).reason==DIZZASS_SCAN_STOP && report17(&e).stops==1);close17(&e);
    }++cases17;
}
static void io_failure17(unsigned mode)
{
    struct env17 e;open17(&e,25,mode!=0);
    if(mode==1)C17(dizzass_io_request_stop(e.native.q.io)==0);
    if(mode==2){atomic_store(&fail_read,EIO);uint8_t noise=1;peer_write(&e.native.q.e,&noise,1);
        struct dizzass_io_report s;uint64_t end=r01_now()+2000;
        do{C17(dizzass_io_snapshot(e.native.q.io,&s)==0);C17(r01_now()<end);tick17();}while(!s.rx_finished);}
    struct worker17 w={.thr=thr17(&e)};pthread_t p;
    if(mode==3){C17(pthread_create(&p,NULL,worker17,&w)==0);wait_active17(&e);C17(dizzass_io_request_stop(e.native.q.io)==0);join17(p,&w);}
    else w.result=dizzass_scanwork(thr17(&e));
    struct dizzass_scan_report r=report17(&e);
    C17(w.result==-1 && r.reason==DIZZASS_SCAN_IO_FAILURE && r.failures==1);
    C17(r.status==(mode==0?ENOTCONN:ECANCELED) && !r.active);close17(&e);++cases17;
}
static void wait_failure17(void)
{
    struct env17 e;open17(&e,20,true);wait_error17=EIO;
    C17(dizzass_scanwork(thr17(&e))==-1);struct dizzass_scan_report r=report17(&e);
    C17(r.reason==DIZZASS_SCAN_WAIT_FAILURE && r.status==EIO && !r.active && !r.waiting);
    close17(&e);++cases17;
}
static void native_loop17(void)
{
    struct env17 e;open17(&e,40,true);uint32_t ids[33];
    for(unsigned i=0;i<33;++i)ids[i]=push12(&e.native,false,false);
    struct worker17 w={.thr=thr17(&e),.native=true};pthread_t p;
    C17(pthread_create(&p,NULL,worker17,&w)==0);
    uint64_t end=r01_now()+3000;while(report17(&e).calls<3){C17(r01_now()<end);tick17();}
    peer_write(&e.native.q.e,r08_nonce[0],11);wait_events(&e.native.q.e,2);
    stop17(&e);join17(p,&w);struct dizzass_scan_report r=report17(&e);
    C17(r.ticks>=2 && !r.active && r.stop_requested);
    C17(atomic_load(&get_calls)==32 && atomic_load(&complete_calls)==32);
    C17(gpu17(&e)->unqueued_work && gpu17(&e)->unqueued_work->id==ids[32] && !gpu17(&e)->queued_count);
    for(unsigned i=0;i<32;++i){uint8_t b[88],expected[88];r01_read(e.native.q.e.f.peer,b,88);
        C17(dizzass_native_work_tx88(e.native.q.e.source,2,0,i,expected,88)==0 && !memcmp(b,expected,88));}
    C17(e.native.q.e.events[1].integrity_verified && e.native.q.e.events[1].submission.native_called);
    C17(e.native.q.e.events[1].submission.captured.serial==seen_steps[0].queued.send.send.ticket.serial);
    take_genesis(&e.native.q.e);C17(!atomic_load(&enables17));close17(&e);++cases17;
}
static void starved17(void)
{
    struct env17 e;open17(&e,20,true);struct worker17 w={.thr=thr17(&e),.native=true};pthread_t p;
    upstream_waiting=false;C17(pthread_create(&p,NULL,worker17,&w)==0);
    C17(pthread_mutex_lock(&wait_lock)==0);while(!upstream_waiting)C17(pthread_cond_wait(&wait_cond,&wait_lock)==0);
    C17(pthread_mutex_unlock(&wait_lock)==0);stop17(&e);join17(p,&w);
    C17(!report17(&e).calls && !atomic_load(&get_calls));close17(&e);++cases17;
}
static void paused17(void)
{
    struct env17 e;open17(&e,10,true);fill_remaining_slots(&e.native);push12(&e.native,false,false);thr17(&e)->pause=true;
    struct worker17 w={.thr=thr17(&e),.native=true};pthread_t p;C17(pthread_create(&p,NULL,worker17,&w)==0);
    until17(&sem_entries17,1);stop17(&e);join17(p,&w);
    C17(!atomic_load(&enables17) && report17(&e).ticks==1);
    uint8_t bytes[88];r01_read(e.native.q.e.f.peer,bytes,88);close17(&e);++cases17;
}
int main(void)
{
    void (*volatile keep_fill)(struct thr_info *,struct cgpu_info *,struct device_drv *,const int)=fill_queue;C17(keep_fill);
    alarm(55);rwlock_init(&devices_lock);mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    getq=tq_new();C17(getq);stgd_lock=&getq->mutex;C17(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;opt_log_interval=INT_MAX;
    guards17();binding17();period17(5);period17(20);period17(80);prestop17(false);prestop17(true);spurious_case17();
    stop_wait17(false,false);stop_wait17(true,false);stop_wait17(false,true);prewait17();
    for(unsigned i=0;i<4;++i)io_failure17(i);wait_failure17();native_loop17();starved17();paused17();
    C17(cases17==20 && !staged_work && !staged_rollable);tq_free(getq);getq=NULL;stgd_lock=NULL;C17(pthread_cond_destroy(&gws_cond)==0);
    printf("R17_PASS cases=%u checks=%u real_native_loop=1 wait_hashes=0 physical_asic=0\n",cases17,atomic_load(&checks17));return 0;
}
