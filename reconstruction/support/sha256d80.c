/* New support filename. Fixed 80-byte SHA256d, not a recovered general SHA API.
 * Original 0x2d994 and SHA 0x108f38 serve as differential references.
 * Leaves upstream sha2.c unchanged. No allocation, libc, I/O or mutable globals. */
#include "xminer/recovery/nonce_verify.h"
#include "xminer/recovery/sha256_midstate.h"
static void store_be(uint8_t *p, uint32_t v) {
    p[0]=(uint8_t)(v>>24); p[1]=(uint8_t)(v>>16);
    p[2]=(uint8_t)(v>>8); p[3]=(uint8_t)v;
}
int vn135_sha256d_header80(const uint8_t header[80], uint8_t digest[32]) {
    uint8_t tail[64]={0}, final[64]={0};
    uint32_t state[8];
    if (!header || !digest) return VN135_VERIFY_INVALID;
    /* First hash: 80 bytes => two blocks, length 640 bits. */
    if (vn135_sha256_midstate64(header,state)) return VN135_VERIFY_INVALID;
    for (size_t i=0;i<16;i++) tail[i]=header[64+i];
    tail[16]=0x80; tail[62]=0x02; tail[63]=0x80;
    if (vn135_sha256_compress_block(state,tail)) return VN135_VERIFY_INVALID;
    for (size_t i=0;i<8;i++) store_be(final+4*i,state[i]);
    /* Second hash: 32 bytes => one padded block, length 256 bits. */
    final[32]=0x80; final[62]=0x01;
    if (vn135_sha256_midstate64(final,state)) return VN135_VERIFY_INVALID;
    for (size_t i=0;i<8;i++) store_be(digest+4*i,state[i]);
    return 0;
}
