#include "integration/frequency_worker_135.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases,checks;
#define CHECK(x) do { ++checks; assert(x); } while(0)
struct fixture {
    struct vn135_general_model model;
    struct vn135_general_chain chains[3];
    struct vn135_general_monitor general;
    struct vn135_monitor_handlers handlers;
    struct vn135_frequency_fall_config target;
    struct vn135_frequency_fall_state fall;
    struct vn135_frequency_worker_control control;
    struct vn135_frequency_worker_view view;
    struct vn135_frequency_worker_ops ops;
    struct vn135_monitor_handler_ops decisions;
    unsigned sets,delays,exits,stops,events,creates,powers,logs;
    int fail_at,create_error;
    int32_t frequencies[64];
    int poison,mutate_control;
    struct vn135_frequency_fall_argument *current_argument;
    struct vn135_frequency_fall_argument *allocated;
    uint32_t *handles;
    struct vn135_frequency_fall_argument *pending[3];
    unsigned parent_creates,joins,frees;
    int parent_fail;
};
static int32_t scalar(void *opaque,uint32_t ep,uint32_t a,uint32_t b)
{
    struct fixture *s=opaque;CHECK(b==0);
    switch(ep){
    case 0x5a6b2c:
        CHECK(a==1);
        if(s->poison){s->current_argument->backend=NULL;s->current_argument->chain=NULL;}
        return -1;
    case 0x593af8: CHECK(a==15);return -1;
    case 0x10ef3c: CHECK(a==100);++s->delays;return -1;
    case 0x49c98: CHECK(a==2010);++s->events;return -1;
    case 0x6b778: CHECK(a==0);++s->powers;return -1;
    case 0x5a52d0: CHECK(a==0);++s->exits;return -1;
    default:CHECK(0);return 0;
    }
}
static int32_t set(void *opaque,struct vn135_general_chain *c,uint32_t a,uint32_t b,double frequency)
{
    struct fixture *s=opaque;unsigned at=s->sets++;
    CHECK(c>=s->chains && c<s->chains+3);CHECK(at<64);
    CHECK(a==s->control.word_20 && b==s->control.word_10);
    s->frequencies[at]=(int32_t)frequency;
    if(s->mutate_control){++s->control.word_10;++s->control.word_20;s->target.target_18=1800;}
    return (int)at==s->fail_at ? -1 : 0;
}
static int32_t stop(void *opaque,struct vn135_route_chain *c,const char *reason)
{
    struct fixture *s=opaque;CHECK(strcmp(reason,"Failed to set minimum frequency")==0);
    ++s->stops;c->state=3;return -1;
}
static int32_t create(void *opaque,uint32_t *out,uint32_t entry,struct vn135_frequency_fall_state *backend)
{
    struct fixture *s=opaque;CHECK(entry==0x72ba4 && backend==&s->fall);*out=0x456;
    ++s->creates;return s->create_error;
}
static int32_t decision(void *opaque,uint32_t ep,uint32_t a,uint32_t b)
{ (void)opaque;CHECK(ep==0xfe668 && a==0 && b==0);return 3; }
static void log_worker(void *opaque,uint32_t line,uint32_t index,int32_t frequency)
{ struct fixture *s=opaque;(void)frequency;CHECK(line==4444 || line==6483);if(line==6483)CHECK(index==0);++s->logs; }
static void init(struct fixture *s,int32_t frequency,int32_t target)
{
    memset(s,0,sizeof *s);s->general.model=&s->model;s->general.chains=s->chains;
    s->handlers.general=&s->general;s->handlers.minimum_chains_f8=2;
    s->target.target_18=target;s->fall.general=&s->general;s->fall.config=&s->target;
    s->control.word_10=17;s->control.word_20=29;
    s->view.control=&s->control;s->view.handlers=&s->handlers;s->decisions.call=decision;
    s->ops=(struct vn135_frequency_worker_ops){scalar,set,stop,create,log_worker,&s->decisions};
    s->fail_at=-1;s->parent_fail=-1;
    for(unsigned i=0;i<3;++i){s->chains[i].thermal.state=2;s->chains[i].thermal.present=1;
        s->chains[i].thermal.index=i;s->chains[i].thermal.cleared_words[0]=(uint32_t)frequency;}
}
static void run(struct fixture *s,struct vn135_frequency_fall_argument *a)
{
    s->current_argument=a;
    CHECK(vn135_frequency_fall_worker_135(a,&s->view,&s->ops,s)==VN135_FREQUENCY_THREAD_EXIT);
}
static int32_t parent_count(void *p){(void)p;return 3;}
static void *allocate(void *p,enum vn135_frequency_fall_allocation k,uint32_t n,uint32_t stride)
{
    struct fixture *s=p;CHECK(n==3);CHECK(stride==(k==VN135_FALL_ARGUMENTS?8u:4u));
    if(k==VN135_FALL_ARGUMENTS){s->allocated=calloc(n,sizeof *s->allocated);return s->allocated;}
    s->handles=calloc(n,sizeof *s->handles);return s->handles;
}
static void release(void *p,enum vn135_frequency_fall_allocation k,void *array)
{ struct fixture *s=p;(void)k;CHECK(array!=NULL);++s->frees;free(array); }
static int32_t parent_create(void *p,uint32_t *out,uint32_t entry,struct vn135_frequency_fall_argument *a)
{
    struct fixture *s=p;unsigned i=s->parent_creates++;CHECK(i<3 && entry==0x65fcc);
    if((int)i==s->parent_fail)return 11;
    *out=i+10;s->pending[i]=a;return 0;
}
static int32_t join(void *p,uint32_t h,uint32_t *out)
{
    struct fixture *s=p;CHECK(h>=10 && h<13 && out==NULL);++s->joins;
    run(s,s->pending[h-10]);s->pending[h-10]=NULL;return -1;
}
int main(void)
{
    struct fixture s;
    for(int frequency=-100;frequency<=1200;frequency+=13){
        for(int target=0;target<=500;target+=50){
            init(&s,frequency,target);struct vn135_frequency_fall_argument a={&s.fall,&s.chains[0]};run(&s,&a);
            int f=(frequency/50)*50;unsigned n=0;
            if(f>=target){for(;;){CHECK(s.frequencies[n++]==f);if(f==target)break;f-=100;if(f<target)f=target;}}
            CHECK(s.sets==n && s.delays==n && s.exits==1 && s.stops==0);++cases;
        }
    }
    for(unsigned present=0;present<256;++present){
        init(&s,400,400);s.chains[0].thermal.present=(uint8_t)present;
        struct vn135_frequency_fall_argument a={&s.fall,&s.chains[0]};run(&s,&a);
        CHECK(s.sets==(present?1u:0u) && s.exits==1);++cases;
    }
    for(int partial=0;partial<2;++partial)for(int failed=0;failed<3;++failed){
        init(&s,635,400);s.handlers.partial_chains_105=(uint8_t)partial;s.fail_at=failed;s.create_error=11;
        struct vn135_frequency_fall_argument a={&s.fall,&s.chains[0]};run(&s,&a);
        CHECK(s.sets==(unsigned)failed+1 && s.delays==(unsigned)failed && s.stops==1 && s.exits==1);
        CHECK(s.events==(partial?0u:1u) && s.powers==s.events);++cases;
    }
    init(&s,635,400);s.poison=1;s.mutate_control=1;
    struct vn135_frequency_fall_argument a={&s.fall,&s.chains[0]};run(&s,&a);
    CHECK(s.sets==3 && s.frequencies[0]==600 && s.frequencies[1]==500 && s.frequencies[2]==400);++cases;
    for(int failed=-1;failed<3;++failed){
        init(&s,635,400);s.parent_fail=failed;
        struct vn135_frequency_fall_ops o={parent_count,allocate,release,parent_create,join,NULL};
        int32_t rc=vn135_backend_fall_frequency_135(&s.fall,&o,&s);
        CHECK(s.frees==2);
        if(failed<0){CHECK(rc==0 && s.joins==3 && s.exits==3 && s.sets==9);}
        else {CHECK(rc==11 && s.joins==0 && s.exits==0);}
        /* Deliberately do not dereference pending arguments after free. The
         * reference-instruction lifetime test reports the unsafe schedule. */
        ++cases;
    }
    printf("FREQUENCY_WORKER135_NATIVE_PASS cases=%u assertions=%u real_threads=no\n",cases,checks);
    return 0;
}
