/* Actual C allocations and scripted GPIO/syscall results. No /dev or sysfs. */
#include "integration/i2c_init_135.h"
#include "integration/psu_protocol_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

enum action { OPEN, CLOSE, WRITE, CHECK_PIN, UNEXPORT, DIRECTION, DUPLICATE, MUTEX, ACTIONS };
struct context {
    enum action fault; unsigned nth; int32_t result; int exported;
    unsigned count[ACTIONS], logs, last_source, last_line, allocated;
    char *names[16];
    struct vn135_aml_psu_bus psu;
    struct vn135_psu_protocol *protocol;
    unsigned byte_writes,byte_reads,block_writes,block_reads,getters;
    uint8_t tx[16],rx[8];
};
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"init135:%d: %s\n",__LINE__,#x);exit(1);} }while(0)
static int32_t action(struct context *c,enum action a,int32_t normal)
{ ++c->count[a];return c->nth && c->fault==a && c->nth==c->count[a]?c->result:normal; }
static int32_t op(void *p,const char *path,uint32_t flags)
{ struct context *c=p;CHECK(path&&*path);CHECK(flags==1||flags==0x802);return action(c,OPEN,(int32_t)c->count[OPEN]+100); }
static int32_t cl(void *p,int32_t fd)
{ (void)fd;return action(p,CLOSE,0); }
static int32_t wr(void *p,int32_t fd,const uint8_t *b,uint32_t n)
{ (void)fd;CHECK(b&&n>0&&n<256);return action(p,WRITE,(int32_t)n); }
static int32_t exported(void *p,int32_t pin)
{ struct context *c=p;(void)pin;return action(c,CHECK_PIN,c->exported); }
static int32_t unexport(void *p,int32_t pin)
{ (void)pin;return action(p,UNEXPORT,0); }
static int32_t direction(void *p,int32_t pin,uint32_t mode)
{ CHECK(pin==437&&mode==1);return action(p,DIRECTION,0); }
static char *duplicate(void *p,const char *name)
{
    struct context *c=p;size_t n=strlen(name)+1;char *s;
    if(!action(c,DUPLICATE,1))return NULL;
    s=malloc(n);CHECK(s);memcpy(s,name,n);CHECK(c->allocated<16);c->names[c->allocated++]=s;return s;
}
static int32_t mutex_step(void *p,enum vn135_i2c_mutex_step step,
    struct vn135_i2c_registration *r,uint32_t type)
{
    struct context *c=p;CHECK(r&&r->name);CHECK((unsigned)step==c->count[MUTEX]%4);
    CHECK(type==(step==VN135_ATTR_SETTYPE?1u:0u));return action(c,MUTEX,0);
}
static void log_(void *p,enum vn135_i2c_init_source src,uint32_t line)
{ struct context *c=p;++c->logs;c->last_source=(unsigned)src;c->last_line=line; }
static void tlog(void *p,enum vn135_i2c_log_source src,uint32_t line,
    uint32_t a,uint32_t b,uint32_t c,const char *s)
{ (void)src;(void)a;(void)b;(void)c;(void)s;log_(p,VN135_INIT_GENERIC,line); }
static const struct vn135_i2c_init_ops ops={
    .io={.write=wr,.open=op,.close=cl},.is_exported=exported,.unexport=unexport,
    .set_direction=direction,.duplicate=duplicate,.mutex_step=mutex_step,.log=log_};
