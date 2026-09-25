/* New host-only API tests. No physical devices or original code executed. */
#include "xminer/recovery/uart.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>

typedef struct { unsigned writes,locks,unlocks,sleeps,frees,closes,destroys; int32_t err; } model;
static int32_t write_short(void *p,int32_t fd,const uint8_t *b,uint32_t n) {
    model *m=p;(void)fd;assert(b && n==4);m->writes++;return 2;
}
static void lock_cb(void *p){((model*)p)->locks++;}
static void unlock_cb(void *p){((model*)p)->unlocks++;}
static int32_t *error_cb(void *p){return &((model*)p)->err;}
static void sleep_cb(void *p,uint32_t n){assert(n==20);((model*)p)->sleeps++;}
static void free_cb(void *p,void *b){assert(b);((model*)p)->frees++;}
static int32_t close_cb(void *p,int32_t fd){assert(fd==7);((model*)p)->closes++;return -1;}
static void destroy_cb(void *p){((model*)p)->destroys++;}
static int32_t ioctl_fail(void *p,int32_t fd,uint32_t req,void *arg){(void)p;(void)fd;(void)req;(void)arg;return -1;}
static int32_t read_never(void *p,int32_t fd,uint8_t*b,uint32_t n){(void)p;(void)fd;(void)b;(void)n;assert(0);return -1;}
int main(void){
    model m={0};m.err=11;
    vn135_uart u=VN135_UART_INITIALIZER;
    vn135_uart_ops o={0};o.context=&m;o.write=write_short;o.lock=lock_cb;o.unlock=unlock_cb;o.error_number=error_cb;o.sleep_ms=sleep_cb;
    o.release=free_cb;o.close=close_cb;o.mutex_destroy=destroy_cb;o.ioctl=ioctl_fail;o.read=read_never;
    const uint8_t b[]={1,2,3,4};uint8_t out[4]={0x17,0x17,0x17,0x17};
    assert(vn135_uart_write_legacy(&u,&o,b,4)==2);
    assert(m.writes==5 && m.locks==5 && m.unlocks==5 && m.sleeps==5);
    m.err=5;assert(vn135_uart_write_legacy(&u,&o,b,4)==2);assert(m.writes==6 && m.sleeps==5);
    assert(vn135_uart_read(&u,&o,out,sizeof out)==0);assert(out[0]==0x17);
    assert(vn135_uart_read(&u,&o,NULL,1)==-2);
    assert(vn135_uart_read(&u,&o,out,(size_t)INT32_MAX+1)==-2);
    assert(vn135_uart_write_legacy(&u,&o,NULL,4)==-2);
    assert(vn135_uart_write_legacy(&u,&o,b,(size_t)INT32_MAX+1)==-2);
    assert(vn135_uart_open(&u,&o,"not-opened")==-2);
    assert(vn135_uart_set_baud(NULL,&o,100)==-2);
    assert(vn135_uart_flush(&u,&o)==-2);
    u.path=(char*)b;u.fd=7;u.baud=115200;u.mutex_ready=true;
    assert(vn135_uart_destroy(&u,&o)==0);
    assert(!u.path && u.fd==-1 && u.baud==0 && !u.mutex_ready);
    assert(vn135_uart_destroy(&u,&o)==0); /* New API guard. */
    assert(m.frees==1 && m.closes==1 && m.destroys==1);
    puts("UART native API guards, legacy retry and lifecycle: PASS");return 0;
}
