/* Native tests of newly recovered caller bodies. Effects are RAM only. */
#include "integration/thermal_reader_135.h"
#include "integration/backend_shutdown_135.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
static unsigned scenarios,checks;
#define CHECK(x) do {++checks;assert(x);} while(0)
struct reader_fixture {
    uint32_t platform,transfers,delays,delay_total,reads,models,offsets;
    uint32_t locks,unlocks;
    int fail_at,fail_all,no_write,config_busy;
    uint8_t raw,remote;
    double clock;
    int32_t offset;
};
static int32_t rm(void *p,struct vn135_temperature_sensor *s)
{struct reader_fixture *f=p;(void)s;++f->locks;return -3;}
static int32_t ru(void *p,struct vn135_temperature_sensor *s)
{struct reader_fixture *f=p;(void)s;++f->unlocks;return -4;}
static double rn(void *p){struct reader_fixture *f=p;f->clock+=0.125;return f->clock;}
static int32_t rd(void *p,uint32_t n){struct reader_fixture *f=p;++f->delays;f->delay_total+=n;return -7;}
static int32_t rr(void *p,struct vn135_temperature_sensor *s,uint32_t reg,uint8_t *out)
{struct reader_fixture *f=p;(void)s;CHECK(reg==0);++f->reads;if(!f->no_write)*out=f->raw;return f->fail_all?-1:0;}
static uint32_t rp(void *p){return ((struct reader_fixture *)p)->platform;}
static int32_t rt(void *p,uint32_t ep,uint32_t address,uint32_t mode,
                  uint32_t reg,uint8_t *out,uint32_t length)
{
    struct reader_fixture *f=p;uint32_t k=f->transfers++;
    CHECK(address<=255);CHECK(length>=1&&length<=3);
    CHECK(ep==0xfe440||ep==0xfe518||ep==0xfe528||ep==0xfe538||ep==0xfaeec);
    if(ep==0xfe518){CHECK(mode==0);CHECK((!out&&length==1)||(out&&length==2));}
    else CHECK(out!=NULL);
    if(ep==0xfe440||ep==0xfe528||ep==0xfaeec){
        if(!f->no_write)*out=reg==3?(uint8_t)(f->config_busy?4:0):reg==1?f->remote:f->raw;
    }
    return f->fail_all||(int)k==f->fail_at?-1:0;
}
static int32_t rc(void *p,const char *a,const char *b)
{struct reader_fixture *f=p;++f->models;CHECK(strcmp(b,"u3s21exph")==0);return strcmp(a,b);}
static int32_t ro(void *p,uint32_t chain,uint32_t index,int32_t *out)
{struct reader_fixture *f=p;++f->offsets;CHECK(chain==4);CHECK(index<258);*out=f->offset;return 1;}
static const struct vn135_temperature_ops temperature_ops={.lock=rm,.unlock=ru,.now=rn,.read_register=rr,.delay_ms=rd};
static const struct vn135_reader_ops reader_ops={&temperature_ops,rp,rt,rc,ro};
static struct vn135_temperature_sensor sensor(uint32_t kind)
{
    struct vn135_temperature_sensor s;
    memset(&s,0,sizeof(s));s.index=3;s.address=76;s.state=2;s.access_kind=kind;
    s.sample=50;s.corrected=55;s.local_offset=5;s.remote_offset=-3;s.sampled_at=1;
    return s;
}
static int32_t sb(uint8_t v){return v<128?(int32_t)v:(int32_t)v-256;}
static void reader_tests(void)
{
    unsigned plat,kind,v,remote,st;
    struct vn135_reader_context c={3,112,1,1,"u3s21exph"};
    for(plat=0;plat<2;++plat)for(kind=0;kind<6;++kind)
    for(remote=0;remote<2;++remote)for(v=0;v<256;++v){
        struct {uint64_t left;struct vn135_temperature_sensor s;uint64_t right;} g={0x1122334455667788ULL,{0},0x8877665544332211ULL};
        struct {uint64_t left;struct vn135_reader_scratch s;uint64_t right;} x={0xabcdef1234567890ULL,{{0}},0x12345678abcdef90ULL};
        struct reader_fixture f={.platform=plat,.fail_at=-1,.raw=(uint8_t)v,.remote=(uint8_t)(255-v),.offset=5};
        int ret;g.s=sensor(kind);g.s.remote_enabled=(uint8_t)remote;
        ret=vn135_temperature_read_135(&g.s,&c,&reader_ops,&f,&x.s);
        if(remote&&kind!=4){CHECK(ret==-1&&g.s.state==3&&f.transfers==0);}
        else if(kind==2||kind==5){CHECK(ret==-1&&g.s.state==2&&f.transfers==0);}
        else{
            int32_t expected=sb(kind==1?(uint8_t)(v-64): (uint8_t)v);
            CHECK(ret==0&&g.s.sample==expected&&g.s.failures==0);
            if(remote){int32_t t=(int32_t)(-5.0+(double)sb((uint8_t)(255-v))*0x1.2666666666666p+0);CHECK(g.s.corrected==t-3);}
            else CHECK(g.s.corrected==expected+5);
        }
        CHECK(g.left==0x1122334455667788ULL&&g.right==0x8877665544332211ULL);
        CHECK(x.left==0xabcdef1234567890ULL&&x.right==0x12345678abcdef90ULL);
        CHECK(f.locks==f.unlocks);++scenarios;
    }
    for(plat=0;plat<2;++plat)for(st=0;st<4;++st){
        struct vn135_temperature_sensor s=sensor(4);struct vn135_reader_scratch x={{0}};
        struct reader_fixture f={.platform=plat,.fail_at=-1,.fail_all=1};
        s.failures=(int32_t)st;s.remote_enabled=1;
        CHECK(vn135_temperature_read_135(&s,&c,&reader_ops,&f,&x)==-1);
        CHECK(f.transfers==3&&f.delay_total==60&&s.failures==(int32_t)st+1);
        CHECK(s.state==(st>=2?3u:2u));++scenarios;
    }
    for(plat=0;plat<2;++plat)for(v=0;v<10;++v){
        struct vn135_temperature_sensor s=sensor(4);struct vn135_reader_scratch x={{0}};
        struct reader_fixture f={.platform=plat,.fail_at=(int)v,.raw=74,.remote=80,.offset=5};
        s.remote_enabled=1;
        CHECK(vn135_temperature_read_135(&s,&c,&reader_ops,&f,&x)==0);
        CHECK(s.sample==74&&f.locks==f.unlocks);++scenarios;
    }
    for(kind=0;kind<6;++kind)for(st=0;st<2;++st){
        struct vn135_temperature_sensor s=sensor(kind);struct vn135_reader_scratch x={{0}};
        struct reader_fixture f={.fail_at=-1,.raw=74};int ret;
        s.skip_initial_read=(uint8_t)st;
        ret=vn135_temperature_initialize_direct_135(&s,&c,&reader_ops,&f,&x);
        CHECK(ret==((kind==0||kind==3||(kind==4&&!st))?0:-1));++scenarios;
    }
    for(plat=0;plat<2;++plat){
        struct vn135_temperature_sensor s=sensor(4);struct vn135_reader_scratch x={{0}};
        struct reader_fixture f={.platform=plat,.fail_at=-1,.raw=74,.remote=80,.offset=5};
        s.remote_enabled=1;CHECK(vn135_temperature_read_135(&s,&c,&reader_ops,&f,&x)==0);
        CHECK(f.delay_total==400&&f.delays==9&&f.transfers==7);++scenarios;
    }
}
struct shutdown_fixture {
    struct vn135_shutdown_state *s;
    unsigned try_count,lock_failures,cancels,joins,detaches,off_calls,resets,marks;
    unsigned tick,off_tick,last_cancel_tick,last_join_tick;
    uint32_t self;
    int off_rc,unlock_rc,mutate_cancel;
};
static int32_t sl(void *p){struct shutdown_fixture *f=p;return ++f->try_count<=f->lock_failures?-1:0;}
static int32_t su(void *p){return ((struct shutdown_fixture *)p)->unlock_rc;}
static int32_t sd(void *p,uint32_t n){(void)p;CHECK(n==100);return -1;}
static uint32_t ss(void *p){return ((struct shutdown_fixture *)p)->self;}
static int32_t sx(void *p,uint32_t h){struct shutdown_fixture *f=p;(void)h;++f->detaches;return -1;}
static int32_t sc(void *p,uint32_t h)
{
    struct shutdown_fixture *f=p;unsigned i;++f->cancels;f->last_cancel_tick=++f->tick;
    for(i=0;i<9;++i)if(f->s->threads[i].handle==h){CHECK(!f->s->threads[i].running);if(f->mutate_cancel)f->s->threads[i].handle+=5000;break;}
    return -7;
}
static int32_t sj(void *p,uint32_t h,uint32_t *out)
{
    struct shutdown_fixture *f=p;++f->joins;f->last_join_tick=++f->tick;
    if(out){CHECK(!f->s->threads[9].running);*out=0xbeef;}
    else if(f->mutate_cancel)CHECK(h>=5000);
    return -9;
}
static int32_t sn(void *p,const char *name){(void)p;CHECK(!strcmp(name,"failure@btm"));return -1;}
static uint32_t step(void *p,uint32_t op,uint32_t arg)
{
    struct shutdown_fixture *f=p;(void)f;(void)arg;
    if(op==0xfdeb4)return 1;
    if(op==0xfdfbc)return 0;
    if(op==0x19c)return 0x1234;
    return 0;
}
static int32_t clean(void *p,uint32_t out[2],uint32_t v){(void)p;CHECK(v==0x1234);out[0]=1;out[1]=2;return -1;}
static int32_t mark(void *p,const char *path){struct shutdown_fixture *f=p;CHECK(!strcmp(path,"/config/stopped"));CHECK(f->s->state==6);++f->marks;return -1;}
static int32_t off(void *p){struct shutdown_fixture *f=p;++f->off_calls;f->off_tick=++f->tick;return f->off_rc;}
static int32_t count(void *p){(void)p;return 3;}
static int32_t reset(void *p,uint32_t i){struct shutdown_fixture *f=p;CHECK(i<3);++f->resets;return -1;}
static const struct vn135_shutdown_ops stop_ops={.trylock=sl,.unlock=su,.delay_ms=sd,.self=ss,.detach=sx,.cancel=sc,.join=sj,.set_thread_name=sn,.step=step,.cleanup=clean,.mark_stopped=mark};
static const struct vn135_backend_power_ops power_ops={.psu_off=off,.chain_count=count,.reset_chain=reset};
static void shutdown_tests(void)
{
    unsigned flag,fail,worker,i,state;
    for(flag=0;flag<256;++flag)for(fail=0;fail<2;++fail)for(worker=0;worker<2;++worker){
        struct {uint64_t before;struct vn135_shutdown_state s;uint64_t after;} g;
        int32_t fans[6]={-999,2000,3000,4000,5000,999};
        struct vn135_shutdown_scratch scratch={{0,0},0};
        struct shutdown_fixture f={0};memset(&g,0,sizeof(g));g.before=0x123456789abcdef0ULL;g.after=~g.before;
        g.s.state=2;g.s.model_chip_selector=4;g.s.persistent_marker=1;g.s.fan_count=4;g.s.fan_readings=fans+1;
        g.s.power.byte_ff1=1;g.s.power.word_20c=13500;
        for(i=0;i<10;++i){g.s.threads[i].handle=100+i;g.s.threads[i].running=(uint8_t)flag;}
        f.s=&g.s;f.self=999;f.mutate_cancel=1;f.lock_failures=flag%4;f.off_rc=fail?-7:0;f.unlock_rc=-9;
        if(worker)CHECK(vn135_backend_shutdown_worker_135(&g.s,&stop_ops,&power_ops,&f,&scratch)==0);
        else vn135_backend_shutdown_135(&g.s,&stop_ops,&power_ops,&f,&scratch);
        CHECK(g.s.state==6&&f.off_calls==1&&f.marks==1);
        CHECK(f.resets==(fail?0u:3u));CHECK(g.s.power.byte_ff1==(fail?1:0));
        CHECK(g.s.power.word_20c==(fail?13500u:0u));
        CHECK(f.cancels==(flag?9u:0u)&&f.joins==(flag?10u:0u));
        CHECK(f.off_tick>f.last_cancel_tick);
        if(flag)CHECK(f.last_join_tick>f.off_tick);
        CHECK(f.detaches==worker);CHECK(fans[0]==-999&&fans[5]==999);
        for(i=1;i<5;++i)CHECK(fans[i]==0);
        CHECK(g.before==0x123456789abcdef0ULL&&g.after==~g.before);++scenarios;
    }
    for(state=4;state<=6;state+=2){
        struct vn135_shutdown_state s={0};struct vn135_shutdown_scratch x={{0,0},0};struct shutdown_fixture f={0};
        s.state=state;s.power.byte_ff1=1;f.s=&s;
        vn135_backend_shutdown_135(&s,&stop_ops,&power_ops,&f,&x);
        CHECK(s.state==state&&s.power.byte_ff1==1&&f.off_calls==0&&f.marks==0);++scenarios;
    }
}
int main(void){reader_tests();shutdown_tests();printf("THERMAL_COMPLETION135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no real_threads=no\n",scenarios,checks);return 0;}
