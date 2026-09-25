/* SPDX-License-Identifier: GPL-3.0-only
 * Original queue wrappers 0xfa5a4..0xfaa24; exact original filename unknown.
 * Explicit lifetime/context and checked callback errors are new integration API.
 */
#include "xminer/recovery/nonce_fifo.h"
static int ready(const vn135_nonce_fifo *q,const vn135_fifo_sync *s){
    return q&&q->ready==1&&q->ring.storage&&q->ring.capacity==VN135_NONCE_FIFO_CAPACITY&&
        q->ring.element_size==VN135_NONCE_FIFO_RECORD_SIZE&&s&&s->lock&&s->unlock;
}
static int finish(const vn135_fifo_sync *s,int rc){return s->unlock(s->context)?VN135_FIFO_SYNC_ERROR:rc;}
int vn135_nonce_fifo_init(vn135_nonce_fifo *q,const vn135_fifo_memory *m,const vn135_fifo_sync *s){
    if(!q||q->ready||q->ring.storage||!m||!m->allocate||!m->release||!s||!s->initialize||!s->destroy||!s->lock||!s->unlock)return VN135_FIFO_INVALID;
    if(s->initialize(s->context))return VN135_FIFO_SYNC_ERROR;
    int rc=vn135_fifo_init(&q->ring,VN135_NONCE_FIFO_CAPACITY,VN135_NONCE_FIFO_RECORD_SIZE,m);
    if(rc){int e=s->destroy(s->context);return e?VN135_FIFO_SYNC_ERROR:rc;}
    q->ready=1;return 0;
}
int vn135_nonce_fifo_push(vn135_nonce_fifo *q,const vn135_nonce_record72 *r,const vn135_fifo_sync *s,uint32_t *dropped){
    if(!ready(q,s)||!r)return VN135_FIFO_INVALID;
    if(s->lock(s->context))return VN135_FIFO_SYNC_ERROR;
    int full=vn135_fifo_is_full(&q->ring);
    if(full){int rc=vn135_fifo_pop(&q->ring,NULL);if(rc!=1)return finish(s,VN135_FIFO_INVALID);}
    int rc=vn135_fifo_push(&q->ring,r->bytes);
    if(rc==1){q->push_word++;if(dropped)*dropped=(uint32_t)full;}
    return finish(s,rc==1?0:VN135_FIFO_INVALID);
}
int vn135_nonce_fifo_pop(vn135_nonce_fifo *q,vn135_nonce_record72 *r,const vn135_fifo_sync *s){
    if(!ready(q,s))return VN135_FIFO_INVALID;
    if(s->lock(s->context))return VN135_FIFO_SYNC_ERROR;
    int rc=vn135_fifo_pop(&q->ring,r?r->bytes:NULL);return finish(s,rc);
}
int vn135_nonce_fifo_is_empty(vn135_nonce_fifo *q,const vn135_fifo_sync *s){
    if(!ready(q,s))return VN135_FIFO_INVALID;
    if(s->lock(s->context))return VN135_FIFO_SYNC_ERROR;
    int rc=vn135_fifo_is_empty(&q->ring);return finish(s,rc);
}
int vn135_nonce_fifo_is_full(vn135_nonce_fifo *q,const vn135_fifo_sync *s){
    if(!ready(q,s))return VN135_FIFO_INVALID;
    if(s->lock(s->context))return VN135_FIFO_SYNC_ERROR;
    int rc=vn135_fifo_is_full(&q->ring);return finish(s,rc);
}
int vn135_nonce_fifo_reset(vn135_nonce_fifo *q,const vn135_fifo_sync *s){
    if(!ready(q,s))return VN135_FIFO_INVALID;
    if(s->lock(s->context))return VN135_FIFO_SYNC_ERROR;
    int rc=vn135_fifo_reset(&q->ring);return finish(s,rc);
}
int vn135_nonce_fifo_destroy(vn135_nonce_fifo *q,const vn135_fifo_memory *m,const vn135_fifo_sync *s){
    if(!q||!m||!m->release||!s||!s->destroy)return VN135_FIFO_INVALID;
    if(!q->ready)return q->ring.storage?VN135_FIFO_INVALID:0;
    int rc=vn135_fifo_destroy(&q->ring,m);if(rc)return rc;
    int e=s->destroy(s->context);q->ready=0;return e?VN135_FIFO_SYNC_ERROR:0;
}
