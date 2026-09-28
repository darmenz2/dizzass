/* SPDX-License-Identifier: GPL-3.0-only
 * Offline harness: actual native cgminer work/allocator/hash helpers. Never
 * calls core startup. Control and allocated-PTY modes are distinct binaries. */
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "integration/native/native_job_channel_tx.h"
#include "integration/native/protocol_channel_tx.h"
#include "tests/fixtures/genesis_work.h"
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pty.h>
#include <stdatomic.h>
#include <sys/socket.h>
#include <termios.h>

static unsigned nj_cases;
#define NJ_CHECK(x) do { if (!(x)) { fprintf(stderr, "NATIVE_JOB_TX_ASSERT %d: %s\n", __LINE__, #x); exit(1); } } while (0)
int __wrap_socket(int domain, int type, int protocol)
{ (void)domain; (void)type; (void)protocol; abort(); }
int __wrap_connect(int fd, const struct sockaddr *a, socklen_t n)
{ (void)fd; (void)a; (void)n; abort(); }
int __wrap_libusb_init(void *ctx) { (void)ctx; abort(); }
static _Thread_local int nj_fail_strdup = -1;
char *__real_strdup(const char *s);
char *__wrap_strdup(const char *s)
{ if (nj_fail_strdup >= 0 && nj_fail_strdup-- == 0) return NULL; return __real_strdup(s); }
static uint32_t nj_le(const uint8_t *p)
{ return p[0] | (uint32_t)p[1]<<8 | (uint32_t)p[2]<<16 | (uint32_t)p[3]<<24; }
static struct work *nj_work(void)
{
    struct work *w = make_work();
    memcpy(w->data, fixture_words, sizeof fixture_words);
    set_target(w->target, 1.0);
    w->job_id=strdup("native-job-channel-fixture"); w->nonce1=strdup("00112233");
    w->ntime=strdup("495fab29"); w->coinbase=strdup("retained-native-copy");
    NJ_CHECK(w->job_id && w->nonce1 && w->ntime && w->coinbase);
    return w;
}
static struct dizzass_nonce_reply nj_reply(unsigned slot, unsigned variant)
{ return (struct dizzass_nonce_reply){2,slot,variant,nj_le(fixture_words+76),0}; }
static struct dizzass_uart_channel_state nj_state(struct dizzass_uart_channel *c)
{ struct dizzass_uart_channel_state s; NJ_CHECK(!dizzass_uart_channel_snapshot(c,&s)); return s; }
static uint64_t nj_now(void)
{ uint64_t t; NJ_CHECK(!dizzass_uart_posix_now_ms(&t)); return t; }
static void nj_dispose(struct dizzass_jobs **j,struct dizzass_uart_channel **c)
{ NJ_CHECK(!dizzass_uart_channel_stop(*c,0)); NJ_CHECK(!dizzass_uart_channel_destroy(c)); dizzass_jobs_destroy(j); }
static void nj_match(struct dizzass_jobs *j,unsigned slot,unsigned variant)
{
    struct dizzass_nonce_reply p=nj_reply(slot,variant);
    struct dizzass_job_result q={0};
    NJ_CHECK(!dizzass_jobs_check(j,41,&p,&q));
    NJ_CHECK(q.check.passes_diff1 && q.check.meets_target);
    NJ_CHECK(!memcmp(q.check.work->hash,fixture_hash,32));
    NJ_CHECK(!strcmp(q.check.work->job_id,"native-job-channel-fixture"));
    NJ_CHECK(!strcmp(q.check.work->coinbase,"retained-native-copy"));
    dizzass_job_result_clear(&q);
}
#include "integration/tests/native_job_channel_cases.h"
int main(void)
{
    alarm(45);
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug=false; opt_quiet=true; opt_realquiet=true;
#ifdef NJ_CONTROL
    nj_controls();
    printf("NATIVE_JOB_TX_CONTROL_PASS cases=%u native_core_helpers=1 lower_frame_scripted=1\n",nj_cases);
#else
    nj_ptys();
    printf("NATIVE_JOB_TX_PTY_PASS cases=%u native_core_helpers=1 physical_uart=0 pool_submit=0\n",nj_cases);
#endif
    alarm(0); return 0;
}
