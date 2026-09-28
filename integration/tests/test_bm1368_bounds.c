/* Standalone bounds, arithmetic and mutation tests. GPL-3.0-or-later. */
#include "integration/bm1368_nonce.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"bm1368 bounds failed at %d: %s\n",__LINE__,#x); exit(1); \
} } while (0)
int main(void)
{
    struct guarded { uint32_t before; struct dizzass_bm1368_location out; uint32_t after; } g;
    uint32_t count, bit, core;
    for (count=1; count<=256; ++count) {
        for (bit=0; bit<32; ++bit) {
            uint32_t nonce=UINT32_C(1)<<bit;
            uint64_t field=(nonce>>9)&UINT32_C(0xffff);
            g.before=UINT32_C(0x12345678); g.after=UINT32_C(0x87654321);
            CHECK(dizzass_bm1368_locate(4,count,nonce,&g.out)==0);
            CHECK(g.out.chip==(field*count)/65536 && g.out.chip<count);
            CHECK(g.out.core==nonce/UINT32_C(0x2000000));
            CHECK(g.before==UINT32_C(0x12345678) && g.after==UINT32_C(0x87654321));
        }
    }
    for (core=0; core<128; ++core) {
        CHECK(dizzass_bm1368_locate(4,108,(core<<25)|UINT32_C(0x1ffffff),&g.out)==0);
        CHECK(g.out.chip==107 && g.out.core==core);
    }
    for (bit=0; bit<9; ++bit) if (bit!=4) {
        struct dizzass_bm1368_location saved={11,22};g.out=saved;
        CHECK(dizzass_bm1368_locate(bit,108,0,&g.out)==DIZZASS_BM1368_UNSUPPORTED);
        CHECK(!memcmp(&g.out,&saved,sizeof(saved)));
    }
    {
        const uint32_t bad_counts[]={0,257,UINT32_MAX};
        size_t i;
        for (i=0;i<sizeof(bad_counts)/sizeof(bad_counts[0]);++i) {
            struct dizzass_bm1368_location saved={33,44};g.out=saved;
            CHECK(dizzass_bm1368_locate(4,bad_counts[i],0,&g.out)==DIZZASS_BM1368_INVALID);
            CHECK(!memcmp(&g.out,&saved,sizeof(saved)));
        }
    }
    CHECK(dizzass_bm1368_locate(4,108,0,NULL)==DIZZASS_BM1368_INVALID);
    printf("BM1368_BOUNDS_PASS checks=%u\n",checks);
    return 0;
}
