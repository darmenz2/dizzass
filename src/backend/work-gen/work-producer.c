/* SPDX-License-Identifier: GPL-3.0-only
 * Bounded original c2498 producer batch, supplied VNish 1.3.5. */
#include "integration/work_producer_135.h"
#include "xminer/recovery/work_rebuild.h"
#include <string.h>

static void reverse_words(uint8_t *out,const uint8_t *in,uint32_t size)
{
    for(uint32_t i=0;i<size;i+=4)
        for(uint32_t j=0;j<4;++j)out[i+j]=in[i+3-j];
}
static void store_word(uint8_t *p,uint32_t x)
{
    for(uint32_t i=0;i<4;++i)p[i]=(uint8_t)(x>>(8*i));
}
static void reverse_bytes(uint8_t *p,uint32_t size)
{
    for(uint32_t i=0;i<size/2;++i){
        uint8_t x=p[i];p[i]=p[size-1-i];p[size-1-i]=x;
    }
}
void vn135_work_producer_batch_135(const struct vn135_producer_view *view,
    const struct vn135_producer_ops *ops,void *context)
{
    const struct vn135_producer_template *job=view->job;
    struct vn135_producer_ring *ring=view->ring;
    uint32_t count=ops->count(context,view->backend),iteration=0;
    uint32_t limit=count<<1;
    if(!count || count>=UINT32_C(0x80000000))return;
    do {
        uint32_t head,tail,next;
        uint8_t root[32],pair[64],*scratch;
        vn135_work_job_snapshot *row;
        (void)ops->sync(context,0x5a6108u,0x633bf0u);
        head=ring->head;tail=ring->tail;
        (void)ops->sync(context,0x5a66c4u,0x633bf0u);
        if((head+1u)%768u==tail)break;
        (void)ops->sync(context,0x5a6108u,0x633bf0u);
        head=ring->head;
        (void)ops->sync(context,0x5a66c4u,0x633bf0u);
        if((head>>8)>2u)break;
        row=&ring->rows[head];
        scratch=ops->allocate(context,job->coinbase_size);
        memcpy(scratch,job->coinbase,job->coinbase_size);
        for(uint32_t i=0;i<job->counter_size;++i)
            scratch[job->counter_offset+i]=(uint8_t)(*view->counter>>(8*i));
        (void)vn135_sha256d_bytes(scratch,job->coinbase_size,root);
        ops->release(context,scratch);
        for(uint32_t i=0;job->branch_count_bits<UINT32_C(0x80000000) && i<job->branch_count_bits;++i){
            memcpy(pair,root,32);
            memcpy(pair+32,job->branches+32u*i,32);
            (void)vn135_sha256d_bytes(pair,sizeof(pair),root);
        }
        memcpy(row->bytes,job->header_words,36);
        reverse_words(row->bytes+36,root,32);
        reverse_bytes(row->bytes,64);
        memcpy(row->bytes+68,job->header_words+40,4);
        memcpy(row->bytes+72,job->header_words+36,4);
        reverse_bytes(row->bytes+64,12);
        store_word(row->bytes+76,0);
        reverse_words(row->bytes+80,root,32);
        store_word(row->bytes+112,(uint32_t)*view->counter);
        store_word(row->bytes+116,(uint32_t)(*view->counter>>32));
        memcpy(row->bytes+120,job->header_words,4);
        memcpy(row->bytes+124,job->header_words+36,4);
        memcpy(row->bytes+128,job->header_words+40,4);
        memcpy(row->bytes+132,job->header_words+4,32);
        store_word(row->bytes+164,job->key);
        (void)ops->sync(context,0x5a6108u,0x633bf0u);
        next=ring->head+1u;
        ring->head=(next>>8)>2u?0u:next;
        (void)ops->sync(context,0x5a66c4u,0x633bf0u);
        ++*view->counter;
        ++iteration;
    }while((iteration^UINT32_C(0x80000000))<(limit^UINT32_C(0x80000000)));
}
