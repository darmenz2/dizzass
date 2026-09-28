/* Bounded allocation lifetime/ordering and native parent composition.
 * No OS threads are started; free() really runs on guarded host allocations. */
#include "mining_stop_fixture_135.inc"
#include "integration/frequency_fall_135.h"
#include <limits.h>
#define FALL_CAP 6
struct fall_allocation {
    uint64_t before;
    union { struct vn135_frequency_fall_argument args[FALL_CAP]; uint32_t handles[FALL_CAP]; } body;
    uint64_t after;
};
struct fall_event { unsigned kind,index;uint32_t value; };
struct fall_fixture {
    struct mining_fixture old;
    uint64_t left;
    struct vn135_frequency_fall_state fall;
    struct vn135_frequency_fall_config cfg;
    struct vn135_general_chain chains[FALL_CAP];
    uint64_t right;
    struct fall_allocation *buffers[2];
    uint32_t lengths[2];
    int32_t counts[3],create_rc,join_rc,child_result;
    int fail_alloc,fail_create,mutate_join;
    unsigned count_calls,allocated,freed,created,joined,logged;
    struct fall_event events[64];unsigned used;
};
static void fevent(struct fall_fixture *f,unsigned k,unsigned i,uint32_t v)
{ CHECK(f->used<64);f->events[f->used++]=(struct fall_event){k,i,v}; }
static void finit(struct fall_fixture *f,int32_t n,int32_t floor,int32_t target,int32_t frequency)
{
    unsigned i;memset(f,0,sizeof(*f));minit(&f->old,1,99);
    f->left=f->right=UINT64_C(0xf00dface01234567);
    f->cfg=(struct vn135_frequency_fall_config){floor,target};
    f->fall=(struct vn135_frequency_fall_state){&f->old.previous.backend.general,&f->cfg};
    f->fall.general->chains=f->chains;
    for(i=0;i<FALL_CAP;++i){f->chains[i].thermal.present=1;f->chains[i].thermal.state=1;f->chains[i].thermal.cleared_words[0]=(uint32_t)frequency;}
    f->counts[0]=f->counts[1]=f->counts[2]=n;f->fail_alloc=f->fail_create=-1;f->create_rc=11;f->join_rc=-3;
}
static void fguard_buffer(struct fall_fixture *f,unsigned kind)
{
    struct fall_allocation *b=f->buffers[kind];size_t n,i,limit;
    CHECK(b);CHECK(b->before==UINT64_C(0xd1e2f3a456789abc)&&b->after==b->before);
    n=kind?sizeof(uint32_t):sizeof(struct vn135_frequency_fall_argument);
    limit=(size_t)f->lengths[kind]*n;
    for(i=limit;i<sizeof(b->body);++i)CHECK(((unsigned char *)&b->body)[i]==0xa5);
}
static int32_t fcount(void *p)
{ struct fall_fixture *f=p;unsigned n=f->count_calls++;CHECK(n<3);fevent(f,1,n,(uint32_t)f->counts[n]);return f->counts[n]; }
static void *fallocate(void *p,enum vn135_frequency_fall_allocation kind,uint32_t n,uint32_t stride)
{
    struct fall_fixture *f=p;struct fall_allocation *b;size_t size;
    CHECK(kind==VN135_FALL_ARGUMENTS||kind==VN135_FALL_HANDLES);CHECK(stride==(kind?4u:8u));
    CHECK(!f->buffers[kind]);++f->allocated;fevent(f,2,(unsigned)kind,n);
    if(n>UINT32_MAX/stride||f->fail_alloc==(int)kind)return NULL;
    CHECK(n<=FALL_CAP);b=calloc(1,sizeof(*b));CHECK(b);b->before=b->after=UINT64_C(0xd1e2f3a456789abc);
    memset(&b->body,0xa5,sizeof(b->body));size=kind?sizeof(uint32_t):sizeof(struct vn135_frequency_fall_argument);
    memset(&b->body,0,(size_t)n*size);f->buffers[kind]=b;f->lengths[kind]=n;fguard_buffer(f,(unsigned)kind);
    return &b->body;
}
static void frelease(void *p,enum vn135_frequency_fall_allocation kind,void *address)
{
    struct fall_fixture *f=p;CHECK(address==&f->buffers[kind]->body);fguard_buffer(f,(unsigned)kind);
    fevent(f,5,(unsigned)kind,0);++f->freed;
    memset(f->buffers[kind],0xfe,sizeof(*f->buffers[kind]));free(f->buffers[kind]);f->buffers[kind]=NULL;
}
static int32_t fcreate(void *p,uint32_t *handle,uint32_t entry,struct vn135_frequency_fall_argument *a)
{
    struct fall_fixture *f=p;unsigned i=f->created++;
    CHECK(entry==0x65fccu);CHECK(i<f->lengths[0]);fguard_buffer(f,0);fguard_buffer(f,1);
    CHECK(a==&f->buffers[0]->body.args[i]);CHECK(handle==&f->buffers[1]->body.handles[i]);
    CHECK(a->backend==&f->fall&&a->chain==&f->fall.general->chains[i]);CHECK(*handle==0);
    fevent(f,3,i,entry);*handle=0x600u+i;
    return f->fail_create==(int)i?f->create_rc:0;
}
static int32_t fjoin(void *p,uint32_t handle,uint32_t *out)
{
    struct fall_fixture *f=p;unsigned i=f->joined++;
    CHECK(!out);CHECK(i<f->lengths[1]);fguard_buffer(f,0);fguard_buffer(f,1);
    CHECK(handle==(f->mutate_join&&i==1?0xfaceu:0x600u+i));fevent(f,4,i,handle);
    if(f->mutate_join&&i==0&&f->lengths[1]>1)f->buffers[1]->body.handles[1]=0xfaceu;
    return f->join_rc;
}
static void flog(void *p,uint32_t line,uint32_t level,int32_t value)
{
    struct fall_fixture *f=p;++f->logged;
    CHECK(line==4481||line==4487||line==4496||line==4506);
    CHECK(level==(line==4496?3u:1u));
    if(line==4496)CHECK(value==f->cfg.target_18);
    if(line==4506)CHECK(value==f->fail_create+1);
    fevent(f,6,line,(uint32_t)value);
}
static const struct vn135_frequency_fall_ops fops={fcount,fallocate,frelease,fcreate,fjoin,flog};
static void fguards(struct fall_fixture *f)
{
    CHECK(f->left==UINT64_C(0xf00dface01234567)&&f->right==f->left);
    CHECK(!f->buffers[0]&&!f->buffers[1]);mguards(&f->old);
}
static void fdirect(int32_t n,int32_t floor,int32_t target,int32_t frequency,int fail_alloc,int fail_create,int present)
{
    struct fall_fixture f;int32_t minimum,level,expected,result;unsigned i,expect_created=0,expect_joined=0;
    finit(&f,n,floor,target,frequency);f.fail_alloc=fail_alloc;f.fail_create=fail_create;f.mutate_join=1;
    for(i=0;i<FALL_CAP;++i)f.chains[i].thermal.present=(uint8_t)present;
    minimum=n>0&&present?frequency:0;level=minimum>floor?minimum:floor;expected=0;
    if(n<0||fail_alloc>=0)expected=-1;
    else if(level>target){
        if(fail_create>=0&&fail_create<n){expected=f.create_rc;expect_created=(unsigned)fail_create+1u;}
        else if(n>0)expect_created=expect_joined=(unsigned)n;
        else expected=-1;
    }
    result=vn135_backend_fall_frequency_135(&f.fall,&fops,&f);++scenarios;
    CHECK(result==expected);CHECK(f.created==expect_created&&f.joined==expect_joined);
    CHECK(f.count_calls==(n<0||fail_alloc>=0?1u:((level>target&&!(fail_create>=0&&fail_create<n))?3u:2u)));
    CHECK(f.freed==(n<0||fail_alloc==0?0u:(fail_alloc==1?1u:2u)));
    if(f.freed==2){CHECK(f.events[f.used-2].kind==5&&f.events[f.used-2].index==0);CHECK(f.events[f.used-1].kind==5&&f.events[f.used-1].index==1);}
    CHECK(f.fall.general->active==255);CHECK(f.old.mining.handle_104c==701);fguards(&f);
}
static uint32_t fmining_step(void *p,uint32_t ep,uint32_t arg)
{
    struct fall_fixture *f=p;uint32_t rc=mstep(&f->old,ep,arg);
    if(ep==0x65b3c)f->child_result=vn135_backend_fall_frequency_135(&f->fall,&fops,f);
    return rc;
}
static uint32_t fparent_step(void *p,uint32_t ep,uint32_t arg)
{
    struct fall_fixture *f=p;uint32_t rc=step_cb(p,ep,arg);struct vn135_shutdown_ops mo=mining_ops;
    if(ep==0xa6080)vn135_voltage_controller_stop_135(&f->old.previous.voltage,&ops,p);
    if(ep==0x287a4)vn135_rescue_service_stop_135(&f->old.previous.rescue,&ops,p);
    if(ep==0x663cc){mo.step=fmining_step;vn135_backend_stop_mining_135(&f->old.mining,&mo,p);}
    return rc;
}
static void fteardown(struct fall_fixture *f,int common)
{
    struct fixture *b=&f->old.previous.backend;struct vn135_shutdown_ops bound=ops;bound.step=fparent_step;
    if(common)vn135_backend_shutdown_135(&b->s,&bound,&power,f,&b->scratch);
    else vn135_backend_before_exit_135(&b->s,&bound,&power,f,&b->scratch);
}
static void fpolicy_before(void *p)
{struct fall_fixture *f=p;struct fixture *b=&f->old.previous.backend;++b->before_calls;fteardown(f,0);b->general.state=b->s.state;}
static void fpolicy_common(void *p)
{struct fall_fixture *f=p;struct fixture *b=&f->old.previous.backend;++b->common_calls;fteardown(f,1);b->general.state=b->s.state;}
static void fcomposition(void)
{
    int common,fail,retry,off;unsigned i;const struct vn135_monitor_handler_ops hops={.call=handler_call};
    for(common=0;common<2;++common)for(fail=-1;fail<3;++fail){
        struct fall_fixture f;struct fixture *b=&f.old.previous.backend;
        finit(&f,3,100,400,700);f.fail_create=fail;fteardown(&f,common);++scenarios;
        CHECK(f.child_result==(fail<0?0:11));CHECK(!b->general.active&&!b->general.tuning&&!b->handlers.warmup_done_22c);
        CHECK(f.old.used==7);CHECK(b->s.state==(common?6u:4u));CHECK(find(b,0x663cc)<find(b,0x65b3c));
        CHECK(f.joined==(fail<0?3u:0u));fguards(&f);guards(b);
    }
    for(retry=0;retry<2;++retry)for(fail=-1;fail<3;++fail)for(off=-1;off<=1;++off){
        struct fall_fixture f;struct fixture *b=&f.old.previous.backend;struct vn135_stop_policy_ops po=policy_ops;int flow;
        finit(&f,3,900,400,700);f.fail_create=fail;b->off_rc=off;b->policy.retry_limit_88=retry?2:0;
        for(i=0;i<3;++i)f.chains[i].thermal.state=3;
        po.before_process_exit=fpolicy_before;po.shutdown=fpolicy_common;
        flow=vn135_test_stop_chain_composed_135(&b->policy,&po,&hops,&f);++scenarios;
        CHECK(flow==(retry?VN135_STOP_PROCESS_EXIT:VN135_STOP_RETURNED));
        CHECK(f.child_result==(fail<0?0:11));CHECK(b->handler_counts==(retry?1u:2u));
        CHECK(!b->general.active&&!b->general.tuning);CHECK(b->exit_calls==(unsigned)retry);
        fguards(&f);guards(b);
    }
}
int main(void)
{
    static const int32_t values[]={INT32_MIN,-1,0,100,400,700,INT32_MAX};
    unsigned i,j,k;int n,fail;
    for(i=0;i<7;++i)for(j=0;j<7;++j)for(k=0;k<7;++k)
        fdirect(3,values[i],values[j],values[k],-1,-1,1);
    for(n=0;n<=FALL_CAP;++n)for(fail=-1;fail<2;++fail){fdirect(n,900,400,700,fail,-1,1);fdirect(n,900,400,700,fail,-1,0);}
    for(n=1;n<=FALL_CAP;++n)for(fail=0;fail<n;++fail)fdirect(n,100,400,700,-1,fail,1);
    fdirect(-1,100,400,700,-1,-1,1);fcomposition();
    printf("FREQUENCY_FALL135_NATIVE_PASS scenarios=%lu assertions=%lu real_threads=no hardware=no allocator=guarded_host\n",scenarios,assertions);
    return 0;
}
