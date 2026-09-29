/* GPL-3.0-or-later. Real core queued-work -> managed TX -> strict RX.
 * Host PTYs and known synthetic nonce frames, never a physical miner. */
#define R04_OWNER_EMBED
#include "integration/review/rx_owner/test.c"
#include "integration/native/queued_work_tx.h"
#include "integration/review/rx_integrity/vectors.h"
#include <math.h>
static unsigned q9_cases;
static _Atomic unsigned q9_checks, get_calls, complete_calls, managed_calls;
#define C9(x) do { atomic_fetch_add(&q9_checks,1); if(!(x)) { fprintf(stderr,"R09_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static struct work *acquired;
static struct dizzass_io_lifecycle *stop_after_get;
static bool block_completion, completion_entered, completion_release;
static pthread_mutex_t completion_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t completion_cond=PTHREAD_COND_INITIALIZER;
static void cancellation_disabled(void)
{
    int saved;
    C9(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0);
    C9(saved==PTHREAD_CANCEL_DISABLE);
}
struct work *__real_get_queued(struct cgpu_info *);
struct work *__wrap_get_queued(struct cgpu_info *g)
{
    cancellation_disabled(); atomic_fetch_add(&get_calls,1);
    acquired=__real_get_queued(g);
    if(acquired) C9(find_queued_work_byid(g,acquired->id)==acquired);
    if(stop_after_get) C9(dizzass_io_request_stop(stop_after_get)==0);
    return acquired;
}
void __real_work_completed(struct cgpu_info *,struct work *);
void __wrap_work_completed(struct cgpu_info *g,struct work *w)
{
    cancellation_disabled();
    C9(w==acquired && find_queued_work_byid(g,w->id)==w);
    C9(pthread_mutex_lock(&completion_lock)==0);
    if(block_completion) {
        completion_entered=true; C9(pthread_cond_broadcast(&completion_cond)==0);
        while(!completion_release) C9(pthread_cond_wait(&completion_cond,&completion_lock)==0);
    }
    C9(pthread_mutex_unlock(&completion_lock)==0);
    __real_work_completed(g,w); acquired=NULL;
    atomic_fetch_add(&complete_calls,1);
}
int __real_dizzass_io_send_work(struct dizzass_io_lifecycle *,uint32_t,uint32_t,uint32_t,uint32_t,const struct work *,uint64_t,unsigned,struct dizzass_io_work_receipt *);
int __wrap_dizzass_io_send_work(struct dizzass_io_lifecycle *io,uint32_t p,uint32_t a,uint32_t s,uint32_t v,const struct work *w,uint64_t deadline,unsigned budget,struct dizzass_io_work_receipt *r)
{
    cancellation_disabled(); C9(w==acquired);
    atomic_fetch_add(&managed_calls,1);
    return __real_dizzass_io_send_work(io,p,a,s,v,w,deadline,budget,r);
}
struct qenv { struct env e; struct dizzass_io_lifecycle *io; };
static struct dizzass_queued_tx_plan plan(unsigned slot)
{ return (struct dizzass_queued_tx_plan){2,0,slot,2,r01_now()+3000,32}; }
static void init(struct qenv *q,bool start)
{
    setup(&q->e);q->io=NULL;
    acquired=NULL;stop_after_get=NULL;block_completion=false;completion_entered=false;completion_release=false;
    atomic_store(&get_calls,0);atomic_store(&complete_calls,0);atomic_store(&managed_calls,0);
    rwlock_init(&q->e.cgpu.qlock);cglock_init(&q->e.pool.data_lock);
    q->e.pool.swork.job_id=strdup("r01-job"); C9(q->e.pool.swork.job_id);
    struct dizzass_rx_owner_config c=config(&q->e,64);c.board_selector=2;c.chip_selector=4;c.poll_ms=10;
    C9(dizzass_io_create_crc5(&c,q->e.f.channel,&q->io)==0);
    if(start) C9(dizzass_io_start(q->io)==0);
}
static struct work *stage(struct qenv *q)
{
    struct work *w=copy_work_noffset(q->e.source,0);C9(w);
    wr_lock(&q->e.cgpu.qlock);C9(!q->e.cgpu.unqueued_work);
    q->e.cgpu.unqueued_work=w;wr_unlock(&q->e.cgpu.qlock);return w;
}
static void gone(struct qenv *q)
{ C9(!q->e.cgpu.unqueued_work && !q->e.cgpu.queued_work && q->e.cgpu.queued_count==0); }
static void close_q(struct qenv *q)
{
    struct dizzass_io_report r;
    C9(dizzass_io_stop(q->io,r01_now()+3000,&r)==0 && r.quiescent && !r.active_tx);
    C9(dizzass_io_destroy(&q->io)==0);
    /* All helper callers are joined BEFORE native queue / pool teardown. */
    flush_queue(&q->e.cgpu);gone(q);rwlock_destroy(&q->e.cgpu.qlock);
    free(q->e.pool.swork.job_id);q->e.pool.swork.job_id=NULL;cglock_destroy(&q->e.pool.data_lock);
    cleanup(&q->e);
}
static int send_q(struct qenv *q,unsigned slot,struct dizzass_queued_tx_receipt *r)
{ struct dizzass_queued_tx_plan p=plan(slot);return dizzass_queued_work_send(&q->e.thr,q->io,&p,r); }
static void written(const struct dizzass_queued_tx_receipt *r,uint32_t id)
{
    C9(r->dequeued && r->completed && r->work_id==id && r->work_thr_id==0);
    C9(!r->work_status && r->send_called && !r->send_status && !r->send.notify_status);
    C9(r->send.send.prepare_called && !r->send.send.prepare_status && r->send.send.finish_called);
    C9(!r->send.send.finish_status && r->send.send.outcome==DIZZASS_TX_WRITTEN);
}
static void preflight(unsigned which)
{
    struct qenv q;init(&q,which!=0);struct work *w=stage(&q);
    struct dizzass_queued_tx_plan p=plan(3);
    struct dizzass_queued_tx_receipt r,before;memset(&r,0x55,sizeof r);before=r;
    struct thr_info *t=&q.e.thr;struct dizzass_io_lifecycle *io=q.io;
    const struct dizzass_queued_tx_plan *arg=&p;struct dizzass_queued_tx_receipt *out=&r;
    int expected=EINVAL;
    if(which==0)expected=ENOTCONN;
    if(which==1){C9(dizzass_io_request_stop(q.io)==0);expected=ECANCELED;}
    if(which==2){p.deadline_ms=0;expected=ETIMEDOUT;}
    if(which==3)p.platform=1;
    if(which==4)p.algorithm=1;
    if(which==5)p.variant=1;
    if(which==6)p.slot=32;
    if(which==7)p.max_no_progress=0;
    if(which==8)t=NULL;
    if(which==9)io=NULL;
    if(which==10)arg=NULL;
    if(which==11)out=NULL;
    if(which==12)q.e.thr.id=-1;
    C9(dizzass_queued_work_send(t,io,arg,out)==expected);
    C9(!atomic_load(&get_calls) && !atomic_load(&complete_calls));
    C9(q.e.cgpu.unqueued_work==w && !q.e.cgpu.queued_count && !q.e.cgpu.queued_work);
    C9(memcmp(&r,&before,sizeof r)==0);r01_empty(q.e.f.peer);
    q.e.thr.id=0;close_q(&q);++q9_cases;
}
static void q_no_work(unsigned mode)
{
    struct qenv q;init(&q,true);
    int64_t discarded=total_discarded;
    if(mode) {
        struct work *w=stage(&q);w->clone=false;w->rolls=0;w->mined=false;
        q.e.pool.quota_used=q.e.pool.works=10;
        if(mode==1)w->work_block=work_block+1;
        if(mode==2){free(w->job_id);w->job_id=strdup("stale-job");}
        if(mode==3)q.e.pool.stratum_active=false;
        if(mode==4)q.e.pool.stratum_notify=false;
        if(mode==5)w->tv_staged.tv_sec-=1000;
    }
    struct dizzass_queued_tx_receipt r={0};C9(send_q(&q,3,&r)==0);
    C9(!r.dequeued && !r.completed && !r.send_called);
    C9(atomic_load(&get_calls)==1 && !atomic_load(&complete_calls) && !atomic_load(&managed_calls));
    C9(total_discarded==discarded+(mode?1:0));gone(&q);r01_empty(q.e.f.peer);close_q(&q);++q9_cases;
}
static void metadata(unsigned which)
{
    struct qenv q;init(&q,true);struct work *w=stage(&q);uint32_t id=w->id;
    if(which==0)w->thr_id=77;
    if(which==1)w->stratum=false;
    if(which==2){free(w->nonce1);w->nonce1=NULL;}
    if(which==3){free(w->ntime);w->ntime=NULL;}
    if(which==4)w->device_diff=0;
    if(which==5)w->work_difficulty=NAN;
    if(which==6)w->device_diff=INFINITY;
    if(which==7)w->work_difficulty=-1;
    struct dizzass_queued_tx_receipt r={0};C9(send_q(&q,3,&r)==0);
    C9(r.dequeued && r.completed && r.work_id==id && !r.send_called);
    C9(r.work_status==(which?DIZZASS_SUBMIT_UNSUPPORTED_WORK:DIZZASS_SUBMIT_WRONG_THREAD));
    C9(atomic_load(&complete_calls)==1 && !atomic_load(&managed_calls));
    gone(&q);r01_empty(q.e.f.peer);close_q(&q);++q9_cases;
}
struct qsender {struct qenv *q;struct dizzass_queued_tx_plan p;struct dizzass_queued_tx_receipt r;int rc;};
static void *qthread(void *v)
{struct qsender *s=v;s->rc=dizzass_queued_work_send(&s->q->e.thr,s->q->io,&s->p,&s->r);pthread_testcancel();return NULL;}
static void early_q(unsigned cap,bool cancel)
{
    struct qenv q;init(&q,true);read_cap=cap;struct work *w=stage(&q);uint32_t id=w->id;
    uint8_t expected[88],bytes[88];C9(dizzass_native_work_tx88(w,2,0,3,expected,88)==0);
    r01_hook(R01_HOLD,q.e.f.host);struct qsender s={.q=&q,.p=plan(3),.rc=-999};pthread_t tx;
    C9(pthread_create(&tx,NULL,qthread,&s)==0);r01_wait_hook();r01_read(q.e.f.peer,bytes,88);C9(memcmp(bytes,expected,88)==0);
    C9(q.e.cgpu.queued_count==1 && find_queued_work_byid(&q.e.cgpu,id)==w);
    peer_write(&q.e,r08_nonce[3],11);wait_events(&q.e,1);
    C9(q.e.events[0].kind==DIZZASS_RX_QUEUED && q.e.events[0].integrity_verified && queue_empty(&q.e));
    if(cancel)C9(pthread_cancel(tx)==0);
    r01_release_hook();void *ret=NULL;C9(pthread_join(tx,&ret)==0);
    C9(ret==(cancel?PTHREAD_CANCELED:NULL));written(&s.r,id);gone(&q);
    C9(atomic_load(&get_calls)==1 && atomic_load(&complete_calls)==1 && atomic_load(&managed_calls)==1);
    /* Deferred cancellation may arrive on restore OR the next testcancel. */
    if(cancel)C9(s.rc==-999 || s.rc==0);else C9(s.rc==0);
    free_work(q.e.source);wait_events(&q.e,2);
    C9(q.e.events[1].submission.captured.serial==s.r.send.send.ticket.serial);
    take_genesis(&q.e);close_q(&q);++q9_cases;
    printf("R09_EARLY cap=%u cancelled=%d real_core_queue=1 strict_rx=1\n",cap,cancel);
}
static void copy_failure(unsigned index)
{
    struct qenv q;init(&q,true);stage(&q);atomic_store(&fail_strdup,(int)index);
    struct dizzass_queued_tx_receipt r={0};C9(send_q(&q,3,&r)==0);
    C9(r.dequeued && r.completed && r.send_called && r.send.send.prepare_status==DIZZASS_NONCE_PARTIAL_COPY);
    C9(!r.send.send.channel_called && !r.send.send.finish_called && !r.send.send.ticket.serial);
    C9(atomic_load(&complete_calls)==1);gone(&q);r01_empty(q.e.f.peer);
    atomic_store(&fail_strdup,-1);uint32_t id=stage(&q)->id;C9(send_q(&q,3,&r)==0);written(&r,id);
    uint8_t p[88];r01_read(q.e.f.peer,p,88);C9(atomic_load(&complete_calls)==2);
    gone(&q);close_q(&q);++q9_cases;
}
static void transport_fault(bool late)
{
    struct qenv q;init(&q,true);stage(&q);struct dizzass_queued_tx_plan p=plan(3);
    if(late){p.deadline_ms=r01_now()+30;r01_late_until=p.deadline_ms+5;}
    r01_hook(late?R01_LATE:R01_PREFIX_EIO,q.e.f.host);
    struct dizzass_queued_tx_receipt r={0};C9(dizzass_queued_work_send(&q.e.thr,q.io,&p,&r)==0);
    C9(r.completed && r.send.send.finish_called && r.send.send.outcome==DIZZASS_TX_UNCERTAIN);
    C9(r.send.send.transport.written==(late?88:5));
    C9(r.send.send.transport.status==(late?DIZZASS_UART_TIMEOUT:DIZZASS_UART_WRITE_ERROR));
    uint8_t b[88];r01_read(q.e.f.peer,b,late?88:5);r01_empty(q.e.f.peer);
    C9(atomic_load(&complete_calls)==1);gone(&q);close_q(&q);++q9_cases;
}
static void stop_race(void)
{
    struct qenv q;init(&q,true);stage(&q);stop_after_get=q.io;
    struct dizzass_queued_tx_receipt r={0};C9(send_q(&q,3,&r)==0);
    C9(r.dequeued && r.completed && r.send_called && r.send_status==ECANCELED);
    C9(!r.send.send.prepare_called && atomic_load(&complete_calls)==1);
    gone(&q);r01_empty(q.e.f.peer);close_q(&q);++q9_cases;
}
static void completion_window(void)
{
    struct qenv q;init(&q,true);uint32_t id=stage(&q)->id;
    block_completion=true;struct qsender s={.q=&q,.p=plan(3),.rc=-999};pthread_t tx;
    C9(pthread_create(&tx,NULL,qthread,&s)==0);
    C9(pthread_mutex_lock(&completion_lock)==0);
    while(!completion_entered)C9(pthread_cond_wait(&completion_cond,&completion_lock)==0);
    C9(pthread_mutex_unlock(&completion_lock)==0);
    struct dizzass_io_report report;C9(dizzass_io_stop(q.io,r01_now()+1000,&report)==0 && report.quiescent);
    C9(q.e.cgpu.queued_count==1 && find_queued_work_byid(&q.e.cgpu,id));
    C9(!atomic_load(&complete_calls));C9(pthread_cancel(tx)==0);
    C9(pthread_mutex_lock(&completion_lock)==0);completion_release=true;C9(pthread_cond_broadcast(&completion_cond)==0);C9(pthread_mutex_unlock(&completion_lock)==0);
    void *ret;C9(pthread_join(tx,&ret)==0 && ret==PTHREAD_CANCELED);
    C9(s.r.completed && s.r.dequeued && (s.rc==-999 || s.rc==0) && atomic_load(&complete_calls)==1);
    gone(&q);uint8_t b[88];r01_read(q.e.f.peer,b,88);close_q(&q);++q9_cases;
    puts("R09_OUTER_LIFETIME io_quiescence_is_not_core_queue_completion=1");
}
static void existing_queue(void)
{
    struct qenv q;init(&q,true);struct work *other=copy_work_noffset(q.e.source,0);add_queued(&q.e.cgpu,other);
    uint32_t id=stage(&q)->id;struct dizzass_queued_tx_receipt r={0};C9(send_q(&q,3,&r)==0);written(&r,id);
    C9(q.e.cgpu.queued_count==1 && find_queued_work_byid(&q.e.cgpu,other->id)==other);
    C9(!find_queued_work_byid(&q.e.cgpu,id));__real_work_completed(&q.e.cgpu,other);gone(&q);
    uint8_t b[88];r01_read(q.e.f.peer,b,88);close_q(&q);++q9_cases;
}
static void all_slots(void)
{
    struct qenv q;init(&q,true);unsigned calls=atomic_load(&native_calls);
    struct dizzass_queued_tx_receipt r={0};uint8_t b[88];
    for(unsigned i=0;i<32;++i){uint32_t id=stage(&q)->id;C9(send_q(&q,i,&r)==0);written(&r,id);gone(&q);
        C9(r.send.send.ticket.slot==i);r01_read(q.e.f.peer,b,88);peer_write(&q.e,r08_nonce[i],11);wait_events(&q.e,2*(i+1));}
    C9(atomic_load(&get_calls)==32 && atomic_load(&complete_calls)==32);
    C9(atomic_load(&native_calls)==calls+32 && q.e.cgpu.diff1==1 && q.e.cgpu.hw_errors==31);
    take_genesis(&q.e);C9(queue_empty(&q.e));
    /* An occupied wire slot is not reclaimed when its ORIGINAL queue work dies. */
    stage(&q);C9(send_q(&q,0,&r)==0 && r.completed && r.send.send.prepare_status==DIZZASS_JOBS_BUSY);
    C9(!r.send.send.channel_called && atomic_load(&complete_calls)==33);r01_empty(q.e.f.peer);gone(&q);
    close_q(&q);++q9_cases;puts("R09_SLOTS native_queue_32=1 no_slot_reuse=1");
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    pthread_mutex_t stage_lock;mutex_init(&stage_lock);stgd_lock=&stage_lock;C9(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    for(unsigned i=0;i<13;++i)preflight(i);
    for(unsigned i=0;i<6;++i)q_no_work(i);
    for(unsigned i=0;i<8;++i)metadata(i);
    for(unsigned i=1;i<=11;++i)early_q(i,false);early_q(1,true);
    for(unsigned i=0;i<4;++i)copy_failure(i);
    transport_fault(false);transport_fault(true);stop_race();completion_window();existing_queue();all_slots();
    C9(pthread_cond_destroy(&gws_cond)==0);C9(pthread_mutex_destroy(&stage_lock)==0);stgd_lock=NULL;
    printf("R09_PASS cases=%u checks=%u native_calls=%u core_queue=1 physical_asic=0\n",q9_cases,atomic_load(&q9_checks),atomic_load(&native_calls));return 0;
}
