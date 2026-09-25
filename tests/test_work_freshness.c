#include "xminer/recovery/work_freshness.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
static unsigned checks;
#define CHECK(x) do { ++checks; assert(x); } while(0)
static void put(uint8_t *p,uint32_t x){for(unsigned i=0;i<4;++i)p[i]=(uint8_t)(x>>(i*8));}
int main(void){
    vn135_work_freshness_snapshot s={0};vn135_work_freshness_result r,before;
    s.work_block=s.current_work_block=7;s.pool_byte_3fc=s.pool_byte_3fe=1;
    s.work_job_id=(vn135_text_view){(const uint8_t *)"same",4};s.pool_job_id=s.work_job_id;
    for(int roll=-4;roll<=604;++roll){
        s.rolltime=roll;s.staged_seconds_bits=UINT64_C(0xffffffff);
        unsigned expiry=roll>60?(unsigned)roll:600u;
        for(unsigned age=0;age<=expiry+1u;++age){
            s.now_seconds_bits=s.staged_seconds_bits+age;
            CHECK(!vn135_frontend_work_stale_legacy(&s,&r));
            CHECK(r.stale==(age>=expiry));CHECK(r.time_compared==1u);
        }
    }
    s.now_seconds_bits=s.staged_seconds_bits;s.rolltime=0;
    s.pool_job_id=(vn135_text_view){(const uint8_t *)"other",5};
    CHECK(!vn135_frontend_work_stale_legacy(&s,&r));CHECK(r.reason==VN135_WORK_JOB_CHANGED && !r.time_compared);
    s.share=1;CHECK(!vn135_frontend_work_stale_legacy(&s,&r));CHECK(!r.stale && !r.job_ids_compared);
    s.share=0;s.pool_job_id=(vn135_text_view){NULL,0};CHECK(!vn135_frontend_work_stale_legacy(&s,&r));CHECK(!r.stale && !r.job_ids_compared);
    s.pool_byte_3fc=0;CHECK(!vn135_frontend_work_stale_legacy(&s,&r));CHECK(r.reason==VN135_WORK_STRATUM_INACTIVE);
    ++s.current_work_block;CHECK(!vn135_frontend_work_stale_legacy(&s,&r));CHECK(r.reason==VN135_WORK_BLOCK_CHANGED);
    memset(&r,0xa7,sizeof r);memcpy(&before,&r,sizeof r);
    CHECK(vn135_frontend_work_stale_legacy(NULL,&r)==-2);CHECK(!memcmp(&r,&before,sizeof r));
    CHECK(vn135_frontend_work_stale_legacy(&s,NULL)==-2);
    s.pool_job_id=(vn135_text_view){NULL,1};CHECK(vn135_frontend_work_stale_legacy(&s,&r)==-2);CHECK(!memcmp(&r,&before,sizeof r));
    const uint8_t bad[]={1,0,2};s.pool_job_id=(vn135_text_view){bad,3};
    CHECK(vn135_frontend_work_stale_legacy(&s,&r)==-2);CHECK(!memcmp(&r,&before,sizeof r));
    vn135_work_storage w={0};put(w.image+0x1b8,17);put(w.image+0x184,60);put(w.image+0x170,900);
    w.text[0]=(char *)"a";w.text_size[0]=1;vn135_text_view v={(const uint8_t *)"a",1};
    CHECK(!vn135_work_storage_stale_snapshot(&w,17,0,1,1,v,1499,&r));CHECK(!r.stale);
    CHECK(!vn135_work_storage_stale_snapshot(&w,17,0,1,1,v,1500,&r));CHECK(r.stale);
    for(unsigned i=0;i<4u;++i){
        const unsigned offsets[]={0x18c,0x19c,0x1a8,0x1b0};w.image[offsets[i]]=1;
        memcpy(&before,&r,sizeof r);CHECK(vn135_work_storage_stale_snapshot(&w,17,0,1,1,v,900,&r)==-2);CHECK(!memcmp(&r,&before,sizeof r));w.image[offsets[i]]=0;
    }
    vn135_pool_gate_snapshot g={1,1,1,1,0};int unusable=77;
    CHECK(!vn135_pool_unusable_legacy(&g,&unusable));CHECK(unusable==0);
    CHECK(vn135_pool_unusable_legacy(NULL,&unusable)==-2);CHECK(unusable==0);
    CHECK(vn135_pool_unusable_legacy(&g,NULL)==-2);
    printf("Stage14 native snapshot/expiry/guard checks PASS: %u assertions\n",checks);
    return 0;
}
