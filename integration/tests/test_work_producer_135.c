/* SPDX-License-Identifier: GPL-3.0-only
 * Bounds, callback ownership and independent field-layout checks. */
#include "integration/work_producer_135.h"
#include "xminer/recovery/work_rebuild.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned long checks,cases;
#define CHECK(x) do{++checks;if(!(x)){fprintf(stderr,"line %d: %s\n",__LINE__,#x);exit(1);}}while(0)
struct test {
    struct vn135_producer_template job;
    struct vn135_producer_ring ring;
    struct vn135_producer_view view;
    uint64_t counter,start;
    uint32_t count,phase,completed,allocated,mutation;
    uint8_t coin[256],branches[128],*memory,*heap;
};
static uint32_t count(void *p,void *backend){struct test *t=p;CHECK(backend==t);CHECK(t->phase==0);return t->count;}
static int32_t sync_op(void *p,uint32_t entry,uint32_t mutex){
    struct test *t=p;CHECK(mutex==0x633bf0);
    CHECK(t->phase==0 || t->phase==1 || t->phase==2 || t->phase==3 || t->phase==6 || t->phase==7);
    CHECK(entry==(t->phase%2?0x5a66c4u:0x5a6108u));CHECK(t->counter==t->start+t->completed);
    if(t->mutation==1 && !t->completed && t->phase==6)t->ring.head=766;
    if(t->mutation==2 && !t->completed && t->phase==3)t->ring.head=900;
    t->phase++;
    if(t->phase==8){t->phase=0;t->completed++;}
    return -97;
}
static uint8_t *allocate(void *p,uint32_t n){
    struct test *t=p;CHECK(t->phase++==4);CHECK(n==t->job.coinbase_size);CHECK(t->heap==NULL);
    t->heap=malloc(n+32u);CHECK(t->heap!=NULL);memset(t->heap,0xa5,n+32u);t->allocated++;return t->heap+16;
}
static void release(void *p,uint8_t *at){
    struct test *t=p;CHECK(t->phase++==5);CHECK(at==t->heap+16);
    for(unsigned i=0;i<16;++i){CHECK(t->heap[i]==0xa5);CHECK(at[t->job.coinbase_size+i]==0xa5);}
    for(unsigned i=0;i<t->job.coinbase_size;++i){
        unsigned off=t->job.counter_offset,width=t->job.counter_size;
        uint8_t expected=i>=off && i-off<width?(uint8_t)(t->counter>>(8*(i-off))):t->coin[i];
        CHECK(at[i]==expected);
    }
    free(t->heap);t->heap=NULL;
}
static const struct vn135_producer_ops ops={count,sync_op,allocate,release};
static void put(uint8_t *p,uint32_t x){for(unsigned i=0;i<4;++i)p[i]=(uint8_t)(x>>(8*i));}
static void expected(struct test *t,uint64_t counter,uint8_t out[168]){
    uint8_t coin[256],root[32],pair[64];const uint8_t *h=t->job.header_words;
    memcpy(coin,t->coin,t->job.coinbase_size);
    for(unsigned i=0;i<t->job.counter_size;++i)coin[t->job.counter_offset+i]=(uint8_t)(counter>>(8*i));
    CHECK(vn135_sha256d_bytes(coin,t->job.coinbase_size,root)==0);
    if(t->job.branch_count_bits<0x80000000u)for(unsigned i=0;i<t->job.branch_count_bits;++i){
        memcpy(pair,root,32);memcpy(pair+32,t->branches+i*32,32);CHECK(vn135_sha256d_bytes(pair,64,root)==0);
    }
    /* Independent direct layout, not the source's two in-place reversals. */
    for(unsigned i=0;i<7;++i)memcpy(out+i*4,root+24-i*4,4);
    for(unsigned i=0;i<36;++i)out[28+i]=h[35-i];
    for(unsigned i=0;i<4;++i){out[64+i]=h[39-i];out[68+i]=h[43-i];}
    memcpy(out+72,root+28,4);memset(out+76,0,4);
    for(unsigned i=0;i<32;++i)out[80+i]=root[(i&~3u)+3-(i&3u)];
    put(out+112,(uint32_t)counter);put(out+116,(uint32_t)(counter>>32));
    memcpy(out+120,h,4);memcpy(out+124,h+36,4);memcpy(out+128,h+40,4);memcpy(out+132,h+4,32);put(out+164,t->job.key);
}
static void run(uint32_t head,uint32_t tail,uint32_t n,uint64_t counter,unsigned size,unsigned width,uint32_t branches,unsigned mutation){
    struct test t;memset(&t,0,sizeof(t));t.count=n;t.start=t.counter=counter;t.mutation=mutation;
    t.memory=malloc(768u*168u+32u);CHECK(t.memory!=NULL);memset(t.memory,0xa5,768u*168u+32u);
    t.ring=(struct vn135_producer_ring){head,tail,(vn135_work_job_snapshot *)(void *)(t.memory+16)};
    for(unsigned i=0;i<sizeof(t.coin);++i)t.coin[i]=(uint8_t)(i*29+width);
    for(unsigned i=0;i<sizeof(t.branches);++i)t.branches[i]=(uint8_t)(i*37+width);
    t.job.key=0x89765432;for(unsigned i=0;i<44;++i)t.job.header_words[i]=(uint8_t)(i*17+width);
    t.job.coinbase=t.coin;t.job.coinbase_size=size;t.job.counter_offset=size-width;t.job.counter_size=width;
    t.job.branches=t.branches;t.job.branch_count_bits=branches;
    t.view=(struct vn135_producer_view){&t.job,&t.ring,&t.counter,&t};
    struct vn135_producer_template saved=t.job;uint8_t coin_before[256],branches_before[128];
    memcpy(coin_before,t.coin,256);memcpy(branches_before,t.branches,128);
    unsigned wanted=0,room=head<768 && tail<768?(tail+768-head-1)%768:0;
    if(n && n<0x80000000u && head<768){uint32_t limit=n<<1;wanted=limit>=0x80000000u?1:limit;if(wanted>room)wanted=room;}
    if(mutation==1)wanted=1;
    if(mutation==2)wanted=4;
    vn135_work_producer_batch_135(&t.view,&ops,&t);
    CHECK(t.completed==wanted && t.allocated==wanted && t.heap==NULL);CHECK(t.counter==counter+wanted);
    uint32_t final_head=mutation==1?767:mutation==2?3:head<768?(head+wanted)%768:head;
    CHECK(t.ring.head==final_head && t.ring.tail==tail);
    CHECK(memcmp(&saved,&t.job,sizeof(saved))==0);CHECK(memcmp(coin_before,t.coin,256)==0 && memcmp(branches_before,t.branches,128)==0);
    uint8_t row[168];
    for(unsigned i=0;i<wanted;++i){unsigned slot=mutation==2 && i?i-1:(head+i)%768;expected(&t,counter+i,row);CHECK(memcmp(row,t.ring.rows[slot].bytes,168)==0);memset(t.ring.rows[slot].bytes,0xa5,168);}
    for(unsigned i=0;i<768u*168u+32u;++i)CHECK(t.memory[i]==0xa5);
    free(t.memory);++cases;
}
int main(void){
    for(unsigned h=0;h<768;++h)run(h,(h+3)%768,2,UINT64_MAX-1,73,8,1,0);
    const uint32_t counts[]={0,1,2,0x3fffffffu,0x40000000u,0x7fffffffu,0x80000000u,UINT32_MAX};
    for(unsigned i=0;i<sizeof(counts)/sizeof(counts[0]);++i)run(765,1,counts[i],0xffffffffu,8,8,0,0);
    for(unsigned size=0;size<=129;++size)for(unsigned width=0;width<=8 && width<=size;++width)run(40,0,1,UINT64_MAX,size,width,size%4,0);
    for(unsigned i=0;i<3;++i){run(767,0,2,99,1,0,0,0);run(768+i,0,2,99,1,0,0,0);}
    run(40,0,2,UINT64_MAX,73,8,2,1);run(40,0,2,UINT64_MAX,73,8,2,2);
    run(40,0,1,0,73,8,UINT32_MAX,0);
    printf("WORK_PRODUCER_NATIVE_PASS cases=%lu checks=%lu\n",cases,checks);return 0;
}
