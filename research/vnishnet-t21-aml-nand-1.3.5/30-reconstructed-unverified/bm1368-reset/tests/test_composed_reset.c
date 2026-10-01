/* Offline composition of the original reset entry with the EXISTING cache,
 * register writer, encoder/CRC, dispatcher, AML framing and legacy UART.
 * All terminal callbacks only record/copy; no OS I/O, allocations, real locks,
 * waits, firmware execution, fault injection or retained temporary pointers. */
#include "integration/bm1368_reset_135.h"
#include "integration/bm1368_register_write_135.h"
#include "integration/bm1368_control.h"
#include "integration/transport_dispatch_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long cases,checks;
#define CHECK(x) do { ++checks; if(!(x)) { \
    fprintf(stderr,"COMPOSED_RESET_FAIL case=%lu line=%d %s\n",cases,__LINE__,#x); \
    exit(1); } } while(0)
#define BIT(n) (1u<<(n))
enum { READ,WRITE,WAIT,LOG };
struct event { unsigned kind,id;uint32_t reg,value; };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    vn135_reg_cache cache;
    vn135_reg_chain chains[2];
    vn135_reg_table chips[2][2],before_chips[2][2],before_common[2];
    struct vn135_bm1368_register_ops register_ops;
    struct vn135_transport_dispatch_135 dispatch;
    struct vn135_aml_uart_binding_135 binding;
    vn135_aml_transport framing;
    vn135_uart_ops uart_ops;
    vn135_uart uart;
    struct event events[32];
    unsigned count,cursor,current,read_fail,send_fail,cache_fail,eagain,custom;
    unsigned reads,writes,waits,reset_logs,register_logs,sends,cache_calls;
    unsigned allocated,outer_locked,inner_locked,allocations,releases;
    unsigned outer_locks,outer_unlocks,inner_locks,inner_unlocks,attempts,errors,sleeps;
    unsigned current_attempts,current_cache_calls,current_errors,current_sleeps;
    int32_t failure,error;
    uint32_t fast,clock,pulse,expected_misc,expected_soft,expected_core,current_reg,current_value;
    uint8_t guard0,storage[11],guard1,expected_frame[11],copied[7][11];
    unsigned wrote[7];
};
static int32_t signed_word(uint32_t value)
{return value<=INT32_MAX?(int32_t)value:(int32_t)((int64_t)value-INT64_C(4294967296));}
static void append(struct fixture *f,unsigned kind,unsigned id,uint32_t reg,uint32_t value)
{CHECK(f->count<32);f->events[f->count++]=(struct event){kind,id,reg,value};}
static struct event next(struct fixture *f,unsigned kind)
{CHECK(f->cursor<f->count);struct event e=f->events[f->cursor++];CHECK(e.kind==kind);return e;}
static void position(struct fixture *f,uint32_t chain,int32_t chip,uint32_t wire)
{f->device.index=chain;f->chip.cache_index=chip;f->chip.wire_address=wire;}
static int slot(const vn135_reg_table *table,uint32_t reg)
{for(int i=0;i<VN135_REG_CACHE_SLOTS;++i)if(table->entries[i].address==reg)return i;CHECK(0);return 0;}
static uint32_t value(const vn135_reg_table *table,uint32_t reg)
{return table->entries[slot(table,reg)].value;}
static void expected_value(vn135_reg_table *table,uint32_t reg,uint32_t word)
{table->entries[slot(table,reg)].value=word;}
/* Independent polynomial long division on a 69-bit dividend. This does not
 * invoke the production encoder/CRC or duplicate its feedback recurrence. */
