#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "integration/gpio_value_io.h"
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
static unsigned checks,calls;
static int injection,last_value_fd=-1,close_failure;
#define CHECK(x) do{++checks;if(!(x)){fprintf(stderr,"gpio:%d:%s\n",__LINE__,#x);exit(1);}}while(0)
ssize_t __real_write(int,const void *,size_t);
int __real_close(int);
ssize_t __wrap_write(int fd,const void *data,size_t n)
{
    if(injection){
        ++calls;last_value_fd=fd;
        if(injection==1){errno=EIO;return -1;}
        if(injection==2)return 0;
        if(injection==3&&calls<4){errno=EINTR;return -1;}
        if(injection==4){errno=EINTR;return -1;}
    }
    return __real_write(fd,data,n);
}
int __wrap_close(int fd)
{
    int rc=__real_close(fd);
    if(close_failure&&fd==last_value_fd){errno=EIO;return -1;}
    return rc;
}
static void put(int d,const char *name,const char *v)
{int fd=openat(d,name,O_WRONLY|O_CREAT|O_TRUNC,0600);CHECK(fd>=0);CHECK(__real_write(fd,v,strlen(v))==(ssize_t)strlen(v));CHECK(!__real_close(fd));}
static char value(int d)
{char ch;int fd=openat(d,"value",O_RDONLY);CHECK(fd>=0);CHECK(read(fd,&ch,1)==1);CHECK(!__real_close(fd));return ch;}
int main(void)
{
    char path[]="/tmp/dizzass-gpio-XXXXXX";int d;struct dizzass_gpio_io_receipt r;unsigned i;
    CHECK(mkdtemp(path));d=open(path,O_RDONLY|O_DIRECTORY);CHECK(d>=0);
    put(d,"direction","out\n");put(d,"active_low","0\n");put(d,"value","0");
    CHECK(!dizzass_gpio_value_write_at(d,1,&r));CHECK(r.written==1&&!r.io_errno&&!r.close_errno&&value(d)=='1');
    CHECK(!dizzass_gpio_value_write_at(d,0,&r));CHECK(value(d)=='0');
    put(d,"active_low","1\n");CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO);CHECK(r.written==0&&value(d)=='0');
    put(d,"active_low","0\n");put(d,"direction","in\n");CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO);CHECK(r.written==0&&value(d)=='0');
    put(d,"direction","out\ntrailing");CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO);
    put(d,"direction","out");put(d,"active_low","0");
    for(i=1;i<=4;++i){
        put(d,"value","0");calls=0;injection=(int)i;
        int rc=dizzass_gpio_value_write_at(d,1,&r);
        injection=0;
        CHECK(rc==(i==3?0:DIZZASS_POWER_IO));CHECK(r.written==(i==3?1u:0u));
        CHECK(value(d)==(i==3?'1':'0'));if(i==4)CHECK(calls==8);
    }
    put(d,"value","0");injection=5;close_failure=1;last_value_fd=-1;
    CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO);
    injection=close_failure=0;CHECK(r.written==1&&r.close_errno==EIO&&value(d)=='1');
    CHECK(unlinkat(d,"value",0)==0);CHECK(symlinkat("direction",d,"value")==0);
    CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO&&r.written==0);
    CHECK(unlinkat(d,"value",0)==0);CHECK(mkfifoat(d,"value",0600)==0);
    CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO&&r.written==0);
    CHECK(unlinkat(d,"value",0)==0);put(d,"value","0");
    CHECK(unlinkat(d,"active_low",0)==0);CHECK(mkfifoat(d,"active_low",0600)==0);
    CHECK(dizzass_gpio_value_write_at(d,1,&r)==DIZZASS_POWER_IO&&r.written==0);
    CHECK(dizzass_gpio_value_write_at(d,2,&r)==DIZZASS_POWER_INVALID);
    CHECK(unlinkat(d,"direction",0)==0);CHECK(unlinkat(d,"active_low",0)==0);CHECK(unlinkat(d,"value",0)==0);
    CHECK(!close(d));CHECK(!rmdir(path));
    printf("GPIO_VALUE_IO_PASS checks=%u actual_temp_file_io=yes physical_gpio=no injected_errors=explicit\n",checks);
    return 0;
}
