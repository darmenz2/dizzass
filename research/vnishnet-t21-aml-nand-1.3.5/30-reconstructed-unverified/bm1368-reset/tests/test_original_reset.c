/* Independent host expectations from REPORT.md and the two complete static
 * listings: cgminer e1b64..e2098, hwscan f2214..f25dc. No firmware execution,
 * instruction interpreter, legacy oracle, physical I/O or real delays.
 * Callbacks borrow output/diagnostic pointers only until that call returns. */
#include "integration/bm1368_reset_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long checks,cases;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"ORIGINAL_RESET_FAIL case=%lu line=%d %s\n",cases,__LINE__,#x); \
    exit(1); } } while (0)

enum { R1,R2,R3,R4,W1,W2,W3,W4,W5,W6,W7,STATUS_COUNT };
enum { READ,WRITE,WAIT,LOG };
struct event { unsigned kind,id; uint32_t reg,value; };
struct fixture;
struct context { struct fixture *owner; unsigned kind; };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    struct context contexts[4];
    struct event events[32];
    unsigned count,cursor,reads,writes,waits,logs,mutate,output_mode;
    int32_t status[STATUS_COUNT],wait_status;
    uint32_t read_value[4],fast,unused,clock,pulse;
};
static int32_t signed_word(uint32_t value)
{
    return value<=INT32_MAX ? (int32_t)value :
        (int32_t)((int64_t)value-INT64_C(4294967296));
}
static void append(struct fixture *f,unsigned kind,unsigned id,uint32_t reg,uint32_t value)
{
    CHECK(f->count<32);f->events[f->count++]=(struct event){kind,id,reg,value};
}
/* This is a fixed branch-table transcript, not a second callable reset/cache
 * implementation. Each guard is pinned to a result-test address above. */