static const struct vn135_i2c_ops transport_ops={.open=op,.close=cl,.log=tlog};
static void free_names(struct context *c)
{ unsigned i;for(i=0;i<c->allocated;++i)free(c->names[i]);c->allocated=0; }
static void initialize(struct vn135_i2c_gpio_init *g,int32_t fd)
{
    memset(g,0,sizeof(*g));g->soft.sda_output=7;
    g->soft.sda_value_fd=fd;g->soft.scl_value_fd=fd;g->soft.sda_direction_fd=fd;
    memset(g->sda_value,0xa5,256);memset(g->sda_direction,0xa5,256);
    memset(g->scl_value,0xa5,256);memset(g->scl_direction,0xa5,256);
}
static void gpio_cases(void)
{
    unsigned a,j,r,ei;const int32_t values[]={INT32_MIN,-2,-1,0,1,2,3,INT32_MAX};
    const unsigned counts[ACTIONS]={7,7,4,2,2,0,0,0};
    for(ei=0;ei<2;++ei)for(a=0;a<ACTIONS;++a)for(j=1;j<=counts[a];++j)for(r=0;r<8;++r) {
        struct context c={.fault=(enum action)a,.nth=j,.result=values[r],.exported=(int)ei};
        struct { uint64_t before;struct vn135_i2c_gpio_init g;uint64_t after; } box;
        int failure=0,rc;
        box.before=UINT64_C(0x1122334455667788);box.after=UINT64_C(0x8877665544332211);initialize(&box.g,20);
        rc=vn135_i2c_gpio_initialize_135(&box.g,&ops,&c,477,476);
        if(a==OPEN)failure=j<=4?values[r]==-1:values[r]<0;
        if(a==WRITE)failure=values[r]!=3;
        CHECK(rc==(failure?-1:0));
        CHECK(box.before==UINT64_C(0x1122334455667788)&&box.after==UINT64_C(0x8877665544332211));
        CHECK(box.g.sda_pin==477&&box.g.scl_pin==476&&box.g.sda_mode==1&&box.g.scl_mode==1);
        CHECK(!strcmp(box.g.sda_value,"/sys/class/gpio/gpio477/value"));
        CHECK(!strcmp(box.g.scl_direction,"/sys/class/gpio/gpio476/direction"));
        CHECK((unsigned char)box.g.sda_value[255]==0xa5);
        if(!failure){CHECK(box.g.soft.sda_output==1);CHECK(box.g.soft.sda_value_fd>=0);}
        else CHECK(c.logs==1);
        ++scenarios;
    }
    for(r=0;r<8;++r){
        struct context c={0};struct vn135_i2c_gpio_init g;unsigned prior,n;
        initialize(&g,values[r]);vn135_i2c_gpio_close_135(&g,&ops,&c);n=values[r]>0?3u:0u;
        CHECK(c.count[CLOSE]==n&&g.soft.sda_value_fd==values[r]);
        prior=c.count[CLOSE];vn135_i2c_gpio_close_135(&g,&ops,&c);CHECK(c.count[CLOSE]==prior+n);++scenarios;
    }
}
static void callers(void)
{
    unsigned a,j,r,ready;const int32_t values[]={-2,-1,0,1,3};
    for(ready=0;ready<2;++ready)for(a=0;a<ACTIONS;++a)for(j=1;j<=8;++j)for(r=0;r<5;++r) {
        struct context c={.fault=(enum action)a,.nth=j,.result=values[r],.exported=1};
        int rc;initialize(&c.psu.gpio,20);c.psu.ready=(uint8_t)ready;
        rc=vn135_aml_psu_bus_initialize_135(&c.psu,&ops,&c);
        CHECK(rc==0||rc==-1);CHECK(c.psu.ready==(rc==0?1:ready));
        if(!rc){CHECK(c.psu.registration.kind==1);CHECK(!strcmp(c.psu.registration.name,"i2c:psu-bus"));CHECK(c.psu.gpio.sda_pin==477&&c.psu.gpio.scl_pin==476);}
        CHECK(vn135_aml_psu_bus_get_135(&c.psu,UINT32_MAX)==&c.psu.registration);
        free_names(&c);++scenarios;
    }
    for(a=0;a<ACTIONS;++a)for(j=1;j<=4;++j)for(r=0;r<5;++r){
        struct context c={.fault=(enum action)a,.nth=j,.result=values[r]};
        struct vn135_aml_hw_bus hw={0};struct vn135_i2c_transport t={&hw.hardware,&transport_ops,&c};
        int fail=(a==DUPLICATE&&j==1&&values[r]==0)||(a==OPEN&&j==1&&values[r]<0);
        CHECK(vn135_aml_hw_bus_initialize_135(&hw,&ops,&c,&t)==(fail?-1:0));
        CHECK(hw.registration.kind==0&&hw.registration.index==0);
        CHECK(vn135_aml_hw_bus_get_135(&hw,UINT32_MAX)==&hw.registration);
        CHECK(c.count[CHECK_PIN]==0&&c.count[WRITE]==0);
        free_names(&c);++scenarios;
    }
    { struct context c={0};struct vn135_i2c_registration r={0};char *first;
      CHECK(vn135_i2c_register_135(&r,&ops,&c,1,2,"first")==0);first=r.name;
      CHECK(vn135_i2c_register_135(&r,&ops,&c,3,4,"second")==0);
      CHECK(r.name!=first&&!strcmp(first,"first")&&!strcmp(r.name,"second"));
      free_names(&c);++scenarios; }
}
/* Compose the initialized getter with the EXISTING voltage-read wrapper.
 * Model 0 preserves original zero decoding; it is not a measured voltage. */
