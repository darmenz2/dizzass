/* Offline fixture: original-size allocation requests, native projected objects.
 * All callbacks are RAM scripts. No device access or process termination. */
#include "integration/backend_cold_135.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define CAP 4096u
struct allocation {void *p;uint32_t role,n,size,token;};
struct fixture {const uint32_t *in;uint32_t *out,used;struct allocation a[32];unsigned n;};
static uint32_t token(struct fixture *f,const void *p)
{
    unsigned i;
    if(!p)return 0;
    for(i=0;i<f->n;i++)if(f->a[i].p==p)return f->a[i].token;
    for(i=0;i<f->n;i++)if(f->a[i].p && f->a[i].role==VN135_C_CHAINS){
        uintptr_t base=(uintptr_t)f->a[i].p,addr=(uintptr_t)p;
        if(addr>=base && addr<base+f->a[i].n*sizeof(struct vn135_cold_chain) &&
           (addr-base)%sizeof(struct vn135_cold_chain)==0)
            return f->a[i].token+(uint32_t)((addr-base)/sizeof(struct vn135_cold_chain))*800u;
    }
    assert(!"unknown fixture pointer");return 0;
}
static void put(struct fixture *f,uint32_t x){assert(f->used<CAP);f->out[f->used++]=x;}
static void event(struct fixture *f,uint32_t key,uint32_t n,const uint32_t *a)
{uint32_t i;put(f,key);put(f,n);for(i=0;i<n;i++)put(f,a[i]);}
static int32_t result(struct fixture *f,uint32_t key,int32_t fallback)
{return f->in[11]==key?(int32_t)f->in[12]:fallback;}
static void *allocate(void *v,enum vn135_cold_allocation role,uint32_t n,uint32_t size)
{
    struct fixture *f=v;struct allocation *a=&f->a[f->n];unsigned i,idx=0;
    static const uint32_t bases[8]={0x840000,0x840400,0x840800,0x842000,0x843000,0x843800,0x846000,0x848000};
    uint32_t args[4];
    for(i=0;i<f->n;++i)if(f->a[i].role==(uint32_t)role)idx++;
    assert(f->n<32 && n<=8 && size<=0x1348);
    a->role=role;a->n=n;a->size=size;
    a->token=bases[role]+(role==VN135_C_CHIPS?idx*0x800u:role==VN135_C_ITEMS?idx*0x400u:0u);
    if(f->in[10]==f->n){a->p=NULL;a->token=0;}
    else{a->p=calloc(n?n:1,size);assert(a->p);}
    f->n++;args[0]=role;args[1]=n;args[2]=size;args[3]=a->token;
    event(f,0x593bb4,4,args);return a->p;
}
static int32_t load(void *v,struct vn135_cold_profile *p)
{
    struct fixture *f=v;uint32_t arg=token(f,p);unsigned i;
    event(f,0xa7a48,1,&arg);
    p->chip_selector=f->in[3];p->board_word_0=f->in[4];p->board_word_10=(int32_t)f->in[1];
    p->table_count=(int32_t)f->in[2];p->model_word_34=f->in[5];p->model_byte_2c=(uint8_t)f->in[6];
    for(i=0;i<3;++i)p->capability[i]=f->in[7+i];
    /* capabilities are at 7,8,9,14; index 10 is allocation-failure selector. */
    p->capability[3]=f->in[14];return result(f,0xa7a48,0);
}
static int32_t scalar(void *v,uint32_t key,uint32_t a,uint32_t b,uint32_t c)
{
    struct fixture *f=v;uint32_t args[5]={a,b,c,0,0},n=1;
    if(key==0xfe668||key==0xfdfac)n=0;
    else if(key==0xfb994){args[0]=2;args[1]=a;args[2]=b;args[3]=c;args[4]=0;n=5;}
    event(f,key,n,args);
    return result(f,key,key==0xfe668?(int32_t)f->in[0]:key==0xfdfac?(int32_t)f->in[13]:0);
}
static int32_t object(void *v,uint32_t key,void *obj,uint32_t off,void *other,uint32_t a,uint32_t b)
{
    struct fixture *f=v;uint32_t args[5]={token(f,obj)+off,0,0,0,0},n=1;
    const uint32_t attr=0x81efd8;
    switch(key){
    case 0x5a6880:case 0x5a6878:args[0]=attr;break;
    case 0x5a6890:args[0]=attr;args[1]=a;n=2;break;
    case 0x5a60dc:args[1]=a?attr:0;n=2;break;
    case 0x5a6c48:n=3;break;
    case 0x82048:args[1]=token(f,other);args[2]=a;n=3;break;
    case 0x5c4dc:case 0x49c98:args[1]=a;n=2;break;
    case 0xd21dc:args[3]=args[0];args[0]=2;args[1]=a;args[2]=b;n=4;break;
    default:break;
    }
    event(f,key,n,args);
    /* Releases stay tracked for post-return cleanup, but only one actual free.
     * State pointer is cleared by the translated caller, not by this callback. */
    return result(f,key,0);
}
static void log_(void *v,uint32_t line,uint32_t level)
{uint32_t a[2]={line,level};event(v,0xfa0c4,2,a);}
static const struct vn135_cold_ops ops={allocate,load,scalar,object,log_};
int vn135_cold_fixture(const uint32_t in[16],uint32_t out[CAP])
{
    struct fixture f={0};struct vn135_cold_result r={0};unsigned i,j;
    enum vn135_cold_boundary end;f.in=in;f.out=out;
    end=vn135_backend_construct_135(&r,&ops,&f,0x848400);
    if(end==VN135_C_FATAL_BOUNDARY)event(&f,0x72bf4,1,&r.fatal_code);
    put(&f,0xffffffffu);put(&f,(uint32_t)end);put(&f,token(&f,r.device));
    if(r.device){put(&f,(uint32_t)r.device->driver);put(&f,token(&f,r.device->data));put(&f,r.device->word_20);put(&f,r.device->word_98);}
    put(&f,token(&f,r.backend));
    if(r.backend){
        struct vn135_cold_backend *b=r.backend;
        put(&f,token(&f,b->model_18));put(&f,token(&f,b->alias_74));
        put(&f,token(&f,b->limits_1c));put(&f,token(&f,b->alias_78));
        put(&f,token(&f,b->records_100));put(&f,token(&f,b->chains_230));
        put(&f,b->word_7c);put(&f,b->word_20);put(&f,b->byte_211);
        for(i=0;i<7;i++)put(&f,b->targets[i]);
        if(b->chains_230)for(i=0;i<in[0];i++){
            struct vn135_cold_chain *c=&b->chains_230[i];
            put(&f,c->index);put(&f,token(&f,c->parent));put(&f,token(&f,c->chips));put(&f,token(&f,c->items));
            if(c->chips)for(j=0;j<in[1];j++){put(&f,c->chips[j].index);put(&f,c->chips[j].word_04);}
        }
    }
    for(i=0;i<f.n;i++)free(f.a[i].p);
    return (int)f.used;
}
#ifndef VN135_FIXTURE_ONLY
int main(void)
{
    uint32_t in[16]={2,3,2,4,2,0,1,1,0,0,0xffffffffu,0,0,0,0,0},out[CAP];
    unsigned count=0,n,mode,fail;int len;
    for(n=0;n<=4;n++)for(mode=0;mode<4;mode++)for(fail=0;fail<14;fail++){
        if(fail==0||fail==2)continue; /* original unguarded allocation domain */
        in[0]=n;in[5]=mode;in[10]=fail==13?0xffffffffu:fail;
        len=vn135_cold_fixture(in,out);assert(len>0&&len<(int)CAP);count++;
    }
    printf("COLD135_NATIVE_PASS scenarios=%u physical_io=no original_fault_domain_excluded=yes\n",count);
    return 0;
}
#endif
