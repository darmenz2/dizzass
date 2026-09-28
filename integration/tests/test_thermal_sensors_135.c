/* Native memory and behavior tests. Every external effect is test RAM. */
#include "integration/thermal_sensors_135.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; assert(x); } while(0)
struct ctx { uint8_t raw; int read_rc,init_rc,finish_rc,fail_reg; unsigned reads,writes,delays,logs,times; double now; unsigned order[32],n; };
static void ev(struct ctx*c,unsigned v){CHECK(c->n<32);c->order[c->n++]=v;}
static int32_t mu(void*p,struct vn135_temperature_sensor*s){(void)p;(void)s;return -1;}
static double now(void*p){struct ctx*c=p;++c->times;return c->now;}
static int32_t init(void*p,struct vn135_temperature_sensor*s){(void)s;return ((struct ctx*)p)->init_rc;}
static int32_t readreg(void*p,struct vn135_temperature_sensor*s,uint32_t r,uint8_t*out)
{struct ctx*c=p;(void)s;CHECK(r==0||r==254);++c->reads;*out=c->raw;return c->read_rc;}
static int32_t writereg(void*p,struct vn135_temperature_sensor*s,uint32_t r,uint8_t v)
{struct ctx*c=p;(void)s;CHECK(r==9||r==17);CHECK(r!=9||v==4);++c->writes;return (int)r==c->fail_reg?-1:0;}
static int32_t finish(void*p,struct vn135_temperature_sensor*s){(void)s;return ((struct ctx*)p)->finish_rc;}
static int32_t delay(void*p,uint32_t n){CHECK(n==50);++((struct ctx*)p)->delays;return -1;}
static void logline(void*p,uint32_t l,uint32_t c,uint32_t s,uint32_t v){(void)l;(void)c;(void)s;(void)v;++((struct ctx*)p)->logs;}
static const struct vn135_temperature_ops ops={mu,mu,mu,now,init,readreg,writereg,finish,delay,logline};
static int32_t tlock(void*p){ev(p,1);return -1;}static int32_t tunlock(void*p){ev(p,2);return -1;}
static uint32_t selectchip(void*p){ev(p,3);return 4;}
static void tlog(void*p,uint32_t line,uint32_t n,int32_t v,uint32_t ix){(void)n;(void)v;(void)ix;ev(p,line);}
static int32_t stop(void*p,int reason){ev(p,reason?5:4);return -1;}
static int32_t full(void*p){ev(p,6);return -1;}
static int32_t event(void*p,uint32_t code,int32_t t){(void)t;ev(p,code);return -1;}
static const struct vn135_thermal_trip_ops trips={tlock,tunlock,selectchip,tlog,stop,full,event};
static struct vn135_temperature_sensor sensor(void)
{
 struct vn135_temperature_sensor s;memset(&s,0,sizeof s);s.access_kind=1;s.state=2;
 s.sample=50;s.corrected=54;s.local_offset=4;s.remote_offset=-3;s.failures=1;
 s.previous_sample=49;s.previous_corrected=53;s.has_previous=1;s.sampled_at=80;s.started_at=40;return s;
}
int main(void)
{
 unsigned raw,k,remote;struct ctx c;struct vn135_temperature_sensor s;
 for(raw=0;raw<256;++raw){
  struct { uint64_t before;struct vn135_temperature_sensor s;uint64_t after; } box;
  memset(&c,0,sizeof c);c.raw=(uint8_t)raw;c.now=100;box.before=123;box.after=456;box.s=sensor();
  CHECK(vn135_temperature_read_local_path(&box.s,&ops,&c)==0);
  {unsigned b=(raw-64u)&255u;int v=b<128?(int)b:(int)b-256;CHECK(box.s.sample==v);CHECK(box.s.corrected==v+4);}
  CHECK(box.s.failures==0);CHECK(box.s.sampled_at==100);CHECK(c.reads==1);CHECK(box.before==123&&box.after==456);++scenarios;
 }
 for(k=0;k<5;++k)for(raw=0;raw<256;++raw)for(remote=0;remote<2;++remote){
  int supported=raw==26||raw==85||raw==89,active=k==1||k==2;memset(&c,0,sizeof c);c.raw=(uint8_t)raw;c.now=100;
  s=sensor();s.access_kind=k;s.remote_enabled=(uint8_t)remote;
  CHECK(vn135_temperature_initialize(&s,&ops,&c,3)==(active&&supported?0:-1));
  CHECK(c.reads==(unsigned)active);CHECK(c.writes==(active&&supported?(unsigned)((k==1)+remote):0));
  CHECK(!active||s.state==(supported?1u:3u));++scenarios;
 }
 memset(&c,0,sizeof c);c.raw=89;c.read_rc=-1;s=sensor();
 CHECK(vn135_temperature_initialize(&s,&ops,&c,0)==-1);CHECK(c.reads==3&&c.delays==3&&s.state==3);++scenarios;
 for(k=0;k<3;++k){
  memset(&c,0,sizeof c);c.read_rc=-1;s=sensor();s.failures=(int32_t)k;
  CHECK(vn135_temperature_read_local_path(&s,&ops,&c)==-1);CHECK(s.failures==(int32_t)k+1);CHECK(s.state==(k==2?3u:2u));++scenarios;
 }
 memset(&c,0,sizeof c);c.read_rc=-1;s=sensor();s.failures=INT_MAX;
 CHECK(vn135_temperature_read_local_path(&s,&ops,&c)==-1);CHECK(s.failures==INT_MIN&&s.state==3);++scenarios;
 for(k=0;k<4;++k){
  memset(&c,0,sizeof c);c.now=100;s=sensor();s.access_kind=4;s.previous_sample=50;
  {int input=80+(int)k;CHECK(vn135_temperature_accept(&s,&ops,&c,input,input)==(k?-1:0));CHECK(s.sample==(k?50:80));CHECK(s.sampled_at==(k?80:100));}++scenarios;
 }
 memset(&c,0,sizeof c);s=sensor();s.local_offset=INT_MAX;
 CHECK(vn135_temperature_accept(&s,&ops,&c,1,1)==0);CHECK(s.corrected==INT_MIN);++scenarios;
 s=sensor();s.remote_offset=37;s.failures=13;s.extended=1;s.has_previous=1;
 vn135_temperature_reset(&s,&ops,&c);CHECK(s.state==0&&s.sample==0&&s.corrected==0);CHECK(s.started_at==0&&s.sampled_at==80);CHECK(s.local_offset==4&&s.failures==13);++scenarios;
 for(k=0;k<3;++k){memset(&c,0,sizeof c);s=sensor();s.access_kind=2;c.now=89.0+0.5*k;
  CHECK(vn135_temperature_fresh(&s,&ops,&c,10)==1);CHECK(s.state==2);++scenarios;}
 c.now=90.01;CHECK(vn135_temperature_fresh(&s,&ops,&c,10)==0);CHECK(s.state==3);++scenarios;
 {struct vn135_temperature_sensor a[2]={sensor(),sensor()};uint32_t ty[2]={0,0};struct vn135_temperature_group g={a,ty,2,10,10};
  memset(&c,0,sizeof c);c.now=100;a[0].sampled_at=1;a[1].sampled_at=95;
  CHECK(vn135_temperature_group_fresh(&g,&ops,&c)==1);a[0].state=3;a[0].role=2;
  CHECK(vn135_temperature_group_fresh(&g,&ops,&c)==0);ty[0]=ty[1]=2;
  CHECK(vn135_temperature_group_fresh(&g,&ops,&c)==1);ty[0]=0;a[0].access_kind=2;
  CHECK(vn135_temperature_check_timeouts(&g,&ops,&c,0,0)==-1);++scenarios;
 }
 {struct vn135_thermal_chip chips[2]={{5,10},{7,20}};struct vn135_thermal_chain ch={0,70,90,2,chips};struct vn135_thermal_limits lim={70,90};
  unsigned expected_pcb[]={1,2,1297,4,6,3002},expected_chip[]={1,2,3,1307,5,6,3003};
  memset(&c,0,sizeof c);CHECK(vn135_thermal_check_overheat(&ch,&lim,&trips,&c)==-1);CHECK(c.n==6&&!memcmp(c.order,expected_pcb,sizeof expected_pcb));
  ch.board_temperature=69;memset(&c,0,sizeof c);CHECK(vn135_thermal_check_overheat(&ch,&lim,&trips,&c)==-1);CHECK(c.n==7&&!memcmp(c.order,expected_chip,sizeof expected_chip));
  ch.chip_temperature=89;memset(&c,0,sizeof c);CHECK(vn135_thermal_check_overheat(&ch,&lim,&trips,&c)==0);CHECK(c.n==2);scenarios+=3;
 }
 printf("THERMAL135_NATIVE_PASS scenarios=%u assertions=%u hardware=no\n",scenarios,checks);return 0;
}
