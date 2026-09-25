/* New API integration with a real pthread mutex: one producer, one consumer.
 * No claim of all-schedule proof or original pthread-runtime reconstruction. */
#include "xminer/recovery/nonce_fifo.h"
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sched.h>
#define N 50000u
static vn135_nonce_fifo q;
static pthread_mutex_t mutex;
static atomic_int finished,error;
static uint32_t dropped,received;
static void *allocate(void *v,size_t n){(void)v;return malloc(n);}
static void release(void *v,void *p){(void)v;free(p);}
static int init(void *v){return pthread_mutex_init(v,NULL);}
static int lock(void *v){return pthread_mutex_lock(v);}
static int unlock(void *v){return pthread_mutex_unlock(v);}
static int destroy(void *v){return pthread_mutex_destroy(v);}
static vn135_fifo_memory mem={NULL,allocate,release};
static vn135_fifo_sync syncops={&mutex,init,lock,unlock,destroy};
static void fill(vn135_nonce_record72 *r,uint32_t n){for(unsigned j=0;j<72;j++)r->bytes[j]=(uint8_t)(n+29*j);for(unsigned j=0;j<4;j++)r->bytes[j]=(uint8_t)(n>>(8*j));}
static void *producer(void *v){(void)v;for(uint32_t i=0;i<N;i++){
    vn135_nonce_record72 r;uint32_t d=0;fill(&r,i);
    if(vn135_nonce_fifo_push(&q,&r,&syncops,&d)!=0){atomic_store(&error,1);break;}dropped+=d;
 }atomic_store_explicit(&finished,1,memory_order_release);return NULL;}
static void *consumer(void *v){(void)v;uint32_t last=0;for(;;){
    vn135_nonce_record72 r,w;int rc=vn135_nonce_fifo_pop(&q,&r,&syncops);
    if(rc<0){atomic_store(&error,1);break;}
    if(!rc){if(atomic_load_explicit(&finished,memory_order_acquire)&&vn135_nonce_fifo_is_empty(&q,&syncops)==1)break;sched_yield();continue;}
    uint32_t n=r.bytes[0]|(uint32_t)r.bytes[1]<<8|(uint32_t)r.bytes[2]<<16|(uint32_t)r.bytes[3]<<24;
    fill(&w,n);if(n>=N||(received&&n<=last)||memcmp(&r,&w,72)){atomic_store(&error,1);break;}last=n;received++;
 }return NULL;}
int main(void){pthread_t p,c;if(vn135_nonce_fifo_init(&q,&mem,&syncops))return 1;
 if(pthread_create(&p,NULL,producer,NULL))return 1;
 if(pthread_create(&c,NULL,consumer,NULL)){pthread_join(p,NULL);vn135_nonce_fifo_destroy(&q,&mem,&syncops);return 1;}
 int joined=pthread_join(p,NULL)|pthread_join(c,NULL);
 int ok=!joined&&!atomic_load(&error)&&received+dropped==N&&q.push_word==N&&q.ring.count==0;
 if(vn135_nonce_fifo_destroy(&q,&mem,&syncops))ok=0;
 printf("{\"status\":\"%s\",\"produced\":%u,\"received\":%u,\"dropped_oldest\":%u,\"tail_bytes_checked\":true,\"hardware_tested\":false}\n",ok?"PASS":"FAIL",N,received,dropped);
 return ok?0:1;}
