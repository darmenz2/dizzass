#define _GNU_SOURCE
#include <pthread.h>
#include <stdlib.h>
static pthread_mutex_t m=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t c=PTHREAD_COND_INITIALIZER;
static int ready,release;
static void *worker(void *p) {
    (void)p; int previous;
    if(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE,&previous)) abort();
    if(pthread_mutex_lock(&m)) abort();
    ready=1; if(pthread_cond_broadcast(&c)) abort();
    while(!release) if(pthread_cond_wait(&c,&m)) abort();
    if(pthread_mutex_unlock(&m)) abort();
    if(pthread_setcancelstate(previous,0)) abort();
    pthread_testcancel(); return 0;
}
int main(void) {
    pthread_t t; void *result=0;
    if(pthread_create(&t,0,worker,0)) abort();
    if(pthread_mutex_lock(&m)) abort();
    while(!ready) if(pthread_cond_wait(&c,&m)) abort();
    if(pthread_cancel(t)) abort();
    release=1; if(pthread_cond_broadcast(&c)) abort();
    if(pthread_mutex_unlock(&m)) abort();
    if(pthread_join(t,&result)) abort();
    return result!=PTHREAD_CANCELED;
}
