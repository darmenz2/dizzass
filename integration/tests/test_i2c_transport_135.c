/* All I/O is scripted RAM. Actual malloc/free exercise translation lifetimes. */
#include "integration/i2c_transport_135.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned checks,cases;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"i2c135:%d: %s\n",__LINE__,#x);abort();} } while(0)
struct test {
    struct vn135_i2c_iface global,other;
    unsigned opens,closes,locks,unlocks,selects,writes,reads,sleeps,allocs,frees,errors;
    unsigned select_fail,write_fail,read_fail,open_fail,alloc_fail,is_read;
    unsigned mode,len; uint32_t reg,address;
    uint8_t data[260],expected[260];
    void *allocation;
};
static int32_t lock_cb(void *v,struct vn135_i2c_iface *i)
{ struct test *t=v;(void)i;++t->locks;return -1; }
static int32_t unlock_cb(void *v,struct vn135_i2c_iface *i)
{ struct test *t=v;(void)i;++t->unlocks;return -2; }
static int32_t open_cb(void *v,const char *path,uint32_t flags)
{
    struct test *t=v;++t->opens;CHECK(!strcmp(path,"/dev/i2c-1"));CHECK(flags==0x802);
    CHECK(t->global.fd==-1);return t->open_fail?-2:29;
}
static int32_t close_cb(void *v,int32_t fd)
{ struct test *t=v;++t->closes;CHECK(fd==17);return -1; }
static int32_t ioctl_cb(void *v,int32_t fd,uint32_t req,uint32_t addr)
{
    struct test *t=v;CHECK(fd==29||fd==41);CHECK(req==0x703&&addr==t->address);
    ++t->selects;return t->selects<=t->select_fail?-1:-2; /* -2 is not -1 */
}
static int32_t write_cb(void *v,int32_t fd,const uint8_t *p,uint32_t n)
{
    struct test *t=v;CHECK(fd==29||fd==41);++t->writes;
    if(t->is_read){CHECK(n==1);CHECK(p[0]==(uint8_t)t->reg);}
    else{
        CHECK(n==t->len+(t->mode!=0));
        if(t->mode){CHECK(p[0]==(uint8_t)t->reg);++p;}
        CHECK(!memcmp(p,t->expected+1,t->len));
    }
    return t->writes<=t->write_fail?(n?(int32_t)n-1:-1):(int32_t)n;
}
static int32_t read_cb(void *v,int32_t fd,uint8_t *p,uint32_t n)
{
    struct test *t=v;CHECK(fd==29||fd==41);CHECK(p==t->data+1&&n==t->len);
    ++t->reads;
    if(t->reads<=t->read_fail){if(n>1){p[0]=0x7c;return 1;}return -1;}
    memset(p,0x9a,n);return (int32_t)n;
}
static int32_t sleep_cb(void *v,uint32_t n)
{ struct test *t=v;++t->sleeps;CHECK(n==50000);return -1; }
static int32_t errno_cb(void *v)
{ struct test *t=v;++t->errors;return 5; }
static const char *text_cb(void *v,int32_t error)
{ (void)v;CHECK(error==5);return "scripted-error"; }
static void *calloc_cb(void *v,uint32_t n,uint32_t size)
{
    struct test *t=v;++t->allocs;CHECK(n==t->len+1&&size==1);CHECK(!t->allocation);
    if(t->alloc_fail)return NULL;
    t->allocation=calloc(n,size);CHECK(t->allocation);return t->allocation;
}
static void free_cb(void *v,void *p)
{ struct test *t=v;++t->frees;CHECK(p==t->allocation);free(p);t->allocation=NULL; }
static void log_cb(void *v,enum vn135_i2c_log_source src,uint32_t line,
                   uint32_t a,uint32_t b,uint32_t c,const char *text)
{
    struct test *t=v;
    switch(line){
    case 67:CHECK(src==VN135_I2C_GENERIC&&!strcmp(text,"/dev/i2c-1"));break;
    case 215:CHECK(a==t->address&&b==5);break;
    case 224:case 284:CHECK(a==t->reg&&b==5&&c==t->address&&!strcmp(text,"scripted-error"));break;
    case 232:CHECK(a==5);break;
    case 242:case 301:CHECK(a==5&&b==t->address&&t->sleeps==5);break;
    case 49:case 207:case 262:CHECK(t->open_fail);break;
    case 271:CHECK(t->alloc_fail);break;
    case 295:CHECK(!t->is_read);break;
    default:CHECK(0);
    }
}
static const struct vn135_i2c_ops ops={lock_cb,unlock_cb,open_cb,close_cb,ioctl_cb,
    write_cb,read_cb,sleep_cb,errno_cb,text_cb,calloc_cb,free_cb,log_cb};
