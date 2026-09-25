/* Native tests of recovered original-domain behavior. No OS/device I/O. */
#include "integration/gpio_power_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; if(!(x)) {fprintf(stderr,"gpio135 line %d: %s\n",__LINE__,#x);exit(1);} } while(0)
struct fixture {
    unsigned opens,closes,locks,unlocks,numbers,texts,logs,scans,uints,perrors,resets,sets;
    unsigned fail_open; int32_t ignored_rc,access_rc,set_rc,count;
    uint8_t byte,ready; unsigned write_scan;
    uint32_t number,value; char format[4],path[256],text[8];
    struct vn135_gpio_io io; struct vn135_backend_power_state *state;
    uint8_t expect_flag; uint32_t expect_word;
};
static int32_t lock(void *p){struct fixture *f=p;++f->locks;return f->ignored_rc;}
static int32_t unlock(void *p){struct fixture *f=p;++f->unlocks;return f->ignored_rc;}
static uintptr_t op(void *p,const char *path,const char *mode)
{
    struct fixture *f=p;++f->opens;CHECK(strlen(path)<256);CHECK(!strcmp(mode,"w")||!strcmp(mode,"r"));
    strcpy(f->path,path);return f->opens==f->fail_open?0:(uintptr_t)(100+f->opens);
}
static int32_t number(void *p,uintptr_t h,const char *fmt,uint32_t v)
{
    struct fixture *f=p;CHECK(h>100);CHECK(!strcmp(fmt,"%u")||!strcmp(fmt,"%d"));
    ++f->numbers;f->number=v;strcpy(f->format,fmt);return f->ignored_rc;
}
static int32_t text(void *p,const char *s,uintptr_t h)
{struct fixture *f=p;CHECK(h>100);CHECK(strlen(s)<8);++f->texts;strcpy(f->text,s);return f->ignored_rc;}
static int32_t close_f(void *p,uintptr_t h)
{struct fixture *f=p;CHECK(h>100);++f->closes;return f->ignored_rc;}
static int32_t access_f(void *p,const char *s,int32_t mode)
{struct fixture *f=p;CHECK(mode==0);CHECK(strlen(s)<256);strcpy(f->path,s);return f->access_rc;}
static int32_t scan(void *p,uintptr_t h,uint8_t *out)
{struct fixture *f=p;CHECK(h>100);++f->scans;if(f->write_scan)*out=f->byte;return f->ignored_rc;}
static int32_t uintscan(void *p,const char *s,uint32_t *out)
{struct fixture *f=p;CHECK(strlen(s)<=1);++f->uints;*out=0xaabbccdd;return f->ignored_rc;}
static void perr(void *p,const char *s){struct fixture *f=p;CHECK(!strcmp(s,"fopen"));++f->perrors;}
static void log_f(void *p,enum vn135_gpio_power_source src,uint32_t line,uint32_t arg)
{struct fixture *f=p;(void)arg;CHECK(src>=0&&src<=2);CHECK(line>0);++f->logs;}
static const struct vn135_gpio_ops gops={lock,unlock,op,number,text,close_f,access_f,scan,uintscan,perr,log_f};
static int32_t on(void *p){struct fixture *f=p;return vn135_aml_psu_on_135(&f->io,f->ready);}
static int32_t off(void *p){struct fixture *f=p;return vn135_aml_psu_off_135(&f->io,f->ready);}
static int32_t set(void *p,uint16_t v)
{
    struct fixture *f=p;++f->sets;f->value=v;
    CHECK(f->state->byte_ff1==f->expect_flag);CHECK(f->state->word_20c==f->expect_word);
    return f->set_rc;
}
static int32_t count(void *p){return ((struct fixture *)p)->count;}
static int32_t reset(void *p,uint32_t index)
{struct fixture *f=p;CHECK(index==f->resets);++f->resets;return -1;}
static const struct vn135_backend_power_ops pops={on,off,set,count,reset,log_f};
static void init(struct fixture *f)
{memset(f,0,sizeof(*f));f->io.ops=&gops;f->io.opaque=f;f->ready=1;f->count=3;}
static void gpio_cases(void)
{
    struct fixture f;uint32_t pins[]={0,1,437,477,0x7fffffff,0x80000000,0xffffffff};
    unsigned i,d,e;int rc;
    for(i=0;i<sizeof(pins)/sizeof(*pins);++i)for(d=0;d<3;++d)for(e=0;e<4;++e) {
        init(&f);f.fail_open=e;f.ignored_rc=-7;
        rc=vn135_gpio_export_direction_135(&f.io,pins[i],d);
        CHECK(rc==((e==1||e==2)?-1:0));CHECK(f.locks==1&&f.unlocks==1);
        if(e!=1){CHECK(f.number==pins[i]);CHECK(!strcmp(f.format,"%u"));}
        if(!rc){CHECK(f.closes==2);CHECK(!strcmp(f.text,d?"out":"in"));}
        else CHECK(f.perrors==1);
        ++scenarios;
        init(&f);f.fail_open=e;f.ignored_rc=-1;
        rc=vn135_gpio_set_value_135(&f.io,pins[i],d);
        CHECK(rc==(e==1?-1:0));if(!rc)CHECK(f.number==(d!=0));++scenarios;
        init(&f);f.fail_open=e;f.ignored_rc=-1;
        rc=vn135_gpio_set_direction_135(&f.io,pins[i],d);
        CHECK(rc==(e==1?-1:0));CHECK(f.opens==1);if(!rc)CHECK(!strcmp(f.text,d?"out":"in"));++scenarios;
        init(&f);f.fail_open=e;f.ignored_rc=-1;
        rc=vn135_gpio_unexport_135(&f.io,pins[i]);CHECK(rc==(e==1?-1:0));
        if(!rc)CHECK(f.number==pins[i]);
        ++scenarios;
    }
    for(i=0;i<256;++i)for(d=0;d<2;++d)for(e=0;e<2;++e) {
        struct {uint32_t before;uint32_t out;uint32_t after;} out={0xdeadbeef,0x11223344,0xa5a5a5a5};
        struct {uint8_t before,byte,after;} in={0xcd,(uint8_t)i,0xef};
        init(&f);f.byte=(uint8_t)(255-i);f.write_scan=d;f.ignored_rc=-1;f.fail_open=e;
        rc=vn135_gpio_get_value_135(&f.io,437,&in.byte,&out.out);
        CHECK(rc==(e?-1:0));CHECK(out.before==0xdeadbeef&&out.after==0xa5a5a5a5);
        CHECK(in.before==0xcd&&in.after==0xef);
        if(e){CHECK(out.out==0x11223344&&f.scans==0);}
        else {CHECK(out.out==((d?255-i:i)!=48));CHECK(f.scans==1&&f.uints==1);}
        ++scenarios;
    }
    for(i=0;i<sizeof(pins)/sizeof(*pins);++i) {
        init(&f);f.access_rc=-2;CHECK(vn135_gpio_is_exported_135(&f.io,pins[i])==0);
        f.access_rc=0;CHECK(vn135_gpio_is_exported_135(&f.io,pins[i])==1);CHECK(f.locks==0);++scenarios;
    }
}
static void power_cases(void)
{
    unsigned r,e,v;struct fixture f;int rc;
    uint32_t values[]={0,1,12000,65535,65536,0x12342ee0,0x80000000,0xffffffff};
    for(r=0;r<256;++r)for(e=0;e<3;++e)for(v=0;v<sizeof(values)/sizeof(*values);++v) {
        struct {uint32_t before;struct vn135_backend_power_state state;uint32_t after;} b;
        memset(&b,0xa5,sizeof(b));b.before=0xcafebabe;b.after=0xdeadbeef;
        b.state.byte_ff1=0x92;b.state.word_20c=0x12345678;
        init(&f);f.ready=(uint8_t)r;f.state=&b.state;f.expect_flag=0x92;f.expect_word=0x12345678;
        f.fail_open=e==1;f.set_rc=e==2?-5:0;f.ignored_rc=-1;
        rc=vn135_backend_power_start_135(&b.state,&pops,&f,values[v]);
        if(r!=1||e)CHECK(rc==-1&&b.state.byte_ff1==0x92&&b.state.word_20c==0x12345678);
        else CHECK(rc==0&&b.state.byte_ff1==1&&b.state.word_20c==values[v]);
        CHECK(f.sets==(r==1&&e!=1));if(f.sets)CHECK(f.value==(values[v]&65535));
        CHECK(f.numbers<=1);if(f.numbers)CHECK(f.number==0); /* No rollback-off. */
        CHECK(b.before==0xcafebabe&&b.after==0xdeadbeef);++scenarios;
        init(&f);f.ready=(uint8_t)r;f.fail_open=e==1;f.count=e==2?-1:3;f.ignored_rc=-1;
        rc=vn135_backend_power_stop_135(&b.state,&pops,&f);
        if(r==1&&e==1)CHECK(rc==-1&&f.resets==0);
        else {CHECK(rc==0&&b.state.byte_ff1==0&&b.state.word_20c==0);CHECK(f.resets==(unsigned)(f.count<0?0:f.count));}
        CHECK(b.before==0xcafebabe&&b.after==0xdeadbeef);++scenarios;
    }
    CHECK(vn135_power_caller_value_135(0xffffffff,14000,0,5)==999);
    CHECK(vn135_power_caller_value_135(0x7fffffff,14000,0,5)==0x800003e7);
    CHECK(vn135_power_caller_value_135(12000,12500,0,5)==12500);
    CHECK(vn135_power_caller_value_135(12000,12500,1,5)==12000);
}
int main(void)
{
    gpio_cases();power_cases();
    printf("GPIO_POWER135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no\n",scenarios,checks);
    return 0;
}
