/* Stage10 native checks. New APIs; historical synthetic data, no live work. */
#include "xminer/recovery/difficulty.h"
#include "xminer/recovery/sha256_midstate.h"
#include "fixtures/genesis_work.h"
#include <stdio.h>
#include <string.h>
#include <float.h>
#include <math.h>
static unsigned checks;
#define CHECK(x) do {++checks;if(!(x)){fprintf(stderr,"FAIL line %d: %s\n",__LINE__,#x);return 1;}}while(0)
static uint32_t get_le(const uint8_t *p){return p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
static void put_le(uint8_t *p,uint32_t x){for(unsigned i=0;i<4;i++)p[i]=(uint8_t)(x>>(8*i));}
static void setup(vn135_rebuild_snapshot *s,vn135_nonce_candidate *c){
    memset(s,0,sizeof(*s));memset(c,0,sizeof(*c));
    memcpy(s->header_words_le,fixture_words,112);
    memset(s->header_words_le,0xa8,4);memset(s->header_words_le+36,0xd3,32);
    s->coinbase=fixture_coinbase;s->coinbase_size=sizeof(fixture_coinbase);
    c->version_word=get_le(fixture_words);c->nonce=get_le(fixture_words+76);
    c->job_word_70=UINT32_MAX;c->job_word_74=UINT32_MAX;c->job_slot=3;
}
static int arithmetic(void){
    uint8_t t[34], before[34], zero[32]={0};double d;
    memset(t,0xa7,sizeof(t));memcpy(before,t,sizeof(t));
    CHECK(vn135_frontend_target_from_difficulty(1.,0,t+1)==0);
    CHECK(memcmp(t+1,fixture_target,32)==0 && t[0]==0xa7 && t[33]==0xa7);
    CHECK(vn135_frontend_difficulty_from_target(t+1,0,&d)==0 && d==1.);
    CHECK(vn135_frontend_target_from_difficulty(65536.,1,t+1)==0);
    CHECK(memcmp(t+1,fixture_target,32)==0);
    CHECK(vn135_frontend_target_from_difficulty(0.,0,t+1)==0);
    CHECK(memcmp(t+1,fixture_target,32)==0);
    CHECK(vn135_frontend_target_from_difficulty(-0.,0,t+1)==0);
    CHECK(memcmp(t+1,fixture_target,32)==0);
    CHECK(vn135_frontend_target_from_difficulty(DBL_MAX,0,t+1)==0);
    CHECK(memcmp(t+1,zero,32)==0);
    CHECK(vn135_frontend_difficulty_from_target(zero,0,&d)==0 && d==0x1.fffep223);
    CHECK(vn135_frontend_difficulty_from_target(zero,1,&d)==0 && d==0x1.fffep239);
    CHECK(vn135_frontend_target_from_difficulty(1.,0,NULL)==-2);
    CHECK(vn135_frontend_difficulty_from_target(t,0,NULL)==-2);
    d=123.;CHECK(vn135_frontend_difficulty_from_target(NULL,0,&d)==-2 && d==123.);
    const double bad[]={NAN,INFINITY,-INFINITY,-1.,-DBL_MAX,0x1p-1000,0x1p-33};
    for(size_t i=0;i<sizeof(bad)/sizeof(bad[0]);++i){
        memcpy(t,before,sizeof(t));
        CHECK(vn135_frontend_target_from_difficulty(bad[i],0,t+1)==(i<5?-2:-4));
        CHECK(memcmp(t,before,sizeof(t))==0);
    }
    vn135_work_math m,old;uint32_t expected_mid[8];
    CHECK(vn135_frontend_work_math(fixture_words,1.,0,&m)==0);
    CHECK(memcmp(m.target_le,fixture_target,32)==0);
    CHECK(vn135_sha256_midstate64(fixture_header,expected_mid)==0);
    CHECK(memcmp(m.midstate,expected_mid,sizeof(expected_mid))==0);
    memcpy(&old,&m,sizeof(m));
    CHECK(vn135_frontend_work_math(fixture_words,-1.,0,&m)==-2);
    CHECK(memcmp(&m,&old,sizeof(m))==0);
    CHECK(vn135_frontend_work_math(NULL,1.,0,&m)==-2);
    CHECK(vn135_frontend_work_math(fixture_words,1.,0,NULL)==-2);
    return 0;
}
static int pipeline_cases(void){
    vn135_rebuild_snapshot s,before;vn135_nonce_candidate c;
    vn135_difficulty_check out,old;uint8_t scratch[sizeof(fixture_coinbase)+2],prior[sizeof(scratch)];
    setup(&s,&c);memcpy(&before,&s,sizeof(s));
    const double values[]={0.,-0.,1.,2.,65536.,1e12,DBL_MAX};
    for(unsigned selector=0;selector<3;selector++)for(size_t i=0;i<sizeof(values)/sizeof(values[0]);i++){
        uint8_t target[32];uint32_t last=0;memset(scratch,0x19,sizeof(scratch));
        CHECK(vn135_frontend_target_from_difficulty(values[i],selector,target)==0);
        CHECK(vn135_candidate_verify_difficulty(&c,&s,scratch+1,sizeof(fixture_coinbase),values[i],&last,selector,&out)==0);
        CHECK(memcmp(out.target_le,target,32)==0);
        CHECK(memcmp(out.checked.work.digest,fixture_hash,32)==0);
        CHECK(out.checked.target_checked==1 && out.checked.hash_computed==1);
        CHECK(out.checked.meets_target==(uint32_t)vn135_target256_check_le(fixture_hash,target));
        CHECK(scratch[0]==0x19 && scratch[sizeof(scratch)-1]==0x19);
        CHECK(memcmp(&s,&before,sizeof(s))==0);
        CHECK(vn135_candidate_verify_difficulty(&c,&s,scratch+1,sizeof(fixture_coinbase),values[i],&last,selector,&out)==0);
        CHECK(out.checked.prefilter_result==1 && out.checked.hash_computed==0 && out.checked.target_checked==0);
    }
    memset(scratch,0x81,sizeof(scratch));memcpy(prior,scratch,sizeof(scratch));
    memset(&out,0x73,sizeof(out));memcpy(&old,&out,sizeof(out));
    const double bad[]={NAN,INFINITY,-1.,0x1p-33};
    for(size_t i=0;i<sizeof(bad)/sizeof(bad[0]);++i){
        uint32_t last=7788;
        CHECK(vn135_candidate_verify_difficulty(&c,&s,scratch,sizeof(scratch),bad[i],&last,0,&out)==(i<3?-2:-4));
        CHECK(last==7788 && memcmp(&out,&old,sizeof(out))==0 && memcmp(scratch,prior,sizeof(scratch))==0);
    }
    uint32_t last=7788;
    CHECK(vn135_candidate_verify_difficulty(&c,&s,scratch,1,1.,&last,0,&out)==-3);
    CHECK(vn135_candidate_verify_difficulty(NULL,&s,scratch,sizeof(scratch),1.,&last,0,&out)==-2);
    CHECK(vn135_candidate_verify_difficulty(&c,NULL,scratch,sizeof(scratch),1.,&last,0,&out)==-2);
    CHECK(vn135_candidate_verify_difficulty(&c,&s,scratch,sizeof(scratch),1.,NULL,0,&out)==-2);
    CHECK(vn135_candidate_verify_difficulty(&c,&s,scratch,sizeof(scratch),1.,&last,0,NULL)==-2);
    CHECK(last==7788 && memcmp(&out,&old,sizeof(out))==0 && memcmp(scratch,prior,sizeof(scratch))==0);
    return 0;
}
typedef struct {vn135_work_job_snapshot row;uint32_t slot;unsigned reads,chips,cores;} reader_context;
static int read_job(void *opaque,uint32_t slot,vn135_work_job_snapshot *out){
    reader_context *x=opaque;x->reads++;if(slot!=x->slot)return 0;*out=x->row;return 1;
}
static uint32_t chip(void *opaque,uint32_t nonce){reader_context *x=opaque;(void)nonce;x->chips++;return 2;}
static uint32_t core(void *opaque,uint32_t nonce){reader_context *x=opaque;(void)nonce;x->cores++;return 7;}
static int stream(void){
    vn135_rebuild_snapshot snap;vn135_nonce_candidate desired;
    setup(&snap,&desired);
    reader_context ctx={0};ctx.slot=3;
    put_le(ctx.row.bytes+0x78,desired.version_word);
    put_le(ctx.row.bytes+0x70,desired.job_word_70);put_le(ctx.row.bytes+0x74,desired.job_word_74);
    memcpy(ctx.row.bytes+0x84,fixture_words+4,32);memcpy(ctx.row.bytes+0x50,fixture_words+36,28);
    put_le(ctx.row.bytes+0xa4,0x12345678);
    vn135_work_job_reader reader={&ctx,read_job};vn135_nonce_attribution ids={&ctx,chip,core};
    uint8_t frame[11]={0xaa,0x55,0,0,0,0,0,24,0,0,0x80};
    for(unsigned j=0;j<4;j++)frame[2+j]=(uint8_t)(desired.nonce>>(24-8*j));
    for(size_t fragment=1;fragment<=11;fragment++){
        vn135_work_rx_stream rx;vn135_work_rx_message msg;
        CHECK(vn135_work_rx_stream_init(&rx,0,1,6,0)==0);
        size_t pos=0;int event=0;
        while(pos<sizeof(frame)){
            size_t n=sizeof(frame)-pos,used=999;if(n>fragment)n=fragment;
            event=vn135_work_rx_stream_feed(&rx,frame+pos,n,&used,&msg);
            CHECK(used>0 && used<=n);pos+=used;
            CHECK(event==(pos==sizeof(frame)?VN135_RX_NONCE_RAW:VN135_RX_NEED_MORE));
        }
        vn135_work_nonce_result candidate;vn135_difficulty_check checked;uint8_t scratch[sizeof(fixture_coinbase)];uint32_t last=0;
        CHECK(vn135_work_nonce_from_rx(&rx.policy,&msg,&reader,&ids,&candidate)==0);
        CHECK(candidate.candidate.nonce==desired.nonce && candidate.candidate.version_word==desired.version_word);
        CHECK(memcmp(candidate.compression_block,fixture_header,64)==0);
        CHECK(vn135_candidate_verify_difficulty(&candidate.candidate,&snap,scratch,sizeof(scratch),1.0,&last,0,&checked)==0);
        CHECK(checked.checked.meets_target==1 && checked.checked.target_checked==1 && memcmp(checked.checked.work.digest,fixture_hash,32)==0);
    }
    CHECK(ctx.reads==11 && ctx.chips==11 && ctx.cores==11);
    return 0;
}
int main(void){CHECK(arithmetic()==0);CHECK(pipeline_cases()==0);CHECK(stream()==0);
    printf("{\"status\":\"PASS\",\"native_checks\":%u,\"fragmented_genesis_replays\":11,\"target_derived_from_difficulty\":true,\"hardware_tested\":false,\"submitted\":false}\n",checks);return 0;}
