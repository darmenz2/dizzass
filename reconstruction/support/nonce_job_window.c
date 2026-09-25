/* Bounded consumer selection from 0x74de4; original source filename unknown.
 * Normalized stable snapshot, no original mutex/queue/work-pointer ABI.
 * Pointer-wrap sentinel from the raw ARM pointer arithmetic is not meaningful
 * in this checked API; only valid three-record arrays are accepted. */
#include "xminer/recovery/nonce_verify.h"
int vn135_recent_job_select(const vn135_recent_job_record records[3],uint32_t key,
    vn135_job_reject_fn reject,void *context,size_t *selected_index) {
    if (!records || !reject || !selected_index) return VN135_VERIFY_INVALID;
    for (size_t i=0;i<3;i++) {
        if (records[i].key!=key) continue;
        if (!records[i].reference) return VN135_JOB_NULL_REFERENCE;
        if (reject(context,records[i].reference)) return VN135_JOB_REJECTED;
        if (!records[i].word_1fc) return VN135_JOB_STATUS_ZERO;
        *selected_index=i;
        return VN135_JOB_SELECTED;
    }
    return VN135_JOB_NOT_FOUND;
}

int vn135_reference_absent(void *const *references,int32_t count,void *reference) {
    if (count<=0) return 1;
    if (!references) return VN135_VERIFY_INVALID;
    for (int32_t i=0;i<count;i++) if (references[i]==reference) return 0;
    return 1;
}
struct reference_snapshot { void *const *references; int32_t count; };
static int reject_absent(void *context,void *reference) {
    const struct reference_snapshot *snapshot=context;
    return vn135_reference_absent(snapshot->references,snapshot->count,reference);
}
int vn135_recent_job_select_registered(const vn135_recent_job_record records[3],
    uint32_t key,void *const *references,int32_t count,size_t *selected_index) {
    if (count>0 && !references) return VN135_VERIFY_INVALID;
    struct reference_snapshot snapshot={references,count};
    return vn135_recent_job_select(records,key,reject_absent,&snapshot,selected_index);
}
