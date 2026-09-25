/* Original unsigned comparison 0x10c1c; exact original source path unknown.
 * Integration helper, not a duplicate or replacement of upstream fulltest(). */
#include "xminer/recovery/nonce_verify.h"
static uint32_t load_le(const uint8_t *p) {
    return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);
}
int vn135_target256_check_le(const uint8_t hash[32],const uint8_t target[32]) {
    if (!hash || !target) return VN135_VERIFY_INVALID;
    for (size_t i=8;i!=0;i--) {
        uint32_t h=load_le(hash+4*(i-1)),t=load_le(target+4*(i-1));
        if (h<t) return 1;
        if (h>t) return 0;
    }
    return 1;
}
