#include "integration/common_read_register_135.h"
#include "integration/transport_initialize_135.h"
#include "integration/bm1368_initialize_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned checks, cases;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"COMMON_READ_FAIL line=%d %s\n",__LINE__,#x); exit(1); \
} } while (0)

/* Test-only polynomial division, independently expressed from the reused
 * byte/bit recurrence: x^5+x^2+1, initial 1f, MSB first, no final XOR. */
static uint8_t expected_crc(const uint8_t body[4])
{
    uint32_t message=((uint32_t)body[0]<<24)|((uint32_t)body[1]<<16)|
        ((uint32_t)body[2]<<8)|body[3];
    uint64_t remainder=((uint64_t)message<<5)^(UINT64_C(31)<<32);
    for(int bit=36;bit>=5;--bit)
        if(remainder&(UINT64_C(1)<<(unsigned)bit))
            remainder^=UINT64_C(0x25)<<(unsigned)(bit-5);
    return (uint8_t)remainder;
}
static void packet(uint8_t out[5],uint32_t mode,uint32_t address,uint32_t reg)
{
    out[0]=(uint8_t)(0x42u+16u*(mode%2u));out[1]=5;
    out[2]=(uint8_t)(address%256u);out[3]=(uint8_t)(reg%256u);
    out[4]=expected_crc(out);
}
static void diagnostic(const struct vn135_common_read_diagnostic_135 *d,
                       uint32_t index)
{
    CHECK(strcmp(d->module,"driver")==0);
    CHECK(strcmp(d->source_path,"/tmp/build/libbitmain/src/chip/chip.c")==0);
    CHECK(strcmp(d->function,"[redacted]")==0);
    CHECK(strcmp(d->format,"chain#%d - failed to send GET_STATUS command")==0);
    CHECK(d->source_line==103 && d->severity==1);
    CHECK(d->index_bits==index+UINT32_C(1));
}
struct recorded {
    void *identity;
    uint32_t *index;
    vn135_chip_reference *chip;
    uint8_t expected[5],copied[5];
    uint32_t index_after_send,index_after_log,wire_after_send;
    int32_t status;
    unsigned sends,logs,mutate_index,mutate_chip,mutate_log;
};
static int32_t send_record(void *opaque,void *device,const uint8_t *body,uint32_t n)
{
    struct recorded *r=opaque;
    CHECK(r->sends==0 && r->logs==0);++r->sends;
    CHECK(device==r->identity && n==5);
    CHECK(memcmp(body,r->expected,5)==0);memcpy(r->copied,body,5);
    if(r->mutate_index) *r->index=r->index_after_send;
    if(r->mutate_chip) r->chip->wire_address=r->wire_after_send;
    return r->status;
}
static void log_record(void *opaque,const struct vn135_common_read_diagnostic_135 *d)
{
    struct recorded *r=opaque;
    CHECK(r->sends==1 && r->logs==0 && r->status!=0);++r->logs;
    diagnostic(d,*r->index);
    if(r->mutate_log) *r->index=r->index_after_log;
}
static void golden_vectors(void)
{
    static const uint8_t vectors[][5]={
        {0x42,5,0,0,0x0e},{0x52,5,0,0,0x0a},
        {0x42,5,0xff,0x18,6},{0x52,5,0xff,0x18,2},
        {0x42,5,1,0xff,6},{0x52,5,1,0xff,2},
        {0x42,5,0xff,0xff,5},{0x52,5,0xff,0xff,1}
    };
    for(size_t i=0;i<sizeof(vectors)/sizeof(vectors[0]);++i) {
        uint8_t b[5];++cases;packet(b,(uint32_t)i%2u,vectors[i][2],vectors[i][3]);
        CHECK(memcmp(b,vectors[i],5)==0);
    }
}
static void direct_cases(void)
{
    static const uint32_t modes[]={0,1,2,3,0x80000000u,0x80000001u,UINT32_MAX-1,UINT32_MAX};
    static const uint32_t addresses[]={0,1,255,256,257,0x80000000u,UINT32_MAX};
    static const uint32_t registers[]={0,1,0x18,255,256,257,0x80000000u,UINT32_MAX};
    static const int32_t statuses[]={0,-1,-55,1,INT32_MIN,INT32_MAX};
    static const uint32_t indices[]={0,1,UINT32_MAX,INT32_MAX,0x80000000u,UINT32_MAX-1};
    for(size_t m=0;m<8;++m) for(size_t a=0;a<8;++a)
    for(size_t g=0;g<8;++g) for(size_t s=0;s<6;++s) {
        uint32_t index=indices[cases%6];uint32_t old=index;
        vn135_chip_reference chip={INT32_MIN,a<7?addresses[a]:0};
        uint32_t old_wire=chip.wire_address;
        struct recorded r={0};r.identity=&chip;r.index=&index;r.chip=&chip;
        r.status=statuses[s];r.mutate_index=cases%2;r.mutate_chip=(unsigned)(a<7 && cases%3==0);
        r.mutate_log=(unsigned)(r.status!=0 && cases%3==1);
        r.index_after_send=indices[(cases/2)%6];r.index_after_log=UINT32_C(0x673412ef);
        r.wire_after_send=UINT32_C(0xfeedbeef);
        packet(r.expected,modes[m],a<7?old_wire:0,registers[g]);
        struct vn135_common_read_device_135 device={r.identity,&index};
        struct vn135_transport_dispatch_135 transport={send_record,&r};
        struct vn135_common_read_log_135 log={log_record,&r};
        ++cases;
        CHECK(vn135_common_read_register_135(&device,modes[m],a<7?&chip:NULL,registers[g],&transport,&log)==(r.status==0?0:-1));
        CHECK(r.sends==1 && r.logs==(unsigned)(r.status!=0));
        CHECK(memcmp(r.expected,r.copied,5)==0);
        CHECK(index==(r.mutate_log?r.index_after_log:r.mutate_index?r.index_after_send:old));
        CHECK(chip.wire_address==(r.mutate_chip?r.wire_after_send:old_wire));
        CHECK(chip.cache_index==INT32_MIN);
    }
    /* Diagnostic-only inputs need not exist on the zero-status path. A NULL
     * opaque device is explicitly accepted by this recording callback. */
    for(unsigned i=0;i<2;++i) {
        struct recorded r={0};uint32_t token=123;
        r.identity=i?&token:NULL;packet(r.expected,2,0,256);
        struct vn135_common_read_device_135 device={r.identity,NULL};
        struct vn135_transport_dispatch_135 transport={send_record,&r};++cases;
        CHECK(vn135_common_read_register_135(&device,2,NULL,256,&transport,NULL)==0);
        CHECK(r.sends==1 && r.logs==0);
    }
}

