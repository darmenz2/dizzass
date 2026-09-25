/* SPDX-License-Identifier: GPL-3.0-only */
#include "xminer/recovery/chip1398.h"
#include "xminer/recovery/aml_chip.h"
#include <assert.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { int sequence[8]; size_t used; int fail_alloc, delta; uint8_t captured[64]; size_t size; } fixture;
static void mark(fixture *s,int event) { assert(s->used<8); s->sequence[s->used++]=event; }
static void *alloc_cb(void *p,size_t n) { fixture *s=p; mark(s,1); return s->fail_alloc?NULL:malloc(n); }
static void free_cb(void *p,void *block) { mark(p,5);free(block); }
static void lock_cb(void *p) { mark(p,2); }
static void unlock_cb(void *p) { mark(p,4); }
static int32_t write_cb(void *p,void *uart,const uint8_t *data,uint32_t n)
{
    fixture *s=p;assert(uart==s);mark(s,3);assert(n<=sizeof s->captured);
    memcpy(s->captured,data,n);s->size=n;return s->delta==INT_MIN?-1:(int32_t)n+s->delta;
}
static void zero_result(const vn135_pll_result *p)
{
    const vn135_pll_result zero={0};assert(memcmp(p,&zero,sizeof zero)==0);
}
int main(void)
{
    typedef int (*search_fn)(const vn135_pll_limits *,double,vn135_pll_result *);
    const search_fn funcs[]={vn135_pll_search_legacy,vn135_pll_search_round4};
    for(size_t f=0;f<2;f++) {
        vn135_pll_limits cfg=vn135_bm1398_pll_limits;vn135_pll_result out;
        assert(funcs[f](&cfg,500.,NULL)==-2);
        memset(&out,0xa5,sizeof out);assert(funcs[f](NULL,500.,&out)==-2);zero_result(&out);
        const double bad[]={NAN,INFINITY,-INFINITY,-1.,1e10};
        for(size_t i=0;i<sizeof bad/sizeof bad[0];i++) {
            memset(&out,0xa5,sizeof out);assert(funcs[f](&cfg,bad[i],&out)==-2);zero_result(&out);
        }
        for(int which=0;which<9;which++) {
            cfg=vn135_bm1398_pll_limits;
            switch(which) {
            case 0:cfg.reference_mhz=0;break;case 1:cfg.reference_mhz=NAN;break;
            case 2:cfg.vco_min_mhz=-INFINITY;break;case 3:cfg.vco_max_mhz=INFINITY;break;
            case 4:cfg.initial_error_mhz=NAN;break;case 5:cfg.max_reference_divider=65;break;
            case 6:cfg.max_post_divider=65;break;case 7:cfg.reference_mhz=1e-10;break;
            default:cfg.reference_mhz=1e10;break;
            }
            assert(funcs[f](&cfg,500.,&out)==-2);zero_result(&out);
        }
        cfg=vn135_bm1398_pll_limits;
        assert(funcs[f](&cfg,500.,&out)==0);
        assert(out.reference_divider>0 && out.feedback_divider>0 && out.candidate_written==1);
        assert(out.reserved_28==0);
        cfg.max_reference_divider=0;assert(funcs[f](&cfg,500.,&out)==-1);zero_result(&out);
        cfg.max_reference_divider=INT_MIN;assert(funcs[f](&cfg,500.,&out)==-1);zero_result(&out);
        cfg=vn135_bm1398_pll_limits;cfg.max_post_divider=INT_MIN;
        assert(funcs[f](&cfg,500.,&out)==-1);zero_result(&out);
    }
    /* The original legacy routine can write a zero-feedback candidate then fail. */
    {
        vn135_pll_limits cfg={25.,0.,0.,0.,2,250,7,0,2.5};vn135_pll_result out;
        assert(vn135_pll_search_legacy(&cfg,0.,&out)==-1);
        assert(out.candidate_written==1 && out.feedback_divider==0);
    }
    assert(vn135_bm1398_pll_parameter_word(0xffffffffu,0xffffffffu,0xffffffffu,0xffffffffu)==0x4fff3f77u);
    uint8_t src[]={1,2,3},dst[8];memset(dst,0xa5,sizeof dst);
    assert(vn135_aml_frame_command(src,3,dst,4)==-2);
    for(size_t i=0;i<sizeof dst;i++) assert(dst[i]==0xa5);
    assert(vn135_aml_frame_command(NULL,1,dst,sizeof dst)==-2);
    assert(vn135_aml_frame_command(src,SIZE_MAX,dst,sizeof dst)==-2);
    assert(vn135_aml_frame_command(src,0,NULL,8)==-2);
    assert(vn135_aml_frame_command(NULL,0,dst,2)==0 && dst[0]==0x55 && dst[1]==0xaa);
    assert(vn135_aml_frame_command(src,3,dst,sizeof dst)==0);
    assert(dst[0]==0x55 && dst[1]==0xaa && memcmp(dst+2,src,3)==0 && dst[5]==0xa5);
    fixture s={0};vn135_aml_transport io={&s,alloc_cb,free_cb,lock_cb,unlock_cb,write_cb};
    assert(vn135_aml_send_command(NULL,NULL,NULL,0)==-1 && s.used==0);
    assert(vn135_aml_send_command(&s,NULL,src,3)==-2 && s.used==0);
    assert(vn135_aml_send_command(&s,&io,NULL,1)==-2 && s.used==0);
    assert(vn135_aml_send_command(&s,&io,src,SIZE_MAX)==-2 && s.used==0);
    vn135_aml_transport missing=io;missing.write=NULL;
    assert(vn135_aml_send_command(&s,&missing,src,3)==-2 && s.used==0);
    const int deltas[]={0,-1,1,INT_MIN};
    for(size_t i=0;i<4;i++) {
        memset(&s,0,sizeof s);s.delta=deltas[i];
        assert(vn135_aml_send_command(&s,&io,src,3)==(i==0?0:-1));
        const int expected[]={1,2,3,4,5};assert(s.used==5 && memcmp(s.sequence,expected,sizeof expected)==0);
        assert(s.size==5 && s.captured[0]==0x55 && s.captured[1]==0xaa && memcmp(s.captured+2,src,3)==0);
    }
    memset(&s,0,sizeof s);s.fail_alloc=1;
    assert(vn135_aml_send_command(&s,&io,src,3)==-1 && s.used==1 && s.sequence[0]==1);
    assert(vn135_aml_chain_mask(-1,1,0x1398)==0);
    assert(vn135_aml_chain_mask(256,1,0x1398)==1);
    assert(vn135_aml_chain_mask(INT_MIN,0,0x1398)==1);
    puts("PLL/AML host guards and flow tests: PASS (no hardware)");
    return 0;
}
