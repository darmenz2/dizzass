#include "xminer/recovery/work_rx.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

static void same(const vn135_work_rx_message *a, const vn135_work_rx_message *b)
{
    assert(a->kind == b->kind && a->consumed == b->consumed);
    assert(a->payload_size == b->payload_size && a->chain_id == b->chain_id);
    assert(a->register_value == b->register_value && a->chip_address == b->chip_address);
    assert(a->register_address == b->register_address && a->crc5_field == b->crc5_field);
    assert(a->job_slot == b->job_slot);
    assert(memcmp(a->payload,b->payload,sizeof(a->payload)) == 0);
}
static uint32_t random32(uint32_t *s)
{ *s ^= *s << 13; *s ^= *s >> 17; *s ^= *s << 5; return *s; }
static void errors(void)
{
    vn135_work_rx_policy p, bad;
    vn135_work_rx_message message, before;
    vn135_work_rx_stream s, old;
    uint8_t data[16]={0};uint32_t slot=123;
    size_t n=987;
    memset(&message,0xa5,sizeof(message));before=message;
    assert(vn135_work_rx_policy_init(NULL,0,0,0)==-2);
    assert(vn135_work_rx_policy_init(&p,1,2,0)==0);
    assert(vn135_work_rx_next(NULL,0,data,11,&message)==-2);
    assert(vn135_work_rx_next(&p,0,NULL,11,&message)==-2);
    assert(vn135_work_rx_next(&p,0,data,11,NULL)==-2);
    assert(memcmp(&message,&before,sizeof(message))==0);
    bad=p;bad.frame_size=UINT32_MAX;
    assert(vn135_work_rx_next(&bad,0,data,11,&message)==-2);
    bad=p;bad.payload_size=0;
    assert(vn135_work_rx_next(&bad,0,data,11,&message)==-2);
    bad=p;bad.variant=3;
    assert(vn135_work_rx_next(&bad,0,data,11,&message)==-2);
    assert(memcmp(&message,&before,sizeof(message))==0);
    assert(vn135_work_rx_job_slot(2,3,data,sizeof(data),&slot)==-2 && slot==123);
    assert(vn135_work_rx_job_slot(2,2,data,8,&slot)==-2 && slot==123);
    assert(vn135_work_rx_job_slot(2,0,NULL,7,&slot)==-2);
    assert(vn135_work_rx_job_slot(2,0,data,7,NULL)==-2);
    assert(vn135_work_rx_stream_init(NULL,0,0,0,0)==-2);
    assert(vn135_work_rx_stream_init(&s,1,1,2,0)==0);
    old=s;
    assert(vn135_work_rx_stream_feed(&s,NULL,1,&n,&message)==-2 && n==987);
    assert(memcmp(&s,&old,sizeof(s))==0 && memcmp(&message,&before,sizeof(message))==0);
    s.used=11;old=s;
    assert(vn135_work_rx_stream_feed(&s,data,1,&n,&message)==-2);
    assert(memcmp(&s,&old,sizeof(s))==0);
    s.used=0;s.policy.variant=999;old=s;
    assert(vn135_work_rx_stream_feed(&s,data,1,&n,&message)==-2);
    assert(memcmp(&s,&old,sizeof(s))==0 && n==987);
}
int main(void)
{
    const uint32_t cases[][3]={{0,0,0},{4,6,0},{1,7,0},{1,2,0},{1,4,0},{1,5,0},
                              {1,7,1},{1,2,1},{0,0,1},{1,UINT32_MAX,0}};
    uint32_t seed=0x1350606u;unsigned checked=0;
    errors();
    for (size_t c=0;c<sizeof(cases)/sizeof(cases[0]);++c) {
        vn135_work_rx_policy p;
        assert(vn135_work_rx_policy_init(&p,cases[c][0],cases[c][1],cases[c][2])==0);
        for (unsigned iteration=0;iteration<30;++iteration) {
            uint8_t input[1024];size_t pos=0;
            /* Mixture of complete random frames, noise, overlap, and short tail. */
            for (size_t i=0;i<sizeof(input);++i) input[i]=(uint8_t)random32(&seed);
            for (size_t i=0;i+11<sizeof(input);i+=37) {input[i]=0xaa;input[i+1]=0x55;}
            input[53]=0xaa;input[54]=0xaa;input[55]=0x55;
            vn135_work_rx_message expected[1024];size_t count=0;
            while(pos<sizeof(input)) {
                int rc=vn135_work_rx_next(&p,17,input+pos,sizeof(input)-pos,&expected[count]);
                assert(rc>=0);if(rc==0)break;
                assert(expected[count].consumed>0);pos+=expected[count].consumed;++count;
            }
            for (size_t fragment=1;fragment<=23;fragment+=2) {
                vn135_work_rx_stream stream;size_t at=0,seen=0;
                assert(vn135_work_rx_stream_init(&stream,17,cases[c][0],cases[c][1],cases[c][2])==0);
                while(at<sizeof(input)) {
                    size_t n=sizeof(input)-at;if(n>fragment)n=fragment;
                    vn135_work_rx_message got;size_t taken=999;
                    int rc=vn135_work_rx_stream_feed(&stream,input+at,n,&taken,&got);
                    assert(rc>=0 && taken>0 && taken<=n);at+=taken;
                    assert(stream.used<stream.policy.frame_size);
                    if(rc>0) {assert(seen<count);same(&got,&expected[seen++]);}
                }
                assert(seen==count && stream.used==sizeof(input)-pos);
                assert(memcmp(stream.pending,input+pos,stream.used)==0);
                vn135_work_rx_message empty;size_t used=12;
                assert(vn135_work_rx_stream_feed(&stream,NULL,0,&used,&empty)==0 && used==0);
                ++checked;
            }
        }
    }
    printf("Stage 6 C safety and stream chunk-invariance: PASS (%u stream replays)\n",checked);
    return 0;
}
