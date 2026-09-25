/* Real Linux PTY plus explicitly injected syscall failures. No physical ASIC. */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include "integration/posix_tx88.h"
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pty.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
static unsigned checks,calls;static int mode,slave=-1;
#define CHECK(x) do {++checks;if(!(x)){fprintf(stderr,"pty %d: %s\n",__LINE__,#x);exit(1);}}while(0)
ssize_t __real_write(int,const void *,size_t);
int __real_poll(struct pollfd *,nfds_t,int);
ssize_t __wrap_write(int fd,const void *p,size_t n)
{
    if(fd==slave&&mode) {
        ++calls;
        if(mode==2&&calls==1) {errno=EINTR;return -1;}
        if(mode==3&&calls>1) {errno=EIO;return -1;}
        if(mode==4) {errno=EAGAIN;return -1;}
        if(mode==3&&n>17)n=17;
        if((mode==1||mode==2)&&n>7)n=7;
        errno=EAGAIN; /* A successful write must not consult stale errno. */
    }
    return __real_write(fd,p,n);
}
int __wrap_poll(struct pollfd *fds,nfds_t count,int timeout)
{
    if(mode==4&&count==1&&fds[0].fd==slave)return 0; /* injected timeout */
    return __real_poll(fds,count,timeout);
}
static void pair(int *master)
{
    struct termios t;
    CHECK(openpty(master,&slave,NULL,NULL,NULL)==0);
    CHECK(tcgetattr(slave,&t)==0);cfmakeraw(&t);t.c_iflag&=~IXOFF;
    t.c_cflag|=CREAD|CLOCAL;
    CHECK(cfsetispeed(&t,B115200)==0&&cfsetospeed(&t,B115200)==0);
    CHECK(tcsetattr(slave,TCSANOW,&t)==0);
    CHECK(fcntl(slave,F_SETFL,fcntl(slave,F_GETFL)|O_NONBLOCK)==0);
    CHECK(fcntl(*master,F_SETFL,fcntl(*master,F_GETFL)|O_NONBLOCK)==0);
    CHECK(dizzass_posix_uart_check(slave,115200)==0);
    CHECK(dizzass_posix_uart_check(slave,9600)==DIZZASS_SERIAL_INVALID);
}
static void receive(int fd,uint8_t *out,size_t size)
{
    size_t n=0;unsigned attempts=0;
    while(n<size&&++attempts<100) {
        ssize_t k=read(fd,out+n,size-n);
        if(k>0)n+=(size_t)k;
        else {struct pollfd f={fd,POLLIN,0};CHECK(k<0&&(errno==EAGAIN||errno==EWOULDBLOCK));CHECK(poll(&f,1,100)>0);}
    }
    CHECK(n==size);
}
int main(void)
{
    uint8_t words[80],packet[88],got[88];unsigned i,m;int master;
    struct dizzass_serial_receipt r;
    for(i=0;i<80;++i)words[i]=(uint8_t)i;
    CHECK(dizzass_tx88_encode_words(words,80,31,packet,88)==0);
    for(m=0;m<5;++m) {
        mode=0;pair(&master);mode=(int)m;calls=0;
        int rc=dizzass_posix_tx88_write(slave,packet,50,&r);
        if(m<=2) {
            CHECK(rc==0&&r.written==88&&r.outcome==DIZZASS_SERIAL_WRITTEN);
            receive(master,got,88);CHECK(!memcmp(got,packet,88));
            if(m)CHECK(calls==(m==1?13u:14u));
        } else if(m==3) {
            CHECK(rc==DIZZASS_SERIAL_IO&&r.written==17&&r.outcome==DIZZASS_SERIAL_UNCERTAIN);
            receive(master,got,17);CHECK(!memcmp(got,packet,17));
        } else CHECK(rc==DIZZASS_SERIAL_TIMEOUT&&r.written==0&&r.outcome==DIZZASS_SERIAL_NOT_SENT);
        mode=0;CHECK(read(master,got,88)<0&&errno==EAGAIN);close(master);close(slave);
    }
    pair(&master);
    {
        struct termios t; CHECK(tcgetattr(slave,&t)==0);
        t.c_cc[VMIN]=0;CHECK(tcsetattr(slave,TCSANOW,&t)==0);
        CHECK(dizzass_posix_uart_check(slave,115200)==DIZZASS_SERIAL_INVALID);
        t.c_cc[VMIN]=1;CHECK(tcsetattr(slave,TCSANOW,&t)==0);
        CHECK(dizzass_posix_uart_check(slave,115200)==0);
    }
    packet[86]^=1;
    CHECK(dizzass_posix_tx88_write(slave,packet,50,&r)==DIZZASS_SERIAL_INVALID&&r.written==0);
    CHECK(read(master,got,88)<0&&errno==EAGAIN);packet[86]^=1;
    CHECK(dizzass_posix_tx88_write(slave,packet,0,&r)==DIZZASS_SERIAL_INVALID);
    CHECK(dizzass_posix_tx88_write(-1,packet,50,&r)==DIZZASS_SERIAL_INVALID);
    CHECK(dizzass_posix_tx88_write(slave,NULL,50,&r)==DIZZASS_SERIAL_INVALID);
    close(master);
    CHECK(dizzass_posix_tx88_write(slave,packet,50,&r)!=0);
    close(slave);
    /* Real kernel backpressure with an unread PTY, not injected poll. */
    pair(&master);
    {
        uint8_t fill[4096]={0};unsigned blocked=0;size_t total=0;
        for(i=0;i<1000&&blocked<3;++i) {
            ssize_t n=write(slave,fill,sizeof(fill));
            if(n>0){total+=(size_t)n;blocked=0;}
            else{CHECK(errno==EAGAIN);++blocked;usleep(1000);}
        }
        CHECK(blocked==3&&total>0);
        CHECK(dizzass_posix_tx88_write(slave,packet,10,&r)==DIZZASS_SERIAL_TIMEOUT);
        CHECK(r.written<88&&r.outcome!=DIZZASS_SERIAL_WRITTEN);
    }
    close(master);close(slave);
    printf("POSIX_TX88_PASS checks=%u syscall_injection=explicit real_pty=yes backpressure=yes\n",checks);
    return 0;
}