static uint8_t expected_crc(const uint8_t bytes[8])
{
    unsigned char polynomial[69]={0};
    for(unsigned i=0;i<64;++i)
        polynomial[68u-i]=(unsigned char)(((unsigned)bytes[i/8u]>>(7u-i%8u))&1u);
    for(unsigned i=64;i<69;++i)polynomial[i]^=1u;
    for(int bit=68;bit>=5;--bit)if(polynomial[bit]) {
        polynomial[bit]^=1u;polynomial[bit-3]^=1u;polynomial[bit-5]^=1u;
    }
    unsigned result=0;for(unsigned i=0;i<5;++i)result|=(unsigned)polynomial[i]<<i;
    return (uint8_t)result;
}
static void frame(uint8_t out[11],uint32_t wire,uint32_t reg,uint32_t word)
{
    out[0]=0x55;out[1]=0xaa;out[2]=0x41;out[3]=9;
    out[4]=(uint8_t)wire;out[5]=(uint8_t)reg;
    out[6]=(uint8_t)(word>>24);out[7]=(uint8_t)(word>>16);
    out[8]=(uint8_t)(word>>8);out[9]=(uint8_t)word;out[10]=expected_crc(out+2);
}
static void *allocate_frame(void *opaque,size_t n)
{
    struct fixture *f=opaque;CHECK(n==11 && !f->allocated && !f->outer_locked && !f->inner_locked);
    f->allocated=1;++f->allocations;return f->storage;
}
static void release_frame(void *opaque,void *pointer)
{
    struct fixture *f=opaque;CHECK(pointer==f->storage && f->allocated && !f->outer_locked && !f->inner_locked);
    CHECK(f->current_attempts>0);f->allocated=0;++f->releases;
}
static void outer_lock(void *opaque)
{struct fixture *f=opaque;CHECK(f->allocated && !f->outer_locked && !f->inner_locked);f->outer_locked=1;++f->outer_locks;}
static void outer_unlock(void *opaque)
{struct fixture *f=opaque;CHECK(f->outer_locked && !f->inner_locked);f->outer_locked=0;++f->outer_unlocks;}
static void inner_lock(void *opaque)
{struct fixture *f=opaque;CHECK(f->outer_locked && !f->inner_locked);f->inner_locked=1;++f->inner_locks;}
static void inner_unlock(void *opaque)
{struct fixture *f=opaque;CHECK(f->outer_locked && f->inner_locked);f->inner_locked=0;++f->inner_unlocks;}
static int32_t record_write(void *opaque,int32_t fd,const uint8_t *bytes,uint32_t n)
{
    struct fixture *f=opaque;CHECK(fd==-71 && n==11 && f->outer_locked && f->inner_locked);
    CHECK(bytes==f->storage && memcmp(bytes,f->expected_frame,11)==0);
    memcpy(f->copied[f->current],bytes,11);++f->current_attempts;++f->attempts;
    if(f->custom && f->current==0)position(f,0,1,0x167);
    return f->send_fail&BIT(f->current)?f->failure:11;
}
static int32_t *error_number(void *opaque)
{
    struct fixture *f=opaque;CHECK(f->outer_locked && !f->inner_locked);
    ++f->errors;++f->current_errors;return &f->error;
}
static void record_uart_sleep(void *opaque,uint32_t ms)
{
    struct fixture *f=opaque;CHECK(f->outer_locked && !f->inner_locked && ms==20);
    ++f->sleeps;++f->current_sleeps;
}
static int32_t forbidden_frame_write(void *opaque,void *uart,const uint8_t *bytes,uint32_t n)
{(void)opaque;(void)uart;(void)bytes;(void)n;CHECK(0);return -1;}
static int32_t selected_send(void *opaque,void *device,const uint8_t *bytes,uint32_t n)
{
    struct fixture *f=opaque;CHECK(device==&f->device && n==9);
    CHECK(!f->allocated && memcmp(bytes,f->expected_frame+2,9)==0);++f->sends;
    return vn135_aml_uart_send_135(&f->binding,device,bytes,n);
}
static int32_t register_send(void *opaque,struct vn135_bm1368_frequency_device *device,
    const uint8_t *bytes,size_t n)
{
    struct fixture *f=opaque;CHECK(device==&f->device && n==9);
    return vn135_transport_send_135(&f->dispatch,device,bytes,(uint32_t)n);
}
static int32_t cache_chain(void *opaque,int32_t chain,uint32_t reg,uint32_t word)
{(void)opaque;(void)chain;(void)reg;(void)word;CHECK(0);return -1;}
static int32_t cache_chip(void *opaque,int32_t chain,int32_t chip,uint32_t reg,uint32_t word)
{
    struct fixture *f=opaque;CHECK(!f->allocated && !f->outer_locked && !f->inner_locked);
    CHECK(chain==signed_word(f->device.index) && chip==f->chip.cache_index);
    CHECK(reg==f->current_reg && word==f->current_value);
    ++f->cache_calls;++f->current_cache_calls;
    /* Supported cache-disabled admission failure, with all owned arrays valid.
     * This exercises the real setter, never a successful cache stub. */
    if(f->cache_fail&BIT(f->current))f->cache.initialized=0;
    int32_t result=vn135_bm1368_register_cache_chip_135(&f->cache,chain,chip,reg,word);
    f->cache.initialized=1;
    CHECK(result==((f->cache_fail&BIT(f->current))?-1:0));
    if(f->custom && f->current==0)position(f,1,0,0x189);
    if(f->custom && f->current==1) {
        /* Change both the R3 source and the upcoming W3 destination while W2
         * is running. W3 must still use the value already saved by R3. */
        CHECK(vn135_reg_cache_set_chip(&f->cache,0,0,0x18,UINT32_C(0xdecafbad))==0);
        CHECK(vn135_reg_cache_set_chip(&f->cache,0,1,0x18,UINT32_C(0xcafef00d))==0);
        position(f,0,1,0x1ef);
    }
    return result;
}
static void register_log(void *opaque,uint32_t line,uint32_t index)
{
    struct fixture *f=opaque;CHECK(line==350 && index==f->device.index+1u);
    CHECK((f->send_fail&BIT(f->current)) && !f->allocated && !f->outer_locked && !f->inner_locked);
    ++f->register_logs;
    if(f->custom && f->current==4)position(f,UINT32_MAX,0,0x155);
    if(f->custom && f->current==5)position(f,INT32_MAX,1,0x199);
}
static int32_t read_cached(void *opaque,int32_t chain,int32_t chip,uint32_t reg,uint32_t *out)
{
    struct fixture *f=opaque;struct event e=next(f,READ);++f->reads;
    CHECK(chain==signed_word(f->device.index) && chip==f->chip.cache_index && reg==e.reg && *out==0);
    if(f->read_fail&BIT(e.id))f->cache.initialized=0;
    int32_t result=vn135_reg_cache_get_chip(&f->cache,chain,chip,reg,out);
    f->cache.initialized=1;
    CHECK(result==((f->read_fail&BIT(e.id))?-1:0));
    CHECK(*out==(result?0:e.value));
    if(f->custom) {
        static const uint32_t chains[]={1,0,1,1},wire[]={0x145,0x1ab,0x1cd,0x133};
        static const int32_t chips[]={1,0,1,1};position(f,chains[e.id],chips[e.id],wire[e.id]);
    }
    return result;
}
static int32_t write_register(void *opaque,struct vn135_bm1368_frequency_device *device,
    uint32_t mode,const vn135_chip_reference *chip,uint32_t reg,uint32_t word)
{
    struct fixture *f=opaque;struct event e=next(f,WRITE);
    CHECK(device==&f->device && chip==&f->chip && mode==0 && reg==e.reg && word==e.value);
    f->current=e.id;f->current_reg=e.reg;f->current_value=e.value;CHECK(f->wrote[e.id]==0);f->wrote[e.id]=1;++f->writes;
    static const uint32_t custom_wire[]={0x145,0x1cd,0x1ef,0x133,0x133,0x199,0x1dd};
    frame(f->expected_frame,f->custom?custom_wire[e.id]:0x123,reg,e.value);
    f->current_attempts=f->current_cache_calls=f->current_errors=f->current_sleeps=0;
    unsigned logs_before=f->register_logs;
    int32_t result=vn135_bm1368_write_register_135(device,mode,chip,reg,word,&f->register_ops,f);
    unsigned send_failure=(unsigned)((f->send_fail&BIT(e.id))!=0);
    unsigned expected_attempts=send_failure && f->eagain?5u:1u;
    CHECK(result==(((f->send_fail|f->cache_fail)&BIT(e.id))?-1:0));
    CHECK(f->current_attempts==expected_attempts && f->current_cache_calls==1u-send_failure);
    CHECK(f->register_logs-logs_before==send_failure);
    CHECK(f->current_errors==send_failure && f->current_sleeps==(f->eagain?expected_attempts*send_failure:0));
    CHECK(!f->allocated && !f->outer_locked && !f->inner_locked);
    CHECK(memcmp(f->copied[e.id],f->expected_frame,11)==0);
    return result;
}
static int32_t reset_wait(void *opaque,uint32_t ms)
{
    struct fixture *f=opaque;struct event e=next(f,WAIT);CHECK(e.id==f->waits && ms==e.value);++f->waits;
    if(f->custom && e.id<3) {
        static const uint32_t chain[]={1,1,1},wire[]={0x111,0x199,0x1dd};
        static const int32_t chip[]={0,1,0};position(f,chain[e.id],chip[e.id],wire[e.id]);
    }
    return f->failure; /* Deliberately ignored by the original reset. */
}
static void reset_log(void *opaque,const struct vn135_bm1368_reset_diagnostic_135 *d)
{
    struct fixture *f=opaque;struct event e=next(f,LOG);++f->reset_logs;
    CHECK(d->line==e.id && d->severity==1);
    CHECK(d->has_index==(unsigned)(e.id<800));
    CHECK(d->index_bits==(e.id<800?f->device.index+1u:0));
    if(f->custom) {
        if(e.id==444){CHECK(d->index_bits==0);position(f,0,1,0x177);}
        else if(e.id==387 && f->current==5){CHECK(d->index_bits==UINT32_C(0x80000000));position(f,UINT32_MAX,0,0x199);}
        else if(e.id==538){CHECK(d->index_bits==0);position(f,0,0,0x1bb);}
        else if(e.id==387){CHECK(d->index_bits==2);position(f,0,1,0x1ff);}
        else CHECK(0);
    }
}
static void init(struct fixture *f)
{
    memset(f,0,sizeof *f);position(f,0,0,0x123);f->guard0=0xa5;f->guard1=0x5a;
    f->failure=-55;f->error=5;
    f->cache.chains=f->chains;f->cache.chain_count=2;f->cache.initialized=1;
    for(int i=0;i<2;++i) {
        CHECK(vn135_reg_cache_defaults(4,&f->chains[i].common)==0);
        f->chains[i].chips=f->chips[i];f->chains[i].chip_count=2;
        for(int j=0;j<2;++j) {
            f->chips[i][j]=f->chains[i].common;
            CHECK(vn135_reg_cache_set_chip(&f->cache,i,j,0x18,
                UINT32_C(0x12345778)+(uint32_t)i*UINT32_C(0x11110000)+(uint32_t)j*UINT32_C(0x101))==0);
            CHECK(vn135_reg_cache_set_chip(&f->cache,i,j,0xa8,
                UINT32_C(0x98765432)+(uint32_t)i*UINT32_C(0x111100)+(uint32_t)j*16u)==0);
            CHECK(vn135_reg_cache_set_chip(&f->cache,i,j,0x3c,UINT32_C(0x87654321))==0);
        }
        f->before_common[i]=f->chains[i].common;
    }
    memcpy(f->before_chips,f->chips,sizeof f->chips);
    f->register_ops=(struct vn135_bm1368_register_ops){register_send,cache_chain,cache_chip,register_log};
    f->dispatch=(struct vn135_transport_dispatch_135){selected_send,f};
    f->framing=(vn135_aml_transport){f,allocate_frame,release_frame,outer_lock,outer_unlock,forbidden_frame_write};
    f->uart=(vn135_uart)VN135_UART_INITIALIZER;f->uart.fd=-71;
    f->uart_ops.context=f;f->uart_ops.write=record_write;f->uart_ops.lock=inner_lock;
    f->uart_ops.unlock=inner_unlock;f->uart_ops.error_number=error_number;f->uart_ops.sleep_ms=record_uart_sleep;
    f->binding=(struct vn135_aml_uart_binding_135){&f->device,&f->uart,&f->framing,&f->uart_ops};
}
/* Closed-form expectations for one fixed cache location. Test values/guards
 * come from the original branch table, not from results of the candidate. */
