/* Native Stage12 checks. Only synthetic storage and real malloc/free.
 * No pool, hardware, vendor ABI cast or unchecked invalid-time execution. */
#include "xminer/recovery/work_time.h"
#include "xminer/recovery/nonce_verify.h"
#include "fixtures/genesis_work.h"
#include "fixtures/time_roll_vectors.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks,scenarios;
#define CHECK(x) do {++checks;if(!(x)){fprintf(stderr,"FAIL %s:%d %s\n",__FILE__,__LINE__,#x);return 1;}}while(0)
typedef struct{void*p;size_t n;int live;} block;
typedef struct{block blocks[16];unsigned count,calls,live,fail,error;size_t sizes[16];} arena;
static void *allocate(void *ctx,size_t n){
    arena*a=ctx;unsigned call=a->calls++;
    if(call>=16u||!n){a->error=1;return NULL;}
    a->sizes[call]=n;
    if(a->fail&(1u<<call))return NULL;
    void*p=malloc(n);if(!p){a->error=2;return NULL;}
    memset(p,0xcd,n);a->blocks[a->count++]=(block){p,n,1};++a->live;return p;
}
static void release(void *ctx,void*p){
    arena*a=ctx;
    for(unsigned i=0;i<a->count;++i)if(a->blocks[i].live&&a->blocks[i].p==p){
        a->blocks[i].live=0;--a->live;free(p);return;
    }
    a->error=3;
}
static vn135_work_memory mem(arena*a){vn135_work_memory m={a,allocate,release};return m;}
static void putbe(uint8_t*p,uint32_t n){p[0]=(uint8_t)(n>>24);p[1]=(uint8_t)(n>>16);p[2]=(uint8_t)(n>>8);p[3]=(uint8_t)n;}
static void putle(uint8_t*p,uint32_t n){p[0]=(uint8_t)n;p[1]=(uint8_t)(n>>8);p[2]=(uint8_t)(n>>16);p[3]=(uint8_t)(n>>24);}
static const size_t slots[4]={0x18c,0x19c,0x1a8,0x1b0};
static void init(vn135_work_storage*w,unsigned seed){
    memset(w,0,sizeof(*w));for(size_t i=0;i<632u;++i)w->image[i]=(uint8_t)(37u*i+seed);
    for(size_t i=0;i<4u;++i)memset(w->image+slots[i],0,4);
}
static int codec(void){
    for(unsigned pos=0;pos<8u;++pos)for(unsigned byte=0;byte<256u;++byte){
        ++scenarios;uint8_t text[8]={'0','1','2','3','a','b','c','d'};text[pos]=(uint8_t)byte;
        uint32_t value=0xabcdef12u,expected=0;int valid=1;
        for(size_t j=0;j<8u;++j){int c=text[j],n;
            if(c>='0'&&c<='9')n=c-'0';else if(c>='a'&&c<='f')n=c-'a'+10;
            else if(c>='A'&&c<='F')n=c-'A'+10;else{valid=0;break;}
            expected=16u*expected+(unsigned)n;
        }
        int rc=vn135_work_time_decode8(text,&value);
        CHECK(rc==(valid?0:-2));CHECK(value==(valid?expected:0xabcdef12u));
        if(valid){char buffer[11],reference[9];memset(buffer,0x5a,sizeof(buffer));
            CHECK(vn135_work_time_encode8(value,buffer+1)==0);
            (void)snprintf(reference,sizeof(reference),"%08x",(unsigned)value);
            CHECK(!memcmp(reference,buffer+1,9));CHECK(buffer[0]==0x5a&&buffer[10]==0x5a);}
    }
    uint32_t n=7;char s[9];CHECK(vn135_work_time_decode8(NULL,&n)==-2);CHECK(n==7);
    CHECK(vn135_work_time_decode8((const uint8_t*)"12345678",NULL)==-2);
    CHECK(vn135_work_time_encode8(0,NULL)==-2);CHECK(vn135_work_time_encode8(0,s)==0);
    CHECK(!strcmp(s,"00000000"));return 0;
}
static int clone_cases(void){
    static const unsigned order[4]={0,2,1,3};
    static const uint32_t deltas[]={0,1,0xffffffffu,0x80000000u};
    char *strings[4]={"job","ABCDEF01","extra","tail"};
    for(unsigned present=0;present<16u;++present)for(unsigned di=0;di<4u;++di)for(unsigned fail=0;fail<32u;++fail){
        uint32_t delta=deltas[di],ht=(present&1u)?0xffffffffu:0,tt=0xabcdef01u;
        vn135_work_storage src;init(&src,present);putbe(src.image+0x44,ht);
        for(size_t i=0;i<4u;++i)if(present&(1u<<i)){src.text[i]=strings[i];src.text_size[i]=strlen(strings[i]);}
        vn135_work_storage before=src;
        for(unsigned atomic=0;atomic<2u;++atomic){
            ++scenarios;arena a={0};a.fail=fail;vn135_work_memory m=mem(&a);vn135_work_storage*out=NULL;
            uint32_t mask=0xaabbccddu;unsigned emask=0,call=1;
            for(unsigned j=0;j<4u;++j)if(present&(1u<<order[j])){
                if(fail&(1u<<call))emask|=1u<<order[j];
                ++call;
            }
            int rc=atomic?vn135_work_clone_time_atomic(&src,0xfeedbabeu,delta,&m,&out):
                vn135_frontend_work_clone_time_legacy(&src,0xfeedbabeu,delta,&m,&out,&mask);
            CHECK(!memcmp(&src,&before,sizeof(src)));CHECK(!a.error);
            if(fail&1u){CHECK(rc==-3&&!out&&!a.live);CHECK(mask==0xaabbccddu);CHECK(a.calls==1);}
            else if(atomic&&emask){CHECK(rc==-3&&!out&&!a.live);CHECK(a.calls==call);}
            else{
                CHECK(out);CHECK(rc==(emask?1:0));if(!atomic)CHECK(mask==emask);CHECK(a.calls==call);
                uint8_t expected[632];memcpy(expected,src.image,632);putle(expected+0x1bc,0xfeedbabeu);
                if(delta)putbe(expected+0x44,ht+delta);
                CHECK(!memcmp(expected,out->image,632));
                unsigned index=1;
                for(unsigned k=0;k<4u;++k){unsigned i=order[k];
                    if(!(present&(1u<<i))){CHECK(!out->text[i]&&!out->text_size[i]);continue;}
                    CHECK(a.sizes[index]==((i==1u&&delta)?12u:strlen(strings[i])+1u));++index;
                    if(emask&(1u<<i)){CHECK(!out->text[i]&&!out->text_size[i]);continue;}
                    CHECK(out->text[i]!=src.text[i]);
                    if(i==1u&&delta){char expected_text[9];(void)snprintf(expected_text,9,"%08x",(unsigned)(tt+delta));
                        CHECK(!strcmp(out->text[i],expected_text));CHECK(out->text_size[i]==8u);
                        CHECK(out->text[i][9]==0&&out->text[i][10]==0&&out->text[i][11]==0);
                    }else{CHECK(!strcmp(out->text[i],strings[i]));CHECK(out->text_size[i]==strlen(strings[i]));}
                }
                CHECK(vn135_frontend_work_storage_delete(&out,&m)==0);CHECK(!out&&!a.live&&!a.error);
                unsigned calls=a.calls;CHECK(vn135_frontend_work_storage_delete(&out,&m)==0);CHECK(a.calls==calls);
            }
        }
    }
    return 0;
}
static int guards(void){
    static const char *bad[]={"","1234567","123456789","0x123456","0000000g","--------"," 1234567",("\xff" "2345678")};
    for(size_t i=0;i<sizeof(bad)/sizeof(bad[0]);++i){
        ++scenarios;vn135_work_storage src;init(&src,7);src.text[1]=(char*)bad[i];src.text_size[1]=strlen(bad[i]);
        vn135_work_storage before=src,*out=NULL;arena a={0};vn135_work_memory m=mem(&a);uint32_t mask=0xeeeeeeeeu;
        CHECK(vn135_frontend_work_clone_time_legacy(&src,0,1,&m,&out,&mask)==-2);
        CHECK(!out&&!a.calls&&mask==0xeeeeeeeeu);CHECK(!memcmp(&src,&before,sizeof(src)));
        CHECK(vn135_work_clone_time_atomic(&src,0,1,&m,&out)==-2);CHECK(!a.calls);
        /* Zero delta retains Stage11's arbitrary-string contract. */
        CHECK(vn135_frontend_work_clone_time_legacy(&src,0,0,&m,&out,&mask)==0);
        CHECK(!strcmp(out->text[1],bad[i]));CHECK(vn135_frontend_work_storage_delete(&out,&m)==0);CHECK(!a.live);
    }
    arena a={0};vn135_work_memory m=mem(&a),broken={0};vn135_work_storage src;init(&src,9);
    vn135_work_storage *out=NULL;uint32_t mask=3;
    CHECK(vn135_frontend_work_clone_time_legacy(NULL,0,1,&m,&out,&mask)==-2);
    CHECK(vn135_frontend_work_clone_time_legacy(&src,0,1,&broken,&out,&mask)==-2);
    CHECK(vn135_frontend_work_clone_time_legacy(&src,0,1,&m,NULL,&mask)==-2);
    CHECK(vn135_frontend_work_clone_time_legacy(&src,0,1,&m,&out,NULL)==-2);
    out=&src;CHECK(vn135_work_clone_time_atomic(&src,0,1,&m,&out)==-2);CHECK(out==&src&&!a.calls);
    out=NULL;src.image[0x18c]=1;CHECK(vn135_work_clone_time_atomic(&src,0,1,&m,&out)==-2);
    CHECK(!a.calls);src.image[0x18c]=0;
    char no_term[]={'1','2','3','4','5','6','7','8','X'};src.text[1]=no_term;src.text_size[1]=8;
    CHECK(vn135_work_clone_time_atomic(&src,0,1,&m,&out)==-2);CHECK(!a.calls);
    return 0;
}
static int lifecycle(void){
    for(size_t i=0;i<sizeof(time_vectors)/sizeof(time_vectors[0]);++i){
        ++scenarios;const time_vector*v=&time_vectors[i];arena a={0};vn135_work_memory m=mem(&a);
        vn135_work_storage source={0};memcpy(source.image,fixture_words,112);
        source.text[0]="historical-fixture";source.text_size[0]=18;
        source.text[1]="495FAB29";source.text_size[1]=8;
        vn135_work_storage *copy=NULL,*restored=NULL;uint8_t hash[32],expected[632];
        memcpy(expected,source.image,632);putle(expected+0x1bc,9);putbe(expected+0x44,v->time);
        CHECK(vn135_work_clone_time_atomic(&source,9,v->delta,&m,&copy)==0);
        CHECK(!memcmp(copy->image,expected,632));CHECK(vn135_frontend_hash_words80(copy->image,hash)==0);
        CHECK(!memcmp(hash,v->digest,32));
        /* Reverse offset in a distinct owned clone, then clear the intermediate. */
        CHECK(vn135_work_clone_time_atomic(copy,10,0u-v->delta,&m,&restored)==0);
        CHECK(vn135_frontend_work_storage_clear(copy,&m)==0);
        CHECK(!memcmp(restored->image,fixture_words,112));
        CHECK(!strcmp(restored->text[0],"historical-fixture"));
        CHECK(!strcmp(restored->text[1],v->delta?"495fab29":"495FAB29"));
        CHECK(vn135_frontend_hash_words80(restored->image,hash)==0);CHECK(!memcmp(hash,fixture_hash,32));
        CHECK(vn135_frontend_work_storage_delete(&copy,&m)==0);
        CHECK(vn135_frontend_work_storage_delete(&restored,&m)==0);CHECK(!a.live&&!a.error);
    }
    return 0;
}
int main(void){
    if(codec()||clone_cases()||guards()||lifecycle())return 1;
    printf("{\"stage\":12,\"status\":\"PASS\",\"native_scenarios\":%u,\"assertions\":%u,\"hardware_tested\":false}\n",scenarios,checks);return 0;
}
