/* Memory and composition checks with serialized callback interference. */
#include "integration/work_tx_worker_135.h"
#include "integration/work_tx88.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks,cases;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"tx worker line %d: %s\n",__LINE__,#x);exit(1);} } while(0)
struct world {
    struct vn135_route_chain states[2][3];
    struct vn135_tx_chain chains[2][3];
    struct vn135_tx_backend backend;
    struct vn135_tx_ring ring;
    struct vn135_tx_slots slots;
    uint8_t qa[16];vn135_work_job_snapshot queue[768];uint8_t qb[16];
    uint8_t sa[16];vn135_work_job_snapshot table[32];uint8_t sb[16];
    vn135_work_job_snapshot expected[32];
    unsigned writes,locks,unlocks,waits,clocks,counts,intervals,exits;
    unsigned mode,passes;
    int32_t count,interval,rc;
    uint32_t slot,tail;
    uint8_t state,present;
};
static int32_t call(void *context,uint32_t entry,uint32_t a,uint32_t b)
{
    struct world *w=context;
    if(entry==0xfe668){CHECK(!a&&!b);++w->counts;return w->count;}
    if(entry==0xfedc4){CHECK(!a&&!b);++w->intervals;return w->interval;}
    if(entry==0x5a6b2c){CHECK(a==1&&!b);return w->rc;}
    if(entry==0x593af8){CHECK(a==15&&b==0x5e977d);w->backend.running=0;return w->rc;}
    if(entry==0x5a52d0){CHECK(!a&&!b);++w->exits;return w->rc;}
    CHECK(entry==0x5a6108||entry==0x5a66c4);
    CHECK(!b&&(a==0x633ba8||a==0x633bf0));
    if(a==0x633bf0){
        if(entry==0x5a6108){
            ++w->locks;
            if(w->mode==2&&w->locks==1)w->backend.chains=w->chains[1];
            if(w->mode==4&&w->locks%3==0)w->ring.tail=100;
        }else{
            ++w->unlocks;
            if(w->mode==3&&w->unlocks%3==1)w->ring.tail=767;
            if(w->mode==5&&w->unlocks%3==0)w->table[w->slot].bytes[64]=0xf7;
        }
    }
    return w->rc;
}
static int32_t clock_now(void *context,uint32_t id,struct vn135_tx_time *time)
{
    struct world *w=context;
    CHECK(id==1);
    if(!w->clocks)CHECK(time->seconds_bits==0&&time->nanoseconds_bits==0&&time->untouched==0);
    ++w->clocks;
    time->seconds_bits=UINT64_MAX;time->nanoseconds_bits=999000000;time->untouched=0xaabbccdd;
    return w->rc;
}
static int32_t wait_for_work(void *context,uint32_t cond,uint32_t mutex,struct vn135_tx_time *time)
{
    struct world *w=context;
    CHECK(cond==0x633bc0&&mutex==0x633ba8);
    CHECK(time->untouched==0xaabbccdd);
    CHECK(time->seconds_bits==0&&time->nanoseconds_bits==16000000);
    ++w->waits;
    if(w->waits==w->passes)w->backend.running=0;
    return w->rc;
}
static int32_t write_uart(void *context,void *uart,const uint8_t *frame,uint32_t size)
{
    struct world *w=context;
    uint8_t header[80]={0},expected_frame[88];
    uint32_t tail=w->mode==3 ? 767u : w->tail;
    uint32_t next_tail=w->mode==4 ? 101u : tail==767 ? 0u : tail+1u;
    unsigned j,chain=w->writes%3,bank=w->mode==2&&w->writes>0 ? 1u : 0u;
    CHECK(uart==&w->states[bank][chain]);
    CHECK(size==88&&frame[4]==w->slot*8);
    CHECK(w->slots.next==(w->slot+1u)%32u);
    CHECK(w->ring.tail==next_tail);
    w->expected[w->slot]=w->queue[tail];
    if(w->mode==5)w->expected[w->slot].bytes[64]=0xf7;
    CHECK(!memcmp(&w->table[w->slot],&w->expected[w->slot],168));
    /* Existing verified native-word encoder supplies an independent interface
     * to the shared frame layout. Whole-original comparison is in Python. */
    for(j=0;j<64;++j)header[j]=w->expected[w->slot].bytes[63-j];
    for(j=0;j<12;++j)header[64+j]=w->expected[w->slot].bytes[75-j];
    CHECK(dizzass_tx88_encode_words(header,80,w->slot,expected_frame,88)==0);
    CHECK(!memcmp(frame,expected_frame,88));
    w->slot=(w->slot+1u)%32u;w->tail=next_tail;
    ++w->writes;
    if(w->mode==1)w->backend.running=0;
    return w->rc;
}
static void run(uint32_t slot,uint32_t tail,int32_t count,unsigned mode,unsigned passes,uint8_t state,uint8_t present,int32_t rc)
{
    struct world *w=calloc(1,sizeof(*w));
    struct vn135_tx_worker_view view;
    const struct vn135_tx_worker_ops ops={call,clock_now,wait_for_work,write_uart};
    unsigned i,j,bank,expected_writes;
    CHECK(w!=NULL);
    w->count=count;w->interval=17;w->mode=mode;w->passes=passes;w->rc=rc;
    w->slot=slot;w->tail=tail;w->state=state;w->present=present;
    memset(w->qa,0xa5,16);memset(w->qb,0xa5,16);memset(w->sa,0xa5,16);memset(w->sb,0xa5,16);
    for(i=0;i<768;++i)for(j=0;j<168;++j)w->queue[i].bytes[j]=(uint8_t)(37*i+j);
    memset(w->table,0xee,sizeof(w->table));memcpy(w->expected,w->table,sizeof(w->table));
    for(bank=0;bank<2;++bank)for(i=0;i<3;++i){
        w->states[bank][i].state=state;w->states[bank][i].present=present;
        w->states[bank][i].index=99+i;
        w->chains[bank][i].state=&w->states[bank][i];w->chains[bank][i].uart=&w->states[bank][i];
    }
    w->backend.chains=w->chains[0];w->backend.running=0;
    w->ring.head=0xffffffff;w->ring.tail=tail;w->ring.rows=w->queue;
    w->slots.next=slot;w->slots.rows=w->table;
    view.backend=&w->backend;view.ring=&w->ring;view.slots=&w->slots;
    CHECK(vn135_work_tx_worker_135(&view,&ops,w)==VN135_TX_THREAD_EXIT);
    expected_writes=count<1||!present||(uint32_t)(state-3u)<=2u ? 0u : (unsigned)count;
    expected_writes*=mode==1 ? 1u : passes;
    CHECK(w->writes==expected_writes);
    CHECK(w->counts==1&&w->exits==1);
    CHECK(w->waits==(mode==1&&expected_writes ? 1u : passes));
    CHECK(w->clocks==w->waits&&w->intervals==w->waits);
    CHECK(w->locks==w->writes*3&&w->unlocks==w->locks);
    CHECK(!memcmp(w->table,w->expected,sizeof(w->table)));
    for(i=0;i<16;++i)CHECK(w->qa[i]==0xa5&&w->qb[i]==0xa5&&w->sa[i]==0xa5&&w->sb[i]==0xa5);
    for(i=0;i<768;++i)for(j=0;j<168;++j)CHECK(w->queue[i].bytes[j]==(uint8_t)(37*i+j));
    for(bank=0;bank<2;++bank)for(i=0;i<3;++i)CHECK(w->states[bank][i].index==99+i&&w->states[bank][i].state==state&&w->states[bank][i].present==present);
    free(w);++cases;
}
static void check_time(void)
{
    unsigned sec,ns,ms;
    const uint64_t seconds[]={0,1,UINT64_MAX,UINT64_C(0x7fffffffffffffff)};
    const uint32_t nanos[]={0,1,999999999};
    const int32_t millis[]={INT32_MIN,-1001,-1000,-1,0,1,999,1000,1001,INT32_MAX};
    for(sec=0;sec<4;++sec)for(ns=0;ns<3;++ns)for(ms=0;ms<10;++ms){
        struct vn135_tx_time t={seconds[sec],nanos[ns],0x55aa};
        int64_t rest=(int64_t)nanos[ns]+(millis[ms]%1000)*INT64_C(1000000);
        int64_t delta=millis[ms]/1000;
        if(rest<0){--delta;rest+=1000000000;}
        else if(rest>=1000000000){++delta;rest-=1000000000;}
        vn135_tx_add_interval_135(&t,millis[ms]);
        CHECK(t.seconds_bits==seconds[sec]+(uint64_t)delta&&t.nanoseconds_bits==(uint32_t)rest&&t.untouched==0x55aa);
    }
}
int main(void)
{
    unsigned slot,tail,mode,state,present;
    const uint32_t tails[]={0,1,254,255,256,511,512,766,767};
    check_time();
    for(slot=0;slot<32;++slot)for(tail=0;tail<9;++tail)for(mode=0;mode<6;++mode)
        run(slot,tails[tail],3,mode,3,2,1,(slot&1)?-1:88);
    for(state=0;state<8;++state)for(present=0;present<256;++present)
        run(31,767,3,0,1,(uint8_t)state,(uint8_t)present,-7);
    run(31,767,0,0,2,2,1,-1);run(0,0,-1,0,2,2,1,-1);run(0,0,INT32_MIN,0,2,2,1,-1);
    printf("WORK_TX_WORKER_NATIVE_PASS cases=%u checks=%u\n",cases,checks);
    return 0;
}
