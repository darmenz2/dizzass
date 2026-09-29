/* GPL-3.0-or-later. Independent R-02 host integration, no miner startup. */
#define R01_STACK_EMBED
#include "integration/review/native_uart_stack/test_stack.c"
#include "integration/native/native_job_channel_tx.h"
#include "integration/native/early_rx.h"
static unsigned q_checks, q_cases;
#define Q(x) do { ++q_checks; if (!(x)) { fprintf(stderr,"RXQ_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static _Atomic int fail_strdup;
char *__real_strdup(const char *);
char *__wrap_strdup(const char *s) { if(atomic_exchange(&fail_strdup,0)) return NULL; return __real_strdup(s); }
static struct dizzass_early_rx *inbox(struct r01_fixture *f,size_t capacity)
{
    struct dizzass_early_rx *q=NULL;
    Q(dizzass_early_rx_create(f->jobs,2,17,capacity,&q)==0); return q;
}
static struct dizzass_nonce_reply synthetic_reply(unsigned slot)
{
    uint32_t n=(uint32_t)fixture_words[76]|(uint32_t)fixture_words[77]<<8|
        (uint32_t)fixture_words[78]<<16|(uint32_t)fixture_words[79]<<24;
    return (struct dizzass_nonce_reply){2,slot,2,n,0};
}
struct sender { struct r01_fixture *f; struct work *work; unsigned slot;
    struct dizzass_native_job_tx_receipt receipt; };
static void *send_actual(void *arg)
{
    struct sender *s=arg;
    s->receipt=dizzass_native_job_channel_send(s->f->jobs,s->f->channel,
        17,2,0,s->slot,2,s->work,r01_now()+3000,32);
    pthread_testcancel(); return NULL;
}
static void require_native(struct dizzass_early_rx_event *e,unsigned slot)
{
    Q(e->job_status==0 && e->result.check.work);
    Q(e->captured.epoch==17 && e->captured.chain_id==2 && e->captured.slot==slot);
    Q(e->result.ticket.serial==e->captured.serial);
    Q(e->result.check.passes_diff1 && e->result.check.meets_target);
    Q(memcmp(e->result.check.work->hash,fixture_hash,32)==0);
    Q(strcmp(e->result.check.work->job_id,"r01-job")==0);
}
/* A REAL A-16 send is held after kernel write. The fixture peer, not an ASIC,
 * supplies the nonce. The NEW inbox, not a test-held reply, retains it. */
