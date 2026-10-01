/* GPL-3.0-or-later. Real queued loop/sem waits and a cooperative host driver. */
#define R13_STOP_EMBED
#include "integration/review/queue_stop/test.c"
#include <limits.h>

static unsigned n14_cases;
static _Atomic unsigned n14_checks, sem_seen14[4];
static cgsem_t *watched14[4];
static pthread_mutex_t gate14=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t gatecond14=PTHREAD_COND_INITIALIZER;
static bool hold_sem14, release_sem14, hold_scan14, scan_boundary14, release_scan14;
#define C14(x) do { atomic_fetch_add(&n14_checks,1); if(!(x)) { fprintf(stderr,"R14_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)

void __real__cgsem_wait(cgsem_t *,const char *,const char *,const int);
void __wrap__cgsem_wait(cgsem_t *s,const char *f,const char *fn,const int line)
{
    for(unsigned i=0;i<4;++i)if(s==watched14[i]){
        atomic_fetch_add(&sem_seen14[i],1);
        C14(pthread_mutex_lock(&gate14)==0);
        while(hold_sem14 && !release_sem14)C14(pthread_cond_wait(&gatecond14,&gate14)==0);
        C14(pthread_mutex_unlock(&gate14)==0);
    }
    __real__cgsem_wait(s,f,fn,line);
}
struct state14 {
    pthread_mutex_t lock;
    pthread_cond_t cond;
    bool stopped, release;
    _Atomic unsigned scanning, waiting, completed, woke, enabled, updated, initialized, shutdowns;
    int wake_error;
    bool stop_on_enable;
};
struct env14 {struct env12 native;struct thr_info *published[4];struct state14 driver;};
static struct state14 *state14(struct cgpu_info *g)
{return g->thr[0]->cgpu_data;}
static int wake14(struct cgpu_info *g)
{
    struct state14 *s=state14(g);
    C14(cgminer_queued_stopped(g));
    /* Failure here catches calling a driver while holding the native mutex. */
    C14(pthread_mutex_trylock(stgd_lock)==0);C14(pthread_mutex_unlock(stgd_lock)==0);
    atomic_fetch_add(&s->woke,1);
    if(s->wake_error)return s->wake_error;
    C14(pthread_mutex_lock(&s->lock)==0);s->stopped=true;
    C14(pthread_cond_broadcast(&s->cond)==0);C14(pthread_mutex_unlock(&s->lock)==0);
    return 0;
}
static int64_t scan14(struct thr_info *t)
{
    struct state14 *s=t->cgpu_data;atomic_fetch_add(&s->scanning,1);
    C14(pthread_mutex_lock(&s->lock)==0);
    while(!s->stopped && !s->release){
        C14(pthread_mutex_lock(&gate14)==0);
        if(hold_scan14){scan_boundary14=true;C14(pthread_cond_broadcast(&gatecond14)==0);
            while(!release_scan14)C14(pthread_cond_wait(&gatecond14,&gate14)==0);}
        C14(pthread_mutex_unlock(&gate14)==0);
        atomic_fetch_add(&s->waiting,1);
        C14(pthread_cond_wait(&s->cond,&s->lock)==0);
    }
    C14(pthread_mutex_unlock(&s->lock)==0);atomic_fetch_add(&s->completed,1);
    return 0; /* No fabricated hashes from waiting. */
}
static void enable14(struct thr_info *t)
{
    struct state14 *s=t->cgpu_data;atomic_fetch_add(&s->enabled,1);
    if(s->stop_on_enable)C14(cgminer_request_queued_stop(t->cgpu)==0);
}
static void update14(struct cgpu_info *g)
{atomic_fetch_add(&state14(g)->updated,1);C14(cgminer_request_queued_stop(g)==0);}
static bool init14(struct thr_info *t)
{atomic_fetch_add(&((struct state14 *)t->cgpu_data)->initialized,1);return true;}
static void shutdown14(struct thr_info *t)
{atomic_fetch_add(&((struct state14 *)t->cgpu_data)->shutdowns,1);}
static void open14(struct env14 *e,bool immediate_scan,bool pause)
{
    memset(e,0,sizeof *e);open12(&e->native,true);
    C14(pthread_mutex_init(&e->driver.lock,NULL)==0);C14(pthread_cond_init(&e->driver.cond,NULL)==0);
    struct cgpu_info *g=&e->native.q.e.cgpu;struct thr_info *t=&e->native.q.e.thr;
    e->published[0]=t;g->thr=e->published;g->threads=1;t->cgpu_data=&e->driver;cgsem_init(&t->sem);
    t->pause=pause;t->work_update=true;g->deven=DEV_ENABLED;
    e->driver.release=immediate_scan;
    e->native.q.e.drv.scanwork=scan14;e->native.q.e.drv.thread_enable=enable14;
    e->native.q.e.drv.update_work=update14;e->native.q.e.drv.queued_stop_wake=wake14;
    e->native.q.e.drv.thread_init=init14;e->native.q.e.drv.thread_shutdown=shutdown14;
    e->native.q.e.drv.hash_work=hash_queued_work;
    for(unsigned i=0;i<4;++i){watched14[i]=NULL;atomic_store(&sem_seen14[i],0);}
    watched14[0]=&t->sem;hold_sem14=release_sem14=hold_scan14=scan_boundary14=release_scan14=false;
}
static void prepare14(struct env14 *e)
{fill_remaining_slots(&e->native);push12(&e->native,false,false);}
static void close14(struct env14 *e)
{
    /* All external owner/request threads are joined BEFORE freeing driver state. */
    struct cgpu_info *g=&e->native.q.e.cgpu;
    g->thr=NULL;g->threads=0;cgsem_destroy(&e->native.q.e.thr.sem);
    for(unsigned i=0;i<4;++i)watched14[i]=NULL;
    C14(pthread_cond_destroy(&e->driver.cond)==0);C14(pthread_mutex_destroy(&e->driver.lock)==0);
    close12(&e->native);
}
struct thread14 {struct thr_info *t;unsigned mode;bool resumed;_Atomic unsigned done;};
static void *thread14(void *arg)
{
    struct thread14 *w=arg;
    if(w->mode==1)w->resumed=mt_disable_common(w->t,w->t->id,w->t->cgpu->drv,true);
    else if(w->mode==2){mt_disable(w->t,w->t->id,w->t->cgpu->drv);w->resumed=true;}
    else if(w->mode==3)miner_thread(w->t);
    else hash_queued_work(w->t);
    atomic_store(&w->done,1);return NULL;
}
static void until14(_Atomic unsigned *p,unsigned n)
{uint64_t end=r01_now()+2000;while(atomic_load(p)<n){C14(r01_now()<end);tick13();}}
static void join14(pthread_t p,struct thread14 *t)
{until14(&t->done,1);C14(pthread_join(p,NULL)==0);}
static int sem_value14(cgsem_t *s)
{int n;C14(sem_getvalue(s,&n)==0);return n;}
static void paused14(bool gap)
{
    struct env14 e;open14(&e,true,true);prepare14(&e);hold_sem14=gap;
    struct thread14 w={.t=&e.native.q.e.thr};pthread_t p;C14(pthread_create(&p,NULL,thread14,&w)==0);
    until14(&sem_seen14[0],1);C14(cgminer_request_queued_stop(w.t->cgpu)==0);
    C14(!atomic_load(&e.driver.enabled));
    C14(pthread_mutex_lock(&gate14)==0);release_sem14=true;
    C14(pthread_cond_broadcast(&gatecond14)==0);C14(pthread_mutex_unlock(&gate14)==0);
    join14(p,&w);C14(!atomic_load(&e.driver.enabled) && !atomic_load(&e.driver.updated));
    C14(atomic_load(&e.driver.scanning)==1 && atomic_load(&e.driver.completed)==1);
    C14(atomic_load(&step_calls)==1 && atomic_load(&complete_calls)==1);
    C14(e.native.q.e.cgpu.deven==DEV_DISABLED && w.t->work_update);
    close14(&e);++n14_cases;
}
static void before_pause14(void)
{
    struct env14 e;open14(&e,true,true);C14(cgminer_request_queued_stop(&e.native.q.e.cgpu)==0);
    struct thread14 w={.t=&e.native.q.e.thr,.mode=1};pthread_t p;
    C14(pthread_create(&p,NULL,thread14,&w)==0);join14(p,&w);
    C14(!w.resumed && !atomic_load(&sem_seen14[0]));C14(!atomic_load(&e.driver.enabled));
    C14(sem_value14(&w.t->sem)==1);close14(&e);++n14_cases;
}
static void resume14(bool stop_from_enable)
{
    struct env14 e;open14(&e,true,true);prepare14(&e);e.driver.stop_on_enable=stop_from_enable;
    struct thread14 w={.t=&e.native.q.e.thr};pthread_t p;C14(pthread_create(&p,NULL,thread14,&w)==0);
    until14(&sem_seen14[0],1);w.t->pause=false;cgsem_post(&w.t->sem);join14(p,&w);
    C14(atomic_load(&e.driver.enabled)==1);
    C14(atomic_load(&e.driver.updated)==(stop_from_enable?0u:1u));
    C14(atomic_load(&e.driver.scanning)==1);close14(&e);++n14_cases;
}
static void legacy14(void)
{
    struct env14 e;open14(&e,true,false);C14(cgminer_request_queued_stop(&e.native.q.e.cgpu)==0);
    struct thread14 w={.t=&e.native.q.e.thr,.mode=2};pthread_t p;
    C14(pthread_create(&p,NULL,thread14,&w)==0);join14(p,&w);
    C14(w.resumed && atomic_load(&e.driver.enabled)==1 && atomic_load(&sem_seen14[0])==1);
    close14(&e);++n14_cases;
}
static void multiple14(void)
{
    struct env14 e;open14(&e,true,true);struct thr_info more[2]={{0}};
    struct thread14 w[3]={{.t=&e.native.q.e.thr,.mode=1}};pthread_t p[3];
    e.published[1]=NULL;e.native.q.e.cgpu.threads=4;
    for(unsigned i=0;i<2;++i){more[i].id=i+1;more[i].cgpu=&e.native.q.e.cgpu;more[i].cgpu_data=&e.driver;
        cgsem_init(&more[i].sem);e.published[i+2]=&more[i];watched14[i+1]=&more[i].sem;
        w[i+1].t=&more[i];w[i+1].mode=1;}
    for(unsigned i=0;i<3;++i){C14(pthread_create(&p[i],NULL,thread14,&w[i])==0);until14(&sem_seen14[i],1);}
    C14(cgminer_request_queued_stop(&e.native.q.e.cgpu)==0);
    for(unsigned i=0;i<3;++i){join14(p[i],&w[i]);C14(!w[i].resumed);}
    C14(!atomic_load(&e.driver.enabled) && atomic_load(&e.driver.woke)==1);
    for(unsigned i=0;i<2;++i)cgsem_destroy(&more[i].sem);
    close14(&e);++n14_cases;
}
static void repeated14(void)
{
    struct env14 e;open14(&e,false,false);struct cgpu_info *g=&e.native.q.e.cgpu;
    C14(cgminer_request_queued_stop(g)==0);C14(sem_value14(&g->thr[0]->sem)==1);
    for(unsigned i=0;i<8;++i)C14(cgminer_request_queued_stop(g)==0);
    C14(sem_value14(&g->thr[0]->sem)==1 && atomic_load(&e.driver.woke)==9);
    close14(&e);++n14_cases;
}
static void scan_wait14(unsigned mode)
{
    struct env14 e;open14(&e,false,false);prepare14(&e);
    if(mode==1)hold_scan14=true;
    if(mode==2)e.native.q.e.drv.queued_stop_wake=NULL;
    if(mode==3)e.driver.wake_error=EIO;
    struct thread14 w={.t=&e.native.q.e.thr};pthread_t p;C14(pthread_create(&p,NULL,thread14,&w)==0);
    if(mode==1){
        C14(pthread_mutex_lock(&gate14)==0);
        while(!scan_boundary14)C14(pthread_cond_wait(&gatecond14,&gate14)==0);
        C14(pthread_mutex_unlock(&gate14)==0);
        struct request13 r={.g=w.t->cgpu};pthread_t requester;C14(pthread_create(&requester,NULL,request13,&r)==0);
        until14(&e.driver.woke,1);C14(!atomic_load(&r.done));
        C14(pthread_mutex_lock(&gate14)==0);release_scan14=true;
        C14(pthread_cond_broadcast(&gatecond14)==0);C14(pthread_mutex_unlock(&gate14)==0);
        C14(pthread_join(requester,NULL)==0 && r.rc==0);
    }else{
        until14(&e.driver.waiting,1);int rc=cgminer_request_queued_stop(w.t->cgpu);
        C14(rc==(mode==3?EIO:0));
        if(mode==2 || mode==3){
            C14(!atomic_load(&w.done) && cgminer_queued_stopped(w.t->cgpu));
            if(mode==3){e.driver.wake_error=0;C14(cgminer_request_queued_stop(w.t->cgpu)==0);}
            else{C14(pthread_mutex_lock(&e.driver.lock)==0);e.driver.release=true;
                C14(pthread_cond_broadcast(&e.driver.cond)==0);C14(pthread_mutex_unlock(&e.driver.lock)==0);}
        }
    }
    join14(p,&w);C14(atomic_load(&e.driver.scanning)==1 && atomic_load(&e.driver.completed)==1);
    C14(!atomic_load(&e.driver.enabled) && !atomic_load(&e.driver.updated));
    C14(atomic_load(&e.driver.woke)==(mode==2?0u:mode==3?2u:1u));
    C14(atomic_load(&complete_calls)==1);close14(&e);++n14_cases;
}
static void isolated14(void)
{
    struct env14 e;open14(&e,true,true);struct cgpu_info other={0};struct thr_info t={.cgpu=&other};
    struct thr_info *list[1]={&t};other.thr=list;other.threads=1;cgsem_init(&t.sem);
    C14(cgminer_request_queued_stop(&e.native.q.e.cgpu)==0);
    C14(!cgminer_queued_stopped(&other) && sem_value14(&t.sem)==0);
    cgsem_destroy(&t.sem);close14(&e);++n14_cases;
}
static void initial14(void)
{
    struct env14 e;open14(&e,false,false);struct thread14 w={.t=&e.native.q.e.thr,.mode=3};pthread_t p;
    C14(pthread_create(&p,NULL,thread14,&w)==0);until14(&sem_seen14[0],1);
    C14(cgminer_request_queued_stop(w.t->cgpu)==0);join14(p,&w);
    C14(atomic_load(&e.driver.initialized)==1 && atomic_load(&e.driver.shutdowns)==1);
    C14(!atomic_load(&e.driver.scanning) && !atomic_load(&e.driver.enabled) && !atomic_load(&step_calls));
    close14(&e);++n14_cases;
}
/* R16 reuses these host fixtures; standalone assertions are unchanged. */
#ifndef R14_WAKE_EMBED
int main(void)
{
    void (*volatile keep_native_fill)(struct thr_info *,struct cgpu_info *,struct device_drv *,const int)=fill_queue;
    C14(keep_native_fill!=NULL); /* Retain the real static symbol on Clang too. */
    alarm(55);rwlock_init(&devices_lock);mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    getq=tq_new();C14(getq);stgd_lock=&getq->mutex;C14(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;opt_log_interval=INT_MAX;
    paused14(false);paused14(true);before_pause14();resume14(false);resume14(true);legacy14();
    multiple14();repeated14();for(unsigned m=0;m<4;++m)scan_wait14(m);isolated14();initial14();
    C14(n14_cases==14 && !staged_work && !staged_rollable);
    tq_free(getq);getq=NULL;stgd_lock=NULL;C14(pthread_cond_destroy(&gws_cond)==0);
    printf("R14_PASS cases=%u checks=%u native_paused_loop=1 driver_condition_wait=1 hardware=0\n",n14_cases,atomic_load(&n14_checks));return 0;
}

#endif
