/* Native memory/lifetime tests of the translated caller. All effects are RAM
 * scripts; thread callbacks do not create threads and no hardware is opened. */
#include "integration/backend_resume_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
static unsigned assertions,scenarios;
#define CHECK(x) do { ++assertions; if (!(x)) { fprintf(stderr,"resume135:%d: %s\n",__LINE__,#x); exit(1); } } while(0)
#define MAX_EVENTS 160u
#define CHAINS 4u
#define ITEMS 5u
struct fixture {
    uint64_t pre;
    struct vn135_resume_state s;
    uint64_t post;
    struct vn135_resume_description d;
    struct vn135_resume_chain chains[CHAINS];
    struct vn135_resume_item items[CHAINS][ITEMS];
    uint32_t types[ITEMS];
    uint8_t platform;
    uintptr_t scratch;
    char source[32];
    uint32_t mode,kind,fail_op,fail_nth;
    int32_t fail_rc,count,random_value;
    unsigned fail_hits,check_before,apply_fail,pool_down,trylock_fail;
    unsigned creates,fail_create,joins,join_write,join_value;
    int32_t join_rc,on_rc,set_rc;
    unsigned ons,offs,setters,duplicates,releases,duplicate_fail;
    unsigned timestamps,completed,unlocks,exit_flags,recovery,stop,events_n;
    uint32_t last_event,last_start,last_delay,set_value,create_offsets[3],create_entries[3];
    uint32_t events[MAX_EVENTS];
};
static char *owned_copy(const char *s)
{
    size_t n=strlen(s)+1;char *p=malloc(n);CHECK(p!=NULL);memcpy(p,s,n);return p;
}
static void event(struct fixture *f,uint32_t id)
{CHECK(f->events_n<MAX_EVENTS);f->events[f->events_n++]=id;}
static int32_t step(void *p,enum vn135_resume_step op,uint32_t a,uint32_t b,uint32_t c)
{
    struct fixture *f=p;event(f,(uint32_t)op);
    if(op==VN135_R_UNLOCK)++f->unlocks;
    if(op==VN135_R_FLAG_8291C)++f->exit_flags;
    if(op==VN135_R_RECOVERY_6BB70)++f->recovery;
    if(op==VN135_R_STOP_5E92C)++f->stop;
    if(op==VN135_R_START_644A8)f->last_start=a;
    if(op==VN135_R_EVENT_49C98)f->last_event=a;
    if(op==VN135_R_DELAY)f->last_delay=a;
    if(op==VN135_R_PREPARE_106E58){CHECK(a==f->d.chip_selector);CHECK(b==(uint32_t)f->count);CHECK(c==108);}
    if(op==VN135_R_CHAIN_55400)CHECK(a<CHAINS);
    if(op==VN135_R_CONFIG_6F6F4 && !f->duplicate_fail)CHECK(!strcmp(f->s.text_fc8,f->source));
    if((uint32_t)op==f->fail_op && f->fail_hits++==f->fail_nth)return f->fail_rc;
    switch(op) {
    case VN135_R_CHAIN_COUNT:return f->count;
    case VN135_R_MODE_82D60:return (int32_t)f->mode;
    case VN135_R_CHECK_B86D0:return (int32_t)f->check_before;
    case VN135_R_APPLY_4F0A0:return f->apply_fail?-1:0;
    case VN135_R_POOL_CHECK:return f->pool_down?0:1;
    case VN135_R_TRYLOCK:return f->trylock_fail?16:0;
    case VN135_R_PLATFORM_KIND:return (int32_t)f->kind;
    case VN135_R_RANDOM:return f->random_value;
    default:return 0; /* Explicit RAM success scenario, not a device binding. */
    }
}
static int32_t create(void *p,uint32_t offset,uint32_t entry,uintptr_t *handle)
{
    struct fixture *f=p;unsigned i=f->creates++;event(f,0x5a55cc);CHECK(i<3);
    f->create_offsets[i]=offset;f->create_entries[i]=entry;
    CHECK(offset==0x1044||offset==0x101c||offset==0x1014);
    if(f->creates==f->fail_create)return 11;
    *handle=(uintptr_t)(0x60000000u+offset);return 0;
}
static int32_t join(void *p,uintptr_t handle,uintptr_t *result)
{
    struct fixture *f=p;event(f,0x5a5d2c);++f->joins;
    CHECK(handle==0x10101010);CHECK(f->s.byte_1054==0);
    if(f->join_write)*result=f->join_value;
    return f->join_rc;
}
static char *duplicate(void *p,const char *s)
{
    struct fixture *f=p;event(f,0x5a38a0);++f->duplicates;
    CHECK(s==f->source);CHECK(f->s.text_fc8==NULL);
    return f->duplicate_fail?NULL:owned_copy(s);
}
static void release(void *p,char *s)
{struct fixture *f=p;event(f,0x593c8c);++f->releases;CHECK(s==f->s.text_fc8);free(s);}
static double timestamp(void *p)
{struct fixture *f=p;event(f,0x1ed58);++f->timestamps;CHECK(f->s.byte_24==1);return 12345.125;}
static void log_resume(void *p,uint32_t line,uint32_t severity,uint32_t a,uint32_t b)
{
    struct fixture *f=p;(void)a;(void)b;event(f,0x80000000u|line);
    CHECK(severity>=1&&severity<=3);if(line==6294)++f->completed;
}
static int32_t on(void *p){struct fixture *f=p;event(f,0xfe310);++f->ons;return f->on_rc;}
static int32_t off(void *p){struct fixture *f=p;++f->offs;CHECK(0);return -1;}
static int32_t setter(void *p,uint16_t v)
{
    struct fixture *f=p;event(f,0x104134);++f->setters;f->set_value=v;
    CHECK(f->s.power.byte_ff1==0x55);CHECK(f->s.power.word_20c==0x11223344);
    return f->set_rc;
}
static int32_t count_for_power(void *p){(void)p;CHECK(0);return 0;}
static int32_t reset_for_power(void *p,uint32_t i){(void)p;(void)i;CHECK(0);return -1;}
static void log_power(void *p,enum vn135_gpio_power_source src,uint32_t line,uint32_t value)
{struct fixture *f=p;(void)value;CHECK(src==VN135_GP_BASE);event(f,0x90000000u|line);}
static const struct vn135_resume_ops ops={step,create,join,duplicate,release,timestamp,log_resume};
static const struct vn135_backend_power_ops pops={on,off,setter,count_for_power,reset_for_power,log_power};
static void init(struct fixture *f)
{
    unsigned i,j;memset(f,0,sizeof(*f));f->pre=UINT64_C(0x123456789abcdef0);f->post=~f->pre;
    f->s.description=&f->d;f->s.chains=f->chains;f->s.platform_byte=&f->platform;
    f->s.word_20=5;f->s.word_dc=12000;f->s.limit_34=15000;
    f->s.power.byte_ff1=0x55;f->s.power.word_20c=0x11223344;
    f->s.thread_1050=0x10101010;f->s.thread_1044=0x20202020;
    f->s.thread_101c=0x30303030;f->s.thread_1014=0x40404040;
    f->s.double_28=-99.25;strcpy(f->source,"original-pool-description");
    f->s.text_90=f->source;f->s.text_fc8=owned_copy("previous-pool-description");
    f->d.word_10=3;f->d.board_word_10=108;f->d.table_count=3;
    f->d.table_types=f->types;f->d.chip_selector=4;f->d.chip_word_2c=0x44332211;
    f->types[1]=4;f->types[3]=4;f->count=3;f->join_write=1;f->random_value=12345;
    for(i=0;i<CHAINS;++i){f->chains[i].word_20=1;f->chains[i].byte_24=1;f->chains[i].items=f->items[i];
        for(j=0;j<ITEMS;++j){f->items[i][j].word_3c=1000+i*10+j;f->items[i][j].word_44=0x87650000+i*10+j;}}
}
static int run(struct fixture *f)
{
    int rc=vn135_backend_resume_135(&f->s,&ops,&pops,f,&f->scratch);
    CHECK(f->pre==UINT64_C(0x123456789abcdef0));CHECK(f->post==~f->pre);CHECK(f->offs==0);
    CHECK(f->platform==(uint8_t)f->mode);++scenarios;return rc;
}
static void clean(struct fixture *f){free(f->s.text_fc8);f->s.text_fc8=NULL;}
static void successful_routes(void)
{
    struct fixture f;unsigned sel,mode,kind,i,j;
    const uint32_t modes[]={0,1,2,255,256,0x7fffffff};
    for(sel=0;sel<10;++sel)for(mode=0;mode<sizeof(modes)/sizeof(*modes);++mode)for(kind=0;kind<4;++kind) {
        init(&f);f.d.chip_selector=sel;f.mode=modes[mode];f.kind=kind;CHECK(run(&f)==0);
        CHECK(f.ons==1&&f.setters==1&&f.timestamps==1&&f.completed==1);
        CHECK(f.last_start==(f.mode^1u));CHECK(f.s.word_20==1);
        CHECK(f.s.power.word_20c==(sel==5?13000u:12000u));CHECK(f.s.double_28==12345.125);
        CHECK(f.creates==1u+(sel!=6&&sel!=7)+(kind==0||kind==2));
        CHECK(f.duplicates==1&&f.releases==1&&f.s.text_fc8!=f.source);
        f.source[0]='X';CHECK(f.s.text_fc8[0]=='o');
        for(i=0;i<CHAINS;++i)for(j=0;j<ITEMS;++j)CHECK(f.items[i][j].word_44==
            (i<3&&j<3?1000+i*10+j:0x87650000+i*10+j));
        CHECK(f.unlocks==1&&f.exit_flags==1);clean(&f);
    }
}
static void failures(void)
{
    struct fixture f;unsigned i,j;int rc;
    const uint32_t fail_ops[]={VN135_R_PREPARE_106E58,VN135_R_CHECK_66504,
        VN135_R_CHAIN_6C61C,VN135_R_CHAIN_6C89C,VN135_R_TYPE4_6E31C,
        VN135_R_CONFIG_6E734,VN135_R_CONFIG_6EC4C,VN135_R_CONFIG_6F1CC,
        VN135_R_CONFIG_6709C,VN135_R_CONFIG_6F8AC,VN135_R_CONFIG_6FAE8,
        VN135_R_CHAIN_55400,VN135_R_CONFIG_A20A0,VN135_R_FINISH_60A2C};
    for(i=0;i<sizeof(fail_ops)/sizeof(*fail_ops);++i)for(j=0;j<3;++j) {
        init(&f);f.fail_op=fail_ops[i];f.fail_rc=j==0?-1:j==1?1:7;rc=run(&f);
        CHECK(rc==(i>=11?0:-1));CHECK(f.completed==0&&f.timestamps==0&&f.s.byte_24==0);
        CHECK(f.s.double_28==-99.25);CHECK(f.unlocks==1&&f.exit_flags==1);
        if(f.fail_op==VN135_R_CONFIG_6F1CC)CHECK(f.last_event==0xbbe);
        clean(&f);
    }
    for(i=1;i<=3;++i){init(&f);f.fail_create=i;CHECK(run(&f)==-1);CHECK(f.creates==i);
        CHECK(f.completed==0&&f.timestamps==0&&f.s.power.byte_ff1==1);clean(&f);}
    for(i=0;i<3;++i){init(&f);if(i==0)f.on_rc=-1;else f.set_rc=i==1?-1:1;
        CHECK(run(&f)==-1);CHECK(f.s.power.byte_ff1==0x55&&f.s.power.word_20c==0x11223344);
        CHECK(f.setters==(i!=0));clean(&f);}
    for(i=1;i<=4;++i){init(&f);f.fail_op=VN135_R_START_644A8;f.fail_rc=(int32_t)i;
        CHECK(run(&f)==(i==2?0:(int)i));CHECK(f.completed==0&&f.unlocks==1);
        CHECK(f.exit_flags==(i>2));CHECK(f.recovery==(i==1));CHECK(f.stop==(i==2));
        if(i==2)CHECK(f.last_event==0x3f1);
        clean(&f);}
}
static void gates_and_memory(void)
{
    struct fixture f;unsigned i,j,k;int rc;
    for(i=0;i<8;++i){init(&f);f.s.word_20=i;rc=run(&f);CHECK(rc==(i==5?0:1));
        if(i!=5)CHECK(f.ons==0&&f.unlocks==0&&f.exit_flags==0);
        clean(&f);}
    init(&f);f.pool_down=1;CHECK(run(&f)==2);CHECK(f.unlocks==0&&f.ons==0);clean(&f);
    init(&f);f.trylock_fail=1;CHECK(run(&f)==1);CHECK(f.unlocks==0&&f.ons==0);clean(&f);
    init(&f);f.s.byte_85=1;f.check_before=1;f.apply_fail=1;
    CHECK(run(&f)==-1);CHECK(f.unlocks==1&&f.exit_flags==1&&f.ons==0);clean(&f);
    for(i=0;i<2;++i)for(j=0;j<2;++j)for(k=0;k<2;++k){
        init(&f);f.s.byte_1054=255;f.join_rc=-1;f.scratch=i?0x1234:0;
        f.join_write=j;f.join_value=k?0x5678:0;
        CHECK(run(&f)==((j?k:i)?-1:0));CHECK(f.s.byte_1054==0&&f.joins==1);clean(&f);
    }
    init(&f);f.duplicate_fail=1;CHECK(run(&f)==0);CHECK(f.s.text_fc8==NULL&&f.completed==1);clean(&f);
    init(&f);f.s.word_d4=7;f.random_value=-1;CHECK(run(&f)==0);CHECK(f.last_delay==UINT32_MAX-999u);clean(&f);
    init(&f);f.count=0;CHECK(run(&f)==0);CHECK(f.completed==0&&f.timestamps==0);clean(&f);
    for(i=0;i<9;++i)for(j=0;j<2;++j){
        init(&f);for(k=0;k<CHAINS;++k){f.chains[k].word_20=i;f.chains[k].byte_24=j?255:0;}
        CHECK(run(&f)==0);CHECK(f.completed==(j&&!(i>=3&&i<=5)));
        for(k=0;k<CHAINS;++k)CHECK(f.items[k][0].word_44==
            (k<3&&j&&!(i>=3&&i<=5)?1000+k*10:0x87650000+k*10));clean(&f);
    }
}
int main(void)
{
    successful_routes();failures();gates_and_memory();
    printf("BACKEND_RESUME135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no real_threads=no\n",scenarios,assertions);
    return 0;
}
