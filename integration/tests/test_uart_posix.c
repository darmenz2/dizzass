/* SPDX-License-Identifier: GPL-3.0-only
 * Syscall scripts at the POSIX boundary; linked B-01 is unchanged. */
#define _POSIX_C_SOURCE 200809L
#include "integration/native/uart_posix.h"
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

static unsigned scenarios, checks;
static const char *name;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr,"UART_POSIX_ASSERT case=%s line=%d %s\n",name,__LINE__,#x); exit(1); } } while (0)
enum kind { FLAGS, ATTR, CLOCK, WRITE, WAIT };
struct event { enum kind kind; int result, error; uint64_t ms; long nsec; size_t offset; int timeout; short revents; };
static struct { struct event e[128]; size_t used, next, length, accepted; int fd; uint8_t data[16], before[16], bytes[16]; } f;
static void init(const char *label) { memset(&f,0,sizeof f); name=label; f.length=7; f.fd=19; for(unsigned i=0;i<16;++i)f.data[i]=(uint8_t)(i*37); memcpy(f.before,f.data,16); }
static void add(struct event e) { CHECK(f.used<128); f.e[f.used++]=e; }
static struct event take(enum kind kind) { CHECK(f.next<f.used); struct event e=f.e[f.next++]; CHECK(e.kind==kind); return e; }
static void clock_at(uint64_t ms) { add((struct event){.kind=CLOCK,.ms=ms,.nsec=-1}); }
static void write_at(size_t off,int n,int error) { add((struct event){.kind=WRITE,.offset=off,.result=n,.error=error}); }
static void wait_at(int timeout,int result,short events,int error) { add((struct event){.kind=WAIT,.timeout=timeout,.result=result,.revents=events,.error=error}); }
static void admit(void) { add((struct event){.kind=FLAGS,.result=O_RDWR|O_NONBLOCK}); add((struct event){.kind=ATTR}); }

int __wrap_fcntl(int fd,int cmd,...) { struct event e=take(FLAGS); CHECK(fd==f.fd && cmd==F_GETFL); errno=e.error; return e.result; }
int __wrap_tcgetattr(int fd,struct termios *out) { struct event e=take(ATTR); CHECK(fd==f.fd); memset(out,0,sizeof *out); out->c_oflag=(tcflag_t)e.ms; errno=e.error; return e.result; }
int __wrap_clock_gettime(clockid_t clock,struct timespec *out) { struct event e=take(CLOCK); CHECK(clock==CLOCK_MONOTONIC); out->tv_sec=(time_t)(e.ms/1000); out->tv_nsec=e.nsec<0?(long)(e.ms%1000)*1000000L:e.nsec; if(e.result==2){out->tv_sec=-1;return 0;} if(e.result==3){out->tv_sec=(time_t)(UINT64_MAX/1000+1);return 0;} errno=e.error; return e.result; }
ssize_t __wrap_write(int fd,const void *p,size_t n) { struct event e=take(WRITE); CHECK(fd==f.fd && p==f.data+e.offset && n==f.length-e.offset); CHECK(e.offset==f.accepted); if(e.result>0){CHECK((size_t)e.result<=n); memcpy(f.bytes+f.accepted,p,(size_t)e.result); f.accepted+=(size_t)e.result;} errno=e.error; return e.result; }
int __wrap_poll(struct pollfd *p,nfds_t n,int timeout) { struct event e=take(WAIT); CHECK(n==1 && p->fd==f.fd && p->events==POLLOUT && p->revents==0); CHECK(timeout==e.timeout && timeout>0); p->revents=e.revents; errno=e.error; return e.result; }
static void run(uint64_t deadline,unsigned budget,enum dizzass_uart_status s,size_t written,int error) { struct dizzass_uart_result r=dizzass_uart_posix_write_all(f.fd,f.data,f.length,deadline,budget); CHECK(r.status==s && r.written==written && r.error==error); CHECK(f.next==f.used && f.accepted==written); CHECK(!memcmp(f.bytes,f.before,written) && !memcmp(f.data,f.before,16)); ++scenarios; }

