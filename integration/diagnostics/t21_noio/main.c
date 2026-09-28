/* SPDX-License-Identifier: GPL-3.0-only
 * Diagnostic executable, NOT cgminer and NOT a hardware discovery tool. */
#include <stddef.h>
#include <stdint.h>
#include "selftest.h"

long diag_write(const void *data, size_t bytes); /* fixed fd1, no open */
long diag_uname(void *data);
long diag_clock(void *data);                   /* CLOCK_MONOTONIC only */
struct diag_time { long sec, nsec; };
struct diag_uts { char fields[6][65]; };         /* Linux new_utsname */
_Static_assert(sizeof(struct diag_uts)==390,"Linux uname layout");
static int output_failed;

static void text(const char *s)
{
    size_t n=0; while(s[n]) ++n;
    for(unsigned tries=0;n && tries<32;++tries) {
        long w=diag_write(s,n);
        if(w==-4) continue;                    /* EINTR, bounded attempts */
        if(w<=0 || (size_t)w>n) { output_failed=1; return; }
        n-=(size_t)w; s+=w;
    }
    if(n) output_failed=1;
}
static void hex(unsigned v)
{
    char s[11]={'0','x',0,0,0,0,0,0,0,0,0};
    const char digits[]="0123456789abcdef";
    for(unsigned i=0;i<8;++i) s[2+i]=digits[(v>>(28-4*i))&15u];
    text(s);
}
static int equals(const char *a,const char *b)
{
    size_t i=0;
    while(a[i] && b[i] && a[i]==b[i]) ++i;
    return a[i]==b[i];
}
static void kernel_field(const char p[65])
{
    char s[65]; size_t n=0;
    while(n<64 && p[n]) {
        unsigned char c=(unsigned char)p[n];
        s[n]=(c>=32 && c<127)?(char)c:'?'; ++n;
    }
    s[n]=0; text(s);
}
static int time_valid(const struct diag_time *t)
{ return t->sec>=0 && t->nsec>=0 && t->nsec<1000000000L; }

int diag_main(const unsigned long *initial_stack)
{
    unsigned long argc=initial_stack[0];
    if(argc==2 && equals((const char *)(uintptr_t)initial_stack[2],"--help")) {
        text("Dizzass D-01: run with no arguments. CPU/codec test only. No hardware or mining.\n");
        return output_failed?74:0;
    }
    if(argc!=1) {
        text("D01_USAGE_ERROR: no arguments accepted except --help. No miner settings.\n");
        return 64;
    }
    text("DIZZASS_NOIO_DIAG_D01\nBASE=bf8cd0513440f91f8a34c69137d0436e6fc30c8a\n");
#if defined(__arm__)
    text("BINARY=ARMv7_LE_EABI_soft_float_no_libc\n");
#elif defined(__aarch64__)
    text("BINARY=AArch64_LE_no_libc\n");
#endif
    text("DEVICE_ACCESS=NONE  NETWORK=NONE  MINING=NO\n");
    struct diag_uts u={0};
    long rc=diag_uname(&u);
    if(rc) { text("UNAME=FAIL errno="); hex((unsigned)-rc); text("\n"); return 2; }
    text("KERNEL_MACHINE="); kernel_field(u.fields[4]);
    text("\nKERNEL_RELEASE="); kernel_field(u.fields[2]); text("\n");
    struct diag_time a={0},b={0};
    rc=diag_clock(&a);
    if(!rc) rc=diag_clock(&b);
    if(rc || !time_valid(&a) || !time_valid(&b) || b.sec<a.sec ||
        (b.sec==a.sec && b.nsec<a.nsec)) {
        text("CLOCK_MONOTONIC=FAIL\n"); return 2;
    }
    text("CLOCK_MONOTONIC=PASS\n");
    unsigned checks=0, failed=diag_selftest(&checks);
    text("CHECKS="); hex(checks); text("\n");
    if(failed) { text("SELFTEST=FAIL check="); hex(failed); text("\n"); return 1; }
    /* A blocked inherited stdout can block: this is not a watchdog. */
    if(output_failed) return 74;
    text("SELFTEST=PASS\nHARDWARE_NOT_TESTED=1  POOL_ACCEPTED_SHARES=0\n");
    return output_failed?74:0;
}
