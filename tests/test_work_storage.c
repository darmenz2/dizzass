/* Native allocation/failure/lifetime tests. All work/strings are fixtures.
 * No vendor work ABI cast, hardware, network or production job ownership. */
#include "xminer/recovery/work_storage.h"
#include "xminer/recovery/nonce_verify.h"
#include "xminer/recovery/difficulty.h"
#include "fixtures/genesis_work.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned checks,scenarios;
#define CHECK(x) do { ++checks; if(!(x)) { fprintf(stderr,"FAIL %s:%d: %s\n",__FILE__,__LINE__,#x);return 1; } } while(0)
typedef struct {void *p;size_t n;int live;} allocation;
typedef struct {
    allocation blocks[32];size_t count,calls,live,free_count;
    void *released[32];uint32_t fail_mask;int error;
} arena;
static void *tracked_allocate(void *context,size_t n) {
    arena *a=context;size_t call=a->calls++;
    if(call<32u && (a->fail_mask&(UINT32_C(1)<<call)))return NULL;
    if(a->count>=32u || !n){a->error=1;return NULL;}
    void *p=malloc(n);if(!p){a->error=2;return NULL;}
    memset(p,0xcd,n);a->blocks[a->count++]=(allocation){p,n,1};++a->live;return p;
}
static void tracked_release(void *context,void *p) {
    arena *a=context;
    for(size_t i=0;i<a->count;++i)if(a->blocks[i].live&&a->blocks[i].p==p){
        if(a->free_count>=32u){a->error=3;return;}
        a->released[a->free_count++]=p;a->blocks[i].live=0;--a->live;free(p);return;
    }
    a->error=4;
}
static vn135_work_memory memory(arena *a){vn135_work_memory m={a,tracked_allocate,tracked_release};return m;}
static uint32_t get32(const uint8_t *p){return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
static void put32(uint8_t *p,uint32_t v){for(size_t i=0;i<4u;++i)p[i]=(uint8_t)(v>>(8u*i));}
static const size_t slots[4]={0x18c,0x19c,0x1a8,0x1b0};
static void image_init(vn135_work_storage *w,unsigned seed){
    memset(w,0,sizeof(*w));for(size_t i=0;i<632u;++i)w->image[i]=(uint8_t)(i*37u+seed);
    for(size_t i=0;i<4u;++i)memset(w->image+slots[i],0,4);
}
static int image_zero(const vn135_work_storage *w){
    for(size_t i=0;i<632u;++i)if(w->image[i])return 0;
    for(size_t i=0;i<4u;++i)if(w->text[i]||w->text_size[i])return 0;
    return 1;
}
static int metadata_cases(void){
    static const unsigned order[3]={0,2,1};
    for(unsigned n=0;n<21u;++n)for(unsigned fail=0;fail<8u;++fail){
        ++scenarios;arena a={0};a.fail_mask=fail;vn135_work_memory m=memory(&a);
        vn135_work_storage w;image_init(&w,n);uint8_t before[632];memcpy(before,w.image,632);
        uint8_t strings[3][160];size_t lengths[3]={n*3u,n*7u,n%17u};
        for(size_t s=0;s<3u;++s)for(size_t j=0;j<160u;++j)strings[s][j]=(uint8_t)(1+(j+13*s)%255u);
        vn135_work_metadata_view v={UINT64_C(0x7ff80000000000ab),{strings[0],lengths[0]},
            {strings[1],lengths[1]},{strings[2],lengths[2]}};
        uint32_t mask=0xeeeeeeeeu,expected=0;
        int rc=vn135_frontend_work_metadata_copy_legacy(&w,&v,&m,&mask);
        CHECK(a.calls==3u);CHECK(rc==(fail?VN135_STORAGE_PARTIAL:0));CHECK(!a.error);
        for(size_t i=0;i<3u;++i){unsigned s=order[i];if(fail&(1u<<i)){expected|=1u<<s;CHECK(!w.text[s]);CHECK(!w.text_size[s]);}
            else {CHECK(w.text[s]);CHECK(w.text_size[s]==lengths[i]);CHECK(!memcmp(w.text[s],strings[i],lengths[i]));CHECK(w.text[s][lengths[i]]=='\0');}}
        CHECK(mask==expected);CHECK(w.text[3]==NULL);
        put32(before+0x1a0,(uint32_t)v.difficulty_bits);put32(before+0x1a4,(uint32_t)(v.difficulty_bits>>32));
        CHECK(!memcmp(before,w.image,632));CHECK(vn135_frontend_work_storage_clear(&w,&m)==0);
        CHECK(image_zero(&w));CHECK(a.live==0u && !a.error);
        size_t freed=a.free_count;CHECK(vn135_frontend_work_storage_clear(&w,&m)==0);CHECK(a.free_count==freed);
    }
    return 0;
}
static int clone_cases(void){
    static const unsigned order[4]={0,2,1,3};
    char s0[]="job/alpha",s1[]="",s2[]="extranonce:abcdef",s3[]="ntime:old";
    char *texts[4]={s0,s1,s2,s3};
    for(unsigned present=0;present<16u;++present)for(unsigned fail=0;fail<32u;++fail){
        ++scenarios;vn135_work_storage src;image_init(&src,present);
        for(size_t i=0;i<4u;++i)if(present&(1u<<i)){src.text[i]=texts[i];src.text_size[i]=strlen(texts[i]);}
        vn135_work_storage before=src;arena a={0};a.fail_mask=fail;vn135_work_memory m=memory(&a);
        vn135_work_storage *copy=NULL;uint32_t failed=0xabcdef12u;
        int rc=vn135_frontend_work_clone_unrolled(&src,0xfeedbabeu,&m,&copy,&failed);
        CHECK(!memcmp(&src,&before,sizeof(src)));CHECK(!a.error);
        if(fail&1u){CHECK(rc==VN135_STORAGE_NOMEM);CHECK(!copy);CHECK(failed==0xabcdef12u);CHECK(a.live==0u);}
        else{
            unsigned attempt=1,mask=0;CHECK(copy);uint8_t image[632];memcpy(image,src.image,632);put32(image+0x1bc,0xfeedbabeu);
            CHECK(!memcmp(copy->image,image,632));
            for(size_t k=0;k<4u;++k){unsigned i=order[k];
                if(!(present&(1u<<i))){CHECK(!copy->text[i]&&!copy->text_size[i]);continue;}
                if(fail&(1u<<attempt)){mask|=1u<<i;CHECK(!copy->text[i]&&!copy->text_size[i]);}
                else {CHECK(copy->text[i]!=src.text[i]);CHECK(!strcmp(copy->text[i],src.text[i]));CHECK(copy->text_size[i]==src.text_size[i]);}
                ++attempt;
            }
            CHECK(a.calls==attempt);CHECK(failed==mask);CHECK(rc==(mask?VN135_STORAGE_PARTIAL:0));
            CHECK(vn135_frontend_work_storage_delete(&copy,&m)==0);CHECK(copy==NULL);CHECK(a.live==0u&&!a.error);
            size_t count=a.free_count;CHECK(vn135_frontend_work_storage_delete(&copy,&m)==0);CHECK(a.free_count==count);
        }
        /* New rollback policy is tested independently from legacy behavior. */
        ++scenarios;arena b={0};b.fail_mask=fail;vn135_work_memory mb=memory(&b);vn135_work_storage *atomic=NULL;
        rc=vn135_work_clone_atomic(&src,23,&mb,&atomic);
        CHECK(!memcmp(&src,&before,sizeof(src)));CHECK(!b.error);
        if(rc){CHECK(rc==VN135_STORAGE_NOMEM);CHECK(atomic==NULL);CHECK(b.live==0u);}
        else{CHECK(atomic);CHECK(get32(atomic->image+0x1bc)==23u);CHECK(vn135_frontend_work_storage_delete(&atomic,&mb)==0);CHECK(!b.live&&!b.error);}
    }
    return 0;
}
static int guards_and_lifetime(void){
    arena a={0};vn135_work_memory m=memory(&a),bad={0};vn135_work_storage w;image_init(&w,7);
    uint8_t empty[]={0},embed[]={1,0,2},noterm[]={'x','y'};
    vn135_work_metadata_view good={UINT64_C(0x3ff0000000000000),{empty,0},{empty,0},{empty,0}};
    vn135_work_metadata_view v=good;vn135_work_storage saved=w;uint32_t failed=0xdeadbeef;
    for(unsigned i=0;i<6u;++i){++scenarios;v=good;
        if(i==0u)v.text_3d0=(vn135_text_view){NULL,0};
        if(i==1u)v.text_3ec=(vn135_text_view){embed,3};
        if(i==2u)v.text_396=(vn135_text_view){empty,SIZE_MAX};
        if(i==3u)v.text_396=(vn135_text_view){NULL,2};
        if(i==4u)v.text_3d0=(vn135_text_view){empty,UINT32_MAX};
        if(i==5u)put32(w.image+0x18c,1);
        vn135_work_storage snapshot=w;
        CHECK(vn135_frontend_work_metadata_copy_legacy(&w,&v,&m,&failed)==VN135_STORAGE_INVALID);
        CHECK(!memcmp(&w,&snapshot,sizeof(w)));CHECK(!a.calls);CHECK(failed==0xdeadbeef);w=saved;
    }
    ++scenarios;
    CHECK(vn135_frontend_work_metadata_copy_legacy(NULL,&good,&m,&failed)==-2);
    CHECK(vn135_frontend_work_metadata_copy_legacy(&w,NULL,&m,&failed)==-2);
    CHECK(vn135_frontend_work_metadata_copy_legacy(&w,&good,&bad,&failed)==-2);
    CHECK(vn135_frontend_work_metadata_copy_legacy(&w,&good,&m,NULL)==-2);
    vn135_work_storage *out=NULL;
    CHECK(vn135_frontend_work_clone_unrolled(NULL,0,&m,&out,&failed)==-2);
    CHECK(vn135_frontend_work_clone_unrolled(&w,0,&m,NULL,&failed)==-2);
    CHECK(vn135_frontend_work_clone_unrolled(&w,0,&m,&out,NULL)==-2);
    out=&w;CHECK(vn135_work_clone_atomic(&w,0,&m,&out)==-2);CHECK(out==&w);out=NULL;
    w.text[0]=(char *)noterm;w.text_size[0]=1;
    CHECK(vn135_frontend_work_clone_unrolled(&w,0,&m,&out,&failed)==-2);CHECK(!out&&!a.calls);
    w=saved;w.text_size[1]=1;CHECK(vn135_frontend_work_clone_unrolled(&w,0,&m,&out,&failed)==-2);w=saved;
    CHECK(vn135_frontend_work_storage_clear(NULL,&m)==-2);
    CHECK(vn135_frontend_work_storage_delete(NULL,&m)==-2);
    CHECK(vn135_frontend_work_storage_clear(&w,&bad)==-2);CHECK(!memcmp(&w,&saved,sizeof(w)));
    uint32_t counter=UINT32_MAX;
    CHECK(vn135_frontend_work_builder_fields(NULL,1,2)==-2);
    CHECK(vn135_frontend_work_wrapper_fields(NULL,1,2,3,&counter,4,5)==-2);
    CHECK(vn135_frontend_work_wrapper_fields(w.image,1,2,3,NULL,4,5)==-2);
    CHECK(counter==UINT32_MAX);CHECK(!memcmp(&w,&saved,sizeof(w)));
    CHECK(vn135_frontend_work_wrapper_fields(w.image,1,2,3,&counter,4,5)==0);
    CHECK(counter==0);CHECK(w.image[0x180]==1u);CHECK(get32(w.image+0x254)==5);
    CHECK(vn135_frontend_work_storage_clear(&w,&m)==0);
    /* Metadata -> independent clone -> clear original -> preserved header hash. */
    ++scenarios;memcpy(w.image,fixture_words,112);
    const uint8_t job[]="synthetic-genesis",en[]="offline-only",tm[]="00000000";
    good.text_3d0=(vn135_text_view){job,sizeof(job)-1};good.text_3ec=(vn135_text_view){en,sizeof(en)-1};good.text_396=(vn135_text_view){tm,sizeof(tm)-1};
    CHECK(vn135_frontend_work_metadata_copy_legacy(&w,&good,&m,&failed)==0);CHECK(failed==0);
    vn135_work_math math;
    CHECK(vn135_frontend_work_math(w.image,1.0,0,&math)==0);
    memcpy(w.image+0x100,math.target_le,32);
    CHECK(vn135_frontend_work_builder_fields(w.image,0x12345678,0xabcdef)==0);
    CHECK(vn135_work_clone_atomic(&w,700,&m,&out)==0);CHECK(out);
    for(unsigned i=0;i<3u;++i){CHECK(out->text[i]!=w.text[i]);CHECK(!strcmp(out->text[i],w.text[i]));}
    void *old[3]={w.text[0],w.text[1],w.text[2]};size_t freed=a.free_count;
    CHECK(vn135_frontend_work_storage_clear(&w,&m)==0);CHECK(image_zero(&w));CHECK(a.free_count==freed+3u);
    for(unsigned i=0;i<3u;++i)CHECK(a.released[freed+i]==old[i]);
    CHECK(!strcmp(out->text[0],(const char *)job));CHECK(!strcmp(out->text[2],(const char *)en));
    uint8_t digest[32];CHECK(vn135_frontend_hash_words80(out->image,digest)==0);
    CHECK(!memcmp(digest,fixture_hash,32));CHECK(vn135_target256_check_le(digest,out->image+0x100)==1);
    CHECK(vn135_frontend_work_storage_delete(&out,&m)==0);CHECK(!out&&!a.live&&!a.error);
    return 0;
}
int main(void){
    if(metadata_cases()||clone_cases()||guards_and_lifetime())return 1;
    printf("{\"stage\":11,\"native_scenarios\":%u,\"assertions\":%u,\"real_malloc_free\":true,\"hardware_tested\":false}\n",scenarios,checks);
    return 0;
}
