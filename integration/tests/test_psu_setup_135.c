/* Original-domain reconstruction tests. All transport is explicit RAM. */
#include "integration/psu_setup_135.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

static unsigned checks, scenarios;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"PSU setup line %d: %s\n",__LINE__,#x); return 1; } } while (0)
struct fixture {
    struct vn135_psu_protocol p;
    struct vn135_psu_calibration cal;
    struct vn135_psu_identity id;
    uint8_t tx[32], rx[40];
    unsigned txlen, index, attempts, writes, locks, unlocks, logs;
    uint16_t model, revision;
    uint32_t extended;
    int failures, bad_command, bad_crc, sentinel, return_error;
};
static uint16_t independent_crc(const uint8_t *p, unsigned n)
{
    unsigned b; uint16_t crc=65535;
    while(n--) {
        crc^=*p++;
        for(b=0;b<8;++b) crc=(uint16_t)((crc>>1)^((crc&1)?0xa001:0));
    }
    return crc;
}
static void be32(uint8_t *p, uint32_t v)
{ unsigned i; for(i=0;i<4;++i)p[i]=(uint8_t)(v>>(24-8*i)); }
static void response(struct fixture *f, unsigned n)
{
    unsigned i, offset, sum=0; uint16_t crc;
    assert(n<=40 && n>=6 && f->txlen>=6);
    for(i=0;i<n;++i)f->rx[i]=(uint8_t)(i*17+13);
    memcpy(f->rx,f->tx,2);f->rx[2]=(uint8_t)(n-2);f->rx[3]=f->tx[3];
    if(f->tx[3]==2 || f->tx[3]==1) {
        unsigned value=f->tx[3]==2?f->model:f->revision;
        f->rx[4]=(uint8_t)value;f->rx[5]=(uint8_t)(value>>8);
    }
    if(f->tx[3]==10 || f->tx[3]==14)be32(f->rx+8,f->extended);
    if(f->tx[3]==6) {
        uint8_t *body;
        offset=n==39?5:6;body=f->rx+offset;memset(body,0,30);
        /* Deterministic valid serial: 00000000001 + 000002. */
        body[7]=1;body[11]=2;body[13]=17;
        for(i=0;i<14;++i)body[14+i]=1;
        if(f->sentinel<14)body[14+f->sentinel]=128;
        body[28]=0x16;body[29]=0x2e;
        crc=independent_crc(body,30);if(f->bad_crc)crc^=1;
        body[30]=(uint8_t)(crc>>8);body[31]=(uint8_t)crc;
    }
    f->rx[n-2]=f->rx[n-1]=0;
    if(f->p.checksum_mode) {
        for(i=2;i<n-2;i+=2)sum+=(unsigned)f->rx[i]+256u*f->rx[i+1];
        if(n&1)sum+=256u*(sum&255u);
    } else for(i=2;i<n-2;++i)sum+=f->rx[i];
    f->rx[n-2]=(uint8_t)sum;f->rx[n-1]=(uint8_t)(sum>>8);
    if(f->attempts<=(unsigned)f->failures || f->tx[3]==f->bad_command)f->rx[n-1]^=1;
}
static int lock_cb(void *v) {struct fixture *f=v;++f->locks;return f->return_error;}
static int unlock_cb(void *v) {struct fixture *f=v;++f->unlocks;return f->return_error;}
static int delay_cb(void *v,uint32_t n)
{
    struct fixture *f=v;assert(n==400 || n==100);
    if(n==400){++f->attempts;f->index=0;}return f->return_error;
}
static int write_block(void *v,uint8_t addr,uint32_t mode,uint8_t reg,const uint8_t *p,uint32_t n)
{
    struct fixture *f=v;assert(addr==16 && reg==17 && mode<=1 && n<=32);
    memcpy(f->tx,p,n);f->txlen=n;++f->writes;return f->return_error;
}
static int read_block(void *v,uint8_t addr,uint32_t mode,uint8_t reg,uint8_t *p,uint32_t n)
{
    struct fixture *f=v;assert(addr==16 && reg==17 && mode<=1);
    response(f,n);memcpy(p,f->rx,n);return f->return_error;
}
static int write_byte(void *v,uint8_t addr,uint32_t mode,uint8_t reg,uint32_t value)
{
    struct fixture *f=v;assert(addr==16 && reg==17 && mode<=1);
    if(f->index){f->txlen=0;f->index=0;}assert(f->txlen<32);
    f->tx[f->txlen++]=(uint8_t)value;++f->writes;return f->return_error;
}
static int read_byte(void *v,uint8_t addr,uint32_t mode,uint8_t reg)
{
    struct fixture *f=v;unsigned n;
    assert(addr==16 && reg==17 && mode==0);
    n=f->tx[3]==1||f->tx[3]==2?8:f->tx[3]==10||f->tx[3]==14?14:
      f->tx[3]==0x83?f->txlen:f->txlen==8?39:40;
    if(f->index==0)response(f,n);
    assert(f->index<n);return f->rx[f->index++];
}
static void log_cb(void *v,unsigned line,uint32_t a,uint32_t b,const uint8_t *data,uint32_t n)
{ struct fixture *f=v;(void)line;(void)a;(void)b;assert(!n || data);++f->logs; }
static uint32_t select_cb(void *v,uint32_t n)
{ struct fixture *f=v;assert(n==0);return f->p.bus_kind; }
static int init_cb(void *v) { return ((struct fixture *)v)->return_error; }
static const struct vn135_psu_ops ops={lock_cb,unlock_cb,write_block,read_block,write_byte,read_byte,delay_cb,log_cb};
static const struct vn135_psu_init_ops init_ops={select_cb,init_cb};
static void fixture_init(struct fixture *f,unsigned kind,unsigned mode)
{
    unsigned i;memset(f,0,sizeof(*f));f->p.ops=&ops;f->p.opaque=f;
    f->p.bus_kind=kind;f->p.checksum_mode=mode;f->p.address=77;f->p.voltage.word_08=99;
    f->model=193;f->revision=4;f->extended=123456;f->sentinel=8;
    f->cal.lower=10000;f->cal.upper=15000;f->cal.enabled=1;f->cal.count=7;
    for(i=0;i<15;++i)f->cal.x[i]=f->cal.y[i]=1234.+i;
    f->id.initial_word=0x55667788;f->id.date_word=0x11223344;
    memcpy(f->id.serial,"old-serial-1234567",18);
}
static int initializer_tests(void)
{
    unsigned kind, mode, test, i;
    for(kind=0;kind<3;++kind)for(mode=0;mode<3;++mode)for(test=0;test<12;++test) {
        struct fixture f;struct {uint64_t before;struct vn135_psu_init_scratch s;uint64_t after;} guarded;
        int rc;fixture_init(&f,kind,mode);memset(&guarded,0xa7,sizeof(guarded));
        if(test==1)f.bad_command=1;
        if(test==2)f.bad_command=6;
        if(test==3)f.bad_command=10;
        if(test==4)f.bad_command=14;
        if(test==5)f.bad_crc=1;
        if(test==6)f.sentinel=0;
        if(test==7)f.extended=0xffffffffu;
        if(test==8)f.model=35;
        if(test==9)f.return_error=-7;
        if(test==10)f.model=34;
        if(test==11)f.failures=6;
        rc=vn135_psu_initialize(&f.p,&f.cal,&f.id,10000,15000,mode,&init_ops,&guarded.s);
        CHECK(guarded.before==UINT64_C(0xa7a7a7a7a7a7a7a7) && guarded.after==guarded.before);
        CHECK(f.id.initial_word==0 && f.p.address==16 && f.cal.lower==10000 && f.cal.upper==15000);
        CHECK(f.locks==f.unlocks);
        if(kind==2 || test==8 || test==11)CHECK(rc==-1);
        else if(test==7 || (test==3 && mode!=1) || (test==4 && mode==1))CHECK(rc==-1);
        else CHECK(rc==0);
        if(!kind && test==0) {
            CHECK(f.cal.enabled==1 && f.cal.count==9);
            CHECK(!strcmp(f.id.serial,"00000000001000002"));
            CHECK(f.id.date_word==150406);
            for(i=9;i<15;++i)CHECK(f.cal.x[i]==1234.+i && f.cal.y[i]==1234.+i);
        }
        if(kind<2 && test==1)CHECK(f.p.voltage.word_08==99);
        if(kind<2 && (test==2 || test==5 || test==6))CHECK(f.cal.enabled==0);
        if(kind<2 && test==6)CHECK(f.cal.count==1 && f.cal.x[0]==1234.);
        if(kind<2 && test==9)CHECK(rc==0 && f.cal.enabled==1);
        if(kind<2 && test==10 && mode!=1)CHECK(f.cal.enabled==1 && f.cal.count==7 && f.id.date_word==0x11223344);
        ++scenarios;
    }
    return 0;
}
static int setter_tests(void)
{
    unsigned kind, mode, enabled, n, value;
    for(kind=0;kind<3;++kind)for(mode=0;mode<3;++mode)for(enabled=0;enabled<2;++enabled)
      for(n=0;n<=15;++n)for(value=9999;value<=15001;value+=2501) {
        struct fixture f;uint8_t scratch[12];int rc;unsigned i;
        fixture_init(&f,kind,mode);f.p.address=16;f.p.voltage.model=193;
        f.cal.enabled=(uint8_t)enabled;f.cal.count=n;
        for(i=0;i<15;++i){f.cal.y[i]=10.+i;f.cal.x[i]=mode?10.1+i:200.-i*10.;}
        memset(scratch,0xa6,sizeof(scratch));rc=vn135_psu_set_voltage(&f.p,&f.cal,value,scratch+1);
        CHECK(scratch[0]==0xa6 && scratch[11]==0xa6 && (!mode?scratch[9]==0xa6:1));
        CHECK(f.locks==f.unlocks);
        if(kind==2 || value<10000 || value>15000 || (enabled && n<2 && mode))CHECK(rc==-1);
        if(f.writes){CHECK(f.tx[0]==0x55 && f.tx[1]==0xaa && f.tx[3]==0x83);CHECK(f.txlen==(mode?10u:8u));}
        if(kind<2 && value==12500 && enabled && n<2 && !mode)CHECK(rc==0 && f.tx[4]==255 && f.tx[5]==255);
        ++scenarios;
    }
    return 0;
}
static int calibration_tests(void)
{
    unsigned fmt,n,i;struct fixture f;uint8_t data[42];double out[17];
    fixture_init(&f,0,0);f.p.voltage.model=193;
    for(fmt=0;fmt<2;++fmt)for(n=1;n<=15;++n) {
        unsigned at=fmt?20:19;int rc;
        memset(data,0,sizeof(data));data[at-2]=0x7f;data[at-1]=0xff;
        for(i=0;i<14;++i)data[at+i]=127;
        if(n<15)data[at+n-1]=128;
        for(i=0;i<15;++i)f.cal.x[i]=f.cal.y[i]=1234.+i;
        rc=fmt?vn135_psu_load_calibration_b(&f.cal,data):vn135_psu_load_calibration_a(&f.p,&f.cal,data);
        CHECK(f.cal.count==n && rc==(n<2?-1:0));
        for(i=n<2?0:n;i<15;++i)CHECK(f.cal.x[i]==1234.+i && f.cal.y[i]==1234.+i);
        ++scenarios;
    }
    for(n=0;n<=17;++n){for(i=0;i<17;++i)out[i]=1234.;
        CHECK(vn135_psu_knots_raw(out,n)==(n<2||n>15?-1:0));CHECK(out[16]==1234.);}
    CHECK(vn135_psu_calibration_crc((const uint8_t *)"123456789",9,65535)==0x4b37);
    for(n=0;n<=65535;++n)CHECK(vn135_psu_decode_date((uint16_t)n)==n/372*10000+(n/31%12+1)*100+n%31+1);
    return 0;
}
int main(void)
{
    if(initializer_tests() || setter_tests() || calibration_tests())return 1;
    printf("PSU_SETUP_NATIVE_PASS scenarios=%u checks=%u io=scripted-RAM physical_psu=no\n",scenarios,checks);
    return 0;
}
