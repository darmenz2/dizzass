#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "integration/posix_tx88.h"
#include <asm/termbits.h>
#include <asm/ioctls.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <string.h>
#include <sys/ioctl.h>
#include <time.h>
#include <unistd.h>
int dizzass_posix_uart_check(int fd,uint32_t baud)
{
    struct termios2 t; int flags;
    if(fd<0||!baud||baud>10000000) return DIZZASS_SERIAL_INVALID;
    flags=fcntl(fd,F_GETFL);
    if(flags<0||(flags&O_ACCMODE)!=O_RDWR||!(flags&O_NONBLOCK)||ioctl(fd,TCGETS2,&t))
        return DIZZASS_SERIAL_INVALID;
    if((t.c_cflag&CSIZE)!=CS8||!(t.c_cflag&CREAD)||
       (t.c_cflag&(PARENB|CSTOPB|CRTSCTS))||
       (t.c_iflag&(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON|IXOFF))||
       (t.c_oflag&OPOST)||(t.c_lflag&(ECHO|ICANON|ISIG|IEXTEN))||
       t.c_cc[VMIN]!=1||t.c_cc[VTIME]!=0||t.c_ospeed!=baud||(t.c_ispeed&&t.c_ispeed!=baud)) return DIZZASS_SERIAL_INVALID;
    return 0;
}
static int64_t now_ms(void)
{
    struct timespec t;
    if(clock_gettime(CLOCK_MONOTONIC,&t)) return -1;
    return (int64_t)t.tv_sec*1000+t.tv_nsec/1000000;
}
static int packet_ok(const uint8_t *p)
{
    uint16_t crc;
    if(!p||p[0]!=0x55||p[1]!=0xaa||p[2]!=0x21||p[3]!=0x36||
       (p[4]&7)||p[5]!=1||p[6]||p[7]||p[8]||p[9]) return 0;
    if(dizzass_tx88_crc16(p+2,84,0xffff,&crc)) return 0;
    return p[86]==(uint8_t)(crc>>8)&&p[87]==(uint8_t)crc;
}
int dizzass_posix_tx88_write(int fd,const uint8_t p[DIZZASS_TX88_SIZE],uint32_t timeout,
    struct dizzass_serial_receipt *out)
{
    struct dizzass_serial_receipt r={DIZZASS_SERIAL_NOT_SENT,0,0};
    int64_t deadline,n; int rc=DIZZASS_SERIAL_IO,flags;
    if(!out) return DIZZASS_SERIAL_INVALID;
    *out=r;
    if(fd<0||!packet_ok(p)||!timeout||timeout>10000) return DIZZASS_SERIAL_INVALID;
    flags=fcntl(fd,F_GETFL);
    if(flags<0||(flags&O_ACCMODE)!=O_RDWR||!(flags&O_NONBLOCK)||!isatty(fd))
        return DIZZASS_SERIAL_INVALID;
    n=now_ms(); if(n<0) { r.error_number=errno; goto done; }
    deadline=n+timeout;
    while(r.written<DIZZASS_TX88_SIZE) {
        ssize_t wrote; struct pollfd f={fd,POLLOUT,0}; int pr;
        n=now_ms();
        if(n<0) { r.error_number=errno; goto done; }
        if(n>=deadline) { r.error_number=ETIMEDOUT; rc=DIZZASS_SERIAL_TIMEOUT; goto done; }
        wrote=write(fd,p+r.written,DIZZASS_TX88_SIZE-r.written);
        if(wrote>0) { r.written+=(size_t)wrote; r.outcome=DIZZASS_SERIAL_UNCERTAIN; continue; }
        if(wrote<0&&errno==EINTR) continue;
        if(wrote==0 || (errno!=EAGAIN&&errno!=EWOULDBLOCK)) {
            r.error_number=wrote==0?EIO:errno; r.outcome=DIZZASS_SERIAL_UNCERTAIN; goto done;
        }
        n=now_ms();
        if(n<0) { r.error_number=errno; goto done; }
        if(n>=deadline) { r.error_number=ETIMEDOUT; rc=DIZZASS_SERIAL_TIMEOUT; goto done; }
        pr=poll(&f,1,(int)(deadline-n));
        if(pr<0&&errno==EINTR) continue;
        if(pr<0) { r.error_number=errno; goto done; }
        if(pr==0) { r.error_number=ETIMEDOUT; rc=DIZZASS_SERIAL_TIMEOUT; goto done; }
        if(f.revents&(POLLERR|POLLHUP|POLLNVAL)) {
            r.error_number=EIO; r.outcome=DIZZASS_SERIAL_UNCERTAIN; goto done;
        }
    }
    r.outcome=DIZZASS_SERIAL_WRITTEN; rc=0;
done:
    *out=r; return rc;
}
