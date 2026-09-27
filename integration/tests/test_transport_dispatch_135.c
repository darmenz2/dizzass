/* Native bounded dispatch/composition checks; no real UART, mutex or threads. */
#include "integration/transport_dispatch_135.h"
#include "integration/bm1368_register_write_135.h"
#include "integration/bm1368_control.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>

static unsigned cases,checks;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"line %d: %s\n",__LINE__,#x);assert(x);} } while(0)
#define GUARD UINT32_C(0x891327af)
struct fixture {
    uint32_t guard0;
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    vn135_uart uart;
    vn135_uart_ops uart_ops;
    vn135_aml_transport frame_ops;
    struct vn135_aml_uart_binding_135 binding;
    struct vn135_transport_dispatch_135 table;
    vn135_reg_cache cache;
    vn135_reg_chain chain;
    vn135_reg_table chips[2];
    struct vn135_bm1368_register_ops reg_ops;
    uint32_t guard1;
    uint8_t storage[1028],expected[1026],input[1024];
    uint32_t total;
    int32_t error;
    unsigned scenario,no_memory,write_count,allocations,releases,errno_calls;
    unsigned outer,inner,outerlocks,innerlocks,sleeps,chaincalls,chipcalls,logs;
    unsigned mutate_device,mutate_ready,mutate_source;
};
static void *alloc_frame(void *p,size_t n)
{
    struct fixture *f=p;CHECK(n==f->total && n<=1026);
    CHECK(!f->outer && !f->inner);f->allocations++;
    if(f->no_memory)return NULL;
    memset(f->storage,0x97,sizeof f->storage);return f->storage+1;
}
static void release_frame(void *p,void *ptr)
{
    struct fixture *f=p;CHECK(ptr==f->storage+1 && !f->outer && !f->inner);
    CHECK(f->storage[0]==0x97 && f->storage[f->total+1]==0x97);f->releases++;
}
static void outer_lock(void *p)
{
    struct fixture *f=p;CHECK(!f->outer && !f->inner);f->outer=1;f->outerlocks++;
    if(f->mutate_source)memset(f->input,0x19,sizeof f->input);
}
static void outer_unlock(void *p)
{
    struct fixture *f=p;CHECK(f->outer && !f->inner);f->outer=0;
}
static void inner_lock(void *p)
{
    struct fixture *f=p;CHECK(f->outer && !f->inner);f->inner=1;f->innerlocks++;
}
static void inner_unlock(void *p)
{
    struct fixture *f=p;CHECK(f->outer && f->inner);f->inner=0;
}
static int32_t os_write(void *p,int32_t fd,const uint8_t *buf,uint32_t n)
{
    struct fixture *f=p;CHECK(f->outer && f->inner && n==f->total);
    CHECK(fd==f->uart.fd && buf==f->storage+1 && !memcmp(buf,f->expected,n));
    f->write_count++;f->uart.fd=29; /* Next retry must reread fd. */
    if(f->mutate_device)f->device.index=1;
    if(f->mutate_ready)f->cache.initialized=0;
    switch(f->scenario){
    case 0:return (int32_t)n;
    case 1:if(f->write_count==1){f->error=11;return -1;}return (int32_t)n;
    case 2:f->error=11;return 1;
    case 3:f->error=4;return -1;
    case 4:f->error=5;return 1;
    case 5:f->error=0;return (int32_t)n+1;
    case 6:return -1;
    default:CHECK(0);return -1;
    }
}
static int32_t *get_errno(void *p)
{
    struct fixture *f=p;CHECK(f->outer && !f->inner);f->errno_calls++;return &f->error;
}
static void sleep_ms(void *p,uint32_t n)
{
    struct fixture *f=p;CHECK(f->outer && !f->inner && n==20);f->sleeps++;
    if(f->scenario==6)f->error=4;
}
static int32_t send_reg(void *p,struct vn135_bm1368_frequency_device *device,
    const uint8_t *payload,size_t n)
{
    struct fixture *f=p;CHECK(device==&f->device && n==9);
    return vn135_transport_send_135(&f->table,device,payload,(uint32_t)n);
}
static int32_t cache_chain(void *p,int32_t chain,uint32_t reg,uint32_t value)
{
    struct fixture *f=p;CHECK(!f->outer && !f->inner && f->releases==1);
    f->chaincalls++;return vn135_bm1368_register_cache_chain_135(&f->cache,chain,reg,value);
}
static int32_t cache_chip(void *p,int32_t chain,int32_t chip,uint32_t reg,uint32_t value)
{
    struct fixture *f=p;CHECK(!f->outer && !f->inner && f->releases==1);
    f->chipcalls++;return vn135_bm1368_register_cache_chip_135(&f->cache,chain,chip,reg,value);
}
static void reg_log(void *p,uint32_t line,uint32_t index)
{
    struct fixture *f=p;CHECK(line==350 && index==f->device.index+1u);f->logs++;
}
static void init(struct fixture *f,unsigned scenario)
{
    memset(f,0,sizeof *f);f->guard0=f->guard1=GUARD;f->error=11;f->scenario=scenario;
    f->uart=(vn135_uart)VN135_UART_INITIALIZER;f->uart.fd=17;
    f->uart_ops=(vn135_uart_ops){.context=f,.write=os_write,.error_number=get_errno,
        .lock=inner_lock,.unlock=inner_unlock,.sleep_ms=sleep_ms};
    f->frame_ops=(vn135_aml_transport){.context=f,.allocate=alloc_frame,.release=release_frame,
        .lock=outer_lock,.unlock=outer_unlock}; /* No frame write: reused UART supplies it. */
    f->binding=(struct vn135_aml_uart_binding_135){&f->device,&f->uart,&f->frame_ops,&f->uart_ops};
    f->table=(struct vn135_transport_dispatch_135){vn135_aml_uart_send_135,&f->binding};
    f->chip=(vn135_chip_reference){1,0x123};
    f->cache.chains=&f->chain;f->cache.chain_count=1;f->cache.initialized=1;
    f->chain.chips=f->chips;f->chain.chip_count=2;
    CHECK(vn135_reg_cache_defaults(4,&f->chain.common)==0);
    f->chips[0]=f->chips[1]=f->chain.common;
    f->reg_ops=(struct vn135_bm1368_register_ops){send_reg,cache_chain,cache_chip,reg_log};
}
static void finished(struct fixture *f)
{
    static const unsigned writes[]={1,2,5,1,1,1,2},sleeps[]={0,1,5,0,0,0,1};
    CHECK(!f->inner && !f->outer && f->guard0==GUARD && f->guard1==GUARD);
    CHECK(f->allocations==1);
    if(f->no_memory){CHECK(!f->write_count && !f->releases && !f->outerlocks);return;}
    CHECK(f->write_count==writes[f->scenario] && f->innerlocks==f->write_count);
    CHECK(f->outerlocks==1 && f->releases==1 && f->sleeps==sleeps[f->scenario]);
    CHECK(f->errno_calls==(f->scenario!=0));
}
struct direct_fixture {
    struct vn135_transport_dispatch_135 table;
    void *device;const uint8_t *payload;uint32_t length;
    int32_t result;unsigned calls,second,reenter;
};
static int32_t direct_second(void *p,void *device,const uint8_t *payload,uint32_t n)
{
    struct direct_fixture *f=p;CHECK(device==f->device && payload==f->payload && n==f->length);
    f->second++;return INT32_MIN;
}
static int32_t direct_first(void *p,void *device,const uint8_t *payload,uint32_t n)
{
    struct direct_fixture *f=p;CHECK(device==f->device && payload==f->payload && n==f->length);
    f->calls++;f->table.send_payload=direct_second;
    if(f->reenter)CHECK(vn135_transport_send_135(&f->table,device,payload,n)==INT32_MIN);
    return f->result;
}
static void test_direct(void)
{
    const int32_t results[]={0,1,-1,-2,11,INT32_MIN,INT32_MAX};
    const uint32_t lengths[]={0,1,9,UINT32_MAX};
    for(unsigned i=0;i<7;i++)for(unsigned j=0;j<4;j++)for(unsigned k=0;k<8;k++){
        struct direct_fixture f={0};uint8_t payload=17;
        f.device=(k&1)?NULL:&f;f.payload=(k&2)?NULL:&payload;
        f.length=lengths[j];f.result=results[i];f.reenter=k&4;
        f.table=(struct vn135_transport_dispatch_135){direct_first,&f};
        CHECK(vn135_transport_send_135(&f.table,f.device,f.payload,f.length)==f.result);
        CHECK(vn135_transport_send_135(&f.table,f.device,f.payload,f.length)==INT32_MIN);
        CHECK(f.calls==1 && f.second==1u+(f.reenter!=0));cases++;
    }
}
static void test_pipeline(void)
{
    for(unsigned n=0;n<=256;n++)for(unsigned scenario=0;scenario<7;scenario++){
        struct fixture f;init(&f,scenario);f.total=n+2;f.mutate_source=1;
        f.expected[0]=0x55;f.expected[1]=0xaa;
        for(unsigned j=0;j<n;j++)f.expected[j+2]=f.input[j]=(uint8_t)(j*37+n);
        int32_t rc=vn135_transport_send_135(&f.table,&f.device,f.input,n);
        CHECK(rc==((scenario<2)?0:-1));finished(&f);cases++;
    }
}
static void test_register(void)
{
    const uint32_t modes[]={0,1,2,UINT32_MAX},regs[]={8,0x108};
    for(unsigned mi=0;mi<4;mi++)for(unsigned ri=0;ri<2;ri++)
    for(unsigned s=0;s<7;s++)for(unsigned mutation=0;mutation<4;mutation++){
        struct fixture f;size_t encoded=0;init(&f,s);f.total=11;
        f.mutate_device=mutation&1;f.mutate_ready=mutation&2;
        CHECK(dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_CONFIG,modes[mi]==1u,
            f.chip.wire_address&255u,regs[ri]&255u,0x12345678,f.expected,11,&encoded)==0 && encoded==11);
        int32_t rc=vn135_bm1368_write_register_135(&f.device,modes[mi],&f.chip,
            regs[ri],0x12345678,&f.reg_ops,&f);
        CHECK(rc==((s<2 && !ri && !mutation)?0:-1));finished(&f);
        CHECK(f.logs==(s>=2));CHECK(f.chaincalls==(unsigned)(s<2 && modes[mi]!=0));
        CHECK(f.chipcalls==(unsigned)(s<2 && modes[mi]==0));cases++;
    }
}
static void test_guards(void)
{
    struct fixture f;init(&f,0);f.total=11;
    CHECK(vn135_aml_uart_send_135(NULL,NULL,NULL,UINT32_MAX)==-1);
    CHECK(vn135_aml_uart_send_135(NULL,&f.device,f.input,9)==-2);
    CHECK(vn135_aml_uart_send_135(&f.binding,&f.chip,f.input,9)==-2);
    CHECK(vn135_aml_uart_send_135(&f.binding,&f.device,NULL,9)==-2);
    CHECK(vn135_aml_uart_send_135(&f.binding,&f.device,f.input,UINT32_MAX)==-2);
    CHECK(!f.allocations && !f.write_count);
    f.binding.uart=NULL;CHECK(vn135_aml_uart_send_135(&f.binding,&f.device,f.input,9)==-2);
    f.binding.uart=&f.uart;f.uart_ops.write=NULL;
    CHECK(vn135_aml_uart_send_135(&f.binding,&f.device,f.input,9)==-2);
    init(&f,0);f.total=11;f.no_memory=1;
    CHECK(vn135_transport_send_135(&f.table,&f.device,f.input,9)==-1);finished(&f);cases++;
}
int main(void)
{
    test_direct();test_pipeline();test_register();test_guards();
    printf("TRANSPORT_DISPATCH135_NATIVE_PASS cases=%u checks=%u\n",cases,checks);return 0;
}
