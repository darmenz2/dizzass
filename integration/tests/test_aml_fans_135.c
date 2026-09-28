/* Offline native bounds/semantic tests; callbacks never access real devices. */
#include "integration/aml_fans_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned assertions,scenarios;
#define A(x) do { ++assertions; if (!(x)) {fprintf(stderr,"line %d: %s\n",__LINE__,#x);abort();} } while (0)
struct context {
    struct vn135_aml_fans *s;
    unsigned opens,closes,fail_mask,writes,locks,unlocks,logs,last_log;
    uint32_t written[16],values[2];
    unsigned reads,read_fail;
    int create_rc; uint32_t create_entry,create_arg;
    unsigned cancels,names,exits,seeks,sleeps,pos,npolls;
    char lines[3][4][128];unsigned nlines[3];
    uint32_t captured[3][8];
    uint32_t self,mutated_handle;unsigned selves,detaches,thread_cancels,joins;
    uint32_t detached,cancelled,joined;

};
static uint32_t op_open(void *p,const char *path,const char *mode)
{
    struct context *c=p;unsigned i=c->opens++;
    A(path && (!strcmp(mode,"w")||!strcmp(mode,"r")));
    return c->fail_mask&(1u<<i)?0:100u+i;
}
static int32_t op_close(void *p,uint32_t h)
{struct context*c=p;A(h>=100&&h<110);++c->closes;return -1;}
static int32_t op_write(void*p,uint32_t h,const char*f,uint32_t v)
{struct context*c=p;A(h>=100&&h<110);A(!strcmp(f,"%u"));A(c->writes<16);c->written[c->writes++]=v;return -1;}
static int32_t op_read(void*p,uint32_t h,const char*f,uint32_t*v)
{struct context*c=p;unsigned i=c->reads++;A(h>=100&&h<110);A(!strcmp(f,"%u"));A(i<2);if(c->read_fail&(1u<<i))return -1;*v=c->values[i];return 1;}
static int32_t op_mutex(void*p,uint32_t unlock)
{struct context*c=p;if(unlock)++c->unlocks;else ++c->locks;return -1;}
static int32_t op_create(void*p,uint32_t*h,uint32_t e,uint32_t a)
{struct context*c=p;c->create_entry=e;c->create_arg=a;*h=0x5555;return c->create_rc;}
static int32_t op_cancel(void*p,uint32_t v)
{struct context*c=p;A(v==1);++c->cancels;return -1;}
static int32_t op_name(void*p,const char*n)
{struct context*c=p;A(!strcmp(n,"fans@btm"));++c->names;return -1;}
static int32_t op_seek(void*p,uint32_t h,int32_t off,int32_t w)
{struct context*c=p;A(h==100&&off==0&&w==0);c->pos=0;++c->seeks;return 0;}
static char *op_line(void*p,char*out,uint32_t n,uint32_t h)
{struct context*c=p;const char*s;size_t len;A(h==100&&n==256);A(c->sleeps<3);if(c->pos>=c->nlines[c->sleeps])return NULL;s=c->lines[c->sleeps][c->pos++];len=strlen(s);A(len<n);memcpy(out,s,len+1);return out;}
static int32_t op_sleep(void*p,uint32_t ms)
{struct context*c=p;unsigned i;A(ms==1000&&c->sleeps<3);for(i=0;i<4;++i){c->captured[c->sleeps][2*i]=c->s->samples[i].rpm;c->captured[c->sleeps][2*i+1]=c->s->samples[i].previous;}++c->sleeps;if(c->sleeps>=c->npolls)c->s->running=0;return -1;}
static void op_exit(void*p,uint32_t value)
{struct context*c=p;A(value==0);++c->exits;}
static void op_log(void*p,uint32_t line,uint32_t a)
{struct context*c=p;(void)a;++c->logs;c->last_log=line;}
static uint32_t op_self(void*p)
{struct context*c=p;A(c->s->running==0);++c->selves;return c->self;}
static int32_t op_detach(void*p,uint32_t h)
{struct context*c=p;A(c->s->running==0);++c->detaches;c->detached=h;return -1;}
static int32_t op_thread_cancel(void*p,uint32_t h)
{struct context*c=p;A(c->s->running==0);++c->thread_cancels;c->cancelled=h;if(c->mutated_handle)c->s->thread=c->mutated_handle;return -1;}
static int32_t op_join(void*p,uint32_t h)
{struct context*c=p;A(c->s->running==0);++c->joins;c->joined=h;return -1;}
static const struct vn135_aml_fan_ops ops={op_open,op_close,op_write,op_read,op_mutex,
 op_create,op_cancel,op_name,op_seek,op_line,op_sleep,op_exit,op_log,op_self,op_detach,op_thread_cancel,op_join};
