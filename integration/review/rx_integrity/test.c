/* GPL-3.0-or-later. Explicit CRC mode on the existing owner/lifecycle.
 * PTY peer uses synthetic polynomial-division vectors, NOT physical ASIC RX. */
#define R04_OWNER_EMBED
#include "integration/review/rx_owner/test.c"
#include "integration/native/io_lifecycle.h"
#include "integration/rx_crc5.h"
#include "vectors.h"
static unsigned r08_cases,r08_checks;
#define C8(x) do { ++r08_checks; if(!(x)) { fprintf(stderr,"R08_ASSERT line=%d expr=%s\n",__LINE__,#x); exit(1); } } while(0)
static struct dizzass_rx_owner_config strict_config(struct env *e,size_t cap)
{
    struct dizzass_rx_owner_config c=config(e,cap);
    c.board_selector=2;c.chip_selector=4;c.special_mode=0;c.poll_ms=10;return c;
}
static void settled(struct env *e)
{
    uint64_t until=r01_now()+4000;
    while(atomic_load(&raw_polls)<2 && !dizzass_rx_owner_finished(e->owner)) {
        C8(r01_now()<until);struct timespec t={0,1000000};nanosleep(&t,NULL);
    }
}
/* Every corrupted bit is checked on a fresh native registry/PTY/owner. */
static void corrupted(bool reg,unsigned bit)
{
    struct env e;setup(&e);send_one(&e,3);
    struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);
    uint8_t bytes[11];memcpy(bytes,reg?r08_register[0]:r08_nonce[3],11);
    bytes[2+bit/8]^=(uint8_t)(1u<<(bit%8));
    unsigned calls=atomic_load(&native_calls);
    atomic_store(&fail_strdup,0); /* Invalid CRC must not attempt work cloning. */
    peer_write(&e,bytes,11);C8(dizzass_rx_owner_start(e.owner)==0);settled(&e);
    struct dizzass_rx_owner_report r=stop_join(&e);
    C8(e.count==1 && e.events[0].kind==DIZZASS_RX_INTEGRITY_REJECTED);
    C8(e.events[0].status==DIZZASS_RX_CRC_MISMATCH && !e.events[0].integrity_verified);
    C8(memcmp(e.events[0].message.payload,bytes+2,9)==0);
    C8(r.crc5_required && r.crc_checked==1 && r.crc_rejected==1);
    C8(!r.offered && !r.dispatched && !r.nonce_frames && !r.register_frames);
    C8(atomic_load(&native_calls)==calls && atomic_load(&fail_strdup)==0);
    C8(queue_empty(&e) && !e.cgpu.last_nonce && !e.cgpu.hw_errors && e.cgpu.diff1==0);
    atomic_store(&fail_strdup,-1);cleanup(&e);++r08_cases;
}
static void early_crc(size_t cap)
{
    struct env e;setup(&e);read_cap=cap;
    struct dizzass_rx_owner_config c=strict_config(&e,4);c.poll_ms=1000;
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);
    r01_hook(R01_HOLD,e.f.host);struct sender s={.e=&e};pthread_t tx;
    C8(pthread_create(&tx,NULL,send_thread,&s)==0);r01_wait_hook();uint8_t sent[88];r01_read(e.f.peer,sent,88);
    C8(dizzass_rx_owner_start(e.owner)==0);peer_write(&e,r08_nonce[3],11);wait_events(&e,1);
    C8(e.events[0].kind==DIZZASS_RX_QUEUED && e.events[0].integrity_verified);
    C8(queue_empty(&e));wait_uint(&raw_polls,e.queued_poll+1);
    r01_release_hook();C8(pthread_join(tx,NULL)==0 && s.r.finish_status==0);
    free_work(e.source);C8(dizzass_rx_owner_notify(e.owner)==0);wait_events(&e,2);
    struct dizzass_rx_owner_report r=stop_join(&e);
    C8(r.crc5_required && r.crc_checked==1 && !r.crc_rejected && r.dispatched==1);
    C8(e.events[1].kind==DIZZASS_RX_DISPATCHED && e.events[1].integrity_verified);
    C8(e.events[1].submission.captured.serial==s.r.ticket.serial);
    take_genesis(&e);C8(queue_empty(&e));cleanup(&e);++r08_cases;
    printf("R08_EARLY cap=%zu verified_before_pending=1\n",cap);
}
static void profile_guards(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,4);
    unsigned supported=0,rejected=0;
    for(unsigned board=0;board<=4;++board)for(unsigned chip=0;chip<=8;++chip)for(unsigned special=0;special<=1;++special) {
        c.board_selector=board;c.chip_selector=chip;c.special_mode=special;
        struct dizzass_rx_owner *o=NULL;
        bool accepted=board!=0 && chip==4 && special==0;
        if(!accepted)atomic_store(&fail_eventfd,EMFILE);
        int rc=dizzass_rx_owner_create_crc5(&c,&o);
        if(accepted){C8(rc==0 && o);C8(dizzass_rx_owner_destroy(&o)==0);++supported;}
        else {C8(rc==DIZZASS_RX_CRC_UNSUPPORTED && !o);C8(atomic_load(&fail_eventfd)==EMFILE);++rejected;}
        atomic_store(&fail_eventfd,0);
    }
    C8(supported==4 && rejected==86);c=strict_config(&e,4);c.special_mode=1;c.fd=-1;
    struct dizzass_rx_owner *o=NULL;C8(dizzass_rx_owner_create_crc5(&c,&o)==DIZZASS_RX_CRC_UNSUPPORTED && !o);
    struct dizzass_io_lifecycle *io=NULL;C8(dizzass_io_create_crc5(&c,e.f.channel,&io)==DIZZASS_RX_CRC_UNSUPPORTED && !io);
    cleanup(&e);++r08_cases;puts("R08_PROFILES supported=4 refused=86 no_fallback=1");
}
static void register_crc(unsigned which)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);peer_write(&e,r08_register[which],11);
    C8(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,1);struct dizzass_rx_owner_report r=stop_join(&e);
    C8(e.events[0].kind==DIZZASS_RX_REGISTER && e.events[0].integrity_verified);
    C8(e.events[0].message.kind==(which?VN135_RX_REGISTER_FILTERED:VN135_RX_REGISTER));
    C8(e.events[0].message.register_value==0xdeadbeef);
    C8(r.crc_checked==1 && !r.crc_rejected && r.register_frames==1 && !r.offered && queue_empty(&e));
    cleanup(&e);++r08_cases;
}
static void coalesced_crc(void)
{
    struct env e;setup(&e);send_one(&e,3);struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);
    uint8_t p[47]={1,2,3};memcpy(p+3,r08_nonce[3],11);p[13]^=1;memcpy(p+14,r08_register[0],11);
    p[24]^=0x80;memcpy(p+25,r08_register[1],11);memcpy(p+36,r08_nonce[3],11);
    peer_write(&e,p,sizeof p);C8(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,5);
    struct dizzass_rx_owner_report r=stop_join(&e);
    C8(r.crc_checked==4 && r.crc_rejected==2 && r.noise_bytes==3 && r.dispatched==1 && r.register_frames==1);
    C8(e.events[0].kind==DIZZASS_RX_INTEGRITY_REJECTED && e.events[1].kind==DIZZASS_RX_INTEGRITY_REJECTED);
    C8(e.events[2].kind==DIZZASS_RX_REGISTER && e.events[4].kind==DIZZASS_RX_DISPATCHED);
    take_genesis(&e);cleanup(&e);++r08_cases;puts("R08_COALESCED rejected_before_dispatch=1");
}
static void lifecycle_crc(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,4);
    struct dizzass_io_lifecycle *io=NULL;C8(dizzass_io_create_crc5(&c,e.f.channel,&io)==0);C8(dizzass_io_start(io)==0);
    struct dizzass_io_work_receipt wr={0};C8(dizzass_io_send_work(io,2,0,3,2,e.source,r01_now()+2000,32,&wr)==0);
    C8(wr.send.finish_status==0 && wr.send.outcome==DIZZASS_TX_WRITTEN);uint8_t wire[88];r01_read(e.f.peer,wire,88);
    uint8_t bad[11];memcpy(bad,r08_nonce[3],11);bad[10]^=0x80;
    peer_write(&e,bad,11);wait_events(&e,1);
    C8(e.events[0].kind==DIZZASS_RX_INTEGRITY_REJECTED);
    peer_write(&e,r08_nonce[3],11);wait_events(&e,3);
    struct dizzass_io_report r;C8(dizzass_io_stop(io,r01_now()+2000,&r)==0);
    C8(r.quiescent && r.rx.crc5_required && r.rx.crc_rejected==1 && r.rx.dispatched==1);
    C8(e.events[2].integrity_verified && e.events[2].submission.captured.serial==wr.send.ticket.serial);
    take_genesis(&e);C8(dizzass_io_destroy(&io)==0);cleanup(&e);++r08_cases;
    puts("R08_LIFECYCLE strict_tx_rx_submit_stop=1");
}
static void empty_job(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);peer_write(&e,r08_nonce[3],11);
    C8(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,1);struct dizzass_rx_owner_report r=stop_join(&e);
    C8(e.events[0].kind==DIZZASS_RX_REJECTED && e.events[0].status==DIZZASS_JOBS_EMPTY && e.events[0].integrity_verified);
    C8(r.crc_checked==1 && !r.crc_rejected && !r.offered && queue_empty(&e));cleanup(&e);++r08_cases;
}
static void copy_retry_crc(void)
{
    struct env e;setup(&e);send_one(&e,3);struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);atomic_store(&fail_strdup,0);
    peer_write(&e,r08_nonce[3],11);C8(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,2);
    struct dizzass_rx_owner_report r=stop_join(&e);C8(r.copy_retries==1 && r.crc_checked==1 && r.dispatched==1 && !r.crc_rejected);
    take_genesis(&e);cleanup(&e);++r08_cases;
}
static void reject_callback(bool error)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,4);
    if(error)e.error_kind=DIZZASS_RX_INTEGRITY_REJECTED;else e.stop_kind=DIZZASS_RX_INTEGRITY_REJECTED;
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);
    uint8_t p[22];memcpy(p,r08_nonce[3],11);p[10]^=1;memcpy(p+11,r08_nonce[3],11);peer_write(&e,p,22);
    C8(dizzass_rx_owner_start(e.owner)==0);wait_done(&e);struct dizzass_rx_owner_report r=stop_join(&e);
    C8(r.reason==(error?DIZZASS_RX_CALLBACK_ERROR:DIZZASS_RX_STOP_REQUEST));C8(!error || r.detail==771);
    C8(r.crc_rejected==1 && r.unprocessed_batch_bytes==11 && !r.offered && queue_empty(&e));cleanup(&e);++r08_cases;
}
static void partial_crc(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);peer_write(&e,r08_nonce[3],5);
    C8(dizzass_rx_owner_start(e.owner)==0);settled(&e);struct dizzass_rx_owner_report r=stop_join(&e);
    C8(r.crc5_required && !r.crc_checked && !r.crc_rejected && r.partial_frame_bytes==5 && !e.count);cleanup(&e);++r08_cases;
}
static void legacy_unchanged(void)
{
    struct env e;setup(&e);send_one(&e,3);struct dizzass_rx_owner_config c=strict_config(&e,4);
    C8(dizzass_rx_owner_create(&c,&e.owner)==0);uint8_t p[11];memcpy(p,r08_nonce[3],11);p[10]^=1;
    peer_write(&e,p,11);C8(dizzass_rx_owner_start(e.owner)==0);wait_events(&e,2);struct dizzass_rx_owner_report r=stop_join(&e);
    C8(!r.crc5_required && !r.crc_checked && r.dispatched==1 && !e.events[1].integrity_verified);
    take_genesis(&e);cleanup(&e);++r08_cases;puts("R08_LEGACY explicitly_unchecked_preserved=1");
}
static void slots_crc(void)
{
    struct env e;setup(&e);struct dizzass_rx_owner_config c=strict_config(&e,32);C8(dizzass_rx_owner_create_crc5(&c,&e.owner)==0);
    for(unsigned slot=0;slot<32;++slot)send_one(&e,slot);
    C8(dizzass_rx_owner_start(e.owner)==0);
    for(unsigned slot=0;slot<32;++slot){peer_write(&e,r08_nonce[slot],11);wait_events(&e,2*(slot+1));}
    struct dizzass_rx_owner_report r=stop_join(&e);C8(r.crc_checked==32 && !r.crc_rejected && r.dispatched==32);
    for(unsigned slot=0;slot<32;++slot)C8(e.events[2*slot+1].submission.captured.slot==slot && e.events[2*slot+1].integrity_verified);
    C8(e.cgpu.diff1==1 && e.cgpu.hw_errors==31);take_genesis(&e);C8(queue_empty(&e));cleanup(&e);++r08_cases;
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;opt_submit_stale=false;
    for(unsigned reg=0;reg<2;++reg)for(unsigned bit=0;bit<72;++bit)corrupted(reg,bit);
    puts("R08_CORRUPTION single_bit_frames=144 native_calls=0 copy_attempts=0");
    for(size_t cap=1;cap<=11;++cap)early_crc(cap);
    profile_guards();register_crc(0);register_crc(1);coalesced_crc();lifecycle_crc();empty_job();copy_retry_crc();
    reject_callback(false);reject_callback(true);partial_crc();legacy_unchanged();slots_crc();
    printf("R08_PASS cases=%u checks=%u native_calls=%u physical_asic=0\n",r08_cases,r08_checks,atomic_load(&native_calls));return 0;
}
