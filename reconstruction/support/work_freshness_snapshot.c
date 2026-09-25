/* NEW adapter, not an original vendor unit or ownership implementation. */
#include "xminer/recovery/work_freshness.h"
static uint32_t word(const uint8_t *p) {
    return (uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);
}
int vn135_work_storage_stale_snapshot(const vn135_work_storage *w,
    uint32_t block,uint8_t share,uint8_t active,uint8_t notify,
    vn135_text_view job,uint64_t now,vn135_work_freshness_result *out) {
    static const unsigned slots[4]={0x18cu,0x19cu,0x1a8u,0x1b0u};
    vn135_work_freshness_snapshot s={0};
    if(!w||!out)return VN135_FRESHNESS_INVALID;
    for(unsigned i=0;i<4u;++i)if(word(w->image+slots[i]))return VN135_FRESHNESS_INVALID;
    s.work_block=word(w->image+0x1b8u);s.current_work_block=block;
    uint32_t raw=word(w->image+0x184u);
    /* Defined conversion, including INT32_MIN, without implementation-defined
     * uint32_t -> int32_t conversion for out-of-range unsigned values. */
    s.rolltime=raw<=INT32_MAX?(int32_t)raw:-1-(int32_t)(UINT32_MAX-raw);
    s.share=share;s.pool_byte_3fc=active;s.pool_byte_3fe=notify;
    s.staged_seconds_bits=word(w->image+0x170u)|((uint64_t)word(w->image+0x174u)<<32);
    s.now_seconds_bits=now;
    s.work_job_id.data=(const uint8_t *)w->text[VN135_TEXT_18C];
    s.work_job_id.size=w->text_size[VN135_TEXT_18C];s.pool_job_id=job;
    return vn135_frontend_work_stale_legacy(&s,out);
}
