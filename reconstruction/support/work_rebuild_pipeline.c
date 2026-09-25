/* SPDX-License-Identifier: GPL-3.0-only
 * New snapshot/scratch adapter. Original producer/caller/wrapper mapping is
 * tested, but this is not the original allocator/queue/pool lifetime code.
 */
#include "xminer/recovery/work_rebuild.h"
#include <limits.h>
static int valid_snapshot(const vn135_rebuild_snapshot *s) {
    return s&&(!s->coinbase_size||s->coinbase)&&s->coinbase_size<=UINT32_MAX&&
        s->counter_size<=8u&&s->counter_offset<=s->coinbase_size&&
        s->counter_size<=s->coinbase_size-s->counter_offset&&
        (!s->merkle_count||s->merkle_branches)&&s->merkle_count<=INT32_MAX&&
        s->merkle_count<=SIZE_MAX/32u;
}
int vn135_rebuild_from_candidate(const vn135_nonce_candidate *candidate,
    const vn135_rebuild_snapshot *snapshot,uint8_t *scratch,size_t scratch_size,
    vn135_rebuilt_header *out) {
    vn135_work_template job={0};
    if(!candidate||!out||!valid_snapshot(snapshot)||
       (!scratch&&snapshot->coinbase_size))return VN135_VERIFY_INVALID;
    if(scratch_size<snapshot->coinbase_size)return -3;
    for(size_t i=0;i<112u;++i)job.header_words_le[i]=snapshot->header_words_le[i];
    for(size_t i=0;i<4u;++i)job.header_words_le[i]=(uint8_t)(candidate->version_word>>(8u*i));
    for(size_t i=0;i<snapshot->coinbase_size;++i)scratch[i]=snapshot->coinbase[i];
    job.coinbase=scratch;job.coinbase_size=snapshot->coinbase_size;
    job.counter_offset=snapshot->counter_offset;job.counter_size=snapshot->counter_size;
    job.counter=(uint64_t)candidate->job_word_70|((uint64_t)candidate->job_word_74<<32);
    job.merkle_branches=snapshot->merkle_branches;job.merkle_count=snapshot->merkle_count;
    return vn135_frontend_rebuild_prefix(&job,out);
}
int vn135_candidate_verify_snapshot(const vn135_nonce_candidate *candidate,
    const vn135_rebuild_snapshot *snapshot,uint8_t *scratch,size_t scratch_size,
    const uint8_t target_le[32],uint32_t *last_nonce,uint32_t selector,
    vn135_rebuild_check *out) {
    vn135_rebuild_check result={0};
    int rc;
    if(!target_le||!last_nonce||!out)return VN135_VERIFY_INVALID;
    rc=vn135_rebuild_from_candidate(candidate,snapshot,scratch,scratch_size,&result.rebuilt);
    if(rc)return rc;
    for(size_t i=0;i<80u;++i)result.work.header_words_le[i]=result.rebuilt.header_words_le[i];
    result.prefilter_result=vn135_frontend_sha256d_prefilter(&result.work,last_nonce,candidate->nonce,selector);
    result.hash_computed=result.prefilter_result==VN135_PREFILTER_DUPLICATE?0u:1u;
    if(result.prefilter_result==VN135_PREFILTER_CONTINUE){
        result.target_checked=1u;
        result.meets_target=(uint32_t)vn135_target256_check_le(result.work.digest,target_le);
    }
    *out=result;
    return 0;
}
