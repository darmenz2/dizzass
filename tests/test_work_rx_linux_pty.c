/* Stage 6 Linux PTY -> recovered UART -> new RX stream integration test.
 * NEW test adapter, not recovered vendor source or a production driver.
 * Opens a pseudoterminal allocated by THIS test only. No real UART/ASIC.
 */
#define _GNU_SOURCE
#include "xminer/recovery/uart.h"
#include "xminer/recovery/work_rx.h"
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
static void delivered(const vn135_work_rx_message *m, uint32_t kind) {
    assert(m->kind==kind && m->chain_id==17);
    if (kind==VN135_RX_REGISTER) {
        assert(m->register_value==UINT32_C(0x12345678));
        assert(m->chip_address==0x3b && m->register_address==0x18);
        assert(m->crc5_field==7);
    }
}
int main(void) {
    int master=posix_openpt(O_RDWR|O_NOCTTY|O_NONBLOCK);assert(master>=0);
    assert(grantpt(master)==0 && unlockpt(master)==0);
    char *path=ptsname(master);assert(path);
    adapter a={0};a.allowed_path=path;
    vn135_uart_ops o={&a,op_open,op_dup,op_free,op_ioctl,op_read,op_write,op_errno,op_close,op_flush,op_init,op_lock,op_unlock,op_destroy,op_sleep};
    vn135_uart u=VN135_UART_INITIALIZER;
    assert(vn135_uart_open(&u,&o,path)==0);
    const uint32_t cfg[][3]={{0,0,0},{1,7,0},{1,2,0},{1,7,1}};
    const uint8_t frames[][11]={
        {0xaa,0x55,0x12,0x34,0x56,0x78,0x3b,0x18,7},
        {0xaa,0x55,0x99,0x12,0x34,0x56,0x78,0x3b,0x18,7},
        {0xaa,0x55,0x12,0x34,0x56,0x78,0x3b,0x18,0xa0,0xb0,7},
        {0xaa,0x55,0x12,0x34,0x56,0x78,0x3b,0x18,0x87}};
    unsigned total=0;
    for (size_t c=0;c<4;++c) for(size_t fragment=1;fragment<=11;++fragment) {
        vn135_work_rx_stream s;
        assert(vn135_work_rx_stream_init(&s,17,cfg[c][0],cfg[c][1],cfg[c][2])==0);
        size_t bytes=s.policy.frame_size;uint8_t pair[22];
        memcpy(pair,frames[c],bytes);memcpy(pair+bytes,frames[c],bytes);
        size_t sent=0;unsigned count=0;
        while(sent<2*bytes) {
            size_t n=2*bytes-sent;if(n>fragment)n=fragment;
            assert(write(master,pair+sent,n)==(ssize_t)n);sent+=n;
            size_t readbytes=0;
            while(readbytes<n) {
                uint8_t buffer[32];wait_input(u.fd);
                int32_t r=vn135_uart_read(&u,&o,buffer,sizeof(buffer));assert(r>0);
                readbytes+=(size_t)r;assert(readbytes<=n);
                size_t at=0;
                while(at<(size_t)r) {
                    vn135_work_rx_message m;size_t used=999;
                    int code=vn135_work_rx_stream_feed(&s,buffer+at,(size_t)r-at,&used,&m);
                    assert(code==0 || code==VN135_RX_REGISTER);
                    assert(used>0 && used<=(size_t)r-at);at+=used;
                    if(code>0) {delivered(&m,VN135_RX_REGISTER);++count;++total;}
                }
            }
        }
        assert(s.used==0 && count==2);
    }
    assert(vn135_uart_flush(&u,&o)==0);
    vn135_uart_destroy(&u,&o);assert(close(master)==0);
    printf("Stage 6 real Linux PTY -> UART -> RX: PASS (%u decoded messages)\n",total);
    return 0;
}
