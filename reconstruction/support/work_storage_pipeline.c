/* New rollback adapter around a verified legacy copy route; not vendor code.
 * Does not publish a partial clone, change the original, acquire live jobs,
 * deduplicate shares, send work or claim a complete 632-byte work constructor. */
#include "xminer/recovery/work_storage.h"
int vn135_work_clone_atomic(const vn135_work_storage *source,uint32_t fresh_id,
    const vn135_work_memory *memory,vn135_work_storage **out) {
    vn135_work_storage *candidate=0;uint32_t failed=0;
    if(!out||*out)return VN135_STORAGE_INVALID;
    int rc=vn135_frontend_work_clone_unrolled(source,fresh_id,memory,&candidate,&failed);
    if(rc!=VN135_STORAGE_OK){
        if(candidate)(void)vn135_frontend_work_storage_delete(&candidate,memory);
        return rc==VN135_STORAGE_PARTIAL?VN135_STORAGE_NOMEM:rc;
    }
    *out=candidate;return VN135_STORAGE_OK;
}

#include "xminer/recovery/work_time.h"
int vn135_work_clone_time_atomic(const vn135_work_storage *source,
    uint32_t fresh_id,uint32_t delta,const vn135_work_memory *memory,
    vn135_work_storage **out) {
    vn135_work_storage *candidate=0;uint32_t failed=0;
    if(!out||*out)return VN135_STORAGE_INVALID;
    int rc=vn135_frontend_work_clone_time_legacy(source,fresh_id,delta,memory,&candidate,&failed);
    if(rc!=VN135_STORAGE_OK){
        if(candidate)(void)vn135_frontend_work_storage_delete(&candidate,memory);
        return rc==VN135_STORAGE_PARTIAL?VN135_STORAGE_NOMEM:rc;
    }
    *out=candidate;return VN135_STORAGE_OK;
}
