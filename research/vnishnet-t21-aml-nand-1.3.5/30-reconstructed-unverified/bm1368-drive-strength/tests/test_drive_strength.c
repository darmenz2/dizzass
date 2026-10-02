/* SPDX-License-Identifier: GPL-3.0-only
 * Offline composition of the real cache, writer and encoder/CRC. Callbacks
 * record/refuse bytes only; no firmware execution, hardware I/O or wait.
 */
#include "integration/bm1368_drive_strength_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"DRIVE135_FAIL case=%u line=%d %s\n",cases,__LINE__,#x); exit(1); } } while(0)
enum { CHAINS=2, CHIPS=3, BODY=9 };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    struct vn135_bm1368_drive_strength_reader_135 reader;
    struct vn135_bm1368_register_ops writer;
    struct vn135_bm1368_drive_strength_log_135 log;
    vn135_reg_cache cache;
    vn135_reg_chain chains[CHAINS];
    vn135_reg_table chips[CHAINS][CHIPS];
    uint8_t expected[BODY];
    uint32_t old, word, outer_index, inner_index;
    int32_t send_status, read_override, selected_chain, selected_chip;
    unsigned scenario, reads, sends, cache_calls, inner_logs, outer_logs, read_failed;
    char events[8]; unsigned event_count;
};
static void event(struct fixture *f,char c) { CHECK(f->event_count+1<sizeof f->events); f->events[f->event_count++]=c; }
static int slot58(const vn135_reg_table *t) {
    for(int i=0;i<VN135_REG_CACHE_SLOTS;++i) if(t->entries[i].address==0x58) return i;
    CHECK(0); return 0;
}
/* Independent per-bit oracle: copy each old bit except the four controlled
 * positions, which are selected independently from the corresponding input. */
