/* GPL-3.0-or-later. Real native staged waits; no work/network/ASIC simulator. */
#define R12_CALLBACK_EMBED
#define __wrap_pthread_cond_timedwait r12_wait_wrapper
#include "integration/review/queue_callback/test.c"
#undef __wrap_pthread_cond_timedwait

static unsigned n13_cases;
static _Atomic unsigned n13_checks, waits[4], scan_calls;
static _Thread_local unsigned wait_role;
static pthread_mutex_t barrier_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t barrier_cond=PTHREAD_COND_INITIALIZER;
static bool hold_wait, wait_entered, release_wait;
#define C13(x) do { atomic_fetch_add(&n13_checks,1); if(!(x)) { fprintf(stderr,"R13_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)

/* The production condition wait still releases/reacquires the REAL staged
 * mutex. This hook only exposes its pre-wait boundary for controlled races. */
int __wrap_pthread_cond_timedwait(pthread_cond_t *c,pthread_mutex_t *m,const struct timespec *t)
{
    if(getq && c==&getq->cond) {
        C13(m==stgd_lock && wait_role<4);
        atomic_fetch_add(&waits[wait_role],1);
        C13(pthread_mutex_lock(&barrier_lock)==0);
        if(hold_wait) {
            wait_entered=true;C13(pthread_cond_broadcast(&barrier_cond)==0);
            while(!release_wait)C13(pthread_cond_wait(&barrier_cond,&barrier_lock)==0);
        }
        C13(pthread_mutex_unlock(&barrier_lock)==0);
    }
    return __real_pthread_cond_timedwait(c,m,t);
}
static void tick13(void) { struct timespec t={0,1000000};nanosleep(&t,NULL); }
static void until13(_Atomic unsigned *p,unsigned n)
{
    uint64_t end=r01_now()+2000;
    while(atomic_load(p)<n){C13(r01_now()<end);tick13();}
}
struct worker13 { struct thr_info *thr; unsigned role,mode; _Atomic unsigned done; struct work *got; };
static void *work13(void *p)
{
    struct worker13 *w=p;wait_role=w->role;
    if(w->mode==1)hash_queued_work(w->thr);
    else if(w->mode==2)w->got=get_work(w->thr,w->thr->id);
    else fill_queue(w->thr,w->thr->cgpu,w->thr->cgpu->drv,w->thr->id);
    atomic_store(&w->done,1);return NULL;
}
static int64_t unexpected_scan13(struct thr_info *t)
{ (void)t;atomic_fetch_add(&scan_calls,1);return -1; }
static void reset13(void)
{
    for(unsigned i=0;i<4;++i)atomic_store(&waits[i],0);
    atomic_store(&scan_calls,0);hold_wait=wait_entered=release_wait=false;
}
static void join13(pthread_t t,struct worker13 *w)
{ until13(&w->done,1);C13(pthread_join(t,NULL)==0); }
static void guards13(void)
{
    struct cgpu_info g={0};struct thread_q *q=getq;pthread_mutex_t *lock=stgd_lock;
    C13(cgminer_request_queued_stop(NULL)==EINVAL);C13(cgminer_queued_stopped(NULL));
    getq=NULL;C13(cgminer_request_queued_stop(&g)==EINVAL);C13(!g.queued_stop);getq=q;
    stgd_lock=NULL;C13(cgminer_request_queued_stop(&g)==EINVAL);stgd_lock=lock;
    C13(!cgminer_queued_stopped(&g));C13(cgminer_request_queued_stop(&g)==0);
    C13(cgminer_queued_stopped(&g));C13(cgminer_request_queued_stop(&g)==0);
    C13(!getq->frozen && !staged_work);++n13_cases;
}
static void registration13(void)
{
    struct device_drv drv={.name="R13"};
    struct cgpu_info g={.drv=&drv,.queued_stop=true};int saved_most=most_devices;
    C13(!devices && !total_devices && !new_devices && !hotplug_mode);
    C13(add_cgpu(&g));C13(!cgminer_queued_stopped(&g));
    C13(total_devices==1 && devices[0]==&g);
    C13(cgminer_request_queued_stop(&g)==0 && cgminer_queued_stopped(&g));
    free(devices);devices=NULL;total_devices=0;most_devices=saved_most;++n13_cases;
}
static void prestop13(unsigned mode)
{
    struct env12 v;open12(&v,true);reset13();uint32_t id=0;struct work *u=NULL;
    if(mode==1)id=push12(&v,false,false);if(mode==2)u=stage(&v.q);
    C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);fill12(&v);
    C13(atomic_load(&step_calls)==0 && atomic_load(&get_calls)==0);
    if(mode==1)C13(staged_work && staged_work->id==id);
    if(mode==2)C13(v.q.e.cgpu.unqueued_work==u);
    C13(!atomic_load(&waits[0]));r01_empty(v.q.e.f.peer);close12(&v);++n13_cases;
}
static void starvation13(bool whole_loop)
{
    struct env12 v;open12(&v,true);reset13();v.q.e.drv.scanwork=unexpected_scan13;
    v.q.e.cgpu.deven=DEV_ENABLED;
    struct worker13 w={.thr=&v.q.e.thr,.role=1,.mode=whole_loop?1:0};pthread_t t;
    C13(pthread_create(&t,NULL,work13,&w)==0);until13(&waits[1],1);
    struct dizzass_io_report r;
    C13(dizzass_io_stop(v.q.io,r01_now()+1000,&r)==0 && r.quiescent);
    C13(!atomic_load(&w.done)); /* R12 boundary still holds for IO-only stop. */
    C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);join13(t,&w);
    C13(!atomic_load(&scan_calls) && !atomic_load(&step_calls));
    C13(!v.q.e.thr.getwork && !staged_work && !v.q.e.cgpu.unqueued_work);
    if(whole_loop)C13(v.q.e.cgpu.deven==DEV_DISABLED);
    C13(pthread_mutex_trylock(stgd_lock)==0);C13(pthread_mutex_unlock(stgd_lock)==0);
    r01_empty(v.q.e.f.peer);close12(&v);++n13_cases;
}
struct request13 {struct cgpu_info *g;_Atomic unsigned entered,done;int rc;};
static void *request13(void *p)
{
    struct request13 *r=p;atomic_store(&r->entered,1);
    r->rc=cgminer_request_queued_stop(r->g);atomic_store(&r->done,1);return NULL;
}
static void prewait13(void)
{
    /* 32 schedules, counted as one race regression, not 32 new features. */
    for(unsigned i=0;i<32;++i){
        struct env12 v;open12(&v,true);reset13();hold_wait=true;
        struct worker13 w={.thr=&v.q.e.thr,.role=1};pthread_t t,rt;
        C13(pthread_create(&t,NULL,work13,&w)==0);
        C13(pthread_mutex_lock(&barrier_lock)==0);
        while(!wait_entered)C13(pthread_cond_wait(&barrier_cond,&barrier_lock)==0);
        C13(pthread_mutex_unlock(&barrier_lock)==0);
        struct request13 r={.g=&v.q.e.cgpu};C13(pthread_create(&rt,NULL,request13,&r)==0);
        until13(&r.entered,1);C13(!atomic_load(&r.done));
        C13(pthread_mutex_lock(&barrier_lock)==0);release_wait=true;
        C13(pthread_cond_broadcast(&barrier_cond)==0);C13(pthread_mutex_unlock(&barrier_lock)==0);
        join13(t,&w);C13(pthread_join(rt,NULL)==0 && !r.rc);
        C13(!atomic_load(&step_calls));close12(&v);
    }++n13_cases;
}
static void spurious13(void)
{
    struct env12 v;open12(&v,true);reset13();struct worker13 w={.thr=&v.q.e.thr,.role=1};pthread_t t;
    C13(pthread_create(&t,NULL,work13,&w)==0);until13(&waits[1],1);
    for(unsigned i=0;i<3;++i){mutex_lock(stgd_lock);C13(pthread_cond_broadcast(&getq->cond)==0);mutex_unlock(stgd_lock);until13(&waits[1],i+2);}
    C13(!atomic_load(&w.done) && !atomic_load(&step_calls));
    C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);join13(t,&w);close12(&v);++n13_cases;
}
static void other_device13(bool legacy)
{
    struct env12 v;open12(&v,true);reset13();
    struct cgpu_info other={.drv=&v.q.e.drv};struct thr_info thr={.id=1,.cgpu=&other};rwlock_init(&other.qlock);
    struct worker13 a={.thr=&v.q.e.thr,.role=1},b={.thr=&thr,.role=2,.mode=legacy?2:0};pthread_t ta,tb;
    C13(pthread_create(&ta,NULL,work13,&a)==0);C13(pthread_create(&tb,NULL,work13,&b)==0);
    until13(&waits[1],1);until13(&waits[2],1);
    C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);join13(ta,&a);until13(&waits[2],2);
    C13(!atomic_load(&b.done) && !cgminer_queued_stopped(&other) && !getq->frozen);
    if(legacy){
        /* Even this cgpu's latch MUST NOT change generic get_work's contract. */
        unsigned n=atomic_load(&waits[2]);C13(cgminer_request_queued_stop(&other)==0);until13(&waits[2],n+1);
        C13(!atomic_load(&b.done));uint32_t id=push12(&v,false,false);join13(tb,&b);
        C13(b.got && b.got->id==id && b.got->thr_id==1);free_work(b.got);
    }else{C13(cgminer_request_queued_stop(&other)==0);join13(tb,&b);C13(!b.got);}
    rwlock_destroy(&other.qlock);close12(&v);++n13_cases;
}
static void popped_before_stop13(void)
{
    struct env12 v;open12(&v,true);reset13();uint32_t id=push12(&v,false,false);
    wr_lock(&v.q.e.cgpu.qlock);struct worker13 w={.thr=&v.q.e.thr,.role=1};pthread_t t;
    C13(pthread_create(&t,NULL,work13,&w)==0);
    uint64_t until=r01_now()+2000;bool empty=false;
    while(!empty){mutex_lock(stgd_lock);empty=!HASH_COUNT(staged_work);mutex_unlock(stgd_lock);C13(r01_now()<until);if(!empty)tick13();}
    C13(!atomic_load(&w.done));C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);
    wr_unlock(&v.q.e.cgpu.qlock);join13(t,&w);
    C13(v.q.e.cgpu.unqueued_work && v.q.e.cgpu.unqueued_work->id==id);
    C13(!atomic_load(&step_calls) && !atomic_load(&get_calls));r01_empty(v.q.e.f.peer);
    close12(&v);++n13_cases;
}
static void stale_then_stop13(void)
{
    struct env12 v;open12(&v,true);reset13();int64_t n=total_discarded;push12(&v,true,false);
    struct worker13 w={.thr=&v.q.e.thr,.role=1};pthread_t t;C13(pthread_create(&t,NULL,work13,&w)==0);
    until13(&waits[1],1);C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);join13(t,&w);
    C13(total_discarded==n+1 && !staged_work && !atomic_load(&step_calls));close12(&v);++n13_cases;
}
static void active_tx13(void)
{
    struct env12 v;open12(&v,true);reset13();push12(&v,false,false);r01_hook(R01_HOLD,v.q.e.f.host);
    struct worker13 w={.thr=&v.q.e.thr,.role=1};pthread_t t;C13(pthread_create(&t,NULL,work13,&w)==0);r01_wait_hook();
    C13(cgminer_request_queued_stop(&v.q.e.cgpu)==0);C13(!atomic_load(&w.done));
    C13(dizzass_io_request_stop(v.q.io)==0);r01_release_hook();join13(t,&w);
    C13(atomic_load(&complete_calls)==1 && atomic_load(&step_calls)==1);
    uint8_t data[88];r01_read(v.q.e.f.peer,data,88);close12(&v);++n13_cases;
}
int main(void)
{
    alarm(55);rwlock_init(&devices_lock);mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    getq=tq_new();C13(getq);stgd_lock=&getq->mutex;C13(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    guards13();registration13();for(unsigned i=0;i<3;++i)prestop13(i);
    starvation13(false);starvation13(true);prewait13();spurious13();other_device13(false);other_device13(true);
    popped_before_stop13();stale_then_stop13();active_tx13();
    C13(!staged_work && !staged_rollable);tq_free(getq);getq=NULL;stgd_lock=NULL;
    C13(pthread_cond_destroy(&gws_cond)==0);
    printf("R13_PASS cases=%u checks=%u prewait_schedules=32 core_loop=1 manufactured_work=0 physical_asic=0\n",n13_cases,atomic_load(&n13_checks));return 0;
}
