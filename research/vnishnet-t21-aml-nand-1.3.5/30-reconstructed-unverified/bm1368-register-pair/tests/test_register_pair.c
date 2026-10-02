/* SPDX-License-Identifier: GPL-3.0-only
 * Actual COMMON getter, writer, encoder/CRC and fanout with recording callbacks.
 * No original instruction execution, transport, wait, hardware or pool access.
 */
#include "integration/bm1368_register_pair_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"PAIR135_FAIL case=%u line=%d %s\n",cases,__LINE__,#x); exit(1); } } while(0)
enum { CHAINS=2, CHIPS=3, BODY=9 };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    struct vn135_bm1368_register_pair_reader_135 reader;
    struct vn135_bm1368_register_ops writer;
    vn135_reg_cache cache;
    vn135_reg_chain chains[CHAINS];
    vn135_reg_table chips[CHAINS][CHIPS], expected_chips[CHAINS][CHIPS], expected_common[CHAINS];
    uint32_t old[2], word[2], inner_index;
    int32_t send_status[2], read_override[2];
    unsigned scenario, reads, sends, cache_calls, logs, read_failed, first_write_failed, second_write_failed;
    char events[16]; unsigned event_count;
};
static void event(struct fixture *f,char c) { CHECK(f->event_count+1<sizeof f->events); f->events[f->event_count++]=c; }
static int slot(const vn135_reg_table *t,uint32_t reg) {
    for(int i=0;i<VN135_REG_CACHE_SLOTS;++i) if(t->entries[i].address==reg) return i;
    CHECK(0); return 0;
}
/* Independent per-bit oracle for all bits; no implementation mask expression. */
static uint32_t word_oracle(uint32_t old,unsigned which,uint32_t flag) {
    uint32_t result=0;
    for(unsigned b=0;b<32;++b) {
        unsigned bit=(old>>b)&1u;
        if(which==0 && flag && (b<4 || b==8)) bit=1;
        if(which==0 && !flag && b>=4 && b<8) bit=0;
        if(which==1 && flag && b>=20 && b<24) bit=0;
        if(which==1 && !flag && ((b>=16 && b<20) || b>=24)) bit=1;
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
static void mutate_common(struct fixture *f,int chain,uint32_t reg,uint32_t bits) {
    int s=slot(&f->chains[chain].common,reg);
    f->chains[chain].common.entries[s].value^=bits;
    f->expected_common[chain].entries[s].value^=bits;
}
static int32_t read_record(void *p,int32_t chain,uint32_t reg,uint32_t *out) {
    struct fixture *f=p; unsigned n=f->reads;
    CHECK(n<2 && f->sends==0 && reg==(n?0x18u:0xa8u));
    int32_t expected=n && f->scenario==5?0:n && f->scenario==16?-1:f->scenario==4?-1:1;
    CHECK(chain==expected); ++f->reads; event(f,n?'B':'A');
    /* Do not inspect the original uninitialized output before getter success. */
    int32_t result=vn135_bm1368_register_pair_cache_135(&f->cache,chain,reg,out);
    if(result==0) CHECK(*out==f->old[n]);
    if(result==0 && n==0 && f->scenario==5) { f->device.index=0; mutate_common(f,1,0xa8,1); }
    if(result==0 && n==0 && f->scenario==16) f->device.index=UINT32_MAX;
    if(result==0 && n==1 && f->scenario==6) {
        f->device.index=0; mutate_common(f,1,0xa8,2); mutate_common(f,1,0x18,4);
    }
    if(f->read_override[n]) { *out=UINT32_MAX; return f->read_override[n]; }
    if(result) *out=UINT32_MAX; /* Poisoned failure output MUST be ignored. */
    return result;
}
static int32_t send_record(void *p,struct vn135_bm1368_frequency_device *d,const uint8_t *body,size_t size) {
    struct fixture *f=p; unsigned n=f->sends; uint8_t expected[BODY]={0x51,9,0,0};
    CHECK(d==&f->device && f->reads==2 && !f->read_failed && n<2 && size==BODY);
    CHECK(n==0 || (!f->first_write_failed && f->cache_calls==1));
    expected[3]=n?0x18:0xa8;
    for(unsigned b=0;b<4;++b) expected[4+b]=(uint8_t)(f->word[n]>>(24u-8u*b));
    expected[8]=crc_oracle(expected); CHECK(memcmp(body,expected,BODY)==0);
    ++f->sends; event(f,n?'T':'S');
    if((n==0 && f->scenario==7) || (n==1 && f->scenario==8)) d->index=0;
    if((n==0 && f->scenario==10) || (n==1 && f->scenario==11)) f->cache.initialized=0;
    return f->send_status[n];
}
static int32_t chain_cache(void *p,int32_t chain,uint32_t reg,uint32_t value) {
    struct fixture *f=p; unsigned n=f->sends-1u;
    CHECK(f->reads==2 && n<2 && f->cache_calls==n && f->send_status[n]==0);
    CHECK(reg==(n?0x18u:0xa8u) && value==f->word[n]);
    int32_t expected=(f->scenario==5 || f->scenario==6 || f->scenario==7 ||
        (n==1 && (f->scenario==8 || f->scenario==9)))?0:n==1 && f->scenario==14?-1:1;
    CHECK(chain==expected); ++f->cache_calls; event(f,n?'D':'C');
    if((n==0 && f->scenario==12) || (n==1 && f->scenario==13)) f->cache.initialized=0;
    int fail=(n==0 && (f->scenario==10 || f->scenario==12)) ||
        (n==1 && (f->scenario==11 || f->scenario==13 || f->scenario==14));
    int32_t result=vn135_bm1368_register_cache_chain_135(&f->cache,chain,reg,value);
    CHECK(result==(fail?-1:0));
    if(!fail) {
        int s=slot(&f->expected_common[chain],reg);
        f->expected_common[chain].entries[s].value=value;
        for(int j=0;j<CHIPS;++j) f->expected_chips[chain][j].entries[s].value=value;
    }
    if(n==0 && f->scenario==9) f->device.index=0;
    if(n==0 && f->scenario==14) f->device.index=UINT32_MAX;
    return result;
}
static int32_t forbidden_chip(void *p,int32_t chain,int32_t chip,uint32_t reg,uint32_t value) {
    (void)p;(void)chain;(void)chip;(void)reg;(void)value; CHECK(0); return -1;
}
static void inner_log(void *p,uint32_t line,uint32_t index) {
    struct fixture *f=p; unsigned n=f->sends-1u;
    CHECK(f->reads==2 && n<2 && f->send_status[n]!=0 && line==350 && f->logs==0);
    uint32_t expected=(f->scenario==5 || f->scenario==6 || f->scenario==7 ||
        (n==1 && (f->scenario==8 || f->scenario==9)))?0:n==1 && f->scenario==14?UINT32_MAX:1;
    CHECK(index==expected+UINT32_C(1));
    f->inner_index=index; ++f->logs; event(f,'I');
    if(f->scenario==15) f->device.index=UINT32_MAX;
}
static void one_case(uint32_t flag,uint32_t a8,uint32_t reg18,unsigned scenario,
                     int32_t send_a,int32_t send_b,int32_t read_a,int32_t read_b) {
    struct fixture f={0}; f.device.index=scenario==4?UINT32_MAX:1;
    f.scenario=scenario; f.send_status[0]=send_a; f.send_status[1]=send_b;
    f.read_override[0]=read_a; f.read_override[1]=read_b;
    f.old[0]=a8; f.old[1]=scenario==5?reg18^UINT32_C(0x2468ace0):reg18;
    f.word[0]=word_oracle(f.old[0],0,flag); f.word[1]=word_oracle(f.old[1],1,flag);
    f.cache.chains=f.chains; f.cache.chain_count=CHAINS; f.cache.initialized=1;
    for(int i=0;i<CHAINS;++i) {
        CHECK(vn135_reg_cache_defaults(4,&f.chains[i].common)==0);
        int sa=slot(&f.chains[i].common,0xa8),sb=slot(&f.chains[i].common,0x18);
        f.chains[i].common.entries[sa].value=i==1?a8:a8^UINT32_C(0x13579bdf);
        f.chains[i].common.entries[sb].value=i==1?reg18:reg18^UINT32_C(0x2468ace0);
        f.chains[i].chips=f.chips[i]; f.chains[i].chip_count=CHIPS;
        for(int j=0;j<CHIPS;++j) {
            f.chips[i][j]=f.chains[i].common;
            /* Every chip differs from COMMON for both registers. */
            f.chips[i][j].entries[sa].value^=UINT32_C(0x01020304)*(uint32_t)(j+1);
            f.chips[i][j].entries[sb].value^=UINT32_C(0x10203040)*(uint32_t)(j+1);
        }
    }
    int sa=slot(&f.chains[1].common,0xa8),sb=slot(&f.chains[1].common,0x18);
    if(scenario==1) f.cache.initialized=0;
    if(scenario==2) f.chains[1].common.entries[sa].address=0x100;
    if(scenario==3) f.chains[1].common.entries[sb].address=0x100;
    if(scenario==17) f.cache.chain_count=1;
    for(int i=0;i<CHAINS;++i) f.expected_common[i]=f.chains[i].common;
    memcpy(f.expected_chips,f.chips,sizeof f.chips);
    int fail_a=read_a!=0 || scenario==1 || scenario==2 || scenario==4 || scenario==17;
    int fail_b=read_b!=0 || scenario==3 || scenario==16;
    f.read_failed=fail_a || fail_b;
    f.first_write_failed=send_a!=0 || scenario==10 || scenario==12;
    f.second_write_failed=send_b!=0 || scenario==11 || scenario==13 || scenario==14;
    f.reader=(struct vn135_bm1368_register_pair_reader_135){read_record,&f};
    f.writer=(struct vn135_bm1368_register_ops){send_record,chain_cache,forbidden_chip,inner_log};
    int failed=f.read_failed || f.first_write_failed || f.second_write_failed;
    /* Scripted read refusals retain a recording writer for explicit mutation
     * detection; actual cache refusals separately verify NULL unused writer. */
    const struct vn135_bm1368_register_ops *ops=f.read_failed && !read_a && !read_b?NULL:&f.writer;
    CHECK(vn135_bm1368_configure_register_pair_135(&f.device,flag,&f.reader,ops,&f)==(failed?-1:0));
    unsigned wanted_reads=fail_a?1:2;
    unsigned wanted_sends=f.read_failed?0:f.first_write_failed?1:2;
    unsigned wanted_cache=f.read_failed?0:send_a?0:f.first_write_failed?1:send_b?1:2;
    CHECK(f.reads==wanted_reads && f.sends==wanted_sends && f.cache_calls==wanted_cache);
    CHECK(f.logs==(unsigned)(!f.read_failed && (send_a || (!f.first_write_failed && send_b))));
    const char *events=fail_a?"A":fail_b?"AB":send_a?"ABSI":f.first_write_failed?"ABSC":send_b?"ABSCTI":"ABSCTD";
    CHECK(strcmp(f.events,events)==0);
    for(int i=0;i<CHAINS;++i) CHECK(memcmp(&f.expected_common[i],&f.chains[i].common,sizeof f.expected_common[i])==0);
    CHECK(memcmp(f.expected_chips,f.chips,sizeof f.chips)==0); ++cases;
}
struct boundary { int32_t expected; unsigned reads; };
static int32_t boundary_read(void *p,int32_t chain,uint32_t reg,uint32_t *out) {
    struct boundary *b=p; CHECK(b->reads==0 && chain==b->expected && reg==0xa8);
    ++b->reads; *out=UINT32_MAX; return INT32_MIN;
}
static void boundary_cases(void) {
    static const uint32_t bits[]={0,1,0x7fffffff,0x80000000,0xfffffffe,0xffffffff};
    static const int32_t signed_bits[]={0,1,INT32_MAX,INT32_MIN,-2,-1};
    for(unsigned i=0;i<6;++i) {
        struct boundary b={signed_bits[i],0};
        struct vn135_bm1368_frequency_device d={bits[i]};
        const struct vn135_bm1368_register_pair_reader_135 reader={boundary_read,&b};
        CHECK(vn135_bm1368_configure_register_pair_135(&d,UINT32_MAX,&reader,NULL,NULL)==-1);
        CHECK(b.reads==1); ++cases;
    }
}
int main(void) {
    static const uint32_t flags[]={0,1,2,16,256,0x80000000,UINT32_MAX};
    static const uint32_t words[]={0,UINT32_MAX,0x12345678,0xaaaa5555,0x80008000,0x02112111};
    static const int32_t statuses[]={0,1,INT32_MIN,INT32_MAX};
    /* Ignoring either read refusal must hit an explicit oracle before NULL. */
    one_case(1,0,0,0,0,0,1,0); one_case(0,UINT32_MAX,UINT32_MAX,0,0,0,0,1);
    one_case(1,0,0,0,0,0,INT32_MIN,0); one_case(0,UINT32_MAX,UINT32_MAX,0,0,0,0,INT32_MIN);
    for(unsigned f=0;f<7;++f) for(unsigned a=0;a<6;++a) for(unsigned b=0;b<6;++b)
    for(unsigned scenario=0;scenario<18;++scenario) for(unsigned sa=0;sa<4;++sa) for(unsigned sb=0;sb<4;++sb)
        one_case(flags[f],words[a],words[b],scenario,statuses[sa],statuses[sb],0,0);
    for(unsigned bit=0;bit<32;++bit) for(unsigned flag=0;flag<2;++flag) {
        one_case(flag,UINT32_C(1)<<bit,~(UINT32_C(1)<<bit),0,0,0,0,0);
        one_case(flag,~(UINT32_C(1)<<bit),UINT32_C(1)<<bit,9,0,0,0,0);
    }
    for(unsigned s=1;s<4;++s) {
        one_case(2,UINT32_MAX,0,5,0,0,statuses[s],0);
        one_case(16,0,UINT32_MAX,6,0,0,0,statuses[s]);
    }
    boundary_cases();
    printf("BM1368_PAIR135_HOST_PASS cases=%u checks=%u\n",cases,checks); return 0;
}
