/* GPL-3.0-or-later. Actual RX thread, PTYs, cgminer core and Stratum queue.
 * Nonces are historical fixtures from a scripted peer, never ASIC evidence. */
#define R01_STACK_EMBED
#include "integration/review/native_uart_stack/test_stack.c"
#include "integration/native/rx_owner.h"
#include "integration/native/native_job_channel_tx.h"
#include <sys/eventfd.h>
static _Atomic unsigned checks, native_calls, raw_polls, raw_reads, raw_bytes;
static unsigned cases;
#define Q(x) do { atomic_fetch_add(&checks,1); if(!(x)) { fprintf(stderr,"R04_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static int receive_fd=-1;
static size_t read_cap;
static _Atomic int fail_read, fail_poll, fail_eventfd, fail_create, fail_strdup=-1;
ssize_t __real_read(int,void *,size_t);
ssize_t __wrap_read(int fd,void *p,size_t n)
{
    if(fd==receive_fd) {
        atomic_fetch_add(&raw_reads,1);
        int e=atomic_exchange(&fail_read,0);
        if(e) { if(e==-1) return 0; errno=e; return -1; }
        if(read_cap && n>read_cap) n=read_cap;
    }
    ssize_t r=__real_read(fd,p,n);
    if(fd==receive_fd && r>0) atomic_fetch_add(&raw_bytes,(unsigned)r);
    return r;
}
int __real_poll(struct pollfd *,nfds_t,int);
int __wrap_poll(struct pollfd *p,nfds_t n,int timeout)
{
    if(n==2) { atomic_fetch_add(&raw_polls,1); int e=atomic_exchange(&fail_poll,0);
        if(e) { errno=e; return -1; } }
    return __real_poll(p,n,timeout);
}
int __real_eventfd(unsigned,int);
int __wrap_eventfd(unsigned n,int flags)
{ int e=atomic_exchange(&fail_eventfd,0); if(e) {errno=e;return -1;} return __real_eventfd(n,flags); }
int __real_pthread_create(pthread_t *,const pthread_attr_t *,void *(*)(void *),void *);
int __wrap_pthread_create(pthread_t *t,const pthread_attr_t *a,void *(*fn)(void *),void *v)
{ int e=atomic_exchange(&fail_create,0); return e ? e : __real_pthread_create(t,a,fn,v); }
char *__real_strdup(const char *);
char *__wrap_strdup(const char *p)
{ int n=atomic_load(&fail_strdup); if(n>=0 && atomic_fetch_sub(&fail_strdup,1)==0) return NULL; return __real_strdup(p); }
static pthread_mutex_t hold_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t hold_cond=PTHREAD_COND_INITIALIZER;
static bool hold_native, native_entered, native_release;
bool __real_submit_nonce(struct thr_info *,struct work *,uint32_t);
bool __wrap_submit_nonce(struct thr_info *t,struct work *w,uint32_t n)
{
    atomic_fetch_add(&native_calls,1);
    Q(pthread_mutex_lock(&hold_lock)==0);
    if(hold_native) {
        native_entered=true; Q(pthread_cond_broadcast(&hold_cond)==0);
        while(!native_release) Q(pthread_cond_wait(&hold_cond,&hold_lock)==0);
    }
    Q(pthread_mutex_unlock(&hold_lock)==0);
    return __real_submit_nonce(t,w,n);
}
struct env {
    struct r01_fixture f;
    struct pool pool; struct cgpu_info cgpu; struct device_drv drv; struct thr_info thr;
    struct work *source; struct dizzass_submitter *submitter; struct dizzass_rx_owner *owner;
    pthread_mutex_t lock; pthread_cond_t changed;
    struct dizzass_rx_event events[2048]; size_t count;
    unsigned queued_poll;
    int stop_kind, error_kind; bool block_callback, callback_entered, callback_release;
};
static void hw_error(struct thr_info *t) { (void)t; }
static int on_event(void *arg,const struct dizzass_rx_event *e)
{
    struct env *v=arg; int old;
    Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old)==0 && old==PTHREAD_CANCEL_DISABLE);
    Q(pthread_mutex_lock(&v->lock)==0); Q(v->count<2048); v->events[v->count++]=*e;
    if(e->kind==DIZZASS_RX_QUEUED)v->queued_poll=atomic_load(&raw_polls);
    if(v->block_callback) {
        v->callback_entered=true; Q(pthread_cond_broadcast(&v->changed)==0);
        while(!v->callback_release) Q(pthread_cond_wait(&v->changed,&v->lock)==0);
    }
    Q(pthread_cond_broadcast(&v->changed)==0); Q(pthread_mutex_unlock(&v->lock)==0);
    if(v->stop_kind==(int)e->kind) Q(dizzass_rx_owner_request_stop(v->owner)==0);
    return v->error_kind==(int)e->kind ? 771 : 0;
}
static struct dizzass_rx_owner_config config(struct env *e,size_t capacity)
{
    return (struct dizzass_rx_owner_config){.fd=e->f.host,.chain_id=2,.board_selector=1,
        .chip_selector=6,.received_epoch=17,.inbox_capacity=capacity,.poll_ms=1000,
        .jobs=e->f.jobs,.submitter=e->submitter,.context=e,.event=on_event};
}
static void setup(struct env *e)
{
    memset(e,0,sizeof *e); r01_hook(R01_NORMAL,-1); read_cap=0;
    atomic_store(&raw_polls,0); atomic_store(&raw_reads,0); atomic_store(&raw_bytes,0);
    atomic_store(&fail_read,0); atomic_store(&fail_poll,0); atomic_store(&fail_strdup,-1);
    e->f=r01_open(); receive_fd=e->f.host;
    e->drv.name="r04-offline"; e->drv.hw_error=hw_error; e->cgpu.drv=&e->drv;
    e->thr.cgpu=&e->cgpu; e->thr.id=0;
    e->pool.has_stratum=e->pool.stratum_active=e->pool.stratum_notify=true;
    e->pool.stratum_q=tq_new(); Q(e->pool.stratum_q);
    e->source=r01_work(); e->source->pool=&e->pool; e->source->stratum=true;
    e->source->thr_id=0; e->source->work_block=work_block;
    e->source->work_difficulty=e->source->device_diff=1; cgtime(&e->source->tv_staged);
    Q(dizzass_submitter_create(&e->thr,&e->submitter)==0);
    Q(pthread_mutex_init(&e->lock,NULL)==0); Q(pthread_cond_init(&e->changed,NULL)==0);
}
static bool queue_empty(struct env *e)
{
    mutex_lock(&e->pool.stratum_q->mutex); bool empty=list_empty(&e->pool.stratum_q->q);
    mutex_unlock(&e->pool.stratum_q->mutex); return empty;
}
static void take_genesis(struct env *e)
{
    Q(!queue_empty(e)); struct work *w=tq_pop(e->pool.stratum_q);
    Q(w && memcmp(w->hash,fixture_hash,32)==0 && w->pool==&e->pool);
    Q(strcmp(w->job_id,"r01-job")==0); free_work(w);
}
static void cleanup(struct env *e)
{
    if(e->owner) {
        struct dizzass_rx_owner_report r;
        Q(dizzass_rx_owner_request_stop(e->owner)==0);
        int rc=dizzass_rx_owner_join(e->owner,&r); Q(rc==0 || rc==EINVAL);
        Q(dizzass_rx_owner_destroy(&e->owner)==0);
    }
    Q(fcntl(e->f.host,F_GETFL)>=0); /* RX never closes the borrowed port. */
    Q(dizzass_submitter_stop(e->submitter)==0); dizzass_submitter_destroy(&e->submitter);
    if(e->source) free_work(e->source);
    if(e->f.channel) { Q(dizzass_uart_channel_stop(e->f.channel,r01_now()+1000)==0);
        Q(dizzass_uart_channel_destroy(&e->f.channel)==0); }
    dizzass_jobs_destroy(&e->f.jobs);
    Q(close(e->f.host)==0); if(e->f.peer>=0) Q(close(e->f.peer)==0);
    while(!queue_empty(e)) {struct work *w=tq_pop(e->pool.stratum_q);free_work(w);}
    tq_free(e->pool.stratum_q); Q(pthread_cond_destroy(&e->changed)==0); Q(pthread_mutex_destroy(&e->lock)==0);
    receive_fd=-1;
}
static void wait_uint(_Atomic unsigned *v,unsigned target)
{
    uint64_t until=r01_now()+4000;
    while(atomic_load(v)<target) {Q(r01_now()<until); struct timespec t={0,1000000};nanosleep(&t,NULL);}
}
static void wait_done(struct env *e)
{
    uint64_t until=r01_now()+4000;
    while(!dizzass_rx_owner_finished(e->owner)) {Q(r01_now()<until);struct timespec t={0,1000000};nanosleep(&t,NULL);}
}
static void wait_events(struct env *e,size_t n)
{
    struct timespec until; Q(clock_gettime(CLOCK_REALTIME,&until)==0); until.tv_sec+=4;
    Q(pthread_mutex_lock(&e->lock)==0);
    while(e->count<n) Q(pthread_cond_timedwait(&e->changed,&e->lock,&until)==0);
    Q(pthread_mutex_unlock(&e->lock)==0);
}
static struct dizzass_rx_owner_report stop_join(struct env *e)
{
    struct dizzass_rx_owner_report r;
    Q(dizzass_rx_owner_request_stop(e->owner)==0); wait_done(e);
    Q(dizzass_rx_owner_join(e->owner,&r)==0); return r;
}
static void frame(unsigned slot,uint8_t f[11])
{
    memset(f,0,11); f[0]=0xaa;f[1]=0x55;f[10]=0x80;f[7]=(uint8_t)(slot<<3);
    for(unsigned i=0;i<4;++i) f[2+i]=fixture_words[79-i];
}
static void peer_write(struct env *e,const uint8_t *p,size_t n)
{ Q(__real_write(e->f.peer,p,n)==(ssize_t)n); }
static void send_one(struct env *e,unsigned slot)
{
    uint8_t p[88],expected[88];Q(dizzass_native_work_tx88(e->source,2,0,slot,expected,88)==0);
    struct dizzass_native_job_tx_receipt r=dizzass_native_job_channel_send(e->f.jobs,e->f.channel,17,2,0,slot,2,e->source,r01_now()+3000,32);
    Q(r.finish_called && r.finish_status==0 && r.outcome==DIZZASS_TX_WRITTEN);
    r01_read(e->f.peer,p,88); Q(memcmp(expected,p,88)==0);
}
struct sender {struct env *e;struct dizzass_native_job_tx_receipt r;};
static void *send_thread(void *p)
{ struct sender *s=p;s->r=dizzass_native_job_channel_send(s->e->f.jobs,s->e->f.channel,17,2,0,3,2,s->e->source,r01_now()+3000,32);return NULL; }
static void early(size_t cap,bool notify)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,8); if(!notify)c.poll_ms=10;
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);read_cap=cap;
    r01_hook(R01_HOLD,e.f.host);struct sender s={.e=&e};pthread_t tx;
    Q(pthread_create(&tx,NULL,send_thread,&s)==0);r01_wait_hook();uint8_t p[88],f[11];r01_read(e.f.peer,p,88);
    Q(dizzass_rx_owner_start(e.owner)==0);frame(3,f);peer_write(&e,f,11);wait_events(&e,1);
    Q(e.events[0].kind==DIZZASS_RX_QUEUED && e.events[0].epoch==17 && queue_empty(&e));
    wait_uint(&raw_polls,e.queued_poll+1);
    r01_release_hook();Q(pthread_join(tx,NULL)==0 && s.r.finish_status==0);
    memset(e.source->data,0x4a,sizeof e.source->data);e.source->job_id[0]='X';free_work(e.source);
    if(notify)Q(dizzass_rx_owner_notify(e.owner)==0);wait_events(&e,2);
    struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.reason==DIZZASS_RX_STOP_REQUEST && r.offered==1 && r.dispatched==1 && !r.pending_replies);
    Q(r.bytes_read==11 && r.read_calls>=(11+cap-1)/cap);
    if(notify)Q(r.wake_reads>=1);
    Q(e.events[1].kind==DIZZASS_RX_DISPATCHED && e.events[1].submission.native_called);
    Q(e.events[1].submission.captured.epoch==17 && e.events[1].submission.result.native_valid_nonce);
    take_genesis(&e);Q(queue_empty(&e));cleanup(&e);++cases;
    printf("R04_EARLY cap=%zu notify=%d native_queue=1\n",cap,notify);
}
static void lifecycle(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,4);struct dizzass_rx_owner_report r,again;
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);Q(dizzass_rx_owner_join(e.owner,&r)==EINVAL);
    Q(dizzass_rx_owner_request_stop(e.owner)==0);Q(dizzass_rx_owner_start(e.owner)==ECANCELED);
    Q(dizzass_rx_owner_destroy(&e.owner)==0);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    Q(dizzass_rx_owner_start(e.owner)==0);Q(dizzass_rx_owner_start(e.owner)==EALREADY);
    Q(dizzass_rx_owner_destroy(&e.owner)==EBUSY);wait_uint(&raw_polls,1);
    r=stop_join(&e);Q(dizzass_rx_owner_join(e.owner,&again)==0 && memcmp(&r,&again,sizeof r)==0);
    Q(r.reason==0 && !r.bytes_read && !r.pending_replies);cleanup(&e);++cases;puts("R04_LIFECYCLE idle_wake_join=1");
}
static void stop_partial(bool complete_batch)
{
    struct env e;setup(&e);send_one(&e,3);uint8_t f[22];frame(3,f);frame(3,f+11);
    if(complete_batch)e.stop_kind=DIZZASS_RX_QUEUED;
    struct dizzass_rx_owner_config c=config(&e,4);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    peer_write(&e,f,complete_batch?22:5);Q(dizzass_rx_owner_start(e.owner)==0);
    if(complete_batch)wait_done(&e);else wait_uint(&raw_polls,2);
    struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.reason==0 && !r.dispatched && queue_empty(&e));
    if(complete_batch)Q(r.pending_replies==1 && r.unprocessed_batch_bytes==11 && r.bytes_read==22);
    else Q(r.partial_frame_bytes==5 && r.bytes_read==5 && r.pending_replies==0);
    cleanup(&e);++cases;printf("R04_STOP_PARTIAL batch=%d retained_counts=1\n",complete_batch);
}
static void mixed(void)
{
    struct env e;setup(&e);send_one(&e,3);uint8_t data[36]={1,2,3};frame(3,data+3);frame(3,data+14);frame(3,data+25);
    data[35]=0;data[32]=0x42; /* Last frame becomes an explicit register event. */
    struct dizzass_rx_owner_config c=config(&e,8);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    peer_write(&e,data,sizeof data);Q(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,5);
    struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.reason==0 && r.noise_bytes==3 && r.nonce_frames==2 && r.register_frames==1 && r.dispatched==2);
    Q(e.events[4].kind==DIZZASS_RX_REGISTER && e.events[4].message.register_address==0x42);
    take_genesis(&e);Q(queue_empty(&e) && e.cgpu.hw_errors==1);cleanup(&e);++cases;puts("R04_MIXED noise_register_duplicate=1");
}
static void io_case(int which)
{
    struct env e;setup(&e);send_one(&e,3);uint8_t f[11];frame(3,f);
    struct dizzass_rx_owner_config c=config(&e,4);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    if(which<4)atomic_store(&fail_read,which==0?EINTR:which==1?EAGAIN:which==2?EIO:-1);
    else if(which<6)atomic_store(&fail_poll,which==4?EINTR:EIO);
    if(which!=6)peer_write(&e,f,11);else {Q(close(e.f.peer)==0);e.f.peer=-1;}
    Q(dizzass_rx_owner_start(e.owner)==0);
    bool transient=which==0 || which==1 || which==4;
    if(transient)wait_events(&e,2);else wait_done(&e);
    struct dizzass_rx_owner_report r=stop_join(&e);
    if(transient) {Q(r.reason==0 && r.dispatched==1);take_genesis(&e);}
    else Q(r.reason==DIZZASS_RX_IO_ERROR && r.detail==(which==3?EPIPE:EIO) && !r.dispatched);
    cleanup(&e);++cases;printf("R04_IO mode=%d real_or_explicit_fault=1\n",which);
}
static void overflow(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,1);
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);r01_hook(R01_HOLD,e.f.host);
    struct sender s={.e=&e};pthread_t tx;Q(pthread_create(&tx,NULL,send_thread,&s)==0);r01_wait_hook();uint8_t p[88],f[22];r01_read(e.f.peer,p,88);frame(3,f);frame(3,f+11);
    Q(dizzass_rx_owner_start(e.owner)==0);peer_write(&e,f,22);wait_done(&e);
    struct dizzass_rx_owner_report r;Q(dizzass_rx_owner_join(e.owner,&r)==0);
    Q(r.reason==DIZZASS_RX_INBOX_ERROR && r.detail==DIZZASS_EARLY_RX_OVERFLOW && r.pending_replies==1);
    struct dizzass_uart_channel_state state;Q(dizzass_uart_channel_snapshot(e.f.channel,&state)==0 && state.active);
    Q(queue_empty(&e));r01_release_hook();Q(pthread_join(tx,NULL)==0);cleanup(&e);++cases;puts("R04_OVERFLOW rx_finished_tx_still_borrows_fd=1");
}
static void copy_retry(void)
{
    struct env e;setup(&e);send_one(&e,3);struct dizzass_rx_owner_config c=config(&e,4);c.poll_ms=5;
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);atomic_store(&fail_strdup,0);uint8_t f[11];frame(3,f);peer_write(&e,f,11);
    Q(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,2);struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.copy_retries==1 && r.dispatched==1 && !r.pending_replies);take_genesis(&e);cleanup(&e);++cases;puts("R04_COPY retry_without_new_bytes=1");
}
static void rejection(int which)
{
    struct env e;setup(&e);send_one(&e,3);struct dizzass_rx_owner_config c=config(&e,4);
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    if(which==0)Q(dizzass_jobs_pause(e.f.jobs,17)==0);
    if(which==1) {Q(dizzass_jobs_pause(e.f.jobs,17)==0);Q(dizzass_jobs_begin_drained_epoch(e.f.jobs,17,18)==0);}
    uint8_t f[11];frame(which==2?4:3,f);peer_write(&e,f,11);
    Q(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,1);struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.rejected==1 && !r.offered && !r.dispatched && e.events[0].kind==DIZZASS_RX_REJECTED);
    Q(e.events[0].status==(which==0?DIZZASS_JOBS_PAUSED:which==1?DIZZASS_JOBS_OLD_EPOCH:DIZZASS_JOBS_EMPTY));
    Q(queue_empty(&e));cleanup(&e);++cases;printf("R04_REJECT mode=%d original_epoch=1\n",which);
}
static void callback_failure(void)
{
    struct env e;setup(&e);send_one(&e,3);e.error_kind=DIZZASS_RX_QUEUED;
    struct dizzass_rx_owner_config c=config(&e,4);Q(dizzass_rx_owner_create(&c,&e.owner)==0);uint8_t f[11];frame(3,f);peer_write(&e,f,11);
    Q(dizzass_rx_owner_start(e.owner)==0);wait_done(&e);struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.reason==DIZZASS_RX_CALLBACK_ERROR && r.detail==771 && r.pending_replies==1 && !r.dispatched);
    cleanup(&e);++cases;puts("R04_CALLBACK failure_no_silent_replay=1");
}
static void stop_inflight(void)
{
    struct env e;setup(&e);send_one(&e,3);struct dizzass_rx_owner_config c=config(&e,4);
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);hold_native=true;native_entered=native_release=false;
    uint8_t f[11];frame(3,f);peer_write(&e,f,11);Q(dizzass_rx_owner_start(e.owner)==0);
    Q(pthread_mutex_lock(&hold_lock)==0);while(!native_entered)Q(pthread_cond_wait(&hold_cond,&hold_lock)==0);Q(pthread_mutex_unlock(&hold_lock)==0);
    Q(dizzass_rx_owner_request_stop(e.owner)==0 && !dizzass_rx_owner_finished(e.owner));
    Q(dizzass_rx_owner_destroy(&e.owner)==EBUSY);
    Q(pthread_mutex_lock(&hold_lock)==0);native_release=true;Q(pthread_cond_broadcast(&hold_cond)==0);Q(pthread_mutex_unlock(&hold_lock)==0);
    struct dizzass_rx_owner_report r=stop_join(&e);hold_native=false;
    Q(r.reason==0 && r.dispatched==1 && e.count==2 && e.events[1].submission.native_called);
    take_genesis(&e);cleanup(&e);++cases;puts("R04_STOP inflight_receipt_delivered_before_join=1");
}
static void guards(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,4),bad;
    for(unsigned i=0;i<12;++i) {
        bad=c;
        if(i==0)bad.fd=-1;if(i==1)bad.jobs=NULL;if(i==2)bad.submitter=NULL;
        if(i==3)bad.event=NULL;if(i==4)bad.received_epoch=0;if(i==5)bad.poll_ms=0;
        if(i==6)bad.poll_ms=1001;if(i==7)bad.inbox_capacity=0;if(i==8)bad.inbox_capacity=1025;
        if(i==9)bad.board_selector=5;if(i==10)bad.chip_selector=9;if(i==11)bad.special_mode=2;
        Q(dizzass_rx_owner_create(&bad,&e.owner)!=0 && !e.owner);
    }
    int flags=fcntl(e.f.host,F_GETFL);Q(fcntl(e.f.host,F_SETFL,flags&~O_NONBLOCK)==0);
    Q(dizzass_rx_owner_create(&c,&e.owner)==EINVAL);Q(fcntl(e.f.host,F_SETFL,flags)==0);
    struct termios term,original;Q(tcgetattr(e.f.host,&term)==0);original=term;
    term.c_lflag|=ICANON;Q(tcsetattr(e.f.host,TCSANOW,&term)==0);Q(dizzass_rx_owner_create(&c,&e.owner)==EINVAL);
    Q(tcsetattr(e.f.host,TCSANOW,&original)==0);
    atomic_store(&fail_eventfd,EMFILE);Q(dizzass_rx_owner_create(&c,&e.owner)==EMFILE && !e.owner);
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);atomic_store(&fail_create,EAGAIN);
    Q(dizzass_rx_owner_start(e.owner)==EAGAIN);Q(dizzass_rx_owner_start(e.owner)==0);
    stop_join(&e);cleanup(&e);++cases;puts("R04_GUARDS no_unvalidated_fd_or_start=1");
}

