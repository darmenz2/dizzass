/* Offline fixture: no raw vendor ABI, pool connection or actual live jobs. */
#include "xminer/recovery/work_storage.h"
#include "xminer/recovery/nonce_verify.h"
#include "../tests/fixtures/genesis_work.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static void *alloc_mem(void *ctx,size_t bytes){(void)ctx;return malloc(bytes);}
static void free_mem(void *ctx,void *p){(void)ctx;free(p);}
int main(void){
    vn135_work_storage source={0},*copy=NULL;vn135_work_memory m={NULL,alloc_mem,free_mem};
    const uint8_t a[]="fixture-job",b[]="fixture-counter",c[]="fixture-time";
    vn135_work_metadata_view v={UINT64_C(0x3ff0000000000000),{a,sizeof(a)-1},{b,sizeof(b)-1},{c,sizeof(c)-1}};
    uint32_t failed=0;uint8_t digest[32];int result=1;
    memcpy(source.image,fixture_words,112);
    if(vn135_frontend_work_metadata_copy_legacy(&source,&v,&m,&failed))goto cleanup;
    if(vn135_work_clone_atomic(&source,1,&m,&copy))goto cleanup;
    if(vn135_frontend_work_storage_clear(&source,&m))goto cleanup;
    if(strcmp(copy->text[0],(const char *)a)||vn135_frontend_hash_words80(copy->image,digest)||memcmp(digest,fixture_hash,32))goto cleanup;
    printf("{\"independent_clone_after_source_clear\":true,\"hash_matches_fixture\":true,\"vendor_abi_compatible\":false,\"job_freshness_checked\":false,\"submitted\":false,\"hardware_tested\":false}\n");result=0;
cleanup:
    (void)vn135_frontend_work_storage_clear(&source,&m);
    (void)vn135_frontend_work_storage_delete(&copy,&m);return result;
}
