/* Real cgminer + Linux PTY. Firmware and physical ASIC are never executed. */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "integration/native_tx_channel.h"
#include "integration/tests/hwscan_fixture.h"
#include "tests/fixtures/genesis_work.h"
#include "xminer/recovery/chip1398.h"
#include <fcntl.h>
#include <pty.h>
#include <poll.h>
#include <termios.h>
#include <sys/socket.h>

int __wrap_socket(int d,int t,int p){(void)d;(void)t;(void)p;abort();}
int __wrap_connect(int fd,const struct sockaddr *p,socklen_t n){(void)fd;(void)p;(void)n;abort();}
int __wrap_libusb_init(libusb_context **c){(void)c;abort();}
ssize_t __real_write(int,const void *,size_t);
static unsigned checks,late,valid,sends,write_calls,crc_rejected;
static int fail_partial,watch_io;
#define CHECK(x) do{++checks;if(!(x)){fprintf(stderr,"channel %d: %s\n",__LINE__,#x);exit(1);}}while(0)
ssize_t __wrap_write(int fd,const void *p,size_t n)
{
    if(watch_io) {
        ++write_calls;
        if(fail_partial&&write_calls>1){errno=EIO;return -1;}
        if(n>7)n=7;
        errno=EAGAIN;
    }
    return __real_write(fd,p,n);
}
static uint32_t le(const uint8_t *p)
{ return p[0]|(uint32_t)p[1]<<8|(uint32_t)p[2]<<16|(uint32_t)p[3]<<24; }
static struct work *work_fixture(void)
{
    struct work *w=make_work();
    memcpy(w->data,fixture_words,sizeof(fixture_words));set_target(w->target,1.0);
    w->job_id=strdup("session-old");w->nonce1=strdup("00");w->ntime=strdup("495fab29");w->coinbase=strdup("owned-copy");
    CHECK(w->job_id&&w->nonce1&&w->ntime&&w->coinbase);return w;
}
static void make_reply(unsigned slot,uint8_t frame[11])
{
    unsigned i;uint8_t crc;uint32_t nonce=le(fixture_words+76);
    memset(frame,0,11);frame[0]=0xaa;frame[1]=0x55;
    for(i=0;i<4;++i)frame[2+i]=(uint8_t)(nonce>>(24-8*i));
    frame[6]=(uint8_t)(slot>>4);frame[7]=(uint8_t)((slot&15)<<4);frame[10]=0x80;
    CHECK(vn135_crc5_bits(frame+2,9,67,&crc)==0);frame[10]|=crc;
}
static void pair(int *m,int *s)
{
    struct termios t;CHECK(openpty(m,s,NULL,NULL,NULL)==0);
    CHECK(tcgetattr(*s,&t)==0);cfmakeraw(&t);t.c_iflag&=~IXOFF;t.c_cflag|=CREAD|CLOCAL;
    CHECK(cfsetispeed(&t,B115200)==0&&cfsetospeed(&t,B115200)==0);
    CHECK(tcsetattr(*s,TCSANOW,&t)==0);
    CHECK(fcntl(*s,F_SETFL,fcntl(*s,F_GETFL)|O_NONBLOCK)==0);
    CHECK(fcntl(*m,F_SETFL,fcntl(*m,F_GETFL)|O_NONBLOCK)==0);
}
static void receive(int fd,uint8_t *p,size_t size)
{
    size_t n=0;unsigned tries=0;
    while(n<size&&++tries<100) {
        ssize_t k=read(fd,p+n,size-n);
        if(k>0)n+=(size_t)k;
        else {struct pollfd f={fd,POLLIN,0};CHECK(k<0&&(errno==EAGAIN||errno==EWOULDBLOCK));CHECK(poll(&f,1,100)>0);}
    }
    CHECK(n==size);
}
static int event(struct dizzass_tx_channel *c,uint64_t e,struct dizzass_channel_rx_result *out)
{
    unsigned tries;int rc=0;
    for(tries=0;tries<100;++tries) {
        rc=dizzass_tx_channel_read(c,e,out);
        if(rc!=DIZZASS_CHANNEL_AGAIN)return rc;
        usleep(1000);
    }
    return rc;
}
static struct dizzass_hwscan_profile profile(void)
{
    struct dizzass_hwscan_profile p;
    CHECK(dizzass_hwscan_profile_parse(fixture_fw_json,strlen(fixture_fw_json),fixture_model_json,
        strlen(fixture_model_json),fixture_hw_json,strlen(fixture_hw_json),&p)==0);
    return p;
}
static void lifecycle(void)
{
    int m,s;unsigned i;struct dizzass_tx_channel *c=NULL;
    struct dizzass_hwscan_profile p=profile();
    struct work *w=work_fixture();
    struct dizzass_channel_send_result sent;
    struct dizzass_channel_rx_result held={0};
    uint8_t packet[88],expected[88],reply[11],old[11];
    pair(&m,&s);CHECK(dizzass_tx_channel_create(&p,2,101,s,&c)==0);close(s);
    for(i=0;i<32;++i) {
        struct dizzass_channel_rx_result result={0};char label[40];
        if(i) {
            make_reply(i-1,old);CHECK(write(m,old,5)==5);
            CHECK(dizzass_tx_channel_read(c,101,&result)==DIZZASS_CHANNEL_AGAIN);
        }
        free(w->job_id);snprintf(label,sizeof(label),"native-job-%u",i);w->job_id=strdup(label);CHECK(w->job_id);
        CHECK(dizzass_native_work_tx88(w,2,0,i,expected,88)==0);
        watch_io=1;write_calls=0;
        CHECK(dizzass_tx_channel_send(c,w,200,&sent)==0);
        watch_io=0;
        CHECK(sent.ticket.slot==i&&sent.io.written==88&&sent.io.outcome==DIZZASS_SERIAL_WRITTEN&&write_calls==13);
        receive(m,packet,88);CHECK(!memcmp(packet,expected,88));++sends;
        if(i) {
            CHECK(write(m,old+5,6)==6);
            CHECK(event(c,101,&result)==DIZZASS_CHANNEL_DISCARDED);
            CHECK(result.match_status==DIZZASS_JOBS_QUARANTINED&&!result.job.check.work);++late;
        }
        make_reply(i,reply);
        if(i==0) {
            unsigned bit;
            for(bit=0;bit<72;++bit) {
                uint8_t bad[11];uint32_t before=total_work;
                memcpy(bad,reply,11);bad[2+bit/8]^=(uint8_t)(1u<<(bit%8));
                CHECK(write(m,bad,11)==11);
                CHECK(event(c,101,&result)==DIZZASS_CHANNEL_DISCARDED);
                CHECK(result.match_status==DIZZASS_RX_CRC_MISMATCH);
                CHECK(!result.job.check.work&&total_work==before);++crc_rejected;
            }
            /* Bad and good frames in the same tty read must not merge. */
            {uint8_t both[22];uint32_t before=total_work;
             memcpy(both,reply,11);both[10]^=1;memcpy(both+11,reply,11);
             CHECK(write(m,both,sizeof(both))==(ssize_t)sizeof(both));
             CHECK(event(c,101,&result)==DIZZASS_CHANNEL_DISCARDED);
             CHECK(result.match_status==DIZZASS_RX_CRC_MISMATCH&&total_work==before);
             ++crc_rejected;CHECK(event(c,101,&result)==0);
             CHECK(result.job.check.meets_target);dizzass_job_result_clear(&result.job);}
        }
        CHECK(write(m,reply,11)==11);
        CHECK(dizzass_tx_channel_read(c,100,&result)==DIZZASS_JOBS_OLD_EPOCH);
        CHECK(event(c,101,&result)==0);
        CHECK(result.job.check.passes_diff1&&result.job.check.meets_target&&result.job.ticket.slot==i);
        CHECK(!memcmp(result.job.check.work->hash,fixture_hash,32));
        CHECK(!strcmp(result.job.check.work->job_id,label));++valid;
        if(i==31)held=result;else dizzass_job_result_clear(&result.job);
    }
    CHECK(dizzass_tx_channel_send(c,w,100,&sent)==DIZZASS_JOBS_EXHAUSTED);
    CHECK(sent.io.written==0&&sent.io.outcome==DIZZASS_SERIAL_NOT_SENT);
    CHECK(read(m,packet,88)<0&&errno==EAGAIN);
    {struct dizzass_channel_rx_result r={0};make_reply(0,reply);CHECK(write(m,reply,11)==11);
     CHECK(event(c,101,&r)==DIZZASS_CHANNEL_DISCARDED&&r.match_status==DIZZASS_JOBS_QUARANTINED);++late;}
    CHECK(dizzass_tx_channel_stop(c)==0&&dizzass_tx_channel_stop(c)==0);
    CHECK(dizzass_tx_channel_send(c,w,100,&sent)==DIZZASS_CHANNEL_STOPPED);
    dizzass_tx_channel_destroy(&c);dizzass_tx_channel_destroy(&c);free_work(w);close(m);
    CHECK(!strcmp(held.job.check.work->job_id,"native-job-31"));
    CHECK(!strcmp(held.job.check.work->coinbase,"owned-copy"));dizzass_job_result_clear(&held.job);
}
static void partial_stops_channel(void)
{
    struct dizzass_hwscan_profile p=profile();struct dizzass_tx_channel *c=NULL;
    struct work *w=work_fixture();struct dizzass_channel_send_result sent;
    struct dizzass_channel_rx_result r={0};uint8_t bytes[88];int m,s;
    pair(&m,&s);CHECK(dizzass_tx_channel_create(&p,2,201,s,&c)==0);close(s);
    watch_io=1;fail_partial=1;write_calls=0;
    CHECK(dizzass_tx_channel_send(c,w,100,&sent)==DIZZASS_SERIAL_IO);
    watch_io=0;fail_partial=0;
    CHECK(sent.io.written==7&&sent.io.outcome==DIZZASS_SERIAL_UNCERTAIN);
    receive(m,bytes,7);CHECK(dizzass_tx_channel_send(c,w,100,&sent)==DIZZASS_CHANNEL_STOPPED);
    CHECK(dizzass_tx_channel_read(c,201,&r)==DIZZASS_CHANNEL_STOPPED);
    CHECK(read(m,bytes,88)<0&&errno==EAGAIN);
    dizzass_tx_channel_destroy(&c);free_work(w);close(m);
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;
    lifecycle();partial_stops_channel();
    printf("NATIVE_TX_CHANNEL_PASS sends=%u valid=%u late_rejected=%u crc_rejected=%u checks=%u actual_pty=yes physical_asic=no\n",sends,valid,late,crc_rejected,checks);
    return 0;
}
