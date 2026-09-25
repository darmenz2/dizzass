/* New integration and guard tests, not physical-device or vendor-runtime tests. */
#include "xminer/recovery/work_nonce.h"
#include "xminer/recovery/sha256_midstate.h"
#include "xminer/recovery/chip1398.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

typedef struct { unsigned calls,reads; uint32_t nonce,slot; int lookup; } ctx_t;
static uint32_t chipfn(void *p,uint32_t n){ctx_t *c=p;assert(c->calls==0);c->nonce=n;c->calls++;return 7;}
static uint32_t corefn(void *p,uint32_t n){ctx_t *c=p;assert(c->calls==1&&n==c->nonce);c->calls++;return 9;}
static int reader(void *p,uint32_t slot,vn135_work_job_snapshot *out){
    ctx_t *c=p;c->reads++;c->slot=slot;
    if(c->lookup==1)for(unsigned i=0;i<168;++i)out->bytes[i]=(uint8_t)i;
    return c->lookup;
}
static void set_be(uint8_t *p,uint32_t x){p[0]=(uint8_t)(x>>24);p[1]=(uint8_t)(x>>16);p[2]=(uint8_t)(x>>8);p[3]=(uint8_t)x;}
int main(void)
{
    uint8_t block[64]={0};uint32_t state[8],bits=0;
    static const uint32_t abc[8]={0xba7816bf,0x8f01cfea,0x414140de,0x5dae2223,0xb00361a3,0x96177a9c,0xb410ff61,0xf20015ad};
    block[0]='a';block[1]='b';block[2]='c';block[3]=0x80;block[63]=24;
    assert(vn135_sha256_midstate64(block,state)==0);assert(!memcmp(state,abc,sizeof abc));
    assert(vn135_sha256_midstate64(NULL,state)==-2&&!memcmp(state,abc,sizeof abc));
    assert(vn135_sha256_compress_block(state,NULL)==-2&&!memcmp(state,abc,sizeof abc));
    assert(vn135_sha256_midstate64(block,NULL)==-2);
    ctx_t context={0,0,0,0,1};vn135_nonce_attribution ops={&context,chipfn,corefn};
    vn135_work_job_reader jobs={&context,reader};vn135_work_job_snapshot job;
    for(unsigned i=0;i<168;++i)job.bytes[i]=(uint8_t)i;
    uint8_t payload[9]={0,1,2,3,4,5,6,7,8};
    vn135_work_nonce_result out,old;
    memset(&out,0xa5,sizeof out);old=out;
    assert(vn135_work_nonce_prepare(2,3,3,payload,9,&job,&ops,&out)==-2);
    assert(!memcmp(&out,&old,sizeof out)&&context.calls==0);
    assert(vn135_work_nonce_prepare(2,2,3,payload,8,&job,&ops,&out)==-2);
    assert(vn135_work_nonce_prepare(2,2,3,NULL,9,&job,&ops,&out)==-2);
    assert(vn135_work_nonce_prepare(2,2,3,payload,9,NULL,&ops,&out)==-2);
    assert(vn135_work_nonce_prepare(2,2,3,payload,9,&job,NULL,&out)==-2);
    assert(vn135_work_nonce_prepare(2,2,3,payload,9,&job,&ops,NULL)==-2);
    vn135_nonce_attribution broken={&context,chipfn,NULL};
    assert(vn135_work_nonce_prepare(2,2,3,payload,9,&job,&broken,&out)==-2);
    assert(!memcmp(&out,&old,sizeof out)&&context.calls==0);
    assert(vn135_work_nonce_version_bits(0,payload,7,&bits)==0&&bits==0xe0ff1fu);
    assert(vn135_work_nonce_version_bits(1,payload,8,&bits)==0&&bits==0xe0ff1fu);
    assert(vn135_work_nonce_version_bits(2,payload,9,&bits)==0&&bits==0xe0c000u);
    assert(vn135_work_nonce_version_bits(2,NULL,9,&bits)==-2&&bits==0xe0c000u);
    assert(vn135_work_nonce_prepare(2,2,3,payload,9,&job,&ops,&out)==0);
    static const uint32_t want[17]={3,7,9,2812716452u,0,2080045432u,1936879984u,2004252020u,66051,
          837076293,2986030553u,3835568078u,3925925976u,382719371,3983599598u,2309560156u,2009331404};
    assert(!memcmp(&out.candidate,want,sizeof want));assert(context.calls==2);
    assert(vn135_bm1398_core_from_nonce(0x1398,0xabffffff)==0xab);
    assert(vn135_bm1398_core_from_nonce(0x1397,0xffffffff)==1023);
    assert(vn135_bm1398_core_from_nonce(0x1368,0xffffffff)==0);
    unsigned streams=0;
    for(unsigned board=0;board<2;++board)for(unsigned chip=0;chip<8;++chip)for(size_t chunk=1;chunk<=11;++chunk){
        vn135_work_rx_stream stream;vn135_work_rx_message message={0};
        assert(vn135_work_rx_stream_init(&stream,3,board,chip,0)==0);
        uint8_t frame[11]={0xaa,0x55,0,1,2,3,4,5,6,7,8};
        size_t len=stream.policy.frame_size,offset=0;frame[len-1]|=0x80;
        context.calls=context.reads=0;context.lookup=1;
        int rc=0;
        while(offset<len){size_t n=len-offset,used=0;if(n>chunk)n=chunk;
            rc=vn135_work_rx_stream_feed(&stream,frame+offset,n,&used,&message);
            assert(used>0&&used<=n);offset+=used;
            assert(rc==(offset<len?VN135_RX_NEED_MORE:VN135_RX_NONCE_RAW));
        }
        assert(rc==VN135_RX_NONCE_RAW);
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==0);
        assert(context.calls==2&&context.reads==1&&context.slot==message.job_slot);
        assert(out.candidate.chain_id==3&&out.candidate.job_slot==message.job_slot);
        vn135_work_nonce_result direct;context.calls=0;
        assert(vn135_work_nonce_prepare(chip,stream.policy.variant,3,message.payload,message.payload_size,&job,&ops,&direct)==0);
        assert(!memcmp(&out,&direct,sizeof out));++streams;
        old=out;context.calls=context.reads=0;context.lookup=0;
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==VN135_NONCE_NO_JOB);
        assert(context.reads==1&&context.calls==0&&!memcmp(&out,&old,sizeof out));
        context.lookup=-1;context.reads=0;
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==VN135_NONCE_LOOKUP_FAILED);
        assert(context.reads==1&&context.calls==0&&!memcmp(&out,&old,sizeof out));
        context.lookup=2;
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==VN135_NONCE_LOOKUP_FAILED);
        context.lookup=1;context.reads=0;message.job_slot^=1;
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==VN135_NONCE_INVALID);
        assert(context.reads==0&&context.calls==0&&!memcmp(&out,&old,sizeof out));
        message.job_slot^=1;message.kind=VN135_RX_REGISTER;
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==VN135_NONCE_INVALID);
        message.kind=VN135_RX_NONCE_RAW;message.payload_size=99;
        assert(vn135_work_nonce_from_rx(&stream.policy,&message,&jobs,&ops,&out)==VN135_NONCE_INVALID);
    }
    /* Additional empty-message KAT through an explicit standard padding block. */
    memset(block,0,sizeof block);block[0]=0x80;
    assert(vn135_sha256_midstate64(block,state)==0);
    uint8_t digest[32];for(unsigned i=0;i<8;++i)set_be(digest+4*i,state[i]);
    const uint8_t empty[32]={0xe3,0xb0,0xc4,0x42,0x98,0xfc,0x1c,0x14,0x9a,0xfb,0xf4,0xc8,0x99,0x6f,0xb9,0x24,0x27,0xae,0x41,0xe4,0x64,0x9b,0x93,0x4c,0xa4,0x95,0x99,0x1b,0x78,0x52,0xb8,0x55};
    assert(!memcmp(digest,empty,sizeof empty));
    printf("Stage7 native: SHA KATs, candidate fixture, guards, %u fragment streams and lookup failure cases PASS\n",streams);
    return 0;
}
