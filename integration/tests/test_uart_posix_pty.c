/* SPDX-License-Identifier: GPL-3.0-only
 * Real OS integration on newly allocated PTYs only. Never opens a hardware path.
 * Link wrappers OBSERVE real write/poll; they do not script results. */
#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "integration/native/uart_posix.h"
#include "integration/bm1368_control.h"
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <pty.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

static unsigned scenarios,checks;
static int observed_fd=-1;
static unsigned writes,shorts,again,waits;
#define CHECK(x) do { ++checks; if(!(x)){fprintf(stderr,"UART_POSIX_PTY_ASSERT line=%d %s errno=%d\n",__LINE__,#x,errno);exit(1);} } while(0)
ssize_t __real_write(int,const void *,size_t);
int __real_poll(struct pollfd *,nfds_t,int);
int __real___poll_chk(struct pollfd *,nfds_t,int,size_t);
ssize_t __wrap_write(int fd,const void *p,size_t n) { ssize_t r=__real_write(fd,p,n);int e=errno;if(fd==observed_fd){++writes;if(r>0 && (size_t)r<n)++shorts;if(r<0 && (e==EAGAIN || e==EWOULDBLOCK))++again;}errno=e;return r; }
int __wrap_poll(struct pollfd *p,nfds_t n,int t) { if(n==1 && p[0].fd==observed_fd && p[0].events==POLLOUT)++waits;return __real_poll(p,n,t); }
/* Observe the fortified ABI too; still execute its real bounds check and poll. */
int __wrap___poll_chk(struct pollfd *p, nfds_t n, int timeout, size_t size)
{
    if (n == 1 && p[0].fd == observed_fd && p[0].events == POLLOUT) ++waits;
    return __real___poll_chk(p, n, timeout, size);
}
static uint64_t now(void) { uint64_t t;CHECK(dizzass_uart_posix_now_ms(&t)==0);return t; }
static void pair(int *master,int *slave) { CHECK(openpty(master,slave,NULL,NULL,NULL)==0);struct termios a;CHECK(tcgetattr(*slave,&a)==0);cfmakeraw(&a);CHECK(tcsetattr(*slave,TCSANOW,&a)==0);CHECK(fcntl(*slave,F_SETFL,fcntl(*slave,F_GETFL)|O_NONBLOCK)==0);CHECK(fcntl(*master,F_SETFL,fcntl(*master,F_GETFL)|O_NONBLOCK)==0); }
static void observe(int fd){observed_fd=fd;writes=shorts=again=waits=0;}
static void close_pair(int m,int s){observed_fd=-1;CHECK(close(s)==0);CHECK(close(m)==0);}
static void same_config(int s,int flags,const struct termios *before){struct termios after;CHECK(fcntl(s,F_GETFL)==flags);CHECK(tcgetattr(s,&after)==0);CHECK(before->c_iflag==after.c_iflag && before->c_oflag==after.c_oflag && before->c_cflag==after.c_cflag && before->c_lflag==after.c_lflag);CHECK(!memcmp(before->c_cc,after.c_cc,NCCS));CHECK(cfgetispeed(before)==cfgetispeed(&after) && cfgetospeed(before)==cfgetospeed(&after));}
static size_t collect(int m,uint8_t *out,size_t n){size_t have=0;uint64_t end=now()+4000;while(have<n && now()<end){ssize_t got=read(m,out+have,n-have);if(got>0){have+=(size_t)got;continue;}if(got<0 && errno!=EAGAIN && errno!=EINTR){CHECK(0);}struct pollfd p={m,POLLIN,0};(void)poll(&p,1,10);}return have;}
static void nothing_extra(int m){uint8_t extra;struct pollfd p={m,POLLIN,0};CHECK(poll(&p,1,15)==0);CHECK(read(m,&extra,1)==-1 && (errno==EAGAIN || errno==EWOULDBLOCK));}
static void admission(void){
    int m,s;pair(&m,&s);uint8_t b=10;observe(s);int flags=fcntl(s,F_GETFL);CHECK(fcntl(s,F_SETFL,flags & ~O_NONBLOCK)==0);
    struct dizzass_uart_result r=dizzass_uart_posix_write_all(s,&b,1,now()+100,8);CHECK(r.status==DIZZASS_UART_INVALID_INPUT && !r.written && !writes);CHECK(!(fcntl(s,F_GETFL)&O_NONBLOCK));++scenarios;
    CHECK(fcntl(s,F_SETFL,flags)==0);struct termios a;CHECK(tcgetattr(s,&a)==0);a.c_oflag|=OPOST|ONLCR;CHECK(tcsetattr(s,TCSANOW,&a)==0);r=dizzass_uart_posix_write_all(s,&b,1,now()+100,8);CHECK(r.status==DIZZASS_UART_INVALID_INPUT && !r.written && !writes);same_config(s,flags,&a);nothing_extra(m);++scenarios;close_pair(m,s);
    r=dizzass_uart_posix_write_all(-1,NULL,0,0,0);CHECK(r.status==DIZZASS_UART_OK && !r.written);++scenarios;
    int p[2];CHECK(pipe(p)==0);CHECK(fcntl(p[1],F_SETFL,O_NONBLOCK)==0);r=dizzass_uart_posix_write_all(p[1],&b,1,now()+100,8);CHECK(r.status==DIZZASS_UART_INVALID_INPUT && r.error==ENOTTY && !r.written);CHECK(close(p[0])==0 && close(p[1])==0);++scenarios;
}
static void encoded_frame(void) {
    int m, s;
    pair(&m, &s);
    uint8_t sent[11], received[11];
    size_t length = 0;
    CHECK(dizzass_bm1368_command_encode(DIZZASS_BM1368_SET_CONFIG,
        1, 0, 8, 0x12345678, sent, sizeof sent, &length) == 0);
    CHECK(length == 11 && sent[0] == 0x55 && sent[1] == 0xaa);
    observe(s);
    struct dizzass_uart_result r = dizzass_uart_posix_write_all(s, sent,
        length, now() + 2000, 1000);
    CHECK(r.status == DIZZASS_UART_OK && r.written == length);
    CHECK(collect(m, received, length) == length);
    CHECK(!memcmp(sent, received, length));
    nothing_extra(m);
    printf("PTY existing-BM1368-encoder bytes=%zu no_extra_prefix=1\n", length);
    ++scenarios;
    close_pair(m, s);
}
static void small_roundtrip(void){int m,s;pair(&m,&s);uint8_t sent[512],received[512];for(unsigned i=0;i<512;++i)sent[i]=(uint8_t)i;int flags=fcntl(s,F_GETFL);struct termios a;CHECK(tcgetattr(s,&a)==0);observe(s);struct dizzass_uart_result r=dizzass_uart_posix_write_all(s,sent,sizeof sent,now()+2000,1000);CHECK(r.status==DIZZASS_UART_OK && r.written==sizeof sent);CHECK(collect(m,received,sizeof received)==sizeof received && !memcmp(sent,received,sizeof sent));nothing_extra(m);same_config(s,flags,&a);printf("PTY small bytes=%zu writes=%u\n",r.written,writes);++scenarios;close_pair(m,s);}
static void timeout_prefix(void){int m,s;pair(&m,&s);size_t length=1024*1024;uint8_t *sent=malloc(length),*received=malloc(length);CHECK(sent && received);for(size_t i=0;i<length;++i)sent[i]=(uint8_t)(i*29+7);observe(s);uint64_t begin=now(),deadline=begin+60;struct dizzass_uart_result r=dizzass_uart_posix_write_all(s,sent,length,deadline,1000);uint64_t end=now();CHECK(r.status==DIZZASS_UART_TIMEOUT && r.error==ETIMEDOUT);CHECK(r.written>0 && r.written<length && again>0 && waits>0 && shorts>0);CHECK(end>=deadline && end-begin<5000);CHECK(collect(m,received,r.written)==r.written && !memcmp(sent,received,r.written));nothing_extra(m);printf("PTY backpressure prefix=%zu writes=%u short=%u eagain=%u polls=%u elapsed_ms=%llu\n",r.written,writes,shorts,again,waits,(unsigned long long)(end-begin));free(sent);free(received);++scenarios;close_pair(m,s);}
struct reader {int fd,error;uint8_t *out;size_t want,got;};
static void *read_peer(void *opaque){struct reader *r=opaque;struct timespec delay={0,30000000};while(nanosleep(&delay,&delay)<0 && errno==EINTR){}uint64_t start;if(dizzass_uart_posix_now_ms(&start)){r->error=1;return NULL;}while(r->got<r->want){ssize_t n=read(r->fd,r->out+r->got,r->want-r->got);if(n>0){r->got+=(size_t)n;continue;}if(n<0 && errno!=EAGAIN && errno!=EINTR){r->error=2;return NULL;}struct pollfd p={r->fd,POLLIN,0};if(poll(&p,1,10)<0 && errno!=EINTR){r->error=3;return NULL;}uint64_t t;if(dizzass_uart_posix_now_ms(&t) || t-start>7000){r->error=4;return NULL;}}return NULL;}
static void draining_peer(void){int m,s;pair(&m,&s);size_t length=1024*1024;uint8_t *sent=malloc(length),*got=malloc(length);CHECK(sent && got);for(size_t i=0;i<length;++i)sent[i]=(uint8_t)((i*17)^(i>>9));struct reader reader={m,0,got,length,0};pthread_t thread;observe(s);CHECK(pthread_create(&thread,NULL,read_peer,&reader)==0);struct dizzass_uart_result r=dizzass_uart_posix_write_all(s,sent,length,now()+6000,1000);CHECK(pthread_join(thread,NULL)==0);CHECK(!reader.error && r.status==DIZZASS_UART_OK && r.written==length && reader.got==length);CHECK(!memcmp(sent,got,length));CHECK(shorts>0);nothing_extra(m);printf("PTY draining bytes=%zu writes=%u short=%u eagain=%u polls=%u\n",r.written,writes,shorts,again,waits);free(sent);free(got);++scenarios;close_pair(m,s);}
static void expired_and_hangup(void){int m,s;pair(&m,&s);uint8_t b=42;observe(s);struct dizzass_uart_result r=dizzass_uart_posix_write_all(s,&b,1,now(),8);CHECK(r.status==DIZZASS_UART_TIMEOUT && !writes && !r.written);nothing_extra(m);++scenarios;CHECK(close(m)==0);r=dizzass_uart_posix_write_all(s,&b,1,now()+100,8);CHECK(r.status!=DIZZASS_UART_OK && !r.written);printf("PTY closed-peer status=%d error=%d writes=%u\n",r.status,r.error,writes);observed_fd=-1;CHECK(close(s)==0);++scenarios;}
int main(void){alarm(20);admission();encoded_frame();small_roundtrip();timeout_prefix();draining_peer();expired_and_hangup();alarm(0);printf("UART_POSIX_PTY_PASS scenarios=%u checks=%u physical_uart=0\n",scenarios,checks);return 0;}
