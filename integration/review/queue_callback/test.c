/* GPL-3.0-or-later. Exercise REAL fill_queue/get_work, not a copied fill loop. */
#define R09_QUEUED_EMBED
#include "integration/review/queued_work/test.c"
#include "integration/native/queue_callback.h"
static unsigned n12_cases;
static _Atomic unsigned n12_checks, step_calls;
#define C12(x) do { atomic_fetch_add(&n12_checks,1); if(!(x)) { fprintf(stderr,"R12_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static int injected_step_error;
static uint32_t seen_ids[64];
static int seen_threads[64];
static bool seen_mined[64];
static double seen_diff[64];
static struct dizzass_queue_step_receipt seen_steps[64];
int __real_dizzass_queued_work_step(struct thr_info *,struct dizzass_io_lifecycle *,uint64_t,unsigned,struct dizzass_queue_step_receipt *);
int __wrap_dizzass_queued_work_step(struct thr_info *t,struct dizzass_io_lifecycle *io,uint64_t d,unsigned budget,struct dizzass_queue_step_receipt *r)
{
    int saved;C12(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&saved)==0);
    C12(saved==PTHREAD_CANCEL_DISABLE);
    unsigned i=atomic_fetch_add(&step_calls,1);C12(i<64);
    struct work *w=t->cgpu->unqueued_work;
    if(w){seen_ids[i]=w->id;seen_threads[i]=w->thr_id;seen_diff[i]=w->device_diff;seen_mined[i]=w->mined;}
    if(injected_step_error)return injected_step_error;
    int rc=__real_dizzass_queued_work_step(t,io,d,budget,r);
    if(!rc)seen_steps[i]=*r;
    return rc;
}
static pthread_mutex_t wait_lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t wait_cond=PTHREAD_COND_INITIALIZER;
static bool upstream_waiting;
int __real_pthread_cond_timedwait(pthread_cond_t *,pthread_mutex_t *,const struct timespec *);
int __wrap_pthread_cond_timedwait(pthread_cond_t *c,pthread_mutex_t *m,const struct timespec *d)
{
    if(getq && c==&getq->cond){
        C12(pthread_mutex_lock(&wait_lock)==0);upstream_waiting=true;
        C12(pthread_cond_broadcast(&wait_cond)==0);C12(pthread_mutex_unlock(&wait_lock)==0);
    }
    return __real_pthread_cond_timedwait(c,m,d);
}
struct env12 { struct qenv q; struct dizzass_queue_callback b; };
static void open12(struct env12 *v,bool start)
{
    memset(v,0,sizeof *v);init(&v->q,start);
    v->q.e.drv.min_diff=1;v->q.e.drv.max_diff=1;
    C12(dizzass_queue_callback_init(&v->b,&v->q.e.thr,v->q.io,3000,32)==0);
    v->q.e.cgpu.device_data=&v->b;v->q.e.drv.queue_full=dizzass_queue_full;
    atomic_store(&step_calls,0);injected_step_error=0;
    memset(seen_ids,0,sizeof seen_ids);memset(seen_steps,0,sizeof seen_steps);
    C12(!staged_work && !staged_rollable);
}
static void close12(struct env12 *v)
{
    /* Every callback/fill worker is joined before this fixture teardown. */
    struct work *(*volatile native_pop)(bool)=hash_pop;
    struct work *w;while((w=native_pop(false)))discard_work(w);
    v->q.e.cgpu.device_data=NULL;close_q(&v->q);
}
static uint32_t push12(struct env12 *v,bool stale,bool bad_metadata)
{
    struct work *w=copy_work_noffset(v->q.e.source,0);C12(w);
    w->thr_id=77;w->device_diff=123;w->work_difficulty=2;
    w->mined=false;w->rolltime=0;w->rolls=0;w->clone=false;
    if(stale)w->work_block=work_block+1;
    if(bad_metadata){free(w->nonce1);w->nonce1=NULL;}
    uint32_t id=w->id;C12(hash_push(w));return id;
}
/* Volatile function addresses retain the REAL static core functions even when
 * optimized, without undefined linker symbols or changing core source. */
