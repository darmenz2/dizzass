/* Pure framing/selection bounds; no device or native core. GPL-3.0-or-later. */
#include "integration/work_route.h"
#include "integration/work_tx88.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"route bounds %d: %s\n",__LINE__,#x); exit(1); \
} } while (0)
int main(void)
{
    uint8_t input[80], guarded[94], expected[88], shared[180];
    uint16_t crc=0x1234;
    enum dizzass_work_family family=(enum dizzass_work_family)99;
    unsigned i,slot,cap,offset;
    for(i=0;i<80;++i) input[i]=(uint8_t)(i*19u);
    for(slot=0;slot<32;++slot) {
        memset(guarded,0xa5,sizeof(guarded));
        CHECK(dizzass_tx88_encode_words(input,80,slot,guarded+3,88)==0);
        CHECK(guarded[7]==slot*8u);
        for(i=0;i<3;++i) CHECK(guarded[i]==0xa5&&guarded[91+i]==0xa5);
        for(i=0;i<76;++i) CHECK(guarded[13+i]==input[75-i]);
    }
    for(cap=0;cap<88;++cap) {
        memset(guarded,0xa5,sizeof(guarded));
        CHECK(dizzass_tx88_encode_words(input,80,3,guarded+3,cap)==DIZZASS_TX88_CAPACITY);
        for(i=0;i<94;++i) CHECK(guarded[i]==0xa5);
    }
    CHECK(dizzass_tx88_encode_words(input,80,3,expected,88)==0);
    /* Both overlap directions, including exactly the same input/output. */
    for(offset=0;offset<81;++offset) {
        memset(shared,0xa5,sizeof(shared));memcpy(shared+40,input,80);
        CHECK(dizzass_tx88_encode_words(shared+40,80,3,shared+offset,88)==0);
        CHECK(!memcmp(shared+offset,expected,88));
    }
    memset(guarded,0xa5,sizeof(guarded));
    CHECK(dizzass_tx88_encode_words(NULL,80,1,guarded,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(input,79,1,guarded,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(input,81,1,guarded,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(input,80,32,guarded,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(input,80,UINT32_MAX,guarded,88)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_encode_words(input,80,1,NULL,88)==DIZZASS_TX88_INVALID);
    for(i=0;i<94;++i) CHECK(guarded[i]==0xa5);
    CHECK(dizzass_tx88_crc16(NULL,1,0xffff,&crc)==DIZZASS_TX88_INVALID&&crc==0x1234);
    CHECK(dizzass_tx88_crc16(NULL,0,0xffff,&crc)==0&&crc==0xffff);
    CHECK(dizzass_tx88_crc16(input,80,0xffff,NULL)==DIZZASS_TX88_INVALID);
    CHECK(dizzass_tx88_crc16((const uint8_t *)"123456789",9,0xffff,&crc)==0&&crc==0x29b1);
    CHECK(dizzass_work_route_select(2,0,&family)==0&&family==DIZZASS_WORK_SHA256_TX88);
    CHECK(dizzass_work_route_select(0,0,&family)==0&&family==DIZZASS_WORK_SHA256_PLATFORM0);
    CHECK(dizzass_work_route_select(2,1,&family)==0&&family==DIZZASS_WORK_SCRYPT_TX86);
    CHECK(dizzass_work_route_select(2,2,&family)==DIZZASS_ROUTE_UNSUPPORTED&&family==DIZZASS_WORK_SCRYPT_TX86);
    CHECK(dizzass_work_route_select(UINT32_MAX,0,&family)==DIZZASS_ROUTE_UNSUPPORTED);
    CHECK(dizzass_work_route_select(2,0,NULL)==DIZZASS_ROUTE_INVALID);
    printf("WORK_ROUTE_BOUNDS_PASS checks=%u\n",checks);
    return 0;
}
