/* Partial reconstruction. Direct source-path reference at 0x32fdc proves
 * frontend ownership of the prefilter. Hash helper 0x2d994 is placed here as an
 * integration choice within the frontend code cluster; its own source filename
 * is not independently proven. This is NOT a new main or full vendor frontend.
 * Evidence: evidence/stage8/recovery-manifest.json. */
#include "xminer/recovery/nonce_verify.h"
static uint32_t load_le(const uint8_t *p) {
    return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);
}
static void store_le(uint8_t *p,uint32_t v) {
    p[0]=(uint8_t)v;p[1]=(uint8_t)(v>>8);p[2]=(uint8_t)(v>>16);p[3]=(uint8_t)(v>>24);
}
int vn135_frontend_hash_words80(const uint8_t words[80], uint8_t digest[32]) {
    uint8_t header[80];
    if (!words || !digest) return VN135_VERIFY_INVALID;
    for (size_t i=0;i<80;i+=4)
        for (size_t j=0;j<4;j++) header[i+j]=words[i+3-j];
    return vn135_sha256d_header80(header,digest);
}
int vn135_frontend_nonce_prefilter(vn135_verify_work *work, uint32_t *last_nonce,
    uint32_t nonce, uint32_t selector, vn135_work_hash_fn hash, void *context) {
    if (!work || !last_nonce || !hash) return VN135_VERIFY_INVALID;
    if (*last_nonce==nonce) return VN135_PREFILTER_DUPLICATE;
    /* The original retains this value even when the later hash gate rejects. */
    *last_nonce=nonce;
    store_le(work->header_words_le+76,nonce);
    hash(context,work->header_words_le,work->digest);
    return load_le(work->digest+28) <= (selector==1 ? UINT32_C(0xffff) : 0u)
        ? VN135_PREFILTER_CONTINUE : VN135_PREFILTER_HIGH_WORD;
}
static void sha_hash(void *context,const uint8_t words[80],uint8_t digest[32]) {
    (void)context;
    /* The validated outer API supplies both non-NULL fixed-size arrays. */
    (void)vn135_frontend_hash_words80(words,digest);
}
int vn135_frontend_sha256d_prefilter(vn135_verify_work *work,uint32_t *last_nonce,
    uint32_t nonce,uint32_t selector) {
    return vn135_frontend_nonce_prefilter(work,last_nonce,nonce,selector,sha_hash,0);
}

/* Stage9: bounded materializer at 0x30550..0x30a6c. Original SHA calls execute
 * in differential tests. Explicit array view replaces pool pointers/rwlocks.
 * The remainder (target, strings, accounting and ownership) is NOT implemented
 * by this prefix. All 112 source bytes are preserved except the Merkle words. */
#include "xminer/recovery/work_rebuild.h"
#include <limits.h>
int vn135_frontend_rebuild_prefix(vn135_work_template *job,vn135_rebuilt_header *out) {
    vn135_rebuilt_header result={0};
    uint8_t pair[64];
    if(!job||!out||(!job->coinbase&&job->coinbase_size)||
       job->coinbase_size>UINT32_MAX||job->counter_size>8u||
       job->counter_offset>job->coinbase_size||
       job->counter_size>job->coinbase_size-job->counter_offset||
       (job->merkle_count&&!job->merkle_branches)||
       job->merkle_count>INT32_MAX||job->merkle_count>SIZE_MAX/32u)
        return VN135_VERIFY_INVALID;
    result.counter_used=job->counter;
    result.counter_size=job->counter_size;
    for(size_t i=0;i<job->counter_size;++i)
        job->coinbase[job->counter_offset+i]=(uint8_t)(job->counter>>(8u*i));
    job->counter+=UINT64_C(1); /* Defined unsigned wrap even for counter_size=0. */
    (void)vn135_sha256d_bytes(job->coinbase,job->coinbase_size,result.merkle_root);
    for(size_t i=0;i<job->merkle_count;++i){
        for(size_t j=0;j<32u;++j){
            pair[j]=result.merkle_root[j];pair[32u+j]=job->merkle_branches[32u*i+j];
        }
        (void)vn135_sha256d_bytes(pair,64u,result.merkle_root);
    }
    for(size_t i=0;i<112u;++i)result.header_words_le[i]=job->header_words_le[i];
    for(size_t i=0;i<32u;i+=4u)
        for(size_t j=0;j<4u;++j)result.header_words_le[36u+i+j]=result.merkle_root[i+3u-j];
    *out=result;
    return 0;
}

