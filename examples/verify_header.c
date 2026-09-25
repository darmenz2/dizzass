/* Offline diagnostic utility, NOT a miner and NOT a pool submission client.
 * Usage: vn135-verify-header <serialized-header:160 hex> <target-LE:64 hex>
 * Exit 0 means computation completed; inspect meets_target, not the exit code. */
#include "xminer/recovery/nonce_verify.h"
#include <stdio.h>
#include <string.h>
static int nibble(char c) {
    if(c>='0'&&c<='9')return c-'0';
    if(c>='a'&&c<='f')return c-'a'+10;
    if(c>='A'&&c<='F')return c-'A'+10;
    return -1;
}
static int parse(const char *s,uint8_t *out,size_t n) {
    if(strlen(s)!=2*n)return -1;
    for(size_t i=0;i<n;i++){int a=nibble(s[2*i]),b=nibble(s[2*i+1]);if(a<0||b<0)return -1;out[i]=(uint8_t)(a*16+b);}
    return 0;
}
int main(int argc,char **argv) {
    uint8_t header[80],target[32],digest[32];
    if(argc!=3||parse(argv[1],header,80)||parse(argv[2],target,32)) {
        fprintf(stderr,"Usage: %s <serialized header:160 hex chars> <target little-endian:64 hex chars>\n",argv[0]);
        return 2;
    }
    if(vn135_sha256d_header80(header,digest))return 2;
    int match=vn135_target256_check_le(digest,target);if(match<0)return 2;
    printf("{\"sha256d_raw\":\"");for(size_t i=0;i<32;i++)printf("%02x",digest[i]);
    printf("\",\"meets_target\":%s,\"job_freshness_checked\":false,\"submitted\":false}\n",match?"true":"false");
    return 0;
}
