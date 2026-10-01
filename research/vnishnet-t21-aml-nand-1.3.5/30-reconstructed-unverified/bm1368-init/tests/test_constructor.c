#include "integration/bm1368_initialize_135.h"
#include "integration/transport_initialize_135.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "BM1368_INIT_FAIL line=%d %s\n", __LINE__, #x); exit(1); \
} } while (0)

/* Independent literal fixture in ascending output-offset order. Words 0 and
 * 6 are deliberately placeholders; expected values come from caller state. */
static const uint32_t expected[56] = {
    0, 0xe1790, 0xe1798, 0xe17a0, 0xe17a8, 0xe17f0, 0, 0xe1818,
    0xe1b5c, 0xe1b64, 0xe2130, 0xe2210, 0xe249c, 0xe2808, 0xe2810, 0xe2978,
    0xe2980, 0xe2988, 0xe29c8, 0xe2a08, 0xe2a10, 0xe2a18, 0xe2d78, 0xe2e18,
    0xe2eb8, 0xe3090, 0xe3098, 0xe3290, 0xe32c0, 0xe33e0, 0xe34cc, 0xe35b4,
    0xe35c0, 0xe3728, 0xe3a1c, 0xe3bbc, 0xe3bc4, 0xe3c04, 0xe3dd8, 0xe40e8,
    0xe4198, 0xe41a0, 0xe4600, 0xe4688, 0xe4690, 0xe47b8, 0xe48fc, 0xe49bc,
    0xe49c4, 0xe49cc, 0xe49d4, 0xe49dc, 0xe49e4, 0xe49ec, 0xe4a2c, 0xe4a6c
};
struct guarded {
    uint32_t before[2], words[VN135_BM1368_METHOD_WORDS_135], after[2];
};
static void fill(struct guarded *g, uint32_t seed, unsigned pattern)
{
    size_t i;
    g->before[0] = UINT32_C(0x5aa50ff0); g->before[1] = ~seed;
    g->after[0] = seed; g->after[1] = UINT32_C(0xf00fa55a);
    for (i=0; i<56; ++i)
        g->words[i] = pattern ? seed ^ (UINT32_C(0x9e3779b9)*(uint32_t)(i+1)) : seed;
}
static void verify(const struct guarded *g, const struct guarded *before,
                   uint32_t common, int initialized)
{
    size_t i;
    CHECK(memcmp(g->before,before->before,sizeof(g->before))==0);
    CHECK(memcmp(g->after,before->after,sizeof(g->after))==0);
    for (i=0; i<56; ++i) {
        uint32_t want = i==0 ? common :
            initialized && i!=6 ? expected[i] : before->words[i];
        CHECK(g->words[i]==want);
    }
}
static void direct_cases(void)
{
    static const uint32_t seeds[] = {0,1,UINT32_MAX,UINT32_C(0x80000000),
        UINT32_C(0x55555555),UINT32_C(0xaaaaaaaa),UINT32_C(0x12345678)};
    size_t i; unsigned pattern, repeat;
    for (i=0;i<sizeof(seeds)/sizeof(seeds[0]);++i) for (pattern=0;pattern<2;++pattern) {
        struct guarded a, b, old, untouched;
        fill(&a,seeds[i],pattern); fill(&b,~seeds[i],pattern); untouched=b;
        for (repeat=0;repeat<3;++repeat) {
            old=a; ++cases;
            CHECK(vn135_bm1368_initialize_135(a.words)==0);
            verify(&a,&old,old.words[0],1);
            CHECK(memcmp(&b,&untouched,sizeof(b))==0);
            /* Verify repeated use and restoration after caller mutation. */
            if (repeat==0) { a.words[0]^=UINT32_MAX; a.words[6]^=UINT32_MAX; }
            if (repeat==1) {
                size_t k; for(k=0;k<56;++k) a.words[k]^=UINT32_C(0x31415926);
            }
        }
    }
}
struct context { uint32_t *output; unsigned calls; uint32_t selected; };
static int32_t selected_constructor(void *opaque, uint32_t entry, void *output)
{
    struct context *c=opaque;
    CHECK(output==c->output); ++c->calls; c->selected=entry;
    CHECK(c->output[0]==UINT32_C(0xd253c));
    if(entry!=UINT32_C(0xe1450)) return -55;
    return vn135_bm1368_initialize_135(c->output);
}
static void composition_cases(void)
{
    static const struct vn135_transport_initialize_ops_135 ops={selected_constructor};
    static const uint32_t sends[]={0x10fa38,0x11d0cc,0x117f7c,0xf8048,0x109740};
    static const uint32_t entries[]={0xd2db8,0xd8c78,0xea7c8,0xdcbe0,0xe1450,0xe60e8,0xf0560,0xf4448};
    static const uint32_t subtypes[]={0,1,UINT32_C(0x80000000),UINT32_MAX};
    static const uint32_t bad[]={8,UINT32_C(0x80000000),UINT32_MAX};
    uint32_t platform,chip; size_t sub,i;
    uint32_t shared=UINT32_C(0xabcdef01);
    for(platform=0;platform<5;++platform) for(sub=0;sub<4;++sub) for(chip=0;chip<8;++chip) {
        struct guarded g,old;
        struct context c={g.words,0,0};
        struct vn135_transport_initialize_view_135 v={&shared,&g.words[0],g.words};
        fill(&g,platform*16+chip,(unsigned)(sub&1));old=g;++cases;
        CHECK(vn135_transport_initialize_135(platform,chip,subtypes[sub],&v,&ops,&c)==(chip==4?0:-55));
        CHECK(c.calls==1 && c.selected==entries[chip]);
        CHECK(shared==(platform==0 && subtypes[sub]!=0 ? UINT32_C(0x10f938):sends[platform]));
        verify(&g,&old,UINT32_C(0xd253c),chip==4);
    }
    for(platform=0;platform<5;++platform) for(i=0;i<3;++i) {
        struct guarded g,old;
        struct vn135_transport_initialize_view_135 v={&shared,&g.words[0],g.words};
        fill(&g,bad[i],1);old=g;++cases;
        CHECK(vn135_transport_initialize_135(platform,bad[i],0,&v,NULL,NULL)==-1);
        CHECK(shared==sends[platform]);verify(&g,&old,UINT32_C(0xd253c),0);
    }
    for(i=0;i<3;++i) {
        struct guarded g,old;uint32_t saved=shared;
        struct context c={g.words,0,0};
        struct vn135_transport_initialize_view_135 v={&shared,&g.words[0],g.words};
        uint32_t invalid=i==0?5:bad[i];
        fill(&g,invalid,1);old=g;++cases;
        CHECK(vn135_transport_initialize_135(invalid,4,0,&v,&ops,&c)==-1);
        CHECK(c.calls==0 && shared==saved && memcmp(&g,&old,sizeof(g))==0);
        CHECK(vn135_transport_initialize_135(invalid,4,0,NULL,NULL,NULL)==-1);
    }
    /* Exact aligned alias with each output word is representable by both
     * host APIs. The constructor runs after the outer shared/common stores. */
    for(i=0;i<56;++i) {
        struct guarded g,old;
        struct context c={g.words,0,0};
        struct vn135_transport_initialize_view_135 v={&g.words[i],&g.words[0],g.words};
        uint32_t last = i==0 ? UINT32_C(0xd253c) :
            i==6 ? UINT32_C(0x117f7c) : expected[i];
        fill(&g,(uint32_t)i,1);old=g;++cases;
        CHECK(vn135_transport_initialize_135(2,4,0,&v,&ops,&c)==0);
        CHECK(c.calls==1 && c.selected==UINT32_C(0xe1450));
        if(i==6) old.words[6]=UINT32_C(0x117f7c);
        verify(&g,&old,UINT32_C(0xd253c),1);
        CHECK(g.words[i]==last);
    }
    /* Two actual output arrays retain independent identities while the outer
     * initializer replaces one explicitly shared transport selection. */
    {
        struct guarded a,b,old_a,old_b,saved_a;
        struct context ca={a.words,0,0},cb={b.words,0,0};
        struct vn135_transport_initialize_view_135 va={&shared,&a.words[0],a.words};
        struct vn135_transport_initialize_view_135 vb={&shared,&b.words[0],b.words};
        fill(&a,17,1);fill(&b,39,1);old_a=a;old_b=b;++cases;
        CHECK(vn135_transport_initialize_135(2,4,1,&va,&ops,&ca)==0); saved_a=a;
        CHECK(vn135_transport_initialize_135(0,4,1,&vb,&ops,&cb)==0);
        CHECK(shared==UINT32_C(0x10f938) && ca.calls==1 && cb.calls==1);
        verify(&a,&old_a,UINT32_C(0xd253c),1);verify(&b,&old_b,UINT32_C(0xd253c),1);
        CHECK(memcmp(&a,&saved_a,sizeof(a))==0);
    }
}
int main(void)
{
    direct_cases();composition_cases();
    printf("BM1368_INIT_PASS cases=%u checks=%u\n",cases,checks);
    return 0;
}
