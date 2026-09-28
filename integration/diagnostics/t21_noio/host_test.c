/* SPDX-License-Identifier: GPL-3.0-only
 * Native host tests. Kernel effects are scripted here, not in the ARM binary. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "selftest.h"
#define CHECK(x) do {if(!(x)){fprintf(stderr,"D01_HOST_ASSERT %d\n",__LINE__);return 1;}}while(0)
#ifndef D01_PURE_ONLY
int diag_main(const unsigned long *stack);
static unsigned mode,writes,unames,clocks,used;
static char output[8192];
long diag_write(const void *p,size_t n)
{
    ++writes;
    if(mode==6 && writes<=2) return -4;
    if(mode==7) return -4;
    if(mode==8) return 0;
    if(mode==9) return (long)n+1;
    if(mode==12) return -9;
    if(mode==5 && n>5) n=5;
    if(used+n>=sizeof output) abort();
    memcpy(output+used,p,n); used+=(unsigned)n; output[used]=0;
    return (long)n;
}
long diag_uname(void *p)
{
    ++unames; if(mode==1) return -38;
    memset(p,0,390);
    memcpy((char *)p+2*65,"test-kernel",12);
    memcpy((char *)p+4*65,"host-fixture",13);
    if(mode==14) memset((char *)p+4*65,1,65);
    return 0;
}
long diag_clock(void *p)
{
    ++clocks; if(mode==2) return -38;
    long *t=p; t[0]=(mode==13)?-1:100;
    t[1]=(mode==3)?100-(long)clocks:(mode==4?1000000000L:(long)clocks);
    return 0;
}
#endif
int main(int argc,char **argv)
{
    unsigned n=0,failed=diag_selftest(&n);
    printf("D01_PURE checks=%u failed=%u\n",n,failed);
    if(failed) return 1;
#ifdef D01_PURE_ONLY
    (void)argc;(void)argv;
#else
    if(argc!=2) return 64;
    mode=(unsigned)strtoul(argv[1],NULL,10); if(mode>14) return 64;
    unsigned long stack[4]={1,0,0,0};
    if(mode==10 || mode==11){stack[0]=2;stack[2]=(uintptr_t)(mode==10?"--help":"--mine");}
    int rc=diag_main(stack);
    int want=(mode==1 || mode==2 || mode==3 || mode==4 || mode==13)?2:
             (mode==7 || mode==8 || mode==9 || mode==12)?74:mode==11?64:0;
    CHECK(rc==want);
    CHECK(unames==((mode==10 || mode==11)?0u:1u));
    CHECK(clocks==((mode==10 || mode==11 || mode==1)?0u:mode==2?1u:2u));
    if(mode==0 || mode==5 || mode==6 || mode==14) CHECK(strstr(output,"SELFTEST=PASS"));
    if(want) CHECK(!strstr(output,"SELFTEST=PASS"));
    if(mode==14) CHECK(strstr(output,"????????????????????????????????????????????????????????????????"));
    printf("D01_HOST_MODE_PASS mode=%u return=%d syscall_effects_scripted=1\n",mode,rc);
#endif
    return 0;
}