static uint32_t word_oracle(uint32_t old,uint32_t input) {
    uint32_t result=0;
    for(unsigned b=0;b<32;++b) {
        uint32_t bit=b>=12 && b<16 ? (input>>(b-12))&1u : (old>>b)&1u;
        if(bit) result|=UINT32_C(1)<<b;
    }
    return result;
}
static uint8_t crc_oracle(const uint8_t bytes[8]) {
    unsigned char polynomial[69]={0};
    for(unsigned b=0;b<64;++b) polynomial[68u-b]=(unsigned char)((bytes[b/8u]>>(7u-b%8u))&1u);
    for(unsigned b=64;b<69;++b) polynomial[b]^=1u;
    for(int b=68;b>=5;--b) if(polynomial[b]) { polynomial[b]^=1u; polynomial[b-3]^=1u; polynomial[b-5]^=1u; }
    unsigned result=0; for(unsigned b=0;b<5;++b) result|=(unsigned)polynomial[b]<<b;
    return (uint8_t)result;
}
static int32_t read_record(void *p,int32_t chain,int32_t chip,uint32_t reg,uint32_t *out) {
    struct fixture *f=p;
    CHECK(f->reads==0 && f->sends==0 && *out==0 && reg==0x58);
    CHECK(chain==(f->scenario==4?-1:1) && chip==(f->scenario==3?-1:2));
    ++f->reads; event(f,'R');
    int32_t result=vn135_bm1368_drive_strength_cache_135(&f->cache,chain,chip,reg,out);
    if(result==0) CHECK(*out==f->old);
    else CHECK(*out==0);
    if(result==0 && f->scenario==5) {
        f->device.index=0; f->chip.cache_index=1; f->chip.wire_address=0x99;
        f->chips[1][2].entries[slot58(&f->chips[1][2])].value^=1u;
    }
    if(f->read_override) { *out=UINT32_MAX; return f->read_override; }
    return result;
}
static int32_t send_record(void *p,struct vn135_bm1368_frequency_device *d,const uint8_t *body,size_t n) {
    struct fixture *f=p;
    CHECK(d==&f->device && f->reads==1 && !f->read_failed && f->sends==0 && n==BODY);
    CHECK(memcmp(body,f->expected,BODY)==0 && f->cache_calls==0 && f->outer_logs==0);
    ++f->sends; event(f,'S');
    if(f->scenario==6) { d->index=0; f->chip.cache_index=1; f->chip.wire_address=0x88; }
    if(f->scenario==7) f->cache.initialized=0;
    return f->send_status;
}
static int32_t chip_cache(void *p,int32_t chain,int32_t chip,uint32_t reg,uint32_t value) {
    struct fixture *f=p;
    CHECK(f->sends==1 && f->cache_calls==0 && f->send_status==0);
    CHECK(reg==0x58 && value==f->word);
    ++f->cache_calls; event(f,'C'); f->selected_chain=chain; f->selected_chip=chip;
    if(f->scenario==8) f->cache.initialized=0;
    int32_t result=vn135_bm1368_register_cache_chip_135(&f->cache,chain,chip,reg,value);
    if(f->scenario==8) f->device.index=UINT32_MAX;
    return result;
}
static int32_t forbidden_chain(void *p,int32_t chain,uint32_t reg,uint32_t value) {
    (void)p;(void)chain;(void)reg;(void)value; CHECK(0); return -1;
}
static void inner_log(void *p,uint32_t line,uint32_t index) {
    struct fixture *f=p;
    CHECK(line==350 && f->sends==1 && f->inner_logs==0 && f->cache_calls==0 && f->outer_logs==0);
    f->inner_index=index; ++f->inner_logs; event(f,'I');
    if(f->scenario==9) f->device.index=UINT32_MAX;
}
static void outer_log(void *p,const struct vn135_bm1368_drive_strength_diagnostic_135 *d) {
    struct fixture *f=p;
    CHECK(f->reads==1 && f->outer_logs==0 && strcmp(d->module,"driver")==0);
    CHECK(strcmp(d->source,"/tmp/build/libbitmain/src/chip/chip1368.c")==0);
    CHECK(strcmp(d->function,"[redacted]")==0 && d->severity==1);
    if(f->read_failed) {
        CHECK(f->sends==0 && d->line==609 && d->has_index==0 && d->index_bits==0);
        CHECK(strcmp(d->format,"Failed to read cached drive strength register")==0);
    } else {
        CHECK(f->sends==1 && d->line==619 && d->has_index==1);
        CHECK(strcmp(d->format,"chain#%d - failed to config drive strength")==0);
    }
    f->outer_index=d->index_bits; ++f->outer_logs; event(f,'L');
    f->device.index=123; f->chip.cache_index=-1;
}
static void one_case(uint32_t input,uint32_t old,unsigned scenario,int32_t send_status,int32_t read_override) {
    struct fixture f={0}; vn135_reg_table before_common[CHAINS],expected_chips[CHAINS][CHIPS];
    f.device.index=scenario==4?UINT32_MAX:1;
    f.chip=(vn135_chip_reference){scenario==3?-1:2,0x123};
    f.old=old; f.word=word_oracle(old,input); f.scenario=scenario;
    f.send_status=send_status; f.read_override=read_override;
    f.read_failed=read_override!=0 || (scenario>=1 && scenario<=4);
    f.cache.chains=f.chains; f.cache.chain_count=CHAINS; f.cache.initialized=1;
    for(int i=0;i<CHAINS;++i) {
        CHECK(vn135_reg_cache_defaults(4,&f.chains[i].common)==0);
        f.chains[i].chips=f.chips[i]; f.chains[i].chip_count=CHIPS;
        for(int j=0;j<CHIPS;++j) f.chips[i][j]=f.chains[i].common;
    }
    int slot=slot58(&f.chips[1][2]); f.chips[1][2].entries[slot].value=old;
    if(scenario==1) f.cache.initialized=0;
    if(scenario==2) f.chips[1][2].entries[slot].address=0x100;
    for(int i=0;i<CHAINS;++i) before_common[i]=f.chains[i].common;
    memcpy(expected_chips,f.chips,sizeof expected_chips);
    f.reader=(struct vn135_bm1368_drive_strength_reader_135){read_record,&f};
    f.writer=(struct vn135_bm1368_register_ops){send_record,forbidden_chain,chip_cache,inner_log};
    f.log=(struct vn135_bm1368_drive_strength_log_135){&f,outer_log};
    f.expected[0]=0x41; f.expected[1]=9; f.expected[2]=scenario==5?0x99:0x23; f.expected[3]=0x58;
    for(unsigned b=0;b<4;++b) f.expected[4+b]=(uint8_t)(f.word>>(24u-b*8u));
    f.expected[8]=crc_oracle(f.expected);
    int failed=f.read_failed || send_status!=0 || scenario==7 || scenario==8;
    CHECK(vn135_bm1368_set_chip_drive_strength_135(&f.device,&f.chip,input,&f.reader,
        &f.writer,&f,failed?&f.log:NULL)==(failed?-1:0));
    CHECK(f.reads==1 && f.sends==(unsigned)!f.read_failed);
    CHECK(f.cache_calls==(unsigned)(!f.read_failed && send_status==0));
    CHECK(f.inner_logs==(unsigned)(!f.read_failed && send_status!=0));
    CHECK(f.outer_logs==(unsigned)failed);
    CHECK(strcmp(f.events,f.read_failed?"RL":send_status?"RSIL":failed?"RSCL":"RSC")==0);
    if(scenario==5) expected_chips[1][2].entries[slot].value^=1u;
    int chain=(scenario==5 || scenario==6)?0:1,chip=(scenario==5 || scenario==6)?1:2;
    if(!f.read_failed && !send_status) CHECK(f.selected_chain==chain && f.selected_chip==chip);
    if(!failed) expected_chips[chain][chip].entries[slot].value=f.word;
    for(int i=0;i<CHAINS;++i) CHECK(memcmp(&before_common[i],&f.chains[i].common,sizeof before_common[i])==0);
    CHECK(memcmp(expected_chips,f.chips,sizeof expected_chips)==0);
    if(failed && !f.read_failed) {
        uint32_t index=(scenario==5 || scenario==6)?0:1;
        if(send_status) CHECK(f.inner_index==index+UINT32_C(1));
        if((scenario==8 && !send_status) || (scenario==9 && send_status)) index=UINT32_MAX;
        CHECK(f.outer_index==index+UINT32_C(1));
    }
    ++cases;
}
struct boundary { int32_t expected; unsigned reads,logs; };
static int32_t boundary_read(void *p,int32_t chain,int32_t chip,uint32_t reg,uint32_t *out) {
    struct boundary *b=p;
    CHECK(chain==b->expected && chip==INT32_MAX && reg==0x58 && *out==0 && b->reads==0);
    ++b->reads; *out=UINT32_MAX; return 1; /* Explicit refusal, never a success stub. */
}
static void boundary_log(void *p,const struct vn135_bm1368_drive_strength_diagnostic_135 *d) {
    struct boundary *b=p;
    CHECK(b->reads==1 && b->logs==0 && d->line==609 && d->has_index==0 && d->index_bits==0);
    ++b->logs;
}
static void boundary_cases(void) {
    static const uint32_t words[]={0,1,0x7fffffff,0x80000000,0xfffffffe,0xffffffff};
    static const int32_t signed_words[]={0,1,INT32_MAX,INT32_MIN,-2,-1};
    for(unsigned i=0;i<6;++i) {
        struct boundary b={signed_words[i],0,0};
        struct vn135_bm1368_frequency_device d={words[i]};
        const vn135_chip_reference c={INT32_MAX,UINT32_MAX};
        const struct vn135_bm1368_drive_strength_reader_135 reader={boundary_read,&b};
        const struct vn135_bm1368_drive_strength_log_135 log={&b,boundary_log};
        CHECK(vn135_bm1368_set_chip_drive_strength_135(&d,&c,UINT32_MAX,&reader,NULL,NULL,&log)==-1);
        CHECK(b.reads==1 && b.logs==1); ++cases;
    }
}
int main(void) {
    static const uint32_t highs[]={0,16,0x80000000,0xfffffff0};
    static const uint32_t cached[]={0,UINT32_MAX,0x12345678,0xaaaa5555,0x80008000,0x02112111};
    static const int32_t statuses[]={0,1,INT32_MIN,INT32_MAX};
    for(unsigned low=0;low<16;++low) for(unsigned h=0;h<4;++h) for(unsigned c=0;c<6;++c)
    for(unsigned scenario=0;scenario<10;++scenario) for(unsigned s=0;s<4;++s)
        one_case(highs[h]|low,cached[c],scenario,statuses[s],0);
    for(unsigned b=0;b<32;++b) {
        one_case(UINT32_C(1)<<b,UINT32_C(1)<<b,b%10u,statuses[b%4u],0);
        one_case(~(UINT32_C(1)<<b),~(UINT32_C(1)<<b),b%10u,statuses[(b+1u)%4u],0);
    }
    for(unsigned s=1;s<4;++s) { one_case(15,UINT32_MAX,0,0,statuses[s]); one_case(16,0,5,0,statuses[s]); }
    boundary_cases();
    printf("BM1368_DRIVE135_HOST_PASS cases=%u checks=%u\n",cases,checks);
    return 0;
}
