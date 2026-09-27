/* SPDX-License-Identifier: GPL-3.0-only
 * Supplement original-instruction oracle with host bounds/lifetime checks. */
#include "integration/work_stop_135.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define N 8u
static uint64_t checks, cases;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"check failed line %d: %s\n",__LINE__,#x); abort(); } } while (0)
struct guarded_thread { uint32_t before[4]; struct vn135_shutdown_thread value; uint32_t after[4]; };
struct guarded_byte { uint8_t before[16], value, after[16]; };
struct state {
    struct guarded_thread threads[3];
    struct guarded_byte bytes[2][N];
    struct vn135_work_stop_chain banks[2][N];
    struct vn135_work_stop_view view;
    uint8_t initial[3];
    unsigned selected[3], selected_n, cancelled, joined, destroyed, chains;
    unsigned expected_bank[N], expected_row[N], expected_n, mode, base;
    uint32_t expected_method[N], handles[3], method;
    int32_t count;
    unsigned getter;
};
static int32_t get_count(void *p) { struct state *s=p; CHECK(++s->getter==1); return s->count; }
static int32_t cancel_thread(void *p,uint32_t h)
{
    struct state *s=p; CHECK(s->getter==1 && s->destroyed==0);
    CHECK(s->cancelled==s->joined && s->cancelled<s->selected_n);
    unsigned i=s->selected[s->cancelled++];
    CHECK(h==s->handles[i] && s->threads[i].value.running==0);
    for (unsigned j=i+1;j<3;++j) CHECK(s->threads[j].value.running==s->initial[j]);
    s->threads[i].value.handle=h^0xface0000u;
    s->threads[i].value.running=255; /* reassertion must survive */
    s->count=-1; /* must not refresh the cached traversal bound */
    return -7;
}
static int32_t join_thread(void *p,uint32_t h,uint32_t *result)
{
    struct state *s=p; CHECK(s->cancelled==s->joined+1 && result==NULL);
    unsigned i=s->selected[s->joined++];
    CHECK(h==(s->handles[i]^0xface0000u));
    CHECK(s->threads[i].value.running==255);
    return -8;
}
static int32_t destroy_object(void *p,uint32_t entry,uint32_t identity)
{
    struct state *s=p;
    const uint32_t entries[]={0x5a4954,0x5a60b8,0x5a4954,0x5a60b8};
    const uint32_t objects[]={0x633bc0,0x633ba8,0x633b08,0x633af0};
    CHECK(s->getter==1 && s->cancelled==s->selected_n && s->joined==s->selected_n);
    CHECK(s->destroyed<4 && s->chains==0);
    CHECK(entry==entries[s->destroyed] && identity==objects[s->destroyed]);
    if (++s->destroyed==4 && (s->mode&1)) { s->base^=1; s->view.chains=s->banks[s->base]; }
    return -9;
}
static int32_t stop_chain(void *p,uint32_t method,void *object)
{
    struct state *s=p; CHECK(s->destroyed==4 && s->chains<s->expected_n);
    unsigned n=s->chains++,b=s->expected_bank[n],i=s->expected_row[n];
    CHECK(object==&s->bytes[b][i] && method==s->expected_method[n]);
    CHECK(s->bytes[b][i].value!=0);
    if (s->chains==1) {
        if (s->mode&2) { s->base^=1; s->view.chains=s->banks[s->base]; }
        if (s->mode&4) s->view.chain_method=0xbfb94;
        if ((s->mode&8) && i+1<N) s->bytes[s->base][i+1].value=0;
    }
    return -10;
}
static void run(unsigned a,unsigned b,unsigned c,int32_t count,unsigned mode)
{
    struct state s; memset(&s,0,sizeof(s));
    const uint8_t flags[]={0,1,2,128,255};
    const unsigned choices[]={a,b,c};
    s.count=count; s.mode=mode; s.method=0xc39a8;
    for (unsigned i=0;i<3;++i) {
        memset(&s.threads[i],0xa5,sizeof(s.threads[i]));
        s.handles[i]=i==0 ? 0 : i==1 ? UINT32_MAX : 0x80000000u;
        s.threads[i].value.handle=s.handles[i];
        s.initial[i]=s.threads[i].value.running=flags[choices[i]];
        if (s.initial[i]) s.selected[s.selected_n++]=i;
    }
    uint8_t model[2][N];
    for (unsigned bank=0;bank<2;++bank) for (unsigned i=0;i<N;++i) {
        memset(&s.bytes[bank][i],0xa5,sizeof(s.bytes[bank][i]));
        model[bank][i]=s.bytes[bank][i].value=flags[(i+bank)%5];
        s.banks[bank][i]=(struct vn135_work_stop_chain){&s.bytes[bank][i].value,&s.bytes[bank][i]};
    }
    s.view=(struct vn135_work_stop_view){&s.threads[0].value,&s.threads[1].value,&s.threads[2].value,s.banks[0],s.method};
    unsigned bank=mode&1;
    uint32_t method=s.method;
    for (int32_t i=0;i<count;++i) if (model[bank][i]) {
        unsigned n=s.expected_n++;
        s.expected_bank[n]=bank; s.expected_row[n]=(unsigned)i; s.expected_method[n]=method;
        if (n==0) {
            if (mode&2) bank^=1;
            if (mode&4) method=0xbfb94;
            if ((mode&8) && (unsigned)i+1<N) model[bank][i+1]=0;
        }
    }
    const struct vn135_work_stop_ops ops={get_count,cancel_thread,join_thread,destroy_object,stop_chain};
    CHECK(vn135_work_stop_135(&s.view,&ops,&s)==0);
    CHECK(s.getter==1 && s.cancelled==s.selected_n && s.joined==s.selected_n && s.destroyed==4 && s.chains==s.expected_n);
    CHECK(s.view.producer==&s.threads[0].value && s.view.receiver==&s.threads[1].value && s.view.sender==&s.threads[2].value);
    for (unsigned i=0;i<3;++i) {
        CHECK(s.threads[i].value.handle==(s.initial[i] ? s.handles[i]^0xface0000u : s.handles[i]));
        CHECK(s.threads[i].value.running==(s.initial[i] ? 255 : 0));
        for (unsigned j=0;j<4;++j) CHECK(s.threads[i].before[j]==0xa5a5a5a5u && s.threads[i].after[j]==0xa5a5a5a5u);
    }
    for (unsigned k=0;k<2;++k) for (unsigned i=0;i<N;++i) {
        CHECK(s.bytes[k][i].value==model[k][i]);
        for (unsigned j=0;j<16;++j) CHECK(s.bytes[k][i].before[j]==0xa5 && s.bytes[k][i].after[j]==0xa5);
    }
    ++cases;
}
int main(void)
{
    const int32_t counts[]={INT32_MIN,-1,0,1,2,3,8};
    for (unsigned a=0;a<5;++a) for (unsigned b=0;b<5;++b) for (unsigned c=0;c<5;++c)
        for (unsigned n=0;n<sizeof(counts)/sizeof(counts[0]);++n) for (unsigned mode=0;mode<16;++mode)
            run(a,b,c,counts[n],mode);
    printf("WORK_STOP_NATIVE_PASS cases=%" PRIu64 " checks=%" PRIu64 "\n",cases,checks);
    return 0;
}
