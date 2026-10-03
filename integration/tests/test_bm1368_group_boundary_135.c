/* SPDX-License-Identifier: GPL-3.0-only
 * Host tests of authored source only; all terminal sends are recorded.
 */
#include "integration/bm1368_group_boundary_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"GROUP_BOUNDARY_ASSERT line=%d expression=%s\n",__LINE__,#x); \
    exit(1); } } while (0)

struct writer_fixture {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    int32_t send_status, cache_status;
    unsigned sends, caches, lower_logs, upper_logs;
    int mutate;
    uint32_t expected_setting;
    struct vn135_bm1368_relay_diagnostic_135 diagnostic;
    vn135_reg_cache *real_cache;
};
static uint8_t crc_reference(const uint8_t *data)
{
    unsigned crc = 31;
    for (unsigned i=0; i<64; ++i) {
        unsigned bit=((unsigned)data[i/8] >> (7-i%8)) & 1u;
        unsigned feedback=((crc>>4) & 1u)^bit;
        crc=(crc<<1)&31u;
        if (feedback) crc^=5u;
    }
    return (uint8_t)crc;
}
static int32_t send_record(void *opaque,
    struct vn135_bm1368_frequency_device *device, const uint8_t *p, size_t n)
{
    struct writer_fixture *f=opaque;
    CHECK(device==&f->device); CHECK(n==9); ++f->sends;
    CHECK(p[0]==0x41); CHECK(p[1]==9); CHECK(p[2]==(f->chip.wire_address&255u));
    CHECK(p[3]==0x2c);
    uint32_t word=((uint32_t)p[4]<<24)|((uint32_t)p[5]<<16)|
        ((uint32_t)p[6]<<8)|p[7];
    uint32_t expected=3;
    /* Independent bit placement: no copy of the implementation shift expression. */
    for (unsigned bit=0;bit<16;++bit)
        if ((f->expected_setting & (UINT32_C(1)<<bit))!=0)
            expected|=UINT32_C(1)<<(bit+16);
    CHECK(word==expected); CHECK(p[8]==crc_reference(p));
    if (f->mutate) { device->index=11; f->chip.cache_index=13;
        f->chip.wire_address=0x98765432; }
    return f->send_status;
}
static int32_t cache_chain_forbidden(void *opaque,int32_t c,uint32_t r,uint32_t v)
{ (void)opaque;(void)c;(void)r;(void)v; CHECK(0);return -1; }
static int32_t cache_chip_record(void *opaque,int32_t chain,int32_t chip,
    uint32_t reg,uint32_t value)
{
    struct writer_fixture *f=opaque; ++f->caches;
    CHECK(chain==(int32_t)f->device.index); CHECK(chip==f->chip.cache_index);
    CHECK(reg==0x2c); CHECK(value==(3u|((f->expected_setting&65535u)*65536u)));
    int32_t rc=f->cache_status;
    if (f->real_cache) rc=vn135_reg_cache_set_chip(f->real_cache,chain,chip,reg,value);
    if (f->mutate) { f->device.index=29; f->chip.cache_index=31; }
    return rc;
}
static void writer_log(void *opaque,uint32_t line,uint32_t index)
{
    struct writer_fixture *f=opaque; ++f->lower_logs;
    CHECK(line==350); CHECK(index==f->device.index+1u);
    if (f->mutate) { f->device.index=41; f->chip.cache_index=43; }
}
static void relay_log(void *opaque,const struct vn135_bm1368_relay_diagnostic_135 *d)
{
    struct writer_fixture *f=opaque; ++f->upper_logs; f->diagnostic=*d;
    CHECK(d->line==721); CHECK(d->severity==1);
    CHECK(d->chain_index==f->device.index+1u);
    CHECK(d->chip_index==(uint32_t)f->chip.cache_index+1u);
    CHECK(strcmp(d->component,"driver")==0);
    CHECK(strcmp(d->source,"/tmp/build/libbitmain/src/chip/chip1368.c")==0);
    CHECK(strcmp(d->function,"[redacted]")==0);
    CHECK(strcmp(d->format,"chain#%d chip#%d - failed to config UART relay")==0);
}
static const struct vn135_bm1368_register_ops writer={
    send_record,cache_chain_forbidden,cache_chip_record,writer_log
};
static void method_case(uint32_t setting,int32_t send,int32_t cache,int mutate)
{
    struct writer_fixture f={0}; f.device.index=7; f.chip.cache_index=-3;
    f.chip.wire_address=0xabcdef12; f.expected_setting=setting;
    f.send_status=send;f.cache_status=cache;f.mutate=mutate;
    const struct vn135_bm1368_relay_log_135 log={&f,relay_log};
    int32_t rc=vn135_bm1368_set_uart_relay_135(&f.device,&f.chip,setting,&writer,&f,&log);
    CHECK(rc==((send==0&&cache==0)?0:-1)); CHECK(f.sends==1);
    CHECK(f.caches==(send==0?1u:0u));CHECK(f.lower_logs==(send!=0?1u:0u));
    CHECK(f.upper_logs==((send==0&&cache==0)?0u:1u));++cases;
}

