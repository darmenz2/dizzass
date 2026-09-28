/* GPL-3.0-or-later. Real core/queue, scripted PTY peer; no network or driver startup. */
#define R01_STACK_EMBED
#include "integration/review/native_uart_stack/test_stack.c"
#include "integration/native/early_rx.h"
#include "integration/native/native_job_channel_tx.h"
static _Atomic unsigned checks, native_calls;
static unsigned cases;
#define Q(x) do { atomic_fetch_add(&checks,1); if (!(x)) { fprintf(stderr,"R03_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static _Atomic int fail_strdup = -1;
char *__real_strdup(const char *);
char *__wrap_strdup(const char *s)
{
    int n=atomic_load(&fail_strdup);
    if(n>=0 && atomic_fetch_sub(&fail_strdup,1)==0) return NULL;
    return __real_strdup(s);
}
static struct dizzass_jobs *pause_after_admission, *pause_from_hw;
static bool hold_submit, entered_submit, release_submit;
static pthread_mutex_t submit_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t submit_changed=PTHREAD_COND_INITIALIZER;
bool __real_submit_nonce(struct thr_info *,struct work *,uint32_t);
bool __wrap_submit_nonce(struct thr_info *thr,struct work *w,uint32_t n)
{
    atomic_fetch_add(&native_calls,1);
    if(pause_after_admission) Q(dizzass_jobs_pause(pause_after_admission,17)==0);
    if(hold_submit) {
        Q(pthread_mutex_lock(&submit_lock)==0); entered_submit=true;
        Q(pthread_cond_broadcast(&submit_changed)==0);
        while(!release_submit) Q(pthread_cond_wait(&submit_changed,&submit_lock)==0);
        Q(pthread_mutex_unlock(&submit_lock)==0);
    }
    return __real_submit_nonce(thr,w,n); /* Every call forwards the real result. */
}
static void hw_error(struct thr_info *thr)
{
    (void)thr;
    if(pause_from_hw) Q(dizzass_jobs_pause(pause_from_hw,17)==0);
}
struct env {
    struct r01_fixture f;
    struct pool pool;
    struct cgpu_info cgpu;
    struct device_drv drv;
    struct thr_info thr;
    struct work *source;
    struct dizzass_submitter *submitter;
    struct dizzass_early_rx *q;
};
static void setup(struct env *e,size_t capacity)
{
    memset(e,0,sizeof *e); r01_hook(R01_NORMAL,-1);
    e->f=r01_open(); e->drv.name="r03-offline"; e->drv.hw_error=hw_error;
    e->cgpu.drv=&e->drv; e->thr.cgpu=&e->cgpu; e->thr.id=0;
    e->pool.has_stratum=e->pool.stratum_active=e->pool.stratum_notify=true;
    e->pool.stratum_q=tq_new(); Q(e->pool.stratum_q);
    e->source=r01_work(); e->source->pool=&e->pool; e->source->stratum=true;
    e->source->thr_id=0; e->source->work_block=work_block;
    e->source->work_difficulty=e->source->device_diff=1;
    cgtime(&e->source->tv_staged);
    Q(dizzass_submitter_create(&e->thr,&e->submitter)==0);
    Q(dizzass_early_rx_create(e->f.jobs,2,17,capacity,&e->q)==0);
}
static bool queue_empty(struct env *e)
{
    if(!e->pool.stratum_q) return true;
    mutex_lock(&e->pool.stratum_q->mutex);
    bool empty=list_empty(&e->pool.stratum_q->q);
    mutex_unlock(&e->pool.stratum_q->mutex); return empty;
}
static struct work *queued(struct env *e)
{ Q(!queue_empty(e)); return tq_pop(e->pool.stratum_q); }
static void close_env(struct env *e)
{
    Q(dizzass_submitter_stop(e->submitter)==0); dizzass_submitter_destroy(&e->submitter);
    dizzass_early_rx_destroy(&e->q);
    if(e->source) free_work(e->source);
    r01_close(&e->f);
    while(!queue_empty(e)) { struct work *w=queued(e); free_work(w); }
    tq_free(e->pool.stratum_q);
}
static struct dizzass_nonce_reply reply(unsigned slot)
{
    uint32_t n=(uint32_t)fixture_words[76]|(uint32_t)fixture_words[77]<<8|
        (uint32_t)fixture_words[78]<<16|(uint32_t)fixture_words[79]<<24;
    return (struct dizzass_nonce_reply){2,slot,2,n,0};
}
static struct dizzass_tx88_prepared prepare(struct env *e,unsigned slot)
{
    struct dizzass_tx88_prepared p={0};
    Q(dizzass_jobs_prepare_tx88(e->f.jobs,17,2,0,slot,2,e->source,&p)==0); return p;
}
static void offer(struct env *e,unsigned slot)
{ struct dizzass_nonce_reply r=reply(slot); Q(dizzass_early_rx_offer(e->q,17,&r)==0); }
static void finish(struct env *e,struct dizzass_tx88_prepared *p,enum dizzass_tx_result result)
{ Q(dizzass_jobs_finish(e->f.jobs,&p->ticket,result)==0); }
static void native_result(struct env *e,struct dizzass_early_rx_submission *s,unsigned slot)
{
    Q(s->native_called && s->job_status==0);
    Q(s->captured.epoch==17 && s->captured.chain_id==2 && s->captured.slot==slot);
    Q(s->result.ticket.serial==s->captured.serial && s->result.ticket.slot==slot);
    Q(s->result.native_valid_nonce && s->result.meets_target);
    Q(e->pool.accepted==0);
}
static void take_genesis(struct env *e)
{
    struct work *w=queued(e);
    Q(w && memcmp(w->hash,fixture_hash,32)==0);
    Q(w->pool==&e->pool && strcmp(w->job_id,"r01-job")==0);
    free_work(w); Q(queue_empty(e));
}
struct sender { struct env *e; struct dizzass_native_job_tx_receipt receipt; };
static void *send_actual(void *v)
{
    struct sender *s=v;
    s->receipt=dizzass_native_job_channel_send(s->e->f.jobs,s->e->f.channel,17,2,0,3,2,
        s->e->source,r01_now()+3000,32); return NULL;
}
static void early(size_t fragment)
{
    struct env e; setup(&e,4); struct sender sender={.e=&e};
    uint8_t expected[88],wire[88]; Q(dizzass_native_work_tx88(e.source,2,0,3,expected,88)==0);
    r01_hook(R01_HOLD,e.f.host); pthread_t th;
    Q(pthread_create(&th,NULL,send_actual,&sender)==0); r01_wait_hook();
    r01_read(e.f.peer,wire,88); Q(memcmp(expected,wire,88)==0);
    struct dizzass_nonce_reply rx=r01_reply(&e.f,3,fragment);
    Q(dizzass_early_rx_offer(e.q,17,&rx)==0); memset(&rx,0xa5,sizeof rx);
    struct dizzass_early_rx_submission s,unchanged; memset(&s,0x5a,sizeof s); unchanged=s;
    unsigned before=atomic_load(&native_calls);
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==DIZZASS_EARLY_RX_WAITING);
    Q(memcmp(&s,&unchanged,sizeof s)==0 && queue_empty(&e) && atomic_load(&native_calls)==before);
    r01_release_hook(); Q(pthread_join(th,NULL)==0);
    Q(sender.receipt.finish_status==0 && sender.receipt.outcome==DIZZASS_TX_WRITTEN);
    memset(e.source->data,0xa5,sizeof e.source->data); e.source->job_id[0]='X'; free_work(e.source);
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0); native_result(&e,&s,3);
    Q(atomic_load(&native_calls)==before+1 && dizzass_early_rx_size(e.q)==0);
    take_genesis(&e);
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==DIZZASS_EARLY_RX_EMPTY);
    Q(atomic_load(&native_calls)==before+1 && e.cgpu.diff1==1);
    close_env(&e); ++cases; printf("R03_EARLY fragment=%zu real_a16=1 native_queue=1\n",fragment);
}
/* Explicit software lifecycle scripts below are not hardware ACK/drain proof. */
static void reject(unsigned mode)
{
    struct env e; setup(&e,4); struct dizzass_tx88_prepared p=prepare(&e,3); offer(&e,3);
    int expected;
    if(mode==0) { Q(dizzass_jobs_pause(e.f.jobs,17)==0); expected=DIZZASS_JOBS_PAUSED; }
    else if(mode==1) { finish(&e,&p,DIZZASS_TX_UNCERTAIN); expected=DIZZASS_JOBS_QUARANTINED; }
    else if(mode==2) { finish(&e,&p,DIZZASS_TX_NOT_SENT); expected=DIZZASS_JOBS_EMPTY; }
    else if(mode==3) {
        finish(&e,&p,DIZZASS_TX_NOT_SENT); struct dizzass_tx88_prepared replacement=prepare(&e,3);
        Q(replacement.ticket.serial!=p.ticket.serial); finish(&e,&replacement,DIZZASS_TX_WRITTEN);
        expected=DIZZASS_JOBS_STALE_TICKET;
    } else if(mode==4) {
        Q(dizzass_jobs_pause(e.f.jobs,17)==0); Q(dizzass_jobs_begin_drained_epoch(e.f.jobs,17,18)==0);
        expected=DIZZASS_JOBS_OLD_EPOCH; /* Synthetic epoch transition only. */
    } else {
        finish(&e,&p,DIZZASS_TX_WRITTEN); Q(dizzass_jobs_retire(e.f.jobs,&p.ticket)==0);
        expected=DIZZASS_JOBS_QUARANTINED;
    }
    unsigned before=atomic_load(&native_calls); struct dizzass_early_rx_submission s={0};
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
    Q(s.job_status==expected && !s.native_called && s.captured.serial==p.ticket.serial);
    Q(atomic_load(&native_calls)==before && queue_empty(&e) && e.cgpu.diff1==0 && e.cgpu.last_nonce==0);
    Q(dizzass_early_rx_size(e.q)==0); close_env(&e); ++cases;
    printf("R03_REJECT mode=%u no_native_call=1\n",mode);
}
static void copy_retry(unsigned failure)
{
    struct env e; setup(&e,2); struct dizzass_tx88_prepared p=prepare(&e,3);
    finish(&e,&p,DIZZASS_TX_WRITTEN); offer(&e,3);
    struct dizzass_early_rx_submission s,unchanged; memset(&s,0xa6,sizeof s); unchanged=s;
    unsigned before=atomic_load(&native_calls); atomic_store(&fail_strdup,(int)failure);
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==DIZZASS_NONCE_PARTIAL_COPY);
    atomic_store(&fail_strdup,-1);
    Q(dizzass_early_rx_size(e.q)==1 && memcmp(&s,&unchanged,sizeof s)==0);
    Q(atomic_load(&native_calls)==before && queue_empty(&e) && e.cgpu.last_nonce==0);
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0); native_result(&e,&s,3); take_genesis(&e);
    Q(dizzass_early_rx_size(e.q)==0 && atomic_load(&native_calls)==before+1);
    close_env(&e); ++cases; printf("R03_COPY_RETRY field=%u no_loss_no_double=1\n",failure);
}
static void core_outcome(unsigned mode)
{
    struct env e; setup(&e,3);
    if(mode==1) memset(e.source->target,0,32);
    if(mode==2 || mode==3 || mode==6) e.source->work_block=work_block+1;
    opt_submit_stale=mode==6;
    if(mode==4) e.source->tv_staged.tv_sec-=1000;
    if(mode==5) tq_freeze(e.pool.stratum_q);
    e.pool.submit_old=mode==3;
    struct dizzass_tx88_prepared p=prepare(&e,3); finish(&e,&p,DIZZASS_TX_WRITTEN); offer(&e,3);
    if(mode==0) offer(&e,3); /* Two received duplicates, not replay of one record. */
    struct dizzass_early_rx_submission s={0};
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
    Q(s.native_called && s.job_status==0 && s.result.native_valid_nonce);
    Q(s.result.meets_target==(mode!=1));
    Q(e.cgpu.diff1==1 && e.pool.diff1==1 && e.pool.accepted==0);
    if(mode==0 || mode==3 || mode==6) { struct work *w=queued(&e); Q(w->stale==(mode==3 || mode==6)); free_work(w); }
    Q(queue_empty(&e));
    if(mode==0) {
        Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
        Q(s.native_called && !s.result.native_valid_nonce && !s.result.meets_target);
        Q(e.cgpu.hw_errors==1 && e.cgpu.diff1==1 && queue_empty(&e));
    }
    if(mode==2 || mode==4) Q(e.pool.stale_shares==1);
    Q(dizzass_early_rx_size(e.q)==0); close_env(&e); opt_submit_stale=false; ++cases;
    printf("R03_CORE mode=%u actual_stale_duplicate_target_policy=1\n",mode);
}
static void admission_guard(unsigned mode)
{
    struct env e; setup(&e,2);
    if(mode==2) e.source->stratum=false;
    struct dizzass_tx88_prepared p=prepare(&e,3); finish(&e,&p,DIZZASS_TX_WRITTEN); offer(&e,3);
    if(mode==0) Q(dizzass_submitter_stop(e.submitter)==0);
    if(mode==1) e.thr.id=1;
    struct dizzass_early_rx_submission s,unchanged; memset(&s,0x63,sizeof s); unchanged=s;
    int expected=mode==0?DIZZASS_SUBMIT_STOPPED:mode==1?DIZZASS_SUBMIT_WRONG_THREAD:DIZZASS_SUBMIT_UNSUPPORTED_WORK;
    unsigned before=atomic_load(&native_calls);
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==expected);
    Q(memcmp(&s,&unchanged,sizeof s)==0 && dizzass_early_rx_size(e.q)==1);
    Q(atomic_load(&native_calls)==before && queue_empty(&e));
    close_env(&e); ++cases; printf("R03_GATE mode=%u retained=1\n",mode);
}
static void pending_skip(void)
{
    struct env e; setup(&e,3); struct dizzass_tx88_prepared a=prepare(&e,2),b=prepare(&e,3);
    offer(&e,2); offer(&e,3); finish(&e,&b,DIZZASS_TX_WRITTEN);
    struct dizzass_early_rx_submission s={0}; Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
    native_result(&e,&s,3); Q(dizzass_early_rx_size(e.q)==1); take_genesis(&e);
    finish(&e,&a,DIZZASS_TX_UNCERTAIN); Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
    Q(s.job_status==DIZZASS_JOBS_QUARANTINED && s.captured.slot==2 && !s.native_called);
    close_env(&e); ++cases; puts("R03_PENDING skipped_not_lost=1");
}
static void direct_guards(void)
{
    struct env e; setup(&e,2); struct dizzass_tx88_prepared p=prepare(&e,3);
    finish(&e,&p,DIZZASS_TX_WRITTEN); struct dizzass_nonce_reply r=reply(3);
    struct dizzass_submit_result s,unchanged; memset(&s,0x63,sizeof s); unchanged=s;
    struct dizzass_job_ticket t=p.ticket; unsigned before=atomic_load(&native_calls);
    Q(dizzass_submitter_run_captured(e.submitter,e.f.jobs,NULL,&r,&s)==DIZZASS_SUBMIT_INVALID);
    ++t.serial; Q(dizzass_submitter_run_captured(e.submitter,e.f.jobs,&t,&r,&s)==DIZZASS_JOBS_STALE_TICKET);
    t=p.ticket; --t.epoch; Q(dizzass_submitter_run_captured(e.submitter,e.f.jobs,&t,&r,&s)==DIZZASS_JOBS_OLD_EPOCH);
    t=p.ticket; ++t.chain_id; Q(dizzass_submitter_run_captured(e.submitter,e.f.jobs,&t,&r,&s)==DIZZASS_JOBS_WRONG_CHAIN);
    t=p.ticket; r.slot=2; Q(dizzass_submitter_run_captured(e.submitter,e.f.jobs,&t,&r,&s)==DIZZASS_NONCE_WRONG_SLOT);
    r=reply(3); r.chain_id=3; Q(dizzass_submitter_run_captured(e.submitter,e.f.jobs,&t,&r,&s)==DIZZASS_JOBS_WRONG_CHAIN);
    Q(memcmp(&s,&unchanged,sizeof s)==0 && atomic_load(&native_calls)==before && queue_empty(&e));
    close_env(&e); ++cases; puts("R03_CAPTURE guards_before_native=1");
}
static void after_admission(bool hw)
{
    struct env e; setup(&e,2); struct dizzass_tx88_prepared p=prepare(&e,3);
    finish(&e,&p,DIZZASS_TX_WRITTEN); struct dizzass_nonce_reply r=reply(3);
    if(hw) ++r.nonce_word;
    Q(dizzass_early_rx_offer(e.q,17,&r)==0);
    if(hw) pause_from_hw=e.f.jobs; else pause_after_admission=e.f.jobs;
    struct dizzass_early_rx_submission s={0}; Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
    pause_after_admission=pause_from_hw=NULL;
    Q(s.native_called && s.job_status==0 && dizzass_jobs_ticket_live(e.f.jobs,&p.ticket)==DIZZASS_JOBS_PAUSED);
    if(hw) Q(!s.result.native_valid_nonce && e.cgpu.hw_errors==1 && queue_empty(&e));
    else { native_result(&e,&s,3); take_genesis(&e); }
    close_env(&e); ++cases; printf("R03_ADMITTED hw_callback=%d registry_unlocked_copy_owned=1\n",hw);
}
static void overflow_stop(bool stop)
{
    struct env e; setup(&e,1); struct dizzass_tx88_prepared p=prepare(&e,3);
    finish(&e,&p,DIZZASS_TX_WRITTEN); offer(&e,3);
    if(stop) Q(dizzass_early_rx_stop(e.q)==0);
    else { struct dizzass_nonce_reply r=reply(3); Q(dizzass_early_rx_offer(e.q,17,&r)==DIZZASS_EARLY_RX_OVERFLOW); }
    unsigned before=atomic_load(&native_calls); struct dizzass_early_rx_submission s={0};
    Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==(stop?DIZZASS_EARLY_RX_STOPPED:DIZZASS_EARLY_RX_OVERFLOW));
    Q(dizzass_early_rx_size(e.q)==1 && atomic_load(&native_calls)==before && queue_empty(&e));
    close_env(&e); ++cases; printf("R03_INBOX_REFUSAL stop=%d no_native_call=1\n",stop);
}
struct owner { struct env *e; int rc; struct dizzass_early_rx_submission receipt; };
static void *owner_thread(void *v)
{
    struct owner *o=v; int saved;
    Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0);
    o->rc=dizzass_early_rx_dispatch(o->e->q,o->e->submitter,&o->receipt);
    Q(pthread_setcancelstate(saved,NULL)==0); pthread_testcancel(); return NULL;
}
static void cancellation(void)
{
    struct env e; setup(&e,2); struct dizzass_tx88_prepared p=prepare(&e,3);
    finish(&e,&p,DIZZASS_TX_WRITTEN); offer(&e,3);
    hold_submit=true; entered_submit=release_submit=false;
    struct owner o={.e=&e,.rc=999}; pthread_t th;
    Q(pthread_create(&th,NULL,owner_thread,&o)==0);
    struct timespec until; Q(clock_gettime(CLOCK_REALTIME,&until)==0); until.tv_sec+=3;
    Q(pthread_mutex_lock(&submit_lock)==0);
    while(!entered_submit) Q(pthread_cond_timedwait(&submit_changed,&submit_lock,&until)==0);
    Q(pthread_mutex_unlock(&submit_lock)==0);
    Q(pthread_cancel(th)==0);
    Q(pthread_mutex_lock(&submit_lock)==0); release_submit=true;
    Q(pthread_cond_broadcast(&submit_changed)==0); Q(pthread_mutex_unlock(&submit_lock)==0);
    void *ret=NULL; Q(pthread_join(th,&ret)==0 && ret==PTHREAD_CANCELED); hold_submit=false;
    Q(o.rc==0 && dizzass_early_rx_size(e.q)==0); native_result(&e,&o.receipt,3); take_genesis(&e);
    close_env(&e); ++cases; puts("R03_CANCEL owner_exclusion_submit_consume_receipt=1");
}
static void all_slots(void)
{
    struct env e; setup(&e,32); unsigned before=atomic_load(&native_calls);
    for(unsigned i=0;i<32;++i) {
        uint8_t wire[88];
        struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(
            e.f.jobs,e.f.channel,17,2,0,i,2,e.source,r01_now()+1000,32);
        Q(r.finish_status==0 && r.outcome==DIZZASS_TX_WRITTEN);
        r01_read(e.f.peer,wire,sizeof wire);
        struct dizzass_nonce_reply rx=r01_reply(&e.f,i,i%11+1);
        Q(dizzass_early_rx_offer(e.q,17,&rx)==0);
    }
    free_work(e.source);
    for(unsigned i=0;i<32;++i) {
        struct dizzass_early_rx_submission s={0};
        Q(dizzass_early_rx_dispatch(e.q,e.submitter,&s)==0);
        Q(s.native_called && s.captured.slot==i && s.result.ticket.slot==i);
        /* Same public nonce vector: the native device-wide last-nonce policy
         * accepts the first and rejects 31 duplicates. Not ASIC error rates. */
        Q(s.result.native_valid_nonce==(i==0));
        Q(dizzass_jobs_retire(e.f.jobs,&s.captured)==0);
    }
    Q(dizzass_early_rx_size(e.q)==0 && atomic_load(&native_calls)==before+32);
    Q(e.cgpu.diff1==1 && e.cgpu.hw_errors==31);
    take_genesis(&e); close_env(&e); ++cases;
    puts("R03_SLOTS actual_a16_sends=32 captured_dispatches=32 native_duplicate_policy=1");
}
int main(void)
{
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug=false; opt_quiet=true; opt_realquiet=true;
    opt_submit_stale=false; opt_benchmark=false;
    Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,NULL)==0);
    int64_t accepted=total_accepted;
    for(size_t i=1;i<=11;++i) early(i);
    for(unsigned i=0;i<6;++i) reject(i);
    for(unsigned i=0;i<4;++i) copy_retry(i);
    for(unsigned i=0;i<7;++i) core_outcome(i);
    for(unsigned i=0;i<3;++i) admission_guard(i);
    pending_skip(); direct_guards(); after_admission(false); after_admission(true);
    overflow_stop(false); overflow_stop(true); cancellation(); all_slots();
    Q(total_accepted==accepted);
    printf("R03_PASS cases=%u checks=%u native_calls=%u real_stratum_queue=1 network=0\n",cases,atomic_load(&checks),atomic_load(&native_calls));
    return 0;
}
