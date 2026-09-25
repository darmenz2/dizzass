/* Real cgminer + Linux PTY. Firmware and physical ASIC are never executed. */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "integration/native_tx_channel.h"
#include "integration/native_power_guard.h"
#include "integration/gpio_value_io.h"
#include <sys/stat.h>
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
struct power_fixture {
    struct dizzass_tx_channel **channels;
    struct work *work;
    int dirs[4];
    unsigned seen,failmask;
};
static void put_attr(int dir,const char *name,const char *text)
{
    int fd=openat(dir,name,O_CREAT|O_TRUNC|O_WRONLY,0600);
    CHECK(fd>=0);CHECK(write(fd,text,strlen(text))==(ssize_t)strlen(text));CHECK(close(fd)==0);
}
static int write_gpio_fixture(void *p,const struct dizzass_gpio_request *request)
{
    struct power_fixture *f=p;unsigned i=f->seen++;struct dizzass_gpio_io_receipt r;
    unsigned j;CHECK(i<4);CHECK(request->pin==(i?453+i:437));CHECK(request->value==(i?0:1));
    /* This runs after ALL channels were stopped, even on cutoff failure. */
    for(j=0;j<3;++j){struct dizzass_channel_send_result sent;CHECK(dizzass_tx_channel_send(f->channels[j],f->work,50,&sent)==DIZZASS_CHANNEL_STOPPED);CHECK(sent.io.written==0);}
    if(f->failmask&(1u<<i)) return -42;
    CHECK(dizzass_gpio_value_write_at(f->dirs[i],request->value,&r)==0);CHECK(r.written==1);
    return 0;
}
static void trip_case(unsigned failure)
{
    struct dizzass_tx_channel *channels[3]={0};int master[3],slave[3],root;
    struct dizzass_hwscan_profile p=profile();struct work *w=work_fixture();
    struct power_fixture f={.channels=channels,.work=w,.seen=0,.failmask=failure};
    struct dizzass_thermal_sample sample={501,1000,50,60,15,1,1};
    struct dizzass_thermal_limits limits={80,90,100};
    struct dizzass_native_trip_receipt result;char temp[]="/tmp/dizzass-native-power-XXXXXX";
    uint8_t packet[88];unsigned i;char name[24];
    /* Explicit synthetic three-board fixture, NOT a scanned physical machine. */
    p.board_count=3;
    for(i=0;i<3;++i){p.boards[i].id=i;p.boards[i].ready=1;strcpy(p.boards[i].model,"fixture");}
    for(i=0;i<3;++i){
        struct dizzass_channel_send_result sent;
        pair(&master[i],&slave[i]);CHECK(!dizzass_tx_channel_create(&p,i,501,slave[i],&channels[i]));close(slave[i]);
        CHECK(!dizzass_tx_channel_send(channels[i],w,100,&sent));receive(master[i],packet,88);
    }
    CHECK(mkdtemp(temp));root=open(temp,O_RDONLY|O_DIRECTORY);CHECK(root>=0);
    for(i=0;i<4;++i){snprintf(name,sizeof(name),"gpio%u",i?453+i:437);CHECK(!mkdirat(root,name,0700));f.dirs[i]=openat(root,name,O_RDONLY|O_DIRECTORY);CHECK(f.dirs[i]>=0);put_attr(f.dirs[i],"direction","out\n");put_attr(f.dirs[i],"active_low","0\n");put_attr(f.dirs[i],"value",i?"1":"0");}
    CHECK(!dizzass_native_aml_check(channels,&sample,&limits,501,1000,write_gpio_fixture,&f,&result));CHECK(f.seen==0);
    sample.chip=90;
    CHECK(dizzass_native_aml_check(channels,&sample,&limits,501,1000,write_gpio_fixture,&f,&result)==(failure?DIZZASS_POWER_SHUTDOWN_FAILED:1));
    CHECK(result.reason==DIZZASS_THERMAL_CHIP&&f.seen==4&&result.shutdown.attempted_mask==127);
    CHECK(result.shutdown.reported_ok_mask==(127u^(failure<<3)));
    /* Cooling the input does not rearm the stopped native channels. */
    sample.chip=60;
    CHECK(!dizzass_native_aml_check(channels,&sample,&limits,501,1001,write_gpio_fixture,&f,&result));
    for(i=0;i<3;++i){struct dizzass_channel_send_result sent;CHECK(dizzass_tx_channel_send(channels[i],w,100,&sent)==DIZZASS_CHANNEL_STOPPED);CHECK(read(master[i],packet,88)<0&&errno==EAGAIN);dizzass_tx_channel_destroy(&channels[i]);close(master[i]);}
    for(i=0;i<4;++i){char c;int fd=openat(f.dirs[i],"value",O_RDONLY);CHECK(fd>=0&&read(fd,&c,1)==1);close(fd);CHECK(c==(failure&(1u<<i)?(i?'1':'0'):(i?'0':'1')));CHECK(!unlinkat(f.dirs[i],"value",0));CHECK(!unlinkat(f.dirs[i],"direction",0));CHECK(!unlinkat(f.dirs[i],"active_low",0));close(f.dirs[i]);snprintf(name,sizeof(name),"gpio%u",i?453+i:437);CHECK(!unlinkat(root,name,AT_REMOVEDIR));}
    close(root);CHECK(!rmdir(temp));free_work(w);
}
static void software_rearm_negative_control(void)
{
    /* Deliberately violates create()'s CLEAN DEVICE precondition to test the
     * proposition that epoch++ alone proves a drain. It does not. This is NOT
     * an available rearm operation in the production channel interface.
     */
    struct dizzass_hwscan_profile p=profile();struct dizzass_tx_channel *c=NULL;
    struct work *w=work_fixture();struct dizzass_channel_send_result sent;
    struct dizzass_channel_rx_result r={0};int m,s;
    uint8_t original[88],replacement[88],old_reply[11];
    pair(&m,&s);CHECK(!dizzass_tx_channel_create(&p,2,601,s,&c));
    CHECK(!dizzass_tx_channel_send(c,w,100,&sent));receive(m,original,88);make_reply(0,old_reply);
    CHECK(!dizzass_tx_channel_stop(c));dizzass_tx_channel_destroy(&c);
    free(w->job_id);w->job_id=strdup("new-pool-job-same-header");CHECK(w->job_id);
    /* No hardware drain between these sessions, intentionally. */
    CHECK(!dizzass_tx_channel_create(&p,2,602,s,&c));close(s);
    CHECK(!dizzass_tx_channel_send(c,w,100,&sent));receive(m,replacement,88);
    CHECK(!memcmp(original,replacement,88));CHECK(write(m,old_reply,11)==11);
    CHECK(event(c,602,&r)==0&&r.job.check.passes_diff1&&r.job.check.meets_target);
    CHECK(!strcmp(r.job.check.work->job_id,"new-pool-job-same-header"));
    dizzass_job_result_clear(&r.job);dizzass_tx_channel_destroy(&c);close(m);free_work(w);
    puts("DRAIN_NEGATIVE_CONTROL old_CRC_valid_reply_indistinguishable_after_unproven_rearm=yes physical_drain_proven=no");
}
static void profile_range(void)
{
    struct dizzass_hwscan_profile p=profile();
    CHECK(!dizzass_hwscan_profile_validate(&p,2));p.boards[0].id=3;
    CHECK(dizzass_hwscan_profile_validate(&p,3)==DIZZASS_PROFILE_UNSUPPORTED);
    p=profile();p.nominal_boards=4;CHECK(dizzass_hwscan_profile_validate(&p,2)==DIZZASS_PROFILE_UNSUPPORTED);
    {json_t *h=json_loads(fixture_hw_json,0,NULL);char *encoded;struct dizzass_hwscan_profile save=p;
     CHECK(h);CHECK(!json_object_set_new(json_array_get(json_object_get(h,"boards"),0),"id",json_integer(3)));
     encoded=json_dumps(h,0);CHECK(encoded);
     CHECK(dizzass_hwscan_profile_parse(fixture_fw_json,strlen(fixture_fw_json),fixture_model_json,strlen(fixture_model_json),encoded,strlen(encoded),&p)==DIZZASS_PROFILE_UNSUPPORTED);
     CHECK(!memcmp(&p,&save,sizeof(p)));free(encoded);json_decref(h);}
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;
    profile_range();trip_case(0);trip_case(1);software_rearm_negative_control();
    printf("NATIVE_POWER_GUARD_PASS checks=%u stopped_channels=6 actual_pty=yes gpio_tempfiles=yes physical_asic=no\n",checks);
    return 0;
}
