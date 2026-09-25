/* Offline composition with the actual cgminer core; never its startup.
 * GPL-3.0-or-later. Synthetic inputs, no board emulation or pool connection.
 */
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "integration/native_nonce.h"
#include "integration/bm1368_nonce.h"
#include "xminer/recovery/work_rx.h"
#include "tests/fixtures/genesis_work.h"
#include <sys/socket.h>

int __wrap_socket(int domain,int type,int protocol)
{ (void)domain;(void)type;(void)protocol; abort(); }
int __wrap_connect(int fd,const struct sockaddr *address,socklen_t size)
{ (void)fd;(void)address;(void)size; abort(); }
int __wrap_libusb_init(libusb_context **context)
{ (void)context; abort(); }
static unsigned checks, vectors, streams;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"bm1368 native failed at %d: %s\n",__LINE__,#x); exit(1); \
} } while (0)
static uint32_t random_state=UINT32_C(0x13681368);
static uint32_t next_word(void)
{
    random_state^=random_state<<13; random_state^=random_state>>17;
    random_state^=random_state<<5; return random_state;
}
static uint32_t le32(const uint8_t *p)
{ return p[0]|(uint32_t)p[1]<<8|(uint32_t)p[2]<<16|(uint32_t)p[3]<<24; }
static void print_hex(const uint8_t *p,size_t n)
{ size_t i; for(i=0;i<n;++i) printf("%02x",p[i]); }
static struct work *test_work(void)
{
    struct work *w=make_work();
    memcpy(w->data,fixture_words,sizeof(fixture_words));
    memset(w->hash,0xa5,sizeof(w->hash)); set_target(w->target,1.0);
    w->job_id=strdup("bm1368-offline");w->nonce1=strdup("00112233");
    w->ntime=strdup("495fab29");w->coinbase=strdup("owned-offline-string");
    CHECK(w->job_id&&w->nonce1&&w->ntime&&w->coinbase); return w;
}
static void attribution_vectors(void)
{
    unsigned variant,i,j;
    for(variant=0;variant<3;++variant) for(i=0;i<32;++i) {
        uint8_t payload[9]; struct dizzass_nonce_reply r;
        struct dizzass_bm1368_location at;
        unsigned count=(next_word()%256)+1;
        for(j=0;j<7+variant;++j) payload[j]=(uint8_t)next_word();
        payload[6+variant]|=0x80;
        CHECK(dizzass_nonce_decode_payload(4,variant,2,payload,7+variant,&r)==0);
        CHECK(dizzass_bm1368_locate(4,count,r.nonce_word,&at)==0);
        CHECK(at.chip<count&&at.core<128);
        printf("BM1368_NATIVE %u %u ",count,variant); print_hex(payload,7+variant);
        printf(" %08x %u %u\n",r.nonce_word,at.chip,at.core); ++vectors;
    }
}
static void fragmented_native_hash(void)
{
    unsigned fragment;
    for(fragment=1;fragment<=11;++fragment) {
        struct work *source=test_work(), before=*source;
        struct dizzass_nonce_reply reply;
        struct dizzass_nonce_check checked={0};
        struct dizzass_bm1368_location at;
        struct dizzass_nonce_match match={source,2,3,2,0};
        vn135_work_rx_stream stream;vn135_work_rx_message message;
        /* Synthetic known historical nonce; NOT an observed T21 response.
         * BM1368 slot 3 occupies payload[5] bits 4..7 in this RX variant. */
        uint8_t frame[11]={0xaa,0x55,0x1d,0xac,0x2b,0x7c,0,0x30,0,0,0x80};
        uint8_t serial[80];size_t pos=0,j;
        match.version_base_word=le32(source->data);
        CHECK(vn135_work_rx_stream_init(&stream,2,1,4,0)==0);
        CHECK(stream.policy.variant==2);
        while(pos<sizeof(frame)) {
            size_t n=sizeof(frame)-pos, used=0; int rc;
            if(n>fragment)n=fragment;
            rc=vn135_work_rx_stream_feed(&stream,frame+pos,n,&used,&message);
            CHECK(used>0&&used<=n);pos+=used;
            CHECK(rc==(pos<sizeof(frame)?VN135_RX_NEED_MORE:VN135_RX_NONCE_RAW));
        }
        CHECK(dizzass_nonce_decode_payload(4,2,message.chain_id,message.payload,message.payload_size,&reply)==0);
        CHECK(reply.slot==3&&reply.nonce_word==le32(fixture_words+76));
        CHECK(dizzass_bm1368_locate(4,108,reply.nonce_word,&at)==0);
        CHECK(at.chip==90&&at.core==14);
        CHECK(dizzass_nonce_check_matched(&match,&reply,&checked)==0);
        CHECK(checked.passes_diff1&&checked.meets_target);
        CHECK(!memcmp(checked.work->hash,fixture_hash,32));
        CHECK(!memcmp(source,&before,sizeof(before)));
        CHECK(checked.work->job_id!=source->job_id);
        free_work(source);
        CHECK(!strcmp(checked.work->job_id,"bm1368-offline"));
        for(j=0;j<80;++j) serial[j]=checked.work->data[(j&~(size_t)3)+(3-(j&3))];
        printf("BM1368_HASH ");print_hex(serial,80);printf(" ");print_hex(checked.work->hash,32);printf("\n");
        dizzass_nonce_check_clear(&checked);dizzass_nonce_check_clear(&checked);++streams;
    }
}
int main(void)
{
    mutex_init(&stats_lock);mutex_init(&console_lock);cglock_init(&control_lock);
    opt_debug=false;opt_quiet=true;opt_realquiet=true;
    attribution_vectors();fragmented_native_hash();
    printf("BM1368_NATIVE_PASS vectors=%u streams=%u checks=%u\n",vectors,streams,checks);
    return 0;
}
