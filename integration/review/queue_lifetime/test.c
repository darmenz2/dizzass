/* GPL-3.0-or-later. Existing native queue adapter, no replacement dequeue.
 * Independent real-PTY tests of the stronger R-10 software lifetime contract. */
#define R10_QUEUE_SCOPE_WRAPPER
#define R09_QUEUED_EMBED
#include "integration/review/queued_work/test.c"
#include "integration/native/io_queue_scope.h"

static unsigned lifetime_cases;
static _Atomic unsigned lifetime_checks, scope_enters, scope_leaves;
#define C10(x) do { atomic_fetch_add(&lifetime_checks,1); if (!(x)) { \
 fprintf(stderr,"R10_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static pthread_mutex_t scope_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t scope_cond=PTHREAD_COND_INITIALIZER;
static int scope_mode; /* 1: after enter, 2: before leave, 3: stop before enter. */
static int scope_error;
static bool scope_entered, scope_release, expect_taken;
static struct dizzass_queued_tx_receipt *visible_receipt;

static struct dizzass_io_report state_of(struct dizzass_io_lifecycle *io)
{ struct dizzass_io_report r; C10(dizzass_io_snapshot(io,&r)==0); return r; }
static void scope_barrier(int kind)
{
    C10(pthread_mutex_lock(&scope_lock)==0);
    if (scope_mode==kind) {
        scope_entered=true; C10(pthread_cond_broadcast(&scope_cond)==0);
        while (!scope_release) C10(pthread_cond_wait(&scope_cond,&scope_lock)==0);
    }
    C10(pthread_mutex_unlock(&scope_lock)==0);
}
int __real_dizzass_io_queue_enter(struct dizzass_io_lifecycle *);
int __wrap_dizzass_io_queue_enter(struct dizzass_io_lifecycle *io)
{
    cancellation_disabled(); atomic_fetch_add(&scope_enters,1);
    if (scope_mode==3) C10(dizzass_io_request_stop(io)==0);
    if (scope_error) return scope_error; /* Explicit injected adapter error. */
    int rc=__real_dizzass_io_queue_enter(io);
    if (!rc) {
        struct dizzass_io_report s=state_of(io);
        C10(s.active_queue==1);
        scope_barrier(1);
    }
    return rc;
}
void __real_dizzass_io_queue_leave(struct dizzass_io_lifecycle *);
void __wrap_dizzass_io_queue_leave(struct dizzass_io_lifecycle *io)
{
    cancellation_disabled();
    C10(visible_receipt && visible_receipt->dequeued==expect_taken && visible_receipt->completed==expect_taken);
    scope_barrier(2);
    __real_dizzass_io_queue_leave(io); atomic_fetch_add(&scope_leaves,1);
}
static void wait_scope(void)
{
    struct timespec deadline; C10(clock_gettime(CLOCK_REALTIME,&deadline)==0); deadline.tv_sec+=5;
    C10(pthread_mutex_lock(&scope_lock)==0);
    while (!scope_entered) C10(pthread_cond_timedwait(&scope_cond,&scope_lock,&deadline)==0);
    C10(pthread_mutex_unlock(&scope_lock)==0);
}
static void release_scope(void)
{
    C10(pthread_mutex_lock(&scope_lock)==0);scope_release=true;
    C10(pthread_cond_broadcast(&scope_cond)==0);C10(pthread_mutex_unlock(&scope_lock)==0);
}
static void setup_lifetime(struct qenv *q)
{
    init(q,true); scope_mode=scope_error=0; scope_entered=scope_release=false;
    visible_receipt=NULL; expect_taken=true;
    atomic_store(&scope_enters,0);atomic_store(&scope_leaves,0);
}
static void settled(struct qenv *q)
{
    struct dizzass_io_report s=state_of(q->io);
    C10(s.active_queue==0 && s.active_tx==0);
    C10(atomic_load(&scope_enters)==1 && atomic_load(&scope_leaves)==1);
    gone(q);
}
/* Every returning core outcome must release its scope, including no work. */
static void outcome(unsigned mode)
{
    struct qenv q;setup_lifetime(&q);struct work *w=mode?stage(&q):NULL;
    if(mode==1)w->work_block=work_block+1;
    if(mode==2)w->thr_id=77;
    if(mode==3)atomic_store(&fail_strdup,0);
    if(mode==4)stop_after_get=q.io;
    struct dizzass_queued_tx_receipt r={.dequeued=true,.completed=true};
    expect_taken=mode>=2; visible_receipt=&r; C10(send_q(&q,3,&r)==0);
    C10(r.dequeued==expect_taken && r.completed==expect_taken);
    if(mode==2)C10(r.work_status==DIZZASS_SUBMIT_WRONG_THREAD);
    if(mode==3)C10(r.send.send.prepare_status==DIZZASS_NONCE_PARTIAL_COPY);
    if(mode==4)C10(r.send_status==ECANCELED);
    settled(&q);
    if(mode==5){uint8_t b[88];r01_read(q.e.f.peer,b,88);}else r01_empty(q.e.f.peer);
    close_q(&q);++lifetime_cases;
}
/* Stop cannot call a held native queue ownership interval quiescent.
 * kind1: admitted but before get_queued; kind2: inside work_completed;
 * kind3: work completed and receipt stored, before releasing accounting. */
static void window(unsigned kind,bool cancel)
{
    struct qenv q;setup_lifetime(&q);stage(&q);
    if(kind==2)block_completion=true;else scope_mode=kind==1?1:2;
    struct qsender s={.q=&q,.p=plan(3),.rc=-999};visible_receipt=&s.r;
    pthread_t tx;C10(pthread_create(&tx,NULL,qthread,&s)==0);
    if(kind==2){
        struct timespec d;C10(clock_gettime(CLOCK_REALTIME,&d)==0);d.tv_sec+=5;
        C10(pthread_mutex_lock(&completion_lock)==0);
        while(!completion_entered)C10(pthread_cond_timedwait(&completion_cond,&completion_lock,&d)==0);
        C10(pthread_mutex_unlock(&completion_lock)==0);
    }else wait_scope();
    struct dizzass_io_report current=state_of(q.io);
    C10(current.active_queue==1 && current.active_tx==0);
    C10(atomic_load(&complete_calls)==(kind==3?1u:0u));
    if(cancel)C10(pthread_cancel(tx)==0);
    struct dizzass_io_report report;
    C10(dizzass_io_stop(q.io,r01_now()+20,&report)==ETIMEDOUT);
    C10(report.active_queue==1 && !report.quiescent && !report.jobs_paused);
    C10(report.rx_joined && report.active_tx==0);
    C10(dizzass_io_destroy(&q.io)==EBUSY);
    if(kind==2){C10(pthread_mutex_lock(&completion_lock)==0);completion_release=true;
        C10(pthread_cond_broadcast(&completion_cond)==0);C10(pthread_mutex_unlock(&completion_lock)==0);}
    else release_scope();
    void *ret=NULL;C10(pthread_join(tx,&ret)==0 && ret==(cancel?PTHREAD_CANCELED:NULL));
    C10(s.r.dequeued && s.r.completed && atomic_load(&complete_calls)==1);
    settled(&q);
    if(kind==1){C10(s.r.send_status==ECANCELED);r01_empty(q.e.f.peer);}
    else {uint8_t b[88];r01_read(q.e.f.peer,b,88);}
    close_q(&q);++lifetime_cases;
    printf("R10_WINDOW boundary=%u cancel=%d queue_held_until_completion_and_receipt=1\n",kind,cancel);
}
static void scope_refusal(bool injected)
{
    struct qenv q;setup_lifetime(&q);struct work *w=stage(&q);
    if(injected)scope_error=EOVERFLOW;else scope_mode=3;
    struct dizzass_queued_tx_receipt r={0},before=r;visible_receipt=&r;
    C10(send_q(&q,3,&r)==(injected?EOVERFLOW:ECANCELED));
    C10(!atomic_load(&get_calls) && !atomic_load(&complete_calls) && !atomic_load(&scope_leaves));
    C10(q.e.cgpu.unqueued_work==w && memcmp(&r,&before,sizeof r)==0);
    C10(state_of(q.io).active_queue==0);r01_empty(q.e.f.peer);
    close_q(&q);++lifetime_cases;
}
static void whole_tx(bool cancel)
{
    struct qenv q;setup_lifetime(&q);stage(&q);r01_hook(R01_HOLD,q.e.f.host);
    struct qsender s={.q=&q,.p=plan(3),.rc=-999};visible_receipt=&s.r;
    pthread_t tx;C10(pthread_create(&tx,NULL,qthread,&s)==0);r01_wait_hook();
    struct dizzass_io_report r=state_of(q.io);
    C10(r.active_queue==1 && r.active_tx==1);
    if(cancel)C10(pthread_cancel(tx)==0);
    C10(dizzass_io_stop(q.io,r01_now()+20,&r)==ETIMEDOUT);
    C10(r.active_queue==1 && r.active_tx==1 && !r.quiescent);
    r01_release_hook();void *ret=NULL;C10(pthread_join(tx,&ret)==0 && ret==(cancel?PTHREAD_CANCELED:NULL));
    settled(&q);uint8_t b[88];r01_read(q.e.f.peer,b,88);close_q(&q);++lifetime_cases;
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    pthread_mutex_t stage_lock;mutex_init(&stage_lock);stgd_lock=&stage_lock;C10(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    for(unsigned i=0;i<6;++i)outcome(i);
    for(unsigned i=1;i<=3;++i){window(i,false);window(i,true);}
    scope_refusal(false);scope_refusal(true);whole_tx(false);whole_tx(true);
    C10(pthread_cond_destroy(&gws_cond)==0);C10(pthread_mutex_destroy(&stage_lock)==0);stgd_lock=NULL;
    printf("R10_PASS cases=%u checks=%u existing_queued_work=1 physical_asic=0\n",lifetime_cases,atomic_load(&lifetime_checks));return 0;
}
