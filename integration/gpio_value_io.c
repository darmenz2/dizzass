#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "integration/gpio_value_io.h"
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int attribute(int dir,const char *name,const char *expected)
{
    int fd,err=0; struct stat st; char b[16]; size_t used=0; unsigned intr=0;
    fd=openat(dir,name,O_RDONLY|O_CLOEXEC|O_NOFOLLOW|O_NONBLOCK);
    if(fd<0) return errno;
    if(fstat(fd,&st)) err=errno;
    else if(!S_ISREG(st.st_mode)) err=EINVAL;
    while(!err && used<sizeof(b)) {
        ssize_t n=read(fd,b+used,sizeof(b)-used);
        if(n<0) {
            if(errno==EINTR && ++intr<8) continue;
            err=errno;break;
        }
        if(!n) break;
        used+=(size_t)n;
    }
    if(!err) {
        size_t want=strlen(expected);
        if(!((used==want || (used==want+1 && b[want]=='\n')) &&
             !memcmp(b,expected,want))) err=EINVAL;
    }
    if(close(fd) && !err) err=errno;
    return err;
}
int dizzass_gpio_value_write_at(int dir,uint32_t value,struct dizzass_gpio_io_receipt *out)
{
    struct dizzass_gpio_io_receipt r={0}; struct stat st;
    int fd,err; ssize_t n; unsigned intr=0; char byte;
    if(!out) return DIZZASS_POWER_INVALID;
    r.value=value;*out=r;
    if(dir<0 || value>1) return DIZZASS_POWER_INVALID;
    if(fstat(dir,&st)) {r.io_errno=errno;goto fail;}
    if(!S_ISDIR(st.st_mode)) {r.io_errno=ENOTDIR;goto fail;}
    err=attribute(dir,"direction","out");
    if(!err) err=attribute(dir,"active_low","0");
    if(err) {r.io_errno=err;goto fail;}
    fd=openat(dir,"value",O_WRONLY|O_CLOEXEC|O_NOFOLLOW|O_NONBLOCK);
    if(fd<0) {r.io_errno=errno;goto fail;}
    if(fstat(fd,&st)) r.io_errno=errno;
    else if(!S_ISREG(st.st_mode)) r.io_errno=EINVAL;
    if(!r.io_errno) {
        byte=value?'1':'0';
        do { n=write(fd,&byte,1); } while(n<0 && errno==EINTR && ++intr<8);
        if(n==1) r.written=1;
        else r.io_errno=n<0?errno:EIO;
    }
    /* Linux close must not be retried: the descriptor may have been released. */
    if(close(fd)) r.close_errno=errno;
    *out=r;
    return r.io_errno || r.close_errno ? DIZZASS_POWER_IO : 0;
fail:
    *out=r;return DIZZASS_POWER_IO;
}
