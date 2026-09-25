/* Offline historical fixture demonstration; no devices, sockets or nonce search. */
#include "xminer/recovery/work_rebuild.h"
#include "../tests/fixtures/genesis_work.h"
#include <stdio.h>
#include <string.h>
static uint32_t get_le(const uint8_t *p){return p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);}
int main(void){
    vn135_rebuild_snapshot s={0};vn135_nonce_candidate c={0};vn135_rebuild_check result;
    uint8_t scratch[sizeof(fixture_coinbase)];uint32_t last=0;
    memcpy(s.header_words_le,fixture_words,112);memset(s.header_words_le+36,0x5a,32);
    s.coinbase=fixture_coinbase;s.coinbase_size=sizeof(fixture_coinbase);
    c.version_word=get_le(fixture_words);c.nonce=get_le(fixture_words+76);
    if(vn135_candidate_verify_snapshot(&c,&s,scratch,sizeof(scratch),fixture_target,&last,0,&result))return 1;
    if(memcmp(result.rebuilt.merkle_root,fixture_root,32)||memcmp(result.work.digest,fixture_hash,32)||
       memcmp(result.work.header_words_le,fixture_words,80)||!result.meets_target)return 1;
    printf("{\"fixture\":\"Bitcoin genesis, not live work\",\"block_hash\":\"");
    for(unsigned i=0;i<32;i++)printf("%02x",result.work.digest[31-i]);
    puts("\",\"header_matches\":true,\"merkle_matches\":true,\"meets_target\":true,\"job_freshness_checked\":false,\"submitted\":false,\"hardware_tested\":false}");
    return 0;
}
