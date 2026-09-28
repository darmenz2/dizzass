/* Offline SMBus boundary tests. No real device, ioctl or select. */
#include "integration/aml_smbus_135.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks, scenarios;
#define CHECK(x) do { ++checks; assert(x); } while (0)
struct test {
    struct vn135_i2c_iface iface;
    int mode, reading, address_calls, select_calls, transfers, locked, unlocked;
    int sleep20, sleep100, logs, last_line, errors;
    uint32_t address, command, protocol;
    void *data;
    size_t size;
    int64_t last_log;
};
static int32_t lock(void *p,struct vn135_i2c_iface *i)
{struct test*t=p;CHECK(i==&t->iface);++t->locked;return -11;}
static int32_t unlock(void *p,struct vn135_i2c_iface *i)
{struct test*t=p;CHECK(i==&t->iface);++t->unlocked;return -12;}
static int32_t address(void*p,int32_t fd,uint32_t ad)
{
 struct test*t=p;CHECK(fd==t->iface.fd);CHECK(ad==t->address);
 ++t->address_calls;return t->mode==1?-2:0;
}
static int32_t ready(void*p,int32_t nf,uint32_t rd,uint32_t b[32],
                     struct vn135_smbus_timeout*tm)
{
 struct test*t=p;unsigned i;CHECK(nf==t->iface.fd+1);CHECK(rd==(unsigned)t->reading);
 CHECK(tm->seconds==0);CHECK(tm->microseconds==50000);
 for(i=0;i<32;++i)CHECK(b[i]==(i==(unsigned)t->iface.fd/32?
                 1u<<((unsigned)t->iface.fd%32):0));
 ++t->select_calls;tm->seconds=123;tm->microseconds=-1999;
 if(t->mode==2)return 0;
 if(t->mode==3)return -1;
 if(t->mode==4)memset(b,0,128);
 return t->mode==6?-2:1;
}
static int32_t transfer(void*p,int32_t fd,uint8_t rd,uint8_t cmd,uint32_t proto,void*d)
{
 struct test*t=p;size_t j;
 CHECK(fd==t->iface.fd);CHECK(rd==t->reading);CHECK(cmd==(uint8_t)t->command);
 CHECK(proto==t->protocol);CHECK(d==t->data);++t->transfers;
 /* Exact-sized allocations catch a mistaken use of selector as length under ASan. */
 for(j=0;j<t->size;++j)((uint8_t*)d)[j]=(uint8_t)(0xc0+j+t->transfers);
 return t->mode==5?1:0;
}
static int32_t sleep_us(void*p,uint32_t us)
{struct test*t=p;if(us==20000)++t->sleep20;else{CHECK(us==100000);++t->sleep100;}return -8;}
static int32_t err(void*p){++((struct test*)p)->errors;return 4;}
static const char* error_text(void*p,int32_t code)
{(void)p;CHECK(code==4);return "EINTR scripted";}
static void log_op(void*p,uint32_t line,int64_t a,uint32_t b,const char*text)
{
 struct test*t=p;++t->logs;t->last_line=(int)line;t->last_log=a;
 if(line==111||line==172){CHECK(text!=NULL);CHECK(!strcmp(text,"EINTR scripted"));}
 else CHECK(text==NULL);
 if(line==134||line==195){CHECK(a==5);CHECK(b==t->address);}
 if(line==115||line==176)CHECK(a==-1); /* signed division truncates toward zero */
}
static const struct vn135_smbus_ops ops={lock,unlock,address,ready,transfer,sleep_us,err,error_text,log_op};
int main(void)
{
 int rw,mode;unsigned f,proto,cmd;
 const int descriptors[]={0,1,31,32,255,1023};
 for(rw=0;rw<=1;++rw)for(mode=0;mode<7;++mode)
 for(f=0;f<sizeof(descriptors)/sizeof(*descriptors);++f)
 for(proto=1;proto<=3;++proto)for(cmd=0;cmd<2;++cmd){
  struct test t={0};int rc;uint8_t *data;
  t.iface.fd=descriptors[f];t.mode=mode;t.reading=rw;t.address=0x100004c;
  t.command=cmd?0x1234:0xfe;t.protocol=proto;
  t.size=proto==3?2:proto==1&&!rw?0:1;
  data=t.size?malloc(t.size):NULL;CHECK(!t.size||data!=NULL);
  if(data)memset(data,0xa5,t.size);
  t.data=data;
  rc=(rw?vn135_aml_smbus_read_135:vn135_aml_smbus_write_135)
      (&t.iface,t.address,t.command,data,proto,&ops,&t);
  CHECK(t.locked==1);CHECK(t.unlocked==1);CHECK(t.iface.fd==descriptors[f]);
  CHECK(rc==((mode==0||mode==6)?0:-1));
  if(mode==1){CHECK(t.address_calls==5);CHECK(t.select_calls==0);CHECK(t.sleep20==5);}
  if(mode==2){CHECK(t.select_calls==5);CHECK(t.sleep100==5);CHECK(t.transfers==0);}
  if(mode==3){CHECK(t.errors==1);CHECK(t.address_calls==1);CHECK(t.sleep20+t.sleep100==0);}
  if(mode==4){CHECK(t.select_calls==5);CHECK(t.transfers==0);CHECK(t.sleep20+t.sleep100==0);}
  if(mode==5){CHECK(t.transfers==3);CHECK(t.address_calls==3);CHECK(t.sleep20==3);}
  if(mode==0||mode==6){CHECK(t.transfers==1);CHECK(t.address_calls==1);}
  if(t.size)CHECK(data[0]==(t.transfers?(uint8_t)(0xc0+t.transfers):0xa5));
  if(t.size==2)CHECK(data[1]==(t.transfers?(uint8_t)(0xc1+t.transfers):0xa5));
  free(data);++scenarios;
 }
 printf("AML_SMBUS135_NATIVE_PASS scenarios=%u assertions=%u physical_io=no\n",scenarios,checks);
 return 0;
}
