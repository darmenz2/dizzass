/* GPL-3.0-or-later. Native software I/O lifecycle, real PTYs and threads.
 * Explicitly scripted peer nonces/pauses are not ASIC or pool acceptance. */
#define R04_OWNER_EMBED
#include "integration/review/rx_owner/test.c"
#include "integration/native/io_lifecycle.h"
static unsigned lc_cases;
static _Atomic unsigned waiting_finishes;
struct dizzass_native_job_tx_receipt __real_dizzass_native_job_channel_send(struct dizzass_jobs *,struct dizzass_uart_channel *,uint64_t,uint32_t,uint32_t,uint32_t,uint32_t,const struct work *,uint64_t,unsigned);
struct dizzass_native_job_tx_receipt __wrap_dizzass_native_job_channel_send(struct dizzass_jobs *j,struct dizzass_uart_channel *c,uint64_t e,uint32_t p,uint32_t a,uint32_t slot,uint32_t v,const struct work *w,uint64_t d,unsigned b)
{
    int old;Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old)==0 && old==PTHREAD_CANCEL_DISABLE);
    return __real_dizzass_native_job_channel_send(j,c,e,p,a,slot,v,w,d,b);
}
static pthread_mutex_t finish_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t finish_cond=PTHREAD_COND_INITIALIZER;
static bool hold_finish, finish_entered, finish_release;
static struct dizzass_job_ticket held_ticket;
int __real_dizzass_jobs_finish(struct dizzass_jobs *,const struct dizzass_job_ticket *,enum dizzass_tx_result);
int __wrap_dizzass_jobs_finish(struct dizzass_jobs *j,const struct dizzass_job_ticket *t,enum dizzass_tx_result r)
{
    Q(pthread_mutex_lock(&finish_lock)==0);
    if(hold_finish) {
        int old;Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old)==0 && old==PTHREAD_CANCEL_DISABLE);
        atomic_fetch_add(&waiting_finishes,1);held_ticket=*t;finish_entered=true;Q(pthread_cond_broadcast(&finish_cond)==0);
        while(!finish_release)Q(pthread_cond_wait(&finish_cond,&finish_lock)==0);
    }
    Q(pthread_mutex_unlock(&finish_lock)==0);
    return __real_dizzass_jobs_finish(j,t,r);
}
static void finish_wait(void)
{
    struct timespec until;Q(clock_gettime(CLOCK_REALTIME,&until)==0);until.tv_sec+=4;
    Q(pthread_mutex_lock(&finish_lock)==0);
    while(!finish_entered)Q(pthread_cond_timedwait(&finish_cond,&finish_lock,&until)==0);
    Q(pthread_mutex_unlock(&finish_lock)==0);
}
static void finish_allow(void)
{
    Q(pthread_mutex_lock(&finish_lock)==0);finish_release=true;
    Q(pthread_cond_broadcast(&finish_cond)==0);Q(pthread_mutex_unlock(&finish_lock)==0);
}
static struct dizzass_io_lifecycle *lc_create(struct env *e,size_t capacity)
{
    struct dizzass_io_lifecycle *l=NULL;struct dizzass_rx_owner_config c=config(e,capacity);
    c.poll_ms=50;Q(dizzass_io_create(&c,e->f.channel,&l)==0 && l);return l;
}
static struct dizzass_io_report lc_state(struct dizzass_io_lifecycle *l)
{ struct dizzass_io_report r;Q(dizzass_io_snapshot(l,&r)==0);return r; }
static void lc_stop_destroy(struct env *e,struct dizzass_io_lifecycle **l)
{
    struct dizzass_io_report r;
    Q(dizzass_io_stop(*l,r01_now()+2000,&r)==0);
    Q(r.quiescent && r.jobs_paused && r.stop_requested && !r.active_tx);
    Q(!r.started || r.rx_joined);
    struct dizzass_nonce_reply reply={.chain_id=2,.slot=3,.variant=2};
    struct dizzass_submit_result submit={0};struct dizzass_job_result check={0};
    Q(dizzass_submitter_run(e->submitter,e->f.jobs,17,&reply,&submit)==DIZZASS_SUBMIT_STOPPED);
    Q(dizzass_jobs_check(e->f.jobs,17,&reply,&check)==DIZZASS_JOBS_PAUSED);
    struct dizzass_protocol_tx_receipt tx=dizzass_channel_bm1368_command(e->f.channel,DIZZASS_BM1368_INACTIVE,0,0,0,0,r01_now()+1000,32);
    Q(tx.transport.status==DIZZASS_UART_CANCELED && tx.transport.written==0);
    struct dizzass_io_report again;
    Q(dizzass_io_stop(*l,0,&again)==0 && again.quiescent);
    Q(memcmp(&r.rx,&again.rx,sizeof r.rx)==0);
    Q(fcntl(e->f.host,F_GETFL)>=0);
    Q(dizzass_io_destroy(l)==0 && !*l);cleanup(e);
}
struct lc_sender {
    struct dizzass_io_lifecycle *l;struct env *e;unsigned slot;
    int rc;bool command;
    struct dizzass_io_work_receipt work;
    struct dizzass_io_command_receipt cmd;
};
static void *lc_send(void *p)
{
    struct lc_sender *s=p;
    if(s->command)s->rc=dizzass_io_send_command(s->l,DIZZASS_BM1368_READ_REGISTER,1,0,0,0,r01_now()+4000,32,&s->cmd);
    else s->rc=dizzass_io_send_work(s->l,2,0,s->slot,2,s->e->source,r01_now()+4000,32,&s->work);
    pthread_testcancel();return NULL;
}
static void lc_sync_send(struct env *e,struct dizzass_io_lifecycle *l,unsigned slot)
{
    struct lc_sender s={.l=l,.e=e,.slot=slot};lc_send(&s);
    Q(!s.rc && s.work.send.finish_called && !s.work.send.finish_status && s.work.send.outcome==DIZZASS_TX_WRITTEN);
    uint8_t wire[88],expected[88];Q(dizzass_native_work_tx88(e->source,2,0,slot,expected,88)==0);
    r01_read(e->f.peer,wire,88);Q(!memcmp(wire,expected,88));
}
static void basic(void)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,8);
    struct dizzass_io_work_receipt r,before;memset(&r,0x55,sizeof r);before=r;
    Q(dizzass_io_send_work(l,2,0,3,2,e.source,r01_now()+1000,32,&r)==ENOTCONN);
    Q(!memcmp(&r,&before,sizeof r));Q(dizzass_io_start(l)==0);Q(dizzass_io_start(l)==EALREADY);
    Q(dizzass_io_destroy(&l)==EBUSY && l);
    lc_sync_send(&e,l,3);uint8_t f[11];frame(3,f);peer_write(&e,f,11);wait_events(&e,2);take_genesis(&e);
    Q(dizzass_io_request_stop(l)==0);
    Q(dizzass_io_send_work(l,2,0,4,2,e.source,r01_now()+1000,32,&r)==ECANCELED);
    Q(!memcmp(&r,&before,sizeof r));lc_stop_destroy(&e,&l);++lc_cases;
    puts("R05_BASIC admission_and_native_queue=1");
}
static void early_progress(size_t cap)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,8);read_cap=cap;
    Q(dizzass_io_start(l)==0);r01_hook(R01_HOLD,e.f.host);
    struct lc_sender s={.l=l,.e=&e,.slot=3};pthread_t th;Q(pthread_create(&th,NULL,lc_send,&s)==0);
    r01_wait_hook();uint8_t wire[88],f[11];r01_read(e.f.peer,wire,88);frame(3,f);peer_write(&e,f,11);wait_events(&e,1);
    Q(lc_state(l).active_tx==1 && queue_empty(&e));
    r01_release_hook();Q(pthread_join(th,NULL)==0);Q(!s.rc && !s.work.notify_status);
    wait_events(&e,2);take_genesis(&e);Q(!lc_state(l).active_tx);
    struct dizzass_io_report r;Q(dizzass_io_stop(l,r01_now()+1000,&r)==0);
    Q(r.rx.wake_reads>=1);
    lc_stop_destroy(&e,&l);++lc_cases;printf("R05_EARLY read_cap=%zu automatic_notify=1\n",cap);
}
/* Channel idle is insufficient: actual A-16 hasn't committed finish yet. */
static void unfinished(bool cancel)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,4);Q(dizzass_io_start(l)==0);
    hold_finish=true;finish_entered=false;finish_release=false;
    struct lc_sender s={.l=l,.e=&e,.slot=3};pthread_t th;Q(pthread_create(&th,NULL,lc_send,&s)==0);finish_wait();
    uint8_t wire[88],f[11];r01_read(e.f.peer,wire,88);frame(3,f);peer_write(&e,f,11);wait_events(&e,1);
    struct dizzass_uart_channel_state cs;Q(dizzass_uart_channel_snapshot(e.f.channel,&cs)==0 && !cs.active);
    if(cancel)Q(pthread_cancel(th)==0);
    struct dizzass_io_report r;Q(dizzass_io_stop(l,r01_now()+20,&r)==ETIMEDOUT);
    Q(r.active_tx==1 && r.rx_joined && !r.quiescent && !r.jobs_paused);
    Q(r.final_tx_stop_status==0 && r.tx_wait_status==ETIMEDOUT);
    Q(dizzass_jobs_ticket_live(e.f.jobs,&held_ticket)==DIZZASS_JOBS_PENDING);
    Q(dizzass_io_destroy(&l)==EBUSY && fcntl(e.f.host,F_GETFL)>=0);
    finish_allow();void *ret=NULL;Q(pthread_join(th,&ret)==0 && ret==(cancel?PTHREAD_CANCELED:NULL));
    hold_finish=false;Q(s.work.send.finish_called && !s.work.send.finish_status);
    Q(!lc_state(l).active_tx);Q(queue_empty(&e));lc_stop_destroy(&e,&l);
    ++lc_cases;printf("R05_PENDING_FINISH canceled=%d channel_idle_but_not_quiescent=1\n",cancel);
}
static void held_write(bool command)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,4);Q(dizzass_io_start(l)==0);
    r01_hook(R01_HOLD,e.f.host);struct lc_sender s={.l=l,.e=&e,.slot=3,.command=command};
    pthread_t th;Q(pthread_create(&th,NULL,lc_send,&s)==0);r01_wait_hook();
    struct dizzass_io_report r;Q(dizzass_io_stop(l,r01_now()+20,&r)==ETIMEDOUT);
    Q(r.active_tx==1 && !r.quiescent && r.rx_joined && r.final_tx_stop_status==ETIMEDOUT);
    uint8_t bytes[88],expected[11];size_t n=88;
    if(command)Q(dizzass_bm1368_command_encode(DIZZASS_BM1368_READ_REGISTER,1,0,0,0,expected,11,&n)==0);
    r01_read(e.f.peer,bytes,n);if(command)Q(!memcmp(bytes,expected,n));r01_empty(e.f.peer);
    Q(dizzass_io_destroy(&l)==EBUSY);r01_release_hook();Q(pthread_join(th,NULL)==0 && !s.rc);
    lc_stop_destroy(&e,&l);++lc_cases;printf("R05_HELD_WRITE command=%d no_early_release=1\n",command);
}
static void multiple_producers(void)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,8);Q(dizzass_io_start(l)==0);
    hold_finish=true;finish_entered=false;finish_release=false;atomic_store(&waiting_finishes,0);
    struct lc_sender s[3];pthread_t th[3];
    for(unsigned i=0;i<3;++i){s[i]=(struct lc_sender){.l=l,.e=&e,.slot=i};Q(pthread_create(&th[i],NULL,lc_send,&s[i])==0);}
    wait_uint(&waiting_finishes,3);Q(lc_state(l).active_tx==3);
    uint8_t wire[264];r01_read(e.f.peer,wire,sizeof wire);
    struct dizzass_io_report r;Q(dizzass_io_stop(l,r01_now()+20,&r)==ETIMEDOUT);
    Q(r.active_tx==3 && !r.quiescent && !r.jobs_paused && r.final_tx_stop_status==0);
    finish_allow();for(unsigned i=0;i<3;++i){Q(pthread_join(th[i],NULL)==0);Q(!s[i].rc && !s[i].work.send.finish_status);}
    hold_finish=false;Q(!lc_state(l).active_tx);lc_stop_destroy(&e,&l);++lc_cases;
    puts("R05_PRODUCERS count=3 wait_for_all_finishes=1");
}
struct lc_controller {struct dizzass_io_lifecycle *l;int rc;struct dizzass_io_report r;_Atomic bool done;};
static void *lc_stop_thread(void *p)
{
    struct lc_controller *c=p;c->rc=dizzass_io_stop(c->l,r01_now()+3000,&c->r);
    atomic_store(&c->done,true);pthread_testcancel();return NULL;
}
static void wait_requested(struct dizzass_io_lifecycle *l)
{
    uint64_t until=r01_now()+3000;while(!lc_state(l).stop_requested){Q(r01_now()<until);struct timespec t={0,1000000};nanosleep(&t,NULL);}
}
static void admitted_submit(bool cancel)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,8);Q(dizzass_io_start(l)==0);lc_sync_send(&e,l,3);
    Q(pthread_mutex_lock(&hold_lock)==0);hold_native=true;native_entered=false;native_release=false;Q(pthread_mutex_unlock(&hold_lock)==0);
    uint8_t f[11];frame(3,f);peer_write(&e,f,11);
    struct timespec until;Q(clock_gettime(CLOCK_REALTIME,&until)==0);until.tv_sec+=4;
    Q(pthread_mutex_lock(&hold_lock)==0);while(!native_entered)Q(pthread_cond_timedwait(&hold_cond,&hold_lock,&until)==0);Q(pthread_mutex_unlock(&hold_lock)==0);
    struct lc_controller c={.l=l};pthread_t th;Q(pthread_create(&th,NULL,lc_stop_thread,&c)==0);wait_requested(l);
    Q(!atomic_load(&c.done) && !lc_state(l).quiescent);
    if(cancel)Q(pthread_cancel(th)==0);
    Q(pthread_mutex_lock(&hold_lock)==0);native_release=true;Q(pthread_cond_broadcast(&hold_cond)==0);Q(pthread_mutex_unlock(&hold_lock)==0);
    void *ret=NULL;Q(pthread_join(th,&ret)==0 && ret==(cancel?PTHREAD_CANCELED:NULL));
    Q(c.r.quiescent && c.r.rx.dispatched==1 && c.r.rx_joined && c.r.jobs_paused);
    Q(lc_state(l).quiescent);take_genesis(&e);hold_native=false;lc_stop_destroy(&e,&l);++lc_cases;
    printf("R05_ADMITTED_SUBMIT canceled_controller=%d receipt_preserved=1\n",cancel);
}
static void startup_failure(int which)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=NULL;struct dizzass_rx_owner_config c=config(&e,4);
    if(which==0){c.fd=-1;Q(dizzass_io_create(&c,e.f.channel,&l)==EBADF && !l);}
    if(which==1){atomic_store(&fail_eventfd,EMFILE);Q(dizzass_io_create(&c,e.f.channel,&l)==EMFILE && !l);}
    if(which==2){l=lc_create(&e,4);atomic_store(&fail_create,EAGAIN);Q(dizzass_io_start(l)==EAGAIN);Q(dizzass_io_start(l)==ECANCELED);Q(dizzass_io_destroy(&l)==EBUSY);}
    if(which==3){l=lc_create(&e,4);Q(dizzass_io_request_stop(l)==0);Q(dizzass_io_start(l)==ECANCELED);}
    if(which==4){l=lc_create(&e,4);Q(dizzass_io_destroy(&l)==0 && !l);}
    if(l)lc_stop_destroy(&e,&l);else cleanup(&e);++lc_cases;printf("R05_START_FAILURE kind=%d borrowed_resources_retained=1\n",which);
}
static void uncertain(enum r01_mode mode)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,4);Q(dizzass_io_start(l)==0);
    r01_hook(mode,e.f.host);uint64_t deadline=r01_now()+50;r01_late_until=deadline+20;
    struct dizzass_io_work_receipt r;Q(dizzass_io_send_work(l,2,0,3,2,e.source,deadline,32,&r)==0);
    Q(r.send.finish_called && r.send.outcome==DIZZASS_TX_UNCERTAIN && lc_state(l).stop_requested);
    uint8_t b[88];r01_read(e.f.peer,b,mode==R01_PREFIX_EIO?5:88);r01_empty(e.f.peer);
    Q(dizzass_jobs_ticket_live(e.f.jobs,&r.send.ticket)==DIZZASS_JOBS_QUARANTINED);
    lc_stop_destroy(&e,&l);++lc_cases;printf("R05_FAULT mode=%d no_retry=1\n",mode);
}
static void rx_failure(bool callback)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,4);
    if(callback)e.error_kind=DIZZASS_RX_QUEUED;Q(dizzass_io_start(l)==0);
    if(callback){lc_sync_send(&e,l,3);uint8_t f[11];frame(3,f);peer_write(&e,f,11);wait_events(&e,1);}
    else {Q(close(e.f.peer)==0);e.f.peer=-1;}
    struct dizzass_io_command_receipt r;int rc=0;uint64_t until=r01_now()+3000;
    do {struct timespec t={0,1000000};nanosleep(&t,NULL);Q(r01_now()<until);
        rc=dizzass_io_send_command(l,(enum dizzass_bm1368_command)99,0,0,0,0,r01_now()+1000,32,&r);
    } while(!rc);
    Q(rc==EPIPE || rc==ECANCELED);Q(lc_state(l).rx_finished);
    struct dizzass_io_report report;Q(dizzass_io_stop(l,r01_now()+1000,&report)==0 && report.quiescent);
    Q(report.rx.reason==(callback?DIZZASS_RX_CALLBACK_ERROR:DIZZASS_RX_IO_ERROR));
    if(callback)Q(report.rx.detail==771);Q(queue_empty(&e));lc_stop_destroy(&e,&l);++lc_cases;
    printf("R05_RX_EXIT callback=%d blocks_new_TX=1\n",callback);
}
static void slots_and_commands(void)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *l=lc_create(&e,64);Q(dizzass_io_start(l)==0);
    for(unsigned i=0;i<32;++i){lc_sync_send(&e,l,i);uint8_t f[11];frame(i,f);peer_write(&e,f,11);}
    wait_events(&e,64);Q(e.cgpu.diff1==1 && e.cgpu.hw_errors==31);take_genesis(&e);
    struct dizzass_io_work_receipt r;Q(dizzass_io_send_work(l,2,0,32,2,e.source,r01_now()+1000,32,&r)==0);
    Q(r.send.prepare_status && !r.send.channel_called && !lc_state(l).stop_requested);
    struct dizzass_io_command_receipt c;uint8_t expect[11],got[11];size_t n=0;
    Q(dizzass_bm1368_command_encode(DIZZASS_BM1368_READ_REGISTER,1,0,0,0,expect,sizeof expect,&n)==0);
    Q(dizzass_io_send_command(l,DIZZASS_BM1368_READ_REGISTER,1,0,0,0,r01_now()+1000,32,&c)==0 && c.send.transport.status==DIZZASS_UART_OK);
    r01_read(e.f.peer,got,n);Q(!memcmp(got,expect,n));lc_stop_destroy(&e,&l);++lc_cases;
    puts("R05_SLOTS work=32 command=1 native_duplicate_policy_preserved=1");
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    basic();for(size_t i=1;i<=11;++i)early_progress(i);
    unfinished(false);unfinished(true);held_write(false);held_write(true);multiple_producers();
    admitted_submit(false);admitted_submit(true);
    for(int i=0;i<5;++i)startup_failure(i);
    uncertain(R01_PREFIX_EIO);uncertain(R01_LATE);rx_failure(false);rx_failure(true);slots_and_commands();
    printf("R05_PASS cases=%u checks=%u native_calls=%u physical_asic=0\n",lc_cases,atomic_load(&checks),atomic_load(&native_calls));return 0;
}
