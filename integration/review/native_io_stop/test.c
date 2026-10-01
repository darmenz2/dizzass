/* GPL-3.0-or-later. REAL core waits, semaphores, PTYs and managed IO. */
#define R14_WAKE_EMBED
#include "integration/review/driver_wake/test.c"
#include "integration/native/native_io_stop.h"

static unsigned n16_cases;
static _Atomic unsigned n16_checks, req16, stops16, wakes16;
#define C16(x) do { atomic_fetch_add(&n16_checks,1); if(!(x)) { fprintf(stderr,"R16_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
struct env16 {
    struct env14 native;
    struct r01_fixture extra[DIZZASS_IO_STOP_MANY_MAX-1];
    struct dizzass_io_lifecycle *io[DIZZASS_IO_STOP_MANY_MAX];
    size_t count;
};
static struct env16 *watch16;
static bool audit16;
static int request_error16=-1, stop_error16=-1;
static uint64_t deadline16;
static pthread_mutex_t wake_lock16=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t wake_cond16=PTHREAD_COND_INITIALIZER;
static bool held16, entered16, released16;
static void disabled16(void)
{int old;C16(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old)==0);C16(old==PTHREAD_CANCEL_DISABLE);}
static size_t member16(struct dizzass_io_lifecycle *io)
{size_t i=0;while(i<watch16->count && watch16->io[i]!=io)++i;C16(i<watch16->count);return i;}
static void all_requested16(void)
{
    for(size_t i=0;i<watch16->count;++i){struct dizzass_io_report s;
        C16(dizzass_io_snapshot(watch16->io[i],&s)==0);
        C16(s.stop_requested);}
}
int __real_dizzass_io_request_stop(struct dizzass_io_lifecycle *);
int __wrap_dizzass_io_request_stop(struct dizzass_io_lifecycle *io)
{
    if(!audit16)return __real_dizzass_io_request_stop(io);
    disabled16();size_t i=member16(io);atomic_fetch_add(&req16,1);
    int rc=__real_dizzass_io_request_stop(io);
    return (int)i==request_error16?EIO:rc; /* Inject AFTER actual latch. */
}
int __real_dizzass_io_stop(struct dizzass_io_lifecycle *,uint64_t,struct dizzass_io_report *);
int __wrap_dizzass_io_stop(struct dizzass_io_lifecycle *io,uint64_t d,struct dizzass_io_report *out)
{
    if(!audit16)return __real_dizzass_io_stop(io,d,out);
    disabled16();all_requested16();C16(d==deadline16);size_t i=member16(io);
    atomic_fetch_add(&stops16,1);
    if((int)i==stop_error16)return EAGAIN; /* Selected child's full stop skipped. */
    return __real_dizzass_io_stop(io,d,out);
}
static int wake16(struct cgpu_info *g)
{
    disabled16();all_requested16();atomic_fetch_add(&wakes16,1);
    C16(pthread_mutex_lock(&wake_lock16)==0);entered16=true;
    C16(pthread_cond_broadcast(&wake_cond16)==0);
    while(held16 && !released16)C16(pthread_cond_wait(&wake_cond16,&wake_lock16)==0);
    C16(pthread_mutex_unlock(&wake_lock16)==0);
    return wake14(g); /* Actual cooperative condition-variable wake. */
}
static void open16(struct env16 *e,size_t count,bool immediate,bool pause)
{
    memset(e,0,sizeof *e);e->count=count;open14(&e->native,immediate,pause);reset13();
    e->io[0]=e->native.native.q.io;
    for(size_t i=1;i<count;++i){
        e->extra[i-1]=r01_open();struct r01_fixture *f=&e->extra[i-1];
        dizzass_jobs_destroy(&f->jobs);C16(dizzass_jobs_create((uint32_t)(2+i),17,&f->jobs)==0);
        struct dizzass_rx_owner_config c=config(&e->native.native.q.e,8);
        c.fd=f->host;c.jobs=f->jobs;c.chain_id=(uint32_t)(2+i);c.poll_ms=10;
        c.chip_selector=4;
        C16(dizzass_io_create_crc5(&c,f->channel,&e->io[i])==0);
        C16(dizzass_io_start(e->io[i])==0);
    }
    watch16=e;audit16=false;request_error16=stop_error16=-1;
    atomic_store(&req16,0);atomic_store(&stops16,0);atomic_store(&wakes16,0);
    held16=entered16=released16=false;e->native.native.q.e.drv.queued_stop_wake=wake16;
}
static void watch_start16(uint64_t deadline)
{deadline16=deadline;atomic_store(&req16,0);atomic_store(&stops16,0);audit16=true;}
static void close16(struct env16 *e)
{
    audit16=false;request_error16=stop_error16=-1;
    /* Every native owner/controller is joined before this teardown. Stop ALL
     * RX users before close14 frees the shared native submitter/pool. */
    for(size_t i=0;i<e->count;++i){struct dizzass_io_report r;C16(__real_dizzass_io_stop(e->io[i],r01_now()+2000,&r)==0);}
    for(size_t i=1;i<e->count;++i){C16(dizzass_io_destroy(&e->io[i])==0);r01_close(&e->extra[i-1]);}
    close14(&e->native);watch16=NULL;
}
static struct cgpu_info *gpu16(struct env16 *e){return &e->native.native.q.e.cgpu;}
static void good16(struct env16 *e,const struct dizzass_native_io_stop_report *r)
{
    C16(r->sequence_complete && r->native_called && !r->native_status && !r->first_error);
    C16(r->io.all_quiescent && r->io.count==e->count && r->io.requested==e->count && r->io.attempted==e->count);
    C16(r->io.quiescent==e->count && !r->cancel_restore_status);
    for(size_t i=0;i<e->count;++i){C16(r->io.entries[i].io.quiescent && r->io.entries[i].io.jobs_paused);
        C16(!r->io.entries[i].io.active_queue && !r->io.entries[i].io.active_tx);
        int fd=i?e->extra[i-1].host:e->native.native.q.e.f.host;C16(fcntl(fd,F_GETFL)>=0);}
}
static void basic16(size_t n)
{
    struct env16 e;open16(&e,n,true,false);watch_start16(r01_now()+2000);
    struct dizzass_native_io_stop_report r;C16(dizzass_native_io_stop(gpu16(&e),e.io,n,deadline16,&r)==0);good16(&e,&r);
    C16(atomic_load(&wakes16)==1 && atomic_load(&req16)>=n && atomic_load(&stops16)==n);
    watch_start16(deadline16);C16(dizzass_native_io_stop(gpu16(&e),e.io,n,deadline16,&r)==0);good16(&e,&r);
    C16(atomic_load(&wakes16)==2 && sem_value14(&e.native.native.q.e.thr.sem)==1);
    close16(&e);++n16_cases;
}
static void invalid16(unsigned k)
{
    struct env16 e;open16(&e,3,true,false);watch_start16(0);
    struct dizzass_native_io_stop_report r,before;memset(&r,0xa5,sizeof r);before=r;
    struct dizzass_io_lifecycle *v[3];memcpy(v,e.io,sizeof v);
    struct cgpu_info *g=gpu16(&e);struct device_drv *drv=g->drv;
    struct dizzass_io_lifecycle **input=v;size_t n=3;struct dizzass_native_io_stop_report *out=&r;
    if(k==0)g=NULL;if(k==1)g->drv=NULL;if(k==2)input=NULL;if(k==3)out=NULL;
    if(k==4)n=0;if(k==5)n=17;if(k==6)n=SIZE_MAX;if(k==7)v[2]=NULL;if(k==8)v[2]=v[0];if(k==9)v[0]=NULL;
    C16(dizzass_native_io_stop(g,input,n,0,out)==EINVAL);gpu16(&e)->drv=drv;
    C16(!memcmp(&r,&before,sizeof r) && !atomic_load(&req16) && !atomic_load(&stops16) && !atomic_load(&wakes16));
    C16(!cgminer_queued_stopped(gpu16(&e)));
    for(size_t i=0;i<3;++i){struct dizzass_io_report s;C16(dizzass_io_snapshot(e.io[i],&s)==0 && !s.stop_requested);}
    close16(&e);++n16_cases;
}
static void native_wait16(unsigned mode)
{
    struct env16 e;open16(&e,3,mode==1,mode==1);struct thr_info *t=&e.native.native.q.e.thr;
    if(mode)prepare14(&e.native);
    struct worker13 w={.thr=t,.role=1,.mode=1};pthread_t p;
    C16(pthread_create(&p,NULL,work13,&w)==0);
    if(mode==0)until13(&waits[1],1);
    else if(mode==1)until14(&sem_seen14[0],1);
    else until14(&e.native.driver.waiting,1);
    watch_start16(r01_now()+2000);struct dizzass_native_io_stop_report r;
    C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==0);good16(&e,&r);join13(p,&w);
    C16(!atomic_load(&e.native.driver.enabled) && !atomic_load(&e.native.driver.updated));
    C16(atomic_load(&e.native.driver.scanning)==(mode?1u:0u));
    close16(&e);++n16_cases;
}
struct controller16{struct env16 *e;int rc;struct dizzass_native_io_stop_report r;};
static void *control16(void *p)
{
    struct controller16 *c=p;c->rc=dizzass_native_io_stop(gpu16(c->e),c->e->io,c->e->count,deadline16,&c->r);
    pthread_testcancel();return NULL;
}
static void wait_wake16(void)
{
    struct timespec d;C16(clock_gettime(CLOCK_REALTIME,&d)==0);d.tv_sec+=3;
    C16(pthread_mutex_lock(&wake_lock16)==0);
    while(!entered16)C16(pthread_cond_timedwait(&wake_cond16,&wake_lock16,&d)==0);
    C16(pthread_mutex_unlock(&wake_lock16)==0);
}
static void release_wake16(void)
{C16(pthread_mutex_lock(&wake_lock16)==0);released16=true;C16(pthread_cond_broadcast(&wake_cond16)==0);C16(pthread_mutex_unlock(&wake_lock16)==0);}
static void held_wake16(bool cancel)
{
    struct env16 e;open16(&e,3,false,false);prepare14(&e.native);
    struct thread14 w={.t=&e.native.native.q.e.thr};pthread_t p,c;
    C16(pthread_create(&p,NULL,thread14,&w)==0);until14(&e.native.driver.waiting,1);
    held16=true;watch_start16(r01_now()+2000);struct controller16 ctrl={.e=&e,.rc=-999};
    C16(pthread_create(&c,NULL,control16,&ctrl)==0);wait_wake16();C16(!atomic_load(&stops16));
    all_requested16();
    for(size_t i=0;i<3;++i){struct dizzass_io_work_receipt r,before;memset(&r,0x5a,sizeof r);before=r;
        C16(__real_dizzass_io_send_work(e.io[i],2,0,0,2,e.native.native.q.e.source,r01_now()+1000,32,&r)==ECANCELED);
        C16(!memcmp(&r,&before,sizeof r));}
    /* The native fixture performed one earlier TX. Extra ports remain silent. */
    for(size_t i=1;i<3;++i)r01_empty(e.extra[i-1].peer);
    if(cancel)C16(pthread_cancel(c)==0);release_wake16();void *value=NULL;C16(pthread_join(c,&value)==0);
    C16(value==(cancel?PTHREAD_CANCELED:NULL));good16(&e,&ctrl.r);join14(p,&w);
    C16(atomic_load(&stops16)==3);close16(&e);++n16_cases;
}
static void failed_wake16(void)
{
    struct env16 e;open16(&e,3,false,false);prepare14(&e.native);e.native.driver.wake_error=ENETDOWN;
    struct thread14 w={.t=&e.native.native.q.e.thr};pthread_t p;C16(pthread_create(&p,NULL,thread14,&w)==0);
    until14(&e.native.driver.waiting,1);watch_start16(r01_now()+2000);struct dizzass_native_io_stop_report r;
    C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==ENETDOWN);
    C16(r.native_called && r.native_status==ENETDOWN && r.first_error==ENETDOWN && !r.sequence_complete);
    C16(r.io.all_quiescent && r.io.attempted==3 && !atomic_load(&w.done));
    e.native.driver.wake_error=0;watch_start16(r01_now()+2000);
    C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==0);good16(&e,&r);join14(p,&w);
    C16(atomic_load(&wakes16)==2);close16(&e);++n16_cases;
}
static void io_error16(unsigned i,bool request)
{
    struct env16 e;open16(&e,3,true,false);watch_start16(r01_now()+2000);
    if(request)request_error16=(int)i;else stop_error16=(int)i;
    struct dizzass_native_io_stop_report r;C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==(request?EIO:EAGAIN));
    C16(r.native_called && !r.native_status && !r.sequence_complete && r.io.attempted==3);
    C16(atomic_load(&stops16)==3 && r.io.quiescent==(request?3u:2u));
    C16((request?r.io.entries[i].request_status:r.io.entries[i].stop_status)==(request?EIO:EAGAIN));
    request_error16=stop_error16=-1;watch_start16(r01_now()+2000);
    C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==0);good16(&e,&r);close16(&e);++n16_cases;
}
static void error_order16(void)
{
    struct env16 e;open16(&e,3,true,false);e.native.driver.wake_error=ENETDOWN;
    watch_start16(r01_now()+2000);request_error16=2;stop_error16=0;
    struct dizzass_native_io_stop_report r;C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==EIO);
    C16(r.first_error==EIO && r.native_status==ENETDOWN && r.io.entries[0].stop_status==EAGAIN);
    C16(r.io.entries[2].request_status==EIO && r.io.attempted==3 && r.io.quiescent==2 && !r.sequence_complete);
    close16(&e);++n16_cases;
}
static void queue_window16(bool cancel)
{
    struct env16 e;open16(&e,3,true,false);struct qenv *q=&e.native.native.q;stage(q);block_completion=true;
    struct qsender tx={.q=q,.p=plan(0)};pthread_t p;C16(pthread_create(&p,NULL,qthread,&tx)==0);
    struct timespec d;C16(clock_gettime(CLOCK_REALTIME,&d)==0);d.tv_sec+=3;
    C16(pthread_mutex_lock(&completion_lock)==0);
    while(!completion_entered)C16(pthread_cond_timedwait(&completion_cond,&completion_lock,&d)==0);
    C16(pthread_mutex_unlock(&completion_lock)==0);
    if(cancel)C16(pthread_cancel(p)==0);watch_start16(r01_now()+20);
    struct dizzass_native_io_stop_report r;C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==ETIMEDOUT);
    C16(r.io.attempted==3 && r.io.quiescent==2 && !r.sequence_complete);
    C16(r.io.entries[0].io.active_queue==1 && !r.io.entries[0].io.active_tx && !r.io.entries[0].io.jobs_paused);
    C16(dizzass_io_destroy(&q->io)==EBUSY);
    C16(pthread_mutex_lock(&completion_lock)==0);completion_release=true;
    C16(pthread_cond_broadcast(&completion_cond)==0);C16(pthread_mutex_unlock(&completion_lock)==0);
    void *value;C16(pthread_join(p,&value)==0 && value==(cancel?PTHREAD_CANCELED:NULL));
    C16(tx.r.completed && atomic_load(&complete_calls)==1);
    watch_start16(r01_now()+2000);C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==0);good16(&e,&r);
    close16(&e);++n16_cases;
}
static void scheduler_missing16(void)
{
    struct env16 e;open16(&e,3,true,false);struct thread_q *save=getq;getq=NULL;
    watch_start16(r01_now()+2000);struct dizzass_native_io_stop_report r;
    C16(dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==EINVAL);getq=save;
    C16(r.native_called && r.native_status==EINVAL && r.io.all_quiescent && !r.sequence_complete);
    C16(!cgminer_queued_stopped(gpu16(&e)) && !atomic_load(&wakes16));close16(&e);++n16_cases;
}
int main(void)
{
    void (*volatile keep_fill)(struct thr_info *,struct cgpu_info *,struct device_drv *,const int)=fill_queue;
    C16(keep_fill);alarm(55);rwlock_init(&devices_lock);mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    getq=tq_new();C16(getq);stgd_lock=&getq->mutex;C16(pthread_cond_init(&gws_cond,NULL)==0);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;opt_log_interval=INT_MAX;
    basic16(1);basic16(3);basic16(16);
    for(unsigned i=0;i<10;++i)invalid16(i);
    for(unsigned i=0;i<3;++i)native_wait16(i);
    held_wake16(false);held_wake16(true);failed_wake16();
    for(unsigned i=0;i<3;++i){io_error16(i,false);io_error16(i,true);}
    error_order16();queue_window16(false);queue_window16(true);scheduler_missing16();
    C16(n16_cases==29 && !staged_work && !staged_rollable);
    tq_free(getq);getq=NULL;stgd_lock=NULL;C16(pthread_cond_destroy(&gws_cond)==0);
    printf("R16_PASS cases=%u checks=%u real_native_waits=1 real_managed_io=1 hardware=0\n",n16_cases,atomic_load(&n16_checks));return 0;
}
