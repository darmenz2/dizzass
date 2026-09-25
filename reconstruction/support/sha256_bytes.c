/* SPDX-License-Identifier: GPL-3.0-only
 * New one-shot SHA adapter over the previously verified compression function.
 * No claim of original library context layout or source filename.
 * RFC 6234 section 4.1: padding/64-bit message length for SHA-256.
 */
#include "xminer/recovery/work_rebuild.h"
#include "xminer/recovery/sha256_midstate.h"
int vn135_sha256_bytes(const uint8_t *data,size_t size,uint8_t digest[32]) {
    uint32_t state[8]={0x6a09e667u,0xbb67ae85u,0x3c6ef372u,0xa54ff53au,
                       0x510e527fu,0x9b05688cu,0x1f83d9abu,0x5be0cd19u};
    uint8_t tail[128]={0};
    size_t offset=0,remaining,tail_size;
    uint64_t bits;
    if(!digest||(!data&&size)||size>UINT32_MAX)return VN135_VERIFY_INVALID;
    remaining=size;
    while(remaining>=64u){
        (void)vn135_sha256_compress_block(state,data+offset);
        offset+=64u;remaining-=64u;
    }
    for(size_t i=0;i<remaining;++i)tail[i]=data[offset+i];
    tail[remaining]=0x80u;tail_size=remaining<56u?64u:128u;
    bits=(uint64_t)size*8u;
    for(size_t i=0;i<8u;++i)tail[tail_size-1u-i]=(uint8_t)(bits>>(8u*i));
    (void)vn135_sha256_compress_block(state,tail);
    if(tail_size==128u)(void)vn135_sha256_compress_block(state,tail+64u);
    for(size_t i=0;i<8u;++i){
        digest[4u*i]=(uint8_t)(state[i]>>24);
        digest[4u*i+1u]=(uint8_t)(state[i]>>16);
        digest[4u*i+2u]=(uint8_t)(state[i]>>8);
        digest[4u*i+3u]=(uint8_t)state[i];
    }
    return 0;
}
int vn135_sha256d_bytes(const uint8_t *data,size_t size,uint8_t digest[32]) {
    uint8_t first[32];
    if(!digest)return VN135_VERIFY_INVALID;
    if(vn135_sha256_bytes(data,size,first))return VN135_VERIFY_INVALID;
    return vn135_sha256_bytes(first,32u,digest);
}
