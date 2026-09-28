/* GPL-3.0-or-later. R-01 independent HOST test, never a miner driver.
 * Real cgminer work/copy/hash helpers; only its main is renamed in this TU.
 * Scripted peer replies and injected write faults are NOT ASIC evidence.
 */
#define main r01_unused_cgminer_main
#include "cgminer.c"
#undef main
#include "integration/native_work_tx88.h"
#include "integration/native/protocol_channel_tx.h"
#include "xminer/recovery/work_rx.h"
#include "tests/fixtures/genesis_work.h"
#include <pty.h>
#include <poll.h>
#include <stdatomic.h>
#include <sys/socket.h>

static _Atomic unsigned r01_checks;
static unsigned r01_cases;
#define R01_CHECK(x) do { atomic_fetch_add(&r01_checks, 1); if (!(x)) { \
    fprintf(stderr,"R01_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); \
} } while (0)
int __wrap_socket(int a,int b,int c) { (void)a;(void)b;(void)c; abort(); }
int __wrap_connect(int a,const struct sockaddr *b,socklen_t c)
{ (void)a;(void)b;(void)c; abort(); }
int __wrap_libusb_init(void **p) { (void)p; abort(); }
ssize_t __real_write(int,const void *,size_t);

/* The hook either makes REAL kernel writes, or explicitly injects EIO.
 * HOLD returns the real write result after a caller-controlled pause.
 */
enum r01_mode { R01_NORMAL, R01_HOLD, R01_PREFIX_EIO, R01_LATE };
static enum r01_mode r01_mode;
static int r01_hook_fd = -1;
static size_t r01_accepted;
static uint64_t r01_late_until;
static pthread_mutex_t r01_hook_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t r01_hook_changed = PTHREAD_COND_INITIALIZER;
static bool r01_entered, r01_release;
static uint64_t r01_now(void)
{
    uint64_t n; R01_CHECK(dizzass_uart_posix_now_ms(&n)==0); return n;
}
ssize_t __wrap_write(int fd,const void *data,size_t size)
{
    if (fd!=r01_hook_fd || r01_mode==R01_NORMAL)
        return __real_write(fd,data,size);
    if (r01_mode==R01_PREFIX_EIO && r01_accepted) { errno=EIO; return -1; }
    size_t requested = r01_mode==R01_PREFIX_EIO && size>5 ? 5 : size;
    ssize_t n=__real_write(fd,data,requested);
    if (n<=0) return n;
    r01_accepted+=(size_t)n;
    if (r01_mode==R01_HOLD) {
        R01_CHECK(pthread_mutex_lock(&r01_hook_lock)==0);
        r01_entered=true;
        R01_CHECK(pthread_cond_broadcast(&r01_hook_changed)==0);
        while (!r01_release) R01_CHECK(pthread_cond_wait(&r01_hook_changed,&r01_hook_lock)==0);
        R01_CHECK(pthread_mutex_unlock(&r01_hook_lock)==0);
    } else if (r01_mode==R01_LATE) {
        struct timespec t={(time_t)(r01_late_until/1000),(long)(r01_late_until%1000)*1000000L};
        int e; do { e=clock_nanosleep(CLOCK_MONOTONIC,TIMER_ABSTIME,&t,NULL); } while(e==EINTR);
        R01_CHECK(e==0);
    }
    return n;
}
static void r01_hook(enum r01_mode mode,int fd)
{
    r01_mode=mode; r01_hook_fd=fd; r01_accepted=0; r01_entered=false; r01_release=false;
}
static void r01_wait_hook(void)
{
    struct timespec t; R01_CHECK(clock_gettime(CLOCK_REALTIME,&t)==0); t.tv_sec+=3;
    R01_CHECK(pthread_mutex_lock(&r01_hook_lock)==0);
    while(!r01_entered) R01_CHECK(pthread_cond_timedwait(&r01_hook_changed,&r01_hook_lock,&t)==0);
    R01_CHECK(pthread_mutex_unlock(&r01_hook_lock)==0);
}
static void r01_release_hook(void)
{
    R01_CHECK(pthread_mutex_lock(&r01_hook_lock)==0); r01_release=true;
    R01_CHECK(pthread_cond_broadcast(&r01_hook_changed)==0);
    R01_CHECK(pthread_mutex_unlock(&r01_hook_lock)==0);
}
struct r01_fixture { int peer,host; struct dizzass_uart_channel *channel; struct dizzass_jobs *jobs; };
static struct r01_fixture r01_open(void)
{
    struct r01_fixture f={.peer=-1,.host=-1}; struct termios term;
    R01_CHECK(openpty(&f.peer,&f.host,NULL,NULL,NULL)==0);
    R01_CHECK(tcgetattr(f.host,&term)==0); cfmakeraw(&term);
    R01_CHECK(tcsetattr(f.host,TCSANOW,&term)==0);
    R01_CHECK(fcntl(f.host,F_SETFL,fcntl(f.host,F_GETFL)|O_NONBLOCK)==0);
    R01_CHECK(fcntl(f.peer,F_SETFL,fcntl(f.peer,F_GETFL)|O_NONBLOCK)==0);
    R01_CHECK(dizzass_uart_channel_create(&f.channel,f.host)==0);
    R01_CHECK(dizzass_jobs_create(2,17,&f.jobs)==0);
    return f;
}
static void r01_close(struct r01_fixture *f)
{
    r01_hook(R01_NORMAL,-1);
    R01_CHECK(dizzass_uart_channel_stop(f->channel,r01_now()+1000)==0);
    R01_CHECK(dizzass_uart_channel_destroy(&f->channel)==0);
    dizzass_jobs_destroy(&f->jobs);
    R01_CHECK(close(f->host)==0); R01_CHECK(close(f->peer)==0);
}
static void r01_read(int fd,uint8_t *data,size_t size)
{
    size_t used=0; uint64_t deadline=r01_now()+2000;
    while(used<size) {
        ssize_t n=read(fd,data+used,size-used);
        if(n>0) { used+=(size_t)n; continue; }
        R01_CHECK(n<0 && (errno==EINTR || errno==EAGAIN || errno==EWOULDBLOCK));
        R01_CHECK(r01_now()<deadline); struct pollfd p={fd,POLLIN,0};
        int e=poll(&p,1,50); R01_CHECK(e>=0 || errno==EINTR);
    }
}
static void r01_empty(int fd)
{
    uint8_t b; ssize_t n=read(fd,&b,1);
    R01_CHECK(n==-1 && (errno==EAGAIN || errno==EWOULDBLOCK));
}
static struct work *r01_work(void)
{
    struct work *w=make_work(); memcpy(w->data,fixture_words,sizeof fixture_words);
    set_target(w->target,1.0); w->job_id=strdup("r01-job"); w->nonce1=strdup("00112233");
    w->ntime=strdup("495fab29"); w->coinbase=strdup("r01-owned-coinbase");
    R01_CHECK(w->job_id && w->nonce1 && w->ntime && w->coinbase); return w;
}
static struct dizzass_tx88_prepared r01_prepare(struct r01_fixture *f,unsigned slot)
{
    struct work *w=r01_work(); struct dizzass_tx88_prepared p={0};
    R01_CHECK(dizzass_jobs_prepare_tx88(f->jobs,17,2,0,slot,2,w,&p)==0);
    /* Mutate and release caller's original AFTER preparation. */
    memset(w->data,0x5a,sizeof w->data); w->job_id[0]='X'; free_work(w);
    R01_CHECK(!w); return p;
}
static struct dizzass_nonce_reply r01_reply(struct r01_fixture *f,unsigned slot,size_t fragment)
{
    uint8_t frame[11]={0xaa,0x55,0,0,0,0,0,0,0,0,0x80};
    for(unsigned j=0;j<4;++j) frame[2+j]=fixture_words[79-j]; /* BE nonce_word. */
    frame[7]=(uint8_t)(slot<<3);
    R01_CHECK(__real_write(f->peer,frame,sizeof frame)==sizeof frame);
    vn135_work_rx_stream stream; vn135_work_rx_message message;
    R01_CHECK(vn135_work_rx_stream_init(&stream,2,1,6,0)==0);
    size_t pos=0;
    while(pos<sizeof frame) {
        uint8_t part[11]; size_t n=sizeof frame-pos,used=0;
        if(n>fragment) n=fragment; r01_read(f->host,part,n);
        int e=vn135_work_rx_stream_feed(&stream,part,n,&used,&message);
        R01_CHECK(used==n); pos+=used;
        R01_CHECK(e==(pos==sizeof frame ? VN135_RX_NONCE_RAW : VN135_RX_NEED_MORE));
    }
    struct dizzass_nonce_reply r;
    R01_CHECK(dizzass_nonce_decode_payload(stream.policy.chip_selector,stream.policy.variant,
        message.chain_id,message.payload,message.payload_size,&r)==0);
    R01_CHECK(r.slot==slot && r.chain_id==2); return r;
}
static void r01_candidate(struct r01_fixture *f,const struct dizzass_nonce_reply *reply)
{
    struct dizzass_job_result r={0};
    R01_CHECK(dizzass_jobs_check(f->jobs,17,reply,&r)==0);
    R01_CHECK(r.check.work && r.check.passes_diff1 && r.check.meets_target);
    R01_CHECK(memcmp(r.check.work->hash,fixture_hash,32)==0);
    R01_CHECK(strcmp(r.check.work->job_id,"r01-job")==0);
    dizzass_job_result_clear(&r); R01_CHECK(!r.check.work);
}
static enum dizzass_tx_result r01_classify(struct dizzass_uart_result r)
{
    return r.status==DIZZASS_UART_OK && r.written==DIZZASS_TX88_SIZE && r.error==0 ?
        DIZZASS_TX_WRITTEN : DIZZASS_TX_UNCERTAIN;
}
struct r01_sender { struct r01_fixture *f; struct dizzass_tx88_prepared prepared;
    bool guard; int finish; struct dizzass_uart_result result; };
static void *r01_send_thread(void *v)
{
    struct r01_sender *s=v; int saved=0;
    if(s->guard) R01_CHECK(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0);
    s->result=dizzass_uart_channel_send(s->f->channel,s->prepared.packet,
        sizeof s->prepared.packet,r01_now()+3000,32);
    /* Deliberately unsafe caller control: a cancellation point before finish. */
    if(!s->guard) pthread_testcancel();
    s->finish=dizzass_jobs_finish(s->f->jobs,&s->prepared.ticket,r01_classify(s->result));
    if(s->guard) R01_CHECK(pthread_setcancelstate(saved,NULL)==0);
    pthread_testcancel(); return NULL;
}

static void r01_early_rx(size_t fragment)
{
    struct r01_fixture f=r01_open();
    struct r01_sender s={.f=&f,.prepared=r01_prepare(&f,3),.guard=true,.finish=999};
    r01_hook(R01_HOLD,f.host); pthread_t thread;
    R01_CHECK(pthread_create(&thread,NULL,r01_send_thread,&s)==0); r01_wait_hook();
    uint8_t bytes[88]; r01_read(f.peer,bytes,sizeof bytes);
    R01_CHECK(memcmp(bytes,s.prepared.packet,sizeof bytes)==0);
    struct dizzass_nonce_reply reply=r01_reply(&f,3,fragment);
    struct dizzass_job_result pending={0};
    R01_CHECK(dizzass_jobs_check(f.jobs,17,&reply,&pending)==DIZZASS_JOBS_PENDING);
    R01_CHECK(!pending.check.work);
    r01_release_hook(); void *ret=(void *)1;
    R01_CHECK(pthread_join(thread,&ret)==0 && ret==NULL);
    R01_CHECK(s.finish==0 && r01_classify(s.result)==DIZZASS_TX_WRITTEN);
    /* Test caller retained the early decoded reply; no new RX driver invented. */
    r01_candidate(&f,&reply); r01_empty(f.peer); r01_empty(f.host);
    printf("R01_EARLY_RX fragment=%zu pending_before_finish=1 retained_reply_valid=1\n",fragment);
    r01_close(&f); ++r01_cases;
}
static void r01_cancel_case(bool guard)
{
    struct r01_fixture f=r01_open();
    struct r01_sender s={.f=&f,.prepared=r01_prepare(&f,3),.guard=guard,.finish=999};
    r01_hook(R01_HOLD,f.host); pthread_t thread;
    R01_CHECK(pthread_create(&thread,NULL,r01_send_thread,&s)==0); r01_wait_hook();
    R01_CHECK(pthread_cancel(thread)==0); r01_release_hook(); void *ret=NULL;
    R01_CHECK(pthread_join(thread,&ret)==0 && ret==PTHREAD_CANCELED);
    uint8_t bytes[88]; r01_read(f.peer,bytes,sizeof bytes);
    R01_CHECK(memcmp(bytes,s.prepared.packet,sizeof bytes)==0);
    struct dizzass_uart_channel_state state;
    R01_CHECK(dizzass_uart_channel_snapshot(f.channel,&state)==0);
    R01_CHECK(!state.active && state.has_result && state.last.written==88);
    int live=dizzass_jobs_ticket_live(f.jobs,&s.prepared.ticket);
    if(guard) {
        R01_CHECK(s.finish==0 && live==DIZZASS_JOBS_OK);
    } else {
        R01_CHECK(s.finish==999 && live==DIZZASS_JOBS_PENDING);
        /* Diagnostic of forbidden caller sequencing, NOT an A-14 regression. */
        R01_CHECK(dizzass_jobs_finish(f.jobs,&s.prepared.ticket,DIZZASS_TX_UNCERTAIN)==0);
    }
    printf("R01_CANCELLATION outer_guard=%d bytes=88 job_status=%d\n",guard,live);
    r01_close(&f); ++r01_cases;
}
static void r01_fault_case(enum r01_mode mode)
{
    struct r01_fixture f=r01_open(); struct dizzass_tx88_prepared p=r01_prepare(&f,3);
    r01_hook(mode,f.host); uint64_t deadline=r01_now()+400; r01_late_until=deadline+25;
    struct dizzass_uart_result r=dizzass_uart_channel_send(f.channel,p.packet,sizeof p.packet,deadline,32);
    size_t expected=mode==R01_PREFIX_EIO ? 5 : 88;
    R01_CHECK(r.written==expected && r01_accepted==expected);
    R01_CHECK(r.status==(mode==R01_PREFIX_EIO ? DIZZASS_UART_WRITE_ERROR : DIZZASS_UART_TIMEOUT));
    R01_CHECK(r.error==(mode==R01_PREFIX_EIO ? EIO : ETIMEDOUT));
    uint8_t bytes[88]; r01_read(f.peer,bytes,expected);
    R01_CHECK(memcmp(bytes,p.packet,expected)==0);
    R01_CHECK(r01_classify(r)==DIZZASS_TX_UNCERTAIN);
    R01_CHECK(dizzass_jobs_finish(f.jobs,&p.ticket,r01_classify(r))==0);
    R01_CHECK(dizzass_jobs_ticket_live(f.jobs,&p.ticket)==DIZZASS_JOBS_QUARANTINED);
    struct dizzass_protocol_tx_receipt command=dizzass_channel_bm1368_command(
        f.channel,DIZZASS_BM1368_INACTIVE,0,0,0,0,r01_now()+1000,32);
    R01_CHECK(command.prepare_status==0 && command.channel_called);
    R01_CHECK(command.transport.status==DIZZASS_UART_CANCELED && command.transport.written==0);
    r01_empty(f.peer);
    printf("R01_UNCERTAIN bytes=%zu quarantined=1 inactive_refused=1 physical_off_unproved=1\n",expected);
    r01_close(&f); ++r01_cases;
}
static void r01_slots(void)
{
    struct r01_fixture f=r01_open(); struct dizzass_tx88_prepared p[32];
    r01_hook(R01_NORMAL,-1);
    for(unsigned slot=0;slot<32;++slot) {
        p[slot]=r01_prepare(&f,slot);
        struct dizzass_uart_result r=dizzass_uart_channel_send(f.channel,p[slot].packet,88,r01_now()+1000,32);
        R01_CHECK(r01_classify(r)==DIZZASS_TX_WRITTEN);
        uint8_t bytes[88]; r01_read(f.peer,bytes,sizeof bytes);
        R01_CHECK(memcmp(bytes,p[slot].packet,88)==0);
        R01_CHECK(dizzass_jobs_finish(f.jobs,&p[slot].ticket,DIZZASS_TX_WRITTEN)==0);
    }
    struct dizzass_nonce_reply old_reply=r01_reply(&f,3,1); r01_candidate(&f,&old_reply);
    struct work *w=r01_work();
    for(unsigned slot=0;slot<32;++slot) {
        struct dizzass_tx88_prepared next={0};
        R01_CHECK(dizzass_jobs_prepare_tx88(f.jobs,17,2,0,slot,2,w,&next)==DIZZASS_JOBS_BUSY);
        R01_CHECK(dizzass_jobs_retire(f.jobs,&p[slot].ticket)==0);
        R01_CHECK(dizzass_jobs_prepare_tx88(f.jobs,17,2,0,slot,2,w,&next)==DIZZASS_JOBS_QUARANTINED);
    }
    R01_CHECK(dizzass_jobs_begin_drained_epoch(f.jobs,17,18)==DIZZASS_JOBS_BUSY);
    R01_CHECK(dizzass_jobs_pause(f.jobs,17)==0);
    /* EXPLICIT synthetic test epoch boundary; never evidence of ASIC drain. */
    R01_CHECK(dizzass_jobs_begin_drained_epoch(f.jobs,17,18)==0);
    struct dizzass_tx88_prepared next={0};
    R01_CHECK(dizzass_jobs_prepare_tx88(f.jobs,18,2,0,3,2,w,&next)==0);
    struct dizzass_job_result result={0};
    R01_CHECK(dizzass_jobs_check(f.jobs,17,&old_reply,&result)==DIZZASS_JOBS_OLD_EPOCH);
    R01_CHECK(dizzass_jobs_finish(f.jobs,&p[3].ticket,DIZZASS_TX_WRITTEN)==DIZZASS_JOBS_OLD_EPOCH);
    /* This preparation NEVER entered a sender: NOT_SENT is proved in this test. */
    R01_CHECK(dizzass_jobs_finish(f.jobs,&next.ticket,DIZZASS_TX_NOT_SENT)==0);
    free_work(w); r01_close(&f); ++r01_cases;
    puts("R01_SLOTS count=32 no_in_epoch_reuse=1 stale_epoch_rejected=1 hardware_drain_unproved=1");
}
int main(void)
{
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug=false; opt_quiet=true; opt_realquiet=true;
    r01_early_rx(1); r01_early_rx(2); r01_early_rx(11);
    r01_fault_case(R01_PREFIX_EIO); r01_fault_case(R01_LATE);
    r01_cancel_case(false); r01_cancel_case(true); r01_slots();
    printf("R01_STACK_PASS cases=%u checks=%u native_work=1 real_pty=1 physical_asic=0 pool_submission=0\n",
        r01_cases,atomic_load(&r01_checks));
    return 0;
}
