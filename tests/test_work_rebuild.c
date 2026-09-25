/* New API/memory/stream tests. Genesis input is public historical data,
 * not an ASIC capture. Chip/core attribution and job lifetime are fixtures. */
#include "xminer/recovery/work_rebuild.h"
#include "xminer/recovery/sha256_midstate.h"
#include "fixtures/genesis_work.h"
#include <stdio.h>
#include <string.h>
#include <limits.h>
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
static int invalids(void){
    uint8_t output[32],old[32],scratch[256],scratch_before[256];
    vn135_rebuild_snapshot s,bad;vn135_nonce_candidate c;vn135_rebuilt_header out,before;
    vn135_rebuild_check check,oldcheck;uint32_t last=123;
    setup(&s,&c);memset(output,0xf1,32);memcpy(old,output,32);
    CHECK(vn135_sha256_bytes(NULL,1,output)==-2);CHECK(memcmp(output,old,32)==0);
    CHECK(vn135_sha256d_bytes(NULL,1,output)==-2);CHECK(memcmp(output,old,32)==0);
    CHECK(vn135_sha256_bytes(output,1,NULL)==-2);
    CHECK(vn135_sha256d_bytes(output,1,NULL)==-2);
#if SIZE_MAX > UINT32_MAX
    CHECK(vn135_sha256_bytes(output,(size_t)UINT32_MAX+1,output)==-2);
#endif
    memset(scratch,0x6e,sizeof(scratch));memcpy(scratch_before,scratch,sizeof(scratch));
    memset(&out,0x77,sizeof(out));memcpy(&before,&out,sizeof(out));
    for(unsigned k=0;k<10;k++){
        bad=s;
        switch(k){
        case 0:bad.counter_size=9;break;
        case 1:bad.counter_offset=bad.coinbase_size+1;break;
        case 2:bad.counter_offset=bad.coinbase_size;bad.counter_size=1;break;
        case 3:bad.coinbase=NULL;break;
        case 4:bad.merkle_count=1;bad.merkle_branches=NULL;break;
        case 5:bad.merkle_count=(size_t)INT32_MAX+1;bad.merkle_branches=output;break;
        default:break;
        }
        int rc=vn135_rebuild_from_candidate(k==6?NULL:&c,k==7?NULL:&bad,k==8?NULL:scratch,
            k==9?s.coinbase_size-1:sizeof(scratch),&out);
        CHECK(rc==(k==9?-3:-2));CHECK(memcmp(&out,&before,sizeof(out))==0);
        CHECK(memcmp(scratch,scratch_before,sizeof(scratch))==0);
    }
    memset(&check,0x3b,sizeof(check));memcpy(&oldcheck,&check,sizeof(check));
    CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch,1,fixture_target,&last,0,&check)==-3);
    CHECK(last==123);CHECK(memcmp(&check,&oldcheck,sizeof(check))==0);
    CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch,sizeof(scratch),NULL,&last,0,&check)==-2);
    CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch,sizeof(scratch),fixture_target,NULL,0,&check)==-2);
    CHECK(memcmp(scratch,scratch_before,sizeof(scratch))==0);
    vn135_work_template job={0};vn135_rebuilt_header empty;
    job.counter=UINT64_MAX;CHECK(vn135_frontend_rebuild_prefix(&job,&empty)==0);
    CHECK(job.counter==0 && empty.counter_used==UINT64_MAX);
    CHECK(vn135_sha256d_bytes(NULL,0,output)==0 && memcmp(output,empty.merkle_root,32)==0);
    for(unsigned k=0;k<5;k++){
        job.counter=77;job.counter_size=0;job.coinbase_size=0;job.coinbase=NULL;job.counter_offset=0;
        job.merkle_count=0;job.merkle_branches=NULL;
        if(k==0)job.counter_size=9;
        if(k==1)job.coinbase_size=1;
        if(k==2)job.counter_offset=1;
        if(k==3)job.merkle_count=1;
        vn135_work_template original=job;memcpy(&out,&before,sizeof(out));
        CHECK(vn135_frontend_rebuild_prefix(k==4?NULL:&job,&out)==-2);
        CHECK(memcmp(&job,&original,sizeof(job))==0 && memcmp(&out,&before,sizeof(out))==0);
    }
    return 0;
}
static int genesis(void){
    vn135_rebuild_snapshot s,before;vn135_nonce_candidate c;
    vn135_rebuild_check out;uint8_t scratch[sizeof(fixture_coinbase)+2],target[32];
    setup(&s,&c);memcpy(&before,&s,sizeof(s));
    for(unsigned selector=0;selector<3;selector++){
        uint32_t last=0;memset(scratch,0x19,sizeof(scratch));
        CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch+1,sizeof(fixture_coinbase),fixture_target,&last,selector,&out)==0);
        CHECK(out.prefilter_result==0 && out.hash_computed==1 && out.target_checked==1 && out.meets_target==1);
        CHECK(memcmp(out.rebuilt.header_words_le,fixture_words,112)==0);
        CHECK(memcmp(out.rebuilt.merkle_root,fixture_root,32)==0);
        CHECK(memcmp(out.work.digest,fixture_hash,32)==0 && last==c.nonce);
        CHECK(scratch[0]==0x19 && scratch[sizeof(scratch)-1]==0x19);
        CHECK(memcmp(scratch+1,fixture_coinbase,sizeof(fixture_coinbase))==0);
        CHECK(memcmp(&s,&before,sizeof(s))==0);
        CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch+1,sizeof(fixture_coinbase),fixture_target,&last,selector,&out)==0);
        CHECK(out.prefilter_result==1 && out.hash_computed==0 && out.target_checked==0 && out.meets_target==0);
        for(unsigned i=0;i<32;i++)CHECK(out.work.digest[i]==0);
    }
    for(unsigned mode=0;mode<3;mode++){
        memcpy(target,fixture_hash,32);
        if(mode==1)target[0]--; /* Raw genesis digest low byte nonzero. */
        if(mode==2)memset(target,0,32);
        uint32_t last=0;
        CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch,sizeof(scratch),target,&last,0,&out)==0);
        CHECK(out.target_checked==1 && out.meets_target==(mode==0));
    }
    c.nonce^=1;uint32_t last=0;
    CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch,sizeof(scratch),fixture_target,&last,0,&out)==0);
    CHECK(out.prefilter_result==2 && out.hash_computed==1 && out.target_checked==0 && last==c.nonce);
    CHECK(vn135_candidate_verify_snapshot(&c,&s,scratch,sizeof(scratch),fixture_target,&last,0,&out)==0);
    CHECK(out.prefilter_result==1 && out.hash_computed==0);
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
        vn135_work_nonce_result candidate;vn135_rebuild_check checked;uint8_t scratch[sizeof(fixture_coinbase)];uint32_t last=0;
        CHECK(vn135_work_nonce_from_rx(&rx.policy,&msg,&reader,&ids,&candidate)==0);
        CHECK(candidate.candidate.nonce==desired.nonce && candidate.candidate.version_word==desired.version_word);
        CHECK(memcmp(candidate.compression_block,fixture_header,64)==0);
        CHECK(vn135_candidate_verify_snapshot(&candidate.candidate,&snap,scratch,sizeof(scratch),fixture_target,&last,0,&checked)==0);
        CHECK(checked.meets_target==1 && checked.target_checked==1 && memcmp(checked.work.digest,fixture_hash,32)==0);
    }
    CHECK(ctx.reads==11 && ctx.chips==11 && ctx.cores==11);
    return 0;
}
int main(void){CHECK(invalids()==0);CHECK(genesis()==0);CHECK(stream()==0);
    printf("{\"status\":\"PASS\",\"native_checks\":%u,\"fragmented_genesis_replays\":11,\"hardware_tested\":false,\"submitted\":false}\n",checks);return 0;}
