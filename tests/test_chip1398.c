/* SPDX-License-Identifier: GPL-3.0-only */
#include "xminer/recovery/chip1398.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
int main(void)
{
    uint8_t p[10], crc;
    for (unsigned i=0;i<256;++i) {
        unsigned expected=0;
        for (unsigned j=0;j<8;++j) expected |= ((i>>j)&1u)<<(7-j);
        assert(vn135_bm1398_ticket_mask_word(i)==expected);
        assert(vn135_bm1398_ticket_mask_word(i | 0xabcd0000u)==expected);
    }
    for (unsigned a=0;a<16;++a) for (unsigned b=0;b<16;++b) for (unsigned c=0;c<4;++c) {
        uint32_t v=vn135_bm1398_clock_delay_word(a,b,c);
        assert(((v>>6)&3u)==(a&3u));assert(((v>>4)&3u)==(b&3u));
        assert(((v>>2)&1u)==(c&1u));assert((v&0xffffff0bu)==0x80008000u);
    }
    assert(vn135_crc5_bits(NULL,0,0,&crc)==0 && crc==31);
    assert(vn135_crc5_bits(NULL,1,1,&crc)==VN135_INVALID);
    assert(vn135_crc5_bits(p,0,1,&crc)==VN135_INVALID);
    assert(vn135_crc5_bits(p,1,9,&crc)==VN135_INVALID);
    assert(vn135_crc5_bits(p,0,0,NULL)==VN135_INVALID);
    memset(p,0xa5,sizeof p);
    assert(vn135_bm1398_set_config_packet(1,0,0x14,0x80,p,8)==VN135_INVALID);
    for (unsigned i=0;i<10;++i)assert(p[i]==0xa5);
    assert(vn135_bm1398_set_config_packet(1,0,0x14,0x80,p,9)==0);
    { const uint8_t expected[]={0x51,9,0,0x14,0,0,0,0x80,0x12};
      assert(memcmp(p,expected,9)==0); }
    assert(p[9]==0xa5);
    assert(vn135_bm1398_set_config_packet(1,0,0,0,NULL,9)==VN135_INVALID);
    assert(vn135_bm1398_misc_control_word(0xffffffffu,0)==0xffbfffffu);
    assert(vn135_bm1398_misc_control_word(0xffffffffu,1)==0x0fffffffu);
    puts("host unit tests: PASS (no hardware)");
    return 0;
}
