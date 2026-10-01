/* SPDX-License-Identifier: GPL-3.0-only
 * Newly authored host decision tests. Constructor callbacks only record data;
 * they do not initialize hardware or execute the original entry identities.
 */
#include "integration/transport_initialize_135.h"
#include <inttypes.h>
#include <limits.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

static unsigned cases, checks;
#define CHECK(c) do { ++checks; if (!(c)) { \
    fprintf(stderr,"FAIL line %d: %s\n",__LINE__,#c); return 1; } } while (0)
static const uint32_t sends[5] = {0x10fa38,0x11d0cc,0x117f7c,0xf8048,0x109740};
static const uint32_t initializers[8] = {
    0xd2db8,0xd8c78,0xea7c8,0xdcbe0,0xe1450,0xe60e8,0xf0560,0xf4448
};
struct output { uint32_t common; uint32_t untouched[7]; };
struct callback {
    uint32_t *send, *common;
    void *identity;
    uint32_t expected_send, expected_entry;
    int32_t status;
    unsigned calls;
    int failed, mutate;
};
static int32_t record_constructor(void *opaque,uint32_t entry,void *identity)
{
    struct callback *c=opaque;
    ++c->calls;
    if (entry!=c->expected_entry || identity!=c->identity ||
        *c->send!=c->expected_send || *c->common!=UINT32_C(0xd253c))
        c->failed=1;
    if (c->mutate) {
        *c->send=UINT32_C(0xfeed1001);
        *c->common=UINT32_C(0xfeed2002);
        ((struct output *)identity)->untouched[3]=UINT32_C(0xfeed3003);
    }
    return c->status;
}
static const struct vn135_transport_initialize_ops_135 ops={record_constructor};
static uint32_t expected_send(uint32_t platform,uint32_t subtype)
{
    return platform==0 && subtype!=0 ? UINT32_C(0x10f938):sends[platform];
}
static int valid_case(uint32_t platform,uint32_t chip,uint32_t subtype,
                      int32_t status,int mutate,int alias)
{
    uint32_t shared=UINT32_C(0x11111111);
    struct output out;
    memset(&out,0xa5,sizeof(out));
    uint32_t *send=alias?&out.common:&shared;
    void *identity=&out;
    struct callback c={send,&out.common,identity,
        alias?UINT32_C(0xd253c):expected_send(platform,subtype),
        initializers[chip],status,0,0,mutate};
    const struct vn135_transport_initialize_view_135 v={send,&out.common,identity};
    const struct vn135_transport_initialize_view_135 saved=v;
    ++cases;
    CHECK(vn135_transport_initialize_135(platform,chip,subtype,&v,&ops,&c)==status);
    CHECK(c.calls==1 && !c.failed);
    CHECK(v.shared_send_method==saved.shared_send_method &&
          v.common_method==saved.common_method && v.chip_methods==saved.chip_methods);
    CHECK(out.common==(mutate?UINT32_C(0xfeed2002):UINT32_C(0xd253c)));
    CHECK(*send==(mutate?(alias?UINT32_C(0xfeed2002):UINT32_C(0xfeed1001)):
                        c.expected_send));
    for (size_t i=0;i<7;i++)
        CHECK(out.untouched[i]==((mutate && i==3)?UINT32_C(0xfeed3003):UINT32_C(0xa5a5a5a5)));
    if (alias) CHECK(shared==UINT32_C(0x11111111));
    return 0;
}
static int invalid_platform(uint32_t platform,uint32_t chip)
{
    uint32_t send=0x11111111,common=0x22222222;
    struct callback c={0};
    const struct vn135_transport_initialize_view_135 v={&send,&common,&common};
    ++cases;
    CHECK(vn135_transport_initialize_135(platform,chip,UINT32_MAX,&v,&ops,&c)==-1);
    CHECK(send==UINT32_C(0x11111111) && common==UINT32_C(0x22222222));
    CHECK(c.calls==0);
    ++cases;
    CHECK(vn135_transport_initialize_135(platform,chip,UINT32_MAX,NULL,NULL,NULL)==-1);
    return 0;
}
static int invalid_chip(uint32_t platform,uint32_t chip,uint32_t subtype,int alias)
{
    uint32_t send=0x11111111,common=0x22222222;
    struct callback c={0};
    const struct vn135_transport_initialize_view_135 v={alias?&common:&send,&common,&common};
    ++cases;
    CHECK(vn135_transport_initialize_135(platform,chip,subtype,&v,&ops,&c)==-1);
    CHECK(c.calls==0 && common==UINT32_C(0xd253c));
    CHECK(send==(alias?UINT32_C(0x11111111):expected_send(platform,subtype)));
    /* No constructor table is required when the chip guard refuses dispatch. */
    ++cases;
    CHECK(vn135_transport_initialize_135(platform,chip,subtype,&v,NULL,NULL)==-1);
    CHECK(common==UINT32_C(0xd253c));
    return 0;
}
static int shared_selection(void)
{
    uint32_t shared=0;
    struct output a={0}, b={0};
    const struct vn135_transport_initialize_view_135 va={&shared,&a.common,&a};
    const struct vn135_transport_initialize_view_135 vb={&shared,&b.common,&b};
    struct callback ca={&shared,&a.common,&a,sends[2],initializers[4],-55,0,0,0};
    struct callback cb={&shared,&b.common,&b,sends[4],initializers[0],-66,0,0,0};
    ++cases;
    CHECK(vn135_transport_initialize_135(2,4,0,&va,&ops,&ca)==-55);
    CHECK(shared==sends[2] && a.common==UINT32_C(0xd253c));
    CHECK(vn135_transport_initialize_135(4,0,0,&vb,&ops,&cb)==-66);
    CHECK(shared==sends[4] && a.common==UINT32_C(0xd253c));
    CHECK(ca.calls==1 && cb.calls==1 && !ca.failed && !cb.failed);
    /* Explicitly selected identities are data, never branches to vendor code. */
    return 0;
}
int main(void)
{
    const uint32_t subtypes[]={0,1,2,UINT32_C(0x80000000),UINT32_MAX};
    const uint32_t bad_platforms[]={5,6,UINT32_C(0x7fffffff),UINT32_C(0x80000000),UINT32_MAX};
    const uint32_t bad_chips[]={8,9,UINT32_C(0x7fffffff),UINT32_C(0x80000000),UINT32_MAX};
    const int32_t statuses[]={0,-1,-55,1,INT32_MIN,INT32_MAX};
    for (uint32_t p=0;p<5;p++) for (uint32_t c=0;c<8;c++)
        for (size_t s=0;s<sizeof(subtypes)/sizeof(subtypes[0]);s++)
            if(valid_case(p,c,subtypes[s],-55,0,0))return 1;
    for (size_t p=0;p<sizeof(bad_platforms)/sizeof(bad_platforms[0]);p++)
        for(size_t c=0;c<sizeof(bad_chips)/sizeof(bad_chips[0]);c++)
            if(invalid_platform(bad_platforms[p],bad_chips[c]))return 1;
    for(size_t p=0;p<sizeof(bad_platforms)/sizeof(bad_platforms[0]);p++)
        for(uint32_t c=0;c<8;c++)
            if(invalid_platform(bad_platforms[p],c))return 1;
    for(uint32_t p=0;p<5;p++)
        for(size_t c=0;c<sizeof(bad_chips)/sizeof(bad_chips[0]);c++)
            for(size_t s=0;s<sizeof(subtypes)/sizeof(subtypes[0]);s++)
                if(invalid_chip(p,bad_chips[c],subtypes[s],0))return 1;
    for(uint32_t c=0;c<8;c++)
        for(size_t s=0;s<sizeof(statuses)/sizeof(statuses[0]);s++)
            for(int mutate=0;mutate<2;mutate++)
                if(valid_case(2,c,0,statuses[s],mutate,0))return 1;
    for(uint32_t p=0;p<5;p++) for(uint32_t c=0;c<8;c++)
        if(valid_case(p,c,1,-55,0,1) || valid_case(p,c,0,-55,1,1))return 1;
    for(uint32_t p=0;p<5;p++) if(invalid_chip(p,8,1,1))return 1;
    if(shared_selection())return 1;
    printf("PASS transport initializer: %u cases, %u checks\n",cases,checks);
    return 0;
}
