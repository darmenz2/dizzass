#define _POSIX_C_SOURCE 200809L
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
struct receipt { unsigned char bytes[128]; };
static void check(int e) { if(e) abort(); }
__attribute__((noinline)) static struct receipt transaction(void) {
    struct receipt r = {{0}};
    int saved;
    check(pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved));
    r.bytes[0] = 7;
    check(pthread_cancel(pthread_self()));
    __asm__ volatile ("" : "+m"(r) : : "memory");
    check(pthread_setcancelstate(saved, NULL));
    return r;
}
static void *worker(void *unused) {
    (void)unused;
    volatile struct receipt r = transaction();
    (void)r;
    pthread_testcancel();
    return NULL;
}
int main(void) {
    pthread_t thread; void *value;
    alarm(10);
    check(pthread_create(&thread, NULL, worker, NULL));
    check(pthread_join(thread, &value));
    if(value != PTHREAD_CANCELED) return 2;
    puts("INDEPENDENT_CANCEL_PROBE_PASS");
    return 0;
}
