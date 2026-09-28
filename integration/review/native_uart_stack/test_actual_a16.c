/* GPL-3.0-or-later. Independent actual A-16 HOST integration tests.
 * Source/strings stay immutable throughout the public A-16 call.
 * Wrappers pause/observe REAL calls; they do not implement A-16 themselves.
 */
#define R01_STACK_EMBED 1
#include "test_stack.c"
#include "integration/native/native_job_channel_tx.h"
#define A16_CHECK(x) do { atomic_fetch_add(&r01_checks,1); if(!(x)) { \
    fprintf(stderr,"A16_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)

enum a16_point { A16_NONE, A16_BEFORE_PREPARE, A16_INSIDE_COPY,
    A16_AFTER_PREPARE, A16_IN_WRITE, A16_AFTER_FINISH };
static enum a16_point a16_point;
static _Thread_local bool a16_inside, a16_copying;
static pthread_mutex_t a16_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t a16_changed=PTHREAD_COND_INITIALIZER;
static bool a16_entered, a16_release;
static struct { unsigned prepares,finishes; int prepare_status,finish_status;
    struct dizzass_tx88_prepared prepared; enum dizzass_tx_result outcome; } a16_trace;

static void a16_disabled(void)
{
    int previous;
    A16_CHECK(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&previous)==0);
    A16_CHECK(previous==PTHREAD_CANCEL_DISABLE);
    A16_CHECK(pthread_setcancelstate(previous,NULL)==0);
}
static void a16_hold(enum a16_point point)
{
    if(a16_point!=point) return;
    a16_disabled(); pthread_testcancel(); /* Must NOT cancel while A-16 owns work. */
    A16_CHECK(pthread_mutex_lock(&a16_lock)==0);
    a16_entered=true; A16_CHECK(pthread_cond_broadcast(&a16_changed)==0);
    while(!a16_release) A16_CHECK(pthread_cond_wait(&a16_changed,&a16_lock)==0);
    A16_CHECK(pthread_mutex_unlock(&a16_lock)==0);
}
static void a16_wait(void)
{
    struct timespec t; A16_CHECK(clock_gettime(CLOCK_REALTIME,&t)==0); t.tv_sec+=3;
    A16_CHECK(pthread_mutex_lock(&a16_lock)==0);
    while(!a16_entered) A16_CHECK(pthread_cond_timedwait(&a16_changed,&a16_lock,&t)==0);
    A16_CHECK(pthread_mutex_unlock(&a16_lock)==0);
}
static void a16_release_hold(void)
{
    A16_CHECK(pthread_mutex_lock(&a16_lock)==0); a16_release=true;
    A16_CHECK(pthread_cond_broadcast(&a16_changed)==0);
    A16_CHECK(pthread_mutex_unlock(&a16_lock)==0);
}
char *__real_strdup(const char *);
char *__wrap_strdup(const char *s)
{
    if(a16_inside && a16_copying) a16_hold(A16_INSIDE_COPY);
    return __real_strdup(s);
}
int __real_dizzass_jobs_prepare_tx88(struct dizzass_jobs *,uint64_t,uint32_t,
    uint32_t,uint32_t,uint32_t,const struct work *,struct dizzass_tx88_prepared *);
int __wrap_dizzass_jobs_prepare_tx88(struct dizzass_jobs *j,uint64_t e,uint32_t p,
    uint32_t a,uint32_t s,uint32_t v,const struct work *w,struct dizzass_tx88_prepared *out)
{
    A16_CHECK(a16_inside); a16_disabled(); ++a16_trace.prepares;
    a16_hold(A16_BEFORE_PREPARE); a16_copying=true;
    int rc=__real_dizzass_jobs_prepare_tx88(j,e,p,a,s,v,w,out);
    a16_copying=false; a16_trace.prepare_status=rc;
    if(!rc) a16_trace.prepared=*out;
    a16_hold(A16_AFTER_PREPARE); return rc;
}
int __real_dizzass_jobs_finish(struct dizzass_jobs *,const struct dizzass_job_ticket *,enum dizzass_tx_result);
int __wrap_dizzass_jobs_finish(struct dizzass_jobs *j,const struct dizzass_job_ticket *t,
    enum dizzass_tx_result outcome)
{
    if(!a16_inside) return __real_dizzass_jobs_finish(j,t,outcome);
    a16_disabled(); ++a16_trace.finishes; a16_trace.outcome=outcome;
    int rc=__real_dizzass_jobs_finish(j,t,outcome); a16_trace.finish_status=rc;
    a16_hold(A16_AFTER_FINISH); return rc;
}
static void a16_reset(enum a16_point p)
{
    memset(&a16_trace,0,sizeof a16_trace); a16_point=p;
    a16_entered=false; a16_release=false;
}
struct a16_sender { struct r01_fixture *f; struct work *source;
    uint64_t epoch,deadline; unsigned slot,platform;
    struct dizzass_native_job_tx_receipt receipt; bool delivered; };