static void burst(void)
{
    struct env e;setup(&e);uint8_t data[32*11];
    for(unsigned i=0;i<32;++i) {send_one(&e,i);frame(i,data+11*i);}
    free_work(e.source);
    struct dizzass_rx_owner_config c=config(&e,64);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    peer_write(&e,data,sizeof data);Q(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,64);
    struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.bytes_read==sizeof data && r.nonce_frames==32 && r.dispatched==32 && !r.partial_frame_bytes && !r.pending_replies);
    for(unsigned i=0;i<32;++i)Q(e.events[i*2+1].submission.captured.slot==i && e.events[i*2+1].submission.native_called);
    take_genesis(&e);Q(queue_empty(&e) && e.cgpu.hw_errors==31);cleanup(&e);++cases;
    puts("R04_BURST slots=32 read_boundary_crossed=1 native_dedup=1");
}
static void register_kind(bool special)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,4);
    c.chip_selector=0;c.special_mode=special;
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    uint8_t f[11];frame(3,f);f[7]=0x40;f[10]=0;f[8]=0x80;
    peer_write(&e,f,special?9:11);Q(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,1);
    struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.register_frames==1 && !r.nonce_frames && !r.dispatched && !r.partial_frame_bytes);
    Q(e.events[0].kind==DIZZASS_RX_REGISTER && e.events[0].message.kind==VN135_RX_REGISTER_FILTERED);
    Q(e.events[0].message.register_address==0x40 && queue_empty(&e));cleanup(&e);++cases;
    printf("R04_REGISTER special=%d filtered_forwarded=1 crc_not_claimed=1\n",special);
}
struct joiner {struct env *e;struct dizzass_rx_owner_report report;_Atomic bool entered;};
static void *join_thread(void *p)
{
    struct joiner *j=p;atomic_store(&j->entered,true);
    Q(dizzass_rx_owner_join(j->e->owner,&j->report)==0);pthread_testcancel();return NULL;
}
static void cancel_controller(void)
{
    struct env e;setup(&e);send_one(&e,3);e.block_callback=true;
    struct dizzass_rx_owner_config c=config(&e,4);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    uint8_t f[11];frame(3,f);peer_write(&e,f,11);Q(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,1);
    Q(dizzass_rx_owner_request_stop(e.owner)==0);
    struct joiner j={.e=&e};atomic_init(&j.entered,false);memset(&j.report,0x5a,sizeof j.report);
    pthread_t t;Q(pthread_create(&t,NULL,join_thread,&j)==0);
    while(!atomic_load(&j.entered))sched_yield();Q(pthread_cancel(t)==0);
    Q(pthread_mutex_lock(&e.lock)==0);e.callback_release=true;Q(pthread_cond_broadcast(&e.changed)==0);Q(pthread_mutex_unlock(&e.lock)==0);
    void *ret=NULL;Q(pthread_join(t,&ret)==0 && ret==PTHREAD_CANCELED);
    Q(j.report.reason==DIZZASS_RX_STOP_REQUEST && j.report.pending_replies==1 && !j.report.dispatched);
    Q(dizzass_rx_owner_destroy(&e.owner)==0);cleanup(&e);++cases;
    puts("R04_JOIN_CANCEL report_and_join_state_committed=1");
}
static void reuse_fd(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,4);
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);Q(dizzass_rx_owner_start(e.owner)==0);wait_uint(&raw_polls,1);stop_join(&e);
    Q(dizzass_uart_channel_stop(e.f.channel,0)==0);Q(dizzass_uart_channel_destroy(&e.f.channel)==0);
    int old=e.f.host;Q(close(old)==0);int pipefd[2];Q(pipe(pipefd)==0);
    if(pipefd[0]!=old) {Q(dup2(pipefd[0],old)==old);Q(close(pipefd[0])==0);}
    Q(fcntl(old,F_SETFL,fcntl(old,F_GETFL)|O_NONBLOCK)==0);
    char value='X',got=0;Q(__real_write(pipefd[1],&value,1)==1);
    for(unsigned i=0;i<32;++i)Q(dizzass_rx_owner_notify(e.owner)==0);
    Q(__real_read(old,&got,1)==1 && got=='X');Q(close(pipefd[1])==0);
    cleanup(&e);++cases;puts("R04_FD_REUSE joined_reader_never_consumes_new_fd=1");
}
static void *notifier(void *p)
{ for(unsigned i=0;i<250;++i)Q(dizzass_rx_owner_notify(p)==0);return NULL; }
static void notifications(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,4);
    Q(dizzass_rx_owner_create(&c,&e.owner)==0);Q(dizzass_rx_owner_start(e.owner)==0);wait_uint(&raw_polls,1);
    pthread_t t[4];for(unsigned i=0;i<4;++i)Q(pthread_create(&t[i],NULL,notifier,e.owner)==0);
    for(unsigned i=0;i<4;++i)Q(pthread_join(t[i],NULL)==0);
    struct dizzass_rx_owner_report r=stop_join(&e);Q(!r.bytes_read && !r.callback_calls && r.reason==0);
    cleanup(&e);++cases;puts("R04_NOTIFY producers=4 signals=1000 coalescing=1");
}
static void pause_pending(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=config(&e,4);Q(dizzass_rx_owner_create(&c,&e.owner)==0);
    r01_hook(R01_HOLD,e.f.host);struct sender s={.e=&e};pthread_t tx;Q(pthread_create(&tx,NULL,send_thread,&s)==0);
    r01_wait_hook();uint8_t p[88],f[11];r01_read(e.f.peer,p,88);frame(3,f);
    Q(dizzass_rx_owner_start(e.owner)==0);peer_write(&e,f,11);wait_events(&e,1);
    Q(dizzass_jobs_pause(e.f.jobs,17)==0);Q(dizzass_rx_owner_notify(e.owner)==0);wait_events(&e,2);
    struct dizzass_rx_owner_report r=stop_join(&e);
    Q(r.dispatched==1 && !r.pending_replies && e.events[1].status==DIZZASS_JOBS_PAUSED && !e.events[1].submission.native_called);
    Q(queue_empty(&e));r01_release_hook();Q(pthread_join(tx,NULL)==0 && s.r.finish_status==DIZZASS_JOBS_PAUSED);
    cleanup(&e);++cases;puts("R04_PENDING pause_wakes_rejection_without_new_data=1");
}

int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    lifecycle();for(size_t f=1;f<=11;++f)early(f,true);early(3,false);
    stop_partial(false);stop_partial(true);mixed();for(int i=0;i<7;++i)io_case(i);
    overflow();copy_retry();for(int i=0;i<3;++i)rejection(i);callback_failure();stop_inflight();guards();
    burst();register_kind(false);register_kind(true);cancel_controller();reuse_fd();notifications();pause_pending();
    printf("R04_PASS cases=%u checks=%u native_calls=%u actual_thread=1 physical_asic=0\n",cases,atomic_load(&checks),atomic_load(&native_calls));
    return 0;
}