struct call_record { int32_t index; uint32_t address, setting; unsigned method; };
struct group_fixture {
    struct vn135_bm1368_boundary_board_135 board, decoy_board;
    struct vn135_bm1368_boundary_owner_135 owner, decoy_owner;
    struct vn135_bm1368_frequency_device device;
    struct vn135_bm1368_boundary_chain_135 chain;
    struct vn135_bm1368_boundary_selector_135 selector;
    struct call_record calls[128];
    vn135_chip_reference *first_pointer,*last_pointer;
    unsigned used,selector_calls,fail_at;
    int32_t failure;
    uint32_t selected;
    int selector_mutation,callback_mutation,clear_last;
};
static int32_t method_b(void *,struct vn135_bm1368_frequency_device *,
    vn135_chip_reference *,uint32_t);
static int32_t group_call(struct group_fixture *f,
    struct vn135_bm1368_frequency_device *device,vn135_chip_reference *chip,
    uint32_t setting,unsigned method)
{
    CHECK(device==&f->device);CHECK(f->used<128);
    unsigned number=f->used++;
    if (f->clear_last && number==0) f->board.configure_last=0;
    f->calls[number]=(struct call_record){chip->cache_index,chip->wire_address,setting,method};
    if (f->callback_mutation) {
        if (number==0) {
            f->first_pointer=chip;
            f->chain.owner=&f->decoy_owner;f->owner.board=&f->decoy_board;
            f->board.enabled=0;f->board.group_count=14;
            f->board.chips_per_group=3;f->board.address_stride=7;
            f->board.group_step=6;f->owner.configure=method_b;
            chip->cache_index=-17;chip->wire_address=0xffffffff;
        } else if (number==1) {
            f->last_pointer=chip;CHECK(chip!=f->first_pointer);
            f->board.configure_first=0;f->board.chips_per_group=4;
            f->board.address_stride=9;f->board.group_step=4;
            chip->cache_index=93;chip->wire_address=95;
        } else if (number==2) {
            CHECK(chip==f->last_pointer);f->board.group_step=9;
        }
    }
    if (f->fail_at!=0&&f->used==f->fail_at)return f->failure;
    return 0;
}
static int32_t method_a(void *p,struct vn135_bm1368_frequency_device *d,
    vn135_chip_reference *c,uint32_t s){return group_call(p,d,c,s,1);}
static int32_t method_b(void *p,struct vn135_bm1368_frequency_device *d,
    vn135_chip_reference *c,uint32_t s){return group_call(p,d,c,s,2);}
