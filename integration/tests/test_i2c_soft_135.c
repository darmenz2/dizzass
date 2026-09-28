/* Original-domain native tests. All GPIO, descriptors and delays are RAM scripts. */
#include "integration/i2c_soft_135.h"
#include <inttypes.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum op { W, R, O, C, D, NOPS };
static uint64_t assertions, scenarios;
#define CHECK(x) do { ++assertions; if (!(x)) { fprintf(stderr,"soft i2c:%d: %s\n",__LINE__,#x); exit(1); } } while (0)
struct script {
    struct vn135_i2c_soft *s;
    unsigned calls[NOPS], logs, exhausted;
    int fault, nth; int32_t failure;
    uint32_t last_flags;
    unsigned ack_before, ack_samples, data_samples, data_value;
    uint8_t sda[64]; unsigned sda_n;
};
struct bounded { uint64_t before[4]; struct vn135_i2c_soft state; uint64_t after[4]; };
static int32_t result(struct script *x,int kind,int32_t normal)
{
    ++x->calls[kind];
    return x->fault==kind && (!x->nth || x->calls[kind]==(unsigned)x->nth) ? x->failure : normal;
}
static int32_t wr(void *v,int32_t fd,const uint8_t *p,uint32_t n)
{
    struct script *x=v;
    CHECK(n>=1 && n<=3 && p);
    if (n>1) {
        CHECK(fd==11);
        CHECK((n==2 && !memcmp(p,"in",2)) || (n==3 && !memcmp(p,"out",3)));
    } else {
        CHECK(p[0]=='0'||p[0]=='1');
        if(fd!=12 && x->sda_n<sizeof(x->sda)) x->sda[x->sda_n++]=p[0];
    }
    return result(x,W,(int32_t)n);
}
static int32_t rd(void *v,int32_t fd,uint8_t *p,uint32_t n)
{
    struct script *x=v; unsigned bit;
    (void)fd; CHECK(n==1 && p);
    if(x->last_flags==0) {
        CHECK(x->data_samples<8);
        bit=(x->data_value>>(7-x->data_samples))&1; ++x->data_samples;
    } else { bit=x->ack_samples<x->ack_before; ++x->ack_samples; }
    p[0]=(uint8_t)(bit?'1':'0');
    return result(x,R,1);
}
static int32_t op(void *v,const char *p,uint32_t flags)
{
    struct script *x=v;
    CHECK(!strcmp(p,"/ram/sda/value") && flags<=2);
    x->last_flags=flags;
    return result(x,O,20+(int32_t)x->calls[O]);
}
static int32_t cl(void *v,int32_t fd) { (void)fd; return result(v,C,0); }
static int32_t delay(void *v,uint32_t ms) { CHECK(ms==1);return result(v,D,0); }
static void log_(void *v,uint32_t line,uint32_t severity,uint32_t arg)
{
    struct script *x=v; ++x->logs;
    CHECK(severity==(line==154?2u:1u));
    CHECK(line==154||line==162||line==174||line==181||line==192||line==200||
          line==208||line==216||line==245||line==279||line==309);
    CHECK(arg==(line==309?4u:0u)); if(line==309)++x->exhausted;
}
static const struct vn135_i2c_soft_ops ops={wr,rd,op,cl,delay,log_};
static void init(struct bounded *b,struct script *x,unsigned direction,unsigned value)
{
    memset(b,0,sizeof(*b));memset(x,0,sizeof(*x));
    for(unsigned i=0;i<4;++i)b->before[i]=b->after[i]=UINT64_C(0xa5f01289deadbeef);
    x->fault=-1;x->data_value=value;x->last_flags=1;x->s=&b->state;
    b->state=(struct vn135_i2c_soft){(uint8_t)direction,10,11,12,"/ram/sda/value",&ops,x};
}
static void bounds(const struct bounded *b)
{
    for(unsigned i=0;i<4;++i)CHECK(b->before[i]==UINT64_C(0xa5f01289deadbeef)&&b->after[i]==UINT64_C(0xa5f01289deadbeef));
    CHECK(b->state.sda_direction_fd==11 && b->state.scl_value_fd==12 && b->state.ops==&ops);
}
static int run(struct vn135_i2c_soft *s,unsigned entry,unsigned value,uint32_t mode)
{
    switch(entry) {
    case 0:vn135_i2c_soft_sda_input(s);return 0;
    case 1:vn135_i2c_soft_sda_output(s);return 0;
    case 2:vn135_i2c_soft_start(s);return 0;
    case 3:vn135_i2c_soft_stop(s);return 0;
    case 4:vn135_i2c_soft_send_bits(s,value);return 0;
    case 5:return vn135_i2c_soft_write_byte(s,UINT32_MAX,mode,0x12345678,value);
    default:return vn135_i2c_soft_read_byte(s,UINT32_MAX,mode,0x12345678);
    }
}
int main(void)
{
    struct bounded b;struct script x;
    const uint32_t modes[]={0,1,2,UINT32_MAX};
    const int32_t failures[]={INT32_MIN,-2,-1,0,2,INT32_MAX};
    for(unsigned value=0;value<256;++value) {
        for(unsigned direction=0;direction<2;++direction) {
            init(&b,&x,direction,value);vn135_i2c_soft_send_bits(&b.state,value);++scenarios;
            CHECK(x.sda_n==8 && x.ack_samples==1 && !x.exhausted);
            for(unsigned bit=0;bit<8;++bit)CHECK(x.sda[bit]==((value&(128u>>bit))?'1':'0'));
            bounds(&b);
            for(unsigned mode=0;mode<4;++mode) {
                init(&b,&x,direction,value);CHECK(run(&b.state,5,value,modes[mode])==0);++scenarios;
                CHECK(x.ack_samples==(mode?3u:2u) && b.state.sda_output==1);bounds(&b);
                init(&b,&x,direction,value);CHECK(run(&b.state,6,value,modes[mode])==(int)value);++scenarios;
                CHECK(x.data_samples==8 && x.ack_samples==(mode?2u:1u) && b.state.sda_output==1);bounds(&b);
            }
        }
    }
    for(unsigned pos=0;pos<=24;++pos) {
        init(&b,&x,1,0);x.ack_before=pos;vn135_i2c_soft_send_bits(&b.state,0x123456a5);++scenarios;
        CHECK(x.ack_samples==(pos==24?24:pos+1));CHECK(x.exhausted==(pos==24));bounds(&b);
    }
    for(unsigned entry=0;entry<7;++entry)for(unsigned direction=0;direction<2;++direction) {
        unsigned baseline[NOPS];
        init(&b,&x,direction,0xa5);(void)run(&b.state,entry,0xa5,1);++scenarios;
        memcpy(baseline,x.calls,sizeof(baseline));bounds(&b);
        for(unsigned kind=0;kind<NOPS;++kind)for(unsigned nth=0;nth<=baseline[kind];++nth)
        for(unsigned f=0;f<sizeof(failures)/sizeof(*failures);++f) {
            int rc;
            init(&b,&x,direction,0xa5);x.fault=(int)kind;x.nth=(int)nth;x.failure=failures[f];
            rc=run(&b.state,entry,0xa5,1);++scenarios;
            CHECK(entry==6?(rc>=0&&rc<=255):rc==0);bounds(&b);
            for(unsigned k=0;k<NOPS;++k)CHECK(x.calls[k]<1000);
        }
    }
    printf("I2C_SOFT_NATIVE_PASS scenarios=%" PRIu64 " assertions=%" PRIu64 " physical_gpio=no\n",scenarios,assertions);
    return 0;
}
