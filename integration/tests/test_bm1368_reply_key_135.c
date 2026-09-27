/* Host-only composition: existing shutdown bodies call the selected BM1368
 * getter. All other lower effects are scripted; no actual registry or I/O. */
#include "integration/bm1368_reply_key_135.h"
#include "integration/exit_cleanup_135.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned scenarios, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr,"REPLY_KEY_ASSERT %d %s\n",__LINE__,#x); exit(1); } } while (0)
struct fixture {
    uint32_t guard_a;
    struct vn135_shutdown_state state;
    struct vn135_shutdown_scratch scratch;
    int32_t fans[3];
    uint32_t guard_b;
    unsigned ready, key_calls, cleanup_calls, last_step, marker_calls;
    int32_t effect_rc;
};
static int32_t lock_cb(void *p) { (void)p; return 0; }
static int32_t result_cb(void *p) { return ((struct fixture *)p)->effect_rc; }
static int32_t delay_cb(void *p,uint32_t n) { CHECK(n==100); return result_cb(p); }
static uint32_t self_cb(void *p) { (void)p; return 102; }
static int32_t handle_cb(void *p,uint32_t h) { CHECK(h>=100 && h<110); return result_cb(p); }
static int32_t join_cb(void *p,uint32_t h,uint32_t *out)
{ CHECK(h>=100 && h<110); if(out)*out=0x1234; return result_cb(p); }
static int32_t name_cb(void *p,const char *name)
{ (void)p;(void)name;CHECK(0);return -1; }
static int32_t marker_cb(void *p,const char *path)
{ struct fixture *f=p; CHECK(!strcmp(path,"/tmp/stopped")); ++f->marker_calls; return result_cb(p); }
static void log_cb(void *p,uint32_t line)
{ (void)p; CHECK(line==6420 || line==6504); }
static uint32_t step_cb(void *p,uint32_t ep,uint32_t arg)
{
    struct fixture *f=p; f->last_step=ep;
    switch(ep) {
    case 0x19c:
        CHECK(arg==0); ++f->key_calls;
        return vn135_bm1368_reply_key_135();
    case 0xfdeb4:CHECK(arg==0);return f->ready;
    case 0x8291c:case 0xfdfbc:CHECK(arg==0);return 0;
    case 0xf98b8:CHECK(arg==1 || arg==2);break;
    case 0xf9840:CHECK(arg==0);break;
    case 0x58d08:case 0x5a9fc:case 0x5ac80:CHECK(arg<3);break;
    case 0x860b8:case 0xa6080:case 0x663cc:case 0x287a4:
    case 0x1082b4:case 0x2f6ec:CHECK(arg==0);break;
    default:CHECK(0);
    }
    return (uint32_t)f->effect_rc;
}
static int32_t cleanup_cb(void *p,uint32_t *scratch,uint32_t key)
{
    struct fixture *f=p;
    CHECK(f->key_calls==1 && f->last_step==0x19c);
    CHECK(scratch==f->scratch.cleanup && key==0x44u);
    ++f->cleanup_calls;
    /* Explicit fake boundary result only; no callback table is implemented. */
    scratch[0]=0xaaaabbbbu; scratch[1]=0xccccddddu;
    return f->effect_rc;
}
static int32_t unused(void *p) { (void)p;CHECK(0);return -1; }
static int32_t setv(void *p,uint16_t v) { (void)p;(void)v;CHECK(0);return -1; }
static int32_t count_cb(void *p) { (void)p; return 3; }
static int32_t reset_cb(void *p,uint32_t i) { CHECK(i<3); return result_cb(p); }
static void power_log(void *p,enum vn135_gpio_power_source src,uint32_t line,uint32_t arg)
{ (void)p;CHECK(src==VN135_GP_BASE);CHECK(line==5019||line==5022);CHECK(arg==0); }
static const struct vn135_shutdown_ops ops={lock_cb,result_cb,delay_cb,self_cb,
    handle_cb,handle_cb,join_cb,name_cb,step_cb,cleanup_cb,marker_cb,log_cb};
static const struct vn135_backend_power_ops power={unused,result_cb,setv,count_cb,reset_cb,power_log};

static void one(unsigned common,uint32_t state,unsigned ready,unsigned mode,unsigned board,int32_t rc,unsigned mask)
{
    struct fixture f={0};
    f.guard_a=f.guard_b=0xa5c33c5a; f.ready=ready; f.effect_rc=rc;
    f.state.state=state; f.state.mode=mode; f.state.model_chip_selector=4;
    f.state.board_byte_4f=(uint8_t)board;
    f.state.power=(struct vn135_backend_power_state){1,13500};
    f.state.fan_count=3; f.state.fan_readings=f.fans;
    f.fans[0]=111; f.fans[1]=222; f.fans[2]=333;
    f.scratch.cleanup[0]=7; f.scratch.cleanup[1]=9;
    for(unsigned i=0;i<10;++i)
        f.state.threads[i]=(struct vn135_shutdown_thread){100+i,(uint8_t)((mask>>i)&1)};
    void (*run)(struct vn135_shutdown_state *,const struct vn135_shutdown_ops *,
        const struct vn135_backend_power_ops *,void *,struct vn135_shutdown_scratch *)=
        common?vn135_backend_shutdown_135:vn135_backend_before_exit_135;
    unsigned reached=state!=4 && state!=6 && (state!=0 || ready);
    run(&f.state,&ops,&power,&f,&f.scratch);
    CHECK(f.key_calls==reached && f.cleanup_calls==reached);
    CHECK(f.scratch.cleanup[0]==(reached?0xaaaabbbbu:7));
    CHECK(f.scratch.cleanup[1]==(reached?0xccccddddu:9));
    CHECK(f.guard_a==0xa5c33c5a && f.guard_b==0xa5c33c5a);
    CHECK(f.state.model_chip_selector==4);
    if(common)CHECK(f.state.state==(state==4?4u:6u));
    else CHECK(f.state.state==(reached?4u:state));
    ++scenarios;
    /* A completed shutdown must not obtain the key a second time. */
    if(f.state.state==4 || f.state.state==6) {
        run(&f.state,&ops,&power,&f,&f.scratch);
        CHECK(f.key_calls==reached && f.cleanup_calls==reached);
        ++scenarios;
    }
}
int main(void)
{
    CHECK(vn135_bm1368_reply_key_135()==0x44u); ++scenarios;
    const uint32_t states[]={0,1,2,3,4,5,6,7,0x80000000u,0xffffffffu};
    const int32_t status[]={-7,0,1};
    for(unsigned parent=0;parent<2;++parent)
      for(unsigned s=0;s<sizeof(states)/sizeof(states[0]);++s)
       for(unsigned ready=0;ready<2;++ready)
        for(unsigned mode=0;mode<3;mode+=2)
         one(parent,states[s],ready,mode,1,0,0x3ff);
    for(unsigned parent=0;parent<2;++parent)
      for(unsigned k=0;k<3;++k)
       for(unsigned board=0;board<2;++board)
        for(unsigned mask=0;mask<4;++mask)
         one(parent,2,1,0,board,status[k],mask==0?0:mask==1?0x155:mask==2?0x2aa:0x3ff);
    printf("BM1368_REPLY_KEY135_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);
    return 0;
}
