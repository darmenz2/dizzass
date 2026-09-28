/* Native tests for the original-domain translation. All I/O is scripted RAM. */
#include "integration/psu_protocol_135.h"
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

_Static_assert(DBL_MANT_DIG==53 && DBL_MAX_EXP==1024, "IEEE binary64 required");
static unsigned checks, scenarios;
#define CHECK(x) do { ++checks; if(!(x)) { fprintf(stderr,"psu135:%d: %s\n",__LINE__,#x);exit(1); } } while(0)
struct script {
    struct vn135_psu_protocol *p;
    uint8_t tx[257], good[257];
    uint32_t tn,rn,mode;
    unsigned attempts,reads,writes,locks,unlocks,delays,logs937,logs939,logs951,logs957,logs439,logs1110;
    unsigned failures;
    int low_rc,leave_rx;
};
static uint16_t sum(const uint8_t *r,uint32_t n,uint32_t mode)
{
    uint32_t z=0,i;
    for(i=2;i<n-2;i+=mode?2:1)z+=r[i]+(mode?((uint32_t)r[i+1]<<8):0);
    return (uint16_t)z;
}
static void response(struct script *s,uint16_t raw)
{
    uint32_t i;uint16_t v;
    for(i=0;i<s->rn;++i)s->good[i]=(uint8_t)(i*13+17);
    memcpy(s->good,s->tx,2);s->good[2]=(uint8_t)(s->rn-2);s->good[3]=s->tx[3];
    if(s->rn==8){s->good[4]=(uint8_t)raw;s->good[5]=(uint8_t)(raw>>8);}
    s->good[s->rn-2]=s->good[s->rn-1]=0;
    v=sum(s->good,s->rn,s->mode);
    if(s->mode && (s->rn&1))v=(uint16_t)(v+((uint16_t)(v&255)<<8));
    s->good[s->rn-2]=(uint8_t)v;s->good[s->rn-1]=(uint8_t)(v>>8);
}
static int lock(void *v){struct script *s=v;++s->locks;return s->low_rc;}
static int unlock(void *v){struct script *s=v;++s->unlocks;return s->low_rc;}
static int write_block(void *v,uint8_t addr,uint32_t mode,uint8_t reg,const uint8_t *p,uint32_t n)
{
    struct script *s=v;CHECK(addr==16&&reg==17&&mode==(s->mode==1?0U:1U));
    CHECK(n==s->tn&&!memcmp(p,s->tx,n));++s->writes;return s->low_rc;
}
static int read_block(void *v,uint8_t addr,uint32_t mode,uint8_t reg,uint8_t *p,uint32_t n)
{
    struct script *s=v;CHECK(addr==16&&reg==17&&mode==(s->mode==1?0U:1U)&&n==s->rn);
    ++s->reads;if(!s->leave_rx)memcpy(p,s->good,n);
    if(s->attempts<=s->failures)p[0]^=1;
    return s->low_rc;
}
static int write_byte(void *v,uint8_t addr,uint32_t mode,uint8_t reg,uint32_t b)
{
    struct script *s=v;CHECK(addr==0x37&&reg==17&&mode==(s->mode==1?0U:1U));
    CHECK(b==s->tx[s->writes%s->tn]);++s->writes;return s->low_rc;
}
static int read_byte(void *v,uint8_t addr,uint32_t mode,uint8_t reg)
{
    struct script *s=v;uint32_t i=s->reads%s->rn;int value=s->good[i];
    CHECK(addr==0x37&&reg==17&&mode==0);++s->reads;
    if(s->attempts<=s->failures&&!i)value^=1;
    /* Negative callback values preserve their low byte, like original STRB. */
    return s->low_rc ? value-256 : value;
}
static int delay(void *v,uint32_t ms)
{
    struct script *s=v;CHECK(ms==((s->delays&1)?100U:400U));
    ++s->delays;if(ms==400)++s->attempts;return s->low_rc;
}
static void log_event(void *v,unsigned line,uint32_t a,uint32_t b,const uint8_t *data,uint32_t n)
{
    struct script *s=v;(void)a;(void)b;
    switch(line){
    case 937:++s->logs937;CHECK(n==s->tn&&!memcmp(data,s->tx,n));break;
    case 939:++s->logs939;CHECK(n==s->rn&&data);break;
    case 951:++s->logs951;CHECK(!data&&!n);break;
    case 957:++s->logs957;CHECK(a!=b&&!data&&!n);break;
    case 439:++s->logs439;break;
    case 1110:++s->logs1110;break;
    default:CHECK(0);
    }
}
static const struct vn135_psu_ops ops={lock,unlock,write_block,read_block,write_byte,read_byte,delay,log_event};
static void init(struct script *s,struct vn135_psu_protocol *p,unsigned kind,uint32_t mode,uint32_t n)
{
    static const uint8_t req[]={0x55,0xaa,4,3,7,0};
    memset(s,0,sizeof(*s));memset(p,0,sizeof(*p));
    p->checksum_mode=mode;p->bus_kind=kind;p->address=0x37;p->ops=&ops;p->opaque=s;p->voltage.model=34;
    s->p=p;s->tn=6;s->rn=n;s->mode=mode;memcpy(s->tx,req,6);response(s,10);
}
static void transfers(void)
{
    unsigned kind,fail,err;uint32_t n,mode;
    for(kind=0;kind<2;++kind)for(mode=0;mode<3;++mode)for(n=6;n<=257;++n)
        for(fail=0;fail<4;++fail)for(err=0;err<2;++err){
            struct script s;struct vn135_psu_protocol p;uint8_t storage[263],before_tx[257];
            unsigned expected=fail==3?3:fail+1;int rc;
            init(&s,&p,kind,mode,n);s.failures=fail;s.low_rc=err?-5:0;
            memset(storage,0xa5,sizeof(storage));memcpy(before_tx,s.tx,257);
            rc=(kind?vn135_psu_exchange_bytes:vn135_psu_exchange_block)(&p,s.tx,6,storage+3,n);
            CHECK(rc==(fail==3?-1:0));CHECK(s.attempts==expected&&s.delays==2*expected);
            CHECK(s.locks==1&&s.unlocks==1);
            CHECK(s.writes==expected*(kind?6:1)&&s.reads==expected*(kind?n:1));
            CHECK(s.logs951==fail&&s.logs957==0);
            CHECK(s.logs937==(kind?(fail==3):fail)&&s.logs939==s.logs937);
            CHECK(!memcmp(before_tx,s.tx,257));
            CHECK(storage[0]==0xa5&&storage[1]==0xa5&&storage[2]==0xa5);
            CHECK(storage[3+n]==0xa5&&storage[4+n]==0xa5&&storage[5+n]==0xa5);
            if(!rc)CHECK(!memcmp(storage+3,s.good,n));
            ++scenarios;
        }
}
static void selected_cases(void)
{
    struct script s;struct vn135_psu_protocol p;uint8_t r[10];int32_t out;int rc;unsigned kind,fail;
    /* Original request length ignored, non-standard matching preamble allowed. */
    init(&s,&p,0,0,8);s.tx[0]=0x12;s.tx[1]=0x34;response(&s,10);
    CHECK(!vn135_psu_response_check(&p,s.tx,0,s.good,8));
    CHECK(!vn135_psu_response_check(&p,s.tx,UINT32_MAX,s.good,8));
    s.good[2]=5;CHECK(vn135_psu_response_check(&p,s.tx,6,s.good,8)==-1);
    init(&s,&p,0,0,8);s.good[7]^=1;CHECK(vn135_psu_response_check(&p,s.tx,6,s.good,8)==-1&&s.logs957==1);
    /* No received-buffer clearing and ignored failing block read: counterexample. */
    init(&s,&p,0,0,8);memcpy(r+1,s.good,8);s.leave_rx=1;s.low_rc=-5;out=0x12345678;
    r[0]=r[9]=0x93;
    CHECK(!vn135_psu_read_voltage(&p,r+1,&out));CHECK(out==20121&&s.attempts==1);
    CHECK(r[0]==0x93&&r[9]==0x93);
    for(kind=0;kind<4;++kind)for(fail=0;fail<4;++fail){
        init(&s,&p,kind,0,8);s.failures=fail;out=0x12345678;memset(r,0x93,sizeof(r));
        rc=vn135_psu_read_voltage(&p,r+1,&out);
        CHECK(rc==((kind>=2||fail==3)?-1:0));
        CHECK(out==(rc?0x12345678:20121));CHECK(r[0]==0x93&&r[9]==0x93);
        CHECK(s.logs1110==(unsigned)(rc!=0));CHECK(s.logs439==(unsigned)(kind>=2));
        if(kind>=2)CHECK(!s.writes&&!s.reads&&!s.delays&&!s.locks&&!s.unlocks);
        ++scenarios;
    }
    init(&s,&p,0,0,8);p.voltage.model=0xffff;out=0x12345678;
    CHECK(!vn135_psu_read_voltage(&p,r+1,&out)&&out==0);
    p.ops=NULL; /* Optional diagnostic sink for pure validator. */
    s.good[0]^=1;CHECK(vn135_psu_response_check(&p,s.tx,6,s.good,8)==-1);
}
static void conversion(void)
{
    struct vn135_psu_voltage_state v={0};unsigned model;
    for(model=0;model<65536;++model){
        double z;v.model=(uint16_t)model;v.byte_130=1;v.word_132=1;
        z=vn135_psu_decode_voltage(&v,0);CHECK(z==16.0);
        v.word_132=9;z=vn135_psu_decode_voltage(&v,-2147483647-1);CHECK(z==0.0&&!signbit(z));
    }
    v.byte_130=0;v.model=34;
    {double value=vn135_psu_decode_voltage(&v,10);uint64_t bits;memcpy(&bits,&value,8);CHECK(bits==UINT64_C(0x40341f079eebe530));}
    v.model=193;v.word_08=3;CHECK(vn135_psu_decode_voltage(&v,0)==15.0);
    v.word_08=4;CHECK(vn135_psu_decode_voltage(&v,0)!=15.0);
}
int main(void)
{
    transfers();selected_cases();conversion();
    printf("PSU135_NATIVE_PASS scenarios=%u assertions=%u real_io=no firmware_process=no\n",scenarios,checks);
    return 0;
}
