/* SPDX-License-Identifier: GPL-3.0-only
 * Original 0xd19b0, d19f0, d1bb0, d1de0, d1df0, d20ac, d212c, d2144.
 * Pointer-based original state is represented by element indices here.
 * New guards bound sizes and reject uninitialized/corrupt state; no fake success.
 */
#include "xminer/recovery/nonce_fifo.h"
static int valid(const vn135_fifo *q) {
    return q && q->storage && q->capacity && q->element_size &&
        q->capacity <= UINT32_MAX/q->element_size &&
        q->capacity <= SIZE_MAX/q->element_size &&
        q->count<=q->capacity && q->write_index<q->capacity && q->read_index<q->capacity &&
        ((uint64_t)q->read_index+q->count)%q->capacity==q->write_index;
}
static void copy_bytes(uint8_t *d,const uint8_t *s,size_t n) { for(size_t i=0;i<n;i++)d[i]=s[i]; }
int vn135_fifo_init(vn135_fifo *q,uint32_t cap,uint32_t stride,const vn135_fifo_memory *m) {
    if(!q||q->storage||!m||!m->allocate||!m->release||!cap||!stride||
       cap>UINT32_MAX/stride||cap>SIZE_MAX/stride)return VN135_FIFO_INVALID;
    uint8_t *p=m->allocate(m->context,(size_t)cap*stride);
    if(!p)return VN135_FIFO_NOMEM;
    *q=(vn135_fifo){p,cap,stride,0,0,0};return VN135_FIFO_OK;
}
int vn135_fifo_push(vn135_fifo *q,const void *element) {
    if(!valid(q)||!element)return VN135_FIFO_INVALID;
    if(q->count==q->capacity)return 0;
    copy_bytes(q->storage+(size_t)q->write_index*q->element_size,element,q->element_size);
    q->write_index++;if(q->write_index==q->capacity)q->write_index=0;
    q->count++;return 1;
}
int vn135_fifo_pop(vn135_fifo *q,void *element) {
    if(!valid(q))return VN135_FIFO_INVALID;
    if(!q->count)return 0;
    if(element)copy_bytes(element,q->storage+(size_t)q->read_index*q->element_size,q->element_size);
    q->read_index++;if(q->read_index==q->capacity)q->read_index=0;
    q->count--;return 1;
}
int vn135_fifo_is_full(const vn135_fifo *q){return q?(q->count==q->capacity):VN135_FIFO_INVALID;}
int vn135_fifo_is_empty(const vn135_fifo *q){return q?(q->count==0):VN135_FIFO_INVALID;}
int vn135_fifo_count(const vn135_fifo *q,uint32_t *out){if(!q||!out)return VN135_FIFO_INVALID;*out=q->count;return 0;}
int vn135_fifo_reset(vn135_fifo *q){if(!q)return VN135_FIFO_INVALID;q->count=q->write_index=q->read_index=0;return 0;}
int vn135_fifo_destroy(vn135_fifo *q,const vn135_fifo_memory *m){
    if(!q)return VN135_FIFO_INVALID;
    if(q->storage){if(!m||!m->release)return VN135_FIFO_INVALID;m->release(m->context,q->storage);q->storage=NULL;}
    return 0;
}
