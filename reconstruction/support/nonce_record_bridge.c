/* SPDX-License-Identifier: GPL-3.0-only
 * New explicit 68/72 bridge. Opaque tail supplied/preserved, never invented.
 */
#include "xminer/recovery/nonce_fifo.h"
_Static_assert(VN135_NONCE_CANDIDATE_DEFINED_SIZE==17*4,"candidate field contract");
_Static_assert(VN135_ORIGINAL_NONCE_QUEUE_ELEMENT_SIZE==VN135_NONCE_FIFO_RECORD_SIZE,"queue contract");
static void put(uint8_t *d,uint32_t v){for(unsigned i=0;i<4;i++)d[i]=(uint8_t)(v>>(i*8));}
static uint32_t get(const uint8_t *s){uint32_t v=0;for(unsigned i=0;i<4;i++)v|=(uint32_t)s[i]<<(i*8);return v;}
int vn135_nonce_record_pack(const vn135_nonce_candidate *c,const uint8_t tail[4],vn135_nonce_record72 *out){
    if(!c||!tail||!out)return VN135_FIFO_INVALID;
    vn135_nonce_record72 r;
    const uint32_t head[9]={c->chain_id,c->chip_id,c->core_id,c->job_word_a4,c->job_slot,c->version_word,c->job_word_70,c->job_word_74,c->nonce};
    for(unsigned i=0;i<9;i++)put(r.bytes+4*i,head[i]);
    for(unsigned i=0;i<8;i++)put(r.bytes+36+4*i,c->midstate[i]);
    for(unsigned i=0;i<4;i++)r.bytes[68+i]=tail[i];
    *out=r;return 0;
}
int vn135_nonce_record_unpack(const vn135_nonce_record72 *r,vn135_nonce_candidate *out,uint8_t tail[4]){
    if(!r||!out||!tail)return VN135_FIFO_INVALID;
    vn135_nonce_candidate c;
    c.chain_id=get(r->bytes);c.chip_id=get(r->bytes+4);c.core_id=get(r->bytes+8);
    c.job_word_a4=get(r->bytes+12);c.job_slot=get(r->bytes+16);c.version_word=get(r->bytes+20);
    c.job_word_70=get(r->bytes+24);c.job_word_74=get(r->bytes+28);c.nonce=get(r->bytes+32);
    for(unsigned i=0;i<8;i++)c.midstate[i]=get(r->bytes+36+4*i);
    for(unsigned i=0;i<4;i++)tail[i]=r->bytes[68+i];
    *out=c;return 0;
}
