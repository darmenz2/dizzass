/* SPDX-License-Identifier: GPL-3.0-only
 * New bounded offline adapter. Not original thread, queue, job lifetime or ABI.
 */
#include "xminer/recovery/difficulty.h"
int vn135_candidate_verify_difficulty(const vn135_nonce_candidate *candidate,
    const vn135_rebuild_snapshot *snapshot,uint8_t *scratch,size_t scratch_size,
    double difficulty,uint32_t *last_nonce,uint32_t selector,
    vn135_difficulty_check *out) {
    vn135_difficulty_check result={0};
    int rc;
    if(!out||!last_nonce)return VN135_VERIFY_INVALID;
    rc=vn135_frontend_target_from_difficulty(difficulty,selector,result.target_le);
    if(rc)return rc;
    rc=vn135_candidate_verify_snapshot(candidate,snapshot,scratch,scratch_size,
        result.target_le,last_nonce,selector,&result.checked);
    if(rc)return rc;
    *out=result;
    return 0;
}
