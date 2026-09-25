/* SPDX-License-Identifier: GPL-3.0-only
 * New integration adapter: Stage 6 RX -> external consistent snapshot ->
 * recovered Stage 7 candidate. NOT the original job-table/thread implementation.
 */
#include "xminer/recovery/work_nonce.h"
int vn135_work_nonce_from_rx(const vn135_work_rx_policy *p,
    const vn135_work_rx_message *m,const vn135_work_job_reader *reader,
    const vn135_nonce_attribution *attribution,vn135_work_nonce_result *out)
{
    vn135_work_rx_policy check;
    vn135_work_job_snapshot job;
    uint32_t slot;
    int rc;
    if(!p||!m||!reader||!reader->read_snapshot||!attribution||
       !attribution->chip_from_nonce||!attribution->core_from_nonce||!out)
        return VN135_NONCE_INVALID;
    (void)vn135_work_rx_policy_init(&check,p->board_selector,p->chip_selector,p->special_mode);
    if(p->special_mode||p->variant!=check.variant||p->payload_size!=check.payload_size||
       p->frame_size!=check.frame_size||m->kind!=VN135_RX_NONCE_RAW||
       m->payload_size!=check.payload_size||m->consumed!=check.frame_size||
       !(m->payload[check.payload_size-1]&0x80u))return VN135_NONCE_INVALID;
    rc=vn135_work_rx_job_slot(p->chip_selector,p->variant,m->payload,m->payload_size,&slot);
    if(rc||slot!=m->job_slot)return VN135_NONCE_INVALID;
    rc=reader->read_snapshot(reader->context,slot,&job);
    if(rc==0)return VN135_NONCE_NO_JOB;
    if(rc!=1)return VN135_NONCE_LOOKUP_FAILED;
    return vn135_work_nonce_prepare(p->chip_selector,p->variant,m->chain_id,
                                   m->payload,m->payload_size,&job,attribution,out);
}