static void (*volatile native_fill12)(struct thr_info *,struct cgpu_info *,struct device_drv *,const int)=fill_queue;
static void fill12(struct env12 *v)
{ native_fill12(&v->q.e.thr,&v->q.e.cgpu,&v->q.e.drv,v->q.e.thr.id); }
static void fill_remaining_slots(struct env12 *v)
{
    /* Registry-only fixture: untouched outstanding slots, NOT simulated drain. */
    for(unsigned i=1;i<32;++i){struct dizzass_tx88_prepared p={0};
        C12(dizzass_jobs_prepare_tx88(v->q.e.f.jobs,17,2,0,i,2,v->q.e.source,&p)==0);
        C12(dizzass_jobs_finish(v->q.e.f.jobs,&p.ticket,DIZZASS_TX_UNCERTAIN)==0);}
}
static void guards12(void)
{
    struct env12 v;open12(&v,true);struct dizzass_queue_callback b,old;
    memset(&b,0x55,sizeof b);old=b;
    C12(dizzass_queue_callback_init(NULL,&v.q.e.thr,v.q.io,10,1)==EINVAL);
    C12(dizzass_queue_callback_init(&b,NULL,v.q.io,10,1)==EINVAL);
    C12(dizzass_queue_callback_init(&b,&v.q.e.thr,NULL,10,1)==EINVAL);
    C12(dizzass_queue_callback_init(&b,&v.q.e.thr,v.q.io,0,1)==EINVAL);
    C12(dizzass_queue_callback_init(&b,&v.q.e.thr,v.q.io,10,0)==EINVAL);
    C12(!memcmp(&b,&old,sizeof b));
    C12(dizzass_queue_full(NULL));v.q.e.cgpu.device_data=NULL;C12(dizzass_queue_full(&v.q.e.cgpu));
    v.q.e.cgpu.device_data=&v.b;struct work *w=stage(&v.q);
    struct dizzass_queue_callback good=v.b;struct cgpu_info other={0};
    for(unsigned i=0;i<7;++i){v.b=good;v.q.e.drv.queue_full=dizzass_queue_full;
        if(i==0)v.b.thr=NULL;if(i==1)v.q.e.thr.id=-1;if(i==2)v.b.io=NULL;
        if(i==3)v.b.timeout_ms=0;if(i==4)v.b.max_no_progress=0;
        if(i==5)v.q.e.drv.queue_full=NULL;if(i==6)v.q.e.thr.cgpu=&other;
        C12(dizzass_queue_full(&v.q.e.cgpu));
        C12(v.b.last.status==EINVAL && !v.b.last.step_called && !v.b.last.receipt_valid);
        C12(!atomic_load(&get_calls) && v.q.e.cgpu.unqueued_work==w);
        v.q.e.thr.id=0;v.q.e.thr.cgpu=&v.q.e.cgpu;
    }
    v.b=good;v.q.e.drv.queue_full=dizzass_queue_full;close12(&v);++n12_cases;
}
static void statuses12(void)
{
    for(unsigned mode=0;mode<5;++mode){struct env12 v;open12(&v,mode!=1);
        struct work *w=mode?stage(&v.q):NULL;
        if(mode==2)C12(dizzass_io_request_stop(v.q.io)==0);
        if(mode==3)C12(dizzass_jobs_pause(v.q.e.f.jobs,17)==0);
        if(mode==4)injected_step_error=EIO;
        C12(dizzass_queue_full(&v.q.e.cgpu));
        C12(v.b.last.queue_full && v.b.last.step_called);
        if(mode==0)C12(v.b.last.receipt_valid && !v.b.last.status && !v.b.last.step.queued.dequeued);
        else {int expected=mode==1?ENOTCONN:mode==2?ECANCELED:mode==3?DIZZASS_JOBS_PAUSED:EIO;
            C12(v.b.last.status==expected && !v.b.last.receipt_valid);
            C12(!atomic_load(&get_calls) && v.q.e.cgpu.unqueued_work==w);}
        r01_empty(v.q.e.f.peer);close12(&v);
    }++n12_cases;
}
static void deadline12(void)
{
    struct env12 v;open12(&v,true);struct work *w=stage(&v.q);v.b.timeout_ms=UINT64_MAX;
    C12(dizzass_queue_full(&v.q.e.cgpu));
    C12(v.b.last.status==EOVERFLOW && !v.b.last.step_called && !v.b.last.receipt_valid);
    C12(!atomic_load(&step_calls) && v.q.e.cgpu.unqueued_work==w);close12(&v);++n12_cases;
}
static void continuation12(void)
{
    struct env12 v;open12(&v,true);uint32_t id=stage(&v.q)->id;
    C12(!dizzass_queue_full(&v.q.e.cgpu));
    C12(v.b.last.receipt_valid && !v.b.last.status && !v.b.last.queue_full);
    written(&v.b.last.step.queued,id);uint8_t data[88];r01_read(v.q.e.f.peer,data,88);
    /* Error after success MUST NOT reuse the previous valid receipt. */
    struct work *w=stage(&v.q);injected_step_error=EIO;
    C12(dizzass_queue_full(&v.q.e.cgpu));
    C12(v.b.last.status==EIO && !v.b.last.receipt_valid && !v.b.last.step.queued.dequeued);
    C12(v.q.e.cgpu.unqueued_work==w && atomic_load(&complete_calls)==1);
    close12(&v);++n12_cases;
}
static void full_native12(void)
{
    struct env12 v;open12(&v,true);uint32_t ids[34];
    for(unsigned i=0;i<34;++i)ids[i]=push12(&v,false,false);
    fill12(&v);
    C12(atomic_load(&step_calls)==32 && atomic_load(&get_calls)==32 && atomic_load(&complete_calls)==32);
    C12(HASH_COUNT(staged_work)==2 && !v.q.e.cgpu.unqueued_work && !v.q.e.cgpu.queued_count);
    C12(v.b.last.receipt_valid && v.b.last.queue_full && v.b.last.step.slot==31);
    for(unsigned i=0;i<32;++i){
        C12(seen_ids[i]==ids[i] && seen_threads[i]==0 && seen_mined[i] && seen_diff[i]==1);
        written(&seen_steps[i].queued,ids[i]);
        uint8_t bytes[88],expected[88];r01_read(v.q.e.f.peer,bytes,88);
        C12(dizzass_native_work_tx88(v.q.e.source,2,0,i,expected,88)==0 && !memcmp(bytes,expected,88));
    }
    /* Native fill_queue prefetches one work BEFORE asking queue_full. */
    fill12(&v);struct work *held=v.q.e.cgpu.unqueued_work;
    C12(held && held->id==ids[32] && HASH_COUNT(staged_work)==1);
    for(unsigned i=0;i<3;++i){fill12(&v);C12(v.q.e.cgpu.unqueued_work==held && HASH_COUNT(staged_work)==1);}
    C12(v.b.last.status==ENOSPC && !v.b.last.receipt_valid && v.b.last.queue_full);
    C12(atomic_load(&get_calls)==32 && atomic_load(&complete_calls)==32);
    C12(dizzass_jobs_retire(v.q.e.f.jobs,&seen_steps[0].queued.send.send.ticket)==0);
    fill12(&v);C12(v.q.e.cgpu.unqueued_work==held && v.b.last.status==ENOSPC);
    r01_empty(v.q.e.f.peer);close12(&v);++n12_cases;
    puts("R12_NATIVE_FILL real_get_work=1 sent=32 preserved_next=1 no_modulo_reuse=1");
}
static void stale_native12(void)
{
    struct env12 v;open12(&v,true);fill_remaining_slots(&v);
    int64_t old=total_discarded;push12(&v,true,false);uint32_t id=push12(&v,false,false);
    fill12(&v);C12(total_discarded==old+1 && atomic_load(&step_calls)==1);
    C12(v.b.last.receipt_valid && v.b.last.queue_full);written(&v.b.last.step.queued,id);
    C12(!staged_work && seen_threads[0]==0 && seen_diff[0]==1 && seen_mined[0]);
    uint8_t data[88];r01_read(v.q.e.f.peer,data,88);close12(&v);++n12_cases;
}
static void metadata_native12(void)
{
    struct env12 v;open12(&v,true);push12(&v,false,true);push12(&v,false,false);
    fill12(&v);C12(atomic_load(&step_calls)==1 && HASH_COUNT(staged_work)==1);
    C12(v.b.last.queue_full && v.b.last.receipt_valid && v.b.last.step.queued.completed);
    C12(v.b.last.step.queued.work_status==DIZZASS_SUBMIT_UNSUPPORTED_WORK);
    r01_empty(v.q.e.f.peer);close12(&v);++n12_cases;
}
struct worker12 {struct env12 *v;bool fill;_Atomic bool done;};
static void *worker12(void *p)
{
    struct worker12 *w=p;if(w->fill)fill12(w->v);else (void)dizzass_queue_full(&w->v->q.e.cgpu);
    atomic_store(&w->done,true);pthread_testcancel();return NULL;
}
static void early_native12(size_t cap)
{
    struct env12 v;open12(&v,true);fill_remaining_slots(&v);uint32_t id=push12(&v,false,false);
    read_cap=cap;r01_hook(R01_HOLD,v.q.e.f.host);struct worker12 a={.v=&v,.fill=true};pthread_t t;
    C12(pthread_create(&t,NULL,worker12,&a)==0);r01_wait_hook();uint8_t data[88];r01_read(v.q.e.f.peer,data,88);
    peer_write(&v.q.e,r08_nonce[0],11);wait_events(&v.q.e,1);
    C12(v.q.e.events[0].kind==DIZZASS_RX_QUEUED && queue_empty(&v.q.e));
    r01_release_hook();C12(pthread_join(t,NULL)==0);wait_events(&v.q.e,2);
    C12(v.b.last.receipt_valid && v.b.last.queue_full);written(&v.b.last.step.queued,id);
    C12(v.q.e.events[1].submission.captured.serial==v.b.last.step.queued.send.send.ticket.serial);
    C12(v.q.e.events[1].submission.native_called && v.q.e.events[1].integrity_verified);
    gone(&v.q);take_genesis(&v.q.e);close12(&v);++n12_cases;
}
static void copy12(unsigned index)
{
    struct env12 v;open12(&v,true);stage(&v.q);atomic_store(&fail_strdup,(int)index);
    C12(dizzass_queue_full(&v.q.e.cgpu));
    C12(v.b.last.receipt_valid && v.b.last.step.queued.completed && v.b.last.queue_full);
    C12(v.b.last.step.queued.send.send.prepare_status==DIZZASS_NONCE_PARTIAL_COPY);
    atomic_store(&fail_strdup,-1);r01_empty(v.q.e.f.peer);close12(&v);++n12_cases;
}
static void transport12(bool late)
{
    struct env12 v;open12(&v,true);stage(&v.q);v.b.timeout_ms=30;
    r01_hook(late?R01_LATE:R01_PREFIX_EIO,v.q.e.f.host);r01_late_until=r01_now()+80;
    C12(dizzass_queue_full(&v.q.e.cgpu));
    C12(v.b.last.receipt_valid && v.b.last.queue_full && v.b.last.step.queued.completed);
    C12(v.b.last.step.queued.send.send.outcome==DIZZASS_TX_UNCERTAIN);
    C12(v.b.last.step.queued.send.send.transport.written==(late?88:5));
    uint8_t data[88];r01_read(v.q.e.f.peer,data,late?88:5);close12(&v);++n12_cases;
}
static void stoprace12(void)
{
    struct env12 v;open12(&v,true);stage(&v.q);stop_after_get=v.q.io;
    C12(dizzass_queue_full(&v.q.e.cgpu));
    C12(v.b.last.receipt_valid && v.b.last.queue_full && v.b.last.step.queued.completed);
    C12(v.b.last.step.queued.send_status==ECANCELED);gone(&v.q);close12(&v);++n12_cases;
}
static void cancelled12(void)
{
    struct env12 v;open12(&v,true);uint32_t id=stage(&v.q)->id;
    r01_hook(R01_HOLD,v.q.e.f.host);struct worker12 a={.v=&v};pthread_t t;
    C12(pthread_create(&t,NULL,worker12,&a)==0);r01_wait_hook();
    C12(pthread_cancel(t)==0);r01_release_hook();void *ret;
    C12(pthread_join(t,&ret)==0 && ret==PTHREAD_CANCELED);
    C12(v.b.last.receipt_valid && v.b.last.step.queued.completed);
    written(&v.b.last.step.queued,id);gone(&v.q);uint8_t data[88];r01_read(v.q.e.f.peer,data,88);
    close12(&v);++n12_cases;
}
static void upstream_block12(void)
{
    struct env12 v;open12(&v,true);upstream_waiting=false;
    struct worker12 a={.v=&v,.fill=true};pthread_t t;C12(pthread_create(&t,NULL,worker12,&a)==0);
    C12(pthread_mutex_lock(&wait_lock)==0);
    while(!upstream_waiting)C12(pthread_cond_wait(&wait_cond,&wait_lock)==0);
    C12(pthread_mutex_unlock(&wait_lock)==0);
    struct dizzass_io_report report;C12(dizzass_io_stop(v.q.io,r01_now()+1000,&report)==0 && report.quiescent);
    C12(!atomic_load(&a.done) && !atomic_load(&step_calls) && !report.active_queue);
    /* Wake REAL upstream hash_pop with a fixture work, not a fake cancel/ACK. */
    uint32_t id=push12(&v,false,false);C12(pthread_join(t,NULL)==0);
    C12(v.q.e.cgpu.unqueued_work && v.q.e.cgpu.unqueued_work->id==id);
    C12(v.b.last.status==ECANCELED && !atomic_load(&get_calls));
    close12(&v);++n12_cases;
    puts("R12_UPSTREAM_WAIT lifecycle_stop_does_not_wake_get_work=1 caller_join_required=1");
}
#ifndef R12_CALLBACK_EMBED
int main(void)
{
    alarm(55);mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    getq=tq_new();C12(getq);stgd_lock=&getq->mutex;C12(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    guards12();statuses12();deadline12();continuation12();
    full_native12();stale_native12();metadata_native12();
    for(size_t n=1;n<=11;++n)early_native12(n);
    for(unsigned i=0;i<4;++i)copy12(i);
    transport12(false);transport12(true);stoprace12();cancelled12();upstream_block12();
    C12(!staged_work && !staged_rollable);tq_free(getq);getq=NULL;stgd_lock=NULL;
    C12(pthread_cond_destroy(&gws_cond)==0);
    printf("R12_PASS cases=%u checks=%u real_fill_queue=1 real_get_work=1 native_calls=%u physical_asic=0\n",n12_cases,atomic_load(&n12_checks),atomic_load(&native_calls));return 0;
}

#endif /* R12_CALLBACK_EMBED */
