/* SPDX-License-Identifier: GPL-3.0-only */
#include "integration/work_start_135.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint64_t checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"line %d: %s\n",__LINE__,#x); exit(1); } } while (0)
struct guarded { uint32_t before, value, after; };
struct test {
    struct guarded handles[3]; uint32_t expected[3], entry, seed, attr_value, *attr;
    unsigned event, creates, logs, writes, mutation;
    int failure, init_failure; int32_t error;
};
static const uint32_t fields[]={0x1060,0x1068,0x1058};
static const uint32_t entries[]={0xc4054,0,0xc4b18};
static const uint32_t prefix_entry[]={0x5a50e8,0x5a50f8,0x5a60dc,0x5a4a08,0x5a60dc,0x5a4a08,0x5a50e0};
static void check_state(struct test *t, int live)
{
    for(unsigned i=0;i<3;++i){CHECK(t->handles[i].before==0xaaaaaaaa);CHECK(t->handles[i].after==0x55555555);CHECK(t->handles[i].value==t->expected[i]);}
    if(live)CHECK(*t->attr==t->attr_value);
}
static void advance(struct test *t)
{
    if(t->mutation){t->entry=0x44000000u+t->event;}
    if(t->mutation==2){
        *t->attr=t->attr_value=0xdeed0000u+t->event;
        for(unsigned i=0;i<3;++i)t->handles[i].value=t->expected[i]=0xcafe0000u+i*64u+t->event;
    }
    ++t->event;
}
static int32_t attribute(void *p,uint32_t entry,uint32_t *attr,uint32_t value)
{
    struct test *t=p;unsigned n=t->event;CHECK(n==0 || n==1 || n==6);
    if(n==0)t->attr=attr;
    CHECK(attr==t->attr);check_state(t,1);CHECK(entry==prefix_entry[n]);CHECK(value==(n==1));
    advance(t);return t->init_failure==(int)n?t->error:0;
}
static int32_t initialize(void *p,uint32_t entry,uint32_t identity,uint32_t *attr)
{
    struct test *t=p;unsigned n=t->event;CHECK(n>=2 && n<=5);
    static const uint32_t objects[]={0x633af0,0x633b08,0x633ba8,0x633bc0};
    check_state(t,1);CHECK(entry==prefix_entry[n]);CHECK(identity==objects[n-2]);
    CHECK(attr==((n==3 || n==5)?t->attr:NULL));advance(t);
    return t->init_failure==(int)n?t->error:0;
}
static int32_t create(void *p,uint32_t field,uint32_t *handle,uint32_t attrs,uint32_t entry,void *backend)
{
    struct test *t=p;unsigned i=t->creates++;CHECK(i<3);CHECK(t->event==7+i);
    check_state(t,1);CHECK(field==fields[i]);CHECK(handle==&t->handles[i].value);CHECK(attrs==0);CHECK(backend==t);
    CHECK(entry==(i==1?t->entry:entries[i]));
    int32_t rc=(int)i==t->failure?t->error:0;advance(t);
    if(t->writes==2 || (t->writes==1 && rc==0))*handle=t->expected[i]=0xfeed0000u+i;
    return rc;
}
static void log_call(void *p,uint32_t category,uint32_t file,uint32_t function,uint32_t line,uint32_t level,uint32_t message)
{
    struct test *t=p;unsigned i=t->logs++;CHECK(t->failure>=0);CHECK(i<(t->failure==0?1u:2u));
    static const uint32_t lines[3][2]={{0x31d,0},{0x308,0x322},{0x291,0x327}};
    static const uint32_t messages[3][2]={{0x5e96d3,0},{0x5e9758,0x5e96fd},{0x5e971d,0x5e971d}};
    check_state(t,1);CHECK(category==0x5e9659);CHECK(file==0x5e962e);CHECK(function==0x5e9660);
    CHECK(line==lines[t->failure][i]);CHECK(level==1);CHECK(message==messages[t->failure][i]);advance(t);
}
int main(void)
{
    uint32_t cases=0;const int32_t errors[]={1,-1,INT32_MIN,INT32_MAX,85};
    const uint32_t seeds[]={0,1,UINT32_C(0x80000000),UINT32_MAX};
    const struct vn135_work_start_ops ops={attribute,initialize,create,log_call};
    for(int failure=-1;failure<3;++failure)
    for(unsigned e=0;e<(failure<0?1u:5u);++e)
    for(int init=-1;init<7;++init)
    for(unsigned write=0;write<3;++write)
    for(unsigned mutation=0;mutation<3;++mutation)
    for(unsigned seed=0;seed<4;++seed){
        struct test t;memset(&t,0,sizeof(t));t.failure=failure;t.init_failure=init;t.error=errors[e];
        t.writes=write;t.mutation=mutation;t.seed=t.attr_value=seeds[seed];t.entry=0xc2498;
        for(unsigned i=0;i<3;++i){t.handles[i].before=0xaaaaaaaa;t.handles[i].after=0x55555555;t.handles[i].value=t.expected[i]=0xbaba0000u+i;}
        const struct vn135_work_start_view view={&t,&t.handles[0].value,&t.handles[1].value,&t.handles[2].value,&t.entry,t.seed};
        int32_t rc=vn135_work_start_135(&view,&ops,&t);
        CHECK(rc==(failure<0?0:-1));CHECK(t.creates==(failure<0?3u:(unsigned)failure+1u));
        CHECK(t.logs==(failure<0?0u:(failure==0?1u:2u)));CHECK(t.event==7+t.creates+t.logs);
        check_state(&t,0);++cases;
    }
    printf("WORK_START_NATIVE_PASS cases=%"PRIu32" checks=%"PRIu64"\n",cases,checks);return 0;
}