static void early(size_t fragment,int action)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=inbox(&f,8);
    struct sender s={.f=&f,.work=r01_work(),.slot=3}; uint8_t expected[88],wire[88];
    Q(dizzass_native_work_tx88(s.work,2,0,3,expected,sizeof expected)==0);
    r01_hook(R01_HOLD,f.host); pthread_t th; Q(pthread_create(&th,NULL,send_actual,&s)==0);
    r01_wait_hook(); r01_read(f.peer,wire,sizeof wire); Q(memcmp(wire,expected,88)==0);
    struct dizzass_nonce_reply reply=r01_reply(&f,3,fragment);
    Q(dizzass_early_rx_offer(q,17,&reply)==0); memset(&reply,0xa5,sizeof reply);
    struct dizzass_early_rx_event e={0},unchanged=e;
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_WAITING);
    Q(memcmp(&e,&unchanged,sizeof e)==0 && dizzass_early_rx_size(q)==1);
    if(action==1) Q(dizzass_jobs_pause(f.jobs,17)==0);
    if(action==2) Q(pthread_cancel(th)==0);
    r01_release_hook(); void *ret=NULL; Q(pthread_join(th,&ret)==0);
    Q(ret==(action==2 ? PTHREAD_CANCELED : NULL));
    /* The PUBLIC sender no longer borrows work after join. */
    memset(s.work->data,0x6b,sizeof s.work->data); s.work->job_id[0]='X'; free_work(s.work);
    Q(dizzass_early_rx_take(q,&e)==0 && dizzass_early_rx_size(q)==0);
    if(action==1) { Q(e.job_status==DIZZASS_JOBS_PAUSED && !e.result.check.work);
        Q(s.receipt.finish_status==DIZZASS_JOBS_PAUSED && s.receipt.stop_called); }
    else require_native(&e,3);
    dizzass_early_rx_event_clear(&e); dizzass_early_rx_event_clear(&e);
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_EMPTY);
    r01_empty(f.peer); r01_empty(f.host); dizzass_early_rx_destroy(&q); r01_close(&f);
    ++q_cases; printf("RXQ_EARLY fragment=%zu action=%d actual_a16=1\n",fragment,action);
}
static void send_one(struct r01_fixture *f,unsigned slot)
{
    struct work *w=r01_work(); uint8_t bytes[88],expected[88];
    Q(dizzass_native_work_tx88(w,2,0,slot,expected,88)==0);
    struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(
        f->jobs,f->channel,17,2,0,slot,2,w,r01_now()+1000,32);
    Q(r.finish_called && r.finish_status==0 && r.outcome==DIZZASS_TX_WRITTEN);
    r01_read(f->peer,bytes,88); Q(memcmp(bytes,expected,88)==0); free_work(w);
}
static void capacity_case(size_t capacity)
{
    struct r01_fixture f=r01_open(); r01_hook(R01_NORMAL,-1); send_one(&f,3);
    struct dizzass_early_rx *q=inbox(&f,capacity); struct dizzass_nonce_reply r=synthetic_reply(3);
    for(size_t i=0;i<capacity;++i) Q(dizzass_early_rx_offer(q,17,&r)==0);
    Q(dizzass_early_rx_size(q)==capacity);
    Q(dizzass_early_rx_offer(q,18,&r)==DIZZASS_JOBS_OLD_EPOCH);
    Q(dizzass_early_rx_size(q)==capacity);
    Q(dizzass_early_rx_offer(q,17,&r)==DIZZASS_EARLY_RX_OVERFLOW);
    struct dizzass_early_rx_event e={0};
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_OVERFLOW && !e.result.check.work);
    Q(dizzass_early_rx_offer(q,17,&r)==DIZZASS_EARLY_RX_OVERFLOW);
    Q(dizzass_early_rx_stop(q)==0 && dizzass_early_rx_size(q)==capacity);
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_OVERFLOW);
    dizzass_early_rx_destroy(&q); dizzass_early_rx_destroy(&q); r01_close(&f);
    ++q_cases; printf("RXQ_OVERFLOW capacity=%zu retained_no_eviction=1\n",capacity);
}
/* Native registry outcomes below are EXPLICIT scripts, not transport ACKs.
 * This test never sends the NOT_SENT preparation, so its freeing is valid.
 */