static int noop(void *p){(void)p;return 0;}
static int delay(void *p,uint32_t ms){(void)p;CHECK(ms==400||ms==100);return 0;}
static void prepare_response(struct context *c)
{
    uint16_t sum;
    memcpy(c->rx,(uint8_t[]){0x55,0xaa,6,3,0,0,0,0},8);
    sum=c->protocol->checksum_mode?0x306:9;
    c->rx[6]=(uint8_t)sum;c->rx[7]=(uint8_t)(sum>>8);
}
static int wb(void *p,uint8_t a,uint32_t m,uint8_t r,uint32_t v)
{ struct context *c=p;(void)m;CHECK(a==16&&r==17&&c->byte_writes<6);c->tx[c->byte_writes++]=(uint8_t)v;return 0; }
static int rb(void *p,uint8_t a,uint32_t m,uint8_t r)
{ struct context *c=p;CHECK(a==16&&m==0&&r==17&&c->byte_reads<8);prepare_response(c);return c->rx[c->byte_reads++]; }
static int wblock(void *p,uint8_t a,uint32_t m,uint8_t r,const uint8_t *b,uint32_t n)
{ struct context *c=p;(void)m;CHECK(a==16&&r==17&&n==6);memcpy(c->tx,b,n);++c->block_writes;return 0; }
static int rblock(void *p,uint8_t a,uint32_t m,uint8_t r,uint8_t *b,uint32_t n)
{ struct context *c=p;(void)m;CHECK(a==16&&r==17&&n==8);prepare_response(c);memcpy(b,c->rx,8);++c->block_reads;return 0; }
static uint32_t bus_kind(void *p,uint32_t index)
{ struct context *c=p;CHECK(index==0);++c->getters;return vn135_aml_psu_bus_get_135(&c->psu,index)->kind; }
static void composition(void)
{
    unsigned mode,kind;const uint32_t modes[]={0,1,2,UINT32_MAX};
    const struct vn135_psu_ops io={.lock=noop,.unlock=noop,.write_block=wblock,.read_block=rblock,.write_byte=wb,.read_byte=rb,.delay_ms=delay};
    for(kind=0;kind<2;++kind)for(mode=0;mode<4;++mode){
        struct context c={0};struct vn135_psu_protocol p={.ops=&io,.opaque=&c};
        uint8_t scratch[8]={0};int32_t voltage=123;
        c.protocol=&p;initialize(&c.psu.gpio,-1);CHECK(vn135_aml_psu_bus_initialize_135(&c.psu,&ops,&c)==0);
        CHECK(c.psu.registration.kind==1);
        if(kind==0)c.psu.registration.kind=0; /* Explicit negative-control mutation. */
        p.bus_kind=bus_kind(&c,0);p.address=16;p.checksum_mode=modes[mode];
        CHECK(vn135_psu_read_voltage(&p,scratch,&voltage)==0&&voltage==0);
        CHECK(c.getters==1&&p.bus_kind==kind&&p.voltage.model==0);
        CHECK(c.byte_writes==(kind==1?6u:0u)&&c.byte_reads==(kind==1?8u:0u));
        CHECK(c.block_writes==(kind==0?1u:0u)&&c.block_reads==(kind==0?1u:0u));
        CHECK(!memcmp(c.tx,(uint8_t[]){0x55,0xaa,4,3},4));
        CHECK(c.tx[4]==7&&c.tx[5]==0);
        free_names(&c);++scenarios;
    }
}
int main(void)
{ gpio_cases();callers();composition();printf("I2C_INIT_NATIVE_PASS scenarios=%u assertions=%u physical_io=no\n",scenarios,checks);return 0; }