struct replaced {
    struct vn135_transport_dispatch_135 *table;
    struct recorded *current,*next;
};
static int32_t replace_for_next_call(void *opaque,void *device,const uint8_t *body,uint32_t n)
{
    struct replaced *x=opaque;
    x->table->send_payload=send_record;x->table->context=x->next;
    return send_record(x->current,device,body,n);
}
static void callback_replacement(void)
{
    uint32_t index=7;struct recorded a={0},b={0};
    a.identity=b.identity=&index;a.index=b.index=&index;a.status=-99;
    a.mutate_index=1;a.index_after_send=UINT32_MAX;
    packet(a.expected,3,0,0xff);memcpy(b.expected,a.expected,5);
    struct vn135_transport_dispatch_135 transport={0};
    struct replaced x={&transport,&a,&b};transport.send_payload=replace_for_next_call;transport.context=&x;
    struct vn135_common_read_device_135 device={&index,&index};
    struct vn135_common_read_log_135 log={log_record,&a};++cases;
    CHECK(vn135_common_read_register_135(&device,3,NULL,UINT32_MAX,&transport,&log)==-1);
    CHECK(a.sends==1 && a.logs==1 && b.sends==0 && index==UINT32_MAX);
    CHECK(vn135_common_read_register_135(&device,3,NULL,UINT32_MAX,&transport,NULL)==0);
    CHECK(a.sends==1 && b.sends==1 && b.logs==0);
}

