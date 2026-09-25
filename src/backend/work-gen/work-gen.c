/* Partial reconstruction of observed src/backend/work-gen/work-gen.c.
 * Sources: original ARM RX loop 0xc4054..0xc4aa8 (bounded slices documented in
 * evidence/stage6). Deliberately excludes threads, runtime queues, device setup,
 * nonce/job validation, CRC verification, and shares. No source-name/ABI claim.
 */
#include "xminer/recovery/work_rx.h"

int vn135_work_rx_policy_init(vn135_work_rx_policy *out,
                             uint32_t board, uint32_t chip, uint32_t special)
{
    vn135_work_rx_policy p;
    if (!out) return VN135_RX_INVALID;
    p.board_selector = board;
    p.chip_selector = chip;
    p.special_mode = special;
    p.variant = 0;
    if (board != 0 && !(chip == 6 && board == 4))
        p.variant = chip == 7 ? 1u : 2u;
    p.payload_size = special ? 7u : 7u + p.variant;
    p.frame_size = p.payload_size + 2u;
    *out = p;
    return 0;
}

/* Placement in this module is an integration choice: original dispatcher file
 * ownership has NOT been determined. Entire original 0xd2a84 dispatch and five
 * constant-return callees are compared in tests with the global getter injected. */
uint32_t vn135_work_rx_filtered_register(uint32_t chip)
{
    return chip <= 4u ? 0x40u : UINT32_MAX;
}

static int policy_valid(const vn135_work_rx_policy *p)
{
    vn135_work_rx_policy expected;
    if (!p) return 0;
    (void)vn135_work_rx_policy_init(&expected, p->board_selector,
                                  p->chip_selector, p->special_mode);
    return p->variant == expected.variant &&
           p->payload_size == expected.payload_size &&
           p->frame_size == expected.frame_size;
}

int vn135_work_rx_job_slot(uint32_t chip, uint32_t variant,
                          const uint8_t *p, size_t size, uint32_t *slot)
{
    uint32_t raw;
    if (!p || !slot || variant > 2 || size < 7u + variant)
        return VN135_RX_INVALID;
    raw = p[variant == 1 ? 6u : 5u];
    if ((chip | 1u) == 5u)
        raw = (variant == 2 ? ((uint32_t)p[4] << 7) : UINT32_C(0xffffff80)) |
              (raw >> 1);
    *slot = (raw >> 3) & 31u;
    return 0;
}

int vn135_work_rx_next(const vn135_work_rx_policy *p, uint32_t chain,
                      const uint8_t *data, size_t available,
                      vn135_work_rx_message *out)
{
    vn135_work_rx_message r = {0};
    uint32_t offset, last;
    if (!policy_valid(p) || !out || (!data && available))
        return VN135_RX_INVALID;
    r.chain_id = chain;
    if (available < p->frame_size) {
        *out = r;
        return VN135_RX_NEED_MORE;
    }
    if (data[0] != 0xaa || data[1] != 0x55) {
        r.kind = VN135_RX_DISCARDED;
        r.consumed = data[0] == 0xaa ? 2u : 1u;
        *out = r;
        return VN135_RX_DISCARDED;
    }
    r.consumed = p->frame_size;
    r.payload_size = p->payload_size;
    for (uint32_t i = 0; i < r.payload_size; ++i) r.payload[i] = data[i + 2u];
    last = r.payload[r.payload_size - 1u];
    r.crc5_field = last & 31u;
    if (!p->special_mode && (last & 0x80u)) {
        r.kind = VN135_RX_NONCE_RAW;
        (void)vn135_work_rx_job_slot(p->chip_selector, p->variant,
                                   r.payload, r.payload_size, &r.job_slot);
    } else {
        offset = !p->special_mode && p->variant == 1 ? 1u : 0u;
        r.register_value = ((uint32_t)r.payload[offset] << 24) |
                           ((uint32_t)r.payload[offset + 1u] << 16) |
                           ((uint32_t)r.payload[offset + 2u] << 8) |
                           r.payload[offset + 3u];
        r.chip_address = r.payload[offset + 4u];
        r.register_address = r.payload[offset + 5u];
        r.kind = r.register_address == vn135_work_rx_filtered_register(p->chip_selector)
               ? VN135_RX_REGISTER_FILTERED : VN135_RX_REGISTER;
    }
    *out = r;
    return (int)r.kind;
}

