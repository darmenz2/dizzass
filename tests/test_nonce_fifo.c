/* Stage13 native checks: actual allocations, overflow, opaque bytes and guards.
 * Separate from original-instruction comparisons; no devices or network. */
#include "xminer/recovery/nonce_fifo.h"
#include "xminer/recovery/difficulty.h"
#include "fixtures/genesis_work.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned assertions,scenarios;
#define CHECK(x) do{assertions++;if(!(x)){fprintf(stderr,"FAIL line %d: %s\n",__LINE__,#x);exit(1);}}while(0)
typedef struct {unsigned allocs,frees,live,fail_alloc,init,locks,unlocks,destroys;int held,fail_init,fail_lock,fail_unlock;} env;
static void *alloc(void *v,size_t n){env *e=v;e->allocs++;if(e->fail_alloc)return NULL;void *p=malloc(n);if(p){memset(p,0xcd,n);e->live++;}return p;}
static void release(void *v,void *p){env *e=v;CHECK(p&&e->live);e->frees++;e->live--;free(p);}
static int initialize(void *v){env *e=v;e->init++;return e->fail_init;}
static int lock(void *v){env *e=v;e->locks++;if(e->fail_lock)return -1;CHECK(!e->held);e->held=1;return 0;}
static int unlock(void *v){env *e=v;e->unlocks++;CHECK(e->held);e->held=0;return e->fail_unlock;}
static int destroy(void *v){env *e=v;e->destroys++;CHECK(!e->held);return 0;}
static uint32_t rng=0x130135;
static uint32_t random32(void){rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;return rng;}
static void record(vn135_nonce_record72 *r,uint32_t n){for(unsigned j=0;j<72;j++)r->bytes[j]=(uint8_t)(n+29u*j);for(unsigned j=0;j<4;j++)r->bytes[j]=(uint8_t)(n>>(8*j));}
static void ring_cases(void){
    const unsigned caps[]={1,2,3,7,19},strides[]={1,9,68,72,127};
    for(unsigned ci=0;ci<5;ci++)for(unsigned si=0;si<5;si++){
        unsigned cap=caps[ci],n=strides[si],count=0;uint8_t model[19][127],input[127],output[127];
        env e={0};vn135_fifo_memory m={&e,alloc,release};vn135_fifo q={0};CHECK(vn135_fifo_init(&q,cap,n,&m)==0);
        for(unsigned it=0;it<800;it++){
            uint32_t op=random32()%11;scenarios++;
            if(op<5){for(unsigned j=0;j<n;j++)input[j]=(uint8_t)random32();
                int rc=vn135_fifo_push(&q,input);CHECK(rc==(count<cap));
                if(count<cap){memcpy(model[count],input,n);count++;}
            }else if(op<9){memset(output,0xa5,sizeof(output));int discard=it%13==0;
                CHECK(vn135_fifo_pop(&q,discard?NULL:output)==(count!=0));
                if(count){if(!discard)CHECK(memcmp(output,model[0],n)==0);count--;memmove(model,model+1,count*sizeof(model[0]));}
                else CHECK(output[0]==0xa5);
                CHECK(n==sizeof(output) || output[n]==0xa5);
            }else if(op==9){CHECK(vn135_fifo_reset(&q)==0);count=0;}
            else {uint32_t got=UINT32_MAX;CHECK(vn135_fifo_count(&q,&got)==0&&got==count);}
            CHECK(q.count==count);CHECK(vn135_fifo_is_full(&q)==(count==cap));CHECK(vn135_fifo_is_empty(&q)==(count==0));
        }
        uint32_t saved=q.count,wi=q.write_index,ri=q.read_index;
        CHECK(vn135_fifo_destroy(&q,&m)==0&&q.storage==NULL&&q.count==saved&&q.write_index==wi&&q.read_index==ri);
        CHECK(vn135_fifo_destroy(&q,&m)==0&&e.frees==1&&e.live==0);
    }
}
static void codec_cases(void){
    _Static_assert(sizeof(vn135_nonce_candidate)==68,"test compact record");
    for(unsigned i=0;i<512;i++){
        vn135_nonce_record72 r,back;vn135_nonce_candidate c;uint8_t tail[4];
        for(unsigned j=0;j<72;j++)r.bytes[j]=(uint8_t)random32();
        CHECK(vn135_nonce_record_unpack(&r,&c,tail)==0);CHECK(vn135_nonce_record_pack(&c,tail,&back)==0);
        CHECK(memcmp(&r,&back,72)==0);CHECK(memcmp(r.bytes+68,tail,4)==0);scenarios++;
    }
    vn135_nonce_record72 r,before;vn135_nonce_candidate c;uint8_t tail[4]={1,2,3,4};
    memset(&r,0xab,sizeof(r));before=r;memset(&c,0,sizeof(c));
    CHECK(vn135_nonce_record_pack(NULL,tail,&r)==-2&&memcmp(&r,&before,72)==0);
    CHECK(vn135_nonce_record_pack(&c,NULL,&r)==-2&&memcmp(&r,&before,72)==0);
    CHECK(vn135_nonce_record_unpack(NULL,&c,tail)==-2);
}
static void queue_cases(void){
    env e={0};vn135_fifo_memory m={&e,alloc,release};vn135_fifo_sync s={&e,initialize,lock,unlock,destroy};vn135_nonce_fifo q={0};
    vn135_nonce_record72 r,out,want;uint32_t drop=777;
    CHECK(vn135_nonce_fifo_init(&q,&m,&s)==0);CHECK(q.ring.capacity==4096&&q.ring.element_size==72);
    CHECK(vn135_nonce_fifo_init(&q,&m,&s)==-2);
    q.push_word=UINT32_MAX-1;
    for(uint32_t i=0;i<4113;i++){record(&r,i);CHECK(vn135_nonce_fifo_push(&q,&r,&s,&drop)==0);CHECK(drop==(i>=4096));scenarios++;}
    CHECK(q.push_word==4111&&q.ring.count==4096&&vn135_nonce_fifo_is_full(&q,&s)==1);
    for(uint32_t i=17;i<4113;i++){record(&want,i);CHECK(vn135_nonce_fifo_pop(&q,&out,&s)==1);CHECK(memcmp(&out,&want,72)==0);scenarios++;}
    memset(&out,0xa7,72);want=out;CHECK(vn135_nonce_fifo_pop(&q,&out,&s)==0&&memcmp(&out,&want,72)==0);
    CHECK(vn135_nonce_fifo_is_empty(&q,&s)==1);
    record(&r,123);CHECK(vn135_nonce_fifo_push(&q,&r,&s,&drop)==0);uint32_t pushes=q.push_word;
    CHECK(vn135_nonce_fifo_reset(&q,&s)==0&&q.ring.count==0&&q.push_word==pushes);
    CHECK(vn135_nonce_fifo_destroy(&q,&m,&s)==0&&e.live==0);
    CHECK(vn135_nonce_fifo_destroy(&q,&m,&s)==0&&e.destroys==1);
    CHECK(vn135_nonce_fifo_pop(&q,&out,&s)==-2);
}
static void errors(void){
    env e={0};vn135_fifo_memory m={&e,alloc,release};vn135_fifo_sync s={&e,initialize,lock,unlock,destroy};
    vn135_fifo f={0},old=f;vn135_nonce_fifo q={0},prior=q;vn135_nonce_record72 r,out;record(&r,7);
    CHECK(vn135_fifo_init(&f,0,72,&m)==-2);CHECK(vn135_fifo_init(&f,7,0,&m)==-2);
    CHECK(vn135_fifo_init(&f,UINT32_MAX,72,&m)==-2&&e.allocs==0&&memcmp(&f,&old,sizeof(f))==0);
    CHECK(vn135_fifo_push(&f,r.bytes)==-2&&vn135_fifo_pop(&f,NULL)==-2);
    e.fail_init=1;CHECK(vn135_nonce_fifo_init(&q,&m,&s)==-4&&e.allocs==0);e.fail_init=0;
    CHECK(memcmp(&q,&prior,sizeof(q))==0);
    e.fail_alloc=1;CHECK(vn135_nonce_fifo_init(&q,&m,&s)==-3&&e.destroys==1&&e.live==0);e.fail_alloc=0;
    CHECK(memcmp(&q,&prior,sizeof(q))==0);
    CHECK(vn135_nonce_fifo_init(&q,&m,&s)==0);
    e.fail_lock=1;uint32_t dropped=777;CHECK(vn135_nonce_fifo_push(&q,&r,&s,&dropped)==-4&&q.ring.count==0&&q.push_word==0&&dropped==777);e.fail_lock=0;
    e.fail_unlock=1;CHECK(vn135_nonce_fifo_push(&q,&r,&s,&dropped)==-4&&q.ring.count==1&&q.push_word==1&&dropped==0);
    CHECK(vn135_nonce_fifo_pop(&q,&out,&s)==-4&&q.ring.count==0&&memcmp(&out,&r,72)==0);e.fail_unlock=0;
    q.ring.count=4097;CHECK(vn135_nonce_fifo_push(&q,&r,&s,NULL)==-2);q.ring.count=0;
    q.ring.read_index=q.ring.write_index;CHECK(vn135_nonce_fifo_destroy(&q,&m,&s)==0&&e.live==0);
}
static int read_job(void *ctx,uint32_t slot,vn135_work_job_snapshot *out){if(slot!=3)return 0;*out=*(vn135_work_job_snapshot *)ctx;return 1;}
static uint32_t chip(void *ctx,uint32_t n){(void)ctx;(void)n;return 2;}
static uint32_t core(void *ctx,uint32_t n){(void)ctx;(void)n;return 7;}
static uint32_t le(const uint8_t *p){return p[0]|(uint32_t)p[1]<<8|(uint32_t)p[2]<<16|(uint32_t)p[3]<<24;}
static void put(uint8_t *p,uint32_t x){for(unsigned i=0;i<4;i++)p[i]=(uint8_t)(x>>(8*i));}
static void genesis_pipeline(void){
    env e={0};vn135_fifo_memory mem={&e,alloc,release};vn135_fifo_sync sync={&e,initialize,lock,unlock,destroy};vn135_nonce_fifo q={0};
    CHECK(vn135_nonce_fifo_init(&q,&mem,&sync)==0);
    vn135_rebuild_snapshot snap={0};memcpy(snap.header_words_le,fixture_words,112);memset(snap.header_words_le+36,0x5a,32);
    snap.coinbase=fixture_coinbase;snap.coinbase_size=sizeof(fixture_coinbase);
    vn135_work_job_snapshot row={0};put(row.bytes+0x78,le(fixture_words));put(row.bytes+0xa4,0x12345678);
    memcpy(row.bytes+0x84,fixture_words+4,32);memcpy(row.bytes+0x50,fixture_words+36,28);
    vn135_work_job_reader reader={&row,read_job};vn135_nonce_attribution ids={NULL,chip,core};
    uint32_t nonce=le(fixture_words+76);uint8_t frame[11]={0xaa,0x55,0,0,0,0,0,24,0,0,0x80};
    for(unsigned j=0;j<4;j++)frame[j+2]=(uint8_t)(nonce>>(24-8*j));
    for(size_t frag=1;frag<=11;frag++){
        vn135_work_rx_stream rx;vn135_work_rx_message msg;CHECK(vn135_work_rx_stream_init(&rx,0,1,6,0)==0);
        size_t pos=0;while(pos<11){size_t n=11-pos,used=999;if(n>frag)n=frag;
            int rc=vn135_work_rx_stream_feed(&rx,frame+pos,n,&used,&msg);CHECK(used>0&&used<=n);pos+=used;
            CHECK(rc==(pos==11?VN135_RX_NONCE_RAW:VN135_RX_NEED_MORE));}
        vn135_work_nonce_result result;CHECK(vn135_work_nonce_from_rx(&rx.policy,&msg,&reader,&ids,&result)==0);
        vn135_nonce_record72 rec,popped;uint8_t tail[4]={0xd1,0xe2,0xf3,(uint8_t)frag},got[4];vn135_nonce_candidate decoded;
        CHECK(vn135_nonce_record_pack(&result.candidate,tail,&rec)==0);
        CHECK(vn135_nonce_fifo_push(&q,&rec,&sync,NULL)==0);CHECK(vn135_nonce_fifo_pop(&q,&popped,&sync)==1);
        CHECK(vn135_nonce_record_unpack(&popped,&decoded,got)==0);CHECK(memcmp(tail,got,4)==0);
        vn135_difficulty_check checked;uint8_t scratch[sizeof(fixture_coinbase)];uint32_t last=0;
        CHECK(vn135_candidate_verify_difficulty(&decoded,&snap,scratch,sizeof(scratch),1.,&last,0,&checked)==0);
        CHECK(checked.checked.meets_target&&memcmp(checked.checked.work.digest,fixture_hash,32)==0);scenarios++;
    }
    CHECK(vn135_nonce_fifo_destroy(&q,&mem,&sync)==0&&e.live==0);
}
int main(void){ring_cases();codec_cases();queue_cases();errors();genesis_pipeline();
 printf("{\"status\":\"PASS\",\"native_scenarios\":%u,\"assertions\":%u,\"rx_queue_genesis_fragments\":11,\"hardware_tested\":false,\"submitted\":false}\n",scenarios,assertions);return 0;}