static struct a16_sender a16_sender(struct r01_fixture *f,unsigned slot)
{
    return (struct a16_sender){.f=f,.source=r01_work(),.epoch=17,.slot=slot,
        .platform=2,.deadline=r01_now()+3000};
}
static void *a16_send(void *arg)
{
    struct a16_sender *s=arg; a16_inside=true;
    s->receipt=dizzass_native_job_channel_send(s->f->jobs,s->f->channel,
        s->epoch,s->platform,0,s->slot,2,s->source,s->deadline,32);
    s->delivered=true; a16_inside=false; pthread_testcancel(); return NULL;
}
static void a16_source_done(struct a16_sender *s)
{
    /* This is AFTER return/join, never during the public A-16 call. */
    memset(s->source->data,0x5a,sizeof s->source->data);
    s->source->job_id[0]='X'; free_work(s->source); A16_CHECK(!s->source);
}
static void a16_ok(const struct a16_sender *s)
{
    const struct dizzass_native_job_tx_receipt *r=&s->receipt;
    A16_CHECK(s->delivered && !r->entry_error && !r->cancel_restore_error);
    A16_CHECK(r->prepare_called && r->prepare_status==0 && r->channel_called);
    A16_CHECK(r->frame_size==88 && r->transport.status==DIZZASS_UART_OK);
    A16_CHECK(r->transport.written==88 && r->transport.error==0);
    A16_CHECK(r->finish_called && r->finish_status==0 && r->outcome==DIZZASS_TX_WRITTEN);
    A16_CHECK(!r->stop_called);
    A16_CHECK(r->ticket.epoch==s->epoch && r->ticket.slot==s->slot && r->ticket.chain_id==2);
    A16_CHECK(a16_trace.prepares==1 && a16_trace.finishes==1);
}
static void a16_early(size_t fragment,bool pause)
{
    struct r01_fixture f=r01_open(); struct a16_sender s=a16_sender(&f,3);
    a16_reset(A16_NONE); r01_hook(R01_HOLD,f.host); pthread_t thread;
    A16_CHECK(pthread_create(&thread,NULL,a16_send,&s)==0); r01_wait_hook();
    uint8_t bytes[88]; r01_read(f.peer,bytes,88);
    A16_CHECK(memcmp(bytes,a16_trace.prepared.packet,88)==0);
    struct dizzass_nonce_reply reply=r01_reply(&f,3,fragment);
    struct dizzass_job_result result={0};
    A16_CHECK(dizzass_jobs_check(f.jobs,17,&reply,&result)==DIZZASS_JOBS_PENDING);
    A16_CHECK(!result.check.work);
    if(pause) A16_CHECK(dizzass_jobs_pause(f.jobs,17)==0);
    r01_release_hook(); void *ret=(void *)1;
    A16_CHECK(pthread_join(thread,&ret)==0 && ret==NULL); a16_source_done(&s);
    if(!pause) { a16_ok(&s); r01_candidate(&f,&reply); }
    else {
        A16_CHECK(s.receipt.transport.status==DIZZASS_UART_OK && s.receipt.transport.written==88);
        A16_CHECK(s.receipt.finish_called && s.receipt.finish_status==DIZZASS_JOBS_PAUSED);
        A16_CHECK(s.receipt.stop_called && s.receipt.stop_status==0);
        A16_CHECK(dizzass_jobs_check(f.jobs,17,&reply,&result)==DIZZASS_JOBS_PAUSED);
        A16_CHECK(!result.check.work);
    }
    r01_empty(f.peer); r01_empty(f.host);
    printf("R01_A16_EARLY fragment=%zu pause=%d retained_until_finish=1\n",fragment,pause);
    r01_close(&f); ++r01_cases;
}
static void a16_cancel(enum a16_point point)
{
    struct r01_fixture f=r01_open(); struct a16_sender s=a16_sender(&f,3);
    a16_reset(point); r01_hook(point==A16_IN_WRITE ? R01_HOLD : R01_NORMAL,f.host);
    pthread_t thread; A16_CHECK(pthread_create(&thread,NULL,a16_send,&s)==0);
    if(point==A16_IN_WRITE) r01_wait_hook(); else a16_wait();
    A16_CHECK(pthread_cancel(thread)==0);
    if(point==A16_IN_WRITE) r01_release_hook(); else a16_release_hold();
    void *ret=NULL; A16_CHECK(pthread_join(thread,&ret)==0 && ret==PTHREAD_CANCELED);
    A16_CHECK(a16_trace.prepares==1 && a16_trace.finishes==1);
    A16_CHECK(a16_trace.prepare_status==0 && a16_trace.finish_status==0);
    A16_CHECK(a16_trace.outcome==DIZZASS_TX_WRITTEN);
    A16_CHECK(dizzass_jobs_ticket_live(f.jobs,&a16_trace.prepared.ticket)==0);
    uint8_t bytes[88]; r01_read(f.peer,bytes,88);
    A16_CHECK(memcmp(bytes,a16_trace.prepared.packet,88)==0);
    a16_source_done(&s); struct dizzass_nonce_reply reply=r01_reply(&f,3,1);
    r01_candidate(&f,&reply); r01_empty(f.peer);
    printf("R01_A16_CANCEL point=%d finish_once=1 receipt_delivered=%d\n",point,s.delivered);
    r01_close(&f); ++r01_cases;
}