static uint32_t select_record(void *opaque)
{
    struct group_fixture *f=opaque;++f->selector_calls;
    if(f->selector_mutation){
        f->chain.owner=&f->decoy_owner;f->owner.board=&f->decoy_board;
        f->board.enabled=0;f->board.group_count=12;f->board.group_step=5;
    }
    return f->selected;
}
static void setup_group(struct group_fixture *f)
{
    memset(f,0,sizeof *f);
    f->board=(struct vn135_bm1368_boundary_board_135){2,2,12,5,1,1,1,1};
    f->owner=(struct vn135_bm1368_boundary_owner_135){&f->board,method_a,f};
    f->chain=(struct vn135_bm1368_boundary_chain_135){&f->owner,&f->device};
    f->selector=(struct vn135_bm1368_boundary_selector_135){f,select_record};
    f->decoy_owner.board=&f->decoy_board;f->selected=2;f->failure=-37;
}
static void expect_call(struct group_fixture *f,unsigned at,int32_t idx,
    uint32_t address,uint32_t setting,unsigned method)
{
    CHECK(at<f->used);const struct call_record *r=&f->calls[at];
    CHECK(r->index==idx);CHECK(r->address==address);CHECK(r->setting==setting);
    CHECK(r->method==method);
}
static void group_tests(void)
{
    struct group_fixture f;
    /* Reachable selector/sign mistakes must fail assertions, not NULL calls
       or very long no-effect loops in the separately compiled controls. */
    setup_group(&f);f.selected=4;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==0 && f.selector_calls==1);++cases;
    setup_group(&f);f.board.group_count=0x80000000;f.board.group_step=1;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==0 && f.selector_calls==1);++cases;
    const uint32_t counts[]={0,1,9,10,12,16,0x80000000,0xffffffff};
    const uint32_t steps[]={1,3,5,10,13,17,0x80000001};
    for(size_t a=0;a<sizeof counts/sizeof *counts;++a)
    for(size_t b=0;b<sizeof steps/sizeof *steps;++b)
    for(unsigned flags=0;flags<8;++flags){
        setup_group(&f);f.board.group_count=counts[a];f.board.group_step=steps[b];
        f.board.configure_first=(uint8_t)(flags&1);f.board.configure_last=(uint8_t)(flags&2);
        f.board.offset_enabled=(uint8_t)(flags&4);
        CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
        CHECK(f.selector_calls==1);
        unsigned expected=0;
        if(counts[a]>=10&&counts[a]<=INT32_MAX){
            int64_t remaining=(int64_t)counts[a]-(int64_t)steps[b];
            for(;remaining>=0;remaining-=(int64_t)steps[b]){
                uint32_t setting=(flags&4)?(uint32_t)((int64_t)counts[a]-remaining)*2u+14u:0u;
                if(flags&1){expect_call(&f,expected,(int32_t)(remaining*2),
                    (uint32_t)remaining*4u,setting,1);++expected;}
                if(flags&2){expect_call(&f,expected,(int32_t)(remaining*2+1),
                    (uint32_t)remaining*4u+2u,setting,1);++expected;}
            }
        }
        CHECK(f.used==expected);++cases;
    }
    setup_group(&f);f.board.enabled=0;f.selector.get=NULL;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==0&&f.selector_calls==0);++cases;
    setup_group(&f);f.selected=4;f.owner.configure=NULL;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==0&&f.selector_calls==1);++cases;
    setup_group(&f);f.selected=UINT32_MAX;f.board.enabled=128;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==4);++cases;
    for(unsigned at=1;at<=4;++at)for(unsigned sign=0;sign<2;++sign){
        setup_group(&f);f.fail_at=at;f.failure=sign?INT32_MAX:INT32_MIN;
        CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==-1);
        CHECK(f.used==at);++cases;
    }
    setup_group(&f);f.callback_mutation=1;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==3);expect_call(&f,0,14,28,24,1);
    expect_call(&f,1,23,161,24,2);expect_call(&f,2,15,135,58,2);++cases;
    setup_group(&f);f.board.group_count=9;f.selector_mutation=1;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==4);expect_call(&f,0,14,28,24,1);++cases;
    setup_group(&f);f.clear_last=1;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==2);expect_call(&f,0,14,28,24,1);
    expect_call(&f,1,4,8,34,1);++cases;
    setup_group(&f);f.board.configure_first=0;f.board.configure_last=0;
    f.owner.configure=NULL;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==0);
    CHECK(f.used==0);++cases;
    /* A zero step is NOT tested by hanging: fail the fourth repeated call. */
    setup_group(&f);f.board.group_count=10;f.board.group_step=0;
    f.board.configure_last=0;f.fail_at=4;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==-1);
    CHECK(f.used==4);for(unsigned i=0;i<4;++i)expect_call(&f,i,20,40,14,1);++cases;
    /* Exact wrapped subtraction is retained, not signed overflow/validation. */
    setup_group(&f);f.board.group_count=10;f.board.group_step=UINT32_MAX;f.fail_at=1;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==-1);
    expect_call(&f,0,22,44,12,1);++cases;
    setup_group(&f);f.board.chips_per_group=0x80000001;f.board.address_stride=0xffffffff;
    f.fail_at=2;
    CHECK(vn135_bm1368_configure_group_boundaries_135(&f.chain,&f.selector)==-1);
    expect_call(&f,0,INT32_MIN+7,0x7ffffff9,0x80000013,1);
    expect_call(&f,1,7,0xfffffff9,0x80000013,1);++cases;
}
static void *alloc_zero(void *p,size_t size,size_t n){(void)p;return calloc(n,size);}
static void release_mem(void *p,void *m){(void)p;free(m);}
static void composition_tests(void)
{
    /* Direct bridge -> method -> writer -> encoder/CRC -> real cache.
       The terminal send only records bytes, so nothing reaches a UART. */
    struct writer_fixture f={0};vn135_reg_cache cache={0};
    const vn135_reg_allocator a={NULL,alloc_zero,release_mem};
    CHECK(vn135_reg_cache_init(&cache,4,1,40,&a)==0);f.real_cache=&cache;
    const struct vn135_bm1368_relay_log_135 log={&f,relay_log};
    const struct vn135_bm1368_boundary_binding_135 bind={&writer,&f,&log};
    /* Direct bridge preserves the chip/device identities. */
    f.chip=(vn135_chip_reference){3,0x106};f.expected_setting=0x12345678;
    CHECK(vn135_bm1368_boundary_uart_relay_135((void*)&bind,&f.device,&f.chip,
        f.expected_setting)==0);
    uint32_t stored=0;CHECK(vn135_reg_cache_get_chip(&cache,0,3,0x2c,&stored)==0);
    CHECK(stored==0x56780003);CHECK(f.sends==1&&f.caches==1&&f.upper_logs==0);
    ++cases;
    /* Cache rejection follows a recorded send, not a transaction rollback. */
    f.chip.cache_index=50;
    CHECK(vn135_bm1368_boundary_uart_relay_135((void*)&bind,&f.device,&f.chip,
        f.expected_setting)==-1);
    CHECK(f.sends==2&&f.caches==2&&f.upper_logs==1);++cases;
    vn135_reg_cache_destroy(&cache);CHECK(cache.chains==NULL);
    f.real_cache=NULL;f.device.index=UINT32_MAX;f.chip.cache_index=-1;
    f.send_status=INT32_MAX;f.sends=f.caches=f.lower_logs=f.upper_logs=0;
    CHECK(vn135_bm1368_boundary_uart_relay_135((void*)&bind,&f.device,&f.chip,
        f.expected_setting)==-1);
    CHECK(f.diagnostic.chain_index==0 && f.diagnostic.chip_index==0);
    CHECK(f.sends==1 && f.caches==0 && f.lower_logs==1 && f.upper_logs==1);++cases;
}