static void stale_serial(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=inbox(&f,2);
    struct dizzass_tx88_prepared a=r01_prepare(&f,3);
    struct dizzass_nonce_reply reply=synthetic_reply(3);
    Q(dizzass_early_rx_offer(q,17,&reply)==0);
    Q(dizzass_jobs_finish(f.jobs,&a.ticket,DIZZASS_TX_NOT_SENT)==0);
    struct dizzass_tx88_prepared b=r01_prepare(&f,3);
    Q(a.ticket.serial!=b.ticket.serial);
    Q(dizzass_jobs_finish(f.jobs,&b.ticket,DIZZASS_TX_WRITTEN)==0);
    struct dizzass_early_rx_event e={0}; Q(dizzass_early_rx_take(q,&e)==0);
    Q(e.job_status==DIZZASS_JOBS_STALE_TICKET && !e.result.check.work);
    Q(e.captured.serial==a.ticket.serial);
    dizzass_early_rx_event_clear(&e); dizzass_early_rx_destroy(&q); r01_close(&f);
    ++q_cases; puts("RXQ_STALE_SERIAL replacement_not_matched=1");
}
static void old_epoch(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=inbox(&f,2);
    send_one(&f,3); struct dizzass_nonce_reply reply=synthetic_reply(3);
    Q(dizzass_early_rx_offer(q,17,&reply)==0); Q(dizzass_jobs_pause(f.jobs,17)==0);
    /* Synthetic epoch transition, no claim of physical drain. */
    Q(dizzass_jobs_begin_drained_epoch(f.jobs,17,18)==0);
    struct dizzass_early_rx_event e={0}; Q(dizzass_early_rx_take(q,&e)==0);
    Q(e.job_status==DIZZASS_JOBS_OLD_EPOCH && e.captured.epoch==17 && !e.result.check.work);
    Q(dizzass_early_rx_offer(q,18,&reply)==DIZZASS_JOBS_OLD_EPOCH);
    dizzass_early_rx_destroy(&q); r01_close(&f); ++q_cases;
    puts("RXQ_OLD_EPOCH original_epoch_preserved=1");
}
static void pending_and_errors(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=inbox(&f,4);
    struct dizzass_tx88_prepared p[3];
    for(unsigned i=0;i<3;++i) { p[i]=r01_prepare(&f,i); struct dizzass_nonce_reply r=synthetic_reply(i);
        Q(dizzass_early_rx_offer(q,17,&r)==0); }
    Q(dizzass_jobs_finish(f.jobs,&p[1].ticket,DIZZASS_TX_WRITTEN)==0);
    struct dizzass_early_rx_event e={0}; Q(dizzass_early_rx_take(q,&e)==0); require_native(&e,1);
    dizzass_early_rx_event_clear(&e); Q(dizzass_early_rx_size(q)==2);
    Q(dizzass_jobs_finish(f.jobs,&p[0].ticket,DIZZASS_TX_UNCERTAIN)==0);
    Q(dizzass_jobs_finish(f.jobs,&p[2].ticket,DIZZASS_TX_NOT_SENT)==0);
    Q(dizzass_early_rx_take(q,&e)==0 && e.job_status==DIZZASS_JOBS_QUARANTINED && e.reply.slot==0);
    dizzass_early_rx_event_clear(&e);
    Q(dizzass_early_rx_take(q,&e)==0 && e.job_status==DIZZASS_JOBS_EMPTY && e.reply.slot==2);
    dizzass_early_rx_event_clear(&e); Q(dizzass_early_rx_size(q)==0);
    dizzass_early_rx_destroy(&q); r01_close(&f); ++q_cases;
    puts("RXQ_PENDING skipped_not_dropped=1 rejection_events=2");
}
static void partial_copy(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=inbox(&f,4); send_one(&f,3);
    struct dizzass_nonce_reply reply=synthetic_reply(3); Q(dizzass_early_rx_offer(q,17,&reply)==0);
    struct dizzass_early_rx_event e={0}; atomic_store(&fail_strdup,1);
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_NONCE_PARTIAL_COPY);
    Q(dizzass_early_rx_size(q)==1 && !e.result.check.work);
    Q(dizzass_early_rx_take(q,&e)==0); require_native(&e,3);
    Q(dizzass_early_rx_offer(q,17,&reply)==0);
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_INVALID && dizzass_early_rx_size(q)==1);
    dizzass_early_rx_event_clear(&e); Q(dizzass_early_rx_take(q,&e)==0); require_native(&e,3);
    /* Result owns its copy independently of the inbox and registry. */
    dizzass_early_rx_destroy(&q); r01_close(&f); require_native(&e,3);
    dizzass_early_rx_event_clear(&e); ++q_cases; puts("RXQ_COPY_FAILURE retained_retry_owned_result=1");
}
static void guards(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=NULL;
    Q(dizzass_early_rx_create(f.jobs,2,0,1,&q)==DIZZASS_EARLY_RX_INVALID);
    Q(dizzass_early_rx_create(f.jobs,2,17,0,&q)==DIZZASS_EARLY_RX_INVALID);
    Q(dizzass_early_rx_create(f.jobs,2,17,1025,&q)==DIZZASS_EARLY_RX_INVALID);
    q=inbox(&f,2); struct dizzass_nonce_reply r=synthetic_reply(3);
    Q(dizzass_early_rx_offer(q,17,&r)==DIZZASS_JOBS_EMPTY);
    struct dizzass_tx88_prepared p=r01_prepare(&f,3); (void)p;
    struct dizzass_job_ticket t={0}; Q(dizzass_jobs_capture_reply(f.jobs,17,&r,&t)==0);
    Q(dizzass_jobs_capture_reply(f.jobs,17,&r,&t)==DIZZASS_JOBS_INVALID);
    struct dizzass_job_result result={0}; struct dizzass_nonce_reply bad=r;
    ++bad.slot; Q(dizzass_jobs_check_captured(f.jobs,&t,&bad,&result)==DIZZASS_NONCE_WRONG_SLOT);
    bad=r; ++bad.chain_id; Q(dizzass_jobs_check_captured(f.jobs,&t,&bad,&result)==DIZZASS_JOBS_WRONG_CHAIN);
    Q(dizzass_jobs_check_captured(f.jobs,NULL,&r,&result)==DIZZASS_JOBS_INVALID);
    bad=r; bad.variant=1; Q(dizzass_early_rx_offer(q,17,&bad)==DIZZASS_NONCE_WRONG_FORMAT);
    bad=r; bad.version_bits=1; Q(dizzass_early_rx_offer(q,17,&bad)==DIZZASS_NONCE_WRONG_VERSION);
    bad=r; bad.slot=32; Q(dizzass_early_rx_offer(q,17,&bad)==DIZZASS_JOBS_INVALID);
    Q(dizzass_early_rx_size(q)==0); Q(dizzass_early_rx_offer(q,17,&r)==0);
    Q(dizzass_early_rx_stop(q)==0); struct dizzass_early_rx_event e={0};
    Q(dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_STOPPED);
    Q(dizzass_early_rx_offer(q,17,&r)==DIZZASS_EARLY_RX_STOPPED);
    Q(dizzass_early_rx_size(q)==1); dizzass_early_rx_destroy(&q); r01_close(&f); ++q_cases;
    puts("RXQ_GUARDS validated_and_stopped=1");
}
static void all_slots(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_early_rx *q=inbox(&f,32);
    for(unsigned i=0;i<32;++i) { send_one(&f,i); struct dizzass_nonce_reply r=r01_reply(&f,i,i%11+1);
        Q(dizzass_early_rx_offer(q,17,&r)==0); }
    Q(dizzass_early_rx_size(q)==32);
    for(unsigned i=0;i<32;++i) { struct dizzass_early_rx_event e={0};
        Q(dizzass_early_rx_take(q,&e)==0); require_native(&e,i);
        Q(dizzass_jobs_retire(f.jobs,&e.captured)==0);
        struct dizzass_nonce_reply r=synthetic_reply(i);
        Q(dizzass_early_rx_offer(q,17,&r)==DIZZASS_JOBS_QUARANTINED);
        dizzass_early_rx_event_clear(&e); }
    Q(dizzass_early_rx_size(q)==0); dizzass_early_rx_destroy(&q); r01_close(&f); ++q_cases;
    puts("RXQ_SLOTS actual_a16_sends=32 native_matches=32");
}
int main(void)
{
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug=false; opt_quiet=true; opt_realquiet=true;
    /* Single RX owner, cancellation excluded through event cleanup. */
    Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,NULL)==0);
    for(size_t f=1;f<=11;++f) early(f,0);
    early(1,1); early(1,2);
    const size_t capacities[]={1,2,31,32,33,1024};
    for(size_t i=0;i<sizeof capacities/sizeof capacities[0];++i) capacity_case(capacities[i]);
    r01_hook(R01_NORMAL,-1); stale_serial(); old_epoch(); pending_and_errors(); partial_copy(); guards(); all_slots();
    printf("RXQ_PASS cases=%u checks=%u helper_checks=%u actual_native=1 real_pty=1 physical_asic=0\n",
        q_cases,q_checks,atomic_load(&r01_checks)); return 0;
}
