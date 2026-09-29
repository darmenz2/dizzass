/* GPL-3.0-or-later. Real cgminer queue and PTYs; capacity is not hardware drain. */
#define R09_QUEUED_EMBED
#include "integration/review/queued_work/test.c"
#include "integration/native/queue_step.h"
static unsigned b11_cases;
static _Atomic unsigned b11_checks, b11_capacity_calls;
#define C11(x) do { atomic_fetch_add(&b11_checks,1); if (!(x)) { fprintf(stderr,"R11_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while (0)
static unsigned b11_race_mode;
static struct qenv *b11_env;
static struct dizzass_tx88_prepared b11_intruder;
int __real_dizzass_io_capacity(struct dizzass_io_lifecycle *,struct dizzass_job_capacity *);
int __wrap_dizzass_io_capacity(struct dizzass_io_lifecycle *io,struct dizzass_job_capacity *out)
{
    int saved; C11(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0);
    C11(saved==PTHREAD_CANCEL_DISABLE);
    unsigned n=atomic_fetch_add(&b11_capacity_calls,1);
    if (b11_race_mode==2 && n==1) C11(dizzass_io_request_stop(io)==0);
    int rc=__real_dizzass_io_capacity(io,out);
    if (!rc && n==0 && b11_race_mode==1) C11(dizzass_io_request_stop(io)==0);
    /* Explicit contract-external competing prepare: stale availability MUST
     * not overwrite a slot. This is not a supported multi-producer scheduler. */
    if (!rc && n==0 && b11_race_mode==3)
        C11(dizzass_jobs_prepare_tx88(b11_env->e.f.jobs,17,2,0,0,2,b11_env->e.source,&b11_intruder)==0);
    return rc;
}
static void b11_setup(struct qenv *q,bool start)
{
    init(q,start); b11_race_mode=0;b11_env=q;memset(&b11_intruder,0,sizeof b11_intruder);
    atomic_store(&b11_capacity_calls,0);
}
static int b11_step(struct qenv *q,struct dizzass_queue_step_receipt *r)
{ return dizzass_queued_work_step(&q->e.thr,q->io,r01_now()+3000,32,r); }
static struct dizzass_job_capacity b11_mask(struct qenv *q)
{
    struct dizzass_job_capacity c={0};
    C11(dizzass_jobs_capacity(q->e.f.jobs,17,&c)==0);
    C11(c.epoch==17 && c.chain_id==2);return c;
}
static void b11_contract(void)
{
    struct qenv q;b11_setup(&q,true);
    struct dizzass_job_capacity c,before;memset(&c,0x55,sizeof c);before=c;
    C11(dizzass_jobs_capacity(NULL,17,&c)==DIZZASS_JOBS_INVALID);
    C11(dizzass_jobs_capacity(q.e.f.jobs,17,NULL)==DIZZASS_JOBS_INVALID);
    C11(dizzass_jobs_capacity(q.e.f.jobs,16,&c)==DIZZASS_JOBS_OLD_EPOCH);
    C11(memcmp(&c,&before,sizeof c)==0);
    C11(__real_dizzass_io_capacity(NULL,&c)==EINVAL);
    C11(__real_dizzass_io_capacity(q.io,NULL)==EINVAL);
    C11(__real_dizzass_io_capacity(q.io,&c)==0 && c.unused_mask==UINT32_MAX);
    C11(!atomic_load(&get_calls) && !atomic_load(&complete_calls));
    close_q(&q);++b11_cases;
}
static void b11_preflight(unsigned mode)
{
    struct qenv q;b11_setup(&q,mode!=0);struct work *w=stage(&q);
    struct dizzass_queue_step_receipt r,before;memset(&r,0x55,sizeof r);before=r;
    struct thr_info *thr=&q.e.thr;struct dizzass_io_lifecycle *io=q.io;
    struct dizzass_queue_step_receipt *out=&r;uint64_t deadline=r01_now()+3000;unsigned budget=32;
    int expected=EINVAL;
    if(mode==0)expected=ENOTCONN;
    if(mode==1){C11(dizzass_io_request_stop(q.io)==0);expected=ECANCELED;}
    if(mode==2){C11(dizzass_jobs_pause(q.e.f.jobs,17)==0);expected=DIZZASS_JOBS_PAUSED;}
    if(mode==3)budget=0;
    if(mode==4){deadline=0;expected=ETIMEDOUT;}
    if(mode==5)thr=NULL;
    if(mode==6)io=NULL;
    if(mode==7)out=NULL;
    if(mode==8)q.e.thr.id=-1;
    if(mode==9)q.e.thr.cgpu=NULL;
    if(mode==10)q.e.cgpu.drv=NULL;
    C11(dizzass_queued_work_step(thr,io,deadline,budget,out)==expected);
    C11(!atomic_load(&get_calls) && !atomic_load(&complete_calls));
    C11(q.e.cgpu.unqueued_work==w && q.e.cgpu.queued_count==0);
    C11(memcmp(&r,&before,sizeof r)==0);r01_empty(q.e.f.peer);
    q.e.thr.id=0;q.e.thr.cgpu=&q.e.cgpu;q.e.cgpu.drv=&q.e.drv;
    close_q(&q);++b11_cases;
}
static void b11_states(void)
{
    struct qenv q;b11_setup(&q,true);struct dizzass_tx88_prepared pending={0},uncertain={0};
    C11(dizzass_jobs_prepare_tx88(q.e.f.jobs,17,2,0,0,2,q.e.source,&pending)==0);
    stage(&q);struct dizzass_queued_tx_receipt sent={0};C11(send_q(&q,1,&sent)==0);
    uint8_t bytes[88];r01_read(q.e.f.peer,bytes,88);
    C11(dizzass_jobs_prepare_tx88(q.e.f.jobs,17,2,0,2,2,q.e.source,&uncertain)==0);
    /* Registry-only outcome script; no hardware ACK or physical drain claim. */
    C11(dizzass_jobs_finish(q.e.f.jobs,&uncertain.ticket,DIZZASS_TX_UNCERTAIN)==0);
    struct dizzass_job_capacity mask=b11_mask(&q);
    C11(mask.unused_mask==(UINT32_MAX & ~UINT32_C(7)));
    struct dizzass_queue_step_receipt r={0};uint32_t id=stage(&q)->id;
    C11(b11_step(&q,&r)==0 && r.slot==3);written(&r.queued,id);r01_read(q.e.f.peer,bytes,88);
    C11(!r.queue_full && r.after_checked && !r.after_status);
    C11(dizzass_jobs_ticket_live(q.e.f.jobs,&pending.ticket)==DIZZASS_JOBS_PENDING);
    C11(dizzass_jobs_retire(q.e.f.jobs,&sent.send.send.ticket)==0);
    C11(!(b11_mask(&q).unused_mask & UINT32_C(2)));
    /* This preparation was never transmitted: only then is NOT_SENT valid. */
    C11(dizzass_jobs_finish(q.e.f.jobs,&pending.ticket,DIZZASS_TX_NOT_SENT)==0);
    id=stage(&q)->id;C11(b11_step(&q,&r)==0 && r.slot==0);written(&r.queued,id);
    C11(r.queued.send.send.ticket.serial!=pending.ticket.serial);r01_read(q.e.f.peer,bytes,88);
    gone(&q);close_q(&q);++b11_cases;
}
static void b11_empty(bool stale)
{
    struct qenv q;b11_setup(&q,true);
    if(stale){struct work *w=stage(&q);w->work_block=work_block+1;}
    struct dizzass_queue_step_receipt r={0};C11(b11_step(&q,&r)==0);
    C11(r.queue_full && !r.after_checked && !r.queued.dequeued && !r.queued.completed);
    C11(atomic_load(&get_calls)==1 && !atomic_load(&complete_calls));
    C11(b11_mask(&q).unused_mask==UINT32_MAX);gone(&q);r01_empty(q.e.f.peer);
    close_q(&q);++b11_cases;
}
static void b11_metadata(void)
{
    struct qenv q;b11_setup(&q,true);stage(&q)->device_diff=0;
    struct dizzass_queue_step_receipt r={0};C11(b11_step(&q,&r)==0);
    C11(r.queue_full && !r.after_checked && r.queued.dequeued && r.queued.completed);
    C11(r.queued.work_status==DIZZASS_SUBMIT_UNSUPPORTED_WORK && !r.queued.send_called);
    C11(b11_mask(&q).unused_mask==UINT32_MAX);gone(&q);r01_empty(q.e.f.peer);
    close_q(&q);++b11_cases;
}
static void b11_copy(unsigned index)
{
    struct qenv q;b11_setup(&q,true);stage(&q);atomic_store(&fail_strdup,(int)index);
    struct dizzass_queue_step_receipt r={0};C11(b11_step(&q,&r)==0);
    C11(r.queue_full && !r.after_checked && r.queued.completed);
    C11(r.queued.send.send.prepare_status==DIZZASS_NONCE_PARTIAL_COPY);
    C11(!r.queued.send.send.channel_called && b11_mask(&q).unused_mask==UINT32_MAX);
    gone(&q);r01_empty(q.e.f.peer);atomic_store(&fail_strdup,-1);
    uint32_t id=stage(&q)->id;C11(b11_step(&q,&r)==0 && r.slot==0 && !r.queue_full);
    written(&r.queued,id);uint8_t b[88];r01_read(q.e.f.peer,b,88);
    gone(&q);close_q(&q);++b11_cases;
}
static void b11_uncertain(bool late)
{
    struct qenv q;b11_setup(&q,true);stage(&q);uint64_t deadline=r01_now()+3000;
    if(late){deadline=r01_now()+30;r01_late_until=deadline+5;}
    r01_hook(late?R01_LATE:R01_PREFIX_EIO,q.e.f.host);
    struct dizzass_queue_step_receipt r={0};
    C11(dizzass_queued_work_step(&q.e.thr,q.io,deadline,32,&r)==0);
    C11(r.queue_full && !r.after_checked && r.queued.completed);
    C11(r.queued.send.send.outcome==DIZZASS_TX_UNCERTAIN);
    C11(r.queued.send.send.transport.written==(late?88u:5u));
    C11(!(b11_mask(&q).unused_mask & UINT32_C(1)));
    uint8_t b[88];r01_read(q.e.f.peer,b,late?88:5);r01_empty(q.e.f.peer);
    gone(&q);close_q(&q);++b11_cases;
}
static void b11_race(unsigned mode)
{
    struct qenv q;b11_setup(&q,true);struct work *w=stage(&q);
    b11_race_mode=mode;if(mode==4)stop_after_get=q.io;
    struct dizzass_queue_step_receipt r={0},before=r;
    int rc=b11_step(&q,&r);
    if(mode==1){C11(rc==ECANCELED && q.e.cgpu.unqueued_work==w);
        C11(!atomic_load(&get_calls) && memcmp(&r,&before,sizeof r)==0);}
    else {
        C11(rc==0 && r.queue_full && r.queued.completed);gone(&q);
        C11(atomic_load(&get_calls)==1 && atomic_load(&complete_calls)==1);
        if(mode==2){C11(r.after_checked && r.after_status==ECANCELED);
            uint8_t b[88];r01_read(q.e.f.peer,b,88);}
        if(mode==3){C11(r.queued.send.send.prepare_status==DIZZASS_JOBS_BUSY && !r.queued.send.send.channel_called);
            C11(dizzass_jobs_ticket_live(q.e.f.jobs,&b11_intruder.ticket)==DIZZASS_JOBS_PENDING);}
        if(mode==4)C11(r.queued.send_status==ECANCELED && !r.queued.send.send.prepare_called);
    }
    r01_empty(q.e.f.peer);close_q(&q);++b11_cases;
}
static void b11_other_queue(void)
{
    struct qenv q;b11_setup(&q,true);
    struct work *other=copy_work_noffset(q.e.source,0);C11(other);add_queued(&q.e.cgpu,other);
    uint32_t id=stage(&q)->id;struct dizzass_queue_step_receipt r={0};
    C11(b11_step(&q,&r)==0 && r.slot==0 && !r.queue_full);written(&r.queued,id);
    C11(q.e.cgpu.queued_count==1 && find_queued_work_byid(&q.e.cgpu,other->id)==other);
    __real_work_completed(&q.e.cgpu,other);uint8_t b[88];r01_read(q.e.f.peer,b,88);
    gone(&q);close_q(&q);++b11_cases;
}
static void b11_full(void)
{
    struct qenv q;b11_setup(&q,true);struct dizzass_queue_step_receipt r={0};
    struct dizzass_job_ticket first={0};uint8_t b[88];
    for(unsigned i=0;i<32;++i){uint32_t id=stage(&q)->id;C11(b11_step(&q,&r)==0);
        C11(r.slot==i && r.queue_full==(i==31));written(&r.queued,id);
        C11(r.after_checked && !r.after_status);if(!i)first=r.queued.send.send.ticket;
        r01_read(q.e.f.peer,b,88);peer_write(&q.e,r08_nonce[i],11);wait_events(&q.e,2*(i+1));gone(&q);}
    C11(b11_mask(&q).unused_mask==0 && q.e.cgpu.queued_count==0);
    struct work *pending=stage(&q);struct dizzass_queue_step_receipt before=r;
    for(unsigned i=0;i<8;++i) C11(b11_step(&q,&r)==ENOSPC);
    C11(q.e.cgpu.unqueued_work==pending && atomic_load(&get_calls)==32 && atomic_load(&complete_calls)==32);
    C11(memcmp(&r,&before,sizeof r)==0);r01_empty(q.e.f.peer);
    C11(dizzass_jobs_retire(q.e.f.jobs,&first)==0);
    C11(b11_step(&q,&r)==ENOSPC && q.e.cgpu.unqueued_work==pending);
    take_genesis(&q.e);C11(queue_empty(&q.e));close_q(&q);++b11_cases;
    puts("R11_FULL sends=32 staged_33_preserved=1 no_slot_reuse=1");
}
struct b11_sender {struct qenv *q;struct dizzass_queue_step_receipt r;int rc;};
static void *b11_thread(void *p)
{struct b11_sender *s=p;s->rc=b11_step(s->q,&s->r);pthread_testcancel();return NULL;}
static void b11_early(unsigned cap,bool cancel)
{
    struct qenv q;b11_setup(&q,true);read_cap=cap;uint32_t id=stage(&q)->id;
    r01_hook(R01_HOLD,q.e.f.host);struct b11_sender s={.q=&q,.rc=-999};pthread_t t;
    C11(pthread_create(&t,NULL,b11_thread,&s)==0);r01_wait_hook();uint8_t b[88];r01_read(q.e.f.peer,b,88);
    peer_write(&q.e,r08_nonce[0],11);wait_events(&q.e,1);
    C11(q.e.events[0].kind==DIZZASS_RX_QUEUED && queue_empty(&q.e));
    if(cancel)C11(pthread_cancel(t)==0);
    r01_release_hook();void *ret;C11(pthread_join(t,&ret)==0 && ret==(cancel?PTHREAD_CANCELED:NULL));
    C11(s.r.slot==0 && !s.r.queue_full && s.r.after_checked);written(&s.r.queued,id);gone(&q);
    wait_events(&q.e,2);C11(q.e.events[1].integrity_verified);
    C11(q.e.events[1].submission.captured.serial==s.r.queued.send.send.ticket.serial);
    take_genesis(&q.e);close_q(&q);++b11_cases;
}
static void b11_completion(void)
{
    struct qenv q;b11_setup(&q,true);stage(&q);block_completion=true;
    struct b11_sender s={.q=&q,.rc=-999};pthread_t t;C11(pthread_create(&t,NULL,b11_thread,&s)==0);
    C11(pthread_mutex_lock(&completion_lock)==0);
    while(!completion_entered)C11(pthread_cond_wait(&completion_cond,&completion_lock)==0);
    C11(pthread_mutex_unlock(&completion_lock)==0);
    struct dizzass_io_report state;C11(dizzass_io_stop(q.io,r01_now()+20,&state)==ETIMEDOUT);
    C11(state.active_queue==1 && !state.quiescent && !state.jobs_paused);
    C11(dizzass_io_destroy(&q.io)==EBUSY);C11(pthread_cancel(t)==0);
    C11(pthread_mutex_lock(&completion_lock)==0);completion_release=true;
    C11(pthread_cond_broadcast(&completion_cond)==0);C11(pthread_mutex_unlock(&completion_lock)==0);
    void *ret;C11(pthread_join(t,&ret)==0 && ret==PTHREAD_CANCELED);
    C11(s.r.queued.completed && s.r.queue_full && s.r.after_status==ECANCELED);
    gone(&q);uint8_t b[88];r01_read(q.e.f.peer,b,88);close_q(&q);++b11_cases;
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    pthread_mutex_t stage_lock;mutex_init(&stage_lock);stgd_lock=&stage_lock;C11(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    b11_contract();for(unsigned i=0;i<11;++i)b11_preflight(i);b11_states();
    b11_empty(false);b11_empty(true);b11_metadata();for(unsigned i=0;i<4;++i)b11_copy(i);
    b11_uncertain(false);b11_uncertain(true);for(unsigned i=1;i<=4;++i)b11_race(i);b11_other_queue();b11_full();
    for(unsigned i=1;i<=11;++i)b11_early(i,false);b11_early(1,true);b11_completion();
    C11(pthread_cond_destroy(&gws_cond)==0);C11(pthread_mutex_destroy(&stage_lock)==0);stgd_lock=NULL;
    printf("R11_PASS cases=%u checks=%u native_calls=%u physical_asic=0\n",b11_cases,atomic_load(&b11_checks),atomic_load(&native_calls));return 0;
}