static void partitions(void) {
    for(unsigned mask=0;mask<64;++mask)for(unsigned mode=0;mode<4;++mode){
        init("partitions"); admit(); clock_at(1); unsigned start=0;
        for(unsigned end=1;end<=7;++end){
            if(end<7 && !(mask&(1u<<(end-1))))continue;
            if(mode){ int err=mode==1?EINTR:mode==2?EAGAIN:0;
                write_at(start,err?-1:0,err);clock_at(1);
                if(mode!=1){clock_at(1);wait_at(99,1,POLLOUT,EBADF);clock_at(1);}
            }
            write_at(start,(int)(end-start),ENOSPC);clock_at(1);start=end;
        }
        run(100,4,DIZZASS_UART_OK,7,0);
    }
}
static void admission(void) {
    init("empty"); f.fd=-1;f.length=0;run(0,0,DIZZASS_UART_OK,0,0);
    init("zero-budget");run(0,0,DIZZASS_UART_INVALID_INPUT,0,EINVAL);
    init("null-data"); struct dizzass_uart_result r=dizzass_uart_posix_write_all(-1,NULL,7,0,1);CHECK(r.status==DIZZASS_UART_INVALID_INPUT && r.error==EINVAL && r.written==0);++scenarios;
    init("size-overflow");f.length=(size_t)PTRDIFF_MAX+1;run(0,1,DIZZASS_UART_INVALID_INPUT,0,EOVERFLOW);
    init("bad-fd");f.fd=-1;add((struct event){.kind=FLAGS,.result=-1,.error=EBADF});run(0,1,DIZZASS_UART_INVALID_INPUT,0,EBADF);
    const int flags[]={O_RDWR,O_WRONLY,O_RDONLY|O_NONBLOCK};
    for(unsigned i=0;i<3;++i){init("blocking-or-readonly");add((struct event){.kind=FLAGS,.result=flags[i]});run(0,1,DIZZASS_UART_INVALID_INPUT,0,EINVAL);}
    init("not-tty");add((struct event){.kind=FLAGS,.result=O_WRONLY|O_NONBLOCK});add((struct event){.kind=ATTR,.result=-1,.error=ENOTTY});run(0,1,DIZZASS_UART_INVALID_INPUT,0,ENOTTY);
    init("postprocessing");add((struct event){.kind=FLAGS,.result=O_RDWR|O_NONBLOCK});add((struct event){.kind=ATTR,.ms=OPOST});run(0,1,DIZZASS_UART_INVALID_INPUT,0,EINVAL);
    init("writeonly-allowed");add((struct event){.kind=FLAGS,.result=O_WRONLY|O_NONBLOCK});add((struct event){.kind=ATTR});clock_at(1);write_at(0,7,0);clock_at(1);run(2,1,DIZZASS_UART_OK,7,0);
}
static void errors_and_time(void) {
    for(unsigned progress=0;progress<2;++progress){
        const int errors[]={EIO,EBADF,ENOSPC};
        for(unsigned j=0;j<3;++j){init("fatal-write-prefix");admit();clock_at(1);if(progress){write_at(0,3,0);clock_at(2);}write_at(progress*3,-1,errors[j]);run(100,4,DIZZASS_UART_WRITE_ERROR,progress*3,errors[j]);}
        const short events[]={POLLNVAL,POLLERR,POLLHUP,POLLERR|POLLOUT,POLLHUP|POLLOUT,POLLIN,0};
        for(unsigned j=0;j<7;++j){init("poll-error-prefix");admit();clock_at(1);if(progress){write_at(0,3,0);clock_at(2);}write_at(progress*3,-1,EAGAIN);clock_at(3);clock_at(4);wait_at(96,1,events[j],ENOSPC);run(100,4,DIZZASS_UART_WAIT_ERROR,progress*3,j==0?EBADF:EIO);}
        init("poll-syscall-error");admit();clock_at(1);if(progress){write_at(0,3,0);clock_at(2);}write_at(progress*3,-1,EAGAIN);clock_at(3);clock_at(4);wait_at(96,-1,0,ENOMEM);run(100,4,DIZZASS_UART_WAIT_ERROR,progress*3,ENOMEM);
    }
    init("expired-no-write");admit();clock_at(100);run(100,3,DIZZASS_UART_TIMEOUT,0,ETIMEDOUT);
    for(int n=3;n<=7;n+=4){init("late-accepted-prefix");admit();clock_at(1);write_at(0,n,0);clock_at(100);run(100,3,DIZZASS_UART_TIMEOUT,(size_t)n,ETIMEDOUT);}
    init("clock-fatal-after-prefix");admit();clock_at(1);write_at(0,3,0);add((struct event){.kind=CLOCK,.result=-1,.error=EIO});run(100,3,DIZZASS_UART_CLOCK_ERROR,3,EIO);
    init("clock-backwards");admit();clock_at(9);write_at(0,3,0);clock_at(8);run(100,3,DIZZASS_UART_CLOCK_ERROR,3,EPROTO);
    init("eintr-wait-budget");admit();clock_at(1);write_at(0,-1,EAGAIN);clock_at(1);clock_at(1);wait_at(99,-1,0,EINTR);clock_at(1);run(100,2,DIZZASS_UART_NO_PROGRESS,0,EINTR);
    init("eintr-wait-then-ready");admit();clock_at(1);write_at(0,-1,EAGAIN);clock_at(2);clock_at(3);wait_at(97,-1,0,EINTR);clock_at(4);clock_at(5);wait_at(95,1,POLLOUT,0);clock_at(6);write_at(0,7,0);clock_at(7);run(100,4,DIZZASS_UART_OK,7,0);
    init("poll-expiry");admit();clock_at(1);write_at(0,3,0);clock_at(2);write_at(3,-1,EAGAIN);clock_at(3);clock_at(4);wait_at(96,0,0,0);clock_at(100);run(100,4,DIZZASS_UART_TIMEOUT,3,ETIMEDOUT);
    init("capped-poll-not-expiry");admit();clock_at(1);write_at(0,-1,EAGAIN);clock_at(1);clock_at(1);wait_at(INT_MAX,0,0,0);clock_at((uint64_t)INT_MAX+1);wait_at(2,1,POLLOUT,0);clock_at((uint64_t)INT_MAX+1);write_at(0,7,0);clock_at((uint64_t)INT_MAX+2);run((uint64_t)INT_MAX+3,4,DIZZASS_UART_OK,7,0);
    init("early-poll-wake");admit();clock_at(1);write_at(0,-1,EAGAIN);clock_at(1);clock_at(2);wait_at(98,0,0,0);clock_at(3);wait_at(97,1,POLLOUT,0);clock_at(4);write_at(0,7,0);clock_at(5);run(100,4,DIZZASS_UART_OK,7,0);
    init("wait-clock-failure");admit();clock_at(1);write_at(0,-1,EAGAIN);clock_at(1);add((struct event){.kind=CLOCK,.result=-1,.error=EIO});run(100,4,DIZZASS_UART_WAIT_ERROR,0,EIO);
    init("no-progress");admit();clock_at(1);write_at(0,0,ENOSPC);clock_at(1);run(100,1,DIZZASS_UART_NO_PROGRESS,0,0);
}
static void clock_conversion(void) {
    init("clock-null");CHECK(dizzass_uart_posix_now_ms(NULL)==EINVAL);++scenarios;
    const long ns[]={0,999999,1000000,999999999,1000000000};
    for(unsigned j=0;j<5;++j){init("clock-conversion");uint64_t out=123;add((struct event){.kind=CLOCK,.ms=2000,.nsec=ns[j]});int e=dizzass_uart_posix_now_ms(&out);CHECK(e==(j==4?EOVERFLOW:0));CHECK(out==(j==4?123:2000+(uint64_t)ns[j]/1000000));CHECK(f.next==f.used);++scenarios;}
    for(int n=2;n<=3;++n){init("clock-range");uint64_t out=123;add((struct event){.kind=CLOCK,.result=n});CHECK(dizzass_uart_posix_now_ms(&out)==EOVERFLOW && out==123);++scenarios;}
}
int main(void) { admission();errors_and_time();clock_conversion();partitions();printf("UART_POSIX_UNIT_PASS scenarios=%u checks=%u real_syscalls=0\n",scenarios,checks);return 0; }
