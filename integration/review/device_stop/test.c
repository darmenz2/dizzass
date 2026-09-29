/* GPL-3.0-or-later. R-07 uses real prior RX/native/PTY helpers, no hardware. */
#define R04_OWNER_EMBED
#include "integration/review/rx_owner/test.c"
#include "integration/native/io_stop_many.h"
static unsigned r07_cases, r07_checks;
#define G(x) do { ++r07_checks; if (!(x)) { fprintf(stderr,"R07_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static struct dizzass_io_lifecycle *watched[DIZZASS_IO_STOP_MANY_MAX];
static size_t watched_count;
static bool audit;
static int request_fault=-1, stop_fault=-1;
static uint64_t same_deadline;
static _Atomic unsigned requests, stop_calls;
static struct dizzass_jobs *held_finish;
static _Atomic unsigned finish_entered, finish_release;
static size_t index_of(struct dizzass_io_lifecycle *p)
{ size_t i; for(i=0;i<watched_count && watched[i]!=p;++i) {} Q(i<watched_count); return i; }
static void guarded(void)
{ int saved; Q(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0); Q(saved==PTHREAD_CANCEL_DISABLE); }
int __real_dizzass_io_request_stop(struct dizzass_io_lifecycle *);
int __wrap_dizzass_io_request_stop(struct dizzass_io_lifecycle *p)
{
    if(!audit) return __real_dizzass_io_request_stop(p);
    guarded(); size_t i=index_of(p); atomic_fetch_add(&requests,1);
    int rc=__real_dizzass_io_request_stop(p);
    /* Explicit wake-error script AFTER the real admission latch is set. */
    return (int)i==request_fault ? EIO : rc;
}
int __real_dizzass_io_stop(struct dizzass_io_lifecycle *,uint64_t,struct dizzass_io_report *);
int __wrap_dizzass_io_stop(struct dizzass_io_lifecycle *p,uint64_t deadline,struct dizzass_io_report *out)
{
    if(!audit) return __real_dizzass_io_stop(p,deadline,out);
    guarded(); Q(deadline==same_deadline);
    for(size_t i=0;i<watched_count;++i) { struct dizzass_io_report state;
        Q(dizzass_io_snapshot(watched[i],&state)==0); Q(state.stop_requested); }
    size_t i=index_of(p); atomic_fetch_add(&stop_calls,1);
    /* Script a child error before its full stop; other child stops stay real. */
    if((int)i==stop_fault) return EAGAIN;
    return __real_dizzass_io_stop(p,deadline,out);
}
int __real_dizzass_jobs_finish(struct dizzass_jobs *,const struct dizzass_job_ticket *,enum dizzass_tx_result);
int __wrap_dizzass_jobs_finish(struct dizzass_jobs *j,const struct dizzass_job_ticket *t,enum dizzass_tx_result r)
{
    if(j==held_finish) { atomic_store(&finish_entered,1); wait_uint(&finish_release,1); }
    return __real_dizzass_jobs_finish(j,t,r);
}
struct group { size_t n; struct env *env; struct dizzass_io_lifecycle *io[DIZZASS_IO_STOP_MANY_MAX]; };
static void open_group(struct group *g,size_t n,bool start)
{
    memset(g,0,sizeof *g);g->n=n;g->env=calloc(n,sizeof *g->env);G(g->env);
    audit=false;request_fault=stop_fault=-1;held_finish=NULL;
    atomic_store(&finish_entered,0);atomic_store(&finish_release,0);
    for(size_t i=0;i<n;++i) {
        setup(&g->env[i]);
        dizzass_jobs_destroy(&g->env[i].f.jobs);
        G(dizzass_jobs_create((uint32_t)(2+i),17,&g->env[i].f.jobs)==0);
    }
    /* Configure every fixture BEFORE starting readers: no test-global races. */
    receive_fd=-1; r01_hook(R01_NORMAL,-1);
    for(size_t i=0;i<n;++i) {
        struct dizzass_rx_owner_config c=config(&g->env[i],32);
        c.chain_id=(uint32_t)(2+i);c.submitter=g->env[0].submitter;c.poll_ms=10;
        G(dizzass_io_create(&c,g->env[i].f.channel,&g->io[i])==0);
        if(start)G(dizzass_io_start(g->io[i])==0);
    }
}
static void watch(struct group *g,uint64_t deadline)
{
    watched_count=g->n;memcpy(watched,g->io,g->n*sizeof g->io[0]);same_deadline=deadline;
    atomic_store(&requests,0);atomic_store(&stop_calls,0);audit=true;
}
static void close_group(struct group *g)
{
    audit=false;held_finish=NULL;
    for(size_t i=0;i<g->n;++i) {
        struct dizzass_io_report r;G(dizzass_io_stop(g->io[i],r01_now()+2000,&r)==0);
    }
    /* All shared-submitter users are joined BEFORE any fixture frees it. */
    for(size_t i=0;i<g->n;++i) {
        G(dizzass_io_destroy(&g->io[i])==0 && !g->io[i]);
        G(fcntl(g->env[i].f.host,F_GETFL)>=0);
    }
    for(size_t i=0;i<g->n;++i) cleanup(&g->env[i]);
    free(g->env);
}
static void complete(const struct group *g,const struct dizzass_io_stop_many_report *r)
{
    G(r->all_quiescent && !r->first_error && !r->cancel_restore_status);
    G(r->count==g->n && r->requested==g->n && r->attempted==g->n && r->quiescent==g->n);
    for(size_t i=0;i<g->n;++i) {
        G(!r->entries[i].request_status && !r->entries[i].stop_status);
        G(r->entries[i].io.quiescent && !r->entries[i].io.active_tx && r->entries[i].io.jobs_paused);
        G(fcntl(g->env[i].f.host,F_GETFL)>=0);
    }
}
static void send_group_one(struct group *g,size_t i)
{
    struct dizzass_io_work_receipt r;uint8_t actual[88],expected[88];
    G(dizzass_io_send_work(g->io[i],2,0,3,2,g->env[i].source,r01_now()+2000,32,&r)==0);
    G(r.send.outcome==DIZZASS_TX_WRITTEN && !r.send.finish_status);
    r01_read(g->env[i].f.peer,actual,88);
    G(dizzass_native_work_tx88(g->env[i].source,2,0,3,expected,88)==0);
    G(!memcmp(actual,expected,88));
}
static void basic(size_t n,bool start)
{
    struct group g;open_group(&g,n,start);
    if(start) for(size_t i=0;i<n;++i)send_group_one(&g,i);
    struct dizzass_io_stop_many_report r;watch(&g,r01_now()+2000);
    G(dizzass_io_stop_many(g.io,n,same_deadline,&r)==0);complete(&g,&r);
    G(atomic_load(&requests)==n && atomic_load(&stop_calls)==n);
    G(dizzass_io_stop_many(g.io,n,same_deadline,&r)==0);complete(&g,&r);
    close_group(&g);++r07_cases;printf("R07_BASIC chains=%zu started=%d\n",n,start);
}
static void invalid(unsigned kind)
{
    struct group g;open_group(&g,3,true);watch(&g,0);
    struct dizzass_io_stop_many_report r,before;memset(&r,0xa5,sizeof r);before=r;
    struct dizzass_io_lifecycle *m[3];memcpy(m,g.io,sizeof m);
    size_t n=3;struct dizzass_io_lifecycle **input=m;
    struct dizzass_io_stop_many_report *output=&r;
    if(kind==0)input=NULL;if(kind==1)n=0;if(kind==2)n=17;if(kind==3)n=SIZE_MAX;
    if(kind==4)output=NULL;if(kind==5)m[0]=NULL;if(kind==6)m[2]=NULL;
    if(kind==7)m[1]=m[0];if(kind==8)m[2]=m[0];
    G(dizzass_io_stop_many(input,n,0,output)==EINVAL);
    G(!memcmp(&r,&before,sizeof r) && !atomic_load(&requests) && !atomic_load(&stop_calls));
    for(size_t i=0;i<g.n;++i){struct dizzass_io_report s;G(dizzass_io_snapshot(g.io[i],&s)==0 && !s.stop_requested);}
    close_group(&g);++r07_cases;printf("R07_INVALID kind=%u no_effects=1\n",kind);
}
static void failed_child(size_t i,bool wake)
{
    struct group g;open_group(&g,3,true);watch(&g,r01_now()+2000);
    if(wake)request_fault=(int)i;else stop_fault=(int)i;
    struct dizzass_io_stop_many_report r;
    G(dizzass_io_stop_many(g.io,g.n,same_deadline,&r)==(wake ? EIO : EAGAIN));
    G(!r.all_quiescent && r.first_error==(wake ? EIO : EAGAIN));
    G(r.requested==3 && r.attempted==3 && atomic_load(&stop_calls)==3);
    G(r.quiescent==(wake ? 3u : 2u));
    G((wake ? r.entries[i].request_status : r.entries[i].stop_status)==(wake ? EIO : EAGAIN));
    request_fault=stop_fault=-1;
    G(dizzass_io_stop_many(g.io,g.n,same_deadline,&r)==0);complete(&g,&r);
    close_group(&g);++r07_cases;printf("R07_ERROR member=%zu wake=%d other_members_attempted=1 retry=1\n",i,wake);
}
struct producer {struct group *g;size_t index;int rc;struct dizzass_io_work_receipt receipt;};
static void *produce(void *arg)
{
    struct producer *p=arg;p->rc=dizzass_io_send_work(p->g->io[p->index],2,0,3,2,
        p->g->env[p->index].source,r01_now()+3000,32,&p->receipt);return NULL;
}
static void pending_tx(size_t i,bool finish)
{
    struct group g;open_group(&g,3,true);
    if(finish)held_finish=g.env[i].f.jobs;else r01_hook(R01_HOLD,g.env[i].f.host);
    struct producer p={.g=&g,.index=i};pthread_t tx;G(pthread_create(&tx,NULL,produce,&p)==0);
    if(finish)wait_uint(&finish_entered,1);else r01_wait_hook();
    uint8_t wire[88];r01_read(g.env[i].f.peer,wire,88);
    if(finish) {struct dizzass_uart_channel_state s;
        G(dizzass_uart_channel_snapshot(g.env[i].f.channel,&s)==0 && !s.active);}
    watch(&g,r01_now());struct dizzass_io_stop_many_report r;
    G(dizzass_io_stop_many(g.io,g.n,same_deadline,&r)==ETIMEDOUT);
    G(!r.all_quiescent && r.attempted==3 && r.quiescent==2);
    G(r.entries[i].io.active_tx==1 && !r.entries[i].io.jobs_paused);
    G(dizzass_io_destroy(&g.io[i])==EBUSY);
    for(size_t j=0;j<g.n;++j)if(i!=j)G(r.entries[j].io.quiescent && r.entries[j].io.jobs_paused);
    if(finish)atomic_store(&finish_release,1);else r01_release_hook();
    G(pthread_join(tx,NULL)==0 && p.rc==0);held_finish=NULL;r01_hook(R01_NORMAL,-1);
    watch(&g,r01_now()+2000);G(dizzass_io_stop_many(g.io,g.n,same_deadline,&r)==0);complete(&g,&r);
    close_group(&g);++r07_cases;printf("R07_PENDING member=%zu after_write=%d timeout_no_release=1 retry=1\n",i,finish);
}
struct controller {struct group *g;int rc;struct dizzass_io_stop_many_report report;};
static void *control(void *arg)
{
    struct controller *c=arg;c->rc=dizzass_io_stop_many(c->g->io,c->g->n,same_deadline,&c->report);
    pthread_testcancel();return NULL;
}
static void submit_inflight(bool cancel)
{
    struct group g;open_group(&g,3,true);send_group_one(&g,0);
    Q(pthread_mutex_lock(&hold_lock)==0);hold_native=true;native_entered=false;native_release=false;Q(pthread_mutex_unlock(&hold_lock)==0);
    uint8_t f[11];frame(3,f);peer_write(&g.env[0],f,11);
    struct timespec limit;Q(clock_gettime(CLOCK_REALTIME,&limit)==0);limit.tv_sec+=4;
    Q(pthread_mutex_lock(&hold_lock)==0);
    while(!native_entered)Q(pthread_cond_timedwait(&hold_cond,&hold_lock,&limit)==0);
    Q(pthread_mutex_unlock(&hold_lock)==0);
    watch(&g,r01_now()+3000);struct controller c={.g=&g};pthread_t thread;
    G(pthread_create(&thread,NULL,control,&c)==0);wait_uint(&stop_calls,1);
    /* The FIRST full stop is blocked by the SHARED native submit lock.
     * Every other chain must ALREADY reject sends, no child stop needed yet. */
    G(atomic_load(&requests)==3);
    for(size_t i=0;i<g.n;++i) {
        struct dizzass_io_command_receipt denied,old;memset(&denied,0xa5,sizeof denied);old=denied;
        G(dizzass_io_send_command(g.io[i],DIZZASS_BM1368_READ_REGISTER,1,0,0,0,r01_now()+500,32,&denied)==ECANCELED);
        G(!memcmp(&denied,&old,sizeof old));r01_empty(g.env[i].f.peer);
    }
    if(cancel)G(pthread_cancel(thread)==0);
    Q(pthread_mutex_lock(&hold_lock)==0);native_release=true;Q(pthread_cond_broadcast(&hold_cond)==0);Q(pthread_mutex_unlock(&hold_lock)==0);
    void *result=NULL;G(pthread_join(thread,&result)==0);G(result==(cancel ? PTHREAD_CANCELED : NULL));
    complete(&g,&c.report);G(atomic_load(&stop_calls)==3);
    wait_events(&g.env[0],2);take_genesis(&g.env[0]);
    hold_native=false;close_group(&g);++r07_cases;
    printf("R07_SHARED_SUBMIT cancel=%d all_admission_closed_before_wait=1 receipt_saved=1\n",cancel);
}
static void two_errors(void)
{
    struct group g;open_group(&g,3,true);watch(&g,r01_now()+2000);request_fault=2;stop_fault=0;
    struct dizzass_io_stop_many_report r;G(dizzass_io_stop_many(g.io,3,same_deadline,&r)==EIO);
    G(r.first_error==EIO && r.entries[0].stop_status==EAGAIN && r.entries[2].request_status==EIO);
    G(r.attempted==3 && r.quiescent==2 && !r.all_quiescent);
    request_fault=stop_fault=-1;close_group(&g);++r07_cases;puts("R07_TWO_ERRORS preserved=1");
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;
    basic(1,true);basic(3,true);basic(16,true);basic(3,false);
    for(unsigned i=0;i<9;++i)invalid(i);
    for(size_t i=0;i<3;++i){failed_child(i,false);failed_child(i,true);pending_tx(i,false);}
    pending_tx(1,true);submit_inflight(false);submit_inflight(true);two_errors();
    printf("R07_PASS cases=%u checks=%u helper_checks=%u native_calls=%u physical_asic=0\n",r07_cases,r07_checks,atomic_load(&checks),atomic_load(&native_calls));
    return 0;
}