static void run(unsigned reading,unsigned alias,unsigned mode,unsigned len,
                unsigned sf,unsigned wf,unsigned rf,unsigned of,unsigned af)
{
    struct test t={0};struct vn135_i2c_transport ctx={&t.global,&ops,&t};
    unsigned failures,expected_attempts;int rc;
    t.global.fd=17;t.other.fd=41;t.is_read=reading;t.mode=mode;t.len=len;
    t.reg=0x87654311u;t.address=0xffff0010u;
    t.select_fail=sf;t.write_fail=wf;t.read_fail=rf;t.open_fail=of;t.alloc_fail=af;
    memset(t.data,0x53,sizeof(t.data));t.data[0]=0x9d;t.data[len+1]=0x63;
    memcpy(t.expected,t.data,sizeof(t.data));
    if(reading)rc=vn135_aml_i2c_read_block(&ctx,alias?&t.global:&t.other,
        t.address,mode,t.reg,t.data+1,len);
    else rc=vn135_aml_i2c_write_block(&ctx,alias?&t.global:&t.other,
        t.address,mode,t.reg,t.data+1,len);
    CHECK(t.opens==1&&t.closes==1&&t.global.fd==(of?-2:29)&&t.other.fd==41);
    CHECK(!t.allocation&&t.allocs==t.frees+((!of&&!reading&&mode&&af)?1u:0u));
    CHECK(t.data[0]==0x9d&&t.data[len+1]==0x63);
    CHECK(!memcmp(t.data+len+2,t.expected+len+2,sizeof(t.data)-len-2));
    if(of||(!reading&&mode&&af)){
        CHECK(rc==-1&&t.locks==1&&t.unlocks==1&&t.selects==0&&t.sleeps==0);
    }else{
        failures=sf+((!reading||mode)?wf:0)+(reading?rf:0);
        expected_attempts=failures<5?failures+1:5;
        CHECK(t.selects==expected_attempts&&t.locks==2&&t.unlocks==2);
        CHECK(t.sleeps==(failures<5?failures:5));CHECK(rc==(failures<5?0:-1));
        if(!rc&&reading){for(unsigned i=0;i<len;++i)CHECK(t.data[i+1]==0x9a);}
    }
    if(!reading)CHECK(!memcmp(t.data,t.expected,sizeof(t.data)));
    ++cases;
}
int main(void)
{
    static const unsigned lengths[]={0,1,2,6,8,33,255,257};
    static const unsigned modes[]={0,1,2,0xffffffffu};
    for(unsigned read=0;read<2;++read)for(unsigned alias=0;alias<2;++alias)
      for(unsigned m=0;m<4;++m)for(unsigned n=0;n<8;++n)
        for(unsigned sf=0;sf<=5;++sf)for(unsigned f=0;f<=5;++f){
            run(read,alias,modes[m],lengths[n],sf,f,0,0,0);
            if(read)run(read,alias,modes[m],lengths[n],sf,0,f,0,0);
        }
    for(unsigned read=0;read<2;++read)for(unsigned alias=0;alias<2;++alias)
      for(unsigned m=0;m<4;++m)for(unsigned n=0;n<8;++n){
        run(read,alias,modes[m],lengths[n],0,0,0,1,0);
        run(read,alias,modes[m],lengths[n],0,0,0,0,1);
      }
    printf("I2C135_NATIVE_PASS scenarios=%u assertions=%u physical_i2c=no\n",cases,checks);
    return 0;
}
