/* SPDX-License-Identifier: GPL-3.0-only
 * Host allocation/lifetime and nested unchanged FIFO reset checks.
 * Scripted clone effects below are a TEST boundary, not recovered 5cd70.
 */
#include "integration/template_publication_135.h"
#include "xminer/recovery/nonce_fifo.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned assertions, scenarios;
#define CHECK(x) do { ++assertions; if (!(x)) { \
    fprintf(stderr,"check failed line %d: %s\n",__LINE__,#x); exit(1); } } while (0)
typedef struct {
    void *slot[3];
    unsigned char *owned[3], source[104], destination[104];
    uint8_t ready, flag;
    unsigned mask, freed, cloned, reset, broadcast, unlock, locked, qlocked;
    unsigned mode;
    uint8_t wanted;
    int rc;
    vn135_nonce_fifo queue;
    vn135_template_publication_view view;
} Context;
static int queue_lock(void *ctx) {
    Context *c=ctx; CHECK(c->locked==1 && c->qlocked==0 && c->ready==1);
    c->qlocked=1; return 0;
}
static int queue_unlock(void *ctx) {
    Context *c=ctx; CHECK(c->qlocked==1 && c->queue.ring.count==0);
    CHECK(c->queue.ring.read_index==0 && c->queue.ring.write_index==0);
    CHECK(c->queue.push_word==0xabcdef12); c->qlocked=0; return 0;
}
static int lock(void *ctx,void *object) {
    Context *c=ctx; CHECK(object==&c->locked && c->locked==0);
    CHECK(c->ready==0xa5); c->locked=1;
    return c->rc;
}
static void release(void *ctx,void *p) {
    Context *c=ctx; unsigned index=0;
    CHECK(c->locked==1 && c->cloned==0 && c->ready==0xa5);
    while(index<3 && c->owned[index]!=p)++index;
    CHECK(index<3 && c->slot[index]==p);
    for(unsigned i=0;i<index;++i) CHECK(c->slot[i]==NULL);
    for(unsigned i=0;i<32;++i) CHECK(((unsigned char *)p)[i]==(unsigned char)(0x30+index));
    free(p); c->owned[index]=NULL; ++c->freed;
    /* After-call clear must win over a synchronous slot write. Address points
     * to accessible caller data and is never owned/freed by the harness. */
    c->slot[index]=c->source;
}
static void clone(void *ctx,void *destination,const void *source) {
    Context *c=ctx;
    CHECK(destination==c->destination && source==c->source && c->locked==1);
    CHECK(c->ready==0xa5 && c->cloned==0);
    for(unsigned i=0;i<3;++i)CHECK(c->slot[i]==NULL);
    c->cloned=1;
    /* Deliberately scripted effects, NOT a vendor/native work clone. */
    c->destination[97]=0xe9;
    c->ready=0x73;
    if(c->mode==1)c->flag=0;
    else if(c->mode==2)c->flag=255;
    c->wanted=c->flag;
    for(unsigned i=0;i<3;++i){
        c->owned[i]=malloc(32);CHECK(c->owned[i]!=NULL);
        memset(c->owned[i],(int)(0x60+i),32);c->slot[i]=c->owned[i];
    }
}
static void reset(void *ctx) {
    Context *c=ctx;
    CHECK(c->cloned==1 && c->ready==1 && c->flag!=0 && c->locked==1);
    CHECK(c->broadcast==0 && c->reset==0);c->reset=1;
    vn135_fifo_sync sync={c,NULL,queue_lock,queue_unlock,NULL};
    CHECK(vn135_nonce_fifo_reset(&c->queue,&sync)==0);
    c->flag=0; /* must not invoke reset again */
}
static int broadcast(void *ctx,void *object) {
    Context *c=ctx;CHECK(object==&c->broadcast);
    CHECK(c->cloned==1 && c->ready==1 && c->locked==1 && !c->qlocked);
    CHECK(c->reset==(c->wanted!=0) && c->broadcast==0);
    c->broadcast=1;c->ready=0x81;return c->rc;
}
static int unlock(void *ctx,void *object) {
    Context *c=ctx;CHECK(object==&c->locked && c->locked==1 && c->broadcast==1);
    CHECK(c->ready==0x81 && c->unlock==0);c->locked=0;c->unlock=1;return c->rc;
}
static void run(unsigned mask,unsigned flag,unsigned mode,int rc,unsigned count,unsigned read) {
    Context c={0};c.mask=mask;c.flag=(uint8_t)flag;c.ready=0xa5;c.mode=mode;c.rc=rc;
    memset(c.source,0x45,sizeof c.source);memset(c.destination,0x56,sizeof c.destination);
    unsigned expect_free=0;
    for(unsigned i=0;i<3;++i) if(mask&(1u<<i)){
        c.slot[i]=c.owned[i]=malloc(32);CHECK(c.owned[i]!=NULL);
        memset(c.owned[i],(int)(0x30+i),32);++expect_free;
    }
    c.queue=(vn135_nonce_fifo){{malloc(4096*72),4096,72,count,(read+count)%4096,read},0xabcdef12,1};
    CHECK(c.queue.ring.storage!=NULL);memset(c.queue.ring.storage,0xa7,4096*72);
    c.view=(vn135_template_publication_view){&c.slot[0],&c.slot[1],&c.slot[2],&c.ready,&c.flag,
        c.destination,c.source,&c.locked,&c.broadcast};
    const vn135_template_publication_ops ops={lock,release,clone,reset,broadcast,unlock};
    vn135_template_publish_135(&c.view,&ops,&c);
    CHECK(c.freed==expect_free && c.cloned==1 && c.broadcast==1 && c.unlock==1 && !c.locked);
    CHECK(c.ready==0x81 && c.destination[97]==0xe9);
    for(unsigned i=0;i<104;++i){CHECK(c.source[i]==0x45);if(i!=97)CHECK(c.destination[i]==0x56);}
    if(!c.wanted){CHECK(c.queue.ring.count==count && c.queue.ring.read_index==read);CHECK(c.queue.ring.write_index==(read+count)%4096);}
    for(unsigned i=0;i<4096*72;++i)CHECK(c.queue.ring.storage[i]==0xa7);
    for(unsigned i=0;i<3;++i){
        CHECK(c.slot[i]==c.owned[i] && c.owned[i]!=NULL);
        for(unsigned j=0;j<32;++j)CHECK(c.owned[i][j]==(unsigned char)(0x60+i));
        free(c.owned[i]);
    }
    free(c.queue.ring.storage);++scenarios;
}
int main(void) {
    const unsigned flags[]={0,1,2,128,255},counts[]={0,1,4095,4096};
    for(unsigned mask=0;mask<8;++mask)
        for(unsigned f=0;f<5;++f)
            for(unsigned mode=0;mode<3;++mode)
                for(unsigned rc=0;rc<2;++rc)
                    run(mask,flags[f],mode,rc?-17:0,counts[(mask+mode)%4],(mask&1)?4095:0);
    printf("TEMPLATE_PUBLICATION_NATIVE_PASS scenarios=%u assertions=%u\n",scenarios,assertions);
    return 0;
}
