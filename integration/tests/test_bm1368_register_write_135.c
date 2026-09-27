/* Offline register transaction and existing PLL/cache composition. */
#include "integration/bm1368_register_write_135.h"
#include "integration/bm1368_control.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

static unsigned scenarios,checks;
#define CHECK(x) do { ++checks; if(!(x)) { fprintf(stderr,"check failed line %d: %s\n",__LINE__,#x); assert(x); } } while(0)
#define GUARD UINT32_C(0x29a4b17e)
struct fixture {
    uint32_t guard0;
    struct vn135_bm1368_frequency_device device;
    uint32_t guard1;
    vn135_chip_reference chip;
    uint32_t guard2;
    vn135_reg_cache cache;
    vn135_reg_chain chains[2];
    vn135_reg_table chips[2][3];
    uint32_t guard3;
    struct vn135_bm1368_register_ops ops;
    uint32_t mode,reg,value,mutate;
    int32_t send_results[2],cache_result;
    unsigned scripted,send_count,chain_count,chip_count,log_count,pll_log_count;
    unsigned depth,reenter,reentered,pll_mode;
    uint8_t packets[8][9];
    unsigned events[32],event_count;
};
static int32_t run(struct fixture *f,const vn135_chip_reference *chip)
{
    return vn135_bm1368_write_register_135(&f->device,f->mode,chip,
        f->reg,f->value,&f->ops,f);
}
static int32_t signed_word(uint32_t u)
{
    return u<=INT32_MAX ? (int32_t)u : (int32_t)((int64_t)u-INT64_C(4294967296));
}
static void event(struct fixture *f,unsigned e)
{
    CHECK(f->event_count<32);f->events[f->event_count++]=e;
}
static int32_t send_cb(void *p,struct vn135_bm1368_frequency_device *device,
    const uint8_t *payload,size_t n)
{
    struct fixture *f=p;
    unsigned k=f->send_count++;
    uint8_t crc=0;
    CHECK(device==&f->device && n==9 && k<8);
    event(f,1);memcpy(f->packets[k],payload,9);
    CHECK(payload[1]==9);
    CHECK(vn135_crc5_bits(payload,8,64,&crc)==0 && crc==payload[8]);
    if(!f->pll_mode){
        CHECK(payload[0]==(f->mode==1u?0x51:0x41));
        CHECK(payload[3]==(uint8_t)f->reg);
        CHECK(payload[4]==(uint8_t)(f->value>>24));
        CHECK(payload[5]==(uint8_t)(f->value>>16));
        CHECK(payload[6]==(uint8_t)(f->value>>8));
        CHECK(payload[7]==(uint8_t)f->value);
    }
    if(f->mutate&1u)f->device.index=0;
    if(f->mutate&2u)f->chip.cache_index=0;
    if(f->mutate&4u)f->chip.wire_address=0x456;
    if(f->mutate&8u)f->cache.initialized=0;
    if(f->mutate&16u)f->device.index=UINT32_MAX;
    if(f->mutate&32u)f->cache.initialized=(uint8_t)(k!=0);
    if(f->reenter && !f->depth){
        f->depth=1;CHECK(run(f,&f->chip)==0);f->depth=0;f->reentered++;
        /* The inner stack payload must not overwrite the outer one. */
        CHECK(memcmp(f->packets[k],payload,9)==0);
    }
    return f->send_results[k<2?k:1];
}
static int32_t chain_cb(void *p,int32_t chain,uint32_t reg,uint32_t value)
{
    struct fixture *f=p;f->chain_count++;event(f,2);
    CHECK(chain==signed_word(f->device.index));
    CHECK(reg==(f->pll_mode?8u:f->reg));
    if(!f->pll_mode)CHECK(value==f->value);
    return f->scripted ? f->cache_result :
        vn135_bm1368_register_cache_chain_135(&f->cache,chain,reg,value);
}
static int32_t chip_cb(void *p,int32_t chain,int32_t chip,uint32_t reg,uint32_t value)
{
    struct fixture *f=p;f->chip_count++;event(f,3);
    CHECK(chain==signed_word(f->device.index) && reg==f->reg && value==f->value);
    return f->scripted ? f->cache_result :
        vn135_bm1368_register_cache_chip_135(&f->cache,chain,chip,reg,value);
}
static void log_cb(void *p,uint32_t line,uint32_t index)
{
    struct fixture *f=p;f->log_count++;event(f,4);
    CHECK(line==350 && index==f->device.index+1u);
}
static void init(struct fixture *f)
{
    memset(f,0,sizeof *f);
    f->guard0=f->guard1=f->guard2=f->guard3=GUARD;
    f->device.index=1;f->chip.cache_index=2;f->chip.wire_address=0x123;
    f->mode=1;f->reg=8;f->value=0x12345678;
    f->cache.chains=f->chains;f->cache.chain_count=2;f->cache.initialized=1;
    for(int i=0;i<2;++i){
        CHECK(vn135_reg_cache_defaults(4,&f->chains[i].common)==0);
        f->chains[i].chips=f->chips[i];f->chains[i].chip_count=3;
        for(int j=0;j<3;++j)f->chips[i][j]=f->chains[i].common;
    }
    f->ops=(struct vn135_bm1368_register_ops){send_cb,chain_cb,chip_cb,log_cb};
}
static void guards(const struct fixture *f)
{
    CHECK(f->guard0==GUARD && f->guard1==GUARD && f->guard2==GUARD && f->guard3==GUARD);
    CHECK(f->cache.chains==f->chains && f->cache.chain_count==2);
    for(int i=0;i<2;++i)CHECK(f->chains[i].chips==f->chips[i] && f->chains[i].chip_count==3);
}
static int find_slot(const vn135_reg_table *t,uint32_t reg)
{
    for(int i=0;i<64;++i)if(t->entries[i].address==reg)return i;
    return -1;
}
static void transaction(uint32_t mode,uint32_t reg,unsigned null_chip,
    uint32_t mutate,int32_t send_result,unsigned scripted,int32_t cache_result)
{
    struct fixture f;
    vn135_reg_table common[2],chips[2][3];
    init(&f);f.mode=mode;f.reg=reg;f.mutate=mutate;f.scripted=scripted;
    f.cache_result=cache_result;f.send_results[0]=send_result;
    for(int i=0;i<2;++i)common[i]=f.chains[i].common;
    memcpy(chips,f.chips,sizeof chips);
    int32_t rc=run(&f,null_chip?NULL:&f.chip);
    unsigned chain=(mutate&1u)?0u:1u,chip=null_chip?0u:((mutate&2u)?0u:2u);
    int slot=find_slot(&common[chain],reg);
    int expected=send_result ? -1 : (scripted ? (cache_result? -1:0) :
        ((mutate&(8u|16u)) || reg>255 || slot<0 ? -1:0));
    CHECK(rc==expected && f.send_count==1);
    CHECK(f.log_count==(unsigned)(send_result!=0));
    CHECK(f.chain_count==(unsigned)(!send_result && mode!=0));
    CHECK(f.chip_count==(unsigned)(!send_result && mode==0));
    CHECK(f.packets[0][2]==(null_chip?0:0x23)); /* Address captured before send. */
    if(!expected && !scripted){
        if(mode){
            common[chain].entries[slot].value=f.value;
            for(int j=0;j<3;++j)chips[chain][j].entries[slot].value=f.value;
        }else chips[chain][chip].entries[slot].value=f.value;
    }
    for(int i=0;i<2;++i)CHECK(memcmp(&common[i],&f.chains[i].common,sizeof common[i])==0);
    CHECK(memcmp(chips,f.chips,sizeof chips)==0);
    CHECK(f.events[0]==1 && f.events[1]==(send_result?4u:(mode?2u:3u)) && f.event_count==2);
    guards(&f);scenarios++;
}
static int32_t pll_solve(void *p,const vn135_pll_limits *limits,double requested,vn135_pll_result *out)
{
    (void)p;return vn135_bm1368_frequency_solve_135(NULL,limits,requested,out);
}
static int32_t pll_write(void *p,struct vn135_bm1368_frequency_device *d,
    uint32_t mode,const void *chip,uint32_t reg,uint32_t value)
{
    struct fixture *f=p;CHECK(d==&f->device && mode==1 && !chip && reg==8);
    return vn135_bm1368_write_register_135(d,mode,NULL,reg,value,&f->ops,f);
}
static void pll_log(void *p,uint32_t line,uint32_t index,double requested)
{
    struct fixture *f=p;f->pll_log_count++;
    CHECK(line==972 && index==f->device.index+1u && requested>=400. && requested<=900.);
}
static void composition(void)
{
    for(int frequency=400;frequency<=900;frequency+=25){
        for(unsigned mask=0;mask<8;++mask){
            struct fixture f;init(&f);f.pll_mode=1;
            f.send_results[0]=(mask&1u)?-11:0;f.send_results[1]=(mask&2u)?7:0;
            f.mutate=(mask&4u)?32u:0u;
            struct vn135_bm1368_frequency_ops ops={pll_solve,pll_write,pll_log};
            int rc=vn135_bm1368_set_frequency_135(&f.device,(double)frequency,&ops,&f);
            CHECK(f.send_count==2 && rc==((mask&2u)?-1:0));
            CHECK(memcmp(f.packets[0],f.packets[1],9)==0);
            CHECK(f.pll_log_count==(unsigned)((mask&2u)!=0));
            guards(&f);scenarios++;
        }
    }
}
static void reentry_and_optional_callbacks(void)
{
    struct fixture f;init(&f);f.reenter=1;
    CHECK(run(&f,&f.chip)==0 && f.reentered==1 && f.send_count==2 && f.chain_count==2);
    CHECK(f.event_count==4 && f.events[0]==1 && f.events[1]==1 && f.events[2]==2 && f.events[3]==2);
    guards(&f);scenarios++;
    init(&f);f.send_results[0]=-1;f.ops.cache_chain=NULL;f.ops.cache_chip=NULL;f.ops.log=NULL;
    CHECK(run(&f,NULL)==-1 && f.send_count==1);guards(&f);scenarios++;
    init(&f);f.mode=0;f.ops.cache_chain=NULL;
    CHECK(run(&f,NULL)==0 && f.chip_count==1);guards(&f);scenarios++;
    init(&f);f.mode=2;f.ops.cache_chip=NULL;
    CHECK(run(&f,NULL)==0 && f.chain_count==1);guards(&f);scenarios++;
}
int main(void)
{
    for(uint32_t mode=0;mode<256;++mode)transaction(mode,8,0,0,0,0,0);
    for(uint32_t reg=0;reg<256;++reg){transaction(0,reg,0,0,0,0,0);transaction(1,reg,1,0,0,0,0);}
    const uint32_t regs[]={8,0x25,0x108,UINT32_MAX};
    const int32_t errors[]={0,-1,7,INT32_MIN};
    for(unsigned m=0;m<4;++m)for(unsigned n=0;n<2;++n)for(unsigned r=0;r<4;++r)
        for(unsigned mutate=0;mutate<32;mutate+=3)for(unsigned e=0;e<4;++e)
            transaction(m==3?UINT32_MAX:m,regs[r],n,mutate,errors[e],0,0);
    for(unsigned m=0;m<3;++m)for(unsigned e=0;e<4;++e)
        transaction(m,8,0,7,0,1,errors[e]);
    composition();reentry_and_optional_callbacks();
    printf("BM1368_REGISTER135_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);
    return 0;
}
