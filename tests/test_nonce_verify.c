#include "xminer/recovery/nonce_verify.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
static unsigned tests;
static uint32_t le(const uint8_t *p) {return (uint32_t)p[0]|(uint32_t)p[1]<<8|(uint32_t)p[2]<<16|(uint32_t)p[3]<<24;}
static void setle(uint8_t *p,uint32_t x) {for(unsigned i=0;i<4;i++)p[i]=(uint8_t)(x>>(8*i));}
static void unhex(const char *s,uint8_t *b,size_t n) {
    const char *hex="0123456789abcdef";
    for(size_t i=0;i<n;i++){const char *a=strchr(hex,s[2*i]),*c=strchr(hex,s[2*i+1]);assert(a&&c);b[i]=(uint8_t)(((a-hex)<<4)|(c-hex));}
}
struct cbstate {uint32_t *last;uint32_t nonce,high;unsigned calls;};
static void forced(void *ctx,const uint8_t words[80],uint8_t digest[32]) {
    struct cbstate *s=ctx;assert(*s->last==s->nonce&&le(words+76)==s->nonce);
    s->calls++;memset(digest,0x55,32);setle(digest+28,s->high);
}
struct rejectstate {unsigned calls;int code;void *expected;};
static int reject(void *ctx,void *ref) {struct rejectstate *s=ctx;assert(s->expected==ref);s->calls++;return s->code;}
int main(void) {
    uint8_t words[80],digest[32],expected[32],wire[80],same[112];
    for(unsigned i=0;i<80;i++)words[i]=(uint8_t)i;
    unhex("7870cff65f59785edabcdd144023095b8926d49a834c73d1f2d77d310af30004",expected,32);
    for(unsigned i=0;i<80;i++)wire[i]=words[(i&~3u)+(3u-(i&3u))];
    assert(vn135_frontend_hash_words80(words,digest)==0&&!memcmp(digest,expected,32));tests++;
    assert(vn135_sha256d_header80(wire,digest)==0&&!memcmp(digest,expected,32));tests++;
    for(unsigned offset=0;offset<4;offset++) {
        memset(same,0x3a,sizeof(same));memcpy(same+offset,wire,80);
        assert(vn135_sha256d_header80(same+offset,same+offset)==0);
        assert(!memcmp(same+offset,expected,32));tests++;
    }
    memset(digest,0x69,32);memcpy(expected,digest,32);
    assert(vn135_sha256d_header80(NULL,digest)==-2&&!memcmp(digest,expected,32));tests++;
    assert(vn135_sha256d_header80(words,NULL)==-2);tests++;
    assert(vn135_frontend_hash_words80(NULL,digest)==-2&&!memcmp(digest,expected,32));tests++;
    assert(vn135_frontend_hash_words80(words,NULL)==-2);tests++;
    assert(vn135_target256_check_le(NULL,digest)==-2);tests++;
    assert(vn135_target256_check_le(digest,NULL)==-2);tests++;
    for(unsigned i=0;i<32;i++) {
        uint8_t h[32]={0},t[32]={0};
        assert(vn135_target256_check_le(h,t)==1);tests++;
        h[i]=0x80;assert(vn135_target256_check_le(h,t)==0);tests++;
        t[i]=0xff;assert(vn135_target256_check_le(h,t)==1);tests++;
        if(i){h[i]=0xff;t[i]=0x80;memset(t,0xff,i);assert(vn135_target256_check_le(h,t)==0);tests++;}
    }
    uint32_t highs[]={0,1,0xffff,0x10000,0x80000000,0xffffffff};
    for(unsigned selector=0;selector<3;selector++)for(unsigned i=0;i<6;i++) {
        vn135_verify_work w;memset(&w,0x9d,sizeof(w));uint32_t last=0;
        struct cbstate s={&last,42,highs[i],0};
        int rc=vn135_frontend_nonce_prefilter(&w,&last,42,selector,forced,&s);
        assert(rc==(highs[i]<=(selector==1?0xffffu:0)?0:2));
        assert(last==42&&s.calls==1);tests++;
        vn135_verify_work saved=w;
        assert(vn135_frontend_nonce_prefilter(&w,&last,42,selector,forced,&s)==1);
        assert(!memcmp(&w,&saved,sizeof(w))&&s.calls==1);tests++;
    }
    vn135_verify_work w;memset(&w,0xa5,sizeof(w));vn135_verify_work saved=w;uint32_t last=0;
    struct cbstate cb={&last,0,0,0};
    assert(vn135_frontend_nonce_prefilter(&w,&last,0,0,forced,&cb)==1&&cb.calls==0);tests++;
    assert(vn135_frontend_nonce_prefilter(NULL,&last,1,0,forced,&cb)==-2);tests++;
    assert(vn135_frontend_nonce_prefilter(&w,NULL,1,0,forced,&cb)==-2);tests++;
    assert(vn135_frontend_nonce_prefilter(&w,&last,1,0,NULL,&cb)==-2);tests++;
    assert(!memcmp(&w,&saved,sizeof(w))&&last==0&&cb.calls==0);
    int tokens[3]={0};vn135_recent_job_record jobs[3]={{7,&tokens[0],1},{7,&tokens[1],1},{7,&tokens[2],1}};
    struct rejectstate state={0,0,&tokens[0]};size_t index=999;
    assert(vn135_recent_job_select(jobs,7,reject,&state,&index)==0&&index==0&&state.calls==1);tests++;
    jobs[0].reference=NULL;index=999;state.calls=0;
    assert(vn135_recent_job_select(jobs,7,reject,&state,&index)==2&&index==999&&state.calls==0);tests++;
    jobs[0].reference=&tokens[0];jobs[0].word_1fc=0;
    assert(vn135_recent_job_select(jobs,7,reject,&state,&index)==4&&index==999&&state.calls==1);tests++;
    state.code=-1;state.calls=0;
    assert(vn135_recent_job_select(jobs,7,reject,&state,&index)==3&&index==999&&state.calls==1);tests++;
    state.calls=0;
    assert(vn135_recent_job_select(jobs,8,reject,&state,&index)==1&&index==999&&state.calls==0);tests++;
    assert(vn135_recent_job_select(NULL,7,reject,&state,&index)==-2);tests++;
    assert(vn135_recent_job_select(jobs,7,NULL,&state,&index)==-2);tests++;
    assert(vn135_recent_job_select(jobs,7,reject,&state,NULL)==-2);tests++;
    void *refs[]={NULL,&tokens[1],&tokens[0],&tokens[0]};
    assert(vn135_reference_absent(refs,4,&tokens[0])==0);tests++;
    assert(vn135_reference_absent(refs,4,&tokens[2])==1);tests++;
    assert(vn135_reference_absent(refs,4,NULL)==0);tests++;
    assert(vn135_reference_absent(NULL,0,NULL)==1);tests++;
    assert(vn135_reference_absent(NULL,INT32_MIN,NULL)==1);tests++;
    assert(vn135_reference_absent(NULL,1,NULL)==-2);tests++;
    jobs[0].word_1fc=1;index=999;
    assert(vn135_recent_job_select_registered(jobs,7,refs,4,&index)==0&&index==0);tests++;
    index=999;
    assert(vn135_recent_job_select_registered(jobs,7,NULL,0,&index)==3&&index==999);tests++;
    assert(vn135_recent_job_select_registered(jobs,7,NULL,1,&index)==-2&&index==999);tests++;
    assert(vn135_recent_job_select_registered(NULL,7,refs,4,&index)==-2);tests++;
    assert(vn135_recent_job_select_registered(jobs,7,refs,4,NULL)==-2);tests++;
    printf("Stage8 native cases: %u PASS; no device access\n",tests);
    return 0;
}
