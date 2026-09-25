/* Fixed-width time helpers from 0x107b0/0x1068c for their four-byte call site.
 * New path/API; original source filename is not proven. General partial decode
 * and allocator ABI are NOT exposed. See evidence/stage12/recovery-manifest.json. */
#include "xminer/recovery/work_time.h"
static int hex_nibble(uint8_t c) {
    if(c>=(uint8_t)'0'&&c<=(uint8_t)'9')return c-(uint8_t)'0';
    if(c>=(uint8_t)'a'&&c<=(uint8_t)'f')return c-(uint8_t)'a'+10;
    if(c>=(uint8_t)'A'&&c<=(uint8_t)'F')return c-(uint8_t)'A'+10;
    return -1;
}
int vn135_work_time_decode8(const uint8_t hex[8],uint32_t *value) {
    uint32_t v=0;
    if(!hex||!value)return VN135_STORAGE_INVALID;
    for(size_t i=0;i<8u;++i){
        int nibble=hex_nibble(hex[i]);
        if(nibble<0)return VN135_STORAGE_INVALID;
        v=(v<<4)|(uint32_t)nibble;
    }
    *value=v;return VN135_STORAGE_OK;
}
int vn135_work_time_encode8(uint32_t value,char hex[9]) {
    static const char alphabet[]="0123456789abcdef";
    if(!hex)return VN135_STORAGE_INVALID;
    for(size_t i=0;i<8u;++i)hex[i]=alphabet[(value>>(28u-4u*i))&15u];
    hex[8]='\0';return VN135_STORAGE_OK;
}
