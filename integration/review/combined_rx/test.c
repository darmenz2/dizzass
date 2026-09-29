/* GPL-3.0-or-later. R-06 composition review; no miner startup.
 * Reuse unchanged R-04 test helpers, actual PTYs and native cgminer. */
#define R04_OWNER_EMBED
#include "integration/review/rx_owner/test.c"
#include "integration/native/io_lifecycle.h"
#include <sched.h>
static unsigned combined_cases, accepted, refused, wire_frames;
struct racer { struct dizzass_io_lifecycle *io; struct work *work;
    pthread_barrier_t *barrier; unsigned slot,yields; int rc;
    struct dizzass_io_work_receipt receipt; };
static void barrier_wait(pthread_barrier_t *b)
{ int e=pthread_barrier_wait(b); Q(e==0 || e==PTHREAD_BARRIER_SERIAL_THREAD); }
static void *race_send(void *arg)
{
    struct racer *r=arg; barrier_wait(r->barrier);
    for(unsigned i=0;i<r->yields;++i) sched_yield();
    r->rc=dizzass_io_send_work(r->io,2,0,r->slot,2,r->work,r01_now()+5000,32,&r->receipt);
    return NULL;
}
static struct dizzass_io_lifecycle *create_io(struct env *e)
{
    struct dizzass_io_lifecycle *io=NULL; struct dizzass_rx_owner_config cfg=config(e,32);
    cfg.poll_ms=10; Q(dizzass_io_create(&cfg,e->f.channel,&io)==0); Q(dizzass_io_start(io)==0); return io;
}
/* Stop before release, race stop, complete TX before stop. Racing outcomes
 * are counted, not assumed; quiescence never licenses freeing caller refs. */