struct composed_fixture {
    vn135_reg_cache cache;
    struct vn135_bm1368_frequency_device device;
    unsigned sends,caches,lower_logs,upper_logs,fail_send;
    int32_t failure;
};
static const uint32_t composed_index[4]={14,15,4,5};
static const uint32_t composed_setting[4]={24,24,34,34};
static int32_t composed_send(void *p,struct vn135_bm1368_frequency_device *d,
    const uint8_t *bytes,size_t length)
{
    struct composed_fixture *f=p;unsigned at=f->sends++;
    CHECK(d==&f->device);CHECK(at<4);CHECK(length==9);
    CHECK(bytes[0]==0x41 && bytes[1]==9 && bytes[2]==composed_index[at]*2u);
    CHECK(bytes[3]==0x2c && bytes[4]==0 && bytes[5]==composed_setting[at]);
    CHECK(bytes[6]==0 && bytes[7]==3 && bytes[8]==crc_reference(bytes));
    return f->sends==f->fail_send ? f->failure : 0;
}
static int32_t composed_cache(void *p,int32_t chain,int32_t chip,
    uint32_t reg,uint32_t value)
{
    struct composed_fixture *f=p;unsigned at=f->caches++;
    CHECK(at<4);CHECK(chain==0);CHECK(chip==(int32_t)composed_index[at]);
    CHECK(reg==0x2c);CHECK(value==composed_setting[at]*65536u+3u);
    return vn135_reg_cache_set_chip(&f->cache,chain,chip,reg,value);
}
static void composed_lower_log(void *p,uint32_t line,uint32_t index)
{
    struct composed_fixture *f=p;++f->lower_logs;
    CHECK(line==350 && index==1);
}
static void composed_upper_log(void *p,const struct vn135_bm1368_relay_diagnostic_135 *d)
{
    struct composed_fixture *f=p;++f->upper_logs;
    CHECK(f->sends>=1 && f->sends<=4);
    CHECK(d->chain_index==1 && d->chip_index==composed_index[f->sends-1]+1);
    CHECK(d->line==721 && d->severity==1);
}
static void full_composition_tests(void)
{
    const vn135_reg_allocator alloc={NULL,alloc_zero,release_mem};
    const struct vn135_bm1368_register_ops ops={
        composed_send,cache_chain_forbidden,composed_cache,composed_lower_log};
    for (unsigned mode=0;mode<10;++mode) {
        struct composed_fixture f={0};struct group_fixture group;
        setup_group(&group);
        CHECK(vn135_reg_cache_init(&f.cache,4,1,mode==9?15:40,&alloc)==0);
        if(mode>=1 && mode<=8){f.fail_send=(mode+1)/2;
            f.failure=(mode&1u)?INT32_MIN:INT32_MAX;}
        const struct vn135_bm1368_relay_log_135 log={&f,composed_upper_log};
        const struct vn135_bm1368_boundary_binding_135 bind={&ops,&f,&log};
        group.chain.device=&f.device;group.owner.configure=vn135_bm1368_boundary_uart_relay_135;
        group.owner.context=(void *)&bind;
        int32_t rc=vn135_bm1368_configure_group_boundaries_135(&group.chain,&group.selector);
        CHECK(rc==(mode==0?0:-1));CHECK(group.selector_calls==1);
        unsigned expected_sends=mode==0?4:mode==9?2:f.fail_send;
        unsigned successful=mode==0?4:mode==9?1:f.fail_send-1;
        CHECK(f.sends==expected_sends);
        CHECK(f.caches==(mode==9?2:successful));
        CHECK(f.lower_logs==((mode>=1&&mode<=8)?1u:0u));
        CHECK(f.upper_logs==(mode==0?0u:1u));
        for(unsigned i=0;i<successful;++i){uint32_t stored=0;
            CHECK(vn135_reg_cache_get_chip(&f.cache,0,(int32_t)composed_index[i],0x2c,&stored)==0);
            CHECK(stored==composed_setting[i]*65536u+3u);}
        vn135_reg_cache_destroy(&f.cache);CHECK(f.cache.chains==NULL);++cases;
    }
}
int main(void)
{
    const uint32_t inputs[]={0,1,2,3,0xffff,0x10000,0x10001,0x80000000,0xffffffff,0xabcd1234};
    const int32_t statuses[]={INT32_MIN,-7,0,1,INT32_MAX};
    for(size_t i=0;i<sizeof inputs/sizeof *inputs;++i)
    for(size_t s=0;s<sizeof statuses/sizeof *statuses;++s)
    for(size_t c=0;c<sizeof statuses/sizeof *statuses;++c)
    for(int m=0;m<2;++m)method_case(inputs[i],statuses[s],statuses[c],m);
    /* Exhaust the entire transmitted setting field without a hardware call. */
    for(uint32_t setting=0;setting<65536;++setting)
        method_case(setting|0xa5a50000u,0,0,0);
    group_tests();composition_tests();full_composition_tests();
    printf("GROUP_BOUNDARY_PASS cases=%u checks=%u hardware=no\n",cases,checks);
    return 0;
}