/* Stage10: difficulty/target and first-block midstate. These placements are
 * integration choices within the same frontend cluster, NOT independently
 * proven original filenames. See evidence/stage10/recovery-manifest.json.
 * Compile without fast-math or fused contraction. Default RN is a precondition.
 */
#include "xminer/recovery/difficulty.h"
#include "xminer/recovery/sha256_midstate.h"
#include <float.h>
#if defined(__FAST_MATH__) || (defined(__FINITE_MATH_ONLY__) && __FINITE_MATH_ONLY__)
#error "Recovered floating-point arithmetic requires strict IEEE semantics"
#endif
#if FLT_RADIX != 2 || DBL_MANT_DIG != 53 || DBL_MAX_EXP != 1024 || FLT_EVAL_METHOD != 0
#error "Recovery requires IEEE binary64 double"
#endif
static double difficulty_numerator(uint32_t selector) {
    /* Exact literals: ELF 0x30040 = 0x4defffe000000000,
     * ELF 0x30048 = 0x4eefffe000000000. */
    return selector==1u ? 0x1.fffep239 : 0x1.fffep223;
}
static uint64_t load_le64(const uint8_t *p) {
    return (uint64_t)load_le(p)|((uint64_t)load_le(p+4)<<32);
}
int vn135_frontend_target_from_difficulty(double difficulty,uint32_t selector,
    uint8_t target_le[32]) {
    static const double down[4]={0x1p-192,0x1p-128,0x1p-64,1.0};
    static const double up[3]={0x1p192,0x1p128,0x1p64};
    uint64_t limbs[4];
    double q;
    if(!target_le||difficulty!=difficulty||difficulty<0.0||difficulty>DBL_MAX)
        return VN135_VERIFY_INVALID;
    if(difficulty==0.0) difficulty=1.0;
    q=difficulty_numerator(selector)/difficulty;
    if(!(q<0x1p256)) return VN135_DIFFICULTY_RANGE;
    for(size_t i=0;i<4u;++i){
        double scaled=q*down[i];
        /* Explicit bounds keep C FP-to-integer conversion defined. Original
         * VFP helpers and C agree on the accepted finite input domain. */
        if(!(scaled>=0.0&&scaled<0x1p64))return VN135_DIFFICULTY_RANGE;
        limbs[3u-i]=(uint64_t)scaled;
        if(i<3u){
            volatile double product=(double)limbs[3u-i]*(-up[i]);
            q=q+product; /* two rounded operations, matching VMLA not VFMA */
        }
    }
    for(size_t i=0;i<4u;++i){
        store_le(target_le+8u*i,(uint32_t)limbs[i]);
        store_le(target_le+8u*i+4u,(uint32_t)(limbs[i]>>32));
    }
    return 0;
}
int vn135_frontend_difficulty_from_target(const uint8_t target_le[32],
    uint32_t selector,double *difficulty) {
    double q;
    volatile double term;
    if(!target_le||!difficulty)return VN135_VERIFY_INVALID;
    q=(double)load_le64(target_le+16)*0x1p128;
    term=(double)load_le64(target_le+24)*0x1p192;q=q+term;
    term=(double)load_le64(target_le+8)*0x1p64;q=q+term;
    q=q+(double)load_le64(target_le);
    if(q==0.0)q=1.0;
    *difficulty=difficulty_numerator(selector)/q;
    return 0;
}
int vn135_frontend_work_math(const uint8_t words112[112],double difficulty,
    uint32_t selector,vn135_work_math *out) {
    vn135_work_math result;
    uint8_t block[64];
    int rc;
    if(!words112||!out)return VN135_VERIFY_INVALID;
    /* Validate arithmetic first; output remains untouched on API errors. */
    rc=vn135_frontend_target_from_difficulty(difficulty,selector,result.target_le);
    if(rc)return rc;
    for(size_t i=0;i<64u;i+=4u)
        for(size_t j=0;j<4u;++j)block[i+j]=words112[i+3u-j];
    (void)vn135_sha256_midstate64(block,result.midstate);
    *out=result;
    return 0;
}