static void plan(struct fixture *f)
{
    unsigned failed=f->send_fail|f->cache_fail;
    uint32_t initial=value(&f->before_chips[0][0],0x18);
    uint32_t soft=value(&f->before_chips[0][0],0xa8);
    uint32_t cleared=initial&UINT32_C(0xfffffcff);
    uint32_t after1=(f->read_fail&1u)||(failed&1u)?initial:cleared;
    unsigned middle=(unsigned)((f->read_fail&6u)==0);
    uint32_t transformed=(after1&UINT32_C(0x00f0ffff))|UINT32_C(0xf0000000);
    uint32_t after3=middle && !(failed&6u)?transformed:after1;
    uint32_t d=f->fast?1u:5u,packed=UINT32_C(0x80008000)+(f->pulse%4u)*64u+(f->clock%8u)*8u;
    f->expected_misc=(f->read_fail&8u)||(failed&8u)?after3:after3|UINT32_C(0x300);
    f->expected_soft=middle && !(failed&2u)?soft|UINT32_C(0x1f0):soft;
    f->expected_core=!(failed&64u)?UINT32_C(0x800082aa):!(failed&32u)?packed:
        !(failed&16u)?UINT32_C(0x80008b00):UINT32_C(0x87654321);
    append(f,READ,0,0x18,initial);
    if(f->read_fail&1u)append(f,LOG,844,0,0);else append(f,WRITE,0,0x18,cleared);
    append(f,READ,1,0xa8,soft);
    if(f->read_fail&2u)append(f,LOG,816,0,0);
    else {
        append(f,READ,2,0x18,after1);
        if(f->read_fail&4u)append(f,LOG,821,0,0);
        else {append(f,WRITE,1,0xa8,soft|UINT32_C(0x1f0));
            if(!(failed&2u))append(f,WRITE,2,0x18,transformed);}
    }
    append(f,WAIT,0,0,d);append(f,READ,3,0x18,after3);
    if(f->read_fail&8u)append(f,LOG,844,0,0);else append(f,WRITE,3,0x18,after3|UINT32_C(0x300));
    append(f,WRITE,4,0x3c,UINT32_C(0x80008b00));if(failed&16u)append(f,LOG,444,0,0);
    append(f,WAIT,1,0,d);append(f,WRITE,5,0x3c,packed);
    if(failed&32u){append(f,LOG,387,0,0);append(f,LOG,538,0,0);}
    append(f,WAIT,2,0,d);append(f,WRITE,6,0x3c,UINT32_C(0x800082aa));
    if(failed&64u)append(f,LOG,387,0,0);
    append(f,WAIT,3,0,d);append(f,WAIT,4,0,10);
}
static void custom_plan(struct fixture *f)
{
    f->custom=1;f->fast=UINT32_MAX;f->clock=UINT32_MAX;f->pulse=UINT32_MAX;
    f->send_fail=BIT(4)|BIT(5)|BIT(6);
    uint32_t a=value(&f->before_chips[0][0],0x18),b=value(&f->before_chips[1][0],0x18);
    uint32_t soft=value(&f->before_chips[1][0],0xa8);
    uint32_t transformed=(a&UINT32_C(0x00f0ffff))|UINT32_C(0xf0000000);
    append(f,READ,0,0x18,a);append(f,WRITE,0,0x18,a&UINT32_C(0xfffffcff));
    append(f,READ,1,0xa8,soft);append(f,READ,2,0x18,a);
    append(f,WRITE,1,0xa8,soft|UINT32_C(0x1f0));append(f,WRITE,2,0x18,transformed);
    append(f,WAIT,0,0,1);append(f,READ,3,0x18,b);append(f,WRITE,3,0x18,b|UINT32_C(0x300));
    append(f,WRITE,4,0x3c,UINT32_C(0x80008b00));append(f,LOG,444,0,0);
    append(f,WAIT,1,0,1);append(f,WRITE,5,0x3c,UINT32_C(0x800080f8));
    append(f,LOG,387,0,0);append(f,LOG,538,0,0);append(f,WAIT,2,0,1);
    append(f,WRITE,6,0x3c,UINT32_C(0x800082aa));append(f,LOG,387,0,0);
    append(f,WAIT,3,0,1);append(f,WAIT,4,0,10);
    expected_value(&f->before_chips[0][0],0x18,UINT32_C(0xdecafbad));
    expected_value(&f->before_chips[0][1],0x18,transformed);
    expected_value(&f->before_chips[1][1],0x18,b|UINT32_C(0x300));
    expected_value(&f->before_chips[1][1],0xa8,soft|UINT32_C(0x1f0));
}
static void run(struct fixture *f)
{
    ++cases;struct vn135_bm1368_reset_ops_135 ops={read_cached,f,write_register,f,reset_wait,f,reset_log,f};
    CHECK(vn135_bm1368_reset_cores_135(&f->device,&f->chip,f->fast,UINT32_C(0xdeadbeef),f->clock,f->pulse,&ops)==0);
    CHECK(f->cursor==f->count && f->waits==5 && f->sends==f->writes);
    CHECK(f->allocations==f->writes && f->releases==f->writes);
    CHECK(f->outer_locks==f->writes && f->outer_unlocks==f->writes);
    CHECK(f->inner_locks==f->attempts && f->inner_unlocks==f->attempts);
    CHECK(f->guard0==0xa5 && f->guard1==0x5a && f->cache.initialized==1);
    CHECK(!f->allocated && !f->outer_locked && !f->inner_locked);
    if(!f->custom) {
        expected_value(&f->before_chips[0][0],0x18,f->expected_misc);
        expected_value(&f->before_chips[0][0],0xa8,f->expected_soft);
        expected_value(&f->before_chips[0][0],0x3c,f->expected_core);
    }
    CHECK(memcmp(f->before_chips,f->chips,sizeof f->chips)==0);
    for(unsigned i=0;i<2;++i) {
        CHECK(memcmp(&f->before_common[i],&f->chains[i].common,sizeof f->before_common[i])==0);
        CHECK(f->chains[i].chips==f->chips[i] && f->chains[i].chip_count==2);
    }
    CHECK(f->cache.chains==f->chains && f->cache.chain_count==2);
}
struct failfast { unsigned calls,fail;int status; };
static int failfast_read(void *opaque,uint8_t reg,uint32_t *out)
{struct failfast *f=opaque;(void)reg;*out=0;return ++f->calls==f->fail?f->status:0;}
static int failfast_write(void *opaque,uint8_t reg,uint32_t word)
{struct failfast *f=opaque;(void)reg;(void)word;return ++f->calls==f->fail?f->status:0;}
static int failfast_wait(void *opaque,uint32_t ms)
{struct failfast *f=opaque;(void)ms;return ++f->calls==f->fail?f->status:0;}
static void preserve_failfast(void)
{
    for(unsigned sign=0;sign<2;++sign)for(unsigned failure=0;failure<=16;++failure) {
        struct failfast f={0,failure,sign?73:-73};
        struct dizzass_bm1368_reset_ops ops={&f,failfast_read,failfast_write,failfast_wait};
        struct dizzass_bm1368_reset_result result={99,99,99};++cases;
        CHECK(dizzass_bm1368_reset_cores(&ops,1,7,3,&result)==(failure?DIZZASS_CONTROL_CALLBACK:0));
        CHECK(f.calls==(failure?failure:16));CHECK(result.completed==(failure?failure-1:16));
        CHECK(result.failed_step==failure && result.callback_status==(failure?f.status:0));
    }
    struct failfast f={0,0,0};struct dizzass_bm1368_reset_ops ops={&f,failfast_read,failfast_write,failfast_wait};
    struct dizzass_bm1368_reset_result result={99,99,99};++cases;
    CHECK(dizzass_bm1368_reset_cores(&ops,2,0,0,&result)==DIZZASS_CONTROL_INVALID);
    CHECK(dizzass_bm1368_reset_cores(&ops,0,8,0,&result)==DIZZASS_CONTROL_INVALID);
    CHECK(dizzass_bm1368_reset_cores(&ops,0,0,4,&result)==DIZZASS_CONTROL_INVALID);
    CHECK(f.calls==0 && result.completed==99 && result.failed_step==99 && result.callback_status==99);
}
int main(void)
{
    for(unsigned fast=0;fast<2;++fast)for(unsigned clock=0;clock<8;++clock)for(unsigned pulse=0;pulse<4;++pulse) {
        struct fixture f;init(&f);f.fast=fast;f.clock=clock;f.pulse=pulse;plan(&f);run(&f);
    }
    for(unsigned mask=0;mask<128;++mask)for(unsigned sign=0;sign<2;++sign)for(unsigned again=0;again<2;++again) {
        struct fixture f;init(&f);f.send_fail=mask;f.failure=sign?2:-55;f.eagain=again;
        f.error=again?VN135_UART_EAGAIN:5;f.fast=UINT32_MAX;f.clock=UINT32_MAX;f.pulse=UINT32_MAX;plan(&f);run(&f);
    }
    for(unsigned reads=0;reads<16;++reads)for(unsigned cache=0;cache<128;++cache) {
        struct fixture f;init(&f);f.read_fail=reads;f.cache_fail=cache;f.clock=0x12345678;f.pulse=0x87654321;plan(&f);run(&f);
    }
    for(unsigned sign=0;sign<2;++sign) {
        struct fixture f;init(&f);f.failure=sign?2:-55;custom_plan(&f);run(&f);
    }
    preserve_failfast();
    printf("COMPOSED_RESET_PASS cases=%lu checks=%lu hardware=no allocations=caller-owned real_waits=no\n",cases,checks);
    return 0;
}
