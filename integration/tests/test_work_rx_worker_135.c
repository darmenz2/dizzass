/* SPDX-License-Identifier: GPL-3.0-only
 * Sanitized composition/ownership checks; the ARM oracle is in the Python test. */
#include "integration/work_rx_worker_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned long checks,cases;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"line %d: %s\n",__LINE__,#x);exit(1);} } while(0)
enum { COUNT,SELECTOR,BOARD,MODE,FILTER,CANCEL,NAME,LOCK,UNLOCK,AVAILABLE,BYTE,PAYLOAD,CHIP,CORE,REPLY,NONCE,WAIT };
struct test {
    struct vn135_route_chain states[3],saved[3];
    struct vn135_rx_chain chains[3];
    struct vn135_rx_backend backend;
    vn135_work_job_snapshot jobs[32],saved_jobs[32];
    struct vn135_rx_worker_view view;
    vn135_nonce_candidate expected[3];
    vn135_work_rx_message messages[3];
    unsigned events[128],used,at,mode_calls,selector_calls,byte_calls;
    uint32_t board,selector,second,initial_mode,live_mode,count,filter,cancel_value;
    unsigned length[3],cursor[3],limit,fail_byte,fail_cancel,nonces,replies,waits;
    uint8_t bytes[3][11];
    int held;
};
static void expect(struct test *t,unsigned n){CHECK(t->used<128);t->events[t->used++]=n;}
static void event(struct test *t,unsigned n){CHECK(t->at<t->used);CHECK(t->events[t->at++]==n);}
static int index_of(struct test *t,void *p,int fifo){
    for(int i=0;i<3;++i)if(p==(fifo?t->chains[i].fifo:t->chains[i].mutex))return i;
    CHECK(0);return -1;
}
static uint32_t scalar(void *p,uint32_t at){
    struct test *t=p;
    switch(at){
    case 0xfe668:event(t,COUNT);return t->count;
    case 0xfdfbc:event(t,SELECTOR);return t->selector_calls++?t->second:t->selector;
    case 0xfdfac:event(t,BOARD);return t->board;
    case 0xfe0b0:event(t,MODE);return t->mode_calls++?t->live_mode:t->initial_mode;
    case 0xd2a84:event(t,FILTER);return t->filter;
    default:CHECK(0);return 0;
    }
}
static int32_t cancel(void *p,uint32_t mode,uint32_t *old){
    struct test *t=p;event(t,CANCEL);
    if(old){CHECK(t->held==3);CHECK(mode==0);CHECK(*old==t->view.initial_scratch.cancel_old);if(!t->fail_cancel)*old=t->cancel_value;}
    else CHECK(mode==(t->waits?(t->fail_cancel?t->view.initial_scratch.cancel_old:t->cancel_value):1));
    return -37;
}
static int32_t name(void *p,uint32_t operation,uint32_t str){
    struct test *t=p;event(t,NAME);CHECK(operation==15 && str==0x5e9749);t->backend.running=0;return -38;
}
static int32_t sync_op(void *p,uint32_t at,void *mutex){
    struct test *t=p;int i=mutex==(void *)(uintptr_t)0x653410?3:index_of(t,mutex,0);
    if(at==0x5a6108){event(t,LOCK);CHECK(t->held==-1);t->held=i;if(t->at<10)CHECK(t->backend.running==1);t->backend.running=0;}
    else{CHECK(at==0x5a66c4);event(t,UNLOCK);CHECK(t->held==i);t->held=-1;}
    return -39;
}
static int32_t wait_op(void *p,uint32_t condition,uint32_t mutex){
    struct test *t=p;event(t,WAIT);CHECK(condition==0x653428 && mutex==0x653410);CHECK(t->held==3);++t->waits;return -40;
}
static uint32_t available(void *p,void *fifo){
    struct test *t=p;int i=index_of(t,fifo,1);event(t,AVAILABLE);CHECK(t->held==i);return t->length[i]-t->cursor[i];
}
static int32_t byte_op(void *p,void *fifo,uint8_t *out){
    struct test *t=p;int i=index_of(t,fifo,1);event(t,BYTE);CHECK(t->held==i);CHECK(t->cursor[i]<t->length[i]);
    if(++t->byte_calls!=t->fail_byte)*out=t->bytes[i][t->cursor[i]];
    ++t->cursor[i];return -41;
}
static int32_t payload(void *p,void *fifo,uint8_t *out,uint32_t size){
    struct test *t=p;int i=index_of(t,fifo,1);event(t,PAYLOAD);CHECK(t->held==i);CHECK(size>=7 && size<=9);
    for(uint32_t j=0;j<size;++j)CHECK(out[j]==0);
    unsigned n=size<t->limit?size:t->limit;CHECK(t->cursor[i]+n<=t->length[i]);
    memcpy(out,t->bytes[i]+t->cursor[i],n);t->cursor[i]+=n;return -42;
}
static uint32_t pure_chip(void *p,uint32_t nonce){(void)p;return nonce^0x1234u;}
static uint32_t pure_core(void *p,uint32_t nonce){(void)p;return nonce^0xfedcba98u;}
static uint32_t chip(void *p,uint32_t nonce){struct test *t=p;event(t,CHIP);CHECK(t->held>=0 && t->held<3);return pure_chip(p,nonce);}
static uint32_t core(void *p,uint32_t nonce){struct test *t=p;event(t,CORE);CHECK(t->held>=0 && t->held<3);return pure_core(p,nonce);}
static int32_t reply(void *p,const vn135_work_rx_message *m){
    struct test *t=p;event(t,REPLY);CHECK(t->held>=0 && t->held<3);const vn135_work_rx_message *e=&t->messages[t->held];
    CHECK(m->chain_id==e->chain_id && m->chip_address==e->chip_address && m->register_address==e->register_address);
    CHECK(m->register_value==e->register_value && m->crc5_field==e->crc5_field);++t->replies;return -43;
}
static int32_t nonce_op(void *p,const vn135_nonce_candidate *c){
    struct test *t=p;event(t,NONCE);CHECK(t->held>=0 && t->held<3);CHECK(memcmp(c,&t->expected[t->held],sizeof(*c))==0);++t->nonces;return -44;
}
static const struct vn135_rx_worker_ops ops={scalar,cancel,name,sync_op,wait_op,available,byte_op,payload,chip,core,reply,nonce_op};