static void a16_fault(enum r01_mode mode)
{
    struct r01_fixture f=r01_open(); struct a16_sender s=a16_sender(&f,3);
    a16_reset(A16_NONE); r01_hook(mode,f.host);
    s.deadline=r01_now()+200; r01_late_until=s.deadline+25; a16_send(&s);
    struct dizzass_native_job_tx_receipt *r=&s.receipt;
    size_t count=mode==R01_PREFIX_EIO ? 5 : 88;
    A16_CHECK(r->transport.written==count && r01_accepted==count);
    A16_CHECK(r->transport.status==(mode==R01_PREFIX_EIO ? DIZZASS_UART_WRITE_ERROR : DIZZASS_UART_TIMEOUT));
    A16_CHECK(r->transport.error==(mode==R01_PREFIX_EIO ? EIO : ETIMEDOUT));
    A16_CHECK(r->outcome==DIZZASS_TX_UNCERTAIN && r->finish_status==0);
    A16_CHECK(r->stop_called && r->stop_status==0);
    A16_CHECK(a16_trace.prepares==1 && a16_trace.finishes==1);
    A16_CHECK(dizzass_jobs_ticket_live(f.jobs,&r->ticket)==DIZZASS_JOBS_QUARANTINED);
    uint8_t bytes[88]; r01_read(f.peer,bytes,count);
    A16_CHECK(memcmp(bytes,a16_trace.prepared.packet,count)==0);
    struct dizzass_protocol_tx_receipt cmd=dizzass_channel_bm1368_command(
        f.channel,DIZZASS_BM1368_INACTIVE,0,0,0,0,r01_now()+1000,32);
    A16_CHECK(cmd.channel_called && cmd.transport.status==DIZZASS_UART_CANCELED);
    r01_empty(f.peer); a16_source_done(&s);
    printf("R01_A16_UNCERTAIN bytes=%zu quarantined=1 stop_requested=1\n",count);
    r01_close(&f); ++r01_cases;
}
static void a16_reject(unsigned kind)
{
    struct r01_fixture f=r01_open(); struct a16_sender s=a16_sender(&f,3);
    a16_reset(A16_NONE); r01_hook(R01_NORMAL,-1);
    int expected;
    if(kind==0) { s.slot=32; expected=DIZZASS_TX88_INVALID; }
    else if(kind==1) { s.platform=0; expected=DIZZASS_ROUTE_UNSUPPORTED; }
    else { s.epoch=16; expected=DIZZASS_JOBS_OLD_EPOCH; }
    a16_send(&s); struct dizzass_native_job_tx_receipt *r=&s.receipt;
    A16_CHECK(r->prepare_called && r->prepare_status==expected);
    A16_CHECK(!r->channel_called && !r->finish_called && !r->stop_called && !r->ticket.serial);
    A16_CHECK(a16_trace.prepares==1 && a16_trace.finishes==0);
    struct dizzass_uart_channel_state state;
    A16_CHECK(dizzass_uart_channel_snapshot(f.channel,&state)==0 && !state.stopped && !state.has_result);
    r01_empty(f.peer); a16_source_done(&s); r01_close(&f); ++r01_cases;
    printf("R01_A16_REJECT kind=%u no_reservation_or_tx=1\n",kind);
}
static void a16_refused(bool stopped)
{
    struct r01_fixture f=r01_open(); struct a16_sender s=a16_sender(&f,3);
    a16_reset(A16_NONE); r01_hook(R01_NORMAL,-1);
    if(stopped) A16_CHECK(dizzass_uart_channel_stop(f.channel,0)==0);
    else s.deadline=r01_now()-1;
    a16_send(&s); struct dizzass_native_job_tx_receipt *r=&s.receipt;
    A16_CHECK(r->prepare_status==0 && r->channel_called && r->transport.written==0);
    A16_CHECK(r->transport.status==(stopped ? DIZZASS_UART_CANCELED : DIZZASS_UART_TIMEOUT));
    A16_CHECK(r->outcome==DIZZASS_TX_UNCERTAIN && r->finish_status==0);
    A16_CHECK(r->stop_called && r->stop_status==0);
    A16_CHECK(dizzass_jobs_ticket_live(f.jobs,&r->ticket)==DIZZASS_JOBS_QUARANTINED);
    r01_empty(f.peer); a16_source_done(&s); r01_close(&f); ++r01_cases;
    printf("R01_A16_REFUSED stopped=%d bytes=0 quarantine=1\n",stopped);
}
struct a16_filler { struct r01_fixture *f; struct dizzass_uart_result result; uint8_t bytes[16]; };
static void *a16_fill(void *v)
{
    struct a16_filler *f=v;
    f->result=dizzass_uart_channel_send(f->f->channel,f->bytes,sizeof f->bytes,r01_now()+3000,32);
    return NULL;
}
static void a16_queued(void)
{
    struct r01_fixture f=r01_open(); struct a16_sender s=a16_sender(&f,3);
    struct a16_filler filler={.f=&f}; memset(filler.bytes,0x42,sizeof filler.bytes);
    a16_reset(A16_NONE); r01_hook(R01_HOLD,f.host); pthread_t thread;
    A16_CHECK(pthread_create(&thread,NULL,a16_fill,&filler)==0); r01_wait_hook();
    uint8_t bytes[16]; r01_read(f.peer,bytes,sizeof bytes);
    A16_CHECK(memcmp(bytes,filler.bytes,sizeof bytes)==0);
    s.deadline=r01_now()+80; a16_send(&s);
    A16_CHECK(s.receipt.transport.status==DIZZASS_UART_TIMEOUT && s.receipt.transport.written==0);
    A16_CHECK(s.receipt.outcome==DIZZASS_TX_UNCERTAIN && s.receipt.finish_status==0);
    A16_CHECK(s.receipt.stop_called && s.receipt.stop_status==ETIMEDOUT);
    struct dizzass_uart_channel_state state;
    A16_CHECK(dizzass_uart_channel_snapshot(f.channel,&state)==0 && state.stopped && state.active);
    A16_CHECK(dizzass_jobs_ticket_live(f.jobs,&s.receipt.ticket)==DIZZASS_JOBS_QUARANTINED);
    r01_release_hook(); A16_CHECK(pthread_join(thread,NULL)==0);
    A16_CHECK(filler.result.status==DIZZASS_UART_OK && filler.result.written==16);
    A16_CHECK(dizzass_uart_channel_stop(f.channel,0)==0); r01_empty(f.peer);
    a16_source_done(&s); r01_close(&f); ++r01_cases;
    puts("R01_A16_QUEUE timeout=1 stop_timeout=1 fd_retained_until_owner_return=1");
}
static void a16_slots(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_job_ticket tickets[32];
    r01_hook(R01_NORMAL,-1);
    for(unsigned slot=0;slot<32;++slot) {
        struct a16_sender s=a16_sender(&f,slot); a16_reset(A16_NONE); a16_send(&s); a16_ok(&s);
        tickets[slot]=s.receipt.ticket; uint8_t bytes[88]; r01_read(f.peer,bytes,88);
        A16_CHECK(memcmp(bytes,a16_trace.prepared.packet,88)==0); a16_source_done(&s);
        struct dizzass_nonce_reply reply=r01_reply(&f,slot,3); r01_candidate(&f,&reply);
        struct a16_sender again=a16_sender(&f,slot); a16_reset(A16_NONE); a16_send(&again);
        A16_CHECK(again.receipt.prepare_status==DIZZASS_JOBS_BUSY && !again.receipt.channel_called);
        A16_CHECK(dizzass_jobs_retire(f.jobs,&tickets[slot])==0);
        a16_reset(A16_NONE); a16_send(&again);
        A16_CHECK(again.receipt.prepare_status==DIZZASS_JOBS_QUARANTINED && !again.receipt.channel_called);
        a16_source_done(&again);
    }
    struct dizzass_nonce_reply old=r01_reply(&f,3,1);
    A16_CHECK(dizzass_jobs_pause(f.jobs,17)==0);
    /* Synthetic empty-device assumption in this fixture, NOT a hardware proof. */
    A16_CHECK(dizzass_jobs_begin_drained_epoch(f.jobs,17,18)==0);
    struct a16_sender s=a16_sender(&f,3); s.epoch=18; a16_reset(A16_NONE); a16_send(&s); a16_ok(&s);
    uint8_t bytes[88]; r01_read(f.peer,bytes,88); A16_CHECK(memcmp(bytes,a16_trace.prepared.packet,88)==0);
    struct dizzass_job_result result={0};
    A16_CHECK(dizzass_jobs_check(f.jobs,17,&old,&result)==DIZZASS_JOBS_OLD_EPOCH);
    A16_CHECK(__real_dizzass_jobs_finish(f.jobs,&tickets[3],DIZZASS_TX_WRITTEN)==DIZZASS_JOBS_OLD_EPOCH);
    A16_CHECK(!result.check.work); r01_empty(f.peer); a16_source_done(&s); r01_close(&f); ++r01_cases;
    puts("R01_A16_SLOTS count=32 retained_copies_checked=32 old_epoch_rejected=1");
}
int main(void)
{
    setvbuf(stdout,NULL,_IONBF,0);
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug=false; opt_quiet=true; opt_realquiet=true;
    for(size_t n=1;n<=11;++n) a16_early(n,false);
    a16_early(1,true);
    a16_cancel(A16_BEFORE_PREPARE); a16_cancel(A16_INSIDE_COPY); a16_cancel(A16_AFTER_PREPARE);
    a16_cancel(A16_IN_WRITE); a16_cancel(A16_AFTER_FINISH);
    a16_fault(R01_PREFIX_EIO); a16_fault(R01_LATE);
    for(unsigned kind=0;kind<3;++kind) a16_reject(kind);
    a16_refused(false); a16_refused(true); a16_queued(); a16_slots();
    A16_CHECK(r01_cases==26);
    printf("R01_A16_PASS cases=%u checks=%u actual_a16=1 real_pty=1 physical_asic=0 pool_submission=0\n",
        r01_cases,atomic_load(&r01_checks)); return 0;
}
