#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "config.h"
#include "miner.h"
#include "integration/native_tx_channel.h"
#include "integration/rx_crc5.h"
#include "xminer/recovery/work_rx.h"
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
struct dizzass_tx_channel {
    pthread_mutex_t lock;
    struct dizzass_hwscan_profile profile;
    struct dizzass_jobs *jobs;
    struct dizzass_job_ticket active;
    vn135_work_rx_stream rx;
    uint64_t epoch;
    uint32_t chain_id,next_slot;
    int fd,stopped;
    uint8_t input[128];
    size_t start,end;
};
static int enter(struct dizzass_tx_channel *c)
{
    int old;
    if(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&old)||pthread_mutex_lock(&c->lock)) abort();
    return old;
}
static void leave(struct dizzass_tx_channel *c,int old)
{
    if(pthread_mutex_unlock(&c->lock)||pthread_setcancelstate(old,NULL)) abort();
}
static void stop_locked(struct dizzass_tx_channel *c)
{ c->stopped=1; (void)dizzass_jobs_pause(c->jobs,c->epoch); }
int dizzass_tx_channel_create(const struct dizzass_hwscan_profile *p,
    uint32_t chain,uint64_t epoch,int fd,struct dizzass_tx_channel **out)
{
    struct dizzass_tx_channel *c; int rc;
    if(!out||*out||!epoch) return DIZZASS_JOBS_INVALID;
    rc=dizzass_hwscan_profile_validate(p,chain); if(rc) return rc;
    rc=dizzass_posix_uart_check(fd,p->uart_speed); if(rc) return rc;
    c=calloc(1,sizeof(*c)); if(!c) return DIZZASS_JOBS_NOMEM;
    c->fd=fcntl(fd,F_DUPFD_CLOEXEC,0);
    if(c->fd<0) { free(c); return DIZZASS_SERIAL_IO; }
    if(pthread_mutex_init(&c->lock,NULL)) {
        close(c->fd);free(c);return DIZZASS_JOBS_LOCK_ERROR;
    }
    rc=dizzass_jobs_create(chain,epoch,&c->jobs);
    if(rc) { pthread_mutex_destroy(&c->lock);close(c->fd);free(c);return rc; }
    c->profile=*p;c->chain_id=chain;c->epoch=epoch;
    rc=vn135_work_rx_stream_init(&c->rx,chain,p->platform,p->chip,0);
    if(rc) { dizzass_jobs_destroy(&c->jobs);pthread_mutex_destroy(&c->lock);close(c->fd);free(c);return rc; }
    *out=c;return 0;
}
int dizzass_tx_channel_send(struct dizzass_tx_channel *c,const struct work *source,
    uint32_t timeout,struct dizzass_channel_send_result *out)
{
    struct dizzass_tx88_prepared prepared={0};
    struct dizzass_channel_send_result result={0};
    enum dizzass_tx_result outcome;int rc,finish,cancel;
    result.io.outcome=DIZZASS_SERIAL_NOT_SENT;
    if(!out) return DIZZASS_JOBS_INVALID;
    *out=result;
    if(!c||!source||!timeout||timeout>10000) return DIZZASS_JOBS_INVALID;
    cancel=enter(c);
    if(c->stopped) { rc=DIZZASS_CHANNEL_STOPPED;goto done; }
    if(c->active.serial) {
        rc=dizzass_jobs_retire(c->jobs,&c->active);
        if(rc) { stop_locked(c);goto done; }
        memset(&c->active,0,sizeof(c->active));
    }
    if(c->next_slot==DIZZASS_JOB_SLOTS) { rc=DIZZASS_JOBS_EXHAUSTED;goto done; }
    rc=dizzass_jobs_prepare_tx88(c->jobs,c->epoch,c->profile.platform,c->profile.algorithm,
        c->next_slot,c->rx.policy.variant,source,&prepared);
    if(rc) goto done;
    result.ticket=prepared.ticket;
    rc=dizzass_posix_tx88_write(c->fd,prepared.packet,timeout,&result.io);
    outcome=result.io.outcome==DIZZASS_SERIAL_WRITTEN?DIZZASS_TX_WRITTEN:
        result.io.outcome==DIZZASS_SERIAL_NOT_SENT?DIZZASS_TX_NOT_SENT:DIZZASS_TX_UNCERTAIN;
    finish=dizzass_jobs_finish(c->jobs,&prepared.ticket,outcome);
    if(finish) { stop_locked(c);rc=finish;goto done; }
    if(outcome==DIZZASS_TX_WRITTEN) { c->active=prepared.ticket;++c->next_slot; }
    if(outcome==DIZZASS_TX_UNCERTAIN || (rc && rc!=DIZZASS_SERIAL_TIMEOUT)) stop_locked(c);
done:
    *out=result;leave(c,cancel);return rc;
}
int dizzass_tx_channel_read(struct dizzass_tx_channel *c,uint64_t epoch,
    struct dizzass_channel_rx_result *out)
{
    struct dizzass_channel_rx_result result={0};
    vn135_work_rx_message message;struct dizzass_nonce_reply reply;
    size_t used;int rc,cancel,read_once=0;
    if(!c||!out||out->job.check.work) return DIZZASS_JOBS_INVALID;
    cancel=enter(c);
    if(epoch!=c->epoch) { rc=DIZZASS_JOBS_OLD_EPOCH;goto done; }
    if(c->stopped) { rc=DIZZASS_CHANNEL_STOPPED;goto done; }
    for(;;) {
        if(c->start==c->end) {
            ssize_t n;
            if(read_once) { rc=DIZZASS_CHANNEL_AGAIN;goto done; }
            read_once=1;
            n=read(c->fd,c->input,sizeof(c->input));
            if(n<0&&(errno==EAGAIN||errno==EWOULDBLOCK||errno==EINTR)) {
                rc=DIZZASS_CHANNEL_AGAIN;goto done;
            }
            if(n<=0) { stop_locked(c);rc=DIZZASS_CHANNEL_RX_IO;goto done; }
            c->start=0;c->end=(size_t)n;
        }
        used=0;
        rc=vn135_work_rx_stream_feed(&c->rx,c->input+c->start,c->end-c->start,&used,&message);
        if(rc<0||!used) { stop_locked(c);rc=DIZZASS_CHANNEL_RX_IO;goto done; }
        c->start+=used;
        if(rc==VN135_RX_NEED_MORE) continue;
        if(rc==VN135_RX_DISCARDED) { rc=DIZZASS_CHANNEL_DISCARDED;goto done; }
        /* Validate the full payload before trusting its kind/slot or doing
         * native work allocation, hashing or accounting. Includes bit 7. */
        result.match_status=dizzass_bm1368_reply_crc5(c->profile.chip,
            c->rx.policy.variant,message.payload,message.payload_size);
        if(result.match_status) {
            *out=result;rc=DIZZASS_CHANNEL_DISCARDED;goto done;
        }
        if(rc!=VN135_RX_NONCE_RAW) { *out=result;rc=DIZZASS_CHANNEL_DISCARDED;goto done; }
        rc=dizzass_nonce_decode_payload(c->profile.chip,c->rx.policy.variant,c->chain_id,
            message.payload,message.payload_size,&reply);
        if(!rc) rc=dizzass_jobs_check(c->jobs,c->epoch,&reply,&result.job);
        result.match_status=rc;
        if(rc) rc=DIZZASS_CHANNEL_DISCARDED;
        *out=result;goto done;
    }
done:
    leave(c,cancel);return rc;
}
int dizzass_tx_channel_stop(struct dizzass_tx_channel *c)
{
    int cancel;
    if(!c) return DIZZASS_JOBS_INVALID;
    cancel=enter(c);stop_locked(c);leave(c,cancel);return 0;
}
void dizzass_tx_channel_destroy(struct dizzass_tx_channel **out)
{
    struct dizzass_tx_channel *c;
    if(!out||!*out) return;
    c=*out;dizzass_tx_channel_stop(c);dizzass_jobs_destroy(&c->jobs);
    close(c->fd);
    if(pthread_mutex_destroy(&c->lock)) abort();
    free(c);*out=NULL;
}
