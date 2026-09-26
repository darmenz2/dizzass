/* RAM-only native tests; no pthread creation, GPIO, PSU or filesystem I/O. */
#include "integration/backend_prepare_135.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; assert(x); } while(0)
struct fixture {
    unsigned char before[32];
    struct vn135_prepare_state s;
    struct vn135_prepare_limits limits;
    struct vn135_prepare_profile profile;
    struct vn135_prepare_fan fans[8];
    struct vn135_prepare_scratch scratch;
    unsigned char after[32];
    struct vn135_prepare_ops ops;
    uint8_t platform;
    char *old,*allocated;
    uint32_t fail_step;
    int32_t fail_rc,stat_rc,psu_rc,thread_rc;
    int32_t read1,read2,scale;
    unsigned polls,reads,locks,unlocks,psu_calls,thread_calls,stops,event;
    unsigned serial_len,serial_mode,dup_fail;
};
static int32_t signed_bits(uint32_t x)
{ return x<=INT32_MAX?(int32_t)x:-1-(int32_t)(UINT32_MAX-x); }
static int32_t step(void *p,uint32_t key,uint32_t a,uint32_t b,uint32_t c)
{
    struct fixture *f=p;(void)b;(void)c;
    if(key==0x4f2d0){
        CHECK(a==0x50);CHECK(f->s.word_28==0&&f->s.word_2c==0);
        CHECK(f->s.word_1070==0&&f->s.byte_24==0&&f->s.byte_fe5==0&&f->s.byte_104a==0);
    }
    if(key==0x49c98)f->event=a;
    if(key==0x5e92c)++f->stops;
    if(key==0x10ef3c){CHECK(a==1000);++f->polls;}
    if(key==0x5a6108)++f->locks;
    if(key==0x5a66c4)++f->unlocks;
    if(key==0xfe2f0)return f->scale;
    if(key==0xfe300)return (f->reads++&1u)?f->read2:f->read1;
    if(key==0x82d60)return -1;
    if(key==f->fail_step)return f->fail_rc;
    return 0;
}
static int32_t stat_path(void *p,const char *path)
{
    struct fixture *f=p;
    CHECK(!strcmp(path,f->s.byte_f4?"/config/stopped":"/tmp/stopped"));return f->stat_rc;
}
static char *duplicate(void *p,const char *str)
{
    struct fixture *f=p;size_t n=strlen(str)+1;
    CHECK(f->s.text_fc8==f->old);
    if(f->dup_fail)return NULL;
    f->allocated=malloc(n);CHECK(f->allocated!=NULL);memcpy(f->allocated,str,n);return f->allocated;
}
static int32_t psu(void *p,int32_t lo,int32_t hi,uint32_t mode)
{
    struct fixture *f=p;++f->psu_calls;
    CHECK(lo==f->limits.lower_30&&hi==f->limits.upper_34&&mode==f->limits.word_14);
    CHECK(f->platform==255);return f->psu_rc;
}
static void *serial_open(void *p,const char *path,const char *mode)
{ CHECK(!strcmp(path,"/config/serial")&&!strcmp(mode,"r"));return p; }
static int32_t serial_read(void *p,void *stream,const char *format,char out[256])
{
    struct fixture *f=p;CHECK(stream==p&&!strcmp(format,"%255s"));
    if(f->serial_mode==2)return -1;
    if(!f->serial_mode){memset(out,'S',f->serial_len);out[f->serial_len]=0;}
    return 1;
}
static int32_t serial_close(void *p,void *stream){CHECK(p==stream);return -1;}
static int32_t create(void *p,uint32_t field,uint32_t entry,uint32_t *handle)
{
    struct fixture *f=p;++f->thread_calls;
    CHECK(field==0xff4&&entry==0x7bfc0&&handle==&f->s.thread_ff4);
    *handle=0x12345678;return f->thread_rc;
}
static void log_event(void *p,uint32_t line,uint32_t level,uint32_t a,uint32_t b,const char *text)
{
    struct fixture *f=p;(void)a;(void)b;CHECK(level==1||level==3);
    if(line==201)CHECK(strlen(text)==(f->serial_mode==1?3u:f->serial_len));
}
static void init(struct fixture *f)
{
    memset(f,0,sizeof(*f));memset(f->before,0x5a,32);memset(f->after,0xa5,32);
    f->s.limits=&f->limits;f->s.profile=&f->profile;f->s.fans=f->fans;
    f->s.platform_byte=&f->platform;f->s.text_90="test-settings";
    f->old=malloc(12);CHECK(f->old!=NULL);memcpy(f->old,"old-pointer",12);
    f->s.text_fc8=f->old;f->s.thread_ff4=0xabcdef01;
    f->s.word_28=11;f->s.word_2c=22;f->s.word_1070=33;
    f->s.byte_24=4;f->s.byte_fe5=5;f->s.byte_104a=6;
    f->limits.lower_30=10000;f->limits.upper_34=15000;f->limits.word_14=1;
    f->limits.word_3c=9000;f->profile.word_1c=3000;
    f->profile.fan_count=2;f->profile.fan_word_0c=1000;f->s.word_68=2;
    for(unsigned i=0;i<8;++i)f->fans[i].byte_1c=1;
    f->read1=1200;f->read2=1200;f->scale=30;f->stat_rc=-1;
    f->serial_len=17;strcpy(f->scratch.serial,"old");
    f->ops=(struct vn135_prepare_ops){step,stat_path,duplicate,psu,serial_open,
        serial_read,serial_close,create,log_event};
}
static void finish(struct fixture *f)
{
    for(unsigned i=0;i<32;++i){CHECK(f->before[i]==0x5a);CHECK(f->after[i]==0xa5);}
    CHECK(!strcmp(f->old,"old-pointer"));CHECK(f->locks==f->unlocks);
    if(f->allocated){CHECK(f->allocated!=f->s.text_90);CHECK(!strcmp(f->allocated,"test-settings"));}
    free(f->allocated);free(f->old);++scenarios;
}
int main(void)
{
    struct fixture f;int rc;
    for(unsigned mode=0;mode<4;++mode)for(unsigned faildup=0;faildup<2;++faildup)
    for(unsigned serial=0;serial<3;++serial)for(unsigned length=0;length<2;++length){
        init(&f);f.s.mode_50=mode;f.dup_fail=faildup;f.serial_mode=serial;
        f.serial_len=length?255:0;
        rc=vn135_backend_prepare_135(&f.s,&f.ops,&f,&f.scratch);
        CHECK(rc==1&&f.thread_calls==1&&f.psu_calls==1&&f.stops==0);
        CHECK(f.s.thread_ff4==0x12345678&&f.s.word_10c==3000);
        CHECK(f.s.byte_210==0);CHECK(f.s.text_fc8==(faildup?NULL:f.allocated));
        CHECK(f.polls==(mode==2?0u:1u));finish(&f);
    }
    const uint32_t stages[]={0x4f2d0,0xf96a0,0xb4c58,0xa1fe0};
    const uint32_t codes[]={1002,2002,2003,1001};
    const int32_t returns[]={-1,1,INT32_MIN,INT32_MAX};
    for(unsigned i=0;i<4;++i)for(unsigned j=0;j<4;++j){
        init(&f);f.fail_step=stages[i];f.fail_rc=returns[j];
        rc=vn135_backend_prepare_135(&f.s,&f.ops,&f,&f.scratch);
        CHECK(rc==0&&f.stops==1&&f.event==codes[i]&&f.thread_calls==0);finish(&f);
    }
    for(unsigned i=0;i<4;++i){
        init(&f);f.psu_rc=returns[i];rc=vn135_backend_prepare_135(&f.s,&f.ops,&f,&f.scratch);
        CHECK(rc==0&&f.event==2001&&f.stops==1&&f.thread_calls==0);finish(&f);
        init(&f);f.thread_rc=returns[i];rc=vn135_backend_prepare_135(&f.s,&f.ops,&f,&f.scratch);
        CHECK(rc==0&&f.event==1001&&f.stops==1&&f.thread_calls==1);
        CHECK(f.s.thread_ff4==0x12345678);finish(&f);
    }
    init(&f);f.read1=0;f.read2=0;
    rc=vn135_backend_prepare_135(&f.s,&f.ops,&f,&f.scratch);
    CHECK(rc==0&&f.event==2004&&f.polls==15&&f.reads==60&&f.thread_calls==0);finish(&f);
    init(&f);f.read1=0;f.read2=0;f.s.word_68=0;
    rc=vn135_backend_prepare_135(&f.s,&f.ops,&f,&f.scratch);
    CHECK(rc==1&&f.polls==15&&f.s.word_23c==0);finish(&f);
    /* Source poll's exact bit/threshold/counter transitions, not a new policy. */
    const int32_t readings[]={INT32_MIN,-1,0,1,999,1000,1001,3000,3001,INT32_MAX};
    for(unsigned flag=0;flag<256;++flag)for(unsigned k=0;k<10;++k){
        init(&f);f.profile.fan_count=1;f.s.word_23c=INT32_MAX;
        f.fans[0].byte_1c=(uint8_t)flag;f.read1=readings[k];f.read2=readings[k];
        int32_t value=f.read1>=1000?1000:f.read2;
        uint8_t expected=(uint8_t)flag;uint32_t count=INT32_MAX;
        if(value>=1&&value<=3000&&flag){expected=0;++count;}
        else if(!(value!=0&&value<=3000)&&!flag){expected=1;--count;}
        vn135_backend_poll_fans_135(&f.s,&f.ops,&f);
        CHECK(f.fans[0].word_20==value&&f.fans[0].byte_1c==expected);
        CHECK(f.s.word_23c==signed_bits(count));CHECK(f.reads==(f.read1>=1000?1u:2u));finish(&f);
    }
    printf("BACKEND_PREPARE135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no real_threads=no\n",scenarios,checks);
    return 0;
}
