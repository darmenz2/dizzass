/* Isolated RAM tests of original cached-value aggregate and caller. */
#include "integration/backend_peripheral_135.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
struct fx {const uint32_t *in;uint32_t *out,n;};
static void event(struct fx *f,uint32_t op,uint32_t n,uint32_t a,uint32_t b,uint32_t c,uint32_t d)
{uint32_t x[4]={a,b,c,d},i;assert(f->n+n+2<128);f->out[f->n++]=op;f->out[f->n++]=n;for(i=0;i<n;i++)f->out[f->n++]=x[i];}
static int32_t count(void *p){struct fx*f=p;event(f,0xfe668,0,0,0,0,0);return (int32_t)f->in[0];}
static int32_t lock(void*p,uint32_t c){struct fx*f=p;event(f,0x5a6108,1,c,0,0,0);return (int32_t)f->in[32];}
static int32_t unlock(void*p,uint32_t c){struct fx*f=p;event(f,0x5a66c4,1,c,0,0,0);return (int32_t)f->in[33];}
static int32_t simple(void*p,uint32_t a){struct fx*f=p;event(f,0xf8a30,1,a,0,0,0);return (int32_t)f->in[34];}
static int32_t apply(void*p,uint32_t a,uint32_t b,uint32_t c,uint32_t d){struct fx*f=p;event(f,0xf86a8,4,a,b,c,d);return (int32_t)f->in[34];}
static void log_(void*p,uint32_t a){event(p,0xfa0c4,1,a,0,0,0);}
static const struct vn135_peripheral_ops ops={count,lock,unlock,simple,apply,log_};
int vn135_peripheral_fixture(const uint32_t in[36],uint32_t out[128])
{
    struct vn135_peripheral_chain chains[4],before[4];
    struct vn135_peripheral_entry entries[4];struct vn135_peripheral_profile profile;
    struct vn135_peripheral_state s;struct fx f={in,out,0};unsigned i;int rc;int32_t value=(int32_t)in[7];
    memset(chains,0,sizeof chains);memset(entries,0,sizeof entries);
    for(i=0;i<4;i++){
        entries[i].type=in[8+i*2];entries[i].byte_19=(uint8_t)in[9+i*2];
        chains[i].word_20=in[16+i*4];chains[i].byte_24=(uint8_t)in[17+i*4];
        chains[i].word_2ac=(int32_t)in[18+i*4];chains[i].byte_2b0=(uint8_t)in[19+i*4];
    }
    memcpy(before,chains,sizeof chains);
    profile.table_count=(int32_t)in[2];profile.entries=entries;profile.model_f0_00=in[3];profile.model_bc_08=in[4];
    s.mode_50=in[1];s.word_6c=in[5];s.word_70=in[6];s.profile=&profile;s.chains=chains;
    rc=in[35]?vn135_backend_collect_5db54_135(&s,&ops,&f,&value):vn135_backend_configure_6c61c_135(&s,&ops,&f);
    assert(!memcmp(before,chains,sizeof chains));
    out[f.n++]=0xffffffffu;out[f.n++]=(uint32_t)rc;out[f.n++]=(uint32_t)value;
    return (int)f.n;
}
#ifndef VN135_FIXTURE_ONLY
int main(void)
{
    uint32_t in[36]={3,0,2,70,35,111,222,0xdeadbeef,0,0,4,0,0,0,0,0,
                    1,1,40,1,1,1,50,1,1,1,45,1,1,1,60,1,0,0,0,0},out[128];
    unsigned mode,valid,status,cases=0;int n;
    for(mode=0;mode<4;mode++)for(valid=0;valid<4;valid++)for(status=0;status<8;status++){
        in[1]=mode;in[19]=valid;in[23]=valid;in[27]=valid;in[16]=status;in[20]=status;in[24]=status;
        n=vn135_peripheral_fixture(in,out);assert(n>=3);
        if(mode==2){assert(n==3&&out[1]==0);}
        else if(valid&&!(status>=3&&status<=5)){assert(out[n-2]==0);}
        else{assert(out[n-2]==0xffffffffu);}
        cases++;
    }
    puts("PERIPHERAL135_NATIVE_PASS scenarios=128 physical_io=no cached_values_only=yes");
    assert(cases==128);return 0;
}
#endif