static void run(unsigned variant,unsigned mode,unsigned slot,unsigned limit,unsigned edge){
    struct test t;memset(&t,0,sizeof(t));t.held=-1;t.count=3;t.limit=limit;t.selector=variant==1?7:2;t.board=variant?1:0;
    t.second=slot%3==0?4:t.selector;t.initial_mode=mode==2;t.live_mode=mode==1;t.filter=slot%2?0x41:0x40;t.cancel_value=0xfedcba98;
    t.view.backend=&t.backend;t.view.slots=t.jobs;t.view.initial_scratch.header_byte=0xaa;t.view.initial_scratch.cancel_old=0x87654321;
    t.backend.chains=t.chains;t.backend.running=99;
    if(edge==1)t.count=0;
    if(edge==2)t.count=UINT32_MAX;
    t.fail_cancel=edge==3;t.fail_byte=edge==4?1:edge==5?2:0;
    for(unsigned s=0;s<32;++s)for(unsigned j=0;j<168;++j)t.jobs[s].bytes[j]=(uint8_t)(s*13+j*7);
    memcpy(t.saved_jobs,t.jobs,sizeof(t.jobs));
    vn135_work_rx_policy initial,live;CHECK(vn135_work_rx_policy_init(&initial,t.board,t.selector,t.initial_mode)==0);
    CHECK(vn135_work_rx_policy_init(&live,t.board,t.selector,t.live_mode)==0);
    for(unsigned i=0;i<3;++i){
        memset(&t.states[i],0xa5,sizeof(t.states[i]));t.states[i].index=UINT32_MAX-i;t.saved[i]=t.states[i];
        t.chains[i].chain=&t.states[i];t.chains[i].enabled=(edge==6 || i==1)?0:255;
        t.chains[i].mutex=&t.chains[i];t.chains[i].fifo=t.bytes[i];t.length[i]=11;
        t.bytes[i][0]=0xaa;t.bytes[i][1]=0x55;
        for(unsigned j=2;j<11;++j)t.bytes[i][j]=(uint8_t)(j*19+slot);
        t.bytes[i][2+(variant==1?6:5)]=(uint8_t)(slot<<3);
        if(i==0)t.bytes[i][live.frame_size-1]|=0x80;else t.bytes[i][live.frame_size-1]&=0x7f;
        if(edge==7)t.bytes[i][0]=0;
        if(edge==8)t.bytes[i][1]=0xaa;
        if(edge==9)t.length[i]=initial.frame_size-1;
    }
    expect(&t,COUNT);expect(&t,SELECTOR);expect(&t,BOARD);expect(&t,MODE);expect(&t,SELECTOR);expect(&t,CANCEL);expect(&t,NAME);
    unsigned progress=0,byte_count=0,wanted_nonce=0,wanted_reply=0;uint8_t header=t.view.initial_scratch.header_byte;
    for(unsigned i=0;t.count<0x80000000u && i<t.count;++i){
        if(!t.chains[i].enabled)continue;
        expect(&t,MODE);expect(&t,LOCK);expect(&t,AVAILABLE);
        if(t.length[i]>=initial.frame_size){
            progress=1;expect(&t,BYTE);if(++byte_count!=t.fail_byte)header=t.bytes[i][0];
            if(header==0xaa){
                expect(&t,BYTE);if(++byte_count!=t.fail_byte)header=t.bytes[i][1];
                if(header==0x55){
                    uint8_t frame[11]={0xaa,0x55};unsigned n=limit<live.payload_size?limit:live.payload_size;
                    memcpy(frame+2,t.bytes[i]+2,n);expect(&t,PAYLOAD);
                    CHECK(vn135_work_rx_next(&live,t.states[i].index,frame,live.frame_size,&t.messages[i])>=0);
                    if(t.messages[i].kind==VN135_RX_NONCE_RAW){
                        uint32_t selected;vn135_work_nonce_result r;vn135_nonce_attribution a={NULL,pure_chip,pure_core};
                        CHECK(vn135_work_rx_job_slot(t.second,variant,frame+2,live.payload_size,&selected)==0);
                        CHECK(selected<32);CHECK(vn135_work_nonce_prepare(t.second,variant,t.states[i].index,frame+2,live.payload_size,&t.jobs[selected],&a,&r)==0);
                        t.expected[i]=r.candidate;expect(&t,CHIP);expect(&t,CORE);expect(&t,NONCE);++wanted_nonce;
                    }else{expect(&t,FILTER);if(t.messages[i].register_address!=t.filter){expect(&t,REPLY);++wanted_reply;}}
                }
            }
        }
        expect(&t,UNLOCK);
    }
    if(!progress){expect(&t,LOCK);expect(&t,CANCEL);expect(&t,WAIT);expect(&t,CANCEL);expect(&t,UNLOCK);}
    CHECK(vn135_work_rx_worker_135(&t.view,&ops,&t)==0);CHECK(t.at==t.used);CHECK(t.held==-1);CHECK(t.backend.running==0);
    CHECK(t.nonces==wanted_nonce && t.replies==wanted_reply && t.waits==!progress);
    CHECK(memcmp(t.saved_jobs,t.jobs,sizeof(t.jobs))==0);CHECK(memcmp(t.saved,t.states,sizeof(t.states))==0);
    CHECK(t.view.initial_scratch.header_byte==0xaa && t.view.initial_scratch.cancel_old==0x87654321);++cases;
}
int main(void){
    for(unsigned v=0;v<3;++v)for(unsigned m=0;m<3;++m)for(unsigned s=0;s<32;++s)for(unsigned n=0;n<=9;++n)run(v,m,s,n,0);
    for(unsigned edge=1;edge<=9;++edge)for(unsigned v=0;v<3;++v)run(v,0,31,9,edge);
    printf("WORK_RX_WORKER_NATIVE_PASS cases=%lu checks=%lu\n",cases,checks);return 0;
}