/* Stage11/12: owned strings, opaque work copy with checked time-roll, clear/delete,
 * and bounded builder/wrapper field writes. Source placement is an integration
 * choice in the existing frontend cluster. See evidence/stage11. */
#include "xminer/recovery/work_storage.h"
#include "xminer/recovery/work_time.h"
static const size_t work_text_offsets[4]={0x18cu,0x19cu,0x1a8u,0x1b0u};
static int storage_memory_ok(const vn135_work_memory *m) {
    return m && m->allocate && m->release;
}
static int storage_view_ok(vn135_text_view s) {
    if(!s.data)return s.size==0u;
    if(s.size>=UINT32_MAX || s.size==SIZE_MAX)return 0;
    for(size_t i=0;i<s.size;++i)if(s.data[i]==0u)return 0;
    return 1;
}
static int storage_image_ok(const vn135_work_storage *w) {
    if(!w)return 0;
    for(size_t i=0;i<4u;++i){
        if(load_le(w->image+work_text_offsets[i])!=0u)return 0;
        if(!w->text[i] && w->text_size[i])return 0;
    }
    return 1;
}
static char *storage_duplicate(vn135_text_view view,const vn135_work_memory *m) {
    char *p=(char *)m->allocate(m->context,view.size+1u);
    if(!p)return 0;
    for(size_t i=0;i<view.size;++i)p[i]=(char)view.data[i];
    p[view.size]='\0';return p;
}
int vn135_frontend_work_metadata_copy_legacy(vn135_work_storage *out,
    const vn135_work_metadata_view *view,const vn135_work_memory *m,uint32_t *failed) {
    vn135_text_view inputs[3];
    static const unsigned order[3]={0u,2u,1u};
    uint32_t mask=0;
    if(!out||!view||!failed||!storage_memory_ok(m)||!storage_image_ok(out))
        return VN135_STORAGE_INVALID;
    inputs[0]=view->text_3d0;inputs[1]=view->text_3ec;inputs[2]=view->text_396;
    for(size_t i=0;i<3u;++i)
        if(!inputs[i].data||!storage_view_ok(inputs[i])||out->text[order[i]])
            return VN135_STORAGE_INVALID;
    store_le(out->image+0x1a0u,(uint32_t)view->difficulty_bits);
    store_le(out->image+0x1a4u,(uint32_t)(view->difficulty_bits>>32));
    for(size_t i=0;i<3u;++i){
        unsigned slot=order[i];char *p=storage_duplicate(inputs[i],m);
        out->text[slot]=p;out->text_size[slot]=p?inputs[i].size:0u;
        if(!p)mask|=UINT32_C(1)<<slot;
    }
    *failed=mask;return mask?VN135_STORAGE_PARTIAL:VN135_STORAGE_OK;
}
int vn135_frontend_work_clone_time_legacy(const vn135_work_storage *source,
    uint32_t fresh_id,uint32_t delta,const vn135_work_memory *m,
    vn135_work_storage **out,uint32_t *failed) {
    static const unsigned order[4]={0u,2u,1u,3u};
    vn135_work_storage *copy;uint32_t mask=0,time_value=0;
    if(!out||*out||!failed||!storage_memory_ok(m)||!storage_image_ok(source))
        return VN135_STORAGE_INVALID;
    for(size_t i=0;i<4u;++i){
        vn135_text_view v={(const uint8_t *)source->text[i],source->text_size[i]};
        if(!storage_view_ok(v))return VN135_STORAGE_INVALID;
        /* Extent through the terminator is a precondition for owned strings. */
        if(source->text[i] && source->text[i][source->text_size[i]]!='\0')
            return VN135_STORAGE_INVALID;
    }
    /* NEW strict format guard: original clone ignored hex2bin failure and could
     * use incomplete stack data. We do not give such input invented semantics. */
    if(delta && source->text[VN135_TEXT_19C]){
        if(source->text_size[VN135_TEXT_19C]!=8u ||
           vn135_work_time_decode8((const uint8_t *)source->text[VN135_TEXT_19C],&time_value))
            return VN135_STORAGE_INVALID;
    }
    copy=(vn135_work_storage *)m->allocate(m->context,sizeof(*copy));
    if(!copy)return VN135_STORAGE_NOMEM; /* Added, not a vendor guarantee. */
    for(size_t i=0;i<VN135_WORK_IMAGE_BYTES;++i)copy->image[i]=source->image[i];
    for(size_t i=0;i<4u;++i){copy->text[i]=0;copy->text_size[i]=0;}
    store_le(copy->image+0x1bcu,fresh_id);
    for(size_t i=0;i<4u;++i){
        unsigned slot=order[i];
        if(slot==VN135_TEXT_19C && delta){
            uint8_t *p=copy->image+0x44u;
            uint32_t n=((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3];
            n+=delta;
            p[0]=(uint8_t)(n>>24);p[1]=(uint8_t)(n>>16);p[2]=(uint8_t)(n>>8);p[3]=(uint8_t)n;
        }
        if(source->text[slot]){
            vn135_text_view v={(const uint8_t *)source->text[slot],source->text_size[slot]};
            char *p;
            if(slot==VN135_TEXT_19C && delta){
                /* Original 0x1068c calloc size when len=4 is 12, not 9. */
                p=(char *)m->allocate(m->context,12u);
                if(p){
                    for(size_t j=0;j<12u;++j)p[j]='\0';
                    (void)vn135_work_time_encode8(time_value+delta,p);
                }
                /* Guarding p==NULL here is NEW; original encoder writes it. */
                copy->text_size[slot]=p?8u:0u;
            }else{
                p=storage_duplicate(v,m);copy->text_size[slot]=p?v.size:0u;
            }
            copy->text[slot]=p;
            if(!p)mask|=UINT32_C(1)<<slot;
        }
    }
    *out=copy;*failed=mask;return mask?VN135_STORAGE_PARTIAL:VN135_STORAGE_OK;
}
/* Preserve the Stage11 zero-roll API and its existing string domain. */
int vn135_frontend_work_clone_unrolled(const vn135_work_storage *source,
    uint32_t fresh_id,const vn135_work_memory *m,vn135_work_storage **out,uint32_t *failed) {
    return vn135_frontend_work_clone_time_legacy(source,fresh_id,0u,m,out,failed);
}
static void storage_release_strings(vn135_work_storage *work,const vn135_work_memory *m) {
    static const unsigned order[4]={0u,1u,3u,2u};
    for(size_t i=0;i<4u;++i){
        unsigned slot=order[i];
        if(work->text[slot])m->release(m->context,work->text[slot]);
        work->text[slot]=0;work->text_size[slot]=0;
    }
}
int vn135_frontend_work_storage_clear(vn135_work_storage *work,const vn135_work_memory *m) {
    if(!work||!storage_memory_ok(m))return VN135_STORAGE_INVALID;
    storage_release_strings(work,m);
    for(size_t i=0;i<VN135_WORK_IMAGE_BYTES;++i)work->image[i]=0;
    return VN135_STORAGE_OK;
}
int vn135_frontend_work_storage_delete(vn135_work_storage **work,const vn135_work_memory *m) {
    if(!work||!storage_memory_ok(m))return VN135_STORAGE_INVALID;
    if(*work){storage_release_strings(*work,m);m->release(m->context,*work);*work=0;}
    return VN135_STORAGE_OK;
}
int vn135_frontend_work_builder_fields(uint8_t image[VN135_WORK_IMAGE_BYTES],
    uint32_t template_cookie,uint32_t global_cookie) {
    if(!image)return VN135_STORAGE_INVALID;
    image[0x250u]=0x53u;store_le(image+0x16cu,template_cookie);
    store_le(image+0x15cu,60u);store_le(image+0x160u,0u);
    store_le(image+0x1b8u,global_cookie);return VN135_STORAGE_OK;
}
int vn135_frontend_work_wrapper_fields(uint8_t image[VN135_WORK_IMAGE_BYTES],
    uint32_t reference_cookie,uint32_t word168,uint32_t global_cookie,
    uint32_t *reference_word98,uint32_t word160,uint32_t word254) {
    if(!image||!reference_word98)return VN135_STORAGE_INVALID;
    store_le(image+0x16cu,reference_cookie);store_le(image+0x168u,word168);
    store_le(image+0x1b8u,global_cookie);*reference_word98+=UINT32_C(1);
    store_le(image+0x160u,word160);image[0x180u]=1u;
    store_le(image+0x254u,word254);return VN135_STORAGE_OK;
}

/* Stage14: snapshot equivalents of original 0x2a560 and 0x32040.
 * Placement is the existing frontend integration cluster, not a proof of the
 * original source file for these individual functions. Diagnostics and locks
 * are not reproduced; coherent retained snapshots are caller preconditions. */
#include "xminer/recovery/work_freshness.h"
#include <float.h>
#if DBL_MANT_DIG != 53 || DBL_MAX_EXP != 1024
#error "Stage14 expects binary64 double"
#endif
static int freshness_text_valid(vn135_text_view view) {
    if(!view.data)return view.size==0u;
    for(size_t i=0;i<view.size;++i)if(view.data[i]==0u)return 0;
    return 1;
}
int vn135_pool_unusable_legacy(const vn135_pool_gate_snapshot *p,int *out) {
    if(!p||!out)return VN135_FRESHNESS_INVALID;
    *out=p->word_1fc!=1u || !p->byte_3fc || !p->byte_3fe ||
         !p->byte_209 || p->byte_1ea!=0u;
    return VN135_FRESHNESS_OK;
}
int vn135_frontend_work_stale_legacy(const vn135_work_freshness_snapshot *s,
    vn135_work_freshness_result *out) {
    vn135_work_freshness_result r={0,0,0,0,0.0,0.0};
    if(!s||!out||!freshness_text_valid(s->work_job_id)||
       !freshness_text_valid(s->pool_job_id))return VN135_FRESHNESS_INVALID;
    if(s->work_block!=s->current_work_block){
        r.stale=1;r.reason=VN135_WORK_BLOCK_CHANGED;*out=r;return 0;
    }
    r.expiry_seconds=s->rolltime>60?(double)s->rolltime:600.0;
    if(!s->share){
        if(!s->pool_byte_3fc||!s->pool_byte_3fe){
            r.stale=1;r.reason=VN135_WORK_STRATUM_INACTIVE;*out=r;return 0;
        }
        if(s->work_job_id.data && s->pool_job_id.data){
            int equal=s->work_job_id.size==s->pool_job_id.size;
            r.job_ids_compared=1u;
            if(equal)for(size_t i=0;i<s->work_job_id.size;++i)
                if(s->work_job_id.data[i]!=s->pool_job_id.data[i]){equal=0;break;}
            if(!equal){r.stale=1;r.reason=VN135_WORK_JOB_CHANGED;*out=r;return 0;}
        }
    }
    /* SUBS/SBC in the original are a modular 64-bit subtraction. */
    uint64_t bits=s->now_seconds_bits-s->staged_seconds_bits;
    if(bits & (UINT64_C(1)<<63))r.age_seconds=-(double)(~bits+UINT64_C(1));
    else r.age_seconds=(double)bits;
    if(r.expiry_seconds<5.0)r.expiry_seconds=5.0;
    r.time_compared=1u;r.stale=!(r.expiry_seconds>r.age_seconds);
    r.reason=r.stale?VN135_WORK_EXPIRED:VN135_WORK_CURRENT;
    *out=r;return VN135_FRESHNESS_OK;
}
