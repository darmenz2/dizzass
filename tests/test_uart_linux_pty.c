/* Linux integration test for the reconstructed host UART layer.
 * NEW test adapter, not recovered vendor source or a production driver.
 * Opens a pseudoterminal allocated by THIS test only. No real UART/ASIC.
 */
#define _GNU_SOURCE
#include "xminer/recovery/uart.h"
#include "xminer/recovery/aml_chip.h"
#include <asm/termbits.h>
#include <asm/ioctls.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <time.h>
#include <unistd.h>

_Static_assert(sizeof(struct termios2)==sizeof(vn135_uart_attributes),"termios2 Linux size");
_Static_assert(offsetof(struct termios2,c_cc)==offsetof(vn135_uart_attributes,control_chars),"termios2 cc layout");
_Static_assert(offsetof(struct termios2,c_ispeed)==offsetof(vn135_uart_attributes,input_speed),"termios2 speed layout");
_Static_assert(TCGETS2==VN135_UART_TCGETS2 && TCSETS2==VN135_UART_TCSETS2,"ioctl ABI");
_Static_assert(FIONREAD==VN135_UART_FIONREAD,"FIONREAD ABI");
_Static_assert((O_RDWR|O_NOCTTY|O_NONBLOCK)==VN135_UART_OPEN_FLAGS,"open ABI");
_Static_assert(EAGAIN==VN135_UART_EAGAIN,"errno ABI");
_Static_assert(sizeof(int)==sizeof(int32_t),"errno size");

typedef struct { pthread_mutex_t mutex; const char *allowed_path; unsigned write_calls; } adapter;
static int32_t op_open(void *p,const char *path,uint32_t f){adapter*a=p;assert(strcmp(path,a->allowed_path)==0);return open(path,(int)f);}
static char *op_dup(void*p,const char*s){(void)p;char*r=strdup(s);assert(r);return r;}
static void op_free(void*p,void*b){(void)p;free(b);}
static int32_t op_ioctl(void*p,int32_t fd,uint32_t req,void*b){(void)p;return ioctl(fd,(unsigned long)req,b);}
static int32_t op_read(void*p,int32_t fd,uint8_t*b,uint32_t n){(void)p;return (int32_t)read(fd,b,n);}
static int32_t op_write(void*p,int32_t fd,const uint8_t*b,uint32_t n){adapter*a=p;a->write_calls++;return (int32_t)write(fd,b,n);}
static int32_t *op_errno(void*p){(void)p;return &errno;}
static int32_t op_close(void*p,int32_t fd){(void)p;return close(fd);}
static int32_t op_flush(void*p,int32_t fd,int32_t q){(void)p;return ioctl(fd,TCFLSH,q);}
static int32_t op_init(void*p){adapter*a=p;int r=pthread_mutex_init(&a->mutex,NULL);assert(r==0);return r;}
static void op_lock(void*p){adapter*a=p;assert(pthread_mutex_lock(&a->mutex)==0);}
static void op_unlock(void*p){adapter*a=p;assert(pthread_mutex_unlock(&a->mutex)==0);}
static void op_destroy(void*p){adapter*a=p;assert(pthread_mutex_destroy(&a->mutex)==0);}
static void op_sleep(void*p,uint32_t ms){(void)p;struct timespec t={(time_t)(ms/1000),(long)(ms%1000)*1000000L};while(nanosleep(&t,&t)!=0)assert(errno==EINTR);}
static void wait_input(int fd){
    for(unsigned i=0;i<200;i++) { int n=0;assert(ioctl(fd,FIONREAD,&n)==0);if(n>0)return;op_sleep(NULL,1); }
    assert(!"pseudoterminal input timed out");
}
int main(void){
    int master=posix_openpt(O_RDWR|O_NOCTTY|O_NONBLOCK);assert(master>=0);
    assert(grantpt(master)==0 && unlockpt(master)==0);
    char *path=ptsname(master);assert(path);
    adapter a={0};a.allowed_path=path;
    vn135_uart_ops o={&a,op_open,op_dup,op_free,op_ioctl,op_read,op_write,op_errno,op_close,op_flush,op_init,op_lock,op_unlock,op_destroy,op_sleep};
    vn135_uart u=VN135_UART_INITIALIZER;
    assert(vn135_uart_open(&u,&o,path)==0);assert(u.baud==115200 && u.fd>=0);
    struct termios2 actual;assert(ioctl(u.fd,TCGETS2,&actual)==0);
    assert(actual.c_ispeed==115200 && actual.c_ospeed==115200);
    assert(actual.c_cc[VMIN]==7 && actual.c_cc[VTIME]==0);
    assert(!(actual.c_lflag&(ICANON|ECHO|ISIG)));
    assert(vn135_uart_set_baud(&u,&o,250000)==0);
    assert(ioctl(u.fd,TCGETS2,&actual)==0 && actual.c_ospeed==250000 && actual.c_ispeed==250000);
    uint8_t got[128]={0};assert(vn135_uart_read(&u,&o,got,sizeof got)==0);
    const uint8_t raw[]={0xaa,0x55,0x00,0x0a,0x0d,0xff,0x11,0x13,0x80};
    assert(write(master,raw,2)==2);wait_input(u.fd);
    assert(vn135_uart_read(&u,&o,got,sizeof got)==2 && memcmp(got,raw,2)==0);
    assert(write(master,raw+2,sizeof raw-2)==(ssize_t)sizeof raw-2);wait_input(u.fd);
    assert(vn135_uart_read(&u,&o,got+2,sizeof got-2)==(int32_t)sizeof raw-2 && memcmp(got,raw,sizeof raw)==0);
    assert(vn135_uart_read(&u,&o,got,sizeof got)==0);
    uint8_t frame[sizeof raw+2];assert(vn135_aml_frame_command(raw,sizeof raw,frame,sizeof frame)==0);
    assert(vn135_uart_write_legacy(&u,&o,frame,sizeof frame)==(int32_t)sizeof frame);
    assert(a.write_calls==1);wait_input(master);
    assert(read(master,got,sizeof got)==(ssize_t)sizeof frame && memcmp(got,frame,sizeof frame)==0);
    assert(vn135_uart_flush(&u,&o)==0);
    int old=u.fd;assert(vn135_uart_destroy(&u,&o)==0);assert(fcntl(old,F_GETFD)==-1 && errno==EBADF);
    assert(vn135_uart_read(&u,&o,got,sizeof got)==0); /* Original hides ioctl EBADF as no data. */
    assert(vn135_uart_destroy(&u,&o)==0 && close(master)==0);
    puts("Linux PTY: open/termios2/arbitrary baud/fragmented RX/TX frame/flush/destroy: PASS");
    puts("No physical UART, chip protocol, timings, init, mining or autotune tested.");return 0;
}
