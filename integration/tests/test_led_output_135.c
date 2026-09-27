/* Deterministic host checks. No OS/device/thread effects. */
#include "integration/led_output_135.h"
#include "integration/exit_cleanup_135.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned scenarios, checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr, \
    "LED_ASSERT line=%d %s\n", __LINE__, #x); exit(1); } } while (0)
struct event { uint32_t pin, value; };
struct fixture {
    uint32_t guard0;
    struct vn135_led_state_135 state;
    uint32_t guard1;
    struct event events[8];
    size_t count;
    int32_t error;
    int mutate, reenter;
};
static const struct vn135_led_ops_135 ops;
static int32_t set_value(void *p, uint32_t pin, uint32_t value)
{
    struct fixture *f = p;
    CHECK(f->count < 8);
    f->events[f->count++] = (struct event){pin,value};
    if (f->count == 1 && f->mutate) {
        f->state.ready = 0;
        f->state.pins[1] = 99;
    }
    if (f->count == 1 && f->reenter) {
        f->state.pins[1] = 77;
        vn135_led_clear_135(&f->state,&ops,f,1);
    }
    return f->error;
}
static const struct vn135_led_ops_135 ops = {set_value};
static void init(struct fixture *f, uint8_t ready)
{
    memset(f,0,sizeof(*f));
    f->guard0 = 0x12345678; f->guard1 = 0xabcdef01;
    f->state.ready = ready; f->state.pins[0] = 17; f->state.pins[1] = 29;
}
static void guards(const struct fixture *f)
{ CHECK(f->guard0==0x12345678 && f->guard1==0xabcdef01); }
static void direct(void)
{
    static const uint32_t selectors[] = {0,1,2,3,255,256,0x80000000,UINT32_MAX};
    for (unsigned set=0; set<2; ++set)
        for (unsigned ready=0; ready<256; ++ready)
            for (size_t j=0; j<sizeof(selectors)/sizeof(selectors[0]); ++j) {
                struct fixture f;
                uint32_t s=selectors[j];
                init(&f,(uint8_t)ready); f.error=-17;
                int enabled = set ? ready==1 : ready!=0;
                size_t n=enabled && s<=2 ? (s==2 ? 2:1) : 0;
                if (set) vn135_led_set_135(&f.state,n?&ops:NULL,&f,s);
                else vn135_led_clear_135(&f.state,n?&ops:NULL,&f,s);
                CHECK(f.count==n);
                if (n) CHECK(f.events[0].pin==(s==1?29u:17u) && f.events[0].value==set);
                if (n==2) CHECK(f.events[1].pin==29 && f.events[1].value==set);
                CHECK(f.state.ready==ready && f.state.pins[0]==17 && f.state.pins[1]==29);
                guards(&f); ++scenarios;
            }
    for (unsigned set=0; set<2; ++set) {
        struct fixture f; init(&f,1); f.mutate=1; f.error=-1;
        if (set) vn135_led_set_135(&f.state,&ops,&f,2);
        else vn135_led_clear_135(&f.state,&ops,&f,2);
        CHECK(f.count==2 && f.events[1].pin==99 && f.events[1].value==set);
        CHECK(!f.state.ready); guards(&f); ++scenarios;
        init(&f,1); f.reenter=1;
        if (set) vn135_led_set_135(&f.state,&ops,&f,2);
        else vn135_led_clear_135(&f.state,&ops,&f,2);
        CHECK(f.count==3 && f.events[1].pin==77 && f.events[1].value==0);
        CHECK(f.events[2].pin==77 && f.events[2].value==set);
        guards(&f); ++scenarios;
    }
}
static void routing(void)
{
    struct fixture f; init(&f,1);
    CHECK(vn135_led_shutdown_step_135(NULL,NULL,NULL,0x12345,2)==VN135_LED_UNHANDLED);
    CHECK(vn135_led_shutdown_step_135(NULL,NULL,NULL,0xf98b8,2)==VN135_LED_INVALID_BINDING);
    CHECK(vn135_led_shutdown_step_135(&f.state,NULL,&f,0xf9840,2)==VN135_LED_INVALID_BINDING);
    struct vn135_led_ops_135 missing={0};
    CHECK(vn135_led_shutdown_step_135(&f.state,&missing,&f,0xf98b8,2)==VN135_LED_INVALID_BINDING);
    CHECK(f.count==0);
    f.state.ready=0;
    CHECK(vn135_led_shutdown_step_135(&f.state,NULL,&f,0xf9840,2)==VN135_LED_HANDLED);
    CHECK(vn135_led_shutdown_step_135(&f.state,NULL,&f,0xf98b8,2)==VN135_LED_HANDLED);
    f.state.ready=255;
    CHECK(vn135_led_shutdown_step_135(&f.state,NULL,&f,0xf9840,2)==VN135_LED_HANDLED);
    CHECK(vn135_led_shutdown_step_135(&f.state,NULL,&f,0xf98b8,UINT32_MAX)==VN135_LED_HANDLED);
    CHECK(vn135_led_shutdown_step_135(&f.state,&ops,&f,0xf98b8,2)==VN135_LED_HANDLED);
    CHECK(f.count==2); guards(&f); ++scenarios;
}