static void race_stop(unsigned iteration)
{
    struct env e;setup(&e); struct work original=*e.source;
    struct dizzass_io_lifecycle *io=create_io(&e);
    pthread_barrier_t barrier; Q(pthread_barrier_init(&barrier,NULL,5)==0);
    pthread_t threads[4]; struct racer r[4];
    for(unsigned i=0;i<4;++i) {
        memset(&r[i],0,sizeof r[i]);memset(&r[i].receipt,0xa5,sizeof r[i].receipt);
        r[i].io=io;r[i].work=e.source;r[i].barrier=&barrier;r[i].slot=i;r[i].yields=(iteration+i)%4;
        Q(pthread_create(&threads[i],NULL,race_send,&r[i])==0);
    }
    struct dizzass_io_report report={0};unsigned mode=iteration%3;
    if(mode==0) Q(dizzass_io_stop(io,r01_now()+5000,&report)==0);
    barrier_wait(&barrier);
    if(mode==1) Q(dizzass_io_stop(io,r01_now()+5000,&report)==0);
    for(unsigned i=0;i<4;++i) Q(pthread_join(threads[i],NULL)==0);
    if(mode==2) Q(dizzass_io_stop(io,r01_now()+5000,&report)==0);
    Q(report.quiescent && report.rx_joined && report.jobs_paused && !report.active_tx);
    Q(pthread_barrier_destroy(&barrier)==0);
    uint8_t expected[4][88],wire[352];size_t total=0;bool seen[4]={0};unsigned complete=0;
    for(unsigned i=0;i<4;++i) {
        Q(dizzass_native_work_tx88(e.source,2,0,i,expected[i],88)==0);
        if(r[i].rc) {
            Q(r[i].rc==ECANCELED);uint8_t before[sizeof r[i].receipt];memset(before,0xa5,sizeof before);
            Q(!memcmp(before,&r[i].receipt,sizeof before));++refused;
        } else {
            struct dizzass_native_job_tx_receipt *s=&r[i].receipt.send;
            Q(s->prepare_called && !s->prepare_status && s->channel_called && s->finish_called && !s->finish_status);
            Q(s->ticket.slot==i && s->ticket.epoch==17 && s->ticket.chain_id==2);
            Q(s->transport.written==0 || s->transport.written==88);
            if(s->transport.written==88){Q(s->outcome==DIZZASS_TX_WRITTEN);++complete;}
            else Q(s->outcome==DIZZASS_TX_UNCERTAIN);
            ++accepted;
        }
    }
    for(;;) {
        uint8_t part[352];ssize_t n=read(e.f.peer,part,sizeof part);
        if(n<0 && errno==EINTR)continue;
        if(n<0){Q(errno==EAGAIN || errno==EWOULDBLOCK);break;}
        Q(n>0 && total+(size_t)n<=sizeof wire);memcpy(wire+total,part,(size_t)n);total+=(size_t)n;
    }
    Q(total==88u*complete);
    for(size_t off=0;off<total;off+=88){unsigned i;for(i=0;i<4;++i)if(!memcmp(wire+off,expected[i],88))break;
        Q(i<4 && !seen[i]);seen[i]=true;++wire_frames;}
    if(mode==0)Q(complete==0);if(mode==2)Q(complete==4);
    Q(!memcmp(&original,e.source,sizeof original) && queue_empty(&e));
    struct dizzass_io_command_receipt denied;
    Q(dizzass_io_send_command(io,DIZZASS_BM1368_READ_REGISTER,1,0,0,0,r01_now()+1000,32,&denied)==ECANCELED);
    Q(fcntl(e.f.host,F_GETFL)>=0);Q(dizzass_io_destroy(&io)==0 && !io);
    cleanup(&e);++combined_cases;
}
static void shared_submitter(void)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *io=create_io(&e);
    struct dizzass_jobs *other=NULL;struct dizzass_tx88_prepared p={0};
    Q(dizzass_jobs_create(3,17,&other)==0);
    Q(dizzass_jobs_prepare_tx88(other,17,2,0,4,2,e.source,&p)==0);
    /* Registry script, NOT an actual second-chain UART write or chip ACK. */
    Q(dizzass_jobs_finish(other,&p.ticket,DIZZASS_TX_WRITTEN)==0);
    struct dizzass_nonce_reply reply={3,4,2,0,0};
    reply.nonce_word=(uint32_t)fixture_words[76]|(uint32_t)fixture_words[77]<<8|
        (uint32_t)fixture_words[78]<<16|(uint32_t)fixture_words[79]<<24;
    struct dizzass_io_report report;Q(dizzass_io_stop(io,r01_now()+1000,&report)==0);
    Q(dizzass_jobs_ticket_live(other,&p.ticket)==0);
    struct dizzass_submit_result result,unchanged;memset(&result,0xa5,sizeof result);unchanged=result;
    unsigned calls=atomic_load(&native_calls);
    Q(dizzass_submitter_run_captured(e.submitter,other,&p.ticket,&reply,&result)==DIZZASS_SUBMIT_STOPPED);
    Q(!memcmp(&result,&unchanged,sizeof result) && calls==atomic_load(&native_calls));
    Q(dizzass_io_destroy(&io)==0);dizzass_jobs_destroy(&other);cleanup(&e);++combined_cases;
    puts("R06_SHARED_SUBMITTER other_chain_rejected=1 other_registry_untouched=1");
}
static void ledger(void)
{
    struct env e;setup(&e);struct dizzass_io_lifecycle *io=create_io(&e);
    struct dizzass_io_work_receipt sent={0};uint8_t wire[88],f[11];
    Q(dizzass_io_send_work(io,2,0,3,2,e.source,r01_now()+1000,32,&sent)==0);
    Q(sent.send.outcome==DIZZASS_TX_WRITTEN);r01_read(e.f.peer,wire,sizeof wire);
    frame(3,f);peer_write(&e,f,sizeof f);wait_events(&e,2);
    struct dizzass_io_report report;Q(dizzass_io_stop(io,r01_now()+1000,&report)==0);
    Q(report.rx.dispatched==1 && report.rx.pending_replies==0 && report.quiescent);
    Q(e.count==2 && e.events[1].kind==DIZZASS_RX_DISPATCHED);
    Q(e.events[1].submission.captured.serial==sent.send.ticket.serial);
    Q(e.events[1].submission.result.ticket.serial==sent.send.ticket.serial);
    Q(e.events[1].submission.native_called && e.events[1].submission.result.meets_target);
    take_genesis(&e);Q(queue_empty(&e) && e.pool.accepted==0);
    Q(dizzass_io_destroy(&io)==0);cleanup(&e);++combined_cases;
    puts("R06_LEDGER same_ticket_tx_rx_submit=1 native_queue=1 pool_acceptance=0");
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    for(unsigned i=0;i<64;++i)race_stop(i);
    Q(accepted+refused==256 && wire_frames>=84);shared_submitter();ledger();
    printf("R06_PASS cases=%u producer_calls=%u admitted=%u refused=%u frames=%u checks=%u\n",
        combined_cases,accepted+refused,accepted,refused,wire_frames,atomic_load(&checks));return 0;
}
