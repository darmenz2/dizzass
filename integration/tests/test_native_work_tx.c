/* Offline native-work encoder harness. GPL-3.0-or-later.
 * Includes the actual root core, never calls its startup or registers a device.
 */
#define main dizzass_unused_cgminer_main
#include "../../cgminer.c"
#undef main
#include "tests/fixtures/genesis_work.h"
#include <sys/socket.h>

int __wrap_socket(int domain, int type, int protocol)
{
    (void)domain; (void)type; (void)protocol;
    fprintf(stderr,"Unexpected socket in work encoder test\n"); abort();
}
int __wrap_connect(int fd, const struct sockaddr *addr, socklen_t length)
{
    (void)fd; (void)addr; (void)length;
    fprintf(stderr,"Unexpected connect in work encoder test\n"); abort();
}
int __wrap_libusb_init(libusb_context **context)
{
    (void)context;
    fprintf(stderr,"Unexpected USB initialization in work encoder test\n"); abort();
}
static uint32_t dt_rng = UINT32_C(0x8666154d);
static uint32_t dn_random(void)
{
    dt_rng ^= dt_rng << 13; dt_rng ^= dt_rng >> 17; dt_rng ^= dt_rng << 5;
    return dt_rng;
}
static uint32_t dn_le(const unsigned char *p)
{
    return p[0] | (uint32_t)p[1]<<8 | (uint32_t)p[2]<<16 | (uint32_t)p[3]<<24;
}
static void dn_hex(const unsigned char *p, size_t size)
{
    size_t i; for(i=0;i<size;++i) printf("%02x",p[i]);
}
static struct work *dn_work(void)
{
    struct work *w=make_work();
    memcpy(w->data,fixture_words,sizeof(fixture_words));
    memset(w->hash,0xa5,sizeof(w->hash)); set_target(w->target,1.0);
    w->job_id=strdup("offline-fixture-job"); w->nonce1=strdup("00112233");
    w->ntime=strdup("495fab29"); w->coinbase=strdup("offline-owned-string");
    if (!w->job_id || !w->nonce1 || !w->ntime || !w->coinbase) abort();
    return w;
}
#include "integration/tests/native_work_tx_cases.h"
int main(void)
{
    mutex_init(&stats_lock); mutex_init(&console_lock); cglock_init(&control_lock);
    opt_debug=false; opt_quiet=true; opt_realquiet=true;
    dt_all();
    return 0;
}
