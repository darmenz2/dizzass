/* SPDX-License-Identifier: GPL-3.0-only
 * Tests current tracked pure codecs. Does not call any transport or reset. */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "integration/work_tx88.h"
#include "integration/bm1368_control.h"
#include "xminer/recovery/chip1398.h"
#include "selftest.h"
#include "vectors.h"
#define CHECK(x) do { ++*checks; if(!(x)) return *checks; } while(0)
unsigned diag_selftest(unsigned *checks)
{
    uint8_t src[80], before[80], expected[88], out[96];
    uint16_t crc=0;
    *checks=0;
    CHECK(sizeof(uint32_t)==4 && sizeof(uint64_t)==8);
    uint32_t endian=1;
    CHECK(*(const unsigned char *)&endian==1);
    CHECK(!dizzass_tx88_crc16((const uint8_t *)"123456789",9,0xffff,&crc) && crc==0x29b1);
    CHECK(!dizzass_tx88_crc16(NULL,0,0x1234,&crc) && crc==0x1234);
    CHECK(dizzass_tx88_crc16(NULL,1,0,&crc)==DIZZASS_TX88_INVALID && crc==0x1234);
    CHECK(dizzass_tx88_crc16(src,0,0,NULL)==DIZZASS_TX88_INVALID);
    for(unsigned i=0;i<80;++i) src[i]=(uint8_t)i;
    memcpy(before,src,80);
    for(unsigned slot=0;slot<32;++slot) {
        memset(out,0xa5,sizeof out); memcpy(expected,d01_tx0,88);
        expected[4]=d01_slots[slot][0];
        expected[86]=d01_slots[slot][1]; expected[87]=d01_slots[slot][2];
        CHECK(!dizzass_tx88_encode_words(src,80,slot,out+4,88));
        CHECK(!memcmp(expected,out+4,88) && !memcmp(before,src,80));
        CHECK(out[0]==0xa5 && out[3]==0xa5 && out[92]==0xa5 && out[95]==0xa5);
    }
    const uint32_t invalid_slots[]={32,255,256,UINT32_MAX};
    for(unsigned i=0;i<4;++i) {
        memset(out,0xa5,sizeof out);
        CHECK(dizzass_tx88_encode_words(src,80,invalid_slots[i],out,88)==DIZZASS_TX88_INVALID);
        for(unsigned j=0;j<sizeof out;++j) CHECK(out[j]==0xa5);
    }
    memset(out,0xa5,sizeof out);
    CHECK(dizzass_tx88_encode_words(src,80,0,out,87)==DIZZASS_TX88_CAPACITY);
    CHECK(dizzass_tx88_encode_words(src,79,0,out,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(NULL,80,0,out,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(src,80,0,NULL,88)==DIZZASS_TX88_INVALID);
    for(unsigned j=0;j<sizeof out;++j) CHECK(out[j]==0xa5);
    /* Overlap is an explicit encoder contract, not a native work overlay. */
    memcpy(out,src,80);
    CHECK(!dizzass_tx88_encode_words(out,80,0,out,88) && !memcmp(out,d01_tx0,88));
    for(unsigned i=76;i<80;++i) src[i]^=0xff;
    CHECK(!dizzass_tx88_encode_words(src,80,0,out,88) && !memcmp(out,d01_tx0,88));
    for(unsigned i=0;i<sizeof d01_commands/sizeof d01_commands[0];++i) {
        const struct d01_command_vector *v=&d01_commands[i];
        size_t n=999; memset(out,0xa5,sizeof out);
        CHECK(!dizzass_bm1368_command_encode((enum dizzass_bm1368_command)v->cmd,
            v->broadcast,v->address,v->reg,v->value,out+4,88,&n));
        CHECK(n==v->length && !memcmp(out+4,v->packet,n));
        CHECK(out[3]==0xa5 && out[4+n]==0xa5 && out[95]==0xa5);
        memset(out,0xa5,sizeof out); n=999;
        CHECK(dizzass_bm1368_command_encode((enum dizzass_bm1368_command)v->cmd,
            v->broadcast,v->address,v->reg,v->value,out, v->length-1,&n)==DIZZASS_CONTROL_NO_SPACE);
        CHECK(n==999);
        for(unsigned j=0;j<sizeof out;++j) CHECK(out[j]==0xa5);
    }
    for(unsigned i=0;i<6;++i) {
        memset(out,0xa5,sizeof out); size_t n=999;
        CHECK(dizzass_bm1368_command_encode((enum dizzass_bm1368_command)(i==0?4:3),
            i==1?2:0,i==2?256:0,i==3?256:0,0,i==4?NULL:out,88,i==5?NULL:&n)==
            (i<=5?DIZZASS_CONTROL_INVALID:0));
        if(i<=5) { CHECK(n==999); for(unsigned j=0;j<sizeof out;++j) CHECK(out[j]==0xa5); }
    }
    const uint32_t bad_commands[5][5]={
        {0,0,1,0,0},{1,1,0,0,0},{1,0,1,1,0},{1,0,1,0,1},{2,0,0,0,1}
    };
    for(unsigned i=0;i<5;++i) {
        const uint32_t *v=bad_commands[i]; size_t n=999;
        memset(out,0xa5,sizeof out);
        CHECK(dizzass_bm1368_command_encode((enum dizzass_bm1368_command)v[0],
            v[1],v[2],v[3],v[4],out,88,&n)==DIZZASS_CONTROL_INVALID && n==999);
        for(unsigned j=0;j<sizeof out;++j) CHECK(out[j]==0xa5);
    }
    uint8_t c5=0;
    CHECK(!vn135_crc5_bits(NULL,0,0,&c5) && c5==31);
    CHECK(vn135_crc5_bits(NULL,1,1,&c5)==VN135_INVALID && c5==31);
    CHECK(vn135_crc5_bits(src,1,9,&c5)==VN135_INVALID && c5==31);
    CHECK(vn135_crc5_bits(src,80,640,NULL)==VN135_INVALID);
    return 0;
}