static void setters(void)
{
    int d;unsigned mask;struct context c;
    for(d=-100;d<=200;++d){
        memset(&c,0,sizeof(c));vn135_aml_fans_set_all_135(&ops,&c,d);
        A(c.opens==6&&c.closes==6&&c.writes==8&&c.logs==0);
        A(c.locks==2&&c.unlocks==2);
        A(c.written[0]==0&&c.written[1]==100000&&c.written[3]==1);
        A(c.written[4]==0&&c.written[5]==100000&&c.written[7]==1);
        A(c.written[2]==(d<0?0u:d>=100?100000u:(uint32_t)d*1000u));
        A(c.written[6]==c.written[2]);++scenarios;
    }
    for(mask=0;mask<64;++mask){unsigned expected=0,closed=0,i;
        memset(&c,0,sizeof(c));c.fail_mask=mask;vn135_aml_fans_set_all_135(&ops,&c,50);
        if(!(mask&7))expected+=4;
        if(!(mask&56))expected+=4;
        for(i=0;i<6;++i)if(!(mask&(1u<<i)))++closed;
        A(c.opens==6&&c.closes==closed&&c.writes==expected);
        A(c.logs==2-expected/4);++scenarios;
    }
    {int32_t extremes[]={INT32_MIN,INT32_MAX};unsigned i;
      for(i=0;i<2;++i){memset(&c,0,sizeof(c));vn135_aml_fans_set_channel_135(&ops,&c,0xffffffff,extremes[i]);A(c.written[2]==(i?100000u:0));++scenarios;}}
}
static void getters(void)
{
    struct context c;struct vn135_aml_fans s={0};unsigned v,mask;
    for(v=0;v<=150;++v){memset(&c,0,sizeof(c));c.values[0]=100000;c.values[1]=v*1000;
      A(vn135_aml_fans_get_duty_135(&ops,&c)==(v>100?100:v));A(c.reads==2&&c.closes==2);++scenarios;}
    for(mask=0;mask<4;++mask){memset(&c,0,sizeof(c));c.read_fail=mask;c.values[0]=100000;c.values[1]=25000;
      A(vn135_aml_fans_get_duty_135(&ops,&c)==((mask&2)?0u:25u));++scenarios;}
    for(mask=1;mask<4;++mask){memset(&c,0,sizeof(c));c.fail_mask=mask;
      A(vn135_aml_fans_get_duty_135(&ops,&c)==0);A(c.reads==0&&c.logs==1&&c.last_log==127);++scenarios;}
    s.samples[0].rpm=0xffffffff;s.samples[3].rpm=0x80000000;
    memset(&c,0,sizeof(c));A(vn135_aml_fans_get_rpm_135(&s,&ops,&c,0)==0xffffffff);
    A(vn135_aml_fans_get_rpm_135(&s,&ops,&c,3)==0x80000000);
    A(vn135_aml_fans_get_rpm_135(&s,&ops,&c,0xffffffff)==0);A(c.last_log==218);++scenarios;
}
static void workers(void)
{
    struct guarded {unsigned char before[16];struct vn135_aml_fans s;unsigned char after[16];}g;
    struct context c;unsigned j,i;static const int labels[]={27,26,28,29};
    for(j=0;j<100;++j){memset(&g,0xa5,sizeof(g));memset(&g.s,0,sizeof(g.s));memset(&c,0,sizeof(c));c.s=&g.s;c.npolls=3;
      for(i=0;i<4;++i){
        (void)snprintf(c.lines[0][i],128," %d: %u 999999 gpiolib\n",labels[i],100+j);
        (void)snprintf(c.lines[1][i],128," %d: %u 999999 gpiolib\n",labels[i],120+j);
        (void)snprintf(c.lines[2][i],128," %d: %u 999999 gpiolib\n",labels[i],123+j);
      }
      c.nlines[0]=c.nlines[1]=c.nlines[2]=4;vn135_aml_fans_rpm_worker_135(&g.s,&ops,&c);
      for(i=0;i<4;++i){A(c.captured[0][i*2]==0);A(c.captured[1][i*2]==600);A(c.captured[2][i*2]==90);}
      for(i=0;i<16;++i)A(g.before[i]==0xa5&&g.after[i]==0xa5);
      A(c.seeks==3&&c.sleeps==3&&c.exits==1&&c.closes==1&&c.cancels==1&&c.names==1);A(g.s.running==0);++scenarios;
    }
    memset(&g.s,0,sizeof(g.s));memset(&c,0,sizeof(c));c.s=&g.s;c.npolls=2;
    g.s.samples[0].rpm=777;g.s.samples[0].previous=8;
    vn135_aml_fans_rpm_worker_135(&g.s,&ops,&c);
    A(g.s.samples[0].rpm==777&&g.s.samples[0].previous==8);++scenarios;
    memset(&g.s,0x7f,sizeof(g.s));memset(&c,0,sizeof(c));c.s=&g.s;c.fail_mask=1;
    vn135_aml_fans_rpm_worker_135(&g.s,&ops,&c);
    A(g.s.running==0x7f&&g.s.thread==0x7f7f7f7f);
    for(i=0;i<4;++i)A(g.s.samples[i].rpm==0&&g.s.samples[i].previous==0);
    A(c.closes==0&&c.sleeps==0&&c.exits==1&&c.last_log==57);++scenarios;
    for(j=0;j<3;++j){memset(&g.s,0x5a,sizeof(g.s));memset(&c,0,sizeof(c));c.create_rc=j?-(int)j:0;
      A(vn135_aml_fans_initialize_135(&g.s,&ops,&c)==(j?-1:0));
      A(g.s.thread==0x5555&&g.s.running==0x5a&&c.create_entry==0x1184fc&&c.create_arg==0);++scenarios;}
}
static void shutdowns(void)
{
    unsigned running,same;struct vn135_aml_fans s;struct context c;
    for(running=0;running<256;++running)for(same=0;same<2;++same){
        memset(&s,0x5a,sizeof(s));s.running=(uint8_t)running;s.thread=123;
        memset(&c,0,sizeof(c));c.s=&s;c.self=same?123:456;
        vn135_aml_fans_shutdown_135(&s,&ops,&c);
        A(s.running==0&&s.thread==123&&s.samples[0].rpm==0x5a5a5a5a);
        A(c.selves==(running!=0));A(c.opens==0&&c.writes==0);
        A(c.detaches==((running!=0)&&same));A(c.joins==((running!=0)&&!same));A(c.thread_cancels==c.joins);
        if(c.detaches)A(c.detached==123);
        if(c.joins)A(c.cancelled==123&&c.joined==123);
        ++scenarios;
    }
    memset(&s,0,sizeof(s));memset(&c,0,sizeof(c));s.thread=123;s.running=1;c.s=&s;c.self=456;c.mutated_handle=789;
    vn135_aml_fans_shutdown_135(&s,&ops,&c);A(c.cancelled==123&&c.joined==789&&s.thread==789);++scenarios;
}
int main(void){setters();getters();workers();shutdowns();printf("AML_FANS135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no threads=no\n",scenarios,assertions);return 0;}