static void transcript(struct fixture *f)
{
    const uint32_t d=f->fast ? 1u:5u;
    append(f,READ,R1,0x18,0);
    if(f->status[R1])append(f,LOG,844,0,0);
    else append(f,WRITE,W1,0x18,f->read_value[R1]&UINT32_C(0xfffffcff));
    append(f,READ,R2,0xa8,0);
    if(f->status[R2])append(f,LOG,816,0,0);
    else {
        append(f,READ,R3,0x18,0);
        if(f->status[R3])append(f,LOG,821,0,0);
        else {
            append(f,WRITE,W2,0xa8,f->read_value[R2]|UINT32_C(0x1f0));
            if(!f->status[W2])append(f,WRITE,W3,0x18,
                (f->read_value[R3]&UINT32_C(0x00f0ffff))|UINT32_C(0xf0000000));
        }
    }
    append(f,WAIT,0,0,d);append(f,READ,R4,0x18,0);
    if(f->status[R4])append(f,LOG,844,0,0);
    else append(f,WRITE,W4,0x18,f->read_value[R4]|UINT32_C(0x300));
    append(f,WRITE,W5,0x3c,UINT32_C(0x80008b00));
    if(f->status[W5])append(f,LOG,444,0,0);
    append(f,WAIT,1,0,d);
    append(f,WRITE,W6,0x3c,UINT32_C(0x80008000)+
        (f->pulse%4u)*64u+(f->clock%8u)*8u);
    if(f->status[W6]){append(f,LOG,387,0,0);append(f,LOG,538,0,0);}
    append(f,WAIT,2,0,d);append(f,WRITE,W7,0x3c,UINT32_C(0x800082aa));
    if(f->status[W7])append(f,LOG,387,0,0);
    append(f,WAIT,3,0,d);append(f,WAIT,4,0,10);
}
static struct event next(struct fixture *f,unsigned kind)
{
    CHECK(f->cursor<f->count);
    struct event e=f->events[f->cursor++];CHECK(e.kind==kind);return e;
}
static struct fixture *owner(void *opaque,unsigned kind)
{
    struct context *c=opaque;CHECK(c->kind==kind);
    CHECK(c==&c->owner->contexts[kind]);return c->owner;
}
static void mutate(struct fixture *f,unsigned kind)
{
    static const uint32_t words[]={UINT32_MAX,UINT32_C(0x80000000),0,
        INT32_MAX,UINT32_C(0xfffffffe),17,UINT32_C(0x76543210)};
    if(f->mutate==1 || f->mutate==kind+2u) {
        f->device.index=words[f->cursor%7u];
        f->chip.cache_index=signed_word(words[(f->cursor+2u)%7u]);
        f->chip.wire_address=words[(f->cursor+3u)%7u];
    }
}
static int32_t read_record(void *opaque,int32_t chain,int32_t chip,
    uint32_t reg,uint32_t *output)
{
    struct fixture *f=owner(opaque,READ);struct event e=next(f,READ);
    CHECK(e.reg==reg && chain==signed_word(f->device.index));
    CHECK(chip==f->chip.cache_index && *output==0);++f->reads;
    /* Both untouched and deliberately poisoned failure outputs are discarded.
     * A zero-status callback may leave its pre-zeroed output untouched. */
    if(!f->status[e.id] && f->output_mode!=1)*output=f->read_value[e.id];
    else if(f->status[e.id] && f->output_mode==2)*output=UINT32_C(0xdeadc0de);
    mutate(f,READ);return f->status[e.id];
}
static int32_t write_record(void *opaque,struct vn135_bm1368_frequency_device *device,
    uint32_t mode,const vn135_chip_reference *chip,uint32_t reg,uint32_t value)
{
    struct fixture *f=owner(opaque,WRITE);struct event e=next(f,WRITE);
    CHECK(device==&f->device && chip==&f->chip && mode==0);
    CHECK(reg==e.reg && value==e.value);++f->writes;
    mutate(f,WRITE);return f->status[e.id];
}
static int32_t wait_record(void *opaque,uint32_t ms)
{
    struct fixture *f=owner(opaque,WAIT);struct event e=next(f,WAIT);
    CHECK(e.id==f->waits && e.value==ms);++f->waits;
    mutate(f,WAIT);return f->wait_status;
}
static void log_record(void *opaque,const struct vn135_bm1368_reset_diagnostic_135 *d)
{
    struct fixture *f=owner(opaque,LOG);struct event e=next(f,LOG);
    const char *format;
    switch(e.id) {
        case 844:case 821:format="Failed to read cached misc contol register";break;
        case 816:format="Failed to read cached soft reset register";break;
        case 444:format="chain#%d - failed to set SWEEP_CLOCK_CTRL";break;
        case 387:format="chain#%d - failed to send core command";break;
        case 538:format="chain#%d - failed to set CLOCK_DELAY_CTRL";break;
        default:CHECK(0);return;
    }
    CHECK(strcmp(d->module,"driver")==0);
    CHECK(strcmp(d->source,"/tmp/build/libbitmain/src/chip/chip1368.c")==0);
    CHECK(strcmp(d->function,"[redacted]")==0 && strcmp(d->format,format)==0);
    CHECK(d->line==e.id && d->severity==1);
    CHECK(d->has_index==(unsigned)(e.id<800));
    CHECK(d->index_bits==(e.id<800?f->device.index+1u:0));
    ++f->logs;mutate(f,LOG);
}
static void run_case(struct fixture *f)
{
    ++cases;f->device.index=UINT32_MAX;f->chip=(vn135_chip_reference){INT32_MIN,0x123};
    for(unsigned i=0;i<4;++i)f->contexts[i]=(struct context){f,i};
    if(f->output_mode==1)memset(f->read_value,0,sizeof f->read_value);
    transcript(f);
    const struct vn135_bm1368_reset_ops_135 ops={read_record,&f->contexts[READ],
        write_record,&f->contexts[WRITE],wait_record,&f->contexts[WAIT],
        log_record,&f->contexts[LOG]};
    CHECK(vn135_bm1368_reset_cores_135(&f->device,&f->chip,f->fast,f->unused,
        f->clock,f->pulse,&ops)==0);
    CHECK(f->cursor==f->count && f->waits==5);
}
static void init(struct fixture *f)
{
    memset(f,0,sizeof *f);
    f->read_value[R1]=UINT32_C(0xabcdef37);f->read_value[R2]=UINT32_C(0x12345678);
    f->read_value[R3]=UINT32_C(0x89abcdef);f->read_value[R4]=UINT32_C(0x76543210);
    f->clock=UINT32_C(0xa5a5a5a5);f->pulse=UINT32_C(0x5a5a5a5a);
    f->unused=UINT32_C(0xbad0cafe);
}
static void exhaustive_statuses(void)
{
    unsigned reachable=0;
    /* 3^11 tuples before canonicalizing uncalled sites. Every reachable
     * read/write site independently has zero, positive and negative status. */
    for(unsigned tuple=0;tuple<177147u;++tuple) {
        struct fixture base;init(&base);unsigned t=tuple;
        for(unsigned s=0;s<STATUS_COUNT;++s) {
            unsigned digit=t%3u;t/=3u;
            base.status[s]=digit==0?0:digit==1?INT32_MIN:INT32_MAX;
        }
        if((base.status[R1] && base.status[W1]) ||
           (base.status[R2] && (base.status[R3]||base.status[W2]||base.status[W3])) ||
           (base.status[R3] && (base.status[W2]||base.status[W3])) ||
           (base.status[W2] && base.status[W3]) ||
           (base.status[R4] && base.status[W4]))continue;
        ++reachable;
        for(unsigned output=0;output<3;++output)for(unsigned mutation=0;mutation<6;++mutation) {
            struct fixture f=base;f.output_mode=output;f.mutate=mutation;
            f.fast=mutation%2u?UINT32_C(0x80000000):0;
            f.wait_status=output==0?0:output==1?INT32_MIN:INT32_MAX;
            run_case(&f);
        }
    }
    CHECK(reachable==6075);
}
static void full_word_inputs(void)
{
    static const uint32_t words[]={0,1,2,3,7,8,255,256,INT32_MAX,
        UINT32_C(0x80000000),UINT32_C(0xfffffffe),UINT32_MAX};
    for(unsigned a=0;a<12;++a)for(unsigned b=0;b<12;++b)
    for(unsigned c=0;c<12;++c)for(unsigned d=0;d<12;++d) {
        struct fixture f;init(&f);f.fast=words[a];f.unused=words[b];
        f.clock=words[c];f.pulse=words[d];run_case(&f);
    }
    /* Every individual high bit is shown irrelevant to clock/pulse packing;
     * all individual nonzero fast bits choose the short wait. */
    for(unsigned bit=0;bit<32;++bit)for(unsigned low=0;low<32;++low) {
        struct fixture f;init(&f);uint32_t one=UINT32_C(1)<<bit;
        f.fast=one;f.clock=one|low;f.pulse=one|low;f.unused=one;
        f.read_value[R1]=one;f.read_value[R2]=~one;
        f.read_value[R3]=one;f.read_value[R4]=~one;run_case(&f);
    }
}
int main(void)
{
    exhaustive_statuses();full_word_inputs();
    printf("ORIGINAL_RESET_PASS cases=%lu checks=%lu reachable_status_tuples=6075 hardware=no\n",cases,checks);
    return 0;
}