struct lower {
    uint32_t index;
    uint8_t before,frame[7],after,expected[7];
    unsigned outer_locked,inner_locked,allocations,releases,outer_locks,outer_unlocks;
    unsigned inner_locks,inner_unlocks,writes,errors,sleeps,sends,logs;
    int32_t error,write_status;
    struct vn135_aml_uart_binding_135 binding;
};
static void *allocate_frame(void *opaque,size_t n)
{
    struct lower *l=opaque;CHECK(n==7 && l->allocations==0);++l->allocations;return l->frame;
}
static void release_frame(void *opaque,void *p)
{
    struct lower *l=opaque;CHECK(p==l->frame && !l->outer_locked && !l->inner_locked);
    CHECK(l->releases==0 && l->writes>0);++l->releases;
}
static void outer_lock(void *opaque)
{struct lower *l=opaque;CHECK(!l->outer_locked && !l->inner_locked);l->outer_locked=1;++l->outer_locks;}
static void outer_unlock(void *opaque)
{struct lower *l=opaque;CHECK(l->outer_locked && !l->inner_locked);l->outer_locked=0;++l->outer_unlocks;}
static void inner_lock(void *opaque)
{struct lower *l=opaque;CHECK(l->outer_locked && !l->inner_locked);l->inner_locked=1;++l->inner_locks;}
static void inner_unlock(void *opaque)
{struct lower *l=opaque;CHECK(l->outer_locked && l->inner_locked);l->inner_locked=0;++l->inner_unlocks;}
static int32_t refused_write(void *opaque,int32_t fd,const uint8_t *bytes,uint32_t n)
{
    struct lower *l=opaque;CHECK(fd==-71 && l->outer_locked && l->inner_locked && n==7);
    CHECK(bytes==l->frame && memcmp(bytes,l->expected,7)==0);++l->writes;
    l->index=UINT32_MAX-(l->writes-1u);return l->write_status;
}
static int32_t *error_number(void *opaque)
{struct lower *l=opaque;CHECK(l->outer_locked && !l->inner_locked);++l->errors;return &l->error;}
static void record_sleep(void *opaque,uint32_t ms)
{struct lower *l=opaque;CHECK(ms==20 && l->outer_locked && !l->inner_locked);++l->sleeps;}
static int32_t forbidden_framing_write(void *opaque,void *uart,const uint8_t *bytes,uint32_t n)
{(void)opaque;(void)uart;(void)bytes;(void)n;CHECK(0);return -1;}
static int32_t selected_aml_send(void *opaque,void *device,const uint8_t *body,uint32_t n)
{
    struct lower *l=opaque;CHECK(l->sends==0 && n==5 && device==l->binding.device_identity);++l->sends;
    CHECK(memcmp(body,l->expected+2,5)==0);
    return vn135_aml_uart_send_135(&l->binding,device,body,n);
}
static void lower_log(void *opaque,const struct vn135_common_read_diagnostic_135 *d)
{
    struct lower *l=opaque;CHECK(l->sends==1 && l->logs==0 && l->releases==1);++l->logs;
    CHECK(!l->outer_locked && !l->inner_locked);diagnostic(d,l->index);
}
static int32_t initialize_bm1368(void *context,uint32_t entry,void *words)
{CHECK(context==words && entry==UINT32_C(0xe1450));return vn135_bm1368_initialize_135(words);}
static void aml_composition(void)
{
    for(unsigned scenario=0;scenario<3;++scenario) {
        struct lower l={0};l.before=0xa5;l.after=0x5a;l.index=7;
        l.error=scenario==2?VN135_UART_EAGAIN:5;l.write_status=scenario==1?2:-55;
        l.expected[0]=0x55;l.expected[1]=0xaa;packet(l.expected+2,3,0x101,0x1ff);
        vn135_uart uart=VN135_UART_INITIALIZER;uart.fd=-71;
        vn135_aml_transport framing={&l,allocate_frame,release_frame,outer_lock,outer_unlock,forbidden_framing_write};
        vn135_uart_ops uart_ops={0};uart_ops.context=&l;uart_ops.write=refused_write;
        uart_ops.lock=inner_lock;uart_ops.unlock=inner_unlock;uart_ops.error_number=error_number;uart_ops.sleep_ms=record_sleep;
        l.binding=(struct vn135_aml_uart_binding_135){&l,&uart,&framing,&uart_ops};
        struct vn135_transport_dispatch_135 transport={selected_aml_send,&l};
        struct vn135_common_read_device_135 device={&l,&l.index};
        struct vn135_common_read_log_135 log={lower_log,&l};vn135_chip_reference chip={-1,0x101};
        uint32_t shared=0,words[56]={0};
        struct vn135_transport_initialize_view_135 view={&shared,words,words};
        struct vn135_transport_initialize_ops_135 init={initialize_bm1368};++cases;
        CHECK(vn135_transport_initialize_135(2,4,1,&view,&init,words)==0);
        /* Explicit host admission of two known identities, then call real C
         * symbols. Never reinterpret integer ARM words as function pointers. */
        CHECK(shared==UINT32_C(0x117f7c) && words[0]==UINT32_C(0xd253c));
        CHECK(vn135_common_read_register_135(&device,3,&chip,0x1ff,&transport,&log)==-1);
        unsigned attempts=scenario==2?5u:1u;
        CHECK(l.sends==1 && l.logs==1 && l.writes==attempts);
        CHECK(l.allocations==1 && l.releases==1 && l.outer_locks==1 && l.outer_unlocks==1);
        CHECK(l.inner_locks==attempts && l.inner_unlocks==attempts && l.errors==1);
        CHECK(l.sleeps==(scenario==2?5u:0u));
        CHECK(l.before==0xa5 && l.after==0x5a && chip.wire_address==0x101);
        CHECK(!l.outer_locked && !l.inner_locked && memcmp(l.frame,l.expected,7)==0);
    }
}
int main(void)
{
    golden_vectors();direct_cases();callback_replacement();aml_composition();
    printf("COMMON_READ_PASS cases=%u checks=%u\n",cases,checks);return 0;
}
