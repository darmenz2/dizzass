/* Reuse the preceding bounded transport/cache fixture without changing it. */
#define main dispatch_fixture_main
#include "test_transport_dispatch_135.c"
#undef main
#include "integration/bm1368_pulse_width_135.h"
#include "integration/chain_frequency_135.h"

static uint32_t expected_word(uint32_t w,uint32_t d)
{
    return UINT32_C(0x80008000)+(w%4u)*64u+(d%8u)*8u;
}
struct direct_pulse {
    uint32_t guard0;
    struct vn135_bm1368_frequency_device device;
    struct vn135_bm1368_pulse_ops ops;
    uint32_t guard1,word;
    int32_t rc;
    unsigned writes,logs,mutate,reenter,depth;
};
static int32_t scripted_register(void *p,struct vn135_bm1368_frequency_device *d,
    uint32_t mode,const vn135_chip_reference *chip,uint32_t reg,uint32_t word)
{
    struct direct_pulse *f=p;
    CHECK(d==&f->device && mode==1 && !chip && reg==0x3c && word==f->word);f->writes++;
    if(f->mutate)f->device.index=17;
    if(f->reenter && !f->depth){
        f->depth=1;
        CHECK(vn135_bm1368_set_pulse_width_135(d,(word>>6)&3u,(word>>3)&7u,0,&f->ops,f)==0);
        f->depth=0;
    }
    return f->depth?0:f->rc;
}
static void scripted_log(void *p,uint32_t line,uint32_t index)
{
    struct direct_pulse *f=p;
    CHECK(line==((f->logs%2)?569u:387u) && index==f->device.index+1u);
    CHECK(f->writes>0);f->logs++;
    if(f->mutate)f->device.index=UINT32_MAX;
}
static void test_pulse_direct(void)
{
    const int32_t rc[]={0,1,-1,11,INT32_MIN,INT32_MAX};
    for(unsigned w=0;w<256;w++)for(unsigned d=0;d<16;d++)for(unsigned k=0;k<6;k++){
        struct direct_pulse f={0};f.guard0=f.guard1=GUARD;f.word=expected_word(w,d);f.rc=rc[k];
        f.ops=(struct vn135_bm1368_pulse_ops){scripted_register,scripted_log};f.mutate=k&1;
        f.device.index=UINT32_MAX-1;
        CHECK(vn135_bm1368_set_pulse_width_135(&f.device,w,d,UINT32_MAX,&f.ops,&f)==(rc[k]?-1:0));
        CHECK(f.writes==1 && f.logs==(rc[k]?2u:0u) && f.guard0==GUARD && f.guard1==GUARD);cases++;
    }
    for(unsigned n=0;n<32;n++){
        struct direct_pulse f={0};f.word=expected_word(UINT32_C(1)<<n,~(UINT32_C(1)<<n));f.rc=-1;
        f.ops=(struct vn135_bm1368_pulse_ops){scripted_register,NULL};
        CHECK(vn135_bm1368_set_pulse_width_135(&f.device,UINT32_C(1)<<n,~(UINT32_C(1)<<n),n,&f.ops,&f)==-1);
        CHECK(f.writes==1 && !f.logs);cases++;
    }
    struct direct_pulse f={0};f.word=expected_word(3,7);f.rc=1;f.reenter=1;f.mutate=1;
    f.ops=(struct vn135_bm1368_pulse_ops){scripted_register,scripted_log};
    CHECK(vn135_bm1368_set_pulse_width_135(&f.device,3,7,1,&f.ops,&f)==-1);
    CHECK(f.writes==2 && f.logs==2);cases++;
}
struct pulse_pipeline {
    struct fixture f;
    struct vn135_bm1368_pulse_binding binding;
    struct vn135_bm1368_pulse_ops ops;
    unsigned logs,mutate_index;
};
static int32_t real_register(void *p,struct vn135_bm1368_frequency_device *device,
    uint32_t mode,const vn135_chip_reference *chip,uint32_t reg,uint32_t word)
{
    struct pulse_pipeline *f=p;
    return vn135_bm1368_pulse_register_135(&f->binding,device,mode,chip,reg,word);
}
static void pulse_log(void *p,uint32_t line,uint32_t index)
{
    struct pulse_pipeline *f=p;CHECK(index==f->f.device.index+1u);
    CHECK(line==(f->logs?569u:387u));f->logs++;
    if(f->mutate_index)f->f.device.index=UINT32_MAX;
}
static void init_pipeline(struct pulse_pipeline *p,unsigned io,uint32_t w,uint32_t d)
{
    memset(p,0,sizeof *p);init(&p->f,io);p->f.total=11;
    size_t written=0;
    CHECK(dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_CONFIG,1,0,0x3c,
        expected_word(w,d),p->f.expected,11,&written)==0 && written==11);
    p->binding=(struct vn135_bm1368_pulse_binding){&p->f.reg_ops,&p->f};
    p->ops=(struct vn135_bm1368_pulse_ops){real_register,pulse_log};
}
static void check_cache(struct fixture *f,uint32_t word,int changed,const vn135_reg_table *before)
{
    for(unsigned i=0;i<64;i++){
        uint32_t want=changed && before->entries[i].address==0x3c?word:before->entries[i].value;
        CHECK(f->chain.common.entries[i].address==before->entries[i].address);
        CHECK(f->chain.common.entries[i].value==want);
        for(unsigned j=0;j<2;j++)CHECK(f->chips[j].entries[i].value==want);
    }
}
static void test_pulse_pipeline(void)
{
    for(unsigned w=0;w<8;w++)for(unsigned d=0;d<16;d++)
    for(unsigned io=0;io<7;io++)for(unsigned mutate=0;mutate<4;mutate++){
        struct pulse_pipeline p;init_pipeline(&p,io,w,d);vn135_reg_table before=p.f.chain.common;
        p.f.mutate_device=mutate&1;p.f.mutate_ready=mutate&2;p.mutate_index=1;
        int ok=io<2 && mutate==0;
        CHECK(vn135_bm1368_set_pulse_width_135(&p.f.device,w,d,1,&p.ops,&p)==(ok?0:-1));
        CHECK(p.logs==(ok?0u:2u));CHECK(p.f.logs==(io>=2));
        CHECK(p.f.chaincalls==(io<2) && !p.f.chipcalls);finished(&p.f);
        check_cache(&p.f,expected_word(w,d),ok,&before);cases++;
    }
    struct pulse_pipeline p;init_pipeline(&p,0,1,2);p.f.no_memory=1;
    CHECK(vn135_bm1368_set_pulse_width_135(&p.f.device,1,2,0,&p.ops,&p)==-1);
    CHECK(p.logs==2 && p.f.logs==1 && !p.f.chaincalls);finished(&p.f);cases++;
}
struct parent_fixture {
    struct pulse_pipeline p;
    struct vn135_general_chain chain;
    struct vn135_route_chip chips[3];
    struct vn135_chain_frequency_methods methods;
    struct vn135_chain_frequency_view view;
    struct vn135_chain_frequency_ops ops;
    unsigned phase,platform,fail_set,parent_logs,pulse_calls;
    uint32_t width,delay;
};
static int32_t parent_set(void *p,struct vn135_general_chain *chain,double frequency)
{
    struct parent_fixture *f=p;(void)frequency;CHECK(chain==&f->chain && f->phase==0);
    f->phase=1;return f->fail_set?-1:0; /* The OTHER method is explicitly scripted. */
}
static int32_t parent_lock(void *p,struct vn135_general_chain *chain)
{
    struct parent_fixture *f=p;CHECK(chain==&f->chain && f->phase==1);f->phase=2;return -1;
}
static int32_t parent_unlock(void *p,struct vn135_general_chain *chain)
{
    struct parent_fixture *f=p;CHECK(chain==&f->chain && f->phase==2);f->phase=3;return -1;
}
static uint32_t parent_platform(void *p){struct parent_fixture *f=p;CHECK(f->phase==3);return f->platform;}
static int32_t parent_pulse(void *p,struct vn135_general_chain *chain,uint32_t w,uint32_t d,uint32_t fourth)
{
    struct parent_fixture *f=p;CHECK(f->phase==3 && chain==&f->chain && w==f->width && d==f->delay && fourth==1);
    f->pulse_calls++;
    return vn135_bm1368_set_pulse_width_135(&f->p.f.device,w,d,fourth,&f->p.ops,&f->p);
}
static void parent_log(void *p,uint32_t line,uint32_t index,double frequency)
{
    struct parent_fixture *f=p;(void)frequency;CHECK(line==(f->fail_set?1060u:1074u));
    CHECK(index==f->chain.thermal.index+1u);f->parent_logs++;
}
static void test_parent(void)
{
    const double freqs[]={0,449,449.99,450,450.5,635.75};
    for(unsigned fi=0;fi<6;fi++)for(unsigned io=0;io<7;io++)
    for(unsigned platform=2;platform<=4;platform+=2)for(unsigned fail=0;fail<2;fail++){
        struct parent_fixture f={0};f.width=5;f.delay=freqs[fi]<450?4:7;
        init_pipeline(&f.p,io,f.width,f.delay);f.platform=platform;f.fail_set=fail;
        f.chain.thermal.present=1;f.chain.thermal.state=2;f.chain.thermal.index=4;
        f.chain.detected_8c=3;f.chain.thermal.chips=f.chips;
        f.methods=(struct vn135_chain_frequency_methods){parent_set,parent_pulse};
        f.view=(struct vn135_chain_frequency_view){&f.chain,&f.methods};
        f.ops=(struct vn135_chain_frequency_ops){parent_lock,parent_unlock,parent_platform,parent_log};
        int error=fail || (platform==4 && io>=2);
        CHECK(vn135_chain_set_frequency_135(&f.view,7,f.width,freqs[fi],&f.ops,&f)==(error?-1:0));
        CHECK(f.parent_logs==(unsigned)error);
        if(!fail){
            CHECK(f.phase==3);
            for(unsigned i=0;i<3;i++)CHECK(f.chips[i].word_08==(uint32_t)freqs[fi]);
            CHECK(f.chain.thermal.cleared_words[0]==(uint32_t)freqs[fi]);
        }
        CHECK(f.pulse_calls==(unsigned)(!fail && platform==4));
        if(f.pulse_calls)finished(&f.p.f);else CHECK(!f.p.f.allocations);
        cases++;
    }
}
int main(void)
{
    test_pulse_direct();test_pulse_pipeline();test_parent();
    printf("BM1368_PULSE135_NATIVE_PASS cases=%u checks=%u parent_compositions=168\n",cases,checks);return 0;
}