/* Stage 7: original candidate materialization, not a complete share verifier.
 * Entry row is selected externally. Raw row word names avoid asserting an
 * unrecovered complete job type. Original 0xc4480..0xc46fc, including the
 * original first-block SHA-256 computation, is compared in nonce_oracle.py.
 */
#include "xminer/recovery/work_nonce.h"
#include "xminer/recovery/sha256_midstate.h"
_Static_assert(sizeof(vn135_nonce_candidate)==VN135_NONCE_CANDIDATE_DEFINED_SIZE,
               "Candidate has 17 contiguous 32-bit words");
_Static_assert(offsetof(vn135_nonce_candidate,midstate)==36u,"Candidate midstate offset");
static uint32_t nonce_le32(const uint8_t *p){
    return p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);
}
static uint32_t nonce_be32(const uint8_t *p){
    return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3];
}
static void nonce_store_be32(uint8_t *p,uint32_t n){
    p[0]=(uint8_t)(n>>24);p[1]=(uint8_t)(n>>16);p[2]=(uint8_t)(n>>8);p[3]=(uint8_t)n;
}
int vn135_work_nonce_version_bits(uint32_t variant,const uint8_t *payload,
                                 size_t size,uint32_t *out)
{
    uint32_t v;
    if(!payload||!out||variant>2u||size<7u+variant)return VN135_NONCE_INVALID;
    v=variant==2u?((uint32_t)payload[6]<<8)|payload[7]:0xffffu;
    *out=(v>>11)|((v&7u)<<21)|((v&0x7f8u)<<5);
    return 0;
}
int vn135_work_nonce_prepare(uint32_t chip_selector,uint32_t variant,uint32_t chain,
    const uint8_t *payload,size_t size,const vn135_work_job_snapshot *job,
    const vn135_nonce_attribution *attribution,vn135_work_nonce_result *out)
{
    vn135_work_nonce_result r={0};
    uint32_t bits;
    if(!payload||!job||!attribution||!attribution->chip_from_nonce||
       !attribution->core_from_nonce||!out||variant>2u||size!=7u+variant)
        return VN135_NONCE_INVALID;
    (void)vn135_work_rx_job_slot(chip_selector,variant,payload,size,&r.candidate.job_slot);
    (void)vn135_work_nonce_version_bits(variant,payload,size,&bits);
    r.candidate.chain_id=chain;
    r.candidate.job_word_a4=nonce_le32(job->bytes+0xa4);
    r.candidate.version_word=nonce_le32(job->bytes+0x78)|bits;
    r.candidate.job_word_70=nonce_le32(job->bytes+0x70);
    r.candidate.job_word_74=nonce_le32(job->bytes+0x74);
    r.candidate.nonce=nonce_be32(payload+(variant==1u?1u:0u));
    r.candidate.chip_id=attribution->chip_from_nonce(attribution->context,r.candidate.nonce);
    r.candidate.core_id=attribution->core_from_nonce(attribution->context,r.candidate.nonce);
    nonce_store_be32(r.compression_block,r.candidate.version_word);
    for(unsigned i=0;i<8;++i)
        nonce_store_be32(r.compression_block+4u+4u*i,nonce_le32(job->bytes+0x84u+4u*i));
    for(unsigned i=0;i<7;++i)
        nonce_store_be32(r.compression_block+36u+4u*i,nonce_le32(job->bytes+0x50u+4u*i));
    (void)vn135_sha256_midstate64(r.compression_block,r.candidate.midstate);
    *out=r;
    return VN135_NONCE_PREPARED;
}
