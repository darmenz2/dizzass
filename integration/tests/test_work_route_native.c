/* Real cgminer work/registry composition; synthetic replies, NO hardware.
 * GPL-3.0-or-later. Includes the root core only in this test translation unit.
 */
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "integration/native_work_tx88.h"
#include "tests/fixtures/genesis_work.h"
#include <sys/socket.h>

int __wrap_socket(int d,int t,int p)
{ (void)d;(void)t;(void)p;abort(); }
int __wrap_connect(int fd,const struct sockaddr *a,socklen_t n)
{ (void)fd;(void)a;(void)n;abort(); }
int __wrap_libusb_init(libusb_context **ctx)
{ (void)ctx;abort(); }
static int fail_strdup=-1;
char *__real_strdup(const char *s);
char *__wrap_strdup(const char *s)
{
    if(fail_strdup==0) { fail_strdup=-1;return NULL; }
    if(fail_strdup>0) --fail_strdup;
    return __real_strdup(s);
}
static unsigned checks,vectors,slots,failures;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"route native %d: %s\n",__LINE__,#x);exit(1); \
} } while(0)
static uint32_t rng=UINT32_C(0x88322026);
static uint32_t random_word(void)
{ rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;return rng; }
static uint32_t le32(const uint8_t *p)
{ return p[0]|(uint32_t)p[1]<<8|(uint32_t)p[2]<<16|(uint32_t)p[3]<<24; }
static void hex(const uint8_t *p,size_t n)
{ size_t i;for(i=0;i<n;++i)printf("%02x",p[i]); }
static struct work *fixture(void)
{
    struct work *w=make_work();
    memcpy(w->data,fixture_words,sizeof(fixture_words));
    memset(w->hash,0xa5,sizeof(w->hash));set_target(w->target,1.0);
    w->job_id=strdup("tx88-offline");w->nonce1=strdup("00112233");
    w->ntime=strdup("495fab29");w->coinbase=strdup("retained-native-string");
    CHECK(w->job_id&&w->nonce1&&w->ntime&&w->coinbase);return w;
}
static struct dizzass_nonce_reply synthetic_reply(unsigned slot)
{
    uint8_t p[9]={0};struct dizzass_nonce_reply r;unsigned i;
    uint32_t nonce=le32(fixture_words+76);
    for(i=0;i<4;++i)p[i]=(uint8_t)(nonce>>(24-8*i));
    /* Separate TX/RX representations. This is NOT a captured chip reply. */
    p[4]=(uint8_t)(slot>>4);p[5]=(uint8_t)((slot&15u)<<4);p[8]=0x80;
    CHECK(dizzass_nonce_decode_payload(4,2,2,p,sizeof(p),&r)==0);
    CHECK(r.slot==slot&&r.chain_id==2&&r.version_bits==0);return r;
}
static void emit_vectors(void)
{
    unsigned i,j;
    for(i=0;i<64;++i) {
        struct work *w=fixture(),before;uint8_t out[88];
        uint32_t allocations=total_work;
        for(j=0;j<80;++j)w->data[j]=(uint8_t)random_word();before=*w;
        CHECK(dizzass_native_work_tx88(w,2,0,i&31u,out,sizeof(out))==0);
        CHECK(total_work==allocations&&!memcmp(&before,w,sizeof(before)));
        printf("ROUTE_TX88_NATIVE %u ",i&31u);hex(w->data,80);printf(" ");hex(out,88);printf("\n");
        free_work(w);++vectors;
    }
}
static void all_slots(void)
{
    struct dizzass_jobs *jobs=NULL;
    struct work *source=fixture(),before=*source;
    struct dizzass_job_result last={0};
    unsigned i,j;
    CHECK(dizzass_jobs_create(2,1,&jobs)==0);
    for(i=0;i<32;++i) {
        struct dizzass_tx88_prepared prepared={0},other={0},saved;
        struct dizzass_nonce_reply r=synthetic_reply(i);
        struct dizzass_job_result result={0};
        memset(prepared.packet,0xa5,sizeof(prepared.packet));
        CHECK(dizzass_jobs_prepare_tx88(jobs,1,2,0,i,2,source,&prepared)==0);
        CHECK(prepared.ticket.slot==i&&prepared.ticket.chain_id==2&&prepared.ticket.epoch==1);
        CHECK(prepared.packet[4]==i*8u);
        for(j=0;j<76;++j)CHECK(prepared.packet[10+j]==source->data[75-j]);
        CHECK(dizzass_jobs_check(jobs,1,&r,&result)==DIZZASS_JOBS_PENDING&&!result.check.work);
        memset(other.packet,0x5a,sizeof(other.packet));saved=other;
        CHECK(dizzass_jobs_prepare_tx88(jobs,1,2,0,i,2,source,&other)==DIZZASS_JOBS_BUSY);
        CHECK(!memcmp(&other,&saved,sizeof(other)));
        /* Only an explicit SYNTHETIC transport completion permits lookup. */
        CHECK(dizzass_jobs_finish(jobs,&prepared.ticket,DIZZASS_TX_WRITTEN)==0);
        CHECK(dizzass_jobs_finish(jobs,&prepared.ticket,DIZZASS_TX_WRITTEN)==DIZZASS_JOBS_STALE_TICKET);
        CHECK(dizzass_jobs_check(jobs,1,&r,&result)==0);
        CHECK(result.check.work!=source&&result.check.passes_diff1&&result.check.meets_target);
        CHECK(!memcmp(result.check.work->hash,fixture_hash,32));
        CHECK(result.check.work->job_id!=source->job_id&&!strcmp(result.check.work->job_id,source->job_id));
        CHECK(dizzass_jobs_retire(jobs,&prepared.ticket)==0);
        CHECK(dizzass_jobs_prepare_tx88(jobs,1,2,0,i,2,source,&other)==DIZZASS_JOBS_QUARANTINED);
        CHECK(!memcmp(&other,&saved,sizeof(other)));
        if(i==31)last=result;else dizzass_job_result_clear(&result);
        ++slots;
    }
    CHECK(!memcmp(source,&before,sizeof(before)));free_work(source);
    dizzass_jobs_destroy(&jobs);CHECK(!jobs);
    CHECK(!strcmp(last.check.work->job_id,"tx88-offline"));
    CHECK(!strcmp(last.check.work->coinbase,"retained-native-string"));
    CHECK(!memcmp(last.check.work->hash,fixture_hash,32));
    dizzass_job_result_clear(&last);dizzass_job_result_clear(&last);
}
static void failure_cases(void)
{
    struct dizzass_jobs *jobs=NULL;struct work *w=fixture(),before=*w;
    struct dizzass_tx88_prepared out={0},saved;
    struct dizzass_job_result checked={0};
    struct dizzass_nonce_reply r=synthetic_reply(0);
    unsigned i;uint32_t allocations;
    CHECK(dizzass_jobs_create(2,7,&jobs)==0);
    memset(out.packet,0xa5,sizeof(out.packet));saved=out;allocations=total_work;
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,1,0,2,w,&out)==DIZZASS_ROUTE_UNSUPPORTED);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,0,0,0,2,w,&out)==DIZZASS_ROUTE_UNSUPPORTED);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,2,0,2,w,&out)==DIZZASS_ROUTE_UNSUPPORTED);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,5,0,0,2,w,&out)==DIZZASS_ROUTE_UNSUPPORTED);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,32,2,w,&out)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,3,w,&out)==DIZZASS_JOBS_INVALID);
    CHECK(dizzass_jobs_prepare_tx88(jobs,6,2,0,0,2,w,&out)==DIZZASS_JOBS_OLD_EPOCH);
    CHECK(dizzass_jobs_prepare_tx88(NULL,7,2,0,0,2,w,&out)==DIZZASS_JOBS_INVALID);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,2,NULL,&out)==DIZZASS_JOBS_INVALID);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,2,w,NULL)==DIZZASS_JOBS_INVALID);
    CHECK(!memcmp(&out,&saved,sizeof(out))&&allocations==total_work);
    for(i=0;i<4;++i) {
        fail_strdup=(int)i;
        CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,2,w,&out)==DIZZASS_NONCE_PARTIAL_COPY);
        fail_strdup=-1;
        CHECK(!memcmp(&out,&saved,sizeof(out)));
        CHECK(dizzass_jobs_check(jobs,7,&r,&checked)==DIZZASS_JOBS_EMPTY);
        ++failures;
    }
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,2,w,&out)==0);
    CHECK(dizzass_jobs_finish(jobs,&out.ticket,DIZZASS_TX_NOT_SENT)==0);
    memset(&out,0,sizeof(out));
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,2,w,&out)==0);
    CHECK(dizzass_jobs_finish(jobs,&out.ticket,DIZZASS_TX_UNCERTAIN)==0);
    memset(&out,0,sizeof(out));memset(out.packet,0xa5,sizeof(out.packet));saved=out;
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,0,2,w,&out)==DIZZASS_JOBS_QUARANTINED);
    CHECK(!memcmp(&out,&saved,sizeof(out)));
    CHECK(dizzass_jobs_pause(jobs,7)==0);
    CHECK(dizzass_jobs_prepare_tx88(jobs,7,2,0,1,2,w,&out)==DIZZASS_JOBS_PAUSED);
    CHECK(!memcmp(&out,&saved,sizeof(out))&&!memcmp(w,&before,sizeof(before)));
    dizzass_jobs_destroy(&jobs);free_work(w);
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;
    emit_vectors();all_slots();failure_cases();
    printf("WORK_ROUTE_NATIVE_PASS vectors=%u slots=%u strdup_failures=%u checks=%u\n",vectors,slots,failures,checks);
    return 0;
}