struct gpio_fixture { unsigned events[32], used, opens; int fail_open; uint32_t pin; };
static void record(struct gpio_fixture *g,unsigned op)
{ CHECK(g->used<32);g->events[g->used++]=op; }
static int32_t glock(void *p) { record(p,1);return -16; }
static int32_t gunlock(void *p) { record(p,5);return -17; }
static uintptr_t gopen(void *p,const char *path,const char *mode)
{
    struct gpio_fixture *g=p; char expected[256];
    int32_t pin=g->pin<=INT32_MAX?(int32_t)g->pin:-1-(int32_t)(UINT32_MAX-g->pin);
    (void)snprintf(expected,sizeof(expected),"/sys/class/gpio/gpio%" PRId32 "/value",pin);
    CHECK(!strcmp(expected,path) && !strcmp(mode,"w"));
    record(g,2);++g->opens;return g->fail_open?0:123;
}
static int32_t gnumber(void *p,uintptr_t h,const char *fmt,uint32_t value)
{ CHECK(h==123 && !strcmp(fmt,"%d") && value==0);record(p,3);return -1; }
static int32_t gclose(void *p,uintptr_t h) { CHECK(h==123);record(p,4);return -1; }
static void gperror(void *p,const char *text) { CHECK(!strcmp(text,"fopen"));record(p,7); }
static void glog(void *p,enum vn135_gpio_power_source s,uint32_t line,uint32_t arg)
{ struct gpio_fixture *g=p;CHECK(s==VN135_GP_GPIO && line==72 && arg==g->pin);record(g,6); }
static void gpio_composition(void)
{
    const struct vn135_gpio_ops go={.lock=glock,.unlock=gunlock,.fopen=gopen,
        .fprintf_number=gnumber,.fclose=gclose,.perror=gperror,.log=glog};
    for (unsigned fail=0;fail<2;++fail) {
        struct gpio_fixture g={.fail_open=(int)fail,.pin=UINT32_MAX};
        struct vn135_gpio_io gio={&go,&g};
        struct vn135_led_state_135 state={1,{UINT32_MAX,UINT32_MAX}};
        const struct vn135_led_ops_135 lo={vn135_led_gpio_set_135};
        vn135_led_clear_135(&state,&lo,&gio,2);
        static const unsigned good[]={1,2,3,4,5,1,2,3,4,5};
        static const unsigned bad[]={1,2,5,6,7,1,2,5,6,7};
        CHECK(g.opens==2 && g.used==10);
        CHECK(!memcmp(g.events,fail?bad:good,sizeof(good)));
        CHECK(state.ready==1 && state.pins[0]==UINT32_MAX);++scenarios;
    }
}

/* Existing parents are compiled and called, with all OTHER effects explicitly
 * scripted. No thread flags or positive chain counts are enabled in this set. */
struct parent_fixture { struct fixture led; unsigned led_calls; };
static int32_t zero(void *p) { (void)p;return 0; }
static int32_t fail(void *p) { (void)p;return -1; }
static int32_t cleanup(void *p,uint32_t out[2],uint32_t v)
{ (void)p;CHECK(v==123);out[0]=out[1]=0;return -1; }
static int32_t marker(void *p,const char *path)
{ (void)p;CHECK(!strcmp(path,"/tmp/stopped"));return -1; }
static uint32_t step(void *p,uint32_t ep,uint32_t arg)
{
    struct parent_fixture *f=p;
    if (ep==0xf98b8 || ep==0xf9840) {
        CHECK(vn135_led_shutdown_step_135(&f->led.state,&ops,&f->led,ep,arg)==VN135_LED_HANDLED);
        ++f->led_calls; return UINT32_MAX;
    }
    switch(ep) {
    case 0xfdeb4:return 1;
    case 0xfdfbc:return 2;
    case 0x19c:return 123;
    case 0x8291c:case 0xa6080:case 0x663cc:case 0x287a4:
    case 0x1082b4:case 0x2f6ec:return 0;
    default:CHECK(0);return UINT32_MAX;
    }
}
static void parent_composition(void)
{
    const struct vn135_shutdown_ops so={.trylock=zero,.unlock=fail,.step=step,.cleanup=cleanup,.mark_stopped=marker};
    const struct vn135_backend_power_ops po={.psu_off=fail,.chain_count=zero};
    for (unsigned before=0;before<2;++before)
        for (unsigned ready=0;ready<256;++ready) {
            struct parent_fixture p={0};init(&p.led,(uint8_t)ready);p.led.error=-1;
            struct vn135_shutdown_state s={.state=2};struct vn135_shutdown_scratch scratch={0};
            if (before) vn135_backend_before_exit_135(&s,&so,&po,&p,&scratch);
            else vn135_backend_shutdown_135(&s,&so,&po,&p,&scratch);
            CHECK(s.state==(before?4u:6u));CHECK(p.led_calls==(before?1u:2u));
            size_t n=before?(ready?2u:0u):(ready?1u:0u)+(ready==1?1u:0u);
            CHECK(p.led.count==n);
            if (n) CHECK(p.led.events[0].pin==(before?17u:29u) && !p.led.events[0].value);
            if (n==2) CHECK(p.led.events[1].pin==(before?29u:17u) && p.led.events[1].value==(before?0u:1u));
            guards(&p.led);++scenarios;
        }
}
int main(void)
{
    direct();routing();gpio_composition();parent_composition();
    printf("LED_OUTPUT135_NATIVE_PASS scenarios=%u checks=%u\n",scenarios,checks);
    return 0;
}
